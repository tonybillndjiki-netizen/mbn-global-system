import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import {createClient} from 'npm:@supabase/supabase-js@2.57.2';
import {createHandler,sessionId} from './handler.ts';
const url=Deno.env.get('SUPABASE_URL')!,serviceKey=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,publicKey=Deno.env.get('SUPABASE_ANON_KEY')!;
const client=()=>createClient(url,serviceKey,{auth:{persistSession:false,autoRefreshToken:false}});
const admin=client();
Deno.serve(createHandler({
 rpc:(name,args)=>admin.rpc(name,args),
 authenticate:async token=>{const {data,error}=await admin.auth.getUser(token);const id=sessionId(token);return !error&&data.user?.email_confirmed_at&&!data.user.is_anonymous&&id?{id:data.user.id,session_id:id}:null;},
 issue:async(userId,email)=>{
  const generated=await admin.auth.admin.generateLink({type:'magiclink',email});
  if(generated.error||generated.data.user?.id!==userId||!generated.data.properties?.hashed_token)throw Error('session_unavailable');
  // generateLink does not send an email. Consume the one-use verifier server-side.
  const scoped=createClient(url,publicKey,{auth:{persistSession:false,autoRefreshToken:false}});
  const verified=await scoped.auth.verifyOtp({type:'email',token_hash:generated.data.properties.hashed_token});
  if(verified.error||verified.data.user?.id!==userId||!verified.data.session)throw Error('session_unavailable');
  const s=verified.data.session;
  return {access_token:s.access_token,refresh_token:s.refresh_token,expires_in:s.expires_in,token_type:s.token_type};
 },
}));
