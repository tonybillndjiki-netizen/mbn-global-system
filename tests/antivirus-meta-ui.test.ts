import {test} from 'node:test';
import {parseHTML,HTMLElement,HTMLSelectElement,HTMLInputElement} from 'linkedom';
import assert from 'node:assert/strict';
import {renderMeta} from '../assets/meta-ui.js';
test('Meta routing can be created, paused and retried from the administrator interface',async()=>{
const {document}=parseHTML('<html><body><div id="root"></div></body></html>');globalThis.document=document;
Object.defineProperty(HTMLElement.prototype,'elements',{get(){return Object.fromEntries([...this.querySelectorAll('[name]')].map(el=>[el.getAttribute('name'),el]));}});
Object.defineProperty(HTMLSelectElement.prototype,'value',{get(){return this.querySelector('option[selected]')?.getAttribute('value')??this.querySelector('option')?.getAttribute('value')??'';},set(v){for(const o of this.querySelectorAll('option'))o.toggleAttribute('selected',o.getAttribute('value')===String(v));}});
Object.defineProperty(HTMLInputElement.prototype,'checked',{get(){return this.hasAttribute('checked');},set(v){this.toggleAttribute('checked',Boolean(v));}});
class DOMFormData{constructor(form){this.values=[];for(const el of form.querySelectorAll('[name]')){if(el.disabled)continue;if(el.type==='checkbox'&&!el.checked)continue;this.values.push([el.getAttribute('name'),el.value]);}}*[Symbol.iterator](){yield* this.values;}}
globalThis.FormData=DOMFormData;
const h=value=>String(value??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const root=document.querySelector('#root'),calls=[],toasts=[];
const data={credentials:{app_secret_configured:false,graph_version_configured:false,verify_token_configured:false},schools:[{code:'MLV BTS',name:'Marne-la-Vallée BTS',is_active:true},{code:'ESIIA',name:'ESIIA',is_active:true}],campuses:[{school_code:'MLV BTS',code:'NOISIEL',name:'Campus Innovation'}],programs:[{school_code:'MLV BTS',id:'synthetic-program',name:'BTS synthétique'}],routes:[],counts:{UNMAPPED:1},events:[{id:'synthetic-event',leadgen_id:'333330000001',form_id:'222220000001',page_id:'111110000001',status:'UNMAPPED',attempts:0,received_at:'2026-10-20T08:00:00Z',updated_at:'2026-10-20T08:00:00Z',revision:'event-revision'}]};
const dialog=(_title,body)=>{const n=document.createElement('dialog');n.innerHTML=body;document.body.append(n);n.close=()=>n.remove();return n;};
const request=async(action,value={})=>{
 calls.push({action,data:structuredClone(value)});
 if(action==='meta_context')return structuredClone(data);
 if(action==='meta_route_save'){
  const r={...value,id:value.id||'synthetic-route',revision:'new-revision',ready:value.enabled,page_token_configured:true};
  data.routes=[r];return structuredClone(r);
 }
 if(action==='meta_process')return {processed:1};
 if(action==='meta_retry'){assert.equal(value.expected_revision,'event-revision');return {queued:true};}
 throw Error('Unhandled '+action);
};
const deps={root,request,dialog,escapeHTML:h,toast:value=>toasts.push(value),openLead:async()=>{}};
await renderMeta(deps);assert.equal(root.querySelector('#processMeta').disabled,true);assert.equal(root.querySelectorAll('input[type=password]').length,0);
await root.querySelector('#newMetaRoute').onclick();let form=document.querySelector('dialog form'),f=form.elements;
assert.equal(f.enabled.checked,false);assert.equal(f.page_id.value,'');assert.equal(f.form_id.value,'');assert.equal(f.consent_field.value,'');
f.school_code.value='MLV BTS';f.school_code.onchange();assert.ok(f.program_id.innerHTML.includes('BTS synthétique'));
f.school_code.value='ESIIA';f.school_code.onchange();assert.ok(!f.program_id.innerHTML.includes('BTS synthétique'));
f.school_code.value='MLV BTS';f.school_code.onchange();
for(const [k,v] of Object.entries({label:'Formulaire <img src=x onerror=alert(1)>',page_id:'111110000001',form_id:'222220000001',campus_code:'NOISIEL',program_id:'synthetic-program',consent_field:'opt_in',consent_value:'Oui',consent_statement:'Je souhaite recevoir les e-mails.'}))f[k].value=v;
f.enabled.checked=true;await form.onsubmit({preventDefault(){}});
const saved=calls.find(c=>c.action==='meta_route_save').data;assert.equal(saved.school_code,'MLV BTS');assert.equal(saved.field_map.email,'email');assert.equal(saved.consent_statement,'Je souhaite recevoir les e-mails.');assert.equal(saved.enabled,true);assert.equal(root.querySelectorAll('img').length,0);assert.ok(root.textContent.includes('Formulaire <img'));
await root.querySelector('[data-meta-edit]').onclick();form=document.querySelector('dialog form');f=form.elements;assert.equal(f.form_id.value,'222220000001');f.enabled.checked=false;await form.onsubmit({preventDefault(){}});const changed=calls.filter(c=>c.action==='meta_route_save').at(-1).data;assert.equal(changed.id,'synthetic-route');assert.equal(changed.expected_revision,'new-revision');assert.equal(changed.enabled,false);
data.credentials={app_secret_configured:true,graph_version_configured:true,verify_token_configured:true};data.routes[0].enabled=true;data.routes[0].ready=true;await renderMeta(deps);assert.equal(root.querySelector('#processMeta').disabled,false);await root.querySelector('#processMeta').onclick();assert.equal(calls.filter(c=>c.action==='meta_process').length,1);
await root.querySelector('[data-meta-retry]').onclick();assert.ok(calls.some(c=>c.action==='meta_retry'));assert.ok(toasts.includes('Notification remise en attente.'));
});
