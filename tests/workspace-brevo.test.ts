import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createBrevo,BREVO_WEBHOOK} from '../supabase/functions/mbn-workspace/brevo.ts';
import {createHandler,normalize} from '../supabase/functions/mbn-brevo-events/handler.ts';
import {createHandler as workspace} from '../supabase/functions/mbn-workspace/handler.ts';
const id='40000000-0000-4000-8000-000000000001',other='40000000-0000-4000-8000-000000000002';
const sender={from_name:'Campus Innovation Marne-la-Vallée',from_email:'sender@example.invalid',reply_to:'reply@example.invalid',identity:'',region:'eu-west-3',configuration_set:'',daily_limit:100};
const message={id,recipient:'recipient@example.invalid',subject:'Évry · admission',text:'Synthetic',html:'<p>Synthetic</p>'};
const secret='synthetic-webhook-'.repeat(6);
test('Brevo uses HTTPS API credentials, raw UTF-8 school names and private attachment bytes',async()=>{
 let calls=0;const brevo=createBrevo('synthetic-api-key',async(url,init)=>{calls++;assert.equal(url,'https://api.brevo.com/v3/smtp/email');assert.equal((init?.headers as any)['api-key'],'synthetic-api-key');assert.equal(init?.redirect,'error');const body=JSON.parse(String(init?.body));assert.equal(body.sender.name,sender.from_name);assert.equal(body.to.length,1);assert.deepEqual(body.attachment,[{name:'admission.pdf',content:'JVBERi0='}]);assert.deepEqual(body.tags,['mbn_'+id]);assert.equal(body.headers['X-Mailin-custom'],'mbn_message_id:'+id);assert.ok(!JSON.stringify(body).includes('/storage/'));return new Response(JSON.stringify({messageId:'<brevo-id>'}),{status:201});});
 assert.deepEqual(await brevo.send(sender,{...message,attachments:[{filename:'admission.pdf',mime_type:'application/pdf',base64:'JVBERi0='}]}),{status:'ACCEPTED',provider_id:'<brevo-id>'});assert.equal(calls,1);
});
test('Brevo outcomes never infer delivery and never retry an ambiguous HTTP acceptance',async()=>{
 for(const [status,value,expected] of [[201,{messageId:'<accepted>'},'ACCEPTED'],[201,{},'UNCERTAIN'],[400,{},'FAILED'],[429,{},'FAILED'],[503,{},'UNCERTAIN'],[408,{},'UNCERTAIN']] as const){let calls=0;const brevo=createBrevo('synthetic',async()=>{calls++;return new Response(JSON.stringify(value),{status});});assert.equal((await brevo.send(sender,message)).status,expected);assert.equal(calls,1);}
 assert.equal((await createBrevo('synthetic',async()=>{throw Error('timeout');}).send(sender,message)).status,'UNCERTAIN');
});
test('Brevo verifies the actual sender, relay and email credits without counting SMS credits',async()=>{
 const fetcher=async(url:RequestInfo|URL)=>new Response(JSON.stringify(String(url).endsWith('/account')?{relay:{enabled:true},plan:[{type:'free',credits:35},{type:'sms',credits:999999}]}:{senders:[{active:true,email:'SENDER@example.invalid'}]}));
 const inspection=await createBrevo('synthetic',fetcher).inspect(sender);assert.equal(inspection.sender_verified,true);assert.equal(inspection.production_access,true);assert.equal(inspection.remaining,35);assert.match(inspection.credential_fingerprint!,/^[a-f0-9]{64}$/);
 const exhausted=await createBrevo('synthetic',async url=>new Response(JSON.stringify(String(url).endsWith('/account')?{relay:{enabled:true},plan:[{type:'sms',credits:999}]}:{senders:[{active:true,email:sender.from_email}]}))).inspect(sender);assert.equal(exhausted.remaining,0);assert.equal(exhausted.error,'brevo_quota_unavailable');
});
test('missing Brevo credentials stop before an owner test can be queued',async()=>{
 const calls:string[]=[];const handler=workspace({authenticate:async()=>({id,session_id:other}),rpc:async(name,args)=>{calls.push(name+':'+String(args.p_action||''));return {data:sender,error:null};},transport:createBrevo(undefined),download:async()=>new Uint8Array(),sleep:async()=>{}});
 const response=await handler(new Request('https://example.invalid',{method:'POST',headers:{authorization:'Bearer '+'t'.repeat(30)},body:JSON.stringify({action:'test_send'})}));assert.equal(response.status,422);assert.equal((await response.json()).error,'brevo_credentials_missing');assert.ok(!calls.some(n=>n.includes('test_prepare')||n.includes('mbn_mail_claim')));
});
test('Brevo callback setup is scoped to the MBN URL and installs bearer authentication',async()=>{
 const requests:any[]=[];const brevo=createBrevo('synthetic',async(url,init)=>{requests.push({url,init});return new Response(JSON.stringify(init?.method==='GET'?{webhooks:[{id:88,url:'https://another.example.invalid/hook'}]}:{id:12}),{status:init?.method==='GET'?200:201});});
 assert.deepEqual(await brevo.configureWebhook(secret),{id:12});const body=JSON.parse(requests[1].init.body);assert.equal(body.url,BREVO_WEBHOOK);assert.equal(body.auth.type,'bearer');assert.equal(body.auth.token,secret);assert.equal(body.batched,false);assert.ok(body.events.includes('delivered'));assert.ok(!body.events.includes('click'));assert.ok(!body.events.includes('opened'));assert.equal(requests[1].init.method,'POST');
});
test('Brevo callback setup updates an existing MBN hook and refuses ambiguous duplicates',async()=>{
 const methods:string[]=[];const client=createBrevo('synthetic',async(_url,init)=>{methods.push(init!.method!);return init?.method==='GET'?new Response(JSON.stringify({webhooks:[{id:12,url:BREVO_WEBHOOK}]})):new Response(null,{status:204});});assert.deepEqual(await client.configureWebhook(secret),{id:12});assert.deepEqual(methods,['GET','PUT']);
 await assert.rejects(createBrevo('synthetic',async()=>new Response(JSON.stringify({webhooks:[{id:1,url:BREVO_WEBHOOK},{id:2,url:BREVO_WEBHOOK}]}))).configureWebhook(secret),{message:'brevo_duplicate_webhooks'});
});
const payload={event:'delivered',email:message.recipient,'message-id':'<brevo-id>',tags:['mbn_'+id],id:12,ts_event:1792400000};
test('Brevo callbacks authenticate before parsing and reject forged tokens without database writes',async()=>{
 let writes=0;const handler=createHandler({secret:async()=>secret,rpc:async()=>{writes++;return {data:true,error:null};}});
 assert.equal((await handler(new Request('https://example.invalid',{method:'POST',body:'invalid'}))).status,403);assert.equal(writes,0);
 assert.equal((await handler(new Request('https://example.invalid',{method:'POST',headers:{authorization:'Bearer '+'x'.repeat(secret.length)},body:JSON.stringify(payload)}))).status,403);assert.equal(writes,0);
});
test('Brevo handles single and batched callbacks, hashes deduplication keys and ignores pixel/click events',async()=>{
 const calls:any[]=[];const handler=createHandler({secret:async()=>secret,rpc:async(_name,args)=>{calls.push(args);return {data:true,error:null};}});
 const request=(body:unknown)=>new Request('https://example.invalid',{method:'POST',headers:{authorization:'Bearer '+secret},body:JSON.stringify(body)});
 assert.equal((await handler(request(payload))).status,200);assert.match(calls[0].p_key,/^[a-f0-9]{64}$/);assert.equal(calls[0].p_event.message_id,id);
 assert.equal((await handler(request([payload,{...payload,event:'opened'},{...payload,event:'click'}]))).status,200);assert.equal(calls.length,2);assert.equal(calls[0].p_key,calls[1].p_key);
 assert.equal(normalize({...payload,tags:[],tag:JSON.stringify(['mbn_'+id])})?.message_id,id);assert.throws(()=>normalize({...payload,'X-Mailin-custom':'mbn_message_id:'+other}));
});
test('Brevo receives retryable 429 for callbacks that race a send or encounter a temporary database failure',async()=>{
 for(const failure of ['pending','unavailable']){const handler=createHandler({secret:async()=>secret,rpc:async()=>{if(failure==='unavailable')throw Error('temporary');return {data:null,error:{code:'PT409',message:'message_pending'}};}});const response=await handler(new Request('https://example.invalid',{method:'POST',headers:{authorization:'Bearer '+secret},body:JSON.stringify(payload)}));assert.equal(response.status,429);}
});

