import {before,after,test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync,readdirSync} from 'node:fs';
import {PGlite} from '@electric-sql/pglite';
import {storageFixture} from './storage-fixture.ts';
const root=new URL('../',import.meta.url),db=new PGlite();
const owner='20000000-0000-4000-8000-000000000001',cm='20000000-0000-4000-8000-000000000002',reviewer='20000000-0000-4000-8000-000000000003',other='20000000-0000-4000-8000-000000000004';
const sid=(id:string)=>id.replace('20000000','30000000');
const program='10000000-0000-4000-8000-000000000001';
before(async()=>{
 await db.exec(`create role anon;create role authenticated;create role service_role bypassrls;create schema auth;
 create table auth.users(id uuid primary key,email text,raw_user_meta_data jsonb default '{}'::jsonb,email_confirmed_at timestamptz);
 create function auth.uid() returns uuid language sql stable as $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;
 grant usage on schema auth to anon,authenticated,service_role;grant execute on function auth.uid() to anon,authenticated,service_role;`);
 await db.exec(readFileSync(new URL('tests/fixtures/remote-baseline.sql',root),'utf8'));await db.exec(storageFixture);
 // Match the hosted Vault signature, including its defaulted fourth argument.
 await db.exec(`create schema vault;create table vault.decrypted_secrets(id uuid primary key,decrypted_secret text);
 create function vault.create_secret(new_secret text,new_name text default null,new_description text default '',new_key_id uuid default null)
 returns uuid language plpgsql as $$declare v_id uuid:=gen_random_uuid();begin insert into vault.decrypted_secrets values(v_id,new_secret);return v_id;end;$$;`);
 for(const file of readdirSync(new URL('supabase/migrations/',root)).filter(f=>f.endsWith('.sql')).sort())await db.exec(readFileSync(new URL('supabase/migrations/'+file,root),'utf8'));
 await db.exec(`insert into auth.users(id,email,email_confirmed_at) values('${owner}','nbtonybill@gmail.com',now()),('${cm}','cm@example.invalid',now()),('${reviewer}','reviewer@example.invalid',now()),('${other}','other@example.invalid',now());
 update public.profiles set is_active=true;insert into auth.sessions(id,user_id) select replace(id::text,'20000000','30000000')::uuid,id from auth.users;
 update public.schools set is_active=true,slug=lower(replace(code,' ','-'));update public.schools set name='Marne-la-Vallée BTS' where code='MLV BTS';insert into public.school_programs(id,school_code,name,cycle,is_active) values('${program}','MLV BTS','Synthetic BTS','BTS',true);
 insert into public.school_memberships(user_id,school_code,role,is_active,can_review_documents) values('${cm}','MLV BTS','CM',true,false),('${reviewer}','MLV BTS','ADMISSIONS',true,true),('${other}','EMSP','DIRECTION',true,true);`);
});
after(()=>db.close());
async function isolated(fn:()=>Promise<void>){await db.exec('begin');try{await fn();}finally{await db.exec('rollback');}}
async function invoke(name:string,args:unknown[]=[]){await db.exec('savepoint call_api;set local role service_role');try{const r=await db.query<{v:any}>('select public.'+name+'('+args.map((_,i)=>'$'+(i+1)).join(',')+') as v',args);await db.exec('reset role;release savepoint call_api');return r.rows[0].v;}catch(e){await db.exec('rollback to savepoint call_api;release savepoint call_api');throw e;}}
const action=(name:string,data:object={},actor=owner)=>invoke('mbn_workspace_action',[actor,sid(actor),name,JSON.stringify(data)]);
const lead=(overrides={})=>({school_code:'MLV BTS',full_name:'Synthetic Prospect',email:'synthetic@example.invalid',source:'META_LEAD',consent_email:true,consent_source:'Synthetic explicit form consent',...overrides});
test('runtime keys initialize against the real defaulted Vault signature and remain service-only',()=>isolated(async()=>{
 assert.equal((await db.query<{n:number}>('select count(*)::int n from private.mbn_runtime_secrets')).rows[0].n,3);
 assert.ok(String(await invoke('mbn_runtime_key',['brevo_webhook'])).length>=80);
 assert.ok(String(await invoke('mbn_runtime_key',['link'])).length>=80);
 const {rows:[permissions]}=await db.query<{allowed:boolean}>("select has_function_privilege('authenticated','public.mbn_runtime_key(text)','EXECUTE') allowed");assert.equal(permissions.allowed,false);
}));
test('test lists are explicit and unavailable to school staff',()=>isolated(async()=>{
 const result=await invoke('mbn_workspace_tests',[owner,sid(owner),'APPLICATIONS','{}']);assert.equal(result.test_mode,true);assert.equal(result.total,0);
 await assert.rejects(invoke('mbn_workspace_tests',[cm,sid(cm),'APPLICATIONS','{}']),{message:'access_denied'});
}));
async function campaign(){return action('campaign_save',{school_code:'MLV BTS',name:'Synthetic campaign',subject:'Bonjour {{prenom}}',body:'Bienvenue chez {{ecole}}.'});}
test('business API requires a live session, an active profile and a scoped school permission',()=>isolated(async()=>{
 await assert.rejects(invoke('mbn_workspace_action',[owner,sid(cm),'bootstrap','{}']),{message:'access_denied'});
 await assert.rejects(action('lead_save',lead(),other),{message:'access_denied'});
 await db.exec(`update public.profiles set is_active=false where user_id='${cm}'`);
 await assert.rejects(action('bootstrap',{},cm),{message:'access_denied'});
}));
test('creating a lead creates an audited prospect and no premature application',()=>isolated(async()=>{
 const row=await action('lead_save',lead(),cm);assert.equal(row.created,1);
 const {rows:[counts]}=await db.query<{leads:number;apps:number;events:number}>('select (select count(*)::int from public.crm_leads) as leads,(select count(*)::int from public.crm_applications) as apps,(select count(*)::int from public.crm_lead_events) as events');
 assert.deepEqual(counts,{leads:1,apps:0,events:1});
 assert.equal((await action('leads_list',{},other)).total,0);
}));
test('import skips duplicates and never silently restores a withdrawn consent',()=>isolated(async()=>{
 const {id}=await action('lead_save',lead({consent_email:false,consent_source:''}));
 const r=await action('leads_import',{rows:[lead(),lead({email:'second@example.invalid'})]});assert.deepEqual({created:r.created,skipped:r.skipped},{created:1,skipped:1});
 assert.equal((await action('lead_detail',{id})).lead.consent_email,false);
 await assert.rejects(action('lead_save',lead({email:'no-proof@example.invalid',consent_source:''})),{message:'consent_evidence_required'});
}));
test('an invalid import row rolls back the entire batch',()=>isolated(async()=>{
 await assert.rejects(action('leads_import',{rows:[lead(),lead({email:'invalid'})]}),{message:'invalid_lead'});
 assert.equal((await action('leads_list')).total,0);
}));
test('a Meta campaign creates exactly J0/J+2/J+4/J+6 and excludes every ineligible recipient',()=>isolated(async()=>{
 await action('lead_save',lead());
 for(const [i,patch] of [{source:'META_MESSENGER'},{consent_email:false,consent_source:''},{source:'DIRECT'}].entries())await action('lead_save',lead({email:'excluded'+i+'@example.invalid',...patch}));
 const {id}=await campaign();assert.equal((await action('campaign_preview',{id})).eligible,1);
 const result=await action('campaign_launch',{id});assert.deepEqual(result,{messages:4,recipients:1});
 const {rows}=await db.query<{attempt_number:number;days:number}>('select attempt_number,extract(epoch from (scheduled_at-min(scheduled_at) over()))/86400 as days from public.crm_outreach_queue order by attempt_number');
 assert.deepEqual(rows.map(r=>[r.attempt_number,Number(r.days)]),[[0,0],[1,2],[2,4],[3,6]]);
 const next=await campaign();assert.equal((await action('campaign_preview',{id:next.id})).eligible,0);
 await assert.rejects(action('campaign_launch',{id:next.id}),{message:'no_eligible_recipients'});
 assert.equal(await invoke('mbn_mail_claim',[null]),null);
}));
test('withdrawing/excluding a lead cancels every queued message and leaves history',()=>isolated(async()=>{
 const l=await action('lead_save',lead()),c=await campaign();await action('campaign_launch',{id:c.id});
 await action('lead_exclude',{id:l.id,note:'Synthetic exclusion'});
 const {rows}=await db.query<{status:string}>('select status from public.mail_messages');assert.equal(rows.length,4);assert.ok(rows.every(r=>r.status==='CANCELED'));
 assert.ok((await action('lead_detail',{id:l.id})).events.some((e:any)=>e.event_type==='EXCLUDED'));
}));
test('confirmed engagement cancels sequence A; scanner-style info calls do not',()=>isolated(async()=>{
 const l=await action('lead_save',lead()),c=await campaign();await action('campaign_launch',{id:c.id});
 const link=await invoke('mbn_mail_link',[l.id]);await invoke('mbn_candidate_context',[link.id,'info']);
 assert.equal((await action('lead_detail',{id:l.id})).lead.clicked_at,null);
 await invoke('mbn_candidate_context',[link.id,'engage']);
 assert.ok((await action('lead_detail',{id:l.id})).lead.clicked_at);
 assert.ok((await db.query<{status:string}>('select status from public.mail_messages')).rows.every(r=>r.status==='CANCELED'));
}));
test('campaign launch and account settings require explicit permission, not merely CM role',()=>isolated(async()=>{
 await assert.rejects(action('campaign_save',{school_code:'MLV BTS',name:'x',subject:'x',body:'x'},cm),{message:'access_denied'});
 await assert.rejects(action('settings_get',{},cm),{message:'access_denied'});
 await db.exec(`update public.school_memberships set can_send_campaigns=true where user_id='${cm}'`);
 assert.ok((await action('campaign_save',{school_code:'MLV BTS',name:'x',subject:'x',body:'x'},cm)).id);
}));
async function application(){const l=await action('lead_save',lead());const {rows:[a]}=await db.query<{id:string}>(`insert into public.crm_applications(lead_id,school_code,campus_code,program_id,application_reference,admission_type) values($1,'MLV BTS','NOISIEL',$2,'SYNTHETIC-APP','INTERNATIONAL') returning id`,[l.id,program]);return a;}
test('school-scoped routing uses the active admissions owner or backup',()=>isolated(async()=>{
 await action('routing_save',{school_code:'MLV BTS',primary_user:reviewer});const a=await application();
 const detail=await action('application_detail',{id:a.id});assert.equal(detail.application.assigned_admissions_user,reviewer);
 await assert.rejects(action('application_assign',{id:a.id,user_id:other}),{message:'inactive_assignee'});
 await action('application_assign',{id:a.id,user_id:''});assert.equal((await action('application_detail',{id:a.id})).application.routing_status,'UNASSIGNED');
}));
test('review, decision and stale status controls are independent and enforced',()=>isolated(async()=>{
 const a=await application();await assert.rejects(action('application_transition',{id:a.id,status:'ADMITTED',expected_status:'RECEIVED',note:'Synthetic'},reviewer),{message:'access_denied'});
 await assert.rejects(action('application_transition',{id:a.id,status:'IN_REVIEW',expected_status:'RECEIVED'},cm),{message:'access_denied'});
 await action('application_transition',{id:a.id,status:'IN_REVIEW',expected_status:'RECEIVED'},reviewer);
 await assert.rejects(action('application_transition',{id:a.id,status:'CLOSED',expected_status:'RECEIVED'},reviewer),{message:'record_changed'});
 await assert.rejects(action('application_transition',{id:a.id,status:'COMPLETE',expected_status:'IN_REVIEW'},reviewer),{message:'required_documents_not_approved'});
 assert.ok(!('form_payload' in (await action('application_detail',{id:a.id},cm)).application));
}));
test('an expired send lease becomes uncertain and is never automatically retried',()=>isolated(async()=>{
 await db.exec(`insert into public.mail_messages(school_code,recipient,subject,body,status,attempt_id,claimed_at) values('MLV BTS','synthetic@example.invalid','Synthetic','Synthetic','SENDING',gen_random_uuid(),now()-interval '10 minutes')`);
 assert.equal(await invoke('mbn_mail_claim',[null]),null);
 assert.equal((await db.query<{status:string}>('select status from public.mail_messages')).rows[0].status,'UNCERTAIN');
}));
test('an accepted provider response remains ACCEPTED until a verified delivery event, with event deduplication',()=>isolated(async()=>{
 const l=await action('lead_save',lead());const {rows:[m]}=await db.query<{id:string;attempt_id:string}>(`insert into public.mail_messages(school_code,lead_id,recipient,subject,body,status,attempt_id,claimed_at) values('MLV BTS',$1,'synthetic@example.invalid','Synthetic','Synthetic','SENDING',gen_random_uuid(),now()) returning id,attempt_id`,[l.id]);
 assert.equal(await invoke('mbn_mail_finish',[m.id,m.attempt_id,'ACCEPTED','provider-id',null]),true);
 assert.equal((await db.query<{status:string}>('select status from public.mail_messages')).rows[0].status,'ACCEPTED');
 const event={event:'delivered',provider_id:'provider-id',message_id:m.id,email:'synthetic@example.invalid'};
 assert.equal(await invoke('mbn_brevo_event',['a'.repeat(64),JSON.stringify(event)]),true);assert.equal(await invoke('mbn_brevo_event',['a'.repeat(64),JSON.stringify(event)]),false);
 assert.equal((await db.query<{status:string}>('select status from public.mail_messages')).rows[0].status,'DELIVERED');
}));
test('a permanent bounce suppresses the address and cancels outstanding marketing',()=>isolated(async()=>{
 const l=await action('lead_save',lead()),c=await campaign();await action('campaign_launch',{id:c.id});const {rows:[m]}=await db.query<{id:string}>('select id from public.mail_messages limit 1');
 await db.query("update public.mail_messages set status='ACCEPTED',provider_message_id='provider-bounce' where id=$1",[m.id]);
 await invoke('mbn_brevo_event',['b'.repeat(64),JSON.stringify({event:'hard_bounce',provider_id:'provider-bounce',message_id:m.id,email:'synthetic@example.invalid'})]);
 assert.equal((await action('lead_detail',{id:l.id})).lead.consent_email,false);
 assert.equal((await db.query<{n:number}>("select count(*)::int as n from public.mail_messages where status='QUEUED'")).rows[0].n,0);
}));
test('every new public business RPC is invoker-only and forbidden to browser roles',()=>isolated(async()=>{
 const {rows}=await db.query<{proname:string;prosecdef:boolean;anon:boolean;staff:boolean}>(`select p.proname,p.prosecdef,has_function_privilege('anon',p.oid,'EXECUTE') anon,has_function_privilege('authenticated',p.oid,'EXECUTE') staff from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and (p.proname like 'mbn_workspace_%' or p.proname like 'mbn_brevo_%' or p.proname like 'mbn_mail_%' or p.proname like 'mbn_candidate_%' or p.proname='mbn_runtime_key')`);
 assert.ok(rows.length>=10);for(const row of rows){assert.equal(row.prosecdef,false,row.proname);assert.equal(row.anon,false,row.proname);assert.equal(row.staff,false,row.proname);}
}));

