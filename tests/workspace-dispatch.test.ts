import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createHandler,SENDER_GROUPS} from '../supabase/functions/mbn-workspace/handler.ts';

type Group=typeof SENDER_GROUPS[number];
const schools:Record<Group,string>={MBN_GLOBAL:'EMSP',CAMPUS_INNOVATION_MLV:'MLV BTS',ADMISSIONS_COMMUN:'ESETH'};
const worker='synthetic-worker-'.repeat(6);

function fixture({dailyLimit=1000,unverified='',failed=''}={}){
 const counts=Object.fromEntries(SENDER_GROUPS.map(g=>[g,0])) as Record<Group,number>;
 const remaining=Object.fromEntries(SENDER_GROUPS.map(g=>[g,200])) as Record<Group,number>;
 const attempts:Group[]=[],claims:Group[]=[];let accepted=0,clock=0;
 const profiles=Object.fromEntries(SENDER_GROUPS.map(g=>[g,{code:g,revision:crypto.randomUUID(),enabled:true,from_email:g.toLowerCase()+'@example.invalid'}]));
 const handler=createHandler({authenticate:async()=>null,download:async()=>new Uint8Array(),sleep:async()=>{},
  transport:{configured:true,
   inspect:async sender=>({sender_verified:sender.from_email!==profiles[unverified]?.from_email,production_access:true,account_sending_enabled:true,remaining:1000,rate:10}),
   send:async(sender,message)=>{const group=SENDER_GROUPS.find(g=>profiles[g].from_email===sender.from_email)!;attempts.push(group);
    if(group===failed)return {status:'FAILED',error:'brevo_request_rejected'};
    counts[group]++;return {status:'ACCEPTED',provider_id:message.id};}},
  rpc:async(name,args)=>{
   let data:unknown;
   if(name==='mbn_runtime_key')data=worker;
   else if(name==='mbn_mail_profile_settings'||name==='mbn_mail_profile_checked')data=profiles[args.p_group as Group];
   else if(name==='mbn_mail_profile_claim'){
    const group=args.p_group as Group;claims.push(group);
    if(accepted<dailyLimit&&remaining[group]>0)profiles[group].last_dispatch_at=new Date(Date.now()+(++clock)).toISOString();
    data=accepted>=dailyLimit||remaining[group]--<=0?null:{id:crypto.randomUUID(),attempt_id:crypto.randomUUID(),lead_id:crypto.randomUUID(),school_code:schools[group],
     recipient:'synthetic@example.invalid',subject:'Synthetic',body:'Synthetic',service_contact_email:'admissions@example.invalid',sender:profiles[group],lead:{full_name:'Synthetic'}};
   }else if(name==='mbn_mail_link')data={id:crypto.randomUUID(),revoked:false,expires_at:'2099-01-01'};
   else if(name==='mbn_mail_profile_authorized')data=true;
   else if(name==='mbn_mail_finish'){if(args.p_status==='ACCEPTED')accepted++;data=null;}
   else throw Error('Unexpected RPC '+name);
   return {data,error:null};
  }});
 const tick=async()=>{const response=await handler(new Request('https://example.invalid',{method:'POST',headers:{'x-mbn-worker':worker},body:'{}'}));assert.equal(response.status,200);return response.json();};
 return {tick,counts,attempts,claims,newDay:()=>{accepted=0;}};
}

test('a batch rotates between ready senders and keeps the twenty-message bound',async()=>{
 const f=fixture(),result=await f.tick();
 assert.equal(result.processed,20);assert.equal(f.attempts.length,20);
 assert.deepEqual(f.attempts.slice(0,6),[...SENDER_GROUPS,...SENDER_GROUPS]);
 assert.deepEqual(Object.values(f.counts),[7,7,6]);
});

test('backlogged groups share the daily allowance across scheduled batches',async()=>{
 const f=fixture({dailyLimit:100});
 for(let i=0;i<6;i++)await f.tick();
 assert.equal(Object.values(f.counts).reduce((a,b)=>a+b),100);
 assert.ok(Object.values(f.counts).every(n=>n>=30&&n<=35));
});

test('a daily allowance of one rotates to the least recently served group on the next day',async()=>{
 const f=fixture({dailyLimit:1});
 for(let day=0;day<3;day++){await f.tick();f.newDay();}
 assert.deepEqual(Object.values(f.counts),[1,1,1]);
});

test('an unverified sender is skipped while the other school groups continue',async()=>{
 const f=fixture({unverified:'MBN_GLOBAL'}),result=await f.tick();
 assert.equal(f.counts.MBN_GLOBAL,0);assert.equal(f.counts.CAMPUS_INNOVATION_MLV,10);assert.equal(f.counts.ADMISSIONS_COMMUN,10);
 assert.equal(result.skipped[0].sender_group,'MBN_GLOBAL');
 assert.ok(!f.claims.includes('MBN_GLOBAL'));
});

test('a rejected send stops that group for this batch without repeating it or blocking the others',async()=>{
 const f=fixture({failed:'MBN_GLOBAL'}),result=await f.tick();
 assert.equal(result.processed,20);assert.equal(f.attempts.filter(g=>g==='MBN_GLOBAL').length,1);
 assert.ok(f.counts.CAMPUS_INNOVATION_MLV>0&&f.counts.ADMISSIONS_COMMUN>0);
});