test('automatic mail includes the school service contact in HTML and plain text without losing unsubscribe',async()=>{
 const {renderMessage}=await import('../supabase/functions/mbn-workspace/handler.ts');
 for(const school_code of ['EMSP','MLV BTS','ESETH']){
  const mail=renderMessage({school_code,subject:'Admission',body:'Bonjour {{prenom}}',lead:{full_name:'Fatoumata Test'},service_contact_email:'admissions-school@example.invalid'},'https://example.invalid/apply','https://example.invalid/preferences');
  assert.ok(mail.text.includes('Merci de ne pas répondre'));assert.ok(mail.html.includes('Merci de ne pas répondre'));
  assert.ok(mail.text.includes('admissions-school@example.invalid'));assert.ok(mail.html.includes('href="mailto:admissions-school@example.invalid"'));
  assert.ok(mail.text.includes('https://example.invalid/preferences'));assert.ok(mail.html.includes('https://example.invalid/preferences'));
 }
 assert.throws(()=>renderMessage({school_code:'EMSP',subject:'Test',body:'Test',service_contact_email:'x@example.invalid\nBcc: other@example.invalid'}));
});
test('dispatch chooses all three server-side sender snapshots and keeps replies on the automatic addresses',async()=>{
 for(const firstReady of [false,true]){
  const groups=['MBN_GLOBAL','CAMPUS_INNOVATION_MLV','ADMISSIONS_COMMUN'],sent:any[]=[],claimed=new Set(),finished:string[]=[];
  const profile=(group:string)=>({code:group,revision:id,from_name:group,from_email:'no-reply@'+group.toLowerCase()+'.example.invalid',reply_to:'ignored@example.invalid',enabled:true});
  const handler=workspace({authenticate:async()=>({id,session_id:other}),rpc:async(name,args)=>{
   if(name==='mbn_workspace_action')return {data:{},error:null};
   if(name==='mbn_mail_profile_settings'||name==='mbn_mail_profile_checked')return {data:profile(String(args.p_group)),error:null};
   if(name==='mbn_mail_profile_claim'){
    const group=String(args.p_group);if(claimed.has(group))return {data:null,error:null};claimed.add(group);
    return {data:{id:'40000000-0000-4000-8000-00000000000'+(groups.indexOf(group)+1),attempt_id:other,lead_id:id,school_code:group==='MBN_GLOBAL'?'EMSP':group==='CAMPUS_INNOVATION_MLV'?'MLV BTS':'ESETH',recipient:group.toLowerCase()+'-candidate@example.invalid',subject:'Admission',body:'Bienvenue {{prenom}}',service_contact_email:group.toLowerCase()+'-service@example.invalid',sender:profile(group),lead:{full_name:'Synthetic Test'}},error:null};
   }
   if(name==='mbn_mail_link')return {data:{id,revoked:false,expires_at:'2099-01-01'},error:null};
   if(name==='mbn_runtime_key')return {data:secret,error:null};
   if(name==='mbn_mail_profile_authorized')return {data:true,error:null};
   if(name==='mbn_mail_finish'){finished.push(String(args.p_id));return {data:true,error:null};}
   throw Error('Unexpected RPC '+name);
  },transport:{configured:true,inspect:async s=>({sender_verified:firstReady||s.code!=='MBN_GLOBAL',production_access:true,account_sending_enabled:true,remaining:10,rate:1}),send:async(s,m)=>{sent.push({s,m});return {status:'ACCEPTED',provider_id:'<'+m.id+'>'};}},download:async()=>new Uint8Array(),sleep:async()=>{}});
  const response=await handler(new Request('https://example.invalid',{method:'POST',headers:{authorization:'Bearer '+'t'.repeat(30)},body:JSON.stringify({action:'dispatch'})}));
  assert.equal(response.status,200);const result=await response.json();assert.equal(result.processed,firstReady?3:2);assert.equal(sent.length,firstReady?3:2);assert.equal(finished.length,sent.length);
  for(const {s,m} of sent){assert.equal(s.reply_to,s.from_email);assert.ok(m.text.includes(s.code.toLowerCase()+'-service@example.invalid'));assert.equal(m.recipient,s.code.toLowerCase()+'-candidate@example.invalid');}
  assert.ok(sent.some(({s})=>s.code==='CAMPUS_INNOVATION_MLV'));assert.ok(sent.some(({s})=>s.code==='ADMISSIONS_COMMUN'));assert.equal(result.skipped.length,firstReady?0:1);
 }
});
test('mail administration checks owner authorization before inspecting or sending through Brevo',async()=>{
 let external=0;const handler=workspace({authenticate:async()=>({id,session_id:other}),rpc:async()=>({data:null,error:{code:'PT403',message:'access_denied'}}),transport:{configured:true,inspect:async()=>{external++;throw Error('must not inspect');},send:async()=>{external++;throw Error('must not send');}},download:async()=>new Uint8Array(),sleep:async()=>{}});
 const response=await handler(new Request('https://example.invalid',{method:'POST',headers:{authorization:'Bearer '+'t'.repeat(30)},body:JSON.stringify({action:'test_send',data:{sender_group:'CAMPUS_INNOVATION_MLV'}})}));
 assert.equal(response.status,403);assert.equal(external,0);
});

