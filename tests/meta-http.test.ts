import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createHmac} from 'node:crypto';
import {createHandler,webhookEvents} from '../supabase/functions/mbn-meta/handler.ts';
import {createMeta,MetaError} from '../supabase/functions/mbn-meta/graph.ts';
const actor={id:'20000000-0000-4000-8000-000000000001',session_id:'30000000-0000-4000-8000-000000000001'};
const secret='synthetic-meta-app-secret-'.repeat(2),verify='synthetic-verify-token-'.repeat(2),worker='synthetic-worker-secret-'.repeat(6);
const page='111110000001',form='222220000001',lead='333330000001',pageToken='synthetic-page-token-'.repeat(3);
const body=()=>({object:'page',entry:[{id:page,changes:[{field:'leadgen',value:{page_id:page,form_id:form,leadgen_id:lead}}]}]});
const rawLead=(patch={})=>({id:lead,form_id:form,created_time:'2026-10-19T12:00:00+0000',field_data:[{name:'full_name',values:['Candidat synthétique']},{name:'email',values:['synthetic@example.invalid']}],...patch});
function request(value:any=body(),signature=true){const raw=typeof value==='string'?value:JSON.stringify(value);return new Request('https://example.invalid',{method:'POST',headers:{'content-type':'application/json',...(signature?{'x-hub-signature-256':'sha256='+createHmac('sha256',secret).update(raw).digest('hex')}:{})},body:raw});}
function api(overrides:any={}){
 const calls:any[]=[];let reads=0;
 const deps={appSecret:secret,verifyToken:verify,authenticate:async()=>actor,rpc:async(name:string,args:any)=>{calls.push({name,args});return {data:name==='mbn_runtime_key'?worker:name==='mbn_meta_admin_action'?{routes:[],events:[],counts:{}}:null,error:null};},
  graph:{configured:true,hasToken:()=>true,status:()=>({app_secret_configured:true,graph_version_configured:true}),read:async()=>{reads++;return {id:lead,form_id:form,created_time:'2026-10-19T12:00:00Z',fields:{email:['synthetic@example.invalid']}};}},...overrides};
 return {handler:createHandler(deps),calls,reads:()=>reads};
}
const adminRequest=(action:string,data={})=>new Request('https://example.invalid',{method:'POST',headers:{authorization:'Bearer '+('t'.repeat(30)),'content-type':'application/json'},body:JSON.stringify({action,data})});
test('Meta verification echoes only an authenticated bounded challenge and never reads personal data',async()=>{
 const {handler,calls}=api();const url=new URL('https://example.invalid');url.search=new URLSearchParams({'hub.mode':'subscribe','hub.verify_token':verify,'hub.challenge':'123456'}).toString();
 const response=await handler(new Request(url));assert.equal(response.status,200);assert.equal(await response.text(),'123456');assert.equal(response.headers.get('cache-control'),'no-store');assert.equal(calls.length,0);
 url.searchParams.set('hub.verify_token','forged');assert.equal((await handler(new Request(url))).status,403);
 assert.equal((await api({verifyToken:undefined}).handler(new Request(url))).status,503);
});
test('unsigned and altered Meta payloads are rejected before a database write or Graph read',async()=>{
 const {handler,calls,reads}=api();assert.equal((await handler(request('malformed',false))).status,403);
 const valid=request();const altered=new Request('https://example.invalid',{method:'POST',headers:valid.headers,body:JSON.stringify(body())+' '});assert.equal((await handler(altered)).status,403);
 assert.equal(calls.length,0);assert.equal(reads(),0);
});
test('a verified Meta webhook persists bounded identifiers without fetching a candidate in the callback',async()=>{
 const {handler,calls,reads}=api();const response=await handler(request());assert.equal(response.status,200);assert.equal(await response.text(),'EVENT_RECEIVED');
 assert.equal(calls.length,1);assert.equal(calls[0].name,'mbn_meta_receive');assert.deepEqual(calls[0].args.p_events,[{page_id:page,form_id:form,leadgen_id:lead}]);assert.equal(reads(),0);
});
test('invalid page identities and oversized Meta bodies cannot enter the inbox',async()=>{
 const {handler,calls}=api();const invalid=body();invalid.entry[0].changes[0].value.page_id='111110000002';assert.equal((await handler(request(invalid))).status,400);
 assert.equal((await handler(request('x'.repeat(262145)))).status,400);assert.equal(calls.length,0);
 assert.deepEqual(webhookEvents({object:'instagram'}),[]);assert.deepEqual(webhookEvents({object:'page',entry:[{id:page,changes:[{field:'feed'}]}]}),[]);
});
test('Meta admin actions require a live session and owner permission before any external retrieval',async()=>{
 assert.equal((await api({authenticate:async()=>null}).handler(new Request('https://example.invalid',{method:'POST',headers:{authorization:'Bearer '+('t'.repeat(30))},body:'malformed'}))).status,401);
 let reads=0;const {handler,calls}=api({rpc:async(name:string,args:any)=>{calls.push({name,args});return {data:null,error:{code:'PT403',message:'access_denied'}};},graph:{configured:true,read:async()=>{reads++;}}});
 const denied=await handler(adminRequest('meta_process'));assert.equal(denied.status,403);assert.equal(reads,0);assert.equal(calls[0].args.p_actor,actor.id);
});
test('Meta connection status contains readiness flags and no access tokens or app secrets',async()=>{
 const {handler}=api({rpc:async()=>({data:{routes:[{page_id:page}],events:[],counts:{}},error:null})});
 const response=await handler(adminRequest('meta_context')),data=await response.json();assert.equal(data.routes[0].page_token_configured,true);assert.equal(data.credentials.verify_token_configured,true);
 assert.ok(!JSON.stringify(data).includes(pageToken));assert.ok(!JSON.stringify(data).includes(secret));assert.ok(!JSON.stringify(data).includes(verify));
});
test('an invalid Meta worker secret cannot claim a job; missing configuration also leaves the queue untouched',async()=>{
 const first=api();const bad=new Request('https://example.invalid',{method:'POST',headers:{'x-mbn-worker':'x'.repeat(100)},body:'{}'});assert.equal((await first.handler(bad)).status,401);assert.ok(!first.calls.some(c=>c.name==='mbn_meta_claim'));
 const second=api({graph:{configured:false}});const good=new Request('https://example.invalid',{method:'POST',headers:{'x-mbn-worker':worker},body:'{}'});assert.equal((await second.handler(good)).status,422);assert.ok(!second.calls.some(c=>c.name==='mbn_meta_claim'));
});
test('the Meta worker records a retrieved lead once and returns no applicant data to its caller',async()=>{
 let count=0;const calls:any[]=[];
 const {handler}=api({rpc:async(name:string,args:any)=>{calls.push({name,args});return {data:name==='mbn_runtime_key'?worker:name==='mbn_meta_claim'?count++===0?{id:'synthetic',page_id:page,form_id:form,leadgen_id:lead,attempt_id:'attempt',route_revision:'revision'}:null:{status:'IMPORTED'},error:null};}});
 const response=await handler(new Request('https://example.invalid',{method:'POST',headers:{'x-mbn-worker':worker},body:'{}'}));assert.equal(response.status,200);const result=await response.json();assert.equal(result.processed,1);assert.equal(result.outcomes[0].status,'IMPORTED');assert.ok(!JSON.stringify(result).includes('synthetic@example.invalid'));
 const finish=calls.find(c=>c.name==='mbn_meta_finish');assert.equal(finish.args.p_lead.id,lead);assert.equal(finish.args.p_revision,'revision');
});
test('Meta provider error text never enters stored diagnostics',async()=>{
 let count=0;const calls:any[]=[];
 const {handler}=api({rpc:async(name:string,args:any)=>{calls.push({name,args});return {data:name==='mbn_runtime_key'?worker:name==='mbn_meta_claim'?count++===0?{id:'synthetic',page_id:page,form_id:form,leadgen_id:lead,attempt_id:'attempt',route_revision:'revision'}:null:{status:'RETRY'},error:null};},graph:{configured:true,read:async()=>{throw Error('Private provider token '+pageToken);}}});
 await handler(new Request('https://example.invalid',{method:'POST',headers:{'x-mbn-worker':worker},body:'{}'}));const finish=calls.find(c=>c.name==='mbn_meta_finish');assert.equal(finish.args.p_error,'meta_processing_failed');assert.equal(finish.args.p_retryable,true);assert.ok(!JSON.stringify(finish).includes(pageToken));
});
test('Graph retrieval uses one fixed origin, a bearer token and an independent appsecret proof',async()=>{
 let calls=0;const graph=createMeta({appSecret:secret,version:'v25.0',pageTokens:JSON.stringify({[page]:pageToken})},async(input,init)=>{
  calls++;const url=new URL(String(input));assert.equal(url.origin,'https://graph.facebook.com');assert.equal(url.pathname,'/v25.0/'+lead);assert.equal(url.searchParams.get('access_token'),null);assert.equal(new Headers(init?.headers).get('Authorization'),'Bearer '+pageToken);assert.equal(init?.redirect,'error');assert.equal(url.searchParams.get('appsecret_proof'),createHmac('sha256',secret).update(pageToken).digest('hex'));
  return new Response(JSON.stringify(rawLead()));
 });
 const result=await graph.read(page,lead,form);assert.equal(result.fields.email[0],'synthetic@example.invalid');assert.equal(calls,1);
 await assert.rejects(graph.read(page,'https://evil.invalid',form),{code:'invalid_meta_event'});assert.equal(calls,1);
 assert.equal(createMeta({appSecret:secret,pageTokens:'malformed'}).configured,false);
});
test('Graph errors distinguish retryable limits from access failures and conceal provider text',async()=>{
 for(const [status,errorCode,expected,retry] of [[429,4,'meta_temporarily_unavailable',true],[500,2,'meta_temporarily_unavailable',true],[401,190,'meta_token_rejected',false],[403,200,'meta_permission_denied',false],[400,100,'meta_lead_unavailable',false]] as const){
  const graph=createMeta({appSecret:secret,version:'v25.0',pageTokens:JSON.stringify({[page]:pageToken})},async()=>new Response(JSON.stringify({error:{code:errorCode,message:'private '+pageToken}}),{status}));
  await assert.rejects(graph.read(page,lead,form),(e:any)=>e instanceof MetaError&&e.code===expected&&e.retryable===retry&&!e.message.includes(pageToken));
 }
 const missing=createMeta({appSecret:secret,version:'v25.0',pageTokens:'{}'},async()=>{throw Error('must not fetch');});await assert.rejects(missing.read(page,lead,form),{code:'meta_page_token_missing'});
});
test('Graph responses must match the notified lead and form and cannot contain ambiguous field names',async()=>{
 for(const patch of [{id:'333330000002'},{form_id:'222220000002'},{field_data:[{name:'email',values:['a@example.invalid']},{name:'email',values:['b@example.invalid']}]}]){
  const graph=createMeta({appSecret:secret,version:'v25.0',pageTokens:JSON.stringify({[page]:pageToken})},async()=>new Response(JSON.stringify(rawLead(patch))));await assert.rejects(graph.read(page,lead,form));
 }
 const graph=createMeta({appSecret:secret,version:'v25.0',pageTokens:JSON.stringify({[page]:pageToken})},async()=>new Response(JSON.stringify(rawLead({field_data:[{name:'__proto__',values:['synthetic']}]}))));
 const result=await graph.read(page,lead,form);assert.equal(Object.getPrototypeOf(result.fields),null);assert.deepEqual(result.fields.__proto__,['synthetic']);
});
