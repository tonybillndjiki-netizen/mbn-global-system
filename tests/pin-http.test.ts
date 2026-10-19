import {before,test} from 'node:test';
import assert from 'node:assert/strict';
import {pbkdf2Sync} from 'node:crypto';
import {createHandler,hashPin,pin,username,type Dependencies} from '../supabase/functions/mbn-auth/handler.ts';
const actor='20000000-0000-4000-8000-000000000001',ticket='30000000-0000-4000-8000-000000000001',version='40000000-0000-4000-8000-000000000001',sid='60000000-0000-4000-8000-000000000001';
const salt='1234567890abcdef1234567890abcdef',code='735104';let hash:string;
before(async()=>{hash=await hashPin(code,salt);});
const jwt='eyJhbGciOiJub25lIn0.'+btoa(JSON.stringify({session_id:sid}))+'.synthetic-test-signature';
function harness(overrides:Partial<Dependencies>={}){
 const calls:{name:string;args:Record<string,unknown>}[]=[];let issues=0;
 const dependencies:Dependencies={authenticate:async()=>({id:actor,session_id:sid}),issue:async()=>{issues++;return {access_token:jwt,refresh_token:'synthetic-refresh',expires_in:3600,token_type:'bearer'};},rpc:async(name,args)=>{
  calls.push({name,args});let data:unknown;
  if(name==='mbn_pin_begin')data={blocked:false,ticket,credential:{version,user_id:actor,hash,salt,iterations:600000}};
  else if(name==='mbn_pin_finish')data=args.p_success?{allowed:true,user_id:actor,email:'test@example.invalid',version}:{allowed:false};
  else if(name==='mbn_pin_register_session')data=true;
  else if(name==='mbn_pin_context')data={actor:{configured:false,version,username_key:'tony bill',fresh:true},target:{configured:false,username:'Tony Bill'},admin:true};
  else data={success:true,username:'Tony Bill'};
  return {data,error:null};},...overrides};
 return {handler:createHandler(dependencies),calls,issues:()=>issues};
}
function req(data:unknown,auth=false){return new Request('https://test.invalid/auth',{method:'POST',headers:{'Content-Type':'application/json',...(auth?{Authorization:'Bearer '+ 'x'.repeat(40)}:{})},body:JSON.stringify(data)});}
test('names ignore case, accents and duplicate spaces while preserving their display name',()=>{assert.equal(username('  TÓNY   Bill ').key,'tony bill');assert.equal(username('  TÓNY   Bill ').display,'TÓNY Bill');});
test('PINs preserve leading zeroes and accept spaced pairs',()=>{assert.equal(pin('01 23 45'),'012345');for(const v of ['12345','1234567','12a456',123456])assert.throws(()=>pin(v));});
test('PIN hashing matches an independent PBKDF2 implementation and never stores the clear code',()=>{assert.equal(hash,pbkdf2Sync(code,Buffer.from(salt,'hex'),600000,32,'sha256').toString('hex'));assert.ok(!hash.includes(code));});
test('successful PIN login registers its revocable session before returning tokens',async()=>{const h=harness();const r=await h.handler(req({action:'login',username:'Tony Bill',pin:code}));assert.equal(r.status,200);assert.equal(h.issues(),1);assert.deepEqual(h.calls.map(c=>c.name),['mbn_pin_begin','mbn_pin_finish','mbn_pin_register_session']);assert.ok(!JSON.stringify(h.calls).includes(code));});
test('a wrong PIN cannot mint a Supabase session',async()=>{const h=harness();assert.equal((await h.handler(req({action:'login',username:'Tony Bill',pin:'654307'}))).status,401);assert.equal(h.issues(),0);});
test('unknown and inactive accounts have the same public failure and do not mint sessions',async()=>{const h=harness({rpc:async(name)=>({error:null,data:name==='mbn_pin_begin'?{blocked:false,ticket,credential:null}:{allowed:false}})});const r=await h.handler(req({action:'login',username:'Unknown User',pin:code}));assert.equal(r.status,401);assert.deepEqual(await r.json(),{error:'invalid_credentials'});assert.equal(h.issues(),0);});
test('rate limiting happens before the expensive hash or session exchange',async()=>{const h=harness({rpc:async()=>({error:null,data:{blocked:true}})});assert.equal((await h.handler(req({action:'login',username:'Tony Bill',pin:code}))).status,429);assert.equal(h.issues(),0);});
test('no code or hash is returned by the authenticated setup status',async()=>{const h=harness();const r=await h.handler(req({action:'status'},true));assert.equal(r.status,200);const body=await r.text();assert.ok(!body.includes(hash));assert.ok(!body.includes('version'));});
test('credential setup requires an authenticated session',async()=>{const h=harness({authenticate:async()=>null});assert.equal((await h.handler(req({action:'configure',username:'Tony Bill',new_pin:code},true))).status,401);assert.equal(h.calls.length,0);});
test('a first PIN cannot be installed from an old session',async()=>{const h=harness({rpc:async()=>({error:null,data:{actor:{configured:false,fresh:false},target:{},admin:true}})});assert.equal((await h.handler(req({action:'configure',username:'Tony Bill',new_pin:code},true))).status,403);assert.equal(h.issues(),0);});
test('a first PIN is sent to the database only as a salted hash',async()=>{const h=harness();const r=await h.handler(req({action:'configure',username:'Tony Bill',new_pin:code},true));assert.equal(r.status,200);const call=h.calls.find(c=>c.name==='mbn_pin_configure')!;assert.match(String(call.args.p_hash),/^[a-f0-9]{64}$/);assert.ok(!JSON.stringify(call.args).includes(code));});
test('changing an existing PIN requires proof of the actor current PIN',async()=>{const h=harness({rpc:async(name,args)=>{if(name==='mbn_pin_context')return {error:null,data:{actor:{configured:true,version,username_key:'tony bill'},target:{},admin:true}};if(name==='mbn_pin_begin')return {error:null,data:{blocked:false,ticket,credential:{version,user_id:actor,hash,salt,iterations:600000}}};return {error:null,data:{allowed:false}};}});assert.equal((await h.handler(req({action:'configure',username:'Tony Bill',new_pin:code,current_pin:'654307'},true))).status,401);assert.equal(h.calls.some(c=>c.name==='mbn_pin_configure'),false);});
test('failure to register a PIN session never exposes its issued token',async()=>{const h=harness({rpc:async(name,args)=>({error:null,data:name==='mbn_pin_begin'?{blocked:false,ticket,credential:{version,user_id:actor,hash,salt,iterations:600000}}:name==='mbn_pin_finish'?{allowed:args.p_success,user_id:actor,email:'test@example.invalid',version}:false})});const r=await h.handler(req({action:'login',username:'Tony Bill',pin:code}));assert.equal(r.status,503);assert.ok(!(await r.text()).includes('access_token'));});
test('oversized bodies and privilege spoofing are rejected',async()=>{const h=harness();assert.equal((await h.handler(req({action:'login',username:'Tony Bill',pin:code,admin:true}))).status,400);const r=req({action:'login',username:'Tony Bill',pin:code});r.headers.set('content-length','3000');assert.equal((await h.handler(r)).status,413);assert.equal(h.calls.length,0);});