test('an administrator can explicitly select the neutral third sender for its own delivery test',async()=>{
 let sent=0,prepared=false;
 const profile={...sender,code:'ADMISSIONS_COMMUN',revision:id,from_name:'Service admissions',enabled:false};
 const handler=workspace({authenticate:async()=>({id,session_id:other}),rpc:async(name,args)=>{
  if(name==='mbn_workspace_action'){
   if(args.p_action==='mail_test_prepare'){assert.deepEqual(args.p_data,{sender_group:'ADMISSIONS_COMMUN'});prepared=true;return {data:{id},error:null};}
   return {data:{},error:null};
  }
  if(name==='mbn_mail_profile_settings'||name==='mbn_mail_profile_checked'){assert.equal(args.p_group,'ADMISSIONS_COMMUN');return {data:profile,error:null};}
  if(name==='mbn_mail_profile_claim'){
   assert.equal(args.p_group,'ADMISSIONS_COMMUN');assert.equal(args.p_test_id,id);
   return {data:{id,attempt_id:other,is_test:true,school_code:'ESETH',recipient:'administrator@example.invalid',subject:'Test',body:'Synthetic',service_contact_email:'eseth-service@example.invalid',sender:profile},error:null};
  }
  if(name==='mbn_mail_profile_authorized'||name==='mbn_mail_finish')return {data:true,error:null};
  throw Error('Unexpected RPC '+name);
 },transport:{configured:true,inspect:async()=>({sender_verified:true,production_access:true,account_sending_enabled:true,remaining:10,rate:1}),send:async(s,m)=>{sent++;assert.equal(s.from_name,'Service admissions');assert.equal(s.reply_to,s.from_email);assert.ok(m.text.includes('eseth-service@example.invalid'));return {status:'ACCEPTED',provider_id:'<neutral-test>'};}},download:async()=>new Uint8Array(),sleep:async()=>{}});
 const response=await handler(new Request('https://example.invalid',{method:'POST',headers:{authorization:'Bearer '+'t'.repeat(30)},body:JSON.stringify({action:'test_send',data:{sender_group:'ADMISSIONS_COMMUN'}})}));
 assert.equal(response.status,200);assert.equal((await response.json()).processed,1);assert.equal(sent,1);assert.equal(prepared,true);
});
