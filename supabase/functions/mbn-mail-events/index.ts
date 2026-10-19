import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import {createClient} from 'npm:@supabase/supabase-js@2.57.2';
import {X509Certificate,verify} from 'node:crypto';
import {createHandler} from './handler.ts';
const admin=createClient(Deno.env.get('SUPABASE_URL')!,Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,{auth:{persistSession:false,autoRefreshToken:false}});
Deno.serve(createHandler({rpc:(name,args)=>admin.rpc(name,args),verify:async(url,signature,canonical,version)=>{
 // Strict AWS regional host + TLS validation are enforced before certificate retrieval.
 const response=await fetch(url,{redirect:'error',signal:AbortSignal.timeout(5000)});
 if(!response.ok||Number(response.headers.get('content-length')||0)>20000)return false;
 const pem=await response.text();if(pem.length>20000)return false;
 const cert=new X509Certificate(pem),now=Date.now();
 if(Date.parse(cert.validFrom)>now||Date.parse(cert.validTo)<now)return false;
 return verify(version==='2'?'RSA-SHA256':'RSA-SHA1',new TextEncoder().encode(canonical),cert.publicKey,Uint8Array.from(atob(signature),c=>c.charCodeAt(0)));
},confirm:async url=>{const response=await fetch(url,{redirect:'error',signal:AbortSignal.timeout(5000)});if(!response.ok)throw Error('confirmation_unavailable');}}));
