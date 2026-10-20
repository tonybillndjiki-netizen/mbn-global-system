import {AppError,object,json,readJSON,rpcError,type Actor} from '../mbn-workspace/handler.ts';
import {MetaError,META_ID,hmac,constantEqual,boundedBytes,type MetaLead} from './graph.ts';
type Reply={data:unknown;error:{code?:string;message?:string}|null};
export type Dependencies={
 authenticate(token:string):Promise<Actor|null>;rpc(name:string,args:Record<string,unknown>):PromiseLike<Reply>;
 appSecret?:string;verifyToken?:string;
 graph:{configured:boolean;hasToken(page:string):boolean;status():Record<string,boolean>;read(page:string,id:string,form:string):Promise<MetaLead>};
};
const webhookHeaders={'Cache-Control':'no-store','X-Content-Type-Options':'nosniff','Content-Type':'text/plain; charset=utf-8'};
const plain=(body:string,status=200)=>new Response(body,{status,headers:webhookHeaders});
export function webhookEvents(value:any){
 if(!value||typeof value!=='object'||Array.isArray(value))throw new MetaError('invalid_meta_event');
 if(value.object!=='page')return [];
 if(!Array.isArray(value.entry)||value.entry.length>100)throw new MetaError('invalid_meta_event');
 const events:{page_id:string;form_id:string;leadgen_id:string}[]=[];
 for(const entry of value.entry){
  if(!entry||typeof entry.id!=='string'||!META_ID.test(entry.id)||!Array.isArray(entry.changes)||entry.changes.length>100)throw new MetaError('invalid_meta_event');
  for(const change of entry.changes){
   if(change?.field!=='leadgen')continue;const v=change.value;
   if(!v||typeof v.leadgen_id!=='string'||!META_ID.test(v.leadgen_id)||typeof v.form_id!=='string'||!META_ID.test(v.form_id)
    ||(v.page_id!==undefined&&v.page_id!==entry.id)||events.length>=100)throw new MetaError('invalid_meta_event');
   events.push({page_id:entry.id,form_id:v.form_id,leadgen_id:v.leadgen_id});
  }
 }
 return events;
}
export function createHandler(deps:Dependencies){
 async function rpc(name:string,args:Record<string,unknown>={}){const r=await deps.rpc(name,args);if(r.error)rpcError(r.error);return r.data;}
 async function process(){
  if(!deps.graph.configured)throw new AppError('meta_configuration_missing',422);
  const outcomes:{id:string;status:string}[]=[],start=Date.now();
  for(let i=0;i<10&&Date.now()-start<35000;i++){
   const raw=await rpc('mbn_meta_claim');if(raw===null)break;const job=object(raw);let result;
   try{
    const lead=await deps.graph.read(job.page_id,job.leadgen_id,job.form_id);
    result=await rpc('mbn_meta_finish',{p_id:job.id,p_attempt:job.attempt_id,p_revision:job.route_revision,p_lead:lead,p_error:null,p_retryable:false});
   }catch(error){
    // Provider text and access tokens never enter diagnostics or the browser.
    const known=error instanceof MetaError;
    result=await rpc('mbn_meta_finish',{p_id:job.id,p_attempt:job.attempt_id,p_revision:job.route_revision,p_lead:null,p_error:known?error.code:'meta_processing_failed',p_retryable:known?error.retryable:true});
   }
   outcomes.push({id:job.id,status:typeof result==='object'&&result?String((result as any).status):'STALE'});
  }
  return {processed:outcomes.length,outcomes};
 }
 return async(request:Request)=>{
  if(request.method==='OPTIONS')return new Response(null,{status:204,headers:{'Access-Control-Allow-Origin':'*','Access-Control-Allow-Headers':'authorization,apikey,content-type,x-mbn-worker','Access-Control-Allow-Methods':'POST,GET,OPTIONS'}});
  try{
   if(request.method==='GET'){
    const q=new URL(request.url).searchParams,expected=deps.verifyToken||'';
    if(expected.length<16||expected.length>256)throw new AppError('meta_configuration_missing',503);
    const token=q.get('hub.verify_token')||'',challenge=q.get('hub.challenge')||'';
    if(q.get('hub.mode')!=='subscribe'||token.length>256||!constantEqual(token,expected)||!/^[a-zA-Z0-9_-]{1,200}$/.test(challenge))throw new AppError('access_denied',403);
    return plain(challenge);
   }
   if(request.method!=='POST')return plain('method_not_allowed',405);
   const worker=request.headers.get('x-mbn-worker');
   if(worker!==null){
    if(worker.length<80||worker.length>200)throw new AppError('authentication_required',401);
    const expected=String(await rpc('mbn_runtime_key',{p_name:'worker'}));
    if(!constantEqual(worker,expected))throw new AppError('authentication_required',401);
    return json(await process());
   }
   const authorization=request.headers.get('authorization');
   if(authorization){
    const token=/^Bearer (\S{20,8192})$/.exec(authorization)?.[1],actor=token?await deps.authenticate(token):null;
    if(!actor)throw new AppError('authentication_required',401);
    const input=await readJSON(request,16384);if(Object.keys(input).some(k=>!['action','data'].includes(k)))throw new AppError('invalid_request');
    const data=object(input.data||{}),actions:Record<string,string>={meta_context:'context',meta_route_save:'save',meta_retry:'retry',meta_process:'context'};
    if(typeof input.action!=='string'||!Object.hasOwn(actions,input.action))throw new AppError('unknown_action');
    const result=await rpc('mbn_meta_admin_action',{p_actor:actor.id,p_session:actor.session_id,p_action:actions[input.action],p_data:data});
    if(input.action==='meta_process')return json(await process());
    if(input.action==='meta_context'){
     const context=object(result);context.routes=context.routes.map((r:any)=>({...r,page_token_configured:deps.graph.hasToken(r.page_id)}));
     return json({...context,credentials:{...deps.graph.status(),verify_token_configured:(deps.verifyToken||'').length>=16&&(deps.verifyToken||'').length<=256}});
    }
    return json(result);
   }
   const signature=request.headers.get('x-hub-signature-256')||'',secret=deps.appSecret||'';
   if(secret.length<16)throw new AppError('meta_configuration_missing',503);
   if(!/^sha256=[a-f0-9]{64}$/.test(signature))throw new AppError('access_denied',403);
   const bytes=await boundedBytes(request,262144);
   if(!constantEqual(signature,'sha256='+await hmac(secret,bytes)))throw new AppError('access_denied',403);
   let payload;try{payload=JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes));}catch{throw new AppError('invalid_meta_event');}
   const events=webhookEvents(payload);
   if(events.length)await rpc('mbn_meta_receive',{p_events:events});
   return plain('EVENT_RECEIVED');
  }catch(error){
   if(error instanceof AppError)return json({error:error.code},error.status);
   if(error instanceof MetaError)return json({error:error.code},400);
   return json({error:'service_unavailable'},503);
  }
 };
}
