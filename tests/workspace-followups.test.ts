import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createHandler} from '../supabase/functions/mbn-workspace/handler.ts';
const actor={id:'20000000-0000-4000-8000-000000000001',session_id:'30000000-0000-4000-8000-000000000001'};
const request=(action:string,data:object)=>new Request('https://example.invalid',{method:'POST',headers:{authorization:'Bearer '+'t'.repeat(30),'Content-Type':'application/json'},body:JSON.stringify({action,data})});
test('followup settings use the authenticated school RPC without inspecting Brevo or sending mail',async()=>{
 const calls:any[]=[];let sends=0,inspects=0;
 const handler=createHandler({authenticate:async()=>actor,rpc:async(name,args)=>{calls.push({name,args});return {data:{schools:[],enabled:false},error:null};},transport:{configured:true,inspect:async()=>{inspects++;throw Error('unexpected');},send:async()=>{sends++;throw Error('unexpected');}},download:async()=>new Uint8Array(),sleep:async()=>{}});
 for(const action of ['followups_context','followup_save','followup_toggle'])assert.equal((await handler(request(action,{school_code:'MLV BTS'}))).status,200);
 assert.equal(sends,0);assert.equal(inspects,0);assert.equal(calls.length,3);
 calls.forEach((c,i)=>{assert.equal(c.name,'mbn_followup_action');assert.equal(c.args.p_actor,actor.id);assert.equal(c.args.p_session,actor.session_id);assert.equal(c.args.p_action,['followups_context','followup_save','followup_toggle'][i]);});
});
test('followup changes reject expired sessions, missing school permission and stale revisions',async()=>{
 for(const blocked of ['authentication','permission','revision']){
  const handler=createHandler({authenticate:async()=>blocked==='authentication'?null:actor,rpc:async()=>({data:null,error:{code:blocked==='revision'?'PT409':'PT403',message:blocked==='revision'?'followup_changed':'access_denied'}}),transport:{configured:false,inspect:async()=>{throw Error('unexpected');},send:async()=>{throw Error('unexpected');}},download:async()=>new Uint8Array(),sleep:async()=>{}});
  const response=await handler(request('followup_save',{school_code:'MLV BTS'}));assert.equal(response.status,blocked==='authentication'?401:blocked==='revision'?409:403);
 }
});
