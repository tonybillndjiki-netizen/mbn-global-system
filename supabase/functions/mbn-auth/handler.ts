type Reply={data:unknown;error:{code?:string;message?:string}|null};
type Actor={id:string;session_id:string};
type Session={access_token:string;refresh_token:string;expires_in:number;token_type:string};
export type Dependencies={rpc(name:string,args:Record<string,unknown>):PromiseLike<Reply>;authenticate(token:string):Promise<Actor|null>;issue(userId:string,email:string):Promise<Session>};
const UUID=/^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/;
const headers={'Access-Control-Allow-Origin':'*','Access-Control-Allow-Headers':'authorization,apikey,content-type,x-client-info','Access-Control-Allow-Methods':'POST,OPTIONS','Content-Type':'application/json; charset=utf-8','Cache-Control':'no-store','X-Content-Type-Options':'nosniff'};
const json=(value:unknown,status=200)=>new Response(JSON.stringify(value),{status,headers});
export class InputError extends Error{constructor(public code:string,public status=400){super(code);}}
function record(value:unknown):Record<string,any>{if(!value||typeof value!=='object'||Array.isArray(value))throw new InputError('invalid_request');return value as Record<string,any>;}
export function username(value:unknown){
 if(typeof value!=='string')throw new InputError('invalid_username');
 const display=value.normalize('NFKC').trim().replace(/\s+/g,' ');
 const key=display.normalize('NFKD').replace(/[\u0300-\u036f]/g,'').toLowerCase();
 if(display.length>60||! /^[a-z0-9][a-z0-9 ._-]{1,58}[a-z0-9]$/.test(key))throw new InputError('invalid_username');
 return {display,key};
}
export function pin(value:unknown){if(typeof value!=='string'||value.length>12)throw new InputError('six_digits_required');const p=value.replace(/\s/g,'');if(!/^\d{6}$/.test(p))throw new InputError('six_digits_required');return p;}
const hex=(bytes:Uint8Array)=>Array.from(bytes,n=>n.toString(16).padStart(2,'0')).join('');
export async function hashPin(code:string,salt:string){
 if(!/^[a-f0-9]{32}$/.test(salt))throw Error('invalid_salt');
 const key=await crypto.subtle.importKey('raw',new TextEncoder().encode(code),'PBKDF2',false,['deriveBits']);
 return hex(new Uint8Array(await crypto.subtle.deriveBits({name:'PBKDF2',hash:'SHA-256',iterations:600000,salt:Uint8Array.from(salt.match(/../g)!,p=>parseInt(p,16))},key,256)));
}
function equal(a:string,b:string){let d=a.length^b.length;for(let i=0;i<Math.max(a.length,b.length);i++)d|=(a.charCodeAt(i)||0)^(b.charCodeAt(i)||0);return d===0;}
export function sessionId(token:string){try{const part=token.split('.')[1].replace(/-/g,'+').replace(/_/g,'/');const value=JSON.parse(atob(part.padEnd(Math.ceil(part.length/4)*4,'='))).session_id;return UUID.test(value)?value:null;}catch{return null;}}
async function body(request:Request){
 const length=request.headers.get('content-length');if(length&&(!/^\d+$/.test(length)||Number(length)>2048))throw new InputError('request_too_large',413);
 if(request.headers.get('content-type')?.split(';')[0].trim()!=='application/json'||!request.body)throw new InputError('json_required',415);
 const reader=request.body.getReader(),chunks:Uint8Array[]=[];let size=0;
 try{for(;;){const {done,value}=await reader.read();if(done)break;size+=value.length;if(size>2048){await reader.cancel();throw new InputError('request_too_large',413);}chunks.push(value);}}finally{reader.releaseLock();}
 const bytes=new Uint8Array(size);let at=0;for(const chunk of chunks){bytes.set(chunk,at);at+=chunk.length;}
 try{return record(JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes)));}catch{throw new InputError('invalid_request');}
}
export function createHandler(deps:Dependencies){
 async function rpc(name:string,args:Record<string,unknown>){const r=await deps.rpc(name,args);if(r.error){const code=r.error.message||'';if(['access_denied','session_revoked','reauthentication_required','access_changed','username_taken','invalid_access'].includes(code)&&/^PT(400|403|409)$/.test(r.error.code||''))throw new InputError(code,Number(r.error.code!.slice(2)));throw Error('service_unavailable');}return r.data;}
 async function verify(key:string,code:string){
  const attempt=record(await rpc('mbn_pin_begin',{p_key:key}));if(attempt.blocked===true)throw new InputError('too_many_attempts',429);
  if(!UUID.test(attempt.ticket))throw Error('invalid_attempt');
  const c=attempt.credential===null?null:record(attempt.credential);
  if(c&&(!/^[a-f0-9]{64}$/.test(c.hash)||!/^[a-f0-9]{32}$/.test(c.salt)||c.iterations!==600000||!UUID.test(c.version)||!UUID.test(c.user_id)))throw Error('invalid_credential');
  const hashed=await hashPin(code,c?.salt||'0'.repeat(32));
  const match=equal(hashed,c?.hash||'0'.repeat(64))&&c!==null;
  const result=record(await rpc('mbn_pin_finish',{p_key:key,p_ticket:attempt.ticket,p_success:match,p_version:c?.version||null}));
  if(result.allowed!==true)throw new InputError('invalid_credentials',401);
  if(!UUID.test(result.user_id)||!UUID.test(result.version)||typeof result.email!=='string')throw Error('invalid_identity');
  return result;
 }
 return async(request:Request)=>{
  if(request.method==='OPTIONS')return new Response(null,{status:204,headers});
  if(request.method!=='POST')return json({error:'method_not_allowed'},405);
  try{
   const input=await body(request);
   const allowed=input.action==='login'?['action','username','pin']:input.action==='status'?['action','target_id']:input.action==='configure'?['action','target_id','username','new_pin','current_pin']:[];
   if(!allowed.length||Object.keys(input).some(k=>!allowed.includes(k)))throw new InputError('invalid_request');
   if(input.action==='login'){
    const name=username(input.username),code=pin(input.pin),identity=await verify(name.key,code);
    const session=await deps.issue(identity.user_id,identity.email),id=sessionId(session.access_token);
    if(!id||!session.refresh_token||session.token_type!=='bearer'||!(session.expires_in>0))throw Error('invalid_session');
    if(await rpc('mbn_pin_register_session',{p_user:identity.user_id,p_version:identity.version,p_session:id})!==true)throw Error('session_revoked');
    return json({session});
   }
   const token=/^Bearer (\S{20,8192})$/.exec(request.headers.get('authorization')||'')?.[1];
   const actor=token?await deps.authenticate(token):null;if(!actor)throw new InputError('authentication_required',401);
   const target=input.target_id??actor.id;if(!UUID.test(target))throw new InputError('invalid_request');
   const ctx=record(await rpc('mbn_pin_context',{p_actor:actor.id,p_session:actor.session_id,p_target:target}));
   if(input.action==='status')return json({username:ctx.target.username,configured:ctx.target.configured,actor_configured:ctx.actor.configured,initial_setup_allowed:ctx.actor.fresh,can_manage_others:ctx.admin});
   const name=username(input.username),newPin=pin(input.new_pin);
   if(ctx.actor.configured===true){const proof=await verify(ctx.actor.username_key,pin(input.current_pin));if(proof.user_id!==actor.id||proof.version!==ctx.actor.version)throw new InputError('access_changed',409);}
   else if(ctx.actor.fresh!==true)throw new InputError('reauthentication_required',403);
   const salt=hex(crypto.getRandomValues(new Uint8Array(16))),hash=await hashPin(newPin,salt);
   const result=await rpc('mbn_pin_configure',{p_actor:actor.id,p_session:actor.session_id,p_target:target,p_actor_version:ctx.actor.version,p_key:name.key,p_display:name.display,p_hash:hash,p_salt:salt});
   return json(result);
  }catch(error){if(error instanceof InputError)return json({error:error.code},error.status);return json({error:'service_unavailable'},503);}
 };
}
