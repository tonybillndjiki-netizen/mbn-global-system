import {before,after,test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync,readdirSync} from 'node:fs';
import {PGlite} from '@electric-sql/pglite';
import {storageFixture} from './storage-fixture.ts';
const db=new PGlite();
const root=new URL('../',import.meta.url);
const program='10000000-0000-4000-8000-000000000001';
const evryProgram='10000000-0000-4000-8000-000000000002';
const cescomProgram='10000000-0000-4000-8000-000000000003';
const bachelor1='10000000-0000-4000-8000-000000000004';
const bachelor2='10000000-0000-4000-8000-000000000005';
const base={event:'application_submitted',reference_dossier:'QA-ATOMIC-0001',email:'qa-atomic@example.invalid',full_name:'Synthetic Candidat',school_code:'MLV BTS',campus_code:'NOISIEL',country_of_residence:'France',program_name:'QA BTS',cycle:'BTS',domain:'Commerce',academic_level:'BTS 1',pace:'Initial',source:'DIRECT',consent_email:false};
before(async()=>{
  await db.exec(`create role anon; create role authenticated; create role service_role bypassrls;
    create schema auth;
    create table auth.users(id uuid primary key,email text,raw_user_meta_data jsonb default '{}'::jsonb,email_confirmed_at timestamptz);
    create function auth.uid() returns uuid language sql stable as $$ select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid $$;
    grant usage on schema auth to anon,authenticated,service_role; grant execute on function auth.uid() to anon,authenticated,service_role;`);
  await db.exec(storageFixture);
  for (const name of readdirSync(new URL('supabase/migrations/',root)).filter(n=>n.endsWith('.sql')).sort()) await db.exec(readFileSync(new URL('supabase/migrations/'+name,root),'utf8'));
  await db.exec(`update public.schools set is_active=true where code in ('MLV BTS','EVRY BTS','CESCOM','EMSP');
    insert into public.school_programs(id,school_code,name,cycle,domain,academic_level,is_active) values
    ('${program}','MLV BTS','QA BTS','BTS','Commerce',null,true),
    ('${evryProgram}','EVRY BTS','QA BTS','BTS','Commerce',null,true),
    ('${cescomProgram}','CESCOM','QA Bachelor','Bachelor','Commerce',null,true),
    ('${bachelor1}','EMSP','QA Bachelor','Bachelor','Commerce','Bachelor 1',true),
    ('${bachelor2}','EMSP','QA Bachelor','Bachelor','Commerce','Bachelor 2',true);`);
});
after(async()=>db.close());
async function isolated(run:()=>Promise<void>){await db.exec('begin');try{await run();}finally{await db.exec('rollback');}}
async function rpc(payload:Record<string,unknown>){
  await db.exec('savepoint invoke_rpc;set local role service_role');
  try {const result=await db.query<{result:{success:boolean;duplicated:boolean;outreach_canceled?:number}}>('select public.mbn_ingest_application($1::jsonb) as result',[JSON.stringify(payload)]);await db.exec('reset role;release savepoint invoke_rpc');return result.rows[0].result;}
  catch(error){await db.exec('rollback to savepoint invoke_rpc;release savepoint invoke_rpc');throw error;}
}
async function fails(payload:Record<string,unknown>,code:string){await assert.rejects(rpc(payload),(error:unknown)=>(error as {code:string}).code===code);}
async function count(table:string){return Number((await db.query<{n:number}>('select count(*) as n from public.'+table)).rows[0].n);}
test('transaction writes one prospect, application and event',()=>isolated(async()=>{
  assert.equal((await rpc(base)).duplicated,false);
  for(const table of ['crm_leads','crm_applications','crm_lead_events'])assert.equal(await count(table),1);
  const row=(await db.query<{program_id:string;admission_type:string;form_payload:unknown}>('select program_id,admission_type,form_payload from public.crm_applications')).rows[0];
  assert.equal(row.program_id,program);assert.equal(row.admission_type,'NATIONAL');
}));
test('replay creates no additional prospect, application or event',()=>isolated(async()=>{
  await rpc(base);assert.equal((await rpc(base)).duplicated,true);
  for(const table of ['crm_leads','crm_applications','crm_lead_events'])assert.equal(await count(table),1);
}));
test('same reference with a different email fails without an orphan prospect',()=>isolated(async()=>{
  await rpc(base);await fails({...base,email:'another@example.invalid'},'PT409');assert.equal(await count('crm_leads'),1);
}));
test('same reference with a different explicit program id is rejected',()=>isolated(async()=>{
  await rpc(base);await fails({...base,program_id:evryProgram},'PT409');assert.equal(await count('crm_applications'),1);
}));
test('same reference from a different school is not acknowledged as a harmless replay',()=>isolated(async()=>{
  await rpc(base);await fails({...base,school_code:'EVRY BTS',campus_code:'EVRY'},'PT409');assert.equal(await count('crm_leads'),1);
}));
test('disabled school blocks new submissions, but preserves acknowledgement of accepted submissions',()=>isolated(async()=>{
  await rpc(base);await db.exec("update public.schools set is_active=false where code='MLV BTS'");
  assert.equal((await rpc(base)).duplicated,true);await fails({...base,reference_dossier:'QA-ATOMIC-0002'},'PT422');
}));
test('wrong campus never creates a record',()=>isolated(async()=>{await fails({...base,campus_code:'LYON'},'PT422');assert.equal(await count('crm_leads'),0);}));
test('program belonging to another school is rejected',()=>isolated(async()=>{await fails({...base,program_id:evryProgram},'PT422');assert.equal(await count('crm_applications'),0);}));
test('unknown or disabled program never becomes a null program match',()=>isolated(async()=>{
  await fails({...base,program_name:'Unknown'},'PT422');await db.exec(`update public.school_programs set is_active=false where id='${program}'`);await fails(base,'PT422');
}));
test('a repeated title is ambiguous until the academic level selects an exact combination',()=>isolated(async()=>{
  const b={...base,school_code:'EMSP',campus_code:'TORCY',program_name:'QA Bachelor',cycle:'Bachelor',academic_level:''};
  await fails(b,'PT422');await rpc({...b,academic_level:'Bachelor 2'});
  assert.equal((await db.query<{program_id:string}>('select program_id from public.crm_applications')).rows[0].program_id,bachelor2);
}));
test('CESCOM PARIS alias routes to the registered Noisiel campus',()=>isolated(async()=>{
  await rpc({...base,school_code:'CESCOM PARIS',campus_code:'PARIS',program_name:'QA Bachelor',cycle:'Bachelor'});
  const row=(await db.query<{school_code:string;campus_code:string}>('select school_code,campus_code from public.crm_applications')).rows[0];
  assert.deepEqual(row,{school_code:'CESCOM',campus_code:'NOISIEL'});
}));
test('Evry BTS uses its own program id',()=>isolated(async()=>{await rpc({...base,school_code:'EVRY BTS',campus_code:'EVRY'});assert.equal((await db.query<{program_id:string}>('select program_id from public.crm_applications')).rows[0].program_id,evryProgram);}));
test('international residence is classified without modifying the original data',()=>isolated(async()=>{await rpc({...base,country_of_residence:'Cameroun'});assert.equal((await db.query<{admission_type:string}>('select admission_type from public.crm_applications')).rows[0].admission_type,'INTERNATIONAL');}));
test('submission keeps original acquisition and opt out, and cancels both queued sequences',()=>isolated(async()=>{
  const {rows:[lead]}=await db.query<{id:string}>(`insert into public.crm_leads(school_code,source,source_external_id,full_name,email,status,consent_email,unsubscribed_at) values('MLV BTS','META_LEAD','META-42','Synthetic Candidat',$1,'UNSUBSCRIBED',false,now()) returning id`,[base.email]);
  await db.query(`insert into public.crm_outreach_queue(lead_id,sequence_type,attempt_number,scheduled_at,status) values
    ($1,'META_UNCLICKED',0,now(),'PENDING'),($1,'META_UNCLICKED',1,now(),'FAILED'),
    ($1,'META_UNCLICKED',2,now(),'SENT'),($1,'CLICKED_NOT_SUBMITTED',0,now(),'PENDING')`,[lead.id]);
  const result=await rpc({...base,consent_email:true});assert.equal(result.outreach_canceled,3);assert.equal(await count('crm_leads'),1);
  const row=(await db.query<{status:string;source:string;source_external_id:string;consent_email:boolean;submitted:boolean}>('select status,source,source_external_id,consent_email,submitted_at is not null as submitted from public.crm_leads')).rows[0];
  assert.deepEqual(row,{status:'UNSUBSCRIBED',source:'META_LEAD',source_external_id:'META-42',consent_email:false,submitted:true});
  assert.equal(Number((await db.query<{n:number}>("select count(*) as n from public.crm_outreach_queue where status='CANCELED'")).rows[0].n),3);
}));
test('ambiguous prospect identity requires review rather than an arbitrary merge',()=>isolated(async()=>{
  await db.query(`insert into public.crm_leads(school_code,source,full_name,email) values('MLV BTS','META_LEAD','Synthetic A',$1),('MLV BTS','DIRECT','Synthetic B',$1)`,[base.email]);
  await fails(base,'PT409');assert.equal(await count('crm_applications'),0);assert.equal(await count('crm_leads'),2);
}));
test('event storage failure rolls back every earlier write',()=>isolated(async()=>{
  await db.exec(`create function pg_temp.fail_event() returns trigger language plpgsql as $$ begin raise exception 'synthetic_event_failure';end;$$;
    create trigger qa_fail_event before insert on public.crm_lead_events for each row execute function pg_temp.fail_event()`);
  await fails(base,'P0001');for(const table of ['crm_leads','crm_applications','crm_lead_events'])assert.equal(await count(table),0);
}));
test('RPC is invoker-only and unavailable to anonymous and normal signed-in roles',()=>isolated(async()=>{
  const row=(await db.query<{definer:boolean;anon:boolean;staff:boolean;server:boolean}>(`select p.prosecdef as definer,has_function_privilege('anon',p.oid,'EXECUTE') as anon,has_function_privilege('authenticated',p.oid,'EXECUTE') as staff,has_function_privilege('service_role',p.oid,'EXECUTE') as server from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname='mbn_ingest_application'`)).rows[0];
  assert.deepEqual(row,{definer:false,anon:false,staff:false,server:true});
}));
test('birth date, disability and attachments do not enter the stored form payload',()=>isolated(async()=>{
  await rpc({...base,date_naissance:'private',handicap:'private',attachments:['private']});
  const raw=JSON.stringify((await db.query('select form_payload from public.crm_applications')).rows);
  assert.ok(!raw.includes('private'));assert.ok(!raw.includes('date_naissance'));
}));
