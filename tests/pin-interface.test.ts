import {test} from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import {readFileSync} from 'node:fs';
const root=new URL('../',import.meta.url),source=readFileSync(new URL('assets/auth-client.js',root),'utf8');
test('the simple login exchanges its session with Supabase without storing a clear PIN',async()=>{
 const requests:RequestInit[]=[],sessions:unknown[]=[];
 const context=vm.createContext({window:{},fetch:async(_url:string,request:RequestInit)=>{requests.push(request);return new Response(JSON.stringify({session:{access_token:'synthetic-access',refresh_token:'synthetic-refresh'}}));}});
 new vm.Script(source).runInContext(context);
 await context.window.MBNAuth.login({auth:{setSession:async(value:unknown)=>{sessions.push(value);return {error:null};}}},'Tony Bill','735104');
 assert.equal(requests.length,1);assert.equal(requests[0].method,'POST');assert.equal(sessions.length,1);
 assert.ok(!('Authorization' in (requests[0].headers as object)));assert.ok(!source.includes('localStorage'));assert.ok(!source.includes('sessionStorage'));
});
test('a failed code never creates a client session and shows the temporary lock clearly',async()=>{
 let stored=false;const context=vm.createContext({window:{},fetch:async()=>new Response(JSON.stringify({error:'too_many_attempts'}),{status:429})});new vm.Script(source).runInContext(context);
 await assert.rejects(context.window.MBNAuth.login({auth:{setSession:async()=>{stored=true;}}},'Tony Bill','735104'),/Trop de tentatives/);assert.equal(stored,false);
});
test('the admin and all school login screens ask for a username and six masked digits',()=>{
 const admin=readFileSync(new URL('MBN_GLOBAL_Admin_Supabase.html',root),'utf8');
 const login=/<form id="loginForm">([\s\S]*?)<\/form>/.exec(admin)![1];
 assert.ok(login.includes('Nom d’utilisateur'));assert.ok(login.includes('inputmode="numeric"'));assert.ok(login.includes('type="password"'));assert.ok(!login.includes('type="email"'));assert.ok(!admin.includes('signupBtn'));
 const schools=JSON.parse(readFileSync(new URL('forms/manifest.json',root),'utf8'));
 for(const school of schools){const html=readFileSync(new URL('forms/'+school.slug+'.html',root),'utf8');const form=/<form id="mbn-native-login">([\s\S]*?)<\/form>/.exec(html)![1];assert.ok(form.includes('Nom d’utilisateur'));assert.ok(form.includes('six chiffres'));assert.ok(!form.includes('type="email"'));assert.ok(html.includes('../assets/auth-client.js'));}
});
