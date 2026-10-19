import {AppError,object,json,readJSON,rpcError} from '../mbn-workspace/handler.ts';
type Envelope=Record<string,any>;
export function snsCanonical(envelope:Envelope){
 const fields=envelope.Type==='Notification'?['Message','MessageId',...('Subject' in envelope?['Subject']:[]),'Timestamp','TopicArn','Type']:['Message','MessageId','SubscribeURL','Timestamp','Token','TopicArn','Type'];
 if(!['Notification','SubscriptionConfirmation','UnsubscribeConfirmation'].includes(envelope.Type)||fields.some(key=>typeof envelope[key]!=='string'))throw new AppError('invalid_notification');
 return fields.map(key=>key+'\n'+envelope[key]+'\n').join('');
}
export function certificateURL(value:unknown,region:string){
 if(typeof value!=='string')throw new AppError('invalid_certificate');
 const url=new URL(value);
 if(url.protocol!=='https:'||url.hostname!==`sns.${region}.amazonaws.com`||url.username||url.password||url.port||url.search||url.hash||!/^\/SimpleNotificationService-[a-zA-Z0-9_-]{1,100}\.pem$/.test(url.pathname))throw new AppError('invalid_certificate');
 return url;
}
export type Dependencies={rpc(name:string,args:Record<string,unknown>):PromiseLike<{data:unknown;error:{code?:string;message?:string}|null}>;verify(certificate:URL,signature:string,canonical:string,version:string):Promise<boolean>;confirm(url:URL):Promise<void>};
export function createHandler(deps:Dependencies){
 async function rpc(name:string,args:Record<string,unknown>={}){const r=await deps.rpc(name,args);if(r.error)rpcError(r.error);return r.data;}
 return async(request:Request)=>{
  if(request.method!=='POST')return json({error:'method_not_allowed'},405);
  try{
   const setting=object(await rpc('mbn_mail_transport_settings'));
   if(!setting.sns_topic_arn)throw new AppError('webhook_not_configured',403);
   const envelope=await readJSON(request,300000);
   if(envelope.TopicArn!==setting.sns_topic_arn||!['1','2'].includes(envelope.SignatureVersion)||typeof envelope.Signature!=='string'||envelope.Signature.length>1000)throw new AppError('invalid_notification',403);
   const timestamp=Date.parse(envelope.Timestamp);if(!Number.isFinite(timestamp)||timestamp>Date.now()+300000||timestamp<Date.now()-7*86400000)throw new AppError('expired_notification',403);
   const cert=certificateURL(envelope.SigningCertURL,setting.region),canonical=snsCanonical(envelope);
   if(!await deps.verify(cert,envelope.Signature,canonical,envelope.SignatureVersion))throw new AppError('invalid_signature',403);
   if(envelope.Type==='SubscriptionConfirmation'){
    const url=new URL(envelope.SubscribeURL);
    if(url.protocol!=='https:'||url.hostname!==`sns.${setting.region}.amazonaws.com`||url.username||url.password||url.port||url.hash||url.pathname!=='/'||url.searchParams.get('Action')!=='ConfirmSubscription'||url.searchParams.get('TopicArn')!==setting.sns_topic_arn||url.searchParams.get('Token')!==envelope.Token)throw new AppError('invalid_confirmation',403);
    await deps.confirm(url);return json({success:true});
   }
   if(envelope.Type==='UnsubscribeConfirmation')return json({success:true});
   let event;try{event=object(JSON.parse(envelope.Message));}catch{throw new AppError('invalid_event');}
   await rpc('mbn_mail_event',{p_envelope_id:envelope.MessageId,p_event:event});return json({success:true});
  }catch(error){if(error instanceof AppError)return json({error:error.code},error.status);return json({error:'service_unavailable'},503);}
 };
}
