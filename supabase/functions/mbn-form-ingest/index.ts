import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2.57.2";
import { BUCKET, createHandler, digest } from "./handler.ts";

const url=Deno.env.get('SUPABASE_URL')!;
const admin=createClient(url,Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,{
  auth:{persistSession:false,autoRefreshToken:false},
});
const publicKey=Deno.env.get('SUPABASE_ANON_KEY')!;
Deno.serve(createHandler({
  authenticate:async token=>{
    const {data,error}=await admin.auth.getUser(token);
    if(error || !data.user?.email_confirmed_at || data.user.is_anonymous)return null;
    const scoped=createClient(url,publicKey,{
      auth:{persistSession:false,autoRefreshToken:false},
      global:{headers:{Authorization:`Bearer ${token}`}},
    });
    const access=await scoped.rpc('mbn_native_admin_access');
    if(access.error)throw new Error('access_check_unavailable');
    return access.data===true ? data.user.id : null;
  },
  rpc:(name,args)=>admin.rpc(name,args),
  upload:async(path,file)=>{
    const result=await admin.storage.from(BUCKET).upload(path,file.bytes,{
      contentType:file.manifest.mime_type,upsert:false,cacheControl:'0',
    });
    if(!result.error)return;
    if(!['409','400'].includes(String(result.error.statusCode)))throw new Error('upload_unavailable');
    const previous=await admin.storage.from(BUCKET).download(path);
    if(previous.error || !previous.data || previous.data.size!==file.bytes.length
      || await digest(new Uint8Array(await previous.data.arrayBuffer()))!==file.manifest.sha256)throw new Error('upload_conflict');
  },
  download:async path=>{
    const result=await admin.storage.from(BUCKET).download(path);
    if(result.error || !result.data)throw new Error('download_unavailable');
    return new Uint8Array(await result.data.arrayBuffer());
  },
}));
