import type {Attachment,Inspection,Outcome,Sender} from './ses.ts';

export const APPS_SCRIPT_PROVIDER='GOOGLE_APPS_SCRIPT';
type Endpoint={url:string;secret:string};
type Message={id:string;recipient:string;subject:string;text:string;html:string;attachments?:Attachment[]};
const groups=['MBN_GLOBAL','CAMPUS_INNOVATION_MLV','ADMISSIONS_COMMUN'];
const encoder=new TextEncoder();
const hex=(bytes:ArrayBuffer)=>Array.from(new Uint8Array(bytes),n=>n.toString(16).padStart(2,'0')).join('');
const digest=async(value:string)=>hex(await crypto.subtle.digest('SHA-256',encoder.encode(value)));
export async function appscriptMAC(secret:string,value:string){
 const key=await crypto.subtle.importKey('raw',encoder.encode(secret),{name:'HMAC',hash:'SHA-256'},false,['sign']);
 return hex(await crypto.subtle.sign('HMAC',key,encoder.encode(value)));
}
function endpoints(value:string|undefined):Record<string,Endpoint>{
 try{
  const input=JSON.parse(value||'{}'),result:Record<string,Endpoint>={};
  for(const group of groups){const row=input[group];
   if(row&&typeof row.url==='string'&&/^https:\/\/script\.google\.com\/macros\/s\/[A-Za-z0-9_-]{20,200}\/exec$/.test(row.url)
    &&typeof row.secret==='string'&&/^[A-Za-z0-9_-]{80,200}$/.test(row.secret))result[group]={url:row.url,secret:row.secret};
  }return result;
 }catch{return {};}
}
export function createAppsScript(value:string|undefined,fetcher:typeof fetch=fetch){
 const config=endpoints(value);
 async function invoke(sender:Sender&{code?:string},action:string,message?:Message){
  const endpoint=sender.code?config[sender.code]:undefined;
  if(!endpoint)throw Error('appscript_connection_missing');
  const nonce=crypto.randomUUID(),timestamp=Date.now(),payload=JSON.stringify({action,sender:{from_email:sender.from_email,from_name:sender.from_name,reply_to:sender.reply_to},...(message?{message}:{})});
  const signature=await appscriptMAC(endpoint.secret,timestamp+'\n'+nonce+'\n'+payload);
  const signal=AbortSignal.timeout(20000);
  let response=await fetcher(endpoint.url,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({timestamp,nonce,payload,signature}),redirect:'manual',signal});
  // ContentService redirects its response to Google. Never forward the signed
  // mail body or secret to a redirect, and never follow a non-Google location.
  if(response.status===302||response.status===303){
   const location=response.headers.get('location');
   if(!location||!/^https:\/\/script\.googleusercontent\.com\/macros\/echo\?[^#\s]{1,4000}$/.test(location))throw Error('appscript_invalid_response');
   response=await fetcher(location,{method:'GET',redirect:'error',signal});
  }
  if(!response.ok||!response.body)throw Error('appscript_connection_unavailable');
  const reader=response.body.getReader(),chunks:Uint8Array[]=[];let size=0;
  try{for(;;){const {done,value}=await reader.read();if(done)break;size+=value.length;if(size>16384){await reader.cancel();throw Error('appscript_invalid_response');}chunks.push(value);}}finally{reader.releaseLock();}
  const bytes=new Uint8Array(size);let at=0;for(const chunk of chunks){bytes.set(chunk,at);at+=chunk.length;}
  const envelope=JSON.parse(new TextDecoder().decode(bytes));
  if(typeof envelope.payload!=='string'||typeof envelope.signature!=='string'||!/^[a-f0-9]{64}$/.test(envelope.signature))throw Error('appscript_invalid_response');
  const expected=await appscriptMAC(endpoint.secret,nonce+'\n'+envelope.payload);
  let diff=0;for(let i=0;i<64;i++)diff|=expected.charCodeAt(i)^envelope.signature.charCodeAt(i);
  if(diff)throw Error('appscript_invalid_response');
  const result=JSON.parse(envelope.payload);
  if(result.nonce!==nonce)throw Error('appscript_invalid_response');
  return {result,fingerprint:await digest(endpoint.url+'\n'+endpoint.secret)};
 }
 return {
  provider:APPS_SCRIPT_PROVIDER,
  configured:Object.keys(config).length>0,
  async inspect(sender:Sender):Promise<Inspection>{
   const empty={provider:APPS_SCRIPT_PROVIDER,sender_verified:false,production_access:false,account_sending_enabled:false,remaining:0,rate:0};
   try{
    const {result,fingerprint}=await invoke(sender,'inspect');
    if(result.error)return {...empty,error:/^appscript_[a-z_]{3,65}$/.test(result.error)?result.error:'appscript_invalid_response'};
    if(result.sender_email!==sender.from_email.toLowerCase())return {...empty,error:'appscript_sender_mismatch'};
    if(!Number.isSafeInteger(result.remaining)||result.remaining<0||result.remaining>100000)return {...empty,error:'appscript_invalid_response'};
    return {...empty,sender_verified:true,production_access:true,account_sending_enabled:true,remaining:result.remaining,rate:1,credential_fingerprint:fingerprint,
     ...(result.remaining===0?{error:'appscript_quota_exhausted'}:{})};
   }catch(error){return {...empty,error:error instanceof Error&&error.message==='appscript_connection_missing'?error.message:'appscript_connection_unavailable'};}
  },
  async send(sender:Sender,message:Message):Promise<Outcome>{
   if(!(sender as Sender&{code?:string}).code||!config[(sender as Sender&{code:string}).code])return {status:'FAILED',error:'appscript_connection_missing'};
   try{
    const {result}=await invoke(sender,'send',message);
    if(result.message_id!==message.id)throw Error('appscript_invalid_response');
    if(result.status==='ACCEPTED'&&result.provider_id==='apps-script:'+message.id)return {status:'ACCEPTED',provider_id:result.provider_id};
    if(['FAILED','UNCERTAIN'].includes(result.status)&&/^appscript_[a-z_]{3,65}$/.test(result.error))return {status:result.status,error:result.error};
    throw Error('appscript_invalid_response');
   }catch{return {status:'UNCERTAIN',error:'appscript_acceptance_uncertain'};}
  }
 };
}
