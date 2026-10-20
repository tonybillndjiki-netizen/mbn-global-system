import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createHandler} from '../supabase/functions/mbn-letters/handler.ts';
import {createSES,senderAddress} from '../supabase/functions/mbn-workspace/ses.ts';
import {digest} from '../supabase/functions/mbn-form-ingest/handler.ts';
import {createHandler as admissions} from '../supabase/functions/mbn-admissions/handler.ts';
import {renderMessage} from '../supabase/functions/mbn-workspace/handler.ts';
const actor={id:'20000000-0000-4000-8000-000000000001',session_id:'30000000-0000-4000-8000-000000000001'},id='40000000-0000-4000-8000-000000000001',attempt='50000000-0000-4000-8000-000000000001';
const bytes=new TextEncoder().encode('%PDF-1.4 synthetic\n%%EOF'),secret='synthetic-secret-'.repeat(10);
const sender={from_name:'Synthetic',from_email:'sender@example.invalid',reply_to:'',identity:'example.invalid',region:'eu-west-3',configuration_set:'synthetic'};
const req=(action:string,data={})=>new Request('https://example.invalid',{method:'POST',headers:{authorization:'Bearer '+('x'.repeat(30)),'content-type':'application/json'},body:JSON.stringify({action,data})});
function api(overrides:Record<string,any>={}){
 const calls:{name:string;args:any}[]=[],uploads:unknown[]=[];let sends=0;
 const deps={authenticate:async()=>actor,rpc:async(name:string,args:any)=>{calls.push({name,args});return {data:null,error:null};},download:async()=>bytes,upload:async(...args:any[])=>{uploads.push(args);},transport:{configured:false,inspect:createSES(undefined).inspect,send:async()=>{sends++;return {status:'ACCEPTED' as const,provider_id:'synthetic'};}},...overrides};
 return {handler:createHandler(deps as any),calls,uploads,sends:()=>sends};
}
test('letters authenticate before parsing or downloading private files',async()=>{
 const {handler,calls}=api({authenticate:async()=>null});const r=await handler(new Request('https://example.invalid',{method:'POST',body:'bad json'}));assert.equal(r.status,401);assert.equal(calls.length,0);
});
test('letter configuration is routed to the permission-checked settings RPC and preserves validation errors',async()=>{
 const {handler,calls}=api({rpc:async(name:string,args:any)=>{calls.push({name,args});return args.p_action==='save'?{data:null,error:{code:'PT409',message:'letter_settings_changed'}}:{data:{settings:[]},error:null};}});
 const get=await handler(req('letter_config_get'));assert.equal(get.status,200);assert.equal(calls[0].name,'mbn_letter_config_action');assert.equal(calls[0].args.p_action,'get');
 const save=await handler(req('letter_config_save',{school_code:'MLV BTS',enabled:true}));assert.equal(save.status,409);assert.equal((await save.json()).error,'letter_settings_changed');assert.equal(calls[1].args.p_actor,actor.id);
});
test('a national admission uses its own mail text and the school sender without international terms',async()=>{
 const row={id,school_code:'MLV BTS',generated_at:'2026-10-19',pdf_sha256:await digest(bytes),pdf_bytes:bytes.length,object_path:id+'/admission.pdf',attachments:[],assets:[],fields:{admission_type:'NATIONAL',full_name:'Synthetic',school_name:'Marne-la-Vallée BTS',reference:'TEST-NATIONAL',email:'synthetic@example.invalid',program_name:'Synthetic',academic_level:'BTS 1',campus_name:'Campus Innovation Marne-la-Vallée',registration_fee:'0',tuition_deposit:'0',intake:'janvier 2027',academic_year:'2026/2027',confirmation_days:'15',avi_mode:'NONE'}};
 let sends=0;
 const {handler}=api({rpc:async(name:string,args:any)=>({data:name==='mbn_mail_profile_settings'?sender:name==='mbn_mail_profile_checked'||name==='mbn_letter_finish'?true:args.p_action==='authorized'?true:args.p_action==='claim'?{...row,sender,message:{id,attempt_id:attempt,service_contact_email:'contact@example.invalid'}}:row,error:null}),transport:{configured:true,inspect:async()=>({sender_verified:true,production_access:true,account_sending_enabled:true,remaining:10,rate:1}),send:async(s:any,m:any)=>{sends++;assert.equal(s.from_name,'Service admissions - Marne-la-Vallée BTS');assert.match(m.text,/contact@example.invalid/);assert.doesNotMatch(m.text,/visa|AVI|Campus France/i);return {status:'ACCEPTED',provider_id:'synthetic-national'};}}});
 const result=await handler(req('letter_send',{id,confirmed:true}));assert.equal(result.status,200);assert.equal((await result.json()).status,'ACCEPTED');assert.equal(sends,1);
});
test('the asset installation route verifies its narrow capability before reading uploaded bytes',async()=>{
 let uploads=0;const {handler}=api({rpc:async()=>({data:null,error:{code:'PT403',message:'access_denied'}}),upload:async()=>{uploads++;}});
 const r=await handler(new Request('https://example.invalid?asset=cgv_group',{method:'POST',headers:{'x-mbn-asset':'forged'},body:'malformed'}));assert.equal(r.status,403);assert.equal(uploads,0);
});
test('an installation ticket cannot replace the pinned original with different bytes',async()=>{
 let uploads=0;const asset={key:'cgv_group',bucket:'mbn-mail-assets',object_path:'cgv_group.pdf',byte_size:bytes.length,sha256:'a'.repeat(64),mime_type:'application/pdf'};
 const {handler}=api({rpc:async()=>({data:asset,error:null}),upload:async()=>{uploads++;}});
 const r=await handler(new Request('https://example.invalid?asset=cgv_group',{method:'POST',headers:{'x-mbn-asset':'a'.repeat(64)},body:bytes}));assert.equal(r.status,422);assert.equal(uploads,0);
});
test('a letter cannot take a send lease when AWS credentials are missing',async()=>{
 const calls:any[]=[];const {handler}=api({rpc:async(name:string,args:any)=>{calls.push({name,args});return {data:name==='mbn_letter_action'?{id,generated_at:'2026-10-19',fields:{},assets:[]}:sender,error:null};}});
 const r=await handler(req('letter_send',{id,confirmed:true}));assert.equal(r.status,422);assert.equal((await r.json()).error,'aws_credentials_missing');assert.ok(!calls.some(c=>c.args.p_action==='claim'));
});
test('SES sends the exact PDF attachment as base64 in its native attachment object',async()=>{
 let payload:any;const ses=createSES({accessKeyId:'synthetic',secretAccessKey:'synthetic'},async(_url,init)=>{payload=JSON.parse(String(init?.body));return new Response(JSON.stringify({MessageId:'synthetic'}));});
 const attachment={filename:'admission.pdf',mime_type:'application/pdf',base64:Buffer.from(bytes).toString('base64')};
 assert.equal((await ses.send(sender,{id,recipient:'synthetic@example.invalid',subject:'Admission',text:'Synthetic',html:'<p>Synthetic</p>',attachments:[attachment]})).status,'ACCEPTED');
 assert.deepEqual(payload.Content.Simple.Attachments,[{RawContent:attachment.base64,FileName:'admission.pdf',ContentType:'application/pdf',ContentDisposition:'ATTACHMENT',ContentTransferEncoding:'BASE64'}]);assert.equal(payload.Destination.ToAddresses.length,1);
});
test('the letter send rechecks authorization after taking its lease and never retries an uncertain outcome',async()=>{
 for(const authorized of [false,true]){
  let sends=0;const calls:any[]=[],row={id,school_code:'MLV BTS',generated_at:'2026-10-19',pdf_sha256:await digest(bytes),pdf_bytes:bytes.length,object_path:id+'/admission.pdf',attachments:[],assets:[],fields:{full_name:'Synthetic',school_name:'Marne-la-Vallée BTS',reference:'SYNTHETIC',email:'synthetic@example.invalid',program_name:'Synthetic',academic_level:'BTS 1',campus_name:'Campus Innovation Marne-la-Vallée',registration_fee:'1000',tuition_deposit:'1000',intake:'janvier 2027',academic_year:'2026/2027',avi_mode:'OPTIONAL'}};
  const {handler}=api({rpc:async(name:string,args:any)=>{calls.push({name,args});return {data:name==='mbn_mail_profile_settings'?sender:name==='mbn_mail_profile_checked'||name==='mbn_letter_finish'?true:args.p_action==='authorized'?authorized:args.p_action==='claim'?{...row,sender:{...sender,from_name:'Campus Innovation Marne-la-Vallée'},message:{id,attempt_id:attempt,service_contact_email:'admissions-school@example.invalid'}}:row,error:null};},transport:{configured:true,inspect:async()=>({sender_verified:true,production_access:true,account_sending_enabled:true,remaining:10,rate:1}),send:async(s:any,m:any)=>{sends++;assert.equal(s.from_name,'Service admissions - Marne-la-Vallée BTS');assert.equal(s.reply_to,s.from_email);assert.ok(m.text.includes('admissions-school@example.invalid'));assert.equal(m.attachments.length,1);assert.ok(!m.html.includes('mbn-global.png'));return {status:'UNCERTAIN'};}}});
  const r=await handler(req('letter_send',{id,confirmed:true}));assert.equal(r.status,200);assert.equal((await r.json()).status,authorized?'UNCERTAIN':'FAILED');assert.equal(sends,authorized?1:0);assert.equal(calls.filter(c=>c.args.p_action==='claim').length,1);assert.equal(calls.find(c=>c.name==='mbn_letter_finish').args.p_status,authorized?'UNCERTAIN':'FAILED');
 }
});
test('hosted school redirects accept no arbitrary destination or school identifier',async()=>{
 const handler=admissions({rpc:async(name,args)=>({data:name==='mbn_runtime_key'?secret:{id,slug:args.p_slug},error:null}),upload:async()=>{}});
 const response=await handler(new Request('https://example.invalid?ecole=mlv-bts'));assert.equal(response.status,303);assert.ok(response.headers.get('location')?.startsWith('https://mbn-global.netlify.app/forms/mlv-bts.html#'+id+'.'));assert.equal(response.headers.get('cache-control'),'no-store');
 assert.equal((await handler(new Request('https://example.invalid?ecole=mlv-bts&redirect=https://evil.invalid'))).status,404);
});
test('all eight campus schools use Campus Innovation and none use the MBN outgoing logo',()=>{
 for(const school of ['CESCOM','ESART','ESEA','ESJM','ESMAS','ESMOSS','MLV BTS','MLV BS']){const mail=renderMessage({school_code:school,subject:'Synthetic',body:'Synthetic'});assert.ok(mail.html.includes('campus-innovation-mlv.png'));assert.ok(mail.html.includes('Campus Innovation Marne-la-Vallée'));assert.ok(!mail.html.includes('mbn-global.png'));}
 const evry=renderMessage({school_code:'EVRY BTS',subject:'Synthetic',body:'Synthetic'});assert.ok(evry.html.includes('/evry-bts.png'));assert.ok(!evry.html.includes('campus-innovation-mlv.png'));
});

 test('French sender names use bounded RFC 2047 words and preserve their exact Unicode identity',()=>{
 const input='Campus Innovation Marne-la-Vallée',address=senderAddress({...sender,from_name:input});
 const encoded=address.split(' <')[0];assert.ok(encoded.startsWith('=?UTF-8?B?'));
 assert.equal(encoded.split(' ').map(v=>Buffer.from(v.slice(10,-2),'base64').toString('utf8')).join(''),input);
 for(const word of encoded.split(' '))assert.ok(word.length<=75);
 assert.ok(!senderAddress({...sender,from_name:'Name\r\nBcc: example.invalid'}).includes('\r\n'));
 });
