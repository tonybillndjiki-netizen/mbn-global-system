import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import {createClient} from 'npm:@supabase/supabase-js@2.57.2';
import {createHandler} from './handler.ts';
const admin=createClient(Deno.env.get('SUPABASE_URL')!,Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,{auth:{persistSession:false,autoRefreshToken:false}});
Deno.serve(createHandler({
 secret:async()=>{const r=await admin.rpc('mbn_runtime_key',{p_name:'brevo_webhook'});if(r.error||typeof r.data!=='string')throw Error('webhook_unavailable');return r.data;},
 rpc:(name,args)=>admin.rpc(name,args)
}));