test('a public capability reserves files first, commits the exact lead/application/documents atomically and acknowledges replays',()=>isolated(async()=>{
 const l=await action('lead_save',lead()),link=await invoke('mbn_mail_link',[l.id]);
 const payload={event:'application_submitted',reference_dossier:'MBNAPP-'+link.id,school_code:'MLV BTS',campus_code:'NOISIEL',program_id:program,program_name:'Synthetic BTS',cycle:'BTS',full_name:'Synthetic Prospect',email:'synthetic@example.invalid',country_of_residence:'Cameroun',consent_email:false,source:'DIRECT'};
 const docs=['CV','DIPLOME','PIECE_IDENTITE'].map(kind=>({kind,original_name:kind+'.pdf',mime_type:'application/pdf',byte_size:20,sha256:'a'.repeat(64),extension:'pdf'}));
 const args=[link.id,JSON.stringify(payload),'{}',JSON.stringify(docs),'f'.repeat(64)];
 const reserved=await invoke('mbn_candidate_prepare',args);assert.equal(reserved.completed,false);assert.equal((await action('applications_list')).total,0);
 await assert.rejects(invoke('mbn_candidate_complete',[link.id,reserved.submission_id]),{message:'documents_pending'});
 for(const d of docs)await db.query('insert into storage.objects(bucket_id,name,metadata) values($1,$2,$3)', ['mbn-admissions',reserved.submission_id+'/'+d.kind+'.pdf',JSON.stringify({size:20,mimetype:'application/pdf'})]);
 const receipt=await invoke('mbn_candidate_complete',[link.id,reserved.submission_id]);assert.equal(receipt.success,true);assert.equal(receipt.duplicated,false);assert.equal(receipt.document_count,3);
 assert.equal((await action('leads_list')).total,1);assert.equal((await action('applications_list')).total,1);
 assert.equal((await invoke('mbn_candidate_complete',[link.id,reserved.submission_id])).duplicated,true);
 assert.equal((await invoke('mbn_candidate_prepare',args)).completed,true);
 await assert.rejects(invoke('mbn_candidate_prepare',[link.id,JSON.stringify({...payload,email:'another@example.invalid'}),'{}',JSON.stringify(docs),'f'.repeat(64)]),{message:'invitation_mismatch'});
 const detail=await action('application_detail',{id:receipt.application_id});assert.equal(detail.documents.length,3);assert.equal(detail.lead.source,'META_LEAD');assert.equal(detail.application.admission_type,'INTERNATIONAL');
 for(const doc of detail.documents)await action('document_review',{id:receipt.application_id,document_id:doc.id,review_status:'APPROVED',note:'Synthetic verification'},reviewer);
 await action('application_transition',{id:receipt.application_id,expected_status:'RECEIVED',status:'IN_REVIEW'},reviewer);
 await action('application_transition',{id:receipt.application_id,expected_status:'IN_REVIEW',status:'COMPLETE'},reviewer);
 await action('application_transition',{id:receipt.application_id,expected_status:'COMPLETE',status:'READY_FOR_DECISION'},reviewer);
 await action('application_transition',{id:receipt.application_id,expected_status:'READY_FOR_DECISION',status:'ADMITTED',note:'Synthetic owner approval'});
 assert.equal((await action('application_detail',{id:receipt.application_id})).application.status,'ADMITTED');
 assert.ok(!(await action('application_detail',{id:receipt.application_id},cm)).events.some((e:any)=>e.event_type==='DOCUMENT_REVIEWED'));
}));

