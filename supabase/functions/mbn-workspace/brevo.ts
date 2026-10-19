import type {Attachment,Inspection,Outcome,Sender} from './ses.ts';

export const BREVO_WEBHOOK='https://ppqeuluykiknuujfaoid.supabase.co/functions/v1/mbn-brevo-events';
const EVENTS=['sent','delivered','hardBounce','softBounce','blocked','spam','invalid','deferred','unsubscribed'];
type Message={id:string;recipient:string;subject:string;text:string;html:string;unsubscribe?:string;attachments?:Attachment[]};
export function createBrevo(apiKey:string|undefined,fetcher:typeof fetch=fetch){
 async function request(method:string,path:string,payload?:unknown){
  if(!apiKey)throw Error('brevo_credentials_missing');
  const response=await fetcher('https://api.brevo.com/v3'+path,{method,
   headers:{'api-key':apiKey,'Content-Type':'application/json','Accept':'application/json'},
   ...(payload===undefined?{}:{body:JSON.stringify(payload)}),redirect:'error',signal:AbortSignal.timeout(12000)});
  let value:Record<string,any>={};try{value=await response.json();}catch{}
  return {response,value};
 }
 return {
  configured:!!apiKey,
  async inspect(sender:Sender&{daily_limit?:number}):Promise<Inspection&{credential_fingerprint?:string}>{
   const empty={sender_verified:false,production_access:false,account_sending_enabled:false,remaining:0,rate:0};
   if(!apiKey)return {...empty,error:'brevo_credentials_missing'};
   if(!sender.from_email)return {...empty,error:'sender_configuration_missing'};
   try{
    const account=await request('GET','/account');
    if(!account.response.ok)return {...empty,error:account.response.status===401||account.response.status===403?'brevo_access_denied':'brevo_connection_unavailable'};
    const senders=await request('GET','/senders');
    if(!senders.response.ok||!Array.isArray(senders.value.senders))return {...empty,error:'brevo_sender_unavailable'};
    const active=senders.value.senders.some(s=>s.active===true&&String(s.email).toLowerCase()===sender.from_email.toLowerCase());
    const plans=Array.isArray(account.value.plan)?account.value.plan.filter(p=>['free','subscription','payAsYouGo'].includes(p.type)):[];
    const credits=plans.map(p=>Number(p.credits)).filter(n=>Number.isFinite(n)&&n>=0);
    const unlimited=plans.some(p=>Number(p.credits)===-1);
    const cap=Math.max(1,Math.min(10000,Number(sender.daily_limit)||100));
    const remaining=unlimited?cap:Math.min(cap,credits.reduce((a,b)=>a+b,0));
    const enabled=account.value.relay?.enabled===true;
    const hash=await crypto.subtle.digest('SHA-256',new TextEncoder().encode(apiKey));
    const credential_fingerprint=Array.from(new Uint8Array(hash),n=>n.toString(16).padStart(2,'0')).join('');
    return {sender_verified:active,production_access:enabled,account_sending_enabled:enabled,remaining,rate:1,credential_fingerprint,
     ...(!active?{error:'brevo_sender_unverified'}:!enabled?{error:'brevo_transactional_disabled'}:remaining<=0?{error:credits.length?'brevo_credits_exhausted':'brevo_quota_unavailable'}:{})};
   }catch{return {...empty,error:'brevo_connection_unavailable'};}
  },
  async configureWebhook(token:string):Promise<{id:number}>{
   if(!apiKey)throw Error('brevo_credentials_missing');
   if(token.length<80||token.length>200)throw Error('webhook_secret_unavailable');
   const list=await request('GET','/webhooks?type=transactional');
   if(!list.response.ok||!Array.isArray(list.value.webhooks))throw Error('brevo_webhook_setup_failed');
   const matches=list.value.webhooks.filter(w=>w.url===BREVO_WEBHOOK);
   if(matches.length>1)throw Error('brevo_duplicate_webhooks');
   const existing=matches[0]?.id;
   if(existing!==undefined&&(!Number.isSafeInteger(existing)||existing<=0))throw Error('brevo_webhook_setup_failed');
   const payload={url:BREVO_WEBHOOK,description:'MBN Mail · suivi des envois',type:'transactional',events:EVENTS,batched:false,auth:{type:'bearer',token}};
   const {type:_type,...update}=payload;
   const saved=await request(existing?'PUT':'POST',existing?'/webhooks/'+existing:'/webhooks',existing?update:payload);
   if(!saved.response.ok)throw Error('brevo_webhook_setup_failed');
   const id=existing||saved.value.id;
   if(!Number.isSafeInteger(id)||id<=0)throw Error('brevo_webhook_setup_failed');
   return {id};
  },
  async send(sender:Sender,message:Message):Promise<Outcome>{
   if(!apiKey)return {status:'FAILED',error:'brevo_credentials_missing'};
   const payload={sender:{name:sender.from_name,email:sender.from_email},to:[{email:message.recipient}],
    subject:message.subject,htmlContent:message.html,textContent:message.text,
    ...(sender.reply_to?{replyTo:{email:sender.reply_to}}:{}),
    tags:['mbn_'+message.id],headers:{'X-Mailin-custom':'mbn_message_id:'+message.id},
    ...(message.attachments?.length?{attachment:message.attachments.map(a=>({name:a.filename,content:a.base64}))}:{})};
   try{
    const {response,value}=await request('POST','/smtp/email',payload);
    if(response.ok&&typeof value.messageId==='string'&&value.messageId.length>0&&value.messageId.length<200)return {status:'ACCEPTED',provider_id:value.messageId};
    if(response.status>=500||response.ok||response.status===408)return {status:'UNCERTAIN',error:'brevo_acceptance_uncertain'};
    return {status:'FAILED',error:response.status===429?'brevo_throttled':'brevo_request_rejected'};
   }catch{return {status:'UNCERTAIN',error:'brevo_connection_interrupted'};}
  }
 };
}
