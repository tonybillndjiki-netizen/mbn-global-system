import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createContext,runInContext} from 'node:vm';
import {createHash,createHmac} from 'node:crypto';
import {createAppsScript,appscriptMAC} from '../supabase/functions/mbn-workspace/appscript.ts';
import {createMailTransport} from '../supabase/functions/mbn-workspace/mail-transport.ts';
import type {Sender} from '../supabase/functions/mbn-workspace/ses.ts';

const secret='s'.repeat(96),url='https://script.google.com/macros/s/'+'A'.repeat(35)+'/exec';
const config=JSON.stringify({MBN_GLOBAL:{url,secret}});
const sender={code:'MBN_GLOBAL',provider:'GOOGLE_APPS_SCRIPT',from_email:'sender@example.invalid',from_name:'Service admissions - EMSP',reply_to:'sender@example.invalid'} as Sender;
const message={id:'70000000-0000-4000-8000-000000000001',recipient:'candidate@example.invalid',subject:'Votre admission',text:'Texte de démonstration',html:'<p>Texte de démonstration</p>',attachments:[{filename:'admission.pdf',mime_type:'application/pdf',base64:Buffer.from('%PDF-synthetic').toString('base64')}]};
function bridge({quota=10,throwSend=false,flushFailure=false}={}){
 const rows:any[][]=[['message_id','sha256','status','updated_at']],sent:any[]=[];
 const props:Record<string,string>={MBN_MAIL_SECRET:secret,MBN_MAIL_LEDGER_ID:'synthetic-ledger'};
 const sheet={appendRow:(v:any[])=>rows.push(v),getLastRow:()=>rows.length,
  getRange:(row:number|string,col?:number,n?:number,w?:number)=>({
   createTextFinder:(value:string)=>({matchEntireCell:()=>({findNext:()=>{const i=rows.findIndex(r=>r[0]===value);return i<0?null:{getRow:()=>i+1};}})}),
   getValues:()=>[rows[Number(row)-1].slice(Number(col)-1,Number(col)-1+Number(w))],
   setValues:(values:any[][])=>{for(let i=0;i<values[0].length;i++)rows[Number(row)-1][Number(col)-1+i]=values[0][i];}})};
 const context=createContext({
  PropertiesService:{getScriptProperties:()=>({getProperty:(k:string)=>props[k],setProperty:(k:string,v:string)=>{props[k]=v;}})},
  Session:{getEffectiveUser:()=>({getEmail:()=>sender.from_email})},
  Utilities:{Charset:{UTF_8:'UTF-8'},DigestAlgorithm:{SHA_256:'sha256'},
   getUuid:()=>crypto.randomUUID(),computeHmacSha256Signature:(v:string,k:string)=>[...createHmac('sha256',k).update(v).digest()],
   computeDigest:(_:any,v:string)=>[...createHash('sha256').update(v).digest()],base64Decode:(v:string)=>[...Buffer.from(v,'base64')],
   newBlob:(v:any,mime?:string,name?:string)=>({getBytes:()=>[...Buffer.from(v)],mime,name})},
  ContentService:{MimeType:{JSON:'application/json'},createTextOutput:(text:string)=>({setMimeType:()=>text})},
  SpreadsheetApp:{openById:()=>({getSheetByName:()=>sheet}),flush:()=>{if(flushFailure)throw Error('synthetic storage failure');}},
  LockService:{getScriptLock:()=>({tryLock:()=>true,releaseLock:()=>{}})},
  MailApp:{getRemainingDailyQuota:()=>quota,sendEmail:(value:any)=>{sent.push(value);if(throwSend)throw Error('synthetic network uncertainty');}}
 });
 runInContext(readFileSync(new URL('../appscript/Code.gs',import.meta.url),'utf8'),context);
 const fetcher=(async(_url:any,init:any)=>new Response(context.doPost({postData:{contents:init.body}}),{status:200})) as typeof fetch;
 return {context,rows,sent,fetcher,props};
}
test('Apps Script verifies its actual sender and sends a letter with the exact attachment once',async()=>{
 const b=bridge(),transport=createAppsScript(config,b.fetcher),inspection=await transport.inspect(sender);
 assert.equal(inspection.provider,'GOOGLE_APPS_SCRIPT');assert.equal(inspection.sender_verified,true);assert.equal(inspection.remaining,10);
 assert.match(inspection.credential_fingerprint!,/^[a-f0-9]{64}$/);
 assert.deepEqual(await transport.send(sender,message),{status:'ACCEPTED',provider_id:'apps-script:'+message.id});
 assert.equal((await transport.send(sender,message)).status,'ACCEPTED');assert.equal(b.sent.length,1);
 assert.equal(b.sent[0].to,message.recipient);assert.equal(b.sent[0].name,sender.from_name);
 assert.equal(b.sent[0].attachments[0].name,'admission.pdf');
 assert.equal(Buffer.from(b.sent[0].attachments[0].getBytes()).toString(),'%PDF-synthetic');
 assert.equal(b.rows[1][2],'ACCEPTED');
});
test('a repeated message id with changed content and an interrupted send never trigger another email',async()=>{
 for(const throwSend of [false,true]){
  const b=bridge({throwSend}),transport=createAppsScript(config,b.fetcher);
  const initial=await transport.send(sender,message);assert.equal(initial.status,throwSend?'UNCERTAIN':'ACCEPTED');
  const replay=await transport.send(sender,{...message,subject:'Changed'});
  assert.equal(replay.status,'UNCERTAIN');assert.equal(b.sent.length,1);
 }
});
test('quota exhaustion, missing connection, invalid sender and journal failures cannot send',async()=>{
 const b=bridge({quota:0}),transport=createAppsScript(config,b.fetcher);
 assert.equal((await transport.inspect(sender)).error,'appscript_quota_exhausted');
 assert.equal((await transport.send(sender,message)).status,'FAILED');assert.equal(b.sent.length,0);
 assert.equal((await transport.inspect({...sender,from_email:'wrong@example.invalid'})).sender_verified,false);
 assert.equal((await transport.send({...sender,code:'ADMISSIONS_COMMUN'},message)).status,'FAILED');
 const failed=bridge({flushFailure:true});assert.equal((await createAppsScript(config,failed.fetcher).send(sender,message)).status,'UNCERTAIN');assert.equal(failed.sent.length,0);
});
test('unsigned requests, expired signatures, multiple recipients and oversized attachments are rejected',async()=>{
 const b=bridge();
 assert.match(b.context.doPost({postData:{contents:'{}'}}),/authentication_required/);
 const payload=JSON.stringify({action:'send',sender,message}),nonce=crypto.randomUUID(),timestamp=Date.now()-121000;
 const signature=await appscriptMAC(secret,timestamp+'\n'+nonce+'\n'+payload);
 assert.match(b.context.doPost({postData:{contents:JSON.stringify({timestamp,nonce,payload,signature})}}),/authentication_required/);
 const transport=createAppsScript(config,b.fetcher);
 assert.equal((await transport.send(sender,{...message,recipient:'a@example.invalid,b@example.invalid'})).status,'FAILED');
 assert.equal((await transport.send(sender,{...message,attachments:[{...message.attachments[0],base64:Buffer.alloc(5242881).toString('base64')}]})).status,'FAILED');
 assert.equal(b.sent.length,0);
});
test('Google redirect responses are fetched with GET and untrusted redirects or signatures cannot confirm sending',async()=>{
 let methods:string[]=[];const b=bridge();
 let responseBody='';
 const fetcher=(async(request:any,init:any)=>{methods.push(init.method);if(init.method==='POST'){
  responseBody=b.context.doPost({postData:{contents:init.body}});
  return new Response(null,{status:302,headers:{location:'https://script.googleusercontent.com/macros/echo?synthetic=1'}});
 }assert.equal(init.body,undefined);return new Response(responseBody);}) as typeof fetch;
 assert.equal((await createAppsScript(config,fetcher).send(sender,message)).status,'ACCEPTED');assert.deepEqual(methods,['POST','GET']);
 const evil=(async()=>new Response(null,{status:302,headers:{location:'https://example.invalid/collect'}})) as typeof fetch;
 assert.equal((await createAppsScript(config,evil).send(sender,message)).status,'UNCERTAIN');
 const fake=(async()=>new Response(JSON.stringify({payload:JSON.stringify({status:'ACCEPTED',message_id:message.id,provider_id:'apps-script:'+message.id}),signature:'0'.repeat(64)}))) as typeof fetch;
 assert.equal((await createAppsScript(config,fake).send(sender,message)).status,'UNCERTAIN');
 assert.equal(createAppsScript(JSON.stringify({MBN_GLOBAL:{url:'https://example.invalid',secret}})).configured,false);
});
test('a selected Google provider never falls back to stored Brevo credentials',async()=>{
 const transport=createMailTransport(undefined,'synthetic-unused-brevo-key',async()=> 'GOOGLE_APPS_SCRIPT');
 assert.equal(transport.configuredFor('GOOGLE_APPS_SCRIPT'),false);
 assert.deepEqual(await transport.status(),{provider:'GOOGLE_APPS_SCRIPT',credentials_configured:false});
 assert.equal((await transport.inspect(sender)).error,'appscript_connection_missing');
 assert.equal((await transport.send(sender,message)).status,'FAILED');
});
