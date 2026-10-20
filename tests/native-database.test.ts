import {before,after,test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync,readdirSync} from 'node:fs';
import {PGlite} from '@electric-sql/pglite';
import {storageFixture} from './storage-fixture.ts';
const db=new PGlite(),root=new URL('../',import.meta.url);
const actor='20000000-0000-4000-8000-000000000001';
const staff='20000000-0000-4000-8000-000000000002';
const program='10000000-0000-4000-8000-000000000001';
const base={event:'application_submitted',reference_dossier:'MBNTEST-50000000-0000-4000-8000-000000000001',email:'native@example.invalid',full_name:'Synthetic Native',school_code:'MLV BTS',campus_code:'NOISIEL',country_of_residence:'France',program_id:program,program_name:'QA BTS',source:'DIRECT',consent_email:false};
const doc={kind:'CV',original_name:'cv.pdf',mime_type:'application/pdf',extension:'pdf',byte_size:100,sha256:'a'.repeat(64)};
before(async()=>{
  await db.exec(`create role anon;create role authenticated;create role service_role bypassrls;create schema auth;
    create table auth.users(id uuid primary key,email text,raw_user_meta_data jsonb default '{}'::jsonb,email_confirmed_at timestamptz);
    create function auth.uid() returns uuid language sql stable as $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;
    grant usage on schema auth to anon,authenticated,service_role;grant execute on function auth.uid() to anon,authenticated,service_role;`);
  await db.exec(storageFixture);
  for(const file of readdirSync(new URL('supabase/migrations/',root)).filter(n=>n.endsWith('.sql')).sort())await db.exec(readFileSync(new URL('supabase/migrations/'+file,root),'utf8'));
  await db.exec("insert into private.admin_allowlist(email) values ('nbtonybill@gmail.com') on conflict do nothing");
  await db.exec(`insert into auth.users(id,email,email_confirmed_at) values('${actor}','nbtonybill@gmail.com',now()),('${staff}','staff@example.invalid',now());
    update public.profiles set is_active=true;
    insert into public.school_memberships(user_id,school_code,role,is_active) values('${staff}','MLV BTS','ADMISSIONS',true);
    update public.schools set is_active=true where code='MLV BTS';
    insert into public.school_programs(id,school_code,name,is_active) values('${program}','MLV BTS','QA BTS',true);`);
});
after(async()=>db.close());
async function isolated(run:()=>Promise<void>){await db.exec('begin');try{await run();}finally{await db.exec('rollback');}}
async function rpc(name:string,args:unknown[]){
  await db.exec('savepoint call;set local role service_role');
  try{const {rows}=await db.query<{result:Record<string,unknown>}>(`select public.${name}(${args.map((_,i)=>'$'+(i+1)).join(',')}) as result`,args);await db.exec('reset role;release savepoint call');return rows[0].result;}
  catch(error){await db.exec('rollback to savepoint call;release savepoint call');throw error;}
}
const prepare=(payload=base,manifest=[doc],a=actor,hash='b'.repeat(64),details={})=>rpc('mbn_prepare_native_test',[a,JSON.stringify(payload),JSON.stringify(details),JSON.stringify(manifest),hash]);
const complete=(id:unknown,a=actor)=>rpc('mbn_complete_native_test',[a,id]);
async function stored(id:unknown,document=doc){await db.query(`insert into storage.objects(bucket_id,name,metadata) values('mbn-native-test',$1,$2::jsonb)`,[`${id}/${document.kind}.${document.extension}`,JSON.stringify({size:document.byte_size,mimetype:document.mime_type})]);}
async function n(table:string){return Number((await db.query<{n:number}>(`select count(*) as n from public.${table}`)).rows[0].n);}
const hasCode=(code:string)=>(error:unknown)=>(error as {code:string}).code===code;
test('reserve a native form without creating a premature CRM application',()=>isolated(async()=>{
  const draft=await prepare();assert.equal(draft.completed,false);assert.equal(await n('native_test_submissions'),1);assert.equal(await n('crm_applications'),0);
}));
test('pending files prevent completion and preserve a resumable draft',()=>isolated(async()=>{
  const draft=await prepare();await assert.rejects(complete(draft.submission_id),hasCode('PT409'));
  assert.equal(await n('crm_leads'),0);assert.equal((await prepare()).submission_id,draft.submission_id);
}));
test('native completion atomically creates the test CRM application and private document metadata',()=>isolated(async()=>{
  const draft=await prepare();await stored(draft.submission_id);const result=await complete(draft.submission_id);
  assert.equal(result.success,true);assert.equal(result.test,true);assert.equal(result.document_count,1);
  assert.equal(await n('crm_leads'),1);assert.equal(await n('crm_applications'),1);assert.equal(await n('application_documents'),1);
  const {rows:[row]}=await db.query(`select is_test,source_system from public.crm_applications`);
  assert.deepEqual(row,{is_test:true,source_system:'MBN_SUPABASE_NATIVE_TEST'});
}));
test('replaying a completed reference creates no additional document, event or application',()=>isolated(async()=>{
  const draft=await prepare();await stored(draft.submission_id);await complete(draft.submission_id);
  assert.equal((await complete(draft.submission_id)).duplicated,true);assert.equal((await prepare()).completed,true);
  for(const t of ['crm_applications','crm_lead_events','application_documents'])assert.equal(await n(t),1);
}));
test('a changed form or changed document under an existing reference is refused',()=>isolated(async()=>{
  await prepare();await assert.rejects(prepare({...base,full_name:'Different'}),hasCode('PT409'));
  await assert.rejects(prepare(base,[{...doc,sha256:'c'.repeat(64)}]),hasCode('PT409'));
  await assert.rejects(prepare(base,[doc],actor,'b'.repeat(64),{ville:'Other'}),hasCode('PT409'));
}));
test('a test submission never merges a real prospect or cancels its reminders',()=>isolated(async()=>{
  const {rows:[lead]}=await db.query<{id:string}>(`insert into public.crm_leads(school_code,source,full_name,email,status) values('MLV BTS','META_LEAD','Real-context fixture',$1,'INVITED') returning id`,[base.email]);
  await db.query(`insert into public.crm_outreach_queue(lead_id,sequence_type,attempt_number,scheduled_at) values($1,'META_UNCLICKED',0,now())`,[lead.id]);
  const draft=await prepare(base,[]);await complete(draft.submission_id);
  assert.equal(await n('crm_leads'),2);assert.equal((await db.query(`select status from public.crm_outreach_queue`)).rows[0].status,'PENDING');
}));
test('unconfirmed, suspended and non-admin accounts cannot reserve or complete native tests',()=>isolated(async()=>{
  await assert.rejects(prepare(base,[],staff),hasCode('PT403'));
  const draft=await prepare(base,[]);await db.query(`update public.profiles set is_active=false where user_id=$1`,[actor]);
  await assert.rejects(complete(draft.submission_id),hasCode('PT403'));
  await db.query(`update public.profiles set is_active=true where user_id=$1;`,[actor]);
  await db.query(`update auth.users set email_confirmed_at=null where id=$1`,[actor]);
  await assert.rejects(complete(draft.submission_id),hasCode('PT403'));
}));
test('active staff school membership does not expose test forms or sensitive documents',()=>isolated(async()=>{
  const draft=await prepare();await stored(draft.submission_id);await complete(draft.submission_id);
  await db.exec(`set local role authenticated;select set_config('request.jwt.claim.sub','${staff}',true);`);
  for(const table of ['native_test_submissions','application_documents'])assert.equal(await n(table),0);
  for(const table of ['crm_applications','crm_leads','crm_lead_events']){
    await db.exec('savepoint denied_read');await assert.rejects(n(table),hasCode('42501'));await db.exec('rollback to savepoint denied_read');
  }
  await db.exec('reset role');
}));
test('active confirmed administrators can review documents but cannot mutate their metadata directly',()=>isolated(async()=>{
  const draft=await prepare();await stored(draft.submission_id);await complete(draft.submission_id);
  await db.exec(`set local role authenticated;select set_config('request.jwt.claim.sub','${actor}',true);`);
  assert.equal(await n('application_documents'),1);assert.equal(await n('native_test_submissions'),1);
  assert.equal((await db.query(`select public.mbn_native_admin_access() as ok`)).rows[0].ok,true);
  await db.exec('savepoint denied');await assert.rejects(db.exec('delete from public.application_documents'),hasCode('42501'));await db.exec('rollback to savepoint denied;reset role');
}));
test('a document metadata failure rolls back CRM creation and keeps the draft resumable',()=>isolated(async()=>{
  const draft=await prepare();await stored(draft.submission_id);
  await db.exec(`create function pg_temp.fail_document() returns trigger language plpgsql as $$begin raise exception 'synthetic failure';end;$$;
    create trigger qa_fail_document before insert on public.application_documents for each row execute function pg_temp.fail_document()`);
  await assert.rejects(complete(draft.submission_id),hasCode('P0001'));
  for(const table of ['crm_leads','crm_applications','crm_lead_events','application_documents'])assert.equal(await n(table),0);
  assert.equal((await prepare()).completed,false);
}));
test('storage metadata must match expected size and MIME type before CRM completion',()=>isolated(async()=>{
  const draft=await prepare();await stored(draft.submission_id,{...doc,byte_size:99});
  await assert.rejects(complete(draft.submission_id),hasCode('PT409'));assert.equal(await n('crm_applications'),0);
}));
test('the test bucket stays private and a broad future user policy cannot expose it',()=>isolated(async()=>{
  const draft=await prepare();await stored(draft.submission_id);
  assert.equal((await db.query(`select public from storage.buckets where id='mbn-native-test'`)).rows[0].public,false);
  await db.exec(`create policy qa_broad on storage.objects for select to authenticated using(true);grant select on storage.objects to authenticated;
    set local role authenticated;select set_config('request.jwt.claim.sub','${actor}',true)`);
  assert.equal((await db.query('select * from storage.objects')).rows.length,0);await db.exec('reset role');
}));
test('native write and document RPCs are invokers callable only by the backend service',()=>isolated(async()=>{
  const {rows}=await db.query<{prosecdef:boolean;anon:boolean;staff:boolean;server:boolean}>(`select prosecdef,has_function_privilege('anon',p.oid,'EXECUTE') as anon,
    has_function_privilege('authenticated',p.oid,'EXECUTE') as staff,has_function_privilege('service_role',p.oid,'EXECUTE') as server from pg_proc p join pg_namespace n on n.oid=p.pronamespace
    where n.nspname='public' and p.proname in ('mbn_prepare_native_test','mbn_complete_native_test','mbn_native_document')`);
  assert.equal(rows.length,3);for(const row of rows)assert.deepEqual(row,{prosecdef:false,anon:false,staff:false,server:true});
}));
