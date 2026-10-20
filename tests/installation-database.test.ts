import {before,after,test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync,readdirSync} from 'node:fs';
import {PGlite} from '@electric-sql/pglite';
import {storageFixture} from './storage-fixture.ts';
import {catalogFromForms,catalogSeed} from '../scripts/export_catalog.mjs';
const root=new URL('../',import.meta.url),db=new PGlite();
const owner='70000000-0000-4000-8000-000000000001',second='70000000-0000-4000-8000-000000000002';
before(async()=>{
 await db.exec(`create role anon;create role authenticated;create role service_role bypassrls;create schema auth;
 create table auth.users(id uuid primary key,email text,raw_user_meta_data jsonb default '{}'::jsonb,email_confirmed_at timestamptz,is_anonymous boolean default false);
 create function auth.uid() returns uuid language sql stable as $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;
 grant usage on schema auth to anon,authenticated,service_role;grant execute on function auth.uid() to anon,authenticated,service_role;`);
 await db.exec(storageFixture);
 // Only Supabase platform services are simulated. Every application object comes from production migrations.
 await db.exec(`create schema vault;create table vault.decrypted_secrets(id uuid primary key,decrypted_secret text);
 create function vault.create_secret(new_secret text,new_name text default null,new_description text default '',new_key_id uuid default null)
 returns uuid language plpgsql as $$declare v_id uuid:=gen_random_uuid();begin insert into vault.decrypted_secrets values(v_id,new_secret);return v_id;end;$$;`);
 for(const file of readdirSync(new URL('supabase/migrations/',root)).filter(f=>f.endsWith('.sql')).sort())await db.exec(readFileSync(new URL('supabase/migrations/'+file,root),'utf8'));
 await db.exec(readFileSync(new URL('supabase/seed.sql',root),'utf8'));
});
after(async()=>db.close());
async function isolated(run:()=>Promise<void>){await db.exec('begin');try{await run();}finally{await db.exec('rollback');}}
async function call(name:string,args:unknown[]){
 await db.exec('savepoint rpc;set local role service_role');
 try{const r=await db.query<any>(`select public.${name}(${args.map((_,i)=>'$'+(i+1)).join(',')}) as result`,args);await db.exec('reset role;release savepoint rpc');return r.rows[0].result;}
 catch(e){await db.exec('rollback to savepoint rpc;release savepoint rpc');throw e;}
}
const hasCode=(code:string)=>(error:unknown)=>(error as {code:string}).code===code;
test('a fresh installation contains every school and catalog choice without granting an owner or enabling sends',async()=>{
 assert.deepEqual((await db.query(`select (select count(*)::int from public.schools) as schools,(select count(*)::int from public.school_programs) as programs,(select count(*)::int from private.admin_allowlist) as owners,(select count(*)::int from public.school_programs where is_active) as active_programs,(select count(*)::int from private.mbn_installation_settings) as targets`)).rows[0],{schools:19,programs:1275,owners:0,active_programs:0,targets:0});
 assert.equal((await db.query(`select enabled from private.mbn_mail_settings where id`)).rows[0].enabled,false);
 assert.equal((await db.query(`select enabled from private.mbn_scan_settings where id`)).rows[0].enabled,false);
 assert.equal((await db.query(`select count(*)::int as n from private.mbn_runtime_secrets r join vault.decrypted_secrets d on d.id=r.vault_id`)).rows[0].n,3);
});
test('the committed seed exactly follows the literal active forms and keeps existing activation decisions',()=>isolated(async()=>{
 assert.equal(readFileSync(new URL('supabase/seed.sql',root),'utf8'),catalogSeed(catalogFromForms()));
 await db.exec(`update public.school_programs set is_active=true,review_status='VALIDATED' where id=(select id from public.school_programs order by id limit 1)`);
 await db.exec(readFileSync(new URL('supabase/seed.sql',root),'utf8'));
 assert.deepEqual((await db.query(`select count(*)::int as total,count(*) filter(where is_active)::int as active from public.school_programs`)).rows[0],{total:1275,active:1});
}));
test('only a confirmed non-anonymous owner can bootstrap a fresh installation',()=>isolated(async()=>{
 await db.query('insert into auth.users(id,email) values($1,$2)',[owner,'owner@example.invalid']);
 await assert.rejects(call('mbn_installation_bootstrap_owner',['owner@example.invalid']),hasCode('PT422'));
 await db.exec('update auth.users set email_confirmed_at=now(),is_anonymous=true');
 await assert.rejects(call('mbn_installation_bootstrap_owner',['owner@example.invalid']),hasCode('PT422'));
 await db.exec('update auth.users set is_anonymous=false');
 // An Auth account may have existed before the application trigger was installed.
 await db.exec('delete from public.profiles');
 assert.equal((await call('mbn_installation_bootstrap_owner',['owner@example.invalid'])).configured,true);
 assert.equal((await db.query('select is_active from public.profiles where user_id=$1',[owner])).rows[0].is_active,true);
 assert.equal((await call('mbn_installation_bootstrap_owner',['owner@example.invalid'])).already_configured,true);
 await db.query('insert into auth.users(id,email,email_confirmed_at) values($1,$2,now())',[second,'second@example.invalid']);
 await assert.rejects(call('mbn_installation_bootstrap_owner',['second@example.invalid']),hasCode('PT409'));
}));
test('installation configuration validates target origins and cannot be called from the browser',()=>isolated(async()=>{
 for(const origin of ['https://example.invalid/path','http://example.invalid','https://example.invalid:444'])await assert.rejects(call('mbn_installation_configure',['https://abcdefghijklmnopqrst.supabase.co',origin,'a'.repeat(40)]),hasCode('PT422'));
 assert.equal((await call('mbn_installation_configure',['https://abcdefghijklmnopqrst.supabase.co','https://mbn-staging.netlify.app','a'.repeat(40)])).configured,true);
 const rows=(await db.query<any>(`select has_function_privilege('anon',p.oid,'EXECUTE') as anon,has_function_privilege('authenticated',p.oid,'EXECUTE') as browser,has_function_privilege('service_role',p.oid,'EXECUTE') as backend from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname in ('mbn_installation_configure','mbn_installation_bootstrap_owner')`)).rows;
 assert.equal(rows.length,2);for(const row of rows)assert.deepEqual(row,{anon:false,browser:false,backend:true});
}));
test('fresh scheduler functions use the installation target and return without it',async()=>{
 await db.exec('select private.mbn_mail_tick();select private.mbn_meta_tick()');
 const definitions=(await db.query<any>(`select pg_get_functiondef(p.oid) as definition from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='private' and p.proname in ('mbn_mail_tick','mbn_meta_tick')`)).rows;
 for(const row of definitions){assert.ok(row.definition.includes('mbn_installation_settings'));assert.ok(!row.definition.includes('ppqeuluykiknuujfaoid'));}
});
