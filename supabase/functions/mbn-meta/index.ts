import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import {createClient} from 'npm:@supabase/supabase-js@2.57.2';
import {sessionId} from '../mbn-auth/handler.ts';
import {createHandler} from './handler.ts';
import {createMeta} from './graph.ts';
const admin=createClient(Deno.env.get('SUPABASE_URL')!,Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,{auth:{persistSession:false,autoRefreshToken:false}});
const appSecret=Deno.env.get('MBN_META_APP_SECRET');
Deno.serve(createHandler({
 appSecret,verifyToken:Deno.env.get('MBN_META_VERIFY_TOKEN'),
 graph:createMeta({appSecret,version:Deno.env.get('MBN_META_GRAPH_VERSION'),pageTokens:Deno.env.get('MBN_META_PAGE_TOKENS')}),
 authenticate:async token=>{const {data,error}=await admin.auth.getUser(token),session=sessionId(token);return !error&&data.user?.email_confirmed_at&&!data.user.is_anonymous&&session?{id:data.user.id,session_id:session}:null;},
 rpc:(name,args)=>admin.rpc(name,args),
}));