test('hosted Messenger entries create no prospect or campaign until an actual complete application',()=>isolated(async()=>{
 const link=await invoke('mbn_school_entry',['mlv-bts','a'.repeat(64)]);
 assert.equal((await action('leads_list')).total,0);
 const ctx=await invoke('mbn_candidate_context',[link.id,'info']);assert.equal(ctx.email,undefined);assert.equal(ctx.submitted,false);
 const payload={event:'application_submitted',reference_dossier:'MBNAPP-'+link.id,school_code:'MLV BTS',campus_code:'NOISIEL',program_id:program,program_name:'Synthetic BTS',cycle:'BTS',full_name:'Synthetic Messenger',email:'messenger@example.invalid',country_of_residence:'Cameroun',consent_email:false};
 const docs=['CV','DIPLOME','PIECE_IDENTITE'].map(kind=>({kind,original_name:kind+'.pdf',mime_type:'application/pdf',byte_size:20,sha256:'a'.repeat(64),extension:'pdf'}));
 await assert.rejects(invoke('mbn_candidate_prepare',[link.id,JSON.stringify({...payload,school_code:'EMSP'}),'{}',JSON.stringify(docs),'f'.repeat(64)]),{message:'invitation_mismatch'});
 const reserved=await invoke('mbn_candidate_prepare',[link.id,JSON.stringify(payload),'{}',JSON.stringify(docs),'f'.repeat(64)]);
 for(const d of docs)await db.query('insert into storage.objects(bucket_id,name,metadata) values($1,$2,$3)', ['mbn-admissions',reserved.submission_id+'/'+d.kind+'.pdf',JSON.stringify({size:20,mimetype:'application/pdf'})]);
 await invoke('mbn_candidate_complete',[link.id,reserved.submission_id]);
 const {rows:[lead]}=await db.query<{source:string;consent_email:boolean}>("select source,consent_email from public.crm_leads where email='messenger@example.invalid'");assert.deepEqual(lead,{source:'META_MESSENGER',consent_email:false});
 assert.equal((await invoke('mbn_candidate_context',[link.id,'info'])).submitted,true);
 assert.equal((await db.query<{n:number}>('select count(*)::int n from public.crm_outreach_queue')).rows[0].n,0);
}));
test('public school sessions are limited, school-scoped and expire without exposing stored identity',()=>isolated(async()=>{
 for(let i=0;i<40;i++)await invoke('mbn_school_entry',['mlv-bts','a'.repeat(64)]);
 await assert.rejects(invoke('mbn_school_entry',['mlv-bts','a'.repeat(64)]),{message:'intake_busy'});
 const link=await invoke('mbn_school_entry',['mlv-bts','b'.repeat(64)]);
 await db.query("update private.mbn_admission_links set expires_at=now()-interval '1 second' where id=$1",[link.id]);
 await assert.rejects(invoke('mbn_candidate_context',[link.id,'info']),{message:'link_unavailable'});
 await db.exec("update public.schools set is_active=false where code='MLV BTS'");
 await assert.rejects(invoke('mbn_school_entry',['mlv-bts','c'.repeat(64)]),{message:'link_unavailable'});
}));
const letterSettingFields={academic_year:'2026/2027',intake:'janvier 2027',deferred_intake:'septembre 2027',registration_fee:'1000',tuition_deposit:'1000',confirmation_days:'30',signatory:'Service synthétique',avi_mode:'OPTIONAL'};
const letterFields={date_of_birth:'2000-01-02',place_of_birth:'Lieu synthétique',logo_variant:'CAMPUS'};
const letterConfig=(name:string,data:object={},actor=owner)=>invoke('mbn_letter_config_action',[actor,sid(actor),name,JSON.stringify(data)]);
async function configureLetters(type='INTERNATIONAL',fields={},school='MLV BTS',enabled=true){
 const config=await letterConfig('get'),current=config.settings.find((s:any)=>s.school_code===school&&s.admission_type===type);
 return letterConfig('save',{school_code:school,admission_type:type,expected_revision:current.revision,enabled,fields:{...letterSettingFields,...(type==='NATIONAL'?{avi_mode:'NONE',deferred_intake:'',registration_fee:'0',tuition_deposit:'0'}:{}),...fields}});
}
async function currentLetterRevision(type='INTERNATIONAL',school='MLV BTS'){
 return (await letterConfig('get')).settings.find((s:any)=>s.school_code===school&&s.admission_type===type).revision;
}
test('letter settings start empty and paused for both flows of every school',()=>isolated(async()=>{
 const data=await letterConfig('get');assert.equal(data.schools.length,19);assert.equal(data.settings.length,38);
 for(const setting of data.settings){assert.deepEqual(setting.fields,{});assert.equal(setting.enabled,false);assert.ok(setting.revision);}
 await assert.rejects(letterConfig('get',{},cm),{message:'access_denied'});
 await assert.rejects(letterConfig('get',{},other),{message:'access_denied'});
 await assert.rejects(letterConfig('save',{},reviewer),{message:'access_denied'});
}));
test('letter configuration validates its flow, amounts, year and stale revisions with an audit record',()=>isolated(async()=>{
 for(const patch of [{avi_mode:'OPTIONAL'},{registration_fee:'-1'},{tuition_deposit:'1e3'},{academic_year:'2026/2028'},{signatory:'  '},{confirmation_days:'0'},{school_name:'Spoofed'}]){
  await assert.rejects(configureLetters('NATIONAL',patch),{message:'invalid_letter_settings'});
 }
 const before=await currentLetterRevision('NATIONAL'),saved=await configureLetters('NATIONAL');assert.notEqual(saved.revision,before);
 await assert.rejects(letterConfig('save',{school_code:'MLV BTS',admission_type:'NATIONAL',expected_revision:before,fields:saved.fields,enabled:true}),{message:'letter_settings_changed'});
 assert.equal((await db.query<{n:number}>('select count(*)::int n from private.mbn_letter_settings_events')).rows[0].n,1);
 const unchanged=await configureLetters('NATIONAL');assert.equal(unchanged.revision,saved.revision);
}));
test('national and international fees remain separate and are never copied from another school',()=>isolated(async()=>{
 await configureLetters('NATIONAL',{registration_fee:'0',tuition_deposit:'120.50'});await configureLetters('INTERNATIONAL',{registration_fee:'800'});
 const all=(await letterConfig('get')).settings;
 assert.equal(all.find((s:any)=>s.school_code==='MLV BTS'&&s.admission_type==='NATIONAL').fields.registration_fee,'0');
 assert.equal(all.find((s:any)=>s.school_code==='MLV BTS'&&s.admission_type==='INTERNATIONAL').fields.registration_fee,'800');
 assert.deepEqual(all.find((s:any)=>s.school_code==='CESCOM'&&s.admission_type==='NATIONAL').fields,{});
}));
test('preparing a letter requires enabled settings and the exact configuration shown in the editor',()=>isolated(async()=>{
 const a=await application();await db.query("update public.crm_applications set status='ADMITTED' where id=$1",[a.id]);
 const args={application_id:a.id,request_id:crypto.randomUUID(),fields:letterFields,attachments:[]};
 await assert.rejects(letterAction('prepare',args),{message:'letter_settings_missing'});
 const settings=await configureLetters();await assert.rejects(letterAction('prepare',{...args,expected_config_revision:crypto.randomUUID()}),{message:'letter_settings_changed'});
 await assert.rejects(letterAction('prepare',{...args,expected_config_revision:settings.revision,fields:{...letterFields,registration_fee:'1'}}),{message:'invalid_letter'});
 await assert.rejects(letterAction('prepare',{...args,expected_config_revision:settings.revision,fields:{...letterFields,date_of_birth:'2026-02-31'}}),{message:'invalid_letter'});
}));
test('national letters snapshot server parameters and reject international annexes',()=>isolated(async()=>{
 const a=await application();await db.query("update public.crm_applications set status='ADMITTED',admission_type='NATIONAL' where id=$1",[a.id]);
 await db.exec('update private.mbn_original_assets set installed_at=now()');
 const settings=await configureLetters('NATIONAL',{tuition_deposit:'150'});
 const args={application_id:a.id,request_id:crypto.randomUUID(),expected_config_revision:settings.revision,fields:letterFields,attachments:['cgv_group']};
 const prepared=await letterAction('prepare',args);assert.equal(prepared.fields.admission_type,'NATIONAL');assert.equal(prepared.fields.template_version,'national-v1-20261019');
 assert.equal(prepared.fields.registration_fee,'0');assert.equal(prepared.fields.tuition_deposit,'150');assert.equal(prepared.fields.signatory,settings.fields.signatory);assert.equal(prepared.fields.avi_mode,'NONE');
 assert.deepEqual((await letterAction('prepare',args)).fields,prepared.fields);
 const context=await letterAction('context',{application_id:a.id});assert.equal(context.letter_settings.revision,settings.revision);
 for(const key of ['avi_attestation','visa_refusal','rib_cameroun']){
  assert.ok(!context.assets.some((x:any)=>x.key===key));
  await assert.rejects(letterAction('prepare',{...args,request_id:crypto.randomUUID(),attachments:[key]}),{message:'national_attachment_conflict'});
 }
}));
test('changing school parameters preserves historical PDFs but invalidates their unsent preview',()=>isolated(async()=>{
 const {id,prepared}=await admissionLetter();await db.query('insert into storage.objects(bucket_id,name,metadata) values($1,$2,$3)',['mbn-admission-letters',id+'/admission.pdf',JSON.stringify({size:100})]);
 await letterAction('generated',{id,sha256:'f'.repeat(64),byte_size:100});
 await configureLetters('INTERNATIONAL',{registration_fee:'2000'});
 const row=await letterAction('download',{id});assert.equal(row.fields.registration_fee,'1000');assert.equal(row.fields.config_revision,prepared.fields.config_revision);
 await assert.rejects(letterAction('claim',{id,confirmed:true}),{message:'letter_settings_changed'});
 assert.equal((await db.query<{n:number}>('select count(*)::int n from public.mail_messages')).rows[0].n,0);
}));
test('a national PDF requires human approval and follows accepted then delivered states',()=>isolated(async()=>{
 const a=await application();await db.query("update public.crm_applications set status='ADMITTED',admission_type='NATIONAL' where id=$1",[a.id]);
 await db.exec('update private.mbn_original_assets set installed_at=now()');const settings=await configureLetters('NATIONAL');
 const id=crypto.randomUUID();await letterAction('prepare',{application_id:a.id,request_id:id,expected_config_revision:settings.revision,fields:letterFields,attachments:['cgv_group']});
 await db.query('insert into storage.objects(bucket_id,name,metadata) values($1,$2,$3)',['mbn-admission-letters',id+'/admission.pdf',JSON.stringify({size:100})]);
 await letterAction('generated',{id,sha256:'f'.repeat(64),byte_size:100});
 await db.exec("update private.mbn_mail_settings set enabled=true,sender_verified=true,production_access=true,account_sending_enabled=true,provider_checked_at=now()");
 await assert.rejects(letterAction('claim',{id}),{message:'letter_approval_required'});
 const claim=await letterAction('claim',{id,confirmed:true});assert.equal(claim.fields.admission_type,'NATIONAL');
 await invoke('mbn_letter_finish',[claim.message.id,claim.message.attempt_id,'ACCEPTED','synthetic-national-provider',null]);
 assert.equal((await action('application_detail',{id:a.id})).application.status,'LETTER_SENT');
 assert.equal((await db.query<{status:string}>('select status from public.mail_messages where id=$1',[claim.message.id])).rows[0].status,'ACCEPTED');
 await invoke('mbn_brevo_event',['e'.repeat(64),JSON.stringify({event:'delivered',provider_id:'synthetic-national-provider',message_id:claim.message.id,email:claim.fields.email})]);
 assert.equal((await db.query<{status:string}>('select status from public.mail_messages where id=$1',[claim.message.id])).rows[0].status,'DELIVERED');
}));
test('authorization is rechecked against a changed flow or paused letter profile after taking the send lease',()=>isolated(async()=>{
 const {a,id}=await admissionLetter();await db.query('insert into storage.objects(bucket_id,name,metadata) values($1,$2,$3)',['mbn-admission-letters',id+'/admission.pdf',JSON.stringify({size:100})]);
 await letterAction('generated',{id,sha256:'f'.repeat(64),byte_size:100});
 await db.exec("update private.mbn_mail_settings set enabled=true,sender_verified=true,production_access=true,account_sending_enabled=true,provider_checked_at=now()");
 const claim=await letterAction('claim',{id,confirmed:true});
 await db.query("update public.crm_applications set admission_type='NATIONAL' where id=$1",[a.id]);
 assert.equal(await letterAction('authorized',{id,attempt_id:claim.message.attempt_id}),false);
 await db.query("update public.crm_applications set admission_type='INTERNATIONAL' where id=$1",[a.id]);
 await configureLetters('INTERNATIONAL',{},'MLV BTS',false);
 assert.equal(await letterAction('authorized',{id,attempt_id:claim.message.attempt_id}),false);
}));
test('all letter RPCs and configuration tables remain inaccessible to browser roles',()=>isolated(async()=>{
 const {rows}=await db.query<{proname:string;prosecdef:boolean;anon:boolean;staff:boolean}>(`select p.proname,p.prosecdef,has_function_privilege('anon',p.oid,'EXECUTE') anon,has_function_privilege('authenticated',p.oid,'EXECUTE') staff from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname like 'mbn_letter_%'`);
 for(const row of rows){assert.equal(row.prosecdef,false);assert.equal(row.anon,false,row.proname);assert.equal(row.staff,false,row.proname);}
 const {rows:tables}=await db.query<{relname:string;relrowsecurity:boolean;allowed:boolean}>(`select c.relname,c.relrowsecurity,has_table_privilege('authenticated',c.oid,'SELECT') allowed from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='private' and c.relname in ('mbn_school_letter_settings','mbn_letter_settings_events')`);
 assert.equal(tables.length,2);for(const t of tables){assert.equal(t.relrowsecurity,true);assert.equal(t.allowed,false);}
}));
const letterAction=(name:string,data:object={},actor=owner)=>invoke('mbn_letter_action',[actor,sid(actor),name,JSON.stringify(data)]);
async function admissionLetter(overrides={}){
 const a=await application();await db.query("update public.crm_applications set status='ADMITTED' where id=$1",[a.id]);
 await db.exec('update private.mbn_original_assets set installed_at=now()');
 const settings=await configureLetters();
 const id=crypto.randomUUID();const prepared=await letterAction('prepare',{application_id:a.id,request_id:id,expected_config_revision:settings.revision,fields:{...letterFields,...overrides},attachments:['cgv_group']});
 return {a,id,prepared};
}
test('letters require an admitted dossier, separate send permission and the campus logo',()=>isolated(async()=>{
 const a=await application();const settings=await configureLetters();await assert.rejects(letterAction('context',{application_id:a.id},cm),{message:'access_denied'});
 await assert.rejects(letterAction('prepare',{application_id:a.id,request_id:crypto.randomUUID(),fields:letterFields,attachments:[]}),{message:'admission_required'});
 await db.query("update public.crm_applications set status='ADMITTED' where id=$1",[a.id]);
 await assert.rejects(letterAction('prepare',{application_id:a.id,request_id:crypto.randomUUID(),expected_config_revision:settings.revision,fields:{...letterFields,logo_variant:'SCHOOL'},attachments:[]}),{message:'campus_brand_required'});
 await assert.rejects(letterAction('prepare',{application_id:a.id,request_id:crypto.randomUUID(),expected_config_revision:settings.revision,fields:{...letterFields,school_name:'Spoofed School'},attachments:[]}),{message:'invalid_letter'});
 await db.exec('update private.mbn_original_assets set installed_at=now()');
 await assert.rejects(letterAction('prepare',{application_id:a.id,request_id:crypto.randomUUID(),expected_config_revision:settings.revision,fields:letterFields,attachments:['cgv_cescom']}),{message:'invalid_attachments'});
 await assert.rejects(letterAction('prepare',{application_id:a.id,request_id:crypto.randomUUID(),expected_config_revision:settings.revision,fields:letterFields,attachments:['avi_attestation']}),{message:'avi_attachment_conflict'});
}));
test('letter previews are immutable and send once with an explicit approval, never an invented delivery',()=>isolated(async()=>{
 const {a,id,prepared}=await admissionLetter();assert.equal(prepared.fields.school_name,'Marne-la-Vallée BTS');assert.equal(prepared.fields.campus_name,'Campus Innovation Marne-la-Vallée');assert.equal(prepared.message_id,null);
 await assert.rejects(letterAction('prepare',{application_id:a.id,request_id:id,expected_config_revision:prepared.fields.config_revision,fields:{...letterFields,place_of_birth:'Autre lieu synthétique'},attachments:['cgv_group']}),{message:'reference_conflict'});
 await db.query('insert into storage.objects(bucket_id,name,metadata) values($1,$2,$3)',['mbn-admission-letters',id+'/admission.pdf',JSON.stringify({size:100,mimetype:'application/pdf'})]);
 await letterAction('generated',{id,sha256:'f'.repeat(64),byte_size:100});
 await assert.rejects(letterAction('claim',{id,confirmed:true}),{message:'sender_not_ready'});
 await db.exec("update private.mbn_mail_settings set enabled=true,sender_verified=true,production_access=true,account_sending_enabled=true,provider_checked_at=now()");
 await assert.rejects(letterAction('claim',{id}),{message:'letter_approval_required'});
 // Transactional admission can be sent without marketing consent.
 await db.query('update public.crm_leads set consent_email=false where id=(select lead_id from public.crm_applications where id=$1)',[a.id]);
 const claim=await letterAction('claim',{id,confirmed:true});assert.equal(claim.message.status,'SENDING');
 assert.equal(await letterAction('authorized',{id,attempt_id:claim.message.attempt_id}),true);
 await assert.rejects(letterAction('claim',{id,confirmed:true}),{message:'letter_already_sent'});
 await invoke('mbn_letter_finish',[claim.message.id,claim.message.attempt_id,'ACCEPTED','synthetic-letter-provider',null]);
 assert.equal((await action('application_detail',{id:a.id})).application.status,'LETTER_SENT');
 assert.equal((await db.query<{status:string}>('select status from public.mail_messages where id=$1',[claim.message.id])).rows[0].status,'ACCEPTED');
 await invoke('mbn_brevo_event',['c'.repeat(64),JSON.stringify({event:'delivered',provider_id:'synthetic-letter-provider',message_id:claim.message.id,email:claim.fields.email})]);
 assert.equal((await db.query<{status:string}>('select status from public.mail_messages where id=$1',[claim.message.id])).rows[0].status,'DELIVERED');
}));
test('an expired, forged or cross-asset installation capability cannot read or install a reference file',()=>isolated(async()=>{
 const ticket=await invoke('mbn_asset_install_ticket',['cgv_group']);
 await assert.rejects(invoke('mbn_asset_install_context',['a'.repeat(64),'cgv_group',false]),{message:'access_denied'});
 await assert.rejects(invoke('mbn_asset_install_context',[ticket.token,'visa_refusal',false]),{message:'access_denied'});
 await assert.rejects(invoke('mbn_asset_install_context',[ticket.token,'cgv_group',true]),{message:'asset_pending'});
 await db.exec("update private.mbn_asset_tickets set expires_at=now()-interval '1 second'");
 await assert.rejects(invoke('mbn_asset_install_context',[ticket.token,'cgv_group',false]),{message:'access_denied'});
 for(const name of ['mbn_asset_install_ticket(text)','mbn_asset_install_context(text,text,boolean)','mbn_letter_action(uuid,uuid,text,jsonb)','mbn_school_entry(text,text)']){
  const {rows:[p]}=await db.query<{anon:boolean;staff:boolean}>("select has_function_privilege('anon',$1,'EXECUTE') anon,has_function_privilege('authenticated',$1,'EXECUTE') staff",['public.'+name]);assert.equal(p.anon,false);assert.equal(p.staff,false);
 }
}));

