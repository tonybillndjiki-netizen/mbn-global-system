import {AppError,json,object,rpcError,UUID} from '../mbn-workspace/handler.ts';
import {digest} from '../mbn-form-ingest/handler.ts';
type Reply={data:unknown;error:{code?:string;message?:string}|null};
type Dependencies={secret():Promise<string>;rpc(name:string,args:Record<string,unknown>):PromiseLike<Reply>};
const supported=new Set(['request','sent','delivered','hard_bounce','soft_bounce','blocked','spam','invalid_email','deferred','unsubscribed','error']);
export function normalize(value:unknown){
 const row=object(value);const event=String(row.event||'');
 if(!supported.has(event))return null;
 const provider=String(row['message-id']||'');const email=String(row.email||'').toLowerCase();
 if(provider.length<1||provider.length>199||!email.includes('@')||email.length>254)throw new AppError('invalid_event');
 let tags=Array.isArray(row.tags)?row.tags:Array.isArray(row.tag)?row.tag:[];
 if(!tags.length&&typeof row.tag==='string'&&row.tag.length<10000){try{const parsed=JSON.parse(row.tag);if(Array.isArray(parsed))tags=parsed;}catch{}}
 const ids=tags.filter(t=>typeof t==='string'&&t.startsWith('mbn_')&&UUID.test(t.slice(4))).map(t=>t.slice(4));
 const header=/^mbn_message_id:([a-f0-9-]{36})$/.exec(String(row['X-Mailin-custom']||''))?.[1];
 if(header&&UUID.test(header))ids.push(header);
 if(new Set(ids).size>1)throw new AppError('invalid_event');
 return {event,provider_id:provider,email,message_id:ids[0]||null,
  event_id:String(row.id??'').slice(0,100),timestamp:String(row.ts_event??row.ts??row.ts_epoch??'').slice(0,30)};
}
export function createHandler(deps:Dependencies){
 return async(request:Request)=>{
  if(request.method!=='POST')return json({error:'method_not_allowed'},405);
  try{
   const expected=await deps.secret(),token=/^Bearer (\S{80,200})$/.exec(request.headers.get('authorization')||'')?.[1]||'';
   let difference=token.length^expected.length;for(let i=0;i<Math.max(token.length,expected.length);i++)difference|=(token.charCodeAt(i)||0)^(expected.charCodeAt(i)||0);
   if(expected.length<80||difference)throw new AppError('invalid_webhook_authentication',403);
   if(!request.body||Number(request.headers.get('content-length')||0)>1048576)throw new AppError('invalid_event');
   const reader=request.body.getReader();const chunks:Uint8Array[]=[];let size=0;
   try{for(;;){const {done,value}=await reader.read();if(done)break;size+=value.length;if(size>1048576){await reader.cancel();throw new AppError('request_too_large',413);}chunks.push(value);}}finally{reader.releaseLock();}
   const bytes=new Uint8Array(size);let offset=0;for(const c of chunks){bytes.set(c,offset);offset+=c.length;}
   let input:unknown;try{input=JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes));}catch{throw new AppError('invalid_event');}
   const rows=Array.isArray(input)?input:[input];if(!rows.length||rows.length>1000)throw new AppError('invalid_event');
   const events=rows.map(normalize).filter(e=>e!==null);
   for(const event of events){
    const key=await digest(new TextEncoder().encode(JSON.stringify([event.provider_id,event.event,event.event_id,event.timestamp,event.email])));
    const r=await deps.rpc('mbn_brevo_event',{p_key:key,p_event:event});
    // Brevo discards 5xx responses; 429 preserves its documented retry mechanism.
    if(r.error?.message==='message_pending')return json({error:'message_pending'},429);
    if(r.error)rpcError(r.error);
   }
   return json({success:true});
  }catch(error){if(error instanceof AppError)return json({error:error.code},error.status);return json({error:'service_unavailable'},429);}
 };
}
