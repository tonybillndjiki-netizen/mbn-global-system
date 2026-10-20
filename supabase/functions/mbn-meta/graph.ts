export class MetaError extends Error{
 constructor(public code:string,public retryable=false){super(code);}
}
export const META_ID=/^[0-9]{5,30}$/;
export type MetaLead={id:string;form_id:string;created_time:string;fields:Record<string,string[]>};
export async function hmac(secret:string,value:Uint8Array){
 const key=await crypto.subtle.importKey('raw',new TextEncoder().encode(secret),{name:'HMAC',hash:'SHA-256'},false,['sign']);
 return [...new Uint8Array(await crypto.subtle.sign('HMAC',key,new Uint8Array(value)))].map(n=>n.toString(16).padStart(2,'0')).join('');
}
export function constantEqual(a:string,b:string){let diff=a.length^b.length;for(let i=0;i<Math.max(a.length,b.length);i++)diff|=(a.charCodeAt(i)||0)^(b.charCodeAt(i)||0);return diff===0;}
export async function boundedBytes(request:Request|Response,max:number){
 if(!request.body||Number(request.headers.get('content-length')||0)>max)throw new MetaError('meta_payload_too_large');
 const reader=request.body.getReader(),parts:Uint8Array[]=[];let size=0;
 try{for(;;){const {done,value}=await reader.read();if(done)break;size+=value.length;if(size>max){await reader.cancel();throw new MetaError('meta_payload_too_large');}parts.push(value);}}
 finally{reader.releaseLock();}
 const out=new Uint8Array(size);let at=0;for(const part of parts){out.set(part,at);at+=part.length;}return out;
}
export function createMeta(options:{appSecret?:string;version?:string;pageTokens?:string},fetcher:typeof fetch=fetch){
 const secret=options.appSecret||'',version=options.version||'';let tokens:Record<string,unknown>={};
 try{const parsed=JSON.parse(options.pageTokens||'{}');if(parsed&&typeof parsed==='object'&&!Array.isArray(parsed))tokens=parsed;}catch{}
 const hasToken=(page:string)=>META_ID.test(page)&&Object.hasOwn(tokens,page)&&typeof tokens[page]==='string'&&(tokens[page] as string).length>=20;
 const configured=secret.length>=16&&/^v[0-9]{1,2}\.0$/.test(version);
 return {configured,hasToken,status:()=>({app_secret_configured:secret.length>=16,graph_version_configured:/^v[0-9]{1,2}\.0$/.test(version)}),
  async read(page:string,id:string,form:string):Promise<MetaLead>{
   if(!configured)throw new MetaError('meta_configuration_missing');
   if(!META_ID.test(id)||!META_ID.test(page)||!META_ID.test(form))throw new MetaError('invalid_meta_event');
   if(!hasToken(page))throw new MetaError('meta_page_token_missing');
   const token=tokens[page] as string,url=new URL('https://graph.facebook.com/'+version+'/'+id);
   url.searchParams.set('fields','id,form_id,created_time,field_data');
   url.searchParams.set('appsecret_proof',await hmac(secret,new TextEncoder().encode(token)));
   let response:Response;
   try{response=await fetcher(url,{method:'GET',headers:{Authorization:'Bearer '+token,Accept:'application/json'},redirect:'error',signal:AbortSignal.timeout(8000)});}
   catch{throw new MetaError('meta_connection_unavailable',true);}
   let value:any;try{value=JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(await boundedBytes(response,262144)));}
   catch(error){if(error instanceof MetaError)throw error;throw new MetaError('meta_invalid_response',response.status===429||response.status>=500);}
   if(!response.ok||value?.error){
    if(response.status===429||response.status>=500||[1,2,4,17,32,613].includes(value?.error?.code))throw new MetaError('meta_temporarily_unavailable',true);
    if(response.status===401||value?.error?.code===190)throw new MetaError('meta_token_rejected');
    if(response.status===403||[10,200].includes(value?.error?.code))throw new MetaError('meta_permission_denied');
    throw new MetaError('meta_lead_unavailable');
   }
   if(value?.id!==id||value?.form_id!==form||typeof value.created_time!=='string'||!Number.isFinite(Date.parse(value.created_time))
    ||!Array.isArray(value.field_data)||value.field_data.length>100)throw new MetaError('meta_identity_mismatch');
   const fields:Record<string,string[]>=Object.create(null);
   for(const field of value.field_data){
    if(!field||typeof field.name!=='string'||!field.name.length||field.name.length>100||Object.hasOwn(fields,field.name)
     ||!Array.isArray(field.values)||field.values.length>20||field.values.some((v:unknown)=>typeof v!=='string'||v.length>3000))throw new MetaError('meta_invalid_response');
    fields[field.name]=field.values;
   }
   return {id,form_id:form,created_time:new Date(value.created_time).toISOString(),fields};
  }
 };
}