const brevoSettings=(overrides={})=>({from_name:'Campus Innovation',from_email:'sender@example.invalid',reply_to:'',daily_limit:100,enabled:false,...overrides});
async function brevoTest(){
 await action('settings_save',brevoSettings());
 await invoke('mbn_mail_provider_checked',[JSON.stringify({sender_verified:true,production_access:true,account_sending_enabled:true,credential_fingerprint:'d'.repeat(64)})]);
 await invoke('mbn_brevo_webhook_configured',[12]);
 const test=await action('test_prepare');const claim=await invoke('mbn_mail_claim',[test.id]);
 assert.equal(claim.status,'SENDING');
 await invoke('mbn_mail_finish',[claim.id,claim.attempt_id,'ACCEPTED','<brevo-test-id>',null]);
 return {id:test.id,event:{event:'delivered',provider_id:'<brevo-test-id>',message_id:test.id,email:'nbtonybill@gmail.com'}};
}
test('Brevo settings require owner access and a delivered test bound to the current sender before activation',()=>isolated(async()=>{
 await assert.rejects(action('settings_save',brevoSettings(),cm),{message:'access_denied'});
 await assert.rejects(action('settings_save',brevoSettings({enabled:true})),{message:'sender_not_ready'});
 const proof=await brevoTest();
 await assert.rejects(action('settings_save',brevoSettings({enabled:true})),{message:'sender_not_ready'});
 await invoke('mbn_brevo_event',['d'.repeat(64),JSON.stringify(proof.event)]);
 assert.equal((await action('settings_save',brevoSettings({enabled:true}))).enabled,true);
 const shown=await action('settings_get');assert.equal(shown.provider,'BREVO');assert.ok(!('identity' in shown));assert.ok(!('credential_fingerprint' in shown));
 await action('settings_save',brevoSettings({from_email:'another@example.invalid'}));
 const changed=await action('settings_get');assert.equal(changed.sender_verified,false);assert.equal(changed.events_verified_at,null);
 await invoke('mbn_brevo_event',['e'.repeat(64),JSON.stringify(proof.event)]);
 assert.equal((await action('settings_get')).events_verified_at,null);
}));
test('rotating Brevo credentials invalidates earlier callback and delivery proofs',()=>isolated(async()=>{
 const proof=await brevoTest();await invoke('mbn_brevo_event',['d'.repeat(64),JSON.stringify(proof.event)]);
 await action('settings_save',brevoSettings({enabled:true}));
 await invoke('mbn_mail_provider_checked',[JSON.stringify({sender_verified:true,production_access:true,account_sending_enabled:true,credential_fingerprint:'e'.repeat(64)})]);
 const state=await action('settings_get');assert.equal(state.enabled,false);assert.equal(state.brevo_webhook_id,null);assert.equal(state.events_verified_at,null);
 await invoke('mbn_brevo_event',['f'.repeat(64),JSON.stringify(proof.event)]);
 assert.equal((await action('settings_get')).events_verified_at,null);
}));
test('Brevo delivery callbacks reject recipient/provider mismatches and preserve in-flight sends for retry',()=>isolated(async()=>{
 const {rows:[m]}=await db.query<{id:string;attempt_id:string}>("insert into public.mail_messages(school_code,recipient,subject,body,status,attempt_id,claimed_at) values('MLV BTS','synthetic@example.invalid','Synthetic','Synthetic','SENDING',gen_random_uuid(),now()) returning id,attempt_id");
 const event={event:'delivered',provider_id:'<race>',message_id:m.id,email:'synthetic@example.invalid'};
 await assert.rejects(invoke('mbn_brevo_event',['a'.repeat(64),JSON.stringify(event)]),{message:'message_pending'});
 await invoke('mbn_mail_finish',[m.id,m.attempt_id,'ACCEPTED','<race>',null]);
 assert.equal(await invoke('mbn_brevo_event',['b'.repeat(64),JSON.stringify({...event,email:'wrong@example.invalid'})]),false);
 assert.equal(await invoke('mbn_brevo_event',['c'.repeat(64),JSON.stringify({...event,provider_id:'<wrong>'})]),false);
 assert.equal(await invoke('mbn_brevo_event',['a'.repeat(64),JSON.stringify(event)]),true);
 assert.equal(await invoke('mbn_brevo_event',['a'.repeat(64),JSON.stringify(event)]),false);
 assert.equal((await db.query<{status:string}>('select status from public.mail_messages where id=$1',[m.id])).rows[0].status,'DELIVERED');
}));
test('Brevo unsubscribe cancels queued marketing across schools without inventing a hard bounce',()=>isolated(async()=>{
 const lead1=await action('lead_save',lead());const lead2=await action('lead_save',lead({school_code:'EMSP'}));const c=await campaign();await action('campaign_launch',{id:c.id});
 const {rows:[m]}=await db.query<{id:string}>("update public.mail_messages set status='ACCEPTED',provider_message_id='<unsubscribe>' where id=(select id from public.mail_messages limit 1) returning id");
 await invoke('mbn_brevo_event',['a'.repeat(64),JSON.stringify({event:'unsubscribed',provider_id:'<unsubscribe>',message_id:m.id,email:'synthetic@example.invalid'})]);
 for(const id of [lead1.id,lead2.id]){const detail=await action('lead_detail',{id});assert.equal(detail.lead.consent_email,false);assert.ok(detail.lead.unsubscribed_at);assert.equal(detail.lead.email_suppressed_at,null);}
 assert.equal((await db.query<{n:number}>("select count(*)::int n from public.mail_messages where status='QUEUED'")).rows[0].n,0);
}));
test('Brevo delivery after a complaint cannot restore a suppressed address or overwrite the complaint',()=>isolated(async()=>{
 const l=await action('lead_save',lead());const {rows:[m]}=await db.query<{id:string}>("insert into public.mail_messages(school_code,lead_id,recipient,subject,body,status,provider_message_id) values('MLV BTS',$1,'synthetic@example.invalid','Synthetic','Synthetic','ACCEPTED','<complaint>') returning id",[l.id]);
 const base={provider_id:'<complaint>',message_id:m.id,email:'synthetic@example.invalid'};
 await invoke('mbn_brevo_event',['a'.repeat(64),JSON.stringify({...base,event:'spam'})]);
 await invoke('mbn_brevo_event',['b'.repeat(64),JSON.stringify({...base,event:'delivered'})]);
 assert.equal((await db.query<{status:string}>('select status from public.mail_messages where id=$1',[m.id])).rows[0].status,'COMPLAINED');
 assert.ok((await action('lead_detail',{id:l.id})).lead.email_suppressed_at);
}));

