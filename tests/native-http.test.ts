import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createHandler,digest,MAX_FILE_BYTES,type Dependencies,type NativeFile} from '../supabase/functions/mbn-form-ingest/handler.ts';
const actor='20000000-0000-4000-8000-000000000001';
const submission='30000000-0000-4000-8000-000000000001';
const application='40000000-0000-4000-8000-000000000001';
const reference='MBNTEST-50000000-0000-4000-8000-000000000001';
const program='10000000-0000-4000-8000-000000000001';
const base={reference_dossier:reference,email:'native@example.invalid',full_name:'Test Synthétique',school_code:'MLV BTS',campus_code:'NOISIEL',country_of_residence:'France',program_id:program,program_name:'QA BTS',details:{}};
const pdf=new TextEncoder().encode('%PDF-1.4\n% test only\n%%EOF');
const token='Bearer '+ 'x'.repeat(40);
function harness(overrides:Partial<Dependencies>={}) {
  const calls:{name:string;args:Record<string,unknown>}[]=[], uploads:{path:string;file:NativeFile}[]=[];
  const dependencies:Dependencies={
    authenticate:async()=>actor,
    rpc:async(name,args)=>{
      calls.push({name,args});
      return {error:null,data:name==='mbn_prepare_native_test'
        ? {submission_id:submission,reference,completed:false}
        : {success:true,test:true,reference,application_id:application,duplicated:false,document_count:1}};
    },
    upload:async(path,file)=>{uploads.push({path,file});},download:async()=>pdf,...overrides,
  };
  return {handler:createHandler(dependencies),calls,uploads};
}
function request(payload:unknown=base,files:{kind?:string;bytes?:Uint8Array;type?:string;name?:string}[]=[{}]) {
  const form=new FormData();form.append('payload',JSON.stringify(payload));
  for(const file of files)form.append(file.kind??'CV',new Blob([new Uint8Array(file.bytes??pdf)],{type:file.type??'application/pdf'}),file.name??'cv.pdf');
  return new Request('https://test.invalid/ingest',{method:'POST',headers:{Authorization:token},body:form});
}
test('CORS preflight is usable without credentials',async()=>{
  const {handler,calls}=harness();const response=await handler(new Request('https://test.invalid',{method:'OPTIONS'}));
  assert.equal(response.status,204);assert.equal(calls.length,0);
});
test('anonymous callers cannot parse or store candidate data',async()=>{
  const {handler,calls,uploads}=harness();const req=request();req.headers.delete('authorization');
  assert.equal((await handler(req)).status,401);assert.equal(calls.length,0);assert.equal(uploads.length,0);
});
test('signed-in non-administrators are denied before body parsing',async()=>{
  const {handler,calls}=harness({authenticate:async()=>null});assert.equal((await handler(request())).status,403);assert.equal(calls.length,0);
});
test('a verified admin can submit a multipart form with a private document',async()=>{
  const {handler,calls,uploads}=harness();const response=await handler(request());
  assert.equal(response.status,201);assert.deepEqual(calls.map(c=>c.name),['mbn_prepare_native_test','mbn_complete_native_test']);
  assert.equal(uploads[0].path,submission+'/CV.pdf');
  assert.equal(uploads[0].file.manifest.sha256,await digest(pdf));
  assert.equal(calls[0].args.p_actor,actor);
});
test('a lost response can be acknowledged without uploading documents again',async()=>{
  const {handler,uploads}=harness({rpc:async name=>({error:null,data:name==='mbn_prepare_native_test'
    ? {submission_id:submission,reference,completed:true}
    : {success:true,test:true,reference,application_id:application,duplicated:true,document_count:1}})});
  assert.equal((await handler(request())).status,200);assert.equal(uploads.length,0);
});
test('upload failure leaves a resumable reservation and never finalizes',async()=>{
  const {handler,calls}=harness({upload:async()=>{throw Error('connection interrupted');}});
  assert.equal((await handler(request())).status,503);assert.equal(calls.length,1);
});
test('an uncertain final commit returns a retryable error without deleting uploads',async()=>{
  const {handler,uploads}=harness({rpc:async name=>{if(name==='mbn_complete_native_test')throw Error('lost response');return {error:null,data:{submission_id:submission,reference,completed:false}};}});
  const response=await handler(request());assert.equal(response.status,503);assert.equal((await response.json()).retryable,true);assert.equal(uploads.length,1);
});
test('unknown fields cannot enable production mode or spoof a decision',async()=>{
  const {handler,calls}=harness();assert.equal((await handler(request({...base,_native_test:false,status:'ACCEPTED'}))).status,400);assert.equal(calls.length,0);
});
test('document MIME spoofing and filename extension mismatches are rejected',async()=>{
  const {handler,calls}=harness();
  assert.equal((await handler(request(base,[{bytes:new TextEncoder().encode('<script>bad</script>')}]))).status,415);
  assert.equal((await handler(request(base,[{name:'cv.html'}]))).status,415);assert.equal(calls.length,0);
});
test('duplicate document kinds and unsupported document kinds are refused',async()=>{
  const {handler,calls}=harness();assert.equal((await handler(request(base,[{},{}]))).status,400);
  assert.equal((await handler(request(base,[{kind:'LETTER_APPROVED'}]))).status,400);assert.equal(calls.length,0);
});
test('oversized documents and streamed bodies are rejected before reservation',async()=>{
  const {handler,calls}=harness();const bytes=new Uint8Array(MAX_FILE_BYTES+1);bytes.set(pdf);
  assert.equal((await handler(request(base,[{bytes}]))).status,413);
  const req=request();req.headers.set('content-length',String(30*1024*1024));assert.equal((await handler(req)).status,413);assert.equal(calls.length,0);
  let canceled=false;
  const stream=new ReadableStream({pull(controller){controller.enqueue(new Uint8Array(1024*1024));},cancel(){canceled=true;}});
  const streamed=new Request('https://test.invalid',{method:'POST',headers:{Authorization:token,'Content-Type':'multipart/form-data; boundary=unused'},body:stream,duplex:'half'} as RequestInit&{duplex:string});
  assert.equal((await handler(streamed)).status,413);assert.equal(canceled,true);assert.equal(calls.length,0);
});
test('invalid country, program id and impossible birth dates are refused',async()=>{
  const {handler,calls}=harness();
  for(const payload of [{...base,country_of_residence:''},{...base,program_id:'bad'},{...base,details:{date_naissance:'2001-02-30'}}])assert.equal((await handler(request(payload))).status,400);
  assert.equal(calls.length,0);
});
test('strict boolean consent is preserved separately from administrative processing',async()=>{
  const {handler,calls}=harness();await handler(request({...base,consent_email:'true'}));
  assert.equal((calls[0].args.p_payload as Record<string,unknown>).consent_email,false);
});
test('expected database conflicts stay explicit and internal failures stay generic',async()=>{
  const a=harness({rpc:async()=>({data:null,error:{code:'PT409',message:'reference_conflict'}})});
  assert.equal((await a.handler(request())).status,409);
  const b=harness({rpc:async()=>({data:null,error:{code:'XX000',message:'secret candidate data'}})});
  const response=await b.handler(request());assert.equal(response.status,503);assert.ok(!(await response.text()).includes('candidate'));
});
test('a download requires authorization and a database document identifier',async()=>{
  const {handler}=harness({rpc:async()=>({error:null,data:{bucket:'mbn-native-test',object_path:submission+'/CV.pdf',original_name:'cv.pdf',sha256:await digest(pdf)}})});
  const response=await handler(new Request('https://test.invalid',{method:'POST',headers:{Authorization:token,'Content-Type':'application/json'},body:JSON.stringify({action:'download',document_id:application})}));
  assert.equal(response.status,200);assert.match(response.headers.get('content-disposition')!,/attachment/);assert.deepEqual(new Uint8Array(await response.arrayBuffer()),pdf);
});
test('arbitrary download paths cannot be submitted by the client',async()=>{
  const {handler,calls}=harness();const response=await handler(new Request('https://test.invalid',{method:'POST',headers:{Authorization:token,'Content-Type':'application/json'},body:JSON.stringify({action:'download',document_id:application,path:'another/file.pdf'})}));
  assert.equal(response.status,400);assert.equal(calls.length,0);
});
test('a corrupted stored file is never returned as the accepted document',async()=>{
  const {handler}=harness({rpc:async()=>({error:null,data:{bucket:'mbn-native-test',object_path:submission+'/CV.pdf',original_name:'cv.pdf',sha256:'0'.repeat(64)}})});
  const response=await handler(new Request('https://test.invalid',{method:'POST',headers:{Authorization:token,'Content-Type':'application/json'},body:JSON.stringify({action:'download',document_id:application})}));
  assert.equal(response.status,503);
});
