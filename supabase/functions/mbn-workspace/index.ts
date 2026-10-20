import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import {createClient} from 'npm:@supabase/supabase-js@2.57.2';
import {createHandler} from './handler.ts';
import {createMailTransport} from './mail-transport.ts';
import {sessionId} from '../mbn-auth/handler.ts';
const admin=createClient(Deno.env.get('SUPABASE_URL')!,Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,{auth:{persistSession:false,autoRefreshToken:false}});
Deno.serve(createHandler({
 authenticate:async token=>{const {data,error}=await admin.auth.getUser(token);const id=sessionId(token);return !error&&data.user?.email_confirmed_at&&!data.user.is_anonymous&&id?{id:data.user.id,session_id:id}:null;},
 rpc:(name,args)=>admin.rpc(name,args),
 transport:createMailTransport(Deno.env.get('MBN_APPS_SCRIPT_ENDPOINTS'),Deno.env.get('MBN_BREVO_API_KEY'),async()=>{const {data,error}=await admin.rpc('mbn_mail_transport_settings');if(error||!data)throw Error('provider_unavailable');return data.provider;}),
 download:async(bucket,path)=>{const result=await admin.storage.from(bucket).download(path);if(result.error||!result.data)throw Error('download_unavailable');return new Uint8Array(await result.data.arrayBuffer());},
 sleep:ms=>new Promise(resolve=>setTimeout(resolve,ms)),
}));