const groupCodes=['MBN_GLOBAL','CAMPUS_INNOVATION_MLV','ADMISSIONS_COMMUN'] as const;
const groupSchool=(group:string)=>({MBN_GLOBAL:'EMSP',CAMPUS_INNOVATION_MLV:'MLV BTS',ADMISSIONS_COMMUN:'ESETH'}[group]!);
const groupEmail=(group:string)=>'no-reply@'+({MBN_GLOBAL:'mbn',CAMPUS_INNOVATION_MLV:'campus',ADMISSIONS_COMMUN:'admissions'}[group]!)+'.example.invalid';
const groupName=(group:string)=>({MBN_GLOBAL:'MBN Global Éducation',CAMPUS_INNOVATION_MLV:'Campus Innovation Marne-la-Vallée',ADMISSIONS_COMMUN:'Service admissions'}[group]!);
const groupSave=(group:string,overrides={})=>action('mail_group_save',{sender_group:group,from_name:groupName(group),from_email:groupEmail(group),enabled:false,...overrides});
const routeSave=(group:string,overrides={})=>action('mail_route_save',{school_code:groupSchool(group),sender_group:group,admissions_email:group.toLowerCase()+'-admissions@example.invalid',...overrides});
async function groupCheck(group:string,fingerprint='a'.repeat(64)){
 const settings=await invoke('mbn_mail_profile_settings',[group]);
 return invoke('mbn_mail_profile_checked',[group,settings.revision,JSON.stringify({sender_verified:true,production_access:true,account_sending_enabled:true,credential_fingerprint:fingerprint})]);
}
async function groupProof(group:string,deliver=true){
 await groupCheck(group);
 const prepared=await action('mail_test_prepare',{sender_group:group});
 const claimed=await invoke('mbn_mail_profile_claim',[group,prepared.id]);
 assert.equal(claimed.recipient,'nbtonybill@gmail.com');
 assert.equal(claimed.sender_identity,groupEmail(group));
 await invoke('mbn_mail_finish',[claimed.id,claimed.attempt_id,'ACCEPTED','<test-'+group+'>',null]);
 const event={event:'delivered',message_id:claimed.id,provider_id:'<test-'+group+'>',email:claimed.recipient};
 if(deliver)await invoke('mbn_brevo_event',[String([1,2,7][groupCodes.indexOf(group as typeof groupCodes[number])]).repeat(64),JSON.stringify(event)]);
 return {claimed,event};
}
async function configureGroups(){
 for(const group of groupCodes){await groupSave(group);await routeSave(group);}
 await groupCheck('MBN_GLOBAL');
 await invoke('mbn_brevo_webhook_configured',[12]);
}
async function enableGroups(){
 await configureGroups();
 for(const group of groupCodes){await groupProof(group);await groupSave(group,{enabled:true});}
}
async function groupCampaign(group:string){
 const school_code=groupSchool(group);
 await action('lead_save',lead({school_code,email:group.toLowerCase()+'-prospect@example.invalid'}));
 const row=await action('campaign_save',{school_code,name:'Synthetic '+group,subject:'Synthetic',body:'Synthetic'});
 await action('campaign_launch',{id:row.id});return row;
}
test('three sender profiles start paused with no inferred domains or school affiliations',()=>isolated(async()=>{
 const config=await action('mail_config_get');assert.equal(config.groups.length,3);assert.equal(config.schools.length,19);
 assert.ok(config.groups.every((g:any)=>g.from_email===''&&!g.enabled&&!('credential_fingerprint' in g)));
 assert.ok(config.schools.every((s:any)=>s.sender_group===null&&s.admissions_email===''));
 assert.equal(await invoke('mbn_mail_profile_claim',['MBN_GLOBAL',null]),null);
 await assert.rejects(action('mail_config_get',{},cm),{message:'access_denied'});
 for(const rpc of ['mbn_mail_profile_settings(text,text)','mbn_mail_profile_checked(text,uuid,jsonb)','mbn_mail_profile_claim(text,uuid)','mbn_mail_profile_authorized(uuid,uuid)','mbn_letter_profile_action(uuid,uuid,text,jsonb)']){
  const {rows:[p]}=await db.query<{allowed:boolean}>("select has_function_privilege('authenticated',$1,'EXECUTE') allowed",['public.'+rpc]);assert.equal(p.allowed,false);
 }
}));
test('an administrator explicitly selects each school route and cannot reuse an address across the three groups',()=>isolated(async()=>{
 await assert.rejects(groupSave('MBN_GLOBAL',{reply_to:'spoof@example.invalid'}),{message:'invalid_sender'});
 await groupSave('MBN_GLOBAL');await assert.rejects(groupSave('CAMPUS_INNOVATION_MLV',{from_email:groupEmail('MBN_GLOBAL')}),{message:'sender_email_already_used'});
 await assert.rejects(routeSave('MBN_GLOBAL',{admissions_email:'bad\nBcc: x@example.invalid'}),{message:'invalid_mail_route'});
 await assert.rejects(routeSave('MBN_GLOBAL',{sender_group:'UNKNOWN'}),{message:'invalid_mail_route'});
 await assert.rejects(action('mail_route_save',{school_code:'MLV BTS',sender_group:'MBN_GLOBAL',admissions_email:'x@example.invalid'},cm),{message:'access_denied'});
 // Existing campus branding does not override an explicit organizational choice.
 await routeSave('MBN_GLOBAL',{school_code:'MLV BTS'});
 assert.equal((await invoke('mbn_mail_profile_settings',[null,'MLV BTS'])).code,'MBN_GLOBAL');
}));
test('each sender requires its own delivered test; API acceptance and another group proof are insufficient',()=>isolated(async()=>{
 await configureGroups();
 await groupProof('MBN_GLOBAL');await groupSave('MBN_GLOBAL',{enabled:true});
 await assert.rejects(groupSave('CAMPUS_INNOVATION_MLV',{enabled:true}),{message:'sender_not_ready'});
 const proof=await groupProof('CAMPUS_INNOVATION_MLV',false);
 assert.equal(await invoke('mbn_mail_profile_claim',['MBN_GLOBAL',proof.claimed.id]),null);
 await assert.rejects(groupSave('CAMPUS_INNOVATION_MLV',{enabled:true}),{message:'sender_not_ready'});
 await invoke('mbn_brevo_event',['3'.repeat(64),JSON.stringify(proof.event)]);
 await groupSave('CAMPUS_INNOVATION_MLV',{enabled:true});
 await assert.rejects(groupSave('ADMISSIONS_COMMUN',{enabled:true}),{message:'sender_not_ready'});
 await groupProof('ADMISSIONS_COMMUN');await groupSave('ADMISSIONS_COMMUN',{enabled:true});
 assert.ok((await action('mail_config_get')).groups.every((g:any)=>g.enabled&&g.events_verified_at));
}));
test('campaign leases use the assigned group and contact and are revoked when the school route changes',()=>isolated(async()=>{
 await enableGroups();await groupCampaign('CAMPUS_INNOVATION_MLV');
 assert.equal(await invoke('mbn_mail_profile_claim',['MBN_GLOBAL',null]),null);
 const claim=await invoke('mbn_mail_profile_claim',['CAMPUS_INNOVATION_MLV',null]);
 assert.equal(claim.sender.from_email,groupEmail('CAMPUS_INNOVATION_MLV'));assert.equal(claim.service_contact_email,'campus_innovation_mlv-admissions@example.invalid');
 assert.equal(await invoke('mbn_mail_profile_authorized',[claim.id,claim.attempt_id]),true);
 await routeSave('MBN_GLOBAL',{school_code:'MLV BTS'});
 assert.equal(await invoke('mbn_mail_profile_authorized',[claim.id,claim.attempt_id]),false);
 assert.equal((await db.query<{status:string}>('select status from public.mail_messages where id=$1',[claim.id])).rows[0].status,'CANCELED');
}));
test('a missing service contact blocks a school without falling back to the other sender',()=>isolated(async()=>{
 await enableGroups();await groupCampaign('CAMPUS_INNOVATION_MLV');
 await routeSave('CAMPUS_INNOVATION_MLV',{admissions_email:''});
 assert.equal(await invoke('mbn_mail_profile_claim',['CAMPUS_INNOVATION_MLV',null]),null);
 assert.equal(await invoke('mbn_mail_profile_claim',['MBN_GLOBAL',null]),null);
 await assert.rejects(action('mail_test_prepare',{sender_group:'CAMPUS_INNOVATION_MLV'}),{message:'mail_route_missing'});
}));
test('a delayed test delivery cannot validate a replacement sender',()=>isolated(async()=>{
 await configureGroups();const proof=await groupProof('MBN_GLOBAL',false);
 await groupSave('MBN_GLOBAL',{from_email:'no-reply@replacement.example.invalid'});
 await invoke('mbn_brevo_event',['4'.repeat(64),JSON.stringify(proof.event)]);
 const group=(await action('mail_config_get')).groups.find((g:any)=>g.code==='MBN_GLOBAL');
 assert.equal(group.events_verified_at,null);assert.equal(group.enabled,false);
 await assert.rejects(groupSave('MBN_GLOBAL',{from_email:'no-reply@replacement.example.invalid',enabled:true}),{message:'sender_not_ready'});
}));
test('rotating the shared key or rebuilding the webhook invalidates proofs for all three senders',()=>isolated(async()=>{
 await enableGroups();const stale=await invoke('mbn_mail_profile_settings',['CAMPUS_INNOVATION_MLV']);
 await groupCheck('MBN_GLOBAL','b'.repeat(64));
 let config=await action('mail_config_get');assert.ok(config.groups.every((g:any)=>!g.enabled&&g.events_verified_at===null));assert.equal(config.brevo_webhook_id,null);
 await assert.rejects(invoke('mbn_mail_profile_checked',['CAMPUS_INNOVATION_MLV',stale.revision,JSON.stringify({credential_fingerprint:'a'.repeat(64)})]),{message:'mail_configuration_changed'});
 await invoke('mbn_brevo_event',['5'.repeat(64),JSON.stringify({event:'delivered',provider_id:'<test-MBN_GLOBAL>',email:'nbtonybill@gmail.com'})]);
 assert.ok((await action('mail_config_get')).groups.every((g:any)=>g.events_verified_at===null));
 await invoke('mbn_brevo_webhook_configured',[13]);
 config=await action('mail_config_get');assert.ok(config.groups.every((g:any)=>!g.enabled&&g.events_verified_at===null));
}));
test('the daily allowance is shared by all three senders and includes tests and in-flight attempts',()=>isolated(async()=>{
 await enableGroups();await action('mail_limit_save',{daily_limit:4});
 for(const group of groupCodes)await groupCampaign(group);
 const claim=await invoke('mbn_mail_profile_claim',['MBN_GLOBAL',null]);assert.ok(claim);
 assert.equal(await invoke('mbn_mail_profile_claim',['CAMPUS_INNOVATION_MLV',null]),null);
 assert.equal(await invoke('mbn_mail_profile_authorized',[claim.id,claim.attempt_id]),true);
}));
test('a letter lease uses its school sender and loses authorization when its service contact changes',()=>isolated(async()=>{
 await enableGroups();const {id}=await admissionLetter();
 await db.query('insert into storage.objects(bucket_id,name,metadata) values($1,$2,$3)',['mbn-admission-letters',id+'/admission.pdf',JSON.stringify({size:100,mimetype:'application/pdf'})]);
 await letterAction('generated',{id,sha256:'f'.repeat(64),byte_size:100});
 const profileLetter=(name:string,data:object)=>invoke('mbn_letter_profile_action',[owner,sid(owner),name,JSON.stringify(data)]);
 const claim=await profileLetter('claim',{id,confirmed:true});
 assert.equal(claim.sender.from_email,groupEmail('CAMPUS_INNOVATION_MLV'));assert.equal(claim.message.service_contact_email,'campus_innovation_mlv-admissions@example.invalid');
 assert.equal(await profileLetter('authorized',{id,attempt_id:claim.message.attempt_id}),true);
 await routeSave('CAMPUS_INNOVATION_MLV',{admissions_email:'new-service@example.invalid'});
 assert.equal(await profileLetter('authorized',{id,attempt_id:claim.message.attempt_id}),false);
 await routeSave('CAMPUS_INNOVATION_MLV',{admissions_email:''});
 assert.equal(await profileLetter('authorized',{id,attempt_id:claim.message.attempt_id}),false);
}));
test('pausing one sender revokes its outstanding campaign lease while the other sender stays enabled',()=>isolated(async()=>{
 await enableGroups();await groupCampaign('MBN_GLOBAL');
 const claim=await invoke('mbn_mail_profile_claim',['MBN_GLOBAL',null]);assert.ok(claim);
 await groupSave('MBN_GLOBAL');
 assert.equal(await invoke('mbn_mail_profile_authorized',[claim.id,claim.attempt_id]),false);
 assert.equal((await action('mail_config_get')).groups.find((g:any)=>g.code==='CAMPUS_INNOVATION_MLV').enabled,true);
}));
test('reconfiguring the same webhook invalidates all three successful tests and ignores their delayed callbacks',()=>isolated(async()=>{
 await enableGroups();
 await invoke('mbn_brevo_webhook_configured',[12]);
 let config=await action('mail_config_get');assert.ok(config.groups.every((g:any)=>!g.enabled&&g.events_verified_at===null));
 await invoke('mbn_brevo_event',['6'.repeat(64),JSON.stringify({event:'delivered',provider_id:'<test-MBN_GLOBAL>',email:'nbtonybill@gmail.com'})]);
 config=await action('mail_config_get');assert.ok(config.groups.every((g:any)=>!g.enabled&&g.events_verified_at===null));
}));

