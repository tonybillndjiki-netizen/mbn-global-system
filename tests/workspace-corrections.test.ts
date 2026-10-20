import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createHandler as admissions} from '../supabase/functions/mbn-admissions/handler.ts';
import {createHandler as workspace,capability,verifyCapability} from '../supabase/functions/mbn-workspace/handler.ts';
import {createBrevo} from '../supabase/functions/mbn-workspace/brevo.ts';
const id='40000000-0000-4000-8000-000000000001',submission='40000000-0000-4000-8000-000000000002',attempt='50000000-0000-4000-8000-000000000001';
const actor={id:'20000000-0000-4000-8000-000000000001',session_id:'30000000-0000-4000-8000-000000000001'},secret='synthetic-correction-key-'.repeat(6);
const profile={code:'ADMISSIONS_COMMUN',revision:id,from_name:'Internal group name',from_email:'no-reply@commun.example.invalid',reply_to:'',identity:'',region:'',configuration_set:''};
const requestJSON=(action:string,data:object={})=>new Request('https://example.invalid',{method:'POST',headers:{authorization:'Bearer '+'t'.repeat(30),'Content-Type':'application/json'},body:JSON.stringify({action,data})});
async function correctionUpload(token:string,content='%PDF-1.4 synthetic updated CV',type='application/pdf'){
 const body=new FormData();body.append('payload','{}');body.append('CV',new Blob([content],{type}),'updated.pdf');
 return new Request('https://example.invalid',{method:'POST',headers:{'x-mbn-correction':token},body});
}
test('correction capabilities are separate from admission and unsubscribe and checked before files',async()=>{
 const token=await capability(secret,id,'correction');assert.equal(await verifyCapability(secret,token,'correction'),id);
 await assert.rejects(verifyCapability(secret,token,'admission'));await assert.rejects(verifyCapability(secret,token,'unsubscribe'));
 let uploads=0,contexts=0;const handler=admissions({rpc:async(name)=>{if(name==='mbn_runtime_key')return {data:secret,error:null};contexts++;return {data:{},error:null};},upload:async()=>{uploads++;}});
 const forged=await capability(secret,id,'admission');
 assert.equal((await handler(await correctionUpload(forged,'not a valid file'))).status,404);assert.equal(uploads,0);assert.equal(contexts,0);
});
test('a correction upload validates the actual file before reserving and commits a resumable receipt',async()=>{
 const token=await capability(secret,id,'correction'),calls:any[]=[],uploaded:any[]=[];
 const handler=admissions({rpc:async(name,args)=>{calls.push({name,args});return {data:name==='mbn_runtime_key'?secret:name==='mbn_correction_info'?{}:name==='mbn_correction_prepare'?{submission_id:submission,completed:false}:{success:true,duplicated:false,document_count:1},error:null};},upload:async(path,file)=>{uploaded.push({path,file});}});
 const bad=await handler(await correctionUpload(token,'<script>bad</script>'));assert.equal(bad.status,415);assert.equal(uploaded.length,0);assert.ok(!calls.some(c=>c.name==='mbn_correction_prepare'));
 const response=await handler(await correctionUpload(token));assert.equal(response.status,201);assert.equal((await response.json()).success,true);
 assert.equal(uploaded[0].path,submission+'/CV.pdf');assert.equal(uploaded[0].file.manifest.kind,'CV');
 const prepare=calls.find(c=>c.name==='mbn_correction_prepare');assert.equal(prepare.args.p_request,id);assert.match(prepare.args.p_fingerprint,/^[a-f0-9]{64}$/);
});
test('an expired correction link and a rejected manifest stop before any upload',async()=>{
 const token=await capability(secret,id,'correction');
 for(const errorAt of ['mbn_correction_info','mbn_correction_prepare']){
  let uploads=0;const handler=admissions({rpc:async(name)=>({data:name==='mbn_runtime_key'?secret:{},error:name===errorAt?{code:errorAt==='mbn_correction_info'?'PT404':'PT422',message:errorAt==='mbn_correction_info'?'link_unavailable':'requested_documents_only'}:null}),upload:async()=>{uploads++;}});
  assert.equal((await handler(await correctionUpload(token))).status,errorAt==='mbn_correction_info'?404:422);assert.equal(uploads,0);
 }
});
test('a completed correction replay acknowledges receipt without uploading again',async()=>{
 const token=await capability(secret,id,'correction');let uploads=0;
 const handler=admissions({rpc:async(name)=>({data:name==='mbn_runtime_key'?secret:name==='mbn_correction_prepare'?{submission_id:submission,completed:true}:name==='mbn_correction_complete'?{success:true,duplicated:true,document_count:1}:{},error:null}),upload:async()=>{uploads++;}});
 const response=await handler(await correctionUpload(token));assert.equal(response.status,200);assert.equal((await response.json()).duplicated,true);assert.equal(uploads,0);
});
test('request send checks review access and missing Brevo credentials before a send lease',async()=>{
 for(const denied of [true,false]){
  const calls:any[]=[];const handler=workspace({authenticate:async()=>actor,rpc:async(name,args)=>{calls.push({name,args});return {data:name==='mbn_document_requests_action'?{school_code:'ESETH'}:profile,error:denied?{code:'PT404',message:'record_not_found'}:null};},transport:createBrevo(undefined),download:async()=>new Uint8Array(),sleep:async()=>{}});
  const response=await handler(requestJSON('document_request_send',{id,application_id:id}));assert.equal(response.status,denied?404:422);
  assert.ok(!calls.some(c=>c.args.p_action==='claim'));
 }
});
test('request email renders the signed upload link, school name, contact and delivery result',async()=>{
 let sent=0,finished:any;const handler=workspace({authenticate:async()=>actor,rpc:async(name,args)=>{
  if(name==='mbn_runtime_key')return {data:secret,error:null};
  if(name==='mbn_mail_profile_settings'||name==='mbn_mail_profile_checked')return {data:profile,error:null};
  if(name==='mbn_mail_finish'){finished=args;return {data:true,error:null};}
  if(name==='mbn_document_requests_action')return {data:args.p_action==='context'?{school_code:'ESETH'}:args.p_action==='authorized'?true:{request:{id,expires_at:'2099-01-01',items:[{kind:'CV',reason:'Lisible <script>test</script>'}]},reference:'SYNTHETIC',sender:profile,message:{id,attempt_id:attempt,school_code:'ESETH',recipient:'candidate@example.invalid',service_contact_email:'eseth-service@example.invalid'}},error:null};
  throw Error('Unexpected RPC '+name);
 },transport:{configured:true,inspect:async()=>({sender_verified:true,production_access:true,account_sending_enabled:true,remaining:10,rate:1}),send:async(s,m)=>{
  sent++;assert.equal(s.from_name,'Service admissions - ESETH');assert.equal(s.from_email,profile.from_email);assert.equal(s.reply_to,profile.from_email);
  assert.ok(m.html.includes('Déposer les pièces demandées'));assert.ok(m.html.includes('eseth-service@example.invalid'));assert.ok(!m.html.includes('<script>'));assert.ok(!m.html.includes('Me désinscrire'));
  const token=m.text.match(/documents\.html#([^\s]+)/)![1];assert.equal(await verifyCapability(secret,token,'correction'),id);
  return {status:'ACCEPTED',provider_id:'<correction-test>'};
 }},download:async()=>new Uint8Array(),sleep:async()=>{}});
 const response=await handler(requestJSON('document_request_send',{id,application_id:id}));assert.equal(response.status,200);assert.equal((await response.json()).status,'ACCEPTED');assert.equal(sent,1);assert.equal(finished.p_provider_id,'<correction-test>');
});
