import {AppError,object,json,readJSON,rpcError,UUID,renderMessage,type Actor} from '../mbn-workspace/handler.ts';
import {digest} from '../mbn-form-ingest/handler.ts';
import type {Sender,Inspection,Outcome,Attachment} from '../mbn-workspace/ses.ts';
import {brandFor} from '../../../assets/branding.js';
import {makeLetterPDF} from './pdf.ts';
import {admissionMail} from './template.ts';
type Asset={key:string;bucket:string;object_path:string;sha256:string;byte_size:number;mime_type:string;filename:string};
type Reply={data:unknown;error:{code?:string;message?:string}|null};
export type Dependencies={authenticate(token:string):Promise<Actor|null>;rpc(name:string,args:Record<string,unknown>):PromiseLike<Reply>;download(bucket:string,path:string):Promise<Uint8Array>;upload(bucket:string,path:string,bytes:Uint8Array,mime:string):Promise<void>;transport:{configured:boolean;inspect(sender:Sender):Promise<Inspection>;send(sender:Sender,message:{id:string;recipient:string;subject:string;text:string;html:string;attachments?:Attachment[]}):Promise<Outcome>}};
const headers={'Access-Control-Allow-Origin':'*','Access-Control-Allow-Headers':'authorization,apikey,content-type,x-mbn-asset','Access-Control-Allow-Methods':'GET,POST,OPTIONS','Access-Control-Expose-Headers':'Content-Disposition','Cache-Control':'no-store','X-Content-Type-Options':'nosniff'};
function binary(bytes:Uint8Array,mime:string,name:string){return new Response(new Uint8Array(bytes).buffer,{headers:{...headers,'Content-Type':mime,'Content-Security-Policy':"sandbox; default-src 'none'",'Content-Disposition':`attachment; filename="document"; filename*=UTF-8''${encodeURIComponent(name).replace(/['()*]/g,c=>'%'+c.charCodeAt(0).toString(16))}`}});}
export function base64(bytes:Uint8Array){let out='';for(let i=0;i<bytes.length;i+=32768)out+=String.fromCharCode(...bytes.subarray(i,i+32768));return btoa(out);}
async function readBytes(request:Request,max:number){
 if(!request.body||Number(request.headers.get('content-length')||0)>max)throw new AppError('request_too_large',413);
 const reader=request.body.getReader(),chunks:Uint8Array[]=[];let size=0;
 try{for(;;){const {done,value}=await reader.read();if(done)break;size+=value.length;if(size>max){await reader.cancel();throw new AppError('request_too_large',413);}chunks.push(value);}}finally{reader.releaseLock();}
 const out=new Uint8Array(size);let at=0;for(const part of chunks){out.set(part,at);at+=part.length;}return out;
}
export function createHandler(deps:Dependencies){
 async function rpc(name:string,args:Record<string,unknown>={}){const r=await deps.rpc(name,args);if(r.error)rpcError(r.error);return r.data;}
 async function asset(a:Asset){
  if(!['mbn-mail-assets','mbn-school-branding'].includes(a.bucket)||!/^[-a-z0-9_/]+\.(pdf|jpg|png|ttf)$/.test(a.object_path)||!/^[-a-z0-9_.]+$/.test(a.filename))throw Error('invalid_asset');
  const bytes=await deps.download(a.bucket,a.object_path);if(bytes.length!==a.byte_size||bytes.length>5242880||await digest(bytes)!==a.sha256)throw Error('asset_integrity_failure');return bytes;
 }
 async function pdf(row:Record<string,any>){const bytes=await deps.download('mbn-admission-letters',row.object_path);if(bytes.length!==row.pdf_bytes||bytes.length>5242880||await digest(bytes)!==row.pdf_sha256)throw Error('letter_integrity_failure');return bytes;}
 return async(request:Request)=>{
  if(request.method==='OPTIONS')return new Response(null,{status:204,headers});
  if(request.method==='GET'&&new URL(request.url).search==='?health=1')return json({service:'mbn-letters',version:'0.8.0',provider:'BREVO',credentials_configured:deps.transport.configured});
  if(request.method!=='POST')return json({error:'method_not_allowed'},405);
  try{
   const ticket=request.headers.get('x-mbn-asset');
   if(ticket){
    const key=new URL(request.url).searchParams.get('asset');if(!key||!/^[a-z0-9_-]{3,80}$/.test(key))throw new AppError('invalid_request');
    const a=object(await rpc('mbn_asset_install_context',{p_token:ticket,p_key:key,p_complete:false})) as Asset;
    const bytes=await readBytes(request,Math.min(5242880,a.byte_size));
    if(bytes.length!==a.byte_size||await digest(bytes)!==a.sha256)throw new AppError('asset_integrity_failure',422);
    await deps.upload(a.bucket,a.object_path,bytes,a.mime_type);
    await rpc('mbn_asset_install_context',{p_token:ticket,p_key:key,p_complete:true});return json({installed:true,key});
   }
   const token=/^Bearer (\S{20,8192})$/.exec(request.headers.get('authorization')||'')?.[1],actor=token?await deps.authenticate(token):null;
   if(!actor)throw new AppError('authentication_required',401);
   const input=await readJSON(request,32768);if(Object.keys(input).some(k=>!['action','data'].includes(k)))throw new AppError('invalid_request');
   const data=object(input.data||{});
   const action=async(p_action:string,p_data:Record<string,unknown>=data)=>rpc('mbn_letter_action',{p_actor:actor.id,p_session:actor.session_id,p_action,p_data});
   if(input.action==='letter_context')return json(await action('context'));
   if(input.action==='letter_asset'){
    const a=await action('asset');if(!a)throw new AppError('asset_not_found',404);const row=object(a)as Asset;return binary(await asset(row),row.mime_type,row.filename);
   }
   if(input.action==='letter_generate'){
    if(!UUID.test(data.request_id)||!UUID.test(data.application_id))throw new AppError('invalid_request');
    let row=object(await action('prepare'));
    if(!row.generated_at){
     const all=row.assets as Asset[],byKey=new Map(all.map(a=>[a.key,a]));
     const load=async(key:string)=>{const value=byKey.get(key);if(!value)throw new AppError('asset_pending',422);return asset(value);};
     const brand=brandFor(row.school_code);
     const [regular,bold,logo,schoolLogo]=await Promise.all([load('font_regular'),load('font_bold'),load('logo_'+brand.logo),row.fields.logo_variant==='CAMPUS_AND_SCHOOL'?load('logo_'+brand.schoolLogo):Promise.resolve(undefined)]);
     const bytes=await makeLetterPDF(row.fields,{regular,bold,logo,schoolLogo},row.created_at);
     if(bytes.length>5242880)throw new AppError('request_too_large',413);
     await deps.upload('mbn-admission-letters',row.object_path,bytes,'application/pdf');
     row=object(await action('generated',{id:row.id,sha256:await digest(bytes),byte_size:bytes.length}));
    }
    return json({id:row.id,generated_at:row.generated_at,reference:row.fields.reference});
   }
   if(input.action==='letter_download'){
    const row=object(await action('download'));if(!row.generated_at)throw new AppError('documents_pending',409);
    return binary(await pdf(row),'application/pdf','admission-'+row.fields.reference+'.pdf');
   }
   if(input.action==='letter_send'){
    // All content and files are prepared before taking the irreversible send lease.
    const row=object(await action('download'));
    if(!row.generated_at)throw new AppError('documents_pending',409);
    const settings=object(await rpc('mbn_mail_profile_settings',{p_school:row.school_code}));
    const inspection=await deps.transport.inspect(settings as Sender);
    await rpc('mbn_mail_profile_checked',{p_group:settings.code,p_revision:settings.revision,p_result:inspection});
    if(!inspection.sender_verified||!inspection.production_access||!inspection.account_sending_enabled||inspection.remaining<=0)throw new AppError(inspection.error||'sender_not_ready',422);
    const attachments:Attachment[]=[{filename:'admission-'+row.fields.reference.replace(/[^a-zA-Z0-9-]/g,'_')+'.pdf',mime_type:'application/pdf',base64:base64(await pdf(row))}];
    for(const a of row.assets as Asset[])if(row.attachments.includes(a.key))attachments.push({filename:a.filename,mime_type:a.mime_type,base64:base64(await asset(a))});
    const profileAction=(p_action:string)=>rpc('mbn_letter_profile_action',{p_actor:actor.id,p_session:actor.session_id,p_action,p_data:data});
    const claim=object(await profileAction('claim')),message=object(claim.message);
    if(!UUID.test(message.id)||!UUID.test(message.attempt_id))throw Error('invalid_claim');
    let outcome:Outcome;
    try{
     if(await rpc('mbn_letter_profile_action',{p_actor:actor.id,p_session:actor.session_id,p_action:'authorized',p_data:{id:row.id,attempt_id:message.attempt_id}})!==true)outcome={status:'FAILED',error:'authorization_changed'};
     else{
      if(!message.service_contact_email)throw new AppError('mail_route_missing',422);
      const sender=object(claim.sender);
      const rendered=renderMessage({school_code:row.school_code,lead:{full_name:row.fields.full_name},subject:'Votre admission · '+row.fields.school_name,body:admissionMail(row.fields),service_contact_email:message.service_contact_email});
      outcome=await deps.transport.send({...sender,reply_to:sender.from_email}as Sender,{id:message.id,recipient:row.fields.email,...rendered,attachments});
     }
    }catch{outcome={status:'UNCERTAIN',error:'brevo_acceptance_uncertain'};}
    await rpc('mbn_letter_finish',{p_id:message.id,p_attempt:message.attempt_id,p_status:outcome.status,p_provider_id:outcome.provider_id||null,p_error:outcome.error||null});
    return json({status:outcome.status,message_id:message.id});
   }
   throw new AppError('unknown_action');
  }catch(error){if(error instanceof AppError)return json({error:error.code},error.status);return json({error:'service_unavailable'},503);}
 };
}