test('ESETH, LSB and both Evry schools can share a neutral sender across campuses',()=>isolated(async()=>{
 await configureGroups();await groupSave('ADMISSIONS_COMMUN',{from_name:'Admissions du réseau'});
 for(const group of groupCodes){await groupProof(group);await groupSave(group,{from_name:group==='ADMISSIONS_COMMUN'?'Admissions du réseau':groupName(group),enabled:true});}
 const schools=['ESETH','LSB','EVRY BTS','EVRY BS'];
 for(const school_code of schools){
  await routeSave('ADMISSIONS_COMMUN',{school_code,admissions_email:school_code.toLowerCase().replaceAll(' ','-')+'@example.invalid'});
  await action('lead_save',lead({school_code,email:school_code.toLowerCase().replaceAll(' ','-')+'-prospect@example.invalid'}));
  const campaign=await action('campaign_save',{school_code,name:'Shared sender',subject:'Synthetic',body:'Synthetic'});
  await action('campaign_launch',{id:campaign.id});
 }
 const claimed=[];
 for(const school of schools){
  const claim=await invoke('mbn_mail_profile_claim',['ADMISSIONS_COMMUN',null]);assert.ok(claim,school);
  assert.equal(claim.sender.from_name,'Admissions du réseau');assert.equal(claim.sender.from_email,groupEmail('ADMISSIONS_COMMUN'));
  assert.equal(claim.service_contact_email,claim.school_code.toLowerCase().replaceAll(' ','-')+'@example.invalid');
  claimed.push(claim.school_code);await invoke('mbn_mail_finish',[claim.id,claim.attempt_id,'ACCEPTED','<shared-'+claim.id+'>',null]);
 }
 assert.deepEqual(claimed.sort(),[...schools].sort());
 for(const group of groupCodes)assert.equal(await invoke('mbn_mail_profile_claim',[group,null]),null);
}));

test('moving a school to the common sender changes queued mail and preserves sent history and campuses',()=>isolated(async()=>{
 await enableGroups();const school_code=groupSchool('MBN_GLOBAL');
 const campusQuery='select campus_code from public.school_campuses where school_code=$1 order by campus_code';
 const campuses=(await db.query(campusQuery,[school_code])).rows;
 await action('lead_save',lead({school_code,email:'history@example.invalid'}));await groupCampaign('MBN_GLOBAL');
 const sent=await invoke('mbn_mail_profile_claim',['MBN_GLOBAL',null]);assert.ok(sent);
 await invoke('mbn_mail_finish',[sent.id,sent.attempt_id,'ACCEPTED','<before-move>',null]);
 const reserved=await invoke('mbn_mail_profile_claim',['MBN_GLOBAL',null]);assert.ok(reserved);
 await routeSave('ADMISSIONS_COMMUN',{school_code,admissions_email:'new-school-service@example.invalid'});
 assert.equal(await invoke('mbn_mail_profile_authorized',[reserved.id,reserved.attempt_id]),false);
 assert.equal(await invoke('mbn_mail_profile_claim',['MBN_GLOBAL',null]),null);
 await db.query("update public.mail_messages set scheduled_at=now() where id=(select id from public.mail_messages where school_code=$1 and status='QUEUED' order by scheduled_at limit 1)",[school_code]);
 const next=await invoke('mbn_mail_profile_claim',['ADMISSIONS_COMMUN',null]);assert.ok(next);
 assert.equal(next.sender_identity,groupEmail('ADMISSIONS_COMMUN'));assert.equal(next.service_contact_email,'new-school-service@example.invalid');
 assert.equal(await invoke('mbn_mail_profile_authorized',[next.id,next.attempt_id]),true);
 const history=(await db.query<{sender_group:string;sender_identity:string;status:string}>('select sender_group,sender_identity,status from public.mail_messages where id=$1',[sent.id])).rows[0];
 assert.deepEqual(history,{sender_group:'MBN_GLOBAL',sender_identity:groupEmail('MBN_GLOBAL'),status:'ACCEPTED'});
 assert.deepEqual((await db.query(campusQuery,[school_code])).rows,campuses);assert.equal(campuses.length,3);
}));

test('moving a school to a paused sender blocks its mail without using the former group',()=>isolated(async()=>{
 await enableGroups();await groupSave('ADMISSIONS_COMMUN');await groupCampaign('MBN_GLOBAL');
 await routeSave('ADMISSIONS_COMMUN',{school_code:groupSchool('MBN_GLOBAL')});
 for(const group of groupCodes)assert.equal(await invoke('mbn_mail_profile_claim',[group,null]),null);
 await groupSave('ADMISSIONS_COMMUN',{enabled:true});
 const claim=await invoke('mbn_mail_profile_claim',['ADMISSIONS_COMMUN',null]);assert.ok(claim);
 assert.equal(claim.school_code,groupSchool('MBN_GLOBAL'));assert.equal(claim.sender_identity,groupEmail('ADMISSIONS_COMMUN'));
}));

const routing=(name:string,data:object={},actor=owner)=>invoke('mbn_routing_action',[actor,sid(actor),name,JSON.stringify(data)]);
const routingRule=(overrides={})=>routing('routing_save',{school_code:'MLV BTS',primary_user:reviewer,backup_user:'',campus_code:'',program_id:'',intake:'',priority:0,...overrides});
async function routingApplication(overrides:Record<string,any>={}){
 const token=crypto.randomUUID(),school=overrides.school_code||'MLV BTS';
 const l=await action('lead_save',lead({school_code:school,email:'routing-'+token+'@example.invalid'}));
 const row={school_code:school,campus_code:'NOISIEL',program_id:program,form_payload:{},is_test:false,status:'RECEIVED',...overrides};
 return (await db.query<any>(`insert into public.crm_applications(lead_id,school_code,campus_code,program_id,application_reference,admission_type,form_payload,is_test,status)
 values($1,$2,$3,$4,$5,'INTERNATIONAL',$6,$7,$8) returning *`,[l.id,row.school_code,row.campus_code,row.program_id,'ROUTING-'+token,JSON.stringify(row.form_payload),row.is_test,row.status])).rows[0];
}
const reviewedRows=(preview:any)=>preview.rows.filter((r:any)=>r.user_id).map(({id,expected_updated_at,rule_id,rule_revision,user_id}:any)=>({id,expected_updated_at,rule_id,rule_revision,user_id}));
async function allowBackup(){await db.exec(`update public.school_memberships set role='ADMISSIONS' where user_id='${cm}' and school_code='MLV BTS'`);}

test('routing administration exposes all schools and only eligible school-specific staff',()=>isolated(async()=>{
 const context=await routing('routing_context');assert.equal(context.schools.length,19);assert.equal(context.rules.length,0);
 assert.ok(context.schools.every((s:any)=>!s.general_ready&&Number(s.active_rules)===0));
 assert.deepEqual(context.people.filter((p:any)=>p.school_code==='MLV BTS').map((p:any)=>p.id),[reviewer]);
 assert.ok(context.people.some((p:any)=>p.id===other&&p.school_code==='EMSP'));
 assert.ok(!context.people.some((p:any)=>p.id===cm));
 for(const action of ['routing_context','routing_save','routing_toggle','routing_reassign_preview','routing_reassign_apply'])await assert.rejects(routing(action,{},cm),{message:'access_denied'});
 const {rows:[permissions]}=await db.query<{allowed:boolean}>("select has_function_privilege('authenticated','public.mbn_routing_action(uuid,uuid,text,jsonb)','EXECUTE') allowed");assert.equal(permissions.allowed,false);
}));

