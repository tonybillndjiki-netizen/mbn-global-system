import {test} from 'node:test';
import assert from 'node:assert/strict';
import {parseHTML,HTMLElement,HTMLInputElement} from 'linkedom';
import {renderAppsScriptSettings} from '../assets/appscript-settings-ui.js';

test('Google configuration distinguishes a manually received test from automatic delivery and preserves school routes',async()=>{
 const {document}=parseHTML('<html><body><main id="view"></main></body></html>');
 Object.defineProperty(HTMLElement.prototype,'elements',{configurable:true,get(){return Object.fromEntries([...this.querySelectorAll('[name]')].map(el=>[el.name,el]));}});
 Object.defineProperty(HTMLInputElement.prototype,'checked',{configurable:true,get(){return this.hasAttribute('checked');},set(value){this.toggleAttribute('checked',Boolean(value));}});
 const view=document.getElementById('view'),calls:any[]=[];let refreshes=0;
 const config={daily_limit:100,groups:[{code:'MBN_GLOBAL',from_name:'MBN Global',from_email:'sender@example.invalid',sender_verified:true,enabled:false,test_confirmation_valid:false,last_test:{id:'synthetic-test',status:'ACCEPTED'}}],schools:[{school_code:'MLV BTS',school_name:'Marne-la-Vallée BTS',sender_group:'MBN_GLOBAL',admissions_email:'contact@example.invalid'}]};
 const deps={view,config,provider:{provider:'GOOGLE_APPS_SCRIPT',credentials_configured:true},request:async(action:string,data:any)=>{calls.push({action,data});return {success:true};},escapeHTML:(s:any)=>String(s??''),toast:()=>{},refresh:async()=>{refreshes++;}};
 await renderAppsScriptSettings(deps);
 assert.ok(view.textContent.includes('Google Apps Script'));assert.ok(view.textContent.includes('ne constitue pas une preuve de réception'));
 assert.equal(view.querySelector('[name=enabled]').hasAttribute('disabled'),true);
 const confirm=view.querySelector('[data-google-confirm]');assert.ok(confirm);assert.equal(confirm.querySelector('[name=received]').hasAttribute('required'),true);
 confirm.elements.received.checked=true;
 await confirm.onsubmit({preventDefault(){},submitter:confirm.querySelector('button')});
 assert.deepEqual(calls,[{action:'appscript_confirm_test',data:{sender_group:'MBN_GLOBAL',message_id:'synthetic-test',received:true}}]);assert.equal(refreshes,1);
 assert.equal(view.querySelector('[name=admissions_email]').value,'contact@example.invalid');
 config.groups[0].test_confirmation_valid=true;
 await renderAppsScriptSettings(deps);
 assert.equal(view.querySelector('[name=enabled]').hasAttribute('disabled'),false);assert.equal(view.querySelector('[data-google-confirm]'),null);
 assert.ok(view.textContent.includes('Réception du test confirmée manuellement'));
});
