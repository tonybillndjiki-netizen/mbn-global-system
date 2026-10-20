import {createAppsScript} from './appscript.ts';
import {createBrevo} from './brevo.ts';
import type {Attachment,Sender,Inspection,Outcome} from './ses.ts';

// Old messages retain their provider. Google is chosen explicitly in the CRM;
// credentials for one provider can never silently fall back to another.
export function createMailTransport(appscriptConfig:string|undefined,brevoKey:string|undefined,getProvider?:()=>Promise<string>){
 const google=createAppsScript(appscriptConfig),brevo=createBrevo(brevoKey);
 const choose=(sender:Sender)=>sender.provider==='GOOGLE_APPS_SCRIPT'?google:sender.provider==='BREVO'?brevo:null;
 return {
  supportsAppsScript:true,
  configured:google.configured||brevo.configured,
  configuredFor:(provider:string)=>provider==='GOOGLE_APPS_SCRIPT'?google.configured:provider==='BREVO'?brevo.configured:false,
  async status(){const provider=getProvider?await getProvider():'BREVO';return {provider,credentials_configured:provider==='GOOGLE_APPS_SCRIPT'?google.configured:provider==='BREVO'?brevo.configured:false};},
  async inspect(sender:Sender):Promise<Inspection>{
   const transport=choose(sender);
   return transport?transport.inspect(sender):{sender_verified:false,production_access:false,account_sending_enabled:false,remaining:0,rate:0,error:'invalid_provider'};
  },
  configureWebhook:(token:string)=>brevo.configureWebhook(token),
  async send(sender:Sender,message:{id:string;recipient:string;subject:string;text:string;html:string;unsubscribe?:string;attachments?:Attachment[]}):Promise<Outcome>{
   const transport=choose(sender);return transport?transport.send(sender,message):{status:'FAILED',error:'invalid_provider'};
  }
 };
}