test('routing choices validate school, campus, active program, distinct staff and duplicate scopes',()=>isolated(async()=>{
 await assert.rejects(routingRule({primary_user:other}),{message:'inactive_assignee'});
 await assert.rejects(routingRule({primary_user:reviewer,backup_user:reviewer}),{message:'invalid_routing_rule'});
 await assert.rejects(routingRule({campus_code:'TORCY'}),{message:'invalid_campus'});
 await assert.rejects(routingRule({program_id:'not-a-uuid'}),{message:'invalid_routing_rule'});
 await assert.rejects(routingRule({program_id:'10000000-0000-4000-8000-000000000099'}),{message:'invalid_program'});
 await assert.rejects(routingRule({priority:1001}),{message:'invalid_routing_rule'});
 const {id}=await routingRule();await assert.rejects(routingRule(),{message:'routing_rule_exists'});
 const context=await routing('routing_context'),rule=context.rules.find((r:any)=>r.id===id);
 assert.equal(context.schools.find((s:any)=>s.code==='MLV BTS').general_ready,true);
 await routingRule({id,expected_revision:rule.revision,intake:' septembre 2027 '});
 const updated=(await routing('routing_context')).rules.find((r:any)=>r.id===id);assert.equal(updated.intake,'septembre 2027');assert.notEqual(updated.revision,rule.revision);
 await assert.rejects(routingRule({id,expected_revision:rule.revision}),{message:'routing_changed'});
 await assert.rejects(routing('routing_toggle',{id,expected_revision:rule.revision}),{message:'routing_changed'});
}));

test('the most specific campus, program and intake rule wins before numeric priority',()=>isolated(async()=>{
 await allowBackup();await routingRule({priority:1000});
 await routingRule({primary_user:cm,campus_code:'NOISIEL',program_id:program,intake:'septembre 2027',priority:0});
 const targeted=await routingApplication({form_payload:{intake:'septembre 2027'}});assert.equal(targeted.assigned_admissions_user,cm);
 const general=await routingApplication({form_payload:{intake:'janvier 2028'}});assert.equal(general.assigned_admissions_user,reviewer);
 const otherSchool=await routingApplication({school_code:'EMSP',campus_code:'TORCY',program_id:null});assert.equal(otherSchool.assigned_admissions_user,null);
}));

test('an inactive principal uses its authorized backup and never a lower-specificity team',()=>isolated(async()=>{
 await allowBackup();await routingRule({primary_user:reviewer,backup_user:cm});
 await db.exec(`update public.profiles set is_active=false where user_id='${reviewer}'`);
 const backup=await routingApplication();assert.equal(backup.assigned_admissions_user,cm);
 const context=await routing('routing_context');assert.equal(context.rules[0].primary_available,false);assert.equal(context.rules[0].backup_available,true);
 await db.exec(`update public.profiles set is_active=true where user_id='${reviewer}'`);
 await routingRule({primary_user:reviewer,program_id:program});
 await db.exec(`update public.profiles set is_active=false where user_id='${reviewer}'`);
 const blocked=await routingApplication();assert.equal(blocked.assigned_admissions_user,null);assert.equal(blocked.routing_status,'UNASSIGNED');
}));

test('pausing a routing rule is versioned and resuming needs an available assignee',()=>isolated(async()=>{
 const {id}=await routingRule(),rule=(await routing('routing_context')).rules.find((r:any)=>r.id===id);
 await routing('routing_toggle',{id,expected_revision:rule.revision});
 assert.equal((await routingApplication()).assigned_admissions_user,null);
 const paused=(await routing('routing_context')).rules.find((r:any)=>r.id===id);
 await db.exec(`update public.profiles set is_active=false where user_id='${reviewer}'`);
 await assert.rejects(routing('routing_toggle',{id,expected_revision:paused.revision}),{message:'inactive_assignee'});
}));

test('reviewing unassigned dossiers is read-only and excludes tests, final dossiers and assigned dossiers',()=>isolated(async()=>{
 const open=await routingApplication();await routingApplication({is_test:true});await routingApplication({status:'CLOSED'});
 await routingRule();await routingApplication();
 const preview=await routing('routing_reassign_preview');assert.equal(preview.total_unassigned,1);assert.equal(preview.rows.length,1);assert.equal(preview.rows[0].id,open.id);assert.equal(preview.rows[0].user_id,reviewer);
 assert.equal((await db.query<any>('select assigned_admissions_user from public.crm_applications where id=$1',[open.id])).rows[0].assigned_admissions_user,null);
 assert.equal((await db.query<any>('select count(*)::int n from public.mail_messages')).rows[0].n,0);
}));

test('applying a reviewed assignment records its actor and can never assign it a second time',()=>isolated(async()=>{
 const app=await routingApplication();await routingRule();const rows=reviewedRows(await routing('routing_reassign_preview'));
 assert.deepEqual(await routing('routing_reassign_apply',{rows}),{assigned:1,skipped:0});
 assert.equal((await db.query<any>('select assigned_admissions_user from public.crm_applications where id=$1',[app.id])).rows[0].assigned_admissions_user,reviewer);
 assert.deepEqual(await routing('routing_reassign_apply',{rows}),{assigned:0,skipped:1});
 const events=(await db.query<any>("select event_metadata from public.crm_lead_events where event_type='ASSIGNMENT_CHANGED' and lead_id=$1",[app.lead_id])).rows;
 assert.equal(events.length,1);assert.equal(events[0].event_metadata.actor_id,owner);assert.equal(events[0].event_metadata.source,'ROUTING_REVIEW');
 assert.equal((await db.query<any>('select count(*)::int n from public.mail_messages')).rows[0].n,0);
}));

test('a changed rule or revoked account invalidates a previously reviewed assignment',()=>isolated(async()=>{
 await routingApplication();const {id}=await routingRule();let rows=reviewedRows(await routing('routing_reassign_preview'));
 const rule=(await routing('routing_context')).rules.find((r:any)=>r.id===id);
 await routingRule({id,expected_revision:rule.revision,priority:1});
 assert.deepEqual(await routing('routing_reassign_apply',{rows}),{assigned:0,skipped:1});
 rows=reviewedRows(await routing('routing_reassign_preview'));
 await db.exec(`update public.school_memberships set is_active=false where user_id='${reviewer}' and school_code='MLV BTS'`);
 assert.deepEqual(await routing('routing_reassign_apply',{rows}),{assigned:0,skipped:1});
}));

test('a manual assignment or dossier closure after preview is preserved',()=>isolated(async()=>{
 await allowBackup();const manual=await routingApplication(),closed=await routingApplication();await routingRule();
 const rows=reviewedRows(await routing('routing_reassign_preview'));
 await action('application_assign',{id:manual.id,user_id:cm});
 await db.query("update public.crm_applications set status='CLOSED' where id=$1",[closed.id]);
 assert.deepEqual(await routing('routing_reassign_apply',{rows}),{assigned:0,skipped:2});
 assert.equal((await db.query<any>('select assigned_admissions_user from public.crm_applications where id=$1',[manual.id])).rows[0].assigned_admissions_user,cm);
}));

test('forged assignees and duplicate reviewed rows cannot redirect a dossier',()=>isolated(async()=>{
 const app=await routingApplication();await routingRule();const rows=reviewedRows(await routing('routing_reassign_preview'));
 assert.deepEqual(await routing('routing_reassign_apply',{rows:[{...rows[0],user_id:other}]}),{assigned:0,skipped:1});
 await assert.rejects(routing('routing_reassign_apply',{rows:[rows[0],rows[0]]}),{message:'invalid_routing_preview'});
 assert.equal((await db.query<any>('select assigned_admissions_user from public.crm_applications where id=$1',[app.id])).rows[0].assigned_admissions_user,null);
}));

test('a dossier changed since review is skipped even when its proposed assignee is unchanged',()=>isolated(async()=>{
 const app=await routingApplication();await routingRule();const rows=reviewedRows(await routing('routing_reassign_preview'));
 await db.query("update public.crm_applications set updated_at=updated_at+interval '1 second' where id=$1",[app.id]);
 assert.deepEqual(await routing('routing_reassign_apply',{rows}),{assigned:0,skipped:1});
}));

test('bounded routing reviews prioritize resolvable dossiers beyond the oldest 200',()=>isolated(async()=>{
 await db.exec(`with leads as (
  insert into public.crm_leads(school_code,full_name,email,source)
   select 'EMSP','Synthetic batch','routing-batch-'||i||'@example.invalid','DIRECT' from generate_series(1,201) i returning id
 ) insert into public.crm_applications(lead_id,school_code,campus_code,application_reference,admission_type)
  select id,'EMSP','TORCY','ROUTING-BATCH-'||id,'INTERNATIONAL' from leads;`);
 const resolvable=await routingApplication();await routingRule();
 const preview=await routing('routing_reassign_preview');assert.equal(preview.total_unassigned,202);assert.equal(preview.rows.length,200);assert.equal(preview.has_more,true);
 const rows=reviewedRows(preview);assert.equal(rows.length,1);assert.equal(rows[0].id,resolvable.id);
 assert.deepEqual(await routing('routing_reassign_apply',{rows}),{assigned:1,skipped:0});
}));

test('school readiness follows the effective general rule instead of an unused lower-priority rule',()=>isolated(async()=>{
 await allowBackup();await routingRule({priority:0});await routingRule({primary_user:cm,priority:10});
 await db.exec(`update public.profiles set is_active=false where user_id='${cm}'`);
 const school=(await routing('routing_context')).schools.find((s:any)=>s.code==='MLV BTS');
 assert.equal(school.general_ready,false);assert.equal(Number(school.active_rules),2);
 assert.equal((await routingApplication()).assigned_admissions_user,null);
}));

