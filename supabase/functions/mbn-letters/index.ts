import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import {createClient} from 'npm:@supabase/supabase-js@2.57.2';
import {createHandler} from './handler.ts';
import {createBrevo} from '../mbn-workspace/brevo.ts';
import {sessionId} from '../mbn-auth/handler.ts';
import {digest} from '../mbn-form-ingest/handler.ts';
const admin=createClient(Deno.env.get('SUPABASE_URL')!,Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,{auth:{persistSession:false,autoRefreshToken:false}});
Deno.serve(createHandler({
 authenticate:async token=>{const {data,error}=await admin.auth.getUser(token);const id=sessionId(token);return !error&&data.user?.email_confirmed_at&&!data.user.is_anonymous&&id?{id:data.user.id,session_id:id}:null;},
 rpc:(name,args)=>admin.rpc(name,args),
 transport:createBrevo(Deno.env.get('MBN_BREVO_API_KEY')),
 download:async(bucket,path)=>{const r=await admin.storage.from(bucket).download(path);if(r.error||!r.data)throw Error('download_unavailable');return new Uint8Array(await r.data.arrayBuffer());},
 upload:async(bucket,path,bytes,mime)=>{
  const store=admin.storage.from(bucket),r=await store.upload(path,bytes,{contentType:mime,upsert:false,cacheControl:bucket==='mbn-school-branding'?'86400':'0'});
  if(!r.error)return;
  if(!['409','400'].includes(String(r.error.statusCode)))throw Error('upload_unavailable');
  const previous=await store.download(path);if(previous.error||!previous.data||previous.data.size!==bytes.length||await digest(new Uint8Array(await previous.data.arrayBuffer()))!==await digest(bytes))throw Error('upload_conflict');
 }
}));
