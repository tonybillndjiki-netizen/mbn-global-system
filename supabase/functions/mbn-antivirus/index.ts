import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import {createClient} from 'npm:@supabase/supabase-js@2.57.2';
import {sessionId} from '../mbn-auth/handler.ts';
import {createHandler} from './handler.ts';
import {createScanner} from './scanner.ts';
const admin=createClient(Deno.env.get('SUPABASE_URL')!,Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,{auth:{persistSession:false,autoRefreshToken:false}});
Deno.serve(createHandler({
 authenticate:async token=>{const {data,error}=await admin.auth.getUser(token),session=sessionId(token);return !error&&data.user?.email_confirmed_at&&!data.user.is_anonymous&&session?{id:data.user.id,session_id:session}:null;},
 rpc:(name,args)=>admin.rpc(name,args),scanner:createScanner(Deno.env.get('MBN_SCANNER_URL'),Deno.env.get('MBN_SCANNER_TOKEN')),
 download:async(bucket,path)=>{const result=await admin.storage.from(bucket).download(path);if(result.error||!result.data||result.data.size>5242880)throw Error('download_unavailable');return new Uint8Array(await result.data.arrayBuffer());}
}));
