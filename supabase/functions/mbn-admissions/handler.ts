import {parseSubmission,InputError,digest,type NativeFile} from '../mbn-form-ingest/handler.ts';
import {AppError,object,json,readJSON,rpcError,verifyCapability,capability,ORIGIN,UUID} from '../mbn-workspace/handler.ts';
type Reply={data:unknown;error:{code?:string;message?:string}|null};
export type Dependencies={rpc(name:string,args:Record<string,unknown>):PromiseLike<Reply>;upload(path:string,file:NativeFile):Promise<void>};
const cors={'Access-Control-Allow-Origin':'*','Access-Control-Allow-Headers':'apikey,content-type,x-mbn-admission,x-mbn-correction','Access-Control-Allow-Methods':'POST,OPTIONS','Cache-Control':'no-store'};
export function createHandler(deps:Dependencies){
 async function rpc(name:string,args:Record<string,unknown>){const r=await deps.rpc(name,args);if(r.error)rpcError(r.error);return r.data;}
 let keyPromise:Promise<string>|undefined;
 const key=()=>keyPromise??=(async()=>{const result=await rpc('mbn_runtime_key',{p_name:'link'});if(typeof result!=='string'||result.length<80)throw Error('key_unavailable');return result;})().catch(error=>{keyPromise=undefined;throw error;});
 return async(request:Request)=>{
  if(request.method==='OPTIONS')return new Response(null,{status:204,headers:cors});
  if(request.method==='HEAD')return new Response(null,{status:204,headers:cors});
  if(request.method==='GET'){
   try{
    const url=new URL(request.url),slug=url.searchParams.get('ecole');
    if(!slug||!/^[a-z0-9-]{2,50}$/.test(slug)||[...url.searchParams.keys()].some(k=>k!=='ecole'))throw new AppError('link_unavailable',404);
    const secret=await key(),ip=request.headers.get('x-forwarded-for')?.split(',')[0].trim()||'unknown';
    const hashKey=await crypto.subtle.importKey('raw',new TextEncoder().encode(secret),{name:'HMAC',hash:'SHA-256'},false,['sign']);
    const hash=new Uint8Array(await crypto.subtle.sign('HMAC',hashKey,new TextEncoder().encode('public-entry:'+new Date().toISOString().slice(0,10)+':'+ip)));
    const clientHash=Array.from(hash,n=>n.toString(16).padStart(2,'0')).join('');
    const entry=object(await rpc('mbn_school_entry',{p_slug:slug,p_client_hash:clientHash}));
    if(!UUID.test(entry.id)||entry.slug!==slug)throw Error('invalid_entry');
    const token=await capability(secret,entry.id,'admission');
    return new Response(null,{status:303,headers:{...cors,Location:ORIGIN+'/forms/'+slug+'.html#'+token,'Referrer-Policy':'no-referrer'}});
   }catch(error){if(error instanceof AppError)return json({error:error.code},error.status);return json({error:'service_unavailable'},503);}
  }
  if(request.method!=='POST')return json({error:'method_not_allowed'},405);
  try{
   const oneClick=new URL(request.url).searchParams.get('unsubscribe');
   if(oneClick){
    const id=await verifyCapability(await key(),oneClick,'unsubscribe');
    if(Number(request.headers.get('content-length')||0)>1024)throw new AppError('request_too_large',413);
    await rpc('mbn_candidate_context',{p_link:id,p_action:'unsubscribe'});return json({success:true});
   }
   const header=request.headers.get('x-mbn-admission'),multipart=request.headers.get('content-type')?.startsWith('multipart/form-data');
   const correction=request.headers.get('x-mbn-correction');
   if(multipart&&correction){
    const id=await verifyCapability(await key(),correction,'correction');
    await rpc('mbn_correction_info',{p_request:id});
    const submission=await parseSubmission(request,'CORRECTION');
    const prepared=object(await rpc('mbn_correction_prepare',{p_request:id,p_manifest:submission.manifest,p_fingerprint:submission.fingerprint}));
    if(!UUID.test(prepared.submission_id)||typeof prepared.completed!=='boolean')throw Error('invalid_reservation');
    if(!prepared.completed)for(const file of submission.files)await deps.upload(`${prepared.submission_id}/${file.manifest.kind}.${file.manifest.extension}`,file);
    const receipt=object(await rpc('mbn_correction_complete',{p_request:id,p_submission:prepared.submission_id}));
    if(receipt.success!==true||typeof receipt.duplicated!=='boolean')throw Error('invalid_receipt');
    return json(receipt,receipt.duplicated?200:201);
   }
   if(multipart){
    // Verify the capability and active school before reading candidate files.
    const id=await verifyCapability(await key(),header,'admission');
    await rpc('mbn_candidate_context',{p_link:id,p_action:'info'});
    const submission=await parseSubmission(request,'CANDIDATE');
    const prepared=object(await rpc('mbn_candidate_prepare',{p_link:id,p_payload:submission.payload,p_details:submission.details,p_manifest:submission.manifest,p_fingerprint:submission.fingerprint}));
    if(!UUID.test(prepared.submission_id)||typeof prepared.completed!=='boolean')throw Error('invalid_reservation');
    if(!prepared.completed)for(const file of submission.files)await deps.upload(`${prepared.submission_id}/${file.manifest.kind}.${file.manifest.extension}`,file);
    const receipt=object(await rpc('mbn_candidate_complete',{p_link:id,p_submission:prepared.submission_id}));
    if(receipt.success!==true||receipt.reference!==submission.payload.reference_dossier||!UUID.test(receipt.application_id))throw Error('invalid_receipt');
    return json(receipt,receipt.duplicated?200:201);
   }
   const input=await readJSON(request,2048);
   if(input.action==='correction_info'){
    if(Object.keys(input).some(k=>!['action','token'].includes(k)))throw new AppError('invalid_request');
    const id=await verifyCapability(await key(),input.token,'correction');
    return json(await rpc('mbn_correction_info',{p_request:id}));
   }
   if(Object.keys(input).some(k=>!['action','token'].includes(k))||!['info','engage','unsubscribe'].includes(input.action))throw new AppError('invalid_request');
   const id=await verifyCapability(await key(),input.token,input.action==='unsubscribe'?'unsubscribe':'admission');
   const result=object(await rpc('mbn_candidate_context',{p_link:id,p_action:input.action}));
   return input.action==='unsubscribe'?json({success:true}):json({school_code:result.school_code,school_name:result.school_name,slug:result.slug,reference:'MBNAPP-'+id,submitted:result.submitted});
  }catch(error){if(error instanceof AppError||error instanceof InputError)return json({error:error.code},error.status);return json({error:'service_unavailable'},503);}
 };
}
export {digest};
