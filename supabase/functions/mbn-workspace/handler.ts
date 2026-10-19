import {brandFor,logoURL} from '../../../assets/branding.js';
import type {Inspection,Outcome,Sender} from './ses.ts';
import {digest} from '../mbn-form-ingest/handler.ts';
export type Actor={id:string;session_id:string};
type Reply={data:unknown;error:{code?:string;message?:string}|null};
type Transport={configured:boolean;inspect(sender:Sender):Promise<Inspection>;configureWebhook?(token:string):Promise<{id:number}>;send(sender:Sender,message:{id:string;recipient:string;subject:string;text:string;html:string;unsubscribe?:string}):Promise<Outcome>};
export type Dependencies={authenticate(token:string):Promise<Actor|null>;rpc(name:string,args:Record<string,unknown>):PromiseLike<Reply>;transport:Transport;download(bucket:string,path:string):Promise<Uint8Array>;sleep(ms:number):Promise<void>};
export const ORIGIN='https://mbn-global.netlify.app';
export const ENDPOINT='https://ppqeuluykiknuujfaoid.supabase.co/functions/v1';
export const UUID=/^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/;
const cors={'Access-Control-Allow-Origin':'*','Access-Control-Allow-Headers':'authorization,apikey,content-type,x-client-info,x-mbn-worker','Access-Control-Allow-Methods':'POST,OPTIONS','Access-Control-Expose-Headers':'Content-Disposition','Cache-Control':'no-store','X-Content-Type-Options':'nosniff'};
export const json=(value:unknown,status=200)=>new Response(JSON.stringify(value),{status,headers:{...cors,'Content-Type':'application/json; charset=utf-8'}});
export class AppError extends Error{constructor(public code:string,public status=400){super(code);}}
export function object(value:unknown):Record<string,any>{if(!value||typeof value!=='object'||Array.isArray(value))throw new AppError('invalid_request');return value as Record<string,any>;}
export async function readJSON(request:Request,max=1048576){
 if(!request.body)throw new AppError('invalid_request');
 if(Number(request.headers.get('content-length')||0)>max)throw new AppError('request_too_large',413);
 const reader=request.body.getReader(),chunks:Uint8Array[]=[];let size=0;
 try{for(;;){const {done,value}=await reader.read();if(done)break;size+=value.length;if(size>max){await reader.cancel();throw new AppError('request_too_large',413);}chunks.push(value);}}finally{reader.releaseLock();}
 const bytes=new Uint8Array(size);let at=0;for(const chunk of chunks){bytes.set(chunk,at);at+=chunk.length;}
 try{return object(JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes)));}catch{throw new AppError('invalid_request');}
}
export function rpcError(error:NonNullable<Reply['error']>){
 const status=/^PT(400|403|404|409|422|429)$/.exec(error.code||'')?.[1];
 if(status&&/^[a-z_]{3,80}$/.test(error.message||''))throw new AppError(error.message!,Number(status));
 throw Error('service_unavailable');
}
const h=(s:unknown)=>String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]!));
export const SENDER_GROUPS=['MBN_GLOBAL','CAMPUS_INNOVATION_MLV'] as const;
function senderGroup(value:unknown){if(typeof value!=='string'||!SENDER_GROUPS.includes(value as typeof SENDER_GROUPS[number]))throw new AppError('invalid_sender_group',422);return value;}
export async function capability(secret:string,id:string,purpose:'admission'|'unsubscribe'){
 const key=await crypto.subtle.importKey('raw',new TextEncoder().encode(secret),{name:'HMAC',hash:'SHA-256'},false,['sign']);
 const mac=new Uint8Array(await crypto.subtle.sign('HMAC',key,new TextEncoder().encode('mbn:v1:'+purpose+':'+id)));
 return id+'.'+Array.from(mac,n=>n.toString(16).padStart(2,'0')).join('');
}
export async function verifyCapability(secret:string,token:unknown,purpose:'admission'|'unsubscribe'){
 if(typeof token!=='string'||!/^[a-f0-9-]{36}\.[a-f0-9]{64}$/.test(token)||!UUID.test(token.slice(0,36)))throw new AppError('link_unavailable',404);
 const expected=await capability(secret,token.slice(0,36),purpose);let diff=0;for(let i=0;i<expected.length;i++)diff|=expected.charCodeAt(i)^token.charCodeAt(i);
 if(diff)throw new AppError('link_unavailable',404);return token.slice(0,36);
}
export function renderMessage(message:Record<string,any>,admissionURL?:string,unsubscribeURL?:string){
 const brand=brandFor(message.school_code),full=String(message.lead?.full_name||''),values:Record<string,string>={nom:full,prenom:full.split(/\s+/)[0]||'',ecole:brand.schoolName,lien_candidature:admissionURL||''};
 const fill=(s:string)=>s.replace(/\{\{\s*(nom|prenom|ecole|lien_candidature)\s*\}\}/g,(_,key)=>values[key]);
 const contact=String(message.service_contact_email||'');
 if(contact&&(contact.length>254||!/^\S+@[^\s@]+\.[^\s@]+$/.test(contact)))throw new AppError('invalid_mail_route',422);
 const notice='Ceci est un message automatique. Merci de ne pas répondre à cet e-mail.';
 const information=contact?'Pour toute information, veuillez écrire au service des admissions de votre établissement : '+contact+'.':'';
 const text=fill(message.body)+(admissionURL?'\n\nDéposer ma candidature : '+admissionURL:'')+'\n\n'+notice+(information?'\n'+information:'')+(unsubscribeURL?'\n\nMe désinscrire : '+unsubscribeURL:'');
 const footer=`<p>${notice}</p>${contact?`<p>Pour toute information, veuillez écrire au service des admissions de votre établissement : <a href="mailto:${h(contact)}" style="color:#514a76">${h(contact)}</a>.</p>`:''}`;
 const html=`<!doctype html><html lang="fr"><body style="margin:0;background:#f4f3ef;font-family:Arial,sans-serif;color:#1b2340"><table role="presentation" width="100%" cellspacing="0" cellpadding="0"><tr><td style="padding:30px 16px"><table role="presentation" width="100%" style="max-width:620px;margin:auto;background:white;border-radius:16px" cellspacing="0" cellpadding="28"><tr><td style="border-bottom:1px solid #eee"><img src="${logoURL(brand)}" width="165" alt="${h(brand.name)}"><p style="color:#6e6b81;font-size:13px">${h(brand.name)} · ${h(brand.schoolName)}</p></td></tr><tr><td style="font-size:16px;line-height:1.7">${h(fill(message.body)).replace(/\n/g,'<br>')}${admissionURL?`<p><a href="${h(admissionURL)}" style="display:inline-block;padding:13px 22px;background:#252350;color:white;text-decoration:none;border-radius:9px">Déposer ma candidature</a></p>`:''}</td></tr><tr><td style="font-size:12px;color:#767283;border-top:1px solid #eee">${h(brand.name)}${footer}${unsubscribeURL?`<p><a href="${h(unsubscribeURL)}" style="color:#767283">Se désinscrire des communications</a></p>`:''}</td></tr></table></td></tr></table></body></html>`;
 return {subject:fill(message.subject),text,html};
}
export function createHandler(deps:Dependencies){
 async function rpc(name:string,args:Record<string,unknown>={}){const r=await deps.rpc(name,args);if(r.error)rpcError(r.error);return r.data;}
 let keyPromise:Promise<string>|undefined;
 const key=()=>keyPromise??=(async()=>{const v=await rpc('mbn_runtime_key',{p_name:'link'});if(typeof v!=='string'||v.length<80)throw Error('key_unavailable');return v;})().catch(error=>{keyPromise=undefined;throw error;});
 async function links(lead:string){const row=object(await rpc('mbn_mail_link',{p_lead:lead}));if(!UUID.test(row.id)||row.revoked||Date.parse(row.expires_at)<Date.now())throw new AppError('link_unavailable',422);const secret=await key();return {url:ORIGIN+'/apply.html#'+await capability(secret,row.id,'admission'),preferences:ORIGIN+'/preferences.html#'+await capability(secret,row.id,'unsubscribe'),oneClick:ENDPOINT+'/mbn-admissions?unsubscribe='+await capability(secret,row.id,'unsubscribe')};}
 async function check(group:string){
  const settings=object(await rpc('mbn_mail_profile_settings',{p_group:group}));
  const raw=await deps.transport.inspect(settings as Sender);
  const current=object(await rpc('mbn_mail_profile_checked',{p_group:group,p_revision:settings.revision,p_result:raw}));
  const {credential_fingerprint:_fingerprint,...inspection}=raw;
  return {settings:current,inspection};
 }
 async function dispatch(testId?:string,selectedGroup?:string){
  const start=Date.now(),outcomes:{id:string;status:string}[]=[],skipped:{sender_group:string;error:string}[]=[];
  for(const group of selectedGroup?[selectedGroup]:SENDER_GROUPS){
   const {settings,inspection}=await check(group);
   const error=!inspection.sender_verified||!inspection.account_sending_enabled||inspection.remaining<=0||inspection.rate<=0?inspection.error||'sender_not_ready':!testId&&(!settings.enabled||!inspection.production_access)?'sending_disabled':null;
   if(error){if(testId)throw new AppError(error,422);skipped.push({sender_group:group,error});continue;}
   for(let n=0;n<(testId?1:Math.min(20,Math.floor(inspection.remaining)));n++){
   if(outcomes.length>=20)break;
   if(Date.now()-start>40000)break;
   const raw=await rpc('mbn_mail_profile_claim',{p_group:group,p_test_id:testId||null});if(raw===null)break;const msg=object(raw);
   if(!UUID.test(msg.id)||!UUID.test(msg.attempt_id))throw Error('invalid_claim');
   let result:Outcome;
   try{
    if(!msg.service_contact_email)throw new AppError('mail_route_missing',422);
    const sender=object(msg.sender);
    const paths=msg.is_test?undefined:await links(msg.lead_id),rendered=renderMessage(msg,paths?.url,paths?.preferences);
    if(await rpc('mbn_mail_profile_authorized',{p_id:msg.id,p_attempt:msg.attempt_id})!==true){outcomes.push({id:msg.id,status:'CANCELED'});continue;}
    result=await deps.transport.send({...sender,reply_to:sender.from_email} as Sender,{id:msg.id,recipient:msg.recipient,...rendered,unsubscribe:paths?.oneClick});
   }catch{result={status:'FAILED',error:'message_preparation_failed'};}
   await rpc('mbn_mail_finish',{p_id:msg.id,p_attempt:msg.attempt_id,p_status:result.status,p_provider_id:result.provider_id||null,p_error:result.error||null});
   outcomes.push({id:msg.id,status:result.status});
   if(result.status!=='ACCEPTED')break;
   if(!testId)await deps.sleep(Math.max(1000,Math.ceil(1000/inspection.rate)));
   }
   if(outcomes.length>=20||Date.now()-start>40000)break;
  }
  return {outcomes,processed:outcomes.length,skipped};
 }
 const actions=new Set(['bootstrap','leads_list','lead_save','leads_import','lead_detail','lead_note','lead_exclude','applications_list','application_detail','application_transition','application_assign','document_review','campaigns_list','campaign_save','campaign_preview','campaign_launch','campaign_pause','campaign_resume','templates_list','template_save','messages_list','message_cancel','settings_get','routing_list','routing_save','routing_toggle','mail_config_get','mail_group_save','mail_route_save','mail_limit_save']);
 return async(request:Request)=>{
  if(request.method==='OPTIONS')return new Response(null,{status:204,headers:cors});
  if(request.method!=='POST')return json({error:'method_not_allowed'},405);
  try{
   const worker=request.headers.get('x-mbn-worker');
   if(worker){
    if(worker.length<80||worker.length>200)return json({error:'authentication_required'},401);
    const expected=await rpc('mbn_runtime_key',{p_name:'worker'});let d=String(expected).length^worker.length;for(let i=0;i<worker.length;i++)d|=worker.charCodeAt(i)^(String(expected).charCodeAt(i)||0);
    if(d)return json({error:'authentication_required'},401);
    return json(await dispatch());
   }
   const token=/^Bearer (\S{20,8192})$/.exec(request.headers.get('authorization')||'')?.[1],actor=token?await deps.authenticate(token):null;
   if(!actor)throw new AppError('authentication_required',401);
   const input=await readJSON(request);if(Object.keys(input).some(k=>!['action','data'].includes(k)))throw new AppError('invalid_request');
   const data=object(input.data||{}),args={p_actor:actor.id,p_session:actor.session_id,p_action:input.action,p_data:data};
   if(actions.has(input.action))return json(await rpc('mbn_workspace_action',args));
   if(['test_leads_list','test_applications_list'].includes(input.action))return json(await rpc('mbn_workspace_tests',{p_actor:actor.id,p_session:actor.session_id,p_kind:input.action==='test_leads_list'?'LEADS':'APPLICATIONS',p_data:data}));
   if(input.action==='link_create'){
    if(!UUID.test(data.id))throw new AppError('invalid_request');
    const detail=object(await rpc('mbn_workspace_action',{...args,p_action:'lead_detail'}));
    if(detail.can_manage!==true)throw new AppError('access_denied',403);
    if(detail.lead.is_test)throw new AppError('test_link_unavailable',422);
    return json(await links(data.id));
   }
   // The following actions require a live owner session, not merely a logged-in account.
   if(['provider_status','provider_check','provider_webhook_setup','test_send','dispatch'].includes(input.action)){
    const settings=await rpc('mbn_workspace_action',{...args,p_action:'settings_get',p_data:{}});
    if(input.action==='provider_status')return json({settings,credentials_configured:deps.transport.configured});
    const group=senderGroup(data.sender_group??'MBN_GLOBAL');
    if(input.action==='provider_check'){const {inspection}=await check(group);return json({inspection,credentials_configured:deps.transport.configured});}
    if(input.action==='provider_webhook_setup'){
     const checked=await check(group);if(!checked.inspection.account_sending_enabled)throw new AppError(checked.inspection.error||'sender_not_ready',422);
     if(!deps.transport.configureWebhook)throw new AppError('brevo_webhook_setup_failed',422);
     const secret=await rpc('mbn_runtime_key',{p_name:'brevo_webhook'});if(typeof secret!=='string'||secret.length<80)throw Error('webhook_secret_unavailable');
     try{const configured=await deps.transport.configureWebhook(secret);await rpc('mbn_brevo_webhook_configured',{p_id:configured.id});return json({configured:true});}
     catch(error){if(error instanceof Error&&/^brevo_[a-z_]+$/.test(error.message))throw new AppError(error.message,422);throw error;}
    }
    if(input.action==='test_send'){
     const checked=await check(group);if(!checked.inspection.sender_verified||!checked.inspection.account_sending_enabled)throw new AppError(checked.inspection.error||'sender_not_ready',422);
     const prepared=object(await rpc('mbn_workspace_action',{...args,p_action:'mail_test_prepare',p_data:{sender_group:group}}));return json(await dispatch(prepared.id,group));
    }
    return json(await dispatch(undefined,data.sender_group?group:undefined));
   }
   if(input.action==='document_download'){
    if(!UUID.test(data.id))throw new AppError('invalid_request');
    const doc=object(await rpc('mbn_workspace_document',{p_actor:actor.id,p_session:actor.session_id,p_document:data.id}));
    if(!['mbn-native-test','mbn-admissions'].includes(doc.bucket)||!/^[-a-f0-9]{36}\/[A-Z_]+\.(pdf|png|jpg)$/.test(doc.object_path))throw Error('invalid_path');
    const bytes=await deps.download(doc.bucket,doc.object_path);
    if(bytes.length>5242880||await digest(bytes)!==doc.sha256)throw Error('integrity_failure');
    return new Response(new Uint8Array(bytes).buffer,{headers:{...cors,'Content-Type':'application/octet-stream','Content-Security-Policy':"sandbox; default-src 'none'",'Content-Disposition':`attachment; filename="document"; filename*=UTF-8''${encodeURIComponent(doc.original_name).replace(/['()*]/g,c=>'%'+c.charCodeAt(0).toString(16))}`}});
   }
   throw new AppError('unknown_action');
  }catch(error){if(error instanceof AppError)return json({error:error.code},error.status);return json({error:'service_unavailable'},503);}
 };
}
