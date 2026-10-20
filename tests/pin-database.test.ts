import {before,after,test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync,readdirSync} from 'node:fs';
import {PGlite} from '@electric-sql/pglite';
import {storageFixture} from './storage-fixture.ts';
const db=new PGlite(),root=new URL('../',import.meta.url);
const actor='20000000-0000-4000-8000-000000000001',staff='20000000-0000-4000-8000-000000000002',sid='60000000-0000-4000-8000-000000000001';
before(async()=>{
 await db.exec(`create role anon;create role authenticated;create role service_role bypassrls;create schema auth;
 create table auth.users(id uuid primary key,email text,raw_user_meta_data jsonb default '{}'::jsonb,email_confirmed_at timestamptz);
 create function auth.uid() returns uuid language sql stable as $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;
 grant usage on schema auth to anon,authenticated,service_role;grant execute on function auth.uid() to anon,authenticated,service_role;`);
 await db.exec(storageFixture);
 for(const file of readdirSync(new URL('supabase/migrations/',root)).filter(n=>n.endsWith('.sql')).sort())await db.exec(readFileSync(new URL('supabase/migrations/'+file,root),'utf8'));
 await db.exec("insert into private.admin_allowlist(email) values ('nbtonybill@gmail.com') on conflict do nothing");
 await db.exec(`insert into auth.users(id,email,email_confirmed_at) values('${actor}','nbtonybill@gmail.com',now()),('${staff}','staff@example.invalid',now());update public.profiles set is_active=true;
 insert into auth.sessions(id,user_id) values('${sid}','${actor}');
 insert into private.app_credentials(user_id,username_key,display_name) values('${actor}','tony bill','Tony Bill');`);
});
after(async()=>db.close());
async function isolated(run:()=>Promise<void>){await db.exec('begin');try{await run();}finally{await db.exec('rollback');}}
async function rpc(name:string,args:unknown[]){await db.exec('savepoint call;set local role service_role');try{const {rows}=await db.query<{v:any}>(`select public.${name}(${args.map((_,i)=>'$'+(i+1)).join(',')}) as v`,args);await db.exec('reset role;release savepoint call');return rows[0].v;}catch(error){await db.exec('rollback to savepoint call;release savepoint call');throw error;}}
async function version(){return (await db.query<{version:string}>('select version from private.app_credentials where user_id=$1',[actor])).rows[0].version;}
const context=(who=actor,session=sid,target=actor)=>rpc('mbn_pin_context',[who,session,target]);
const setup=async(target=actor,key='tony bill')=>rpc('mbn_pin_configure',[actor,sid,target,await version(),key,target===actor?'Tony Bill':'Staff Test','a'.repeat(64),'b'.repeat(32)]);
const begin=(key='tony bill')=>rpc('mbn_pin_begin',[key]);
const finish=(key:string,ticket:string,ok:boolean,ver:string|null)=>rpc('mbn_pin_finish',[key,ticket,ok,ver]);
const hasCode=(code:string)=>(error:unknown)=>(error as {code:string}).code===code;
test('the requested username can be reserved without installing a chat-disclosed code',()=>isolated(async()=>{const c=await context();assert.equal(c.target.username,'Tony Bill');assert.equal(c.target.configured,false);}));
test('initial enrollment requires a recent real auth session',()=>isolated(async()=>{await db.exec("update auth.sessions set created_at=now()-interval '1 hour'");assert.equal((await context()).actor.fresh,false);await assert.rejects(setup(),hasCode('PT403'));}));
test('an administrator can configure another account without activating it',()=>isolated(async()=>{await db.query('update public.profiles set is_active=false where user_id=$1',[staff]);await setup(staff,'staff test');assert.equal((await db.query('select is_active from public.profiles where user_id=$1',[staff])).rows[0].is_active,false);assert.equal((await begin('staff test')).credential,null);}));
test('an active non-admin cannot configure someone else access',()=>isolated(async()=>{const other='60000000-0000-4000-8000-000000000002';await db.query('insert into auth.sessions(id,user_id) values($1,$2)',[other,staff]);await assert.rejects(context(staff,other,actor),hasCode('PT403'));}));
test('duplicate usernames are rejected without changing the first user credentials',()=>isolated(async()=>{await setup();await assert.rejects(setup(staff,'tony bill'),hasCode('PT409'));assert.equal(Number((await db.query('select count(*) as n from private.app_credentials')).rows[0].n),1);}));
test('concurrent guesses cannot get multiple live leases for one username',()=>isolated(async()=>{await setup();assert.equal((await begin()).blocked,false);assert.equal((await begin()).blocked,true);}));
test('five failed attempts trigger the temporary limit',()=>isolated(async()=>{await setup();for(let i=0;i<5;i++){const a=await begin();assert.equal(a.blocked,false);assert.equal((await finish('tony bill',a.ticket,false,null)).allowed,false);}assert.equal((await begin()).blocked,true);}));
test('daily failures cannot be bypassed by waiting for a new short window',()=>isolated(async()=>{await setup();await begin();await db.exec("update private.pin_attempts set lease_until=null,day_attempts=20,period_start=now()-interval '1 hour' where username_key='tony bill'");assert.equal((await begin()).blocked,true);}));
test('unknown usernames pass through the same rate-limited ticket process',()=>isolated(async()=>{const a=await begin('unknown user');assert.equal(a.credential,null);assert.match(a.ticket,/^[a-f0-9-]{36}$/);assert.equal((await finish('unknown user',a.ticket,false,null)).allowed,false);}));
test('an unrelated or expired ticket cannot acknowledge a successful PIN',()=>isolated(async()=>{await setup();const a=await begin();const ver=await version();assert.equal((await finish('tony bill',actor,true,ver)).allowed,false);await db.exec("update private.pin_attempts set lease_until=now()-interval '1 minute' where username_key='tony bill'");assert.equal((await finish('tony bill',a.ticket,true,ver)).allowed,false);}));
test('a suspended, banned, unconfirmed or MFA-protected account cannot use a PIN session',()=>isolated(async()=>{
 await setup();for(const mutation of ["update public.profiles set is_active=false where email='nbtonybill@gmail.com'","update auth.users set banned_until=now()+interval '1 day' where email='nbtonybill@gmail.com'","update auth.users set email_confirmed_at=null where email='nbtonybill@gmail.com'",`insert into auth.mfa_factors(user_id,status) values('${actor}','verified')`]){
  await db.exec('savepoint state');await db.exec(mutation);assert.equal((await begin()).credential,null);await db.exec('rollback to savepoint state');
 }
}));
test('PIN changes revoke earlier PIN sessions in the shared access checks',()=>isolated(async()=>{
 await setup();const old=await version();assert.equal(await rpc('mbn_pin_register_session',[actor,old,sid]),true);
 await setup();await db.exec(`set local role authenticated;select set_config('request.jwt.claim.sub','${actor}',true);select set_config('request.jwt.claims','{"session_id":"${sid}"}',true)`);
 assert.equal((await db.query('select private.is_mbn_admin() as allowed')).rows[0].allowed,false);await db.exec('reset role');
}));
test('signing out a PIN session prevents its old token from reading protected data',()=>isolated(async()=>{
 await setup();assert.equal(await rpc('mbn_pin_register_session',[actor,await version(),sid]),true);await db.query('delete from auth.sessions where id=$1',[sid]);
 await db.exec(`set local role authenticated;select set_config('request.jwt.claim.sub','${actor}',true);select set_config('request.jwt.claims','{"session_id":"${sid}"}',true)`);
 assert.equal((await db.query('select private.is_mbn_admin() as allowed')).rows[0].allowed,false);await db.exec('reset role');
}));
test('codes, hashes and salts are never readable by ordinary authenticated callers',()=>isolated(async()=>{await setup();await db.exec(`set local role authenticated;select set_config('request.jwt.claim.sub','${actor}',true);savepoint denied`);await assert.rejects(db.query('select * from private.app_credentials'),hasCode('42501'));await db.exec('rollback to savepoint denied;reset role');}));
test('credential RPCs are invokers and are callable only by the backend',()=>isolated(async()=>{
 const {rows}=await db.query<{prosecdef:boolean;anon:boolean;staff:boolean;server:boolean}>(`select prosecdef,has_function_privilege('anon',p.oid,'EXECUTE') as anon,has_function_privilege('authenticated',p.oid,'EXECUTE') as staff,has_function_privilege('service_role',p.oid,'EXECUTE') as server from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname like 'mbn_pin_%'`);
 assert.equal(rows.length,5);for(const row of rows)assert.deepEqual(row,{prosecdef:false,anon:false,staff:false,server:true});
}));
