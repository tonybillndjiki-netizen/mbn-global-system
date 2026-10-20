import {test} from 'node:test';
import assert from 'node:assert/strict';
import {parseHTML} from 'linkedom';
import {createWorkspace} from '../assets/workspace-ui.js';

test('the integrated Mail workspace can navigate to both followups and Meta without losing CRM tools',async()=>{
 const {document,window}=parseHTML('<html><body><main id="view"></main></body></html>');
 const oldDocument=globalThis.document,oldFetch=globalThis.fetch,calls:string[]=[],toasts:string[]=[];
 globalThis.document=document;
 const meta={credentials:{},schools:[],campuses:[],programs:[],routes:[],counts:{},events:[]};
 const replies:Record<string,unknown>={bootstrap:{counts:{},permissions:[]},leads_list:{rows:[],total:0},applications_list:{rows:[],total:0},followups_context:{schools:[]},meta_context:meta};
 globalThis.fetch=async(url,init)=>{
  const {action}=JSON.parse(String(init?.body));calls.push(action);
  assert.ok(Object.hasOwn(replies,action),'Unexpected action '+action);
  if(action==='meta_context')assert.ok(String(url).endsWith('/mbn-meta'));
  if(action==='followups_context')assert.ok(String(url).endsWith('/mbn-workspace'));
  return new Response(JSON.stringify(replies[action]),{status:200});
 };
 try{
  const workspace=createWorkspace({client:{auth:{getSession:async()=>({data:{session:{access_token:'synthetic-session'}}})}},getSchools:()=>[],getAdmin:()=>true,toast:value=>toasts.push(value),navigate:()=>{}});
  await workspace.renderMail();
  assert.ok(document.querySelector('[data-mail-tab="followups"]'));
  assert.ok(document.querySelector('[data-mail-tab="meta"]'));
  const select=async(tab:string,action:string)=>{
   const before=calls.filter(v=>v===action).length;
   document.querySelector('[data-mail-tab="'+tab+'"]').dispatchEvent(new window.Event('click'));
   for(let i=0;i<20;i++){await new Promise(resolve=>setImmediate(resolve));if(calls.filter(v=>v===action).length>before)break;}
   assert.equal(calls.filter(v=>v===action).length,before+1);
  };
  await select('followups','followups_context');assert.ok(document.querySelector('#mail-content').textContent.includes('clic confirmé'));
  await select('meta','meta_context');assert.ok(document.querySelector('#newMetaRoute'));
  await workspace.renderCRM();
  for(const id of ['routingRules','letterSettings','antivirusSettings'])assert.ok(document.getElementById(id),'Missing CRM tool '+id);
  assert.deepEqual(toasts,[]);
 }finally{globalThis.document=oldDocument;globalThis.fetch=oldFetch;}
});
