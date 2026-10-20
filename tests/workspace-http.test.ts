import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createHmac,createHash} from 'node:crypto';
import {createHandler,capability,verifyCapability,renderMessage} from '../supabase/functions/mbn-workspace/handler.ts';
import {createSES,signRequest} from '../supabase/functions/mbn-workspace/ses.ts';
import {createHandler as admissions} from '../supabase/functions/mbn-admissions/handler.ts';
import {createHandler as events,certificateURL,snsCanonical} from '../supabase/functions/mbn-mail-events/handler.ts';
import {parseCSV,escapeHTML} from '../assets/workspace-ui.js';
const actor={id:'20000000-0000-4000-8000-000000000001',session_id:'30000000-0000-4000-8000-000000000001'};
const id='40000000-0000-4000-8000-000000000001',attempt='50000000-0000-4000-8000-000000000001',secret='synthetic-test-secret-'.repeat(6),auth='Bearer '+('t'.repeat(30));
const sender={from_name:'Synthetic',from_email:'sender@example.invalid',reply_to:'',identity:'example.invalid',region:'eu-west-3',configuration_set:'synthetic'};
function api({authorized=true,reply=(name:string,args:any)=>name==='mbn_workspace_action'?{admin:true}:null,transport=createSES(undefined)}={}){
 const calls:{name:string;args:any}[]=[];
 const handler=createHandler({authenticate:async()=>authorized?actor:null,rpc:async(name,args)=>{calls.push({name,args});return {data:reply(name,args),error:null};},transport,download:async()=>new Uint8Array(),sleep:async()=>{}});
 return {handler,calls};
}
const req=(action:string,data={},extra={})=>new Request('https://example.invalid',{method:'POST',headers:{authorization:auth,'content-type':'application/json'},body:JSON.stringify({action,data,...extra})});
test('workspace authenticates before reading JSON and ignores spoofed actor identities',async()=>{
 const denied=api({authorized:false});assert.equal((await denied.handler(new Request('https://example.invalid',{method:'POST',headers:{authorization:auth},body:'invalid json'}))).status,401);assert.equal(denied.calls.length,0);
 const allowed=api();assert.equal((await allowed.handler(req('bootstrap'))).status,200);assert.equal(allowed.calls[0].args.p_actor,actor.id);assert.equal(allowed.calls[0].args.p_session,actor.session_id);
 assert.equal((await allowed.handler(req('bootstrap',{}, {p_actor:'spoof'}))).status,400);
});
test('routing administration uses the authenticated server actor and never calls the mail provider',async()=>{
 const calls:any[]=[];let external=0;
 const handler=createHandler({authenticate:async()=>actor,rpc:async(name,args)=>{calls.push({name,args});return {data:null,error:{code:'PT403',message:'access_denied'}};},transport:{configured:true,inspect:async()=>{external++;throw Error('unexpected');},send:async()=>{external++;throw Error('unexpected');}},download:async()=>new Uint8Array(),sleep:async()=>{}});
 for(const action of ['routing_context','routing_save','routing_toggle','routing_reassign_preview','routing_reassign_apply']){
  const response=await handler(req(action));assert.equal(response.status,403);
  assert.equal(calls.at(-1).name,'mbn_routing_action');assert.equal(calls.at(-1).args.p_actor,actor.id);assert.equal(calls.at(-1).args.p_session,actor.session_id);
 }
 assert.equal(external,0);
});
test('missing SES credentials are explicit; a test is not queued or marked sent',async()=>{
 const {handler,calls}=api({reply:(name)=>name==='mbn_workspace_action'||name==='mbn_mail_profile_settings'||name==='mbn_mail_profile_checked'?sender:null});
 const response=await handler(req('test_send'));assert.equal(response.status,422);assert.equal((await response.json()).error,'aws_credentials_missing');
 assert.ok(!calls.some(c=>c.args.p_action==='test_prepare'||c.name==='mbn_mail_claim'));
});
test('an unauthorized read-only member cannot mint a candidate capability',async()=>{
 const {handler,calls}=api({reply:()=>({lead:{is_test:false},can_manage:false})});assert.equal((await handler(req('link_create',{id}))).status,403);assert.ok(!calls.some(c=>c.name==='mbn_runtime_key'));
});
test('signature canonicalization and HMAC chain agree with an independent Node implementation',async()=>{
 const credentials={accessKeyId:'AKIDEXAMPLE',secretAccessKey:'wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY'},body='{"Content":"synthetic"}';
 const signed=await signRequest(credentials,'eu-west-3','POST','/v2/email/outbound-emails',body,new Date('2026-10-19T10:20:30.000Z'));
 const canonical='POST\n/v2/email/outbound-emails\n\ncontent-type:application/json\nhost:email.eu-west-3.amazonaws.com\nx-amz-date:20261019T102030Z\n\ncontent-type;host;x-amz-date\n'+createHash('sha256').update(body).digest('hex');
 assert.equal(signed.canonical,canonical);
 let key=Buffer.from('AWS4'+credentials.secretAccessKey);for(const part of ['20261019','eu-west-3','ses','aws4_request'])key=createHmac('sha256',key).update(part).digest();
 const expected=createHmac('sha256',key).update('AWS4-HMAC-SHA256\n20261019T102030Z\n20261019/eu-west-3/ses/aws4_request\n'+createHash('sha256').update(canonical).digest('hex')).digest('hex');
 assert.ok(signed.headers.authorization.endsWith('Signature='+expected));assert.equal(signed.body,body);assert.ok(!('host' in signed.headers));
});
test('SES timeout/5xx remain uncertain; 400 fails; 200 is accepted but never delivered',async()=>{
 const credentials={accessKeyId:'synthetic',secretAccessKey:'synthetic'},message={id,recipient:'synthetic@example.invalid',subject:'Synthetic',text:'Synthetic',html:'<p>Synthetic</p>'};
 for(const [status,body,outcome] of [[200,{MessageId:'provider'},'ACCEPTED'],[400,{},'FAILED'],[503,{},'UNCERTAIN'],[200,{},'UNCERTAIN']] as const){let count=0;const ses=createSES(credentials,async()=>{count++;return new Response(JSON.stringify(body),{status});});assert.equal((await ses.send(sender,message)).status,outcome);assert.equal(count,1);}
 assert.equal((await createSES(credentials,async()=>{throw Error('timeout');}).send(sender,message)).status,'UNCERTAIN');
});
test('capabilities are purpose-bound, reject tampering, and contain no candidate identity',async()=>{
 const token=await capability(secret,id,'admission');assert.equal(await verifyCapability(secret,token,'admission'),id);
 await assert.rejects(verifyCapability(secret,token,'unsubscribe'));await assert.rejects(verifyCapability(secret,token.slice(0,-1)+(token.endsWith('a')?'b':'a'),'admission'));
 assert.ok(!token.includes('@'));
});
test('mail rendering escapes candidate/template content and supplies a separate unsubscribe URL',()=>{
 const rendered=renderMessage({subject:'Bonjour {{prenom}}',body:'<script>alert(1)</script> {{nom}}',school_code:'MLV BTS',lead:{full_name:'<img onerror=alert(1)>'}},'https://mbn-global.netlify.app/apply.html#safe','https://mbn-global.netlify.app/preferences.html#safe');
 assert.ok(!rendered.html.includes('<script>'));assert.ok(!rendered.html.includes('<img onerror'));assert.ok(rendered.html.includes('&lt;script&gt;'));assert.ok(rendered.text.includes('Me désinscrire'));
});
test('public intake rejects an invalid capability before reading any multipart files',async()=>{
 let uploads=0,context=0;const handler=admissions({rpc:async(name)=>{if(name!=='mbn_runtime_key')context++;return {data:secret,error:null};},upload:async()=>{uploads++;}});
 const response=await handler(new Request('https://example.invalid',{method:'POST',headers:{'content-type':'multipart/form-data','x-mbn-admission':'forged'},body:'malformed'}));assert.equal(response.status,404);assert.equal(uploads,0);assert.equal(context,0);
});
test('public info returns school context without returning recipient email or lead id',async()=>{
 const token=await capability(secret,id,'admission');const handler=admissions({rpc:async name=>({data:name==='mbn_runtime_key'?secret:{school_code:'MLV BTS',school_name:'MLV BTS',slug:'mlv-bts',email:'private@example.invalid',lead_id:actor.id,submitted:false},error:null}),upload:async()=>{}});
 const response=await handler(new Request('https://example.invalid',{method:'POST',body:JSON.stringify({action:'info',token})}));const text=await response.text();assert.equal(response.status,200);assert.ok(!text.includes('private@example'));assert.ok(!text.includes('lead_id'));
});
test('SNS certificates and confirmation origins reject SSRF and canonical text preserves decoded newlines',()=>{
 for(const url of ['http://sns.eu-west-3.amazonaws.com/SimpleNotificationService-x.pem','https://evil.example/SimpleNotificationService-x.pem','https://sns.eu-west-3.amazonaws.com.evil.example/SimpleNotificationService-x.pem','https://sns.eu-west-3.amazonaws.com@evil.example/SimpleNotificationService-x.pem','https://sns.eu-west-3.amazonaws.com/SimpleNotificationService-x.pem?redirect=x'])assert.throws(()=>certificateURL(url,'eu-west-3'));
 const e={Type:'Notification',Message:'line1\nline2',MessageId:'id',Timestamp:'time',TopicArn:'arn',Subject:'subject'};
 assert.equal(snsCanonical(e),'Message\nline1\nline2\nMessageId\nid\nSubject\nsubject\nTimestamp\ntime\nTopicArn\narn\nType\nNotification\n');
});
test('an unsigned or wrong-topic SNS notification cannot update delivery or suppression',async()=>{
 let writes=0;const handler=events({rpc:async name=>{if(name==='mbn_mail_event')writes++;return {data:{...sender,sns_topic_arn:'arn:aws:sns:eu-west-3:123456789012:expected'},error:null};},verify:async()=>false,confirm:async()=>{throw Error('must not confirm');}});
 const envelope={Type:'Notification',TopicArn:'arn:aws:sns:eu-west-3:123456789012:unexpected',SignatureVersion:'2',Signature:'fake',MessageId:'envelope',Message:'{}',Timestamp:new Date().toISOString(),SigningCertURL:'https://sns.eu-west-3.amazonaws.com/SimpleNotificationService-x.pem'};
 assert.equal((await handler(new Request('https://example.invalid',{method:'POST',body:JSON.stringify(envelope)}))).status,403);assert.equal(writes,0);
});
test('CSV supports BOM, quoted delimiters/newlines, explicit consent and rejects malformed rows',()=>{
 const rows=parseCSV('\uFEFFfull_name;email;consent_email;consent_source\r\n"Jean; Test";synthetic@example.invalid;oui;"Formulaire\naccepté"\r\n');assert.equal(rows[0].full_name,'Jean; Test');assert.equal(rows[0].consent_email,true);assert.equal(rows[0].consent_source,'Formulaire\naccepté');
 assert.throws(()=>parseCSV('full_name,email\n"unfinished,mail'));assert.throws(()=>parseCSV('full_name,email\na,b,c'));assert.throws(()=>parseCSV('full_name,full_name,email\na,b,c'));
 assert.equal(escapeHTML('<img onerror="x">'),'&lt;img onerror=&quot;x&quot;&gt;');
});
