import {AppError,json,object,readJSON,rpcError,type Actor} from '../mbn-workspace/handler.ts';
import {ScanError} from './scanner.ts';
type Reply={data:unknown;error:{code?:string;message?:string}|null};
export type Dependencies={authenticate(token:string):Promise<Actor|null>;rpc(name:string,args:Record<string,unknown>):PromiseLike<Reply>;
 download(bucket:string,path:string):Promise<Uint8Array>;scanner:{configured:boolean;scan(bytes:Uint8Array,sha:string):Promise<{status:'CLEAN'|'INFECTED';engine:string}>}};
function equal(a:string,b:string){let d=a.length^b.length;for(let i=0;i<a.length;i++)d|=a.charCodeAt(i)^(b.charCodeAt(i)||0);return d===0;}
export function createHandler(deps:Dependencies){
 async function rpc(name:string,args:Record<string,unknown>={}){const r=await deps.rpc(name,args);if(r.error)rpcError(r.error);return r.data;}
 async function process(){
  if(!deps.scanner.configured)throw new AppError('scanner_configuration_missing',422);
  const outcomes=[];
  for(let i=0;i<2;i++){
   const raw=await rpc('mbn_scan_claim');if(raw===null)break;const job=object(raw);let result;
   try{
    if(!['mbn-admissions','mbn-native-test'].includes(job.bucket)||typeof job.object_path!=='string'||!/^[a-f0-9-]{36}\/[A-Z_]+\.(pdf|png|jpg)$/.test(job.object_path))throw new ScanError('document_integrity_failed');
    const bytes=await deps.download(job.bucket,job.object_path);if(bytes.length!==job.byte_size)throw new ScanError('document_integrity_failed');
    const verdict=await deps.scanner.scan(bytes,job.sha256);
    result=await rpc('mbn_scan_finish',{p_id:job.id,p_attempt:job.attempt_id,p_sha256:job.sha256,p_status:verdict.status,p_engine:verdict.engine,p_error:null});
   }catch(error){result=await rpc('mbn_scan_finish',{p_id:job.id,p_attempt:job.attempt_id,p_sha256:job.sha256,p_status:'ERROR',p_engine:null,p_error:error instanceof ScanError?error.code:'scanner_unavailable'});}
   outcomes.push({id:job.id,status:object(result).status});
  }
  return {processed:outcomes.length,outcomes};
 }
 return async(request:Request)=>{
  if(request.method==='OPTIONS')return new Response(null,{status:204,headers:{'Access-Control-Allow-Origin':'*','Access-Control-Allow-Headers':'authorization,apikey,content-type,x-mbn-worker','Access-Control-Allow-Methods':'POST,OPTIONS'}});
  if(request.method==='GET'&&new URL(request.url).search==='?health=1')return json({service:'mbn-antivirus',configured:deps.scanner.configured});
  if(request.method!=='POST')return json({error:'method_not_allowed'},405);
  try{
   const worker=request.headers.get('x-mbn-worker');
   if(worker!==null){if(worker.length<80||worker.length>200||!equal(worker,String(await rpc('mbn_runtime_key',{p_name:'worker'}))))throw new AppError('authentication_required',401);return json(await process());}
   const token=/^Bearer (\S{20,8192})$/.exec(request.headers.get('authorization')||'')?.[1],actor=token?await deps.authenticate(token):null;
   if(!actor)throw new AppError('authentication_required',401);
   const input=await readJSON(request,4096),data=object(input.data||{}),actions:Record<string,string>={scan_context:'context',scan_save:'save',scan_retry:'retry',scan_process:'context'};
   if(Object.keys(input).some(k=>!['action','data'].includes(k))||typeof input.action!=='string'||!Object.hasOwn(actions,input.action))throw new AppError('invalid_request');
   // Authorization is checked before reporting configuration or touching private files.
   if(input.action==='scan_save'&&data.enabled===true&&!deps.scanner.configured){await rpc('mbn_scan_admin_action',{p_actor:actor.id,p_session:actor.session_id,p_action:'context',p_data:{}});throw new AppError('scanner_configuration_missing',422);}
   const result=await rpc('mbn_scan_admin_action',{p_actor:actor.id,p_session:actor.session_id,p_action:actions[input.action],p_data:data});
   if(input.action==='scan_process')return json(await process());
   return json({...object(result),configured:deps.scanner.configured});
  }catch(error){if(error instanceof AppError)return json({error:error.code},error.status);return json({error:'service_unavailable'},503);}
 };
}
