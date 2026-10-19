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
const letterFields={academic_year:'2026/2027',intake:'janvier 2027',deferred_intake:'septembre 2027',registration_fee:'1000',tuition_deposit:'1000',confirmation_days:'30',date_of_birth:'2000-01-02',place_of_birth:'Lieu synthétique',signatory:'Service synthétique',avi_mode:'OPTIONAL',logo_variant:'CAMPUS'};
const letterAction=(name:string,data:object={},actor=owner)=>invoke('mbn_letter_action',[actor,sid(actor),name,JSON.stringify(data)]);
async function admissionLetter(overrides={}){
 const a=await application();await db.query("update public.crm_applications set status='ADMITTED' where id=$1",[a.id]);
 await db.exec('update private.mbn_original_assets set installed_at=now()');
 const id=crypto.randomUUID();const prepared=await letterAction('prepare',{application_id:a.id,request_id:id,fields:{...letterFields,...overrides},attachments:['cgv_group']});
 return {a,id,prepared};
}
test('letters require an admitted international dossier, separate send permission and the campus logo',()=>isolated(async()=>{
 const a=await application();await assert.rejects(letterAction('context',{application_id:a.id},cm),{message:'access_denied'});
 await assert.rejects(letterAction('prepare',{application_id:a.id,request_id:crypto.randomUUID(),fields:letterFields,attachments:[]}),{message:'international_admission_required'});
 await db.query("update public.crm_applications set status='ADMITTED' where id=$1",[a.id]);
 await assert.rejects(letterAction('prepare',{application_id:a.id,request_id:crypto.randomUUID(),fields:{...letterFields,logo_variant:'SCHOOL'},attachments:[]}),{message:'campus_brand_required'});
 await assert.rejects(letterAction('prepare',{application_id:a.id,request_id:crypto.randomUUID(),fields:{...letterFields,school_name:'Spoofed School'},attachments:[]}),{message:'invalid_letter'});
 await db.exec('update private.mbn_original_assets set installed_at=now()');
 await assert.rejects(letterAction('prepare',{application_id:a.id,request_id:crypto.randomUUID(),fields:letterFields,attachments:['cgv_cescom']}),{message:'invalid_attachments'});
 await assert.rejects(letterAction('prepare',{application_id:a.id,request_id:crypto.randomUUID(),fields:letterFields,attachments:['avi_attestation']}),{message:'avi_attachment_conflict'});
}));
test('letter previews are immutable and send once with an explicit approval, never an invented delivery',()=>isolated(async()=>{
 const {a,id,prepared}=await admissionLetter();assert.equal(prepared.fields.school_name,'Marne-la-Vallée BTS');assert.equal(prepared.fields.campus_name,'Campus Innovation Marne-la-Vallée');assert.equal(prepared.message_id,null);
 await assert.rejects(letterAction('prepare',{application_id:a.id,request_id:id,fields:{...letterFields,registration_fee:'2000'},attachments:['cgv_group']}),{message:'reference_conflict'});
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

const groupCodes=['MBN_GLOBAL','CAMPUS_INNOVATION_MLV'] as const;
const groupSchool=(group:string)=>group==='MBN_GLOBAL'?'EMSP':'MLV BTS';
const groupEmail=(group:string)=>group==='MBN_GLOBAL'?'no-reply@mbn.example.invalid':'no-reply@campus.example.invalid';
const groupName=(group:string)=>group==='MBN_GLOBAL'?'MBN Global Éducation':'Campus Innovation Marne-la-Vallée';
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
 if(deliver)await invoke('mbn_brevo_event',[(group==='MBN_GLOBAL'?'1':'2').repeat(64),JSON.stringify(event)]);
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
test('two sender profiles start paused with no inferred domains or school affiliations',()=>isolated(async()=>{
 const config=await action('mail_config_get');assert.equal(config.groups.length,2);assert.equal(config.schools.length,19);
 assert.ok(config.groups.every((g:any)=>g.from_email===''&&!g.enabled&&!('credential_fingerprint' in g)));
 assert.ok(config.schools.every((s:any)=>s.sender_group===null&&s.admissions_email===''));
 assert.equal(await invoke('mbn_mail_profile_claim',['MBN_GLOBAL',null]),null);
 await assert.rejects(action('mail_config_get',{},cm),{message:'access_denied'});
 for(const rpc of ['mbn_mail_profile_settings(text,text)','mbn_mail_profile_checked(text,uuid,jsonb)','mbn_mail_profile_claim(text,uuid)','mbn_mail_profile_authorized(uuid,uuid)','mbn_letter_profile_action(uuid,uuid,text,jsonb)']){
  const {rows:[p]}=await db.query<{allowed:boolean}>("select has_function_privilege('authenticated',$1,'EXECUTE') allowed",['public.'+rpc]);assert.equal(p.allowed,false);
 }
}));
test('an administrator explicitly selects each school route and cannot reuse one sender for both groups',()=>isolated(async()=>{
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
test('rotating the shared key or rebuilding the webhook invalidates proofs for both senders',()=>isolated(async()=>{
 await enableGroups();const stale=await invoke('mbn_mail_profile_settings',['CAMPUS_INNOVATION_MLV']);
 await groupCheck('MBN_GLOBAL','b'.repeat(64));
 let config=await action('mail_config_get');assert.ok(config.groups.every((g:any)=>!g.enabled&&g.events_verified_at===null));assert.equal(config.brevo_webhook_id,null);
 await assert.rejects(invoke('mbn_mail_profile_checked',['CAMPUS_INNOVATION_MLV',stale.revision,JSON.stringify({credential_fingerprint:'a'.repeat(64)})]),{message:'mail_configuration_changed'});
 await invoke('mbn_brevo_event',['5'.repeat(64),JSON.stringify({event:'delivered',provider_id:'<test-MBN_GLOBAL>',email:'nbtonybill@gmail.com'})]);
 assert.ok((await action('mail_config_get')).groups.every((g:any)=>g.events_verified_at===null));
 await invoke('mbn_brevo_webhook_configured',[13]);
 config=await action('mail_config_get');assert.ok(config.groups.every((g:any)=>!g.enabled&&g.events_verified_at===null));
}));
test('the daily allowance is shared by both senders and includes tests and in-flight attempts',()=>isolated(async()=>{
 await enableGroups();await action('mail_limit_save',{daily_limit:3});
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
test('reconfiguring the same webhook invalidates both successful tests and ignores their delayed callbacks',()=>isolated(async()=>{
 await enableGroups();
 await invoke('mbn_brevo_webhook_configured',[12]);
 let config=await action('mail_config_get');assert.ok(config.groups.every((g:any)=>!g.enabled&&g.events_verified_at===null));
 await invoke('mbn_brevo_event',['6'.repeat(64),JSON.stringify({event:'delivered',provider_id:'<test-MBN_GLOBAL>',email:'nbtonybill@gmail.com'})]);
 config=await action('mail_config_get');assert.ok(config.groups.every((g:any)=>!g.enabled&&g.events_verified_at===null));
}));
