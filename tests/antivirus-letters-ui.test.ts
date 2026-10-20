import {test} from 'node:test';
import {parseHTML,HTMLElement,HTMLFormElement,HTMLSelectElement,HTMLInputElement} from 'linkedom';
import assert from 'node:assert/strict';
import {openLetterSettings,openLetterEditor} from '../assets/letters-ui.js';
test('National and international letters require a current preview and explicit approval',async()=>{
const {document,window}=parseHTML('<html><body></body></html>');globalThis.document=document;
Object.defineProperty(HTMLElement.prototype,'elements',{get(){return Object.fromEntries([...this.querySelectorAll('[name]')].map(el=>[el.name,el]));}});
Object.defineProperty(HTMLSelectElement.prototype,'value',{get(){return this.querySelector('option[selected]')?.getAttribute('value')??this.querySelector('option')?.getAttribute('value')??'';},set(v){for(const o of this.querySelectorAll('option'))o.toggleAttribute('selected',o.getAttribute('value')===String(v));}});
Object.defineProperty(HTMLInputElement.prototype,'checked',{get(){return this.hasAttribute('checked');},set(v){this.toggleAttribute('checked',Boolean(v));}});
class DOMFormData{constructor(form){this.values=[];for(const el of form.querySelectorAll('[name]')){if(el.disabled||el.closest('fieldset[disabled]'))continue;if(el.type==='checkbox'&&!el.checked)continue;this.values.push([el.name,el.value]);}}get(key){return this.values.find(v=>v[0]===key)?.[1]??null;}getAll(key){return this.values.filter(v=>v[0]===key).map(v=>v[1]);}*[Symbol.iterator](){yield* this.values;}}
globalThis.FormData=DOMFormData;
const h=value=>String(value??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const config={schools:[{code:'MLV BTS',name:'Marne-la-Vallée BTS',is_active:true},{code:'ESIIA',name:'ESIIA',is_active:true}],settings:['MLV BTS','ESIIA'].flatMap(code=>['NATIONAL','INTERNATIONAL'].map(type=>({school_code:code,admission_type:type,revision:crypto.randomUUID(),enabled:false,fields:{}})))};
const calls=[];let flow='NATIONAL',delay=0;
const dialog=(title,body)=>{const n=document.createElement('dialog');n.innerHTML='<h2>'+h(title)+'</h2>'+body;document.body.append(n);n.close=()=>{n.dispatchEvent(new window.Event('close'));n.remove();};return n;};
const request=async(action,data={},binary=false)=>{
 calls.push({action,data:structuredClone(data)});
 if(action==='letter_config_get')return structuredClone(config);
 if(action==='letter_config_save'){const i=config.settings.findIndex(x=>x.school_code===data.school_code&&x.admission_type===data.admission_type);assert.equal(config.settings[i].revision,data.expected_revision);const row={...data,revision:crypto.randomUUID()};config.settings[i]=row;return structuredClone(row);}
 if(action==='letter_context')return {application:{id:'synthetic',school_code:'MLV BTS',admission_type:flow,status:'ADMITTED',application_reference:'TEST'},school:{name:'Marne-la-Vallée BTS'},details:{date_naissance:'2000-01-02',lieu_naissance:'Ville synthétique'},letter_settings:structuredClone(config.settings.find(x=>x.school_code==='MLV BTS'&&x.admission_type===flow)),can_configure:true,letters:[],assets:[{key:'cgv_group',label:'Conditions générales',filename:'cgv.pdf'},{key:'avi_attestation',label:'Engagement AVI',filename:'avi.pdf'},{key:'visa_refusal',label:'Refus de visa',filename:'visa.pdf'}]};
 if(action==='letter_generate'){await new Promise(r=>setTimeout(r,delay));return {id:crypto.randomUUID()};}
 if(action==='letter_download')return new Blob(['%PDF-1.4 synthetic'],{type:'application/pdf'});
 if(action==='letter_send')return {status:'ACCEPTED'};
 throw Error('Unhandled '+action);
};
const deps={request,dialog,escapeHTML:h,toast:()=>{},refreshCRM:async()=>{}},event={preventDefault(){}};
let n=await openLetterSettings(deps);let form=n.querySelector('form'),f=form.elements;
f.school_code.value='MLV BTS';f.school_code.onchange();assert.equal(f.registration_fee.value,'');assert.equal(f.signatory.value,'');assert.equal(f.avi_mode.disabled,true);assert.equal(f.deferred_intake.required,false);
for(const [k,v] of Object.entries({academic_year:'2026/2027',intake:'janvier 2027',confirmation_days:'15',registration_fee:'0',tuition_deposit:'0',signatory:'Signataire synthétique'}))f[k].value=v;
f.enabled.checked=true;await form.onsubmit(event);let save=calls.find(c=>c.action==='letter_config_save').data;assert.equal(save.fields.avi_mode,'NONE');assert.equal(save.fields.deferred_intake,'');assert.equal(save.enabled,true);
for(const d of document.querySelectorAll('dialog'))d.close();
n=await openLetterEditor(deps,'synthetic');form=n.querySelector('form');f=form.elements;
assert.equal(n.querySelector('[name=registration_fee]'),null);assert.equal(n.querySelector('[name=attachment][value=avi_attestation]'),null);assert.equal(n.querySelector('#sendLetter').disabled,true);
f.cgv.value='cgv_group';await form.onsubmit(event);assert.equal(n.querySelector('#approveLetter').disabled,false);
const generate=calls.find(c=>c.action==='letter_generate').data;assert.deepEqual(Object.keys(generate.fields).sort(),['date_of_birth','logo_variant','place_of_birth']);assert.ok(generate.expected_config_revision);
const approval=n.querySelector('#approveLetter');approval.checked=true;approval.dispatchEvent(new window.Event('input',{bubbles:true}));assert.equal(n.querySelector('#sendLetter').disabled,false);
f.place_of_birth.value='Autre ville';f.place_of_birth.dispatchEvent(new window.Event('input',{bubbles:true}));assert.equal(n.querySelector('#sendLetter').disabled,true);
delay=20;const pending=form.onsubmit(event);f.place_of_birth.value='Ville modifiée pendant la génération';f.place_of_birth.dispatchEvent(new window.Event('input',{bubbles:true}));await pending;assert.equal(approval.disabled,true);
delay=0;await form.onsubmit(event);approval.checked=true;approval.dispatchEvent(new window.Event('input',{bubbles:true}));await n.querySelector('#sendLetter').onclick();assert.equal(calls.filter(c=>c.action==='letter_send').length,1);n.close();
flow='INTERNATIONAL';const profile=config.settings.find(x=>x.school_code==='MLV BTS'&&x.admission_type===flow);profile.enabled=true;profile.fields={academic_year:'2026/2027',intake:'janvier 2027',deferred_intake:'septembre 2027',confirmation_days:'30',registration_fee:'1000',tuition_deposit:'1000',signatory:'Signataire synthétique',avi_mode:'REQUIRED'};
n=await openLetterEditor(deps,'synthetic');form=n.querySelector('form');f=form.elements;assert.equal(n.querySelector('[name=attachment][value=avi_attestation]').checked,true);assert.equal(n.querySelector('[name=attachment][value=avi_attestation]').disabled,true);
f.cgv.value='cgv_group';await form.onsubmit(event);assert.ok(calls.filter(c=>c.action==='letter_generate').at(-1).data.attachments.includes('avi_attestation'));
});
