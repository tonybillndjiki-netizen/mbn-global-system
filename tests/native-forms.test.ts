import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import vm from 'node:vm';
const root=new URL('../',import.meta.url);
const manifest=JSON.parse(readFileSync(new URL('forms/manifest.json',root),'utf8')) as {school:string;slug:string}[];
test('all 19 school forms preserve their source presentation and use only the native submit handler',()=>{
  assert.equal(manifest.length,19);assert.equal(new Set(manifest.map(s=>s.school)).size,19);
  for(const school of manifest){
    const html=readFileSync(new URL('forms/'+school.slug+'.html',root),'utf8');
    assert.ok(html.includes(`name="mbn-school" content="${school.school}"`));
    for(const id of ['admission-form','nom','prenom','pays_residence','email','telephone','campus','cycle','formation','file_cv','file_diplome','file_identite','btn-submit','success-screen'])assert.ok(html.includes(`id="${id}"`),`${school.school}: missing ${id}`);
    assert.ok(html.includes('window.mbnSubmitNative()'));assert.ok(html.includes('../assets/native-client.js'));
    assert.ok(!html.includes('script.google.com'));assert.ok(!html.includes('await fetch('));assert.ok(!html.includes('readAsDataURL'));
    for(const script of html.matchAll(/<script([^>]*)>([\s\S]*?)<\/script>/gi))if(!/\bsrc\s*=/.test(script[1]))new vm.Script(script[2]);
  }
});
test('Evry BTS has its own identity and Noisiel is absent from its campus presentation',()=>{
  const evry=readFileSync(new URL('forms/evry-bts.html',root),'utf8');
  assert.ok(evry.includes('assets/brands/evry-bts.png'));assert.ok(evry.includes('#c23c55'));
  assert.ok(!evry.includes('marnelavallee-bts.fr'));assert.ok(!evry.includes('NOISIEL'));assert.ok(evry.includes('EVRY BTS'));
});
class Element {
  id='';value='';disabled=false;hidden=false;checked=false;textContent='';content='';style={};files:File[]=[];
  options:{value:string;text:string}[]=[];children:unknown[]=[];listeners:Record<string,Function[]>={};
  classList={remove:()=>{},add:()=>{}};
  replaceChildren(...children:unknown[]){this.options=children as {value:string;text:string}[];this.children=children;this.value='';}
  add(option:{value:string;text:string}){this.options.push(option);}
  addEventListener(name:string,fn:Function){(this.listeners[name]??=[]).push(fn);}
  append(...children:unknown[]){this.children.push(...children);}
  before(){} removeAttribute(){} querySelectorAll(){return [];}querySelector(){return new Element();}
  checkValidity(){return true;}reportValidity(){return true;}
}
const p1='10000000-0000-4000-8000-000000000001',p2='10000000-0000-4000-8000-000000000002';
const rows=[{id:p1,name:'Formation homonyme',cycle:'Bachelor',academic_level:'Bachelor 1',domain:'Commerce',pace:null},
  {id:p2,name:'Formation homonyme',cycle:'Bachelor',academic_level:'Bachelor 2',domain:'Commerce',pace:null}];
