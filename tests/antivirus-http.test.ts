import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {createScanner} from '../supabase/functions/mbn-antivirus/scanner.ts';
import {createHandler,type Dependencies} from '../supabase/functions/mbn-antivirus/handler.ts';
const bytes=new TextEncoder().encode('%PDF-1.4 synthetic'),sha=createHash('sha256').update(bytes).digest('hex');
const token='t'.repeat(90),url='https://scanner.example.invalid/v1/scan',actor={id:'synthetic-owner',session_id:'synthetic-session'};
const job={id:'synthetic-document',attempt_id:'synthetic-attempt',bucket:'mbn-admissions',object_path:'11111111-1111-4111-8111-111111111111/CV.pdf',byte_size:bytes.length,sha256:sha};
const verdict={status:'CLEAN',sha256:sha,engine:'ClamAV synthetic/1'};
test('scanner configuration is private, HTTPS-only and cannot send a candidate file while missing',async()=>{
 for(const endpoint of [undefined,'http://scanner.example.invalid/v1/scan','https://user:pass@scanner.example.invalid/v1/scan','https://scanner.example.invalid/v1/scan?x=1']){
  const scanner=createScanner(endpoint,token,async()=>{throw Error('Must not contact scanner');});assert.equal(scanner.configured,false);await assert.rejects(scanner.scan(bytes,sha),{message:'scanner_configuration_missing'});
 }
});
test('scanner binds a clean verdict to the exact bytes and never follows redirects',async()=>{
 let calls=0;
 const scanner=createScanner(url,token,async(endpoint,init)=>{calls++;assert.equal(endpoint,url);assert.equal(init?.redirect,'error');assert.equal((init?.headers as any).Authorization,'Bearer '+token);assert.deepEqual(init?.body,bytes);return Response.json(verdict);});
 assert.deepEqual(await scanner.scan(bytes,sha),{status:'CLEAN',engine:verdict.engine});
 await assert.rejects(scanner.scan(bytes,'a'.repeat(64)),{message:'document_integrity_failed'});assert.equal(calls,1);
});
test('infected bytes are retained as infected while uncertain, wrong-hash or oversized responses are errors',async()=>{
 const infected=createScanner(url,token,async()=>Response.json({...verdict,status:'INFECTED'}));assert.equal((await infected.scan(bytes,sha)).status,'INFECTED');
 for(const response of [()=>Response.json({...verdict,sha256:'a'.repeat(64)}),()=>Response.json({...verdict,status:'UNKNOWN'}),()=>Response.json({...verdict,engine:'<script>'}),()=>new Response('x'.repeat(4097)),()=>new Response('unavailable',{status:503})]){
  await assert.rejects(createScanner(url,token,async()=>response()).scan(bytes,sha));
 }
});
function harness(overrides:Partial<Dependencies>={}){
 const calls:{name:string,args:Record<string,unknown>}[]=[],downloaded:string[]=[];let claimed=false;
 const deps:Dependencies={authenticate:async()=>actor,scanner:createScanner(url,token,async()=>Response.json(verdict)),download:async(bucket,path)=>{downloaded.push(bucket+'/'+path);return bytes;},rpc:async(name,args)=>{
  calls.push({name,args});if(name==='mbn_runtime_key')return {data:token,error:null};
  if(name==='mbn_scan_claim'){if(claimed)return {data:null,error:null};claimed=true;return {data:job,error:null};}
  return {data:name==='mbn_scan_finish'?{status:args.p_status}:{settings:{enabled:true},counts:{},errors:[]},error:null};
 },...overrides};return {handler:createHandler(deps),calls,downloaded};
}
const req=(body:unknown={action:'scan_context'},auth=true)=>new Request('https://example.invalid',{method:'POST',headers:{'Content-Type':'application/json',...(auth?{Authorization:'Bearer '+'s'.repeat(30)}:{})},body:JSON.stringify(body)});
test('unauthenticated and non-admin callers cannot read the scan queue or contact the engine',async()=>{
 const unauth=harness({authenticate:async()=>null});assert.equal((await unauth.handler(req())).status,401);assert.equal(unauth.calls.length,0);
 const member=harness({rpc:async()=>({data:null,error:{code:'PT403',message:'access_denied'}})});assert.equal((await member.handler(req({action:'scan_process'}))).status,403);assert.equal(member.downloaded.length,0);
});
test('a worker needs its secret before claiming files and records the verified verdict without provider text',async()=>{
 const h=harness();const r=await h.handler(new Request('https://example.invalid',{method:'POST',headers:{'x-mbn-worker':token},body:'{}'}));assert.equal(r.status,200);assert.equal((await r.json()).outcomes[0].status,'CLEAN');
 assert.equal(h.calls.find(c=>c.name==='mbn_scan_finish')?.args.p_sha256,sha);assert.equal(h.downloaded.length,1);
 const bad=harness();assert.equal((await bad.handler(new Request('https://example.invalid',{method:'POST',headers:{'x-mbn-worker':'x'.repeat(90)},body:'{}'}))).status,401);assert.equal(bad.downloaded.length,0);
});
test('a storage or provider failure can only finish as ERROR and never as CLEAN',async()=>{
 const h=harness({download:async()=>{throw Error('sensitive provider detail');}});const response=await h.handler(req({action:'scan_process'}));
 assert.equal(response.status,200);assert.equal(h.calls.find(c=>c.name==='mbn_scan_finish')?.args.p_status,'ERROR');assert.ok(!(await response.text()).includes('sensitive'));
});
test('missing engine configuration cannot activate or process the queue',async()=>{
 const h=harness({scanner:{configured:false,scan:async()=>{throw Error('Must not scan');}}});
 assert.equal((await h.handler(req({action:'scan_save',data:{enabled:true}}))).status,422);
 assert.equal((await h.handler(req({action:'scan_process'}))).status,422);assert.ok(!h.calls.some(c=>c.name==='mbn_scan_claim'));
});