const documentAction=(name:string,data:object={},actor=reviewer)=>invoke('mbn_document_requests_action',[actor,sid(actor),name,JSON.stringify(data)]);
const correctionItems=[{kind:'CV',reason:'Merci de joindre un CV lisible et à jour.'}];
const correctionManifest=[{kind:'CV',original_name:'updated-cv.pdf',mime_type:'application/pdf',byte_size:20,sha256:'b'.repeat(64),extension:'pdf'}];
async function correctionApplication(){
 const leadRow=await action('lead_save',lead()),link=await invoke('mbn_mail_link',[leadRow.id]);
 const payload={reference_dossier:'MBNAPP-'+link.id,school_code:'MLV BTS',campus_code:'NOISIEL',program_id:program,program_name:'Synthetic BTS',cycle:'BTS',full_name:'Synthetic Prospect',email:'synthetic@example.invalid',country_of_residence:'Cameroun',consent_email:false};
 const docs=['CV','DIPLOME','PIECE_IDENTITE'].map(kind=>({kind,original_name:kind+'.pdf',mime_type:'application/pdf',byte_size:20,sha256:'a'.repeat(64),extension:'pdf'}));
 const draft=await invoke('mbn_candidate_prepare',[link.id,JSON.stringify(payload),'{}',JSON.stringify(docs),'a'.repeat(64)]);
 for(const d of docs)await db.query('insert into storage.objects(bucket_id,name,metadata) values($1,$2,$3)',['mbn-admissions',draft.submission_id+'/'+d.kind+'.pdf',JSON.stringify({size:20,mimetype:'application/pdf'})]);
 const receipt=await invoke('mbn_candidate_complete',[link.id,draft.submission_id]);
 const detail=await action('application_detail',{id:receipt.application_id});
 for(const doc of detail.documents)await action('document_review',{id:receipt.application_id,document_id:doc.id,review_status:doc.kind==='CV'?'REJECTED':'APPROVED',note:'Synthetic review'},reviewer);
 return {id:receipt.application_id,documents:detail.documents,lead_id:leadRow.id};
}
const createCorrection=(application_id:string,overrides={})=>documentAction('create',{application_id,request_id:crypto.randomUUID(),items:correctionItems,...overrides});
async function uploadCorrection(request_id:string){
 const draft=await invoke('mbn_correction_prepare',[request_id,JSON.stringify(correctionManifest),'c'.repeat(64)]);
 await db.query('insert into storage.objects(bucket_id,name,metadata) values($1,$2,$3)',['mbn-admissions',draft.submission_id+'/CV.pdf',JSON.stringify({size:20,mimetype:'application/pdf'})]);return draft;
}

test('document requests require review permission and preserve already approved pieces',()=>isolated(async()=>{
 const app=await correctionApplication();
 await assert.rejects(documentAction('context',{application_id:app.id},cm),{message:'record_not_found'});
 await assert.rejects(documentAction('context',{application_id:app.id},other),{message:'record_not_found'});
 await assert.rejects(createCorrection(app.id,{items:[{kind:'DIPLOME',reason:'Synthetic reason'}]}),{message:'document_already_approved'});
 await assert.rejects(createCorrection(app.id,{items:[...correctionItems,...correctionItems]}),{message:'invalid_document_request'});
 const request_id=crypto.randomUUID(),q=await createCorrection(app.id,{request_id});
 assert.equal(q.id,request_id);assert.equal((await createCorrection(app.id,{request_id})).id,q.id);
 await assert.rejects(createCorrection(app.id),{message:'document_request_exists'});
 const ctx=await invoke('mbn_correction_info',[q.id]);assert.equal(ctx.school_code,'MLV BTS');assert.equal(ctx.email,undefined);assert.equal(ctx.documents,undefined);assert.deepEqual(ctx.items,correctionItems);
 assert.equal((await action('application_detail',{id:app.id})).application.status,'MISSING_DOCUMENTS');
 const {rows:[priv]}=await db.query<any>("select has_function_privilege('anon','public.mbn_correction_info(uuid)','EXECUTE') allowed");assert.equal(priv.allowed,false);
}));

test('requested corrections reserve exact files, retain earlier versions and require a fresh review',()=>isolated(async()=>{
 const app=await correctionApplication(),q=await createCorrection(app.id);
 const draft=await invoke('mbn_correction_prepare',[q.id,JSON.stringify(correctionManifest),'c'.repeat(64)]);
 await assert.rejects(invoke('mbn_correction_complete',[q.id,draft.submission_id]),{message:'documents_pending'});
 await assert.rejects(invoke('mbn_correction_prepare',[q.id,JSON.stringify(correctionManifest),'d'.repeat(64)]),{message:'reference_conflict'});
 await db.query('insert into storage.objects(bucket_id,name,metadata) values($1,$2,$3)',['mbn-admissions',draft.submission_id+'/CV.pdf',JSON.stringify({size:20,mimetype:'application/pdf'})]);
 assert.deepEqual(await invoke('mbn_correction_complete',[q.id,draft.submission_id]),{success:true,duplicated:false,document_count:1});
 assert.equal((await invoke('mbn_correction_complete',[q.id,draft.submission_id])).duplicated,true);
 assert.equal((await invoke('mbn_correction_prepare',[q.id,JSON.stringify(correctionManifest),'c'.repeat(64)])).completed,true);
 const context=await documentAction('context',{application_id:app.id});assert.equal(context.documents.length,4);
 const old=context.documents.find((d:any)=>d.id===app.documents.find((d:any)=>d.kind==='CV').id),current=context.documents.find((d:any)=>d.kind==='CV'&&!d.superseded_at);
 assert.ok(old.superseded_at);assert.equal(current.review_status,'PENDING');assert.equal(current.sha256,undefined);assert.equal(current.scan_status,'NOT_SCANNED');
 for(const original of app.documents.filter((d:any)=>d.kind!=='CV'))assert.ok(context.documents.some((d:any)=>d.id===original.id&&!d.superseded_at&&d.review_status==='APPROVED'));
 assert.equal((await action('application_detail',{id:app.id})).application.status,'DOCUMENTS_TO_VERIFY');
 await assert.rejects(action('document_review',{id:app.id,document_id:old.id,review_status:'APPROVED',note:'Stale review'},reviewer),{message:'document_superseded'});
 await assert.rejects(action('application_transition',{id:app.id,expected_status:'DOCUMENTS_TO_VERIFY',status:'COMPLETE'},reviewer),{message:'required_documents_not_approved'});
 await action('document_review',{id:app.id,document_id:current.id,review_status:'APPROVED',note:'New review'},reviewer);
 await action('application_transition',{id:app.id,expected_status:'DOCUMENTS_TO_VERIFY',status:'COMPLETE'},reviewer);
 assert.equal((await action('application_detail',{id:app.id})).application.status,'COMPLETE');
}));

test('expired or canceled correction links cannot read or commit a replacement',()=>isolated(async()=>{
 const app=await correctionApplication(),q=await createCorrection(app.id),draft=await uploadCorrection(q.id);
 await documentAction('cancel',{id:q.id});
 await assert.rejects(invoke('mbn_correction_info',[q.id]),{message:'link_unavailable'});
 await assert.rejects(invoke('mbn_correction_complete',[q.id,draft.submission_id]),{message:'link_unavailable'});
 const next=await createCorrection(app.id);await db.query("update private.mbn_document_requests set expires_at=now()-interval '1 second' where id=$1",[next.id]);
 await assert.rejects(invoke('mbn_correction_info',[next.id]),{message:'link_unavailable'});
 const third=await createCorrection(app.id);assert.notEqual(third.id,next.id);
 assert.equal((await documentAction('context',{application_id:app.id})).documents.length,3);
}));

test('a correction cannot replace an unrequested kind or a piece approved after the request',()=>isolated(async()=>{
 const app=await correctionApplication(),q=await createCorrection(app.id);
 await assert.rejects(invoke('mbn_correction_prepare',[q.id,'[]','c'.repeat(64)]),{message:'requested_documents_only'});
 await assert.rejects(invoke('mbn_correction_prepare',[q.id,JSON.stringify([{...correctionManifest[0],kind:'DIPLOME'}]),'c'.repeat(64)]),{message:'invalid_document'});
 const draft=await uploadCorrection(q.id),original=app.documents.find((d:any)=>d.kind==='CV');
 await action('document_review',{id:app.id,document_id:original.id,review_status:'APPROVED',note:'Approved while waiting'},reviewer);
 await assert.rejects(invoke('mbn_correction_complete',[q.id,draft.submission_id]),{message:'document_request_changed'});
 await assert.rejects(action('application_transition',{id:app.id,expected_status:'MISSING_DOCUMENTS',status:'COMPLETE'},reviewer),{message:'document_request_pending'});
 assert.equal((await documentAction('context',{application_id:app.id})).documents.length,3);
}));

test('a correction email uses its school sender without marketing consent and has a single send lease',()=>isolated(async()=>{
 await enableGroups();const app=await correctionApplication(),q=await createCorrection(app.id);
 await db.query("update public.crm_leads set consent_email=false,status='UNSUBSCRIBED',unsubscribed_at=now() where id=$1",[app.lead_id]);
 const claim=await documentAction('claim',{id:q.id});assert.equal(claim.sender.from_email,groupEmail('CAMPUS_INNOVATION_MLV'));assert.equal(claim.message.document_request_id,q.id);
 assert.equal(await documentAction('authorized',{id:q.id,attempt_id:claim.message.attempt_id}),true);
 await assert.rejects(documentAction('claim',{id:q.id}),{message:'document_request_already_sent'});
 await routeSave('ADMISSIONS_COMMUN',{school_code:'MLV BTS'});
 assert.equal(await documentAction('authorized',{id:q.id,attempt_id:claim.message.attempt_id}),false);
 assert.equal((await db.query<any>('select status from public.mail_messages where id=$1',[claim.message.id])).rows[0].status,'CANCELED');
}));

test('correction email readiness, address suppression and the shared quota block before a send lease',()=>isolated(async()=>{
 const app=await correctionApplication(),q=await createCorrection(app.id);
 await assert.rejects(documentAction('claim',{id:q.id}),{message:'mail_route_missing'});
 await enableGroups();await groupSave('CAMPUS_INNOVATION_MLV');
 await assert.rejects(documentAction('claim',{id:q.id}),{message:'sender_not_ready'});
 await groupSave('CAMPUS_INNOVATION_MLV',{enabled:true});await action('mail_limit_save',{daily_limit:3});
 await assert.rejects(documentAction('claim',{id:q.id}),{message:'daily_limit_reached'});
 await action('mail_limit_save',{daily_limit:100});await db.query('update public.crm_leads set email_suppressed_at=now() where id=$1',[app.lead_id]);
 await assert.rejects(documentAction('claim',{id:q.id}),{message:'document_request_unavailable'});
 assert.equal((await documentAction('context',{application_id:app.id})).requests[0].message_id,null);
}));

test('a correction request stays bound to its dossier and rejects invalid metadata or an excluded applicant',()=>isolated(async()=>{
 const app=await correctionApplication(),q=await createCorrection(app.id),otherApp=await routingApplication();
 await assert.rejects(documentAction('context',{application_id:otherApp.id,id:q.id}),{message:'record_not_found'});
 await assert.rejects(invoke('mbn_correction_prepare',[q.id,JSON.stringify([{...correctionManifest[0],mime_type:null}]),'c'.repeat(64)]),{message:'invalid_document'});
 await enableGroups();const claim=await documentAction('claim',{id:q.id});
 await db.query("update public.crm_leads set status='DISQUALIFIED' where id=$1",[app.lead_id]);
 await assert.rejects(invoke('mbn_correction_info',[q.id]),{message:'link_unavailable'});
 await assert.rejects(documentAction('claim',{id:q.id}),{message:'document_request_unavailable'});
 assert.equal(await documentAction('authorized',{id:q.id,attempt_id:claim.message.attempt_id}),false);
 assert.equal((await db.query<any>('select status from public.mail_messages where id=$1',[claim.message.id])).rows[0].status,'CANCELED');
}));
