import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import {createClient} from 'npm:@supabase/supabase-js@2.57.2';
import {createHandler,digest} from './handler.ts';
const admin=createClient(Deno.env.get('SUPABASE_URL')!,Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,{auth:{persistSession:false,autoRefreshToken:false}});
Deno.serve(createHandler({rpc:(name,args)=>admin.rpc(name,args),upload:async(path,file)=>{
 const bucket=admin.storage.from('mbn-admissions'),result=await bucket.upload(path,file.bytes,{contentType:file.manifest.mime_type,upsert:false,cacheControl:'0'});
 if(!result.error)return;
 if(!['409','400'].includes(String(result.error.statusCode)))throw Error('upload_unavailable');
 const previous=await bucket.download(path);
 if(previous.error||!previous.data||previous.data.size!==file.bytes.length||await digest(new Uint8Array(await previous.data.arrayBuffer()))!==file.manifest.sha256)throw Error('upload_conflict');
}}));