async function browserHarness({authorized=true,catalogue=true}={}){
  const elements:Record<string,Element>={};
  for(const id of ['mbn-native-reference','mbn-native-status','mbn-native-login','mbn-native-logout','mbn-native-new','mbn-native-access','mbn-native-password','mbn-native-username','btn-submit','campus','cycle','niveau_academique','domaine','formation','rythme','nom','prenom','email','pays_residence','telephone','indicatif_tel','admission-form','form-navigation','success-screen','error-message'])elements[id]=new Element();
  elements.nom.value='Test';elements.prenom.value='Synthétique';elements.email.value='synthetic@example.invalid';elements.pays_residence.value='France';elements.rythme.value='Initial';
  const requests:{url:string;init:RequestInit}[]=[];
  let finish:()=>void=()=>{};
  const done=new Promise<void>(resolve=>{finish=resolve;});
  const client={
    from:(table:string)=>{
      const data=table==='school_programs'?rows:table==='school_campuses'?[{campus_code:'NOISIEL'}]:catalogue?{code:'MLV BS',is_active:true}:null;
      const result={data,error:null};
      const query={select:()=>query,eq:()=>query,order:()=>query,range:()=>Promise.resolve(result),maybeSingle:()=>Promise.resolve(result),then:(resolve:Function)=>Promise.resolve(result).then(resolve as never)};
      return query;
    },
    rpc:async()=>({data:authorized,error:null}),
    auth:{getUser:async()=>({data:{user:authorized?{id:'admin'}:null},error:null}),getSession:async()=>({data:{session:{access_token:'synthetic-token'}}}),onAuthStateChange:()=>finish()},
  };
  const context=vm.createContext({
    document:{getElementById:(id:string)=>elements[id]??null,querySelector:(selector:string)=>selector.startsWith('meta')?{content:'MLV BS'}:null,
      querySelectorAll:()=>[],createElement:()=>new Element(),createTextNode:(s:string)=>s},
    window:{},crypto,FormData,Blob,Option:class{constructor(public text:string,public value:string){}},
    sessionStorage:{getItem:()=>null,setItem:()=>{}},
    mbnTestImport:async()=>({createClient:()=>client}),
    fetch:async(url:string,init:RequestInit)=>{requests.push({url,init});const p=JSON.parse(String((init.body as FormData).get('payload')));return new Response(JSON.stringify({success:true,test:true,reference:p.reference_dossier,document_count:0}));},
  });
  const script=readFileSync(new URL('assets/native-client.js',root),'utf8').replace("await import('https://esm.sh/@supabase/supabase-js@2.57.2')",'await globalThis.mbnTestImport()');
  new vm.Script(script).runInContext(context);
  if(catalogue)await Promise.race([done,new Promise((_,reject)=>setTimeout(()=>reject(Error('form boot did not finish')),1000))]);
  else for(let i=0;i<10;i++)await new Promise(setImmediate);
  return {elements,requests,context};
}
test('the live catalogue cascade disambiguates identical titles and submits the selected program UUID',async()=>{
  const {elements,context,requests}=await browserHarness();
  assert.equal(elements['btn-submit'].disabled,false);assert.equal(elements.niveau_academique.options.length,3);
  elements.niveau_academique.value='Bachelor 2';for(const listener of elements.niveau_academique.listeners.change)listener();
  assert.equal(elements.formation.value,p2);assert.equal(elements.formation.options[1].value,p2);
  await context.window.mbnSubmitNative();assert.equal(requests.length,1);
  const payload=JSON.parse(String((requests[0].init.body as FormData).get('payload')));
  assert.equal(payload.program_id,p2);assert.equal(payload.academic_level,'Bachelor 2');assert.equal(payload.school_code,'MLV BS');
  assert.equal(payload.consent_email,false);assert.match(requests[0].url,/supabase\.co\/functions\/v1\/mbn-form-ingest$/);
});
test('a disconnected form cannot submit through a retained legacy catalogue',async()=>{
  const {elements,context,requests}=await browserHarness({authorized:false});
  assert.equal(elements['btn-submit'].disabled,true);await context.window.mbnSubmitNative();assert.equal(requests.length,0);
});
test('catalogue failure keeps submission disabled instead of using hardcoded source options',async()=>{
  const {elements,context,requests}=await browserHarness({catalogue:false});
  assert.equal(elements['btn-submit'].disabled,true);await context.window.mbnSubmitNative();assert.equal(requests.length,0);
});
test('the admin console separates test records and offers authenticated private document downloads',()=>{
  const html=readFileSync(new URL('MBN_GLOBAL_Admin_Supabase.html',root),'utf8');
  const admin=readFileSync(new URL('assets/admin-app.js',root),'utf8');
  assert.ok(html.includes('data-tab="forms"'));assert.ok(admin.includes("from('native_test_submissions')"));
  assert.ok(!html.includes('Apps Script'));assert.ok(!html.includes('service_role'));assert.ok(!html.includes('sb_secret_'));
  for(const match of html.matchAll(/<script[^>]*>([\s\S]*?)<\/script>/g))new vm.Script(match[1].replace(/^import .*;$/m,''));
});
