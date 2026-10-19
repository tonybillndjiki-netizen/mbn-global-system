export type Attachment={filename:string;mime_type:string;base64:string};
export type Credentials={accessKeyId:string;secretAccessKey:string;sessionToken?:string};
export type Sender={from_name:string;from_email:string;reply_to:string;identity:string;region:string;configuration_set:string};
export type Inspection={sender_verified:boolean;production_access:boolean;account_sending_enabled:boolean;remaining:number;rate:number;error?:string;credential_fingerprint?:string};
export type Outcome={status:'ACCEPTED'|'FAILED'|'UNCERTAIN';provider_id?:string;error?:string};
const utf8=new TextEncoder();
const hex=(v:ArrayBuffer)=>Array.from(new Uint8Array(v),n=>n.toString(16).padStart(2,'0')).join('');
const sha=async(v:string)=>hex(await crypto.subtle.digest('SHA-256',utf8.encode(v)));
async function hmac(key:Uint8Array,value:string){const k=await crypto.subtle.importKey('raw',new Uint8Array(key).buffer,{name:'HMAC',hash:'SHA-256'},false,['sign']);return new Uint8Array(await crypto.subtle.sign('HMAC',k,utf8.encode(value)));}
const encode=(v:string)=>encodeURIComponent(v).replace(/[!'()*]/g,c=>'%'+c.charCodeAt(0).toString(16).toUpperCase());
export async function signRequest(credentials:Credentials,region:string,method:string,path:string,body:string,now=new Date()){
 if(!/^[a-z]{2}-[a-z]+-\d$/.test(region))throw Error('invalid_region');
 const host=`email.${region}.amazonaws.com`,date=now.toISOString().replace(/[:-]|\.\d{3}/g,''),day=date.slice(0,8);
 const headers:Record<string,string>={'content-type':'application/json','host':host,'x-amz-date':date};
 if(credentials.sessionToken)headers['x-amz-security-token']=credentials.sessionToken;
 const names=Object.keys(headers).sort(),signed=names.join(';');
 const canonicalPath=path.split('/').map(part=>encode(decodeURIComponent(part))).join('/');
 const canonical=[method,canonicalPath,'',names.map(name=>`${name}:${headers[name].trim().replace(/\s+/g,' ')}\n`).join(''),signed,await sha(body)].join('\n');
 const scope=`${day}/${region}/ses/aws4_request`;
 const stringToSign=`AWS4-HMAC-SHA256\n${date}\n${scope}\n${await sha(canonical)}`;
 let key=await hmac(utf8.encode('AWS4'+credentials.secretAccessKey),day);key=await hmac(key,region);key=await hmac(key,'ses');key=await hmac(key,'aws4_request');
 const signature=hex((await hmac(key,stringToSign)).buffer as ArrayBuffer);
 headers.authorization=`AWS4-HMAC-SHA256 Credential=${credentials.accessKeyId}/${scope}, SignedHeaders=${signed}, Signature=${signature}`;
 delete headers.host;
 return {url:`https://${host}${canonicalPath}`,headers,body,canonical,stringToSign};
}
export function senderAddress(sender:Sender){
 const name=sender.from_name.replace(/["\\\r\n]/g,'');
 if(/^[\x20-\x7e]*$/.test(name))return '"'+name+'" <'+sender.from_email+'>';
 // RFC 2047: split on code points so no UTF-8 character or encoded word is truncated.
 const parts:string[]=[];let chunk='';
 for(const char of name){if(new TextEncoder().encode(chunk+char).length>42){parts.push(chunk);chunk='';}chunk+=char;}if(chunk)parts.push(chunk);
 const encoded=parts.map(p=>'=?UTF-8?B?'+btoa(String.fromCharCode(...new TextEncoder().encode(p)))+'?=').join(' ');
 return encoded+' <'+sender.from_email+'>';
}
export function createSES(credentials:Credentials|undefined,fetcher:typeof fetch=fetch){
 async function request(sender:Sender,method:string,path:string,payload?:unknown){
  if(!credentials)throw Error('aws_credentials_missing');
  const body=payload===undefined?'':JSON.stringify(payload),signed=await signRequest(credentials,sender.region,method,path,body);
  const response=await fetcher(signed.url,{method,headers:signed.headers,...(method==='POST'?{body}:{}),redirect:'error',signal:AbortSignal.timeout(12000)});
  let value:Record<string,any>={};try{value=await response.json();}catch{}
  return {response,value};
 }
 return {
  configured:!!credentials,
  async inspect(sender:Sender):Promise<Inspection>{
   const empty={sender_verified:false,production_access:false,account_sending_enabled:false,remaining:0,rate:0};
   if(!credentials)return {...empty,error:'aws_credentials_missing'};
   if(!sender.from_email||!sender.identity)return {...empty,error:'sender_configuration_missing'};
   try{
    const account=await request(sender,'GET','/v2/email/account');
    if(!account.response.ok)return {...empty,error:'ses_account_access_denied'};
    const identity=await request(sender,'GET','/v2/email/identities/'+encode(sender.identity));
    if(!identity.response.ok)return {...empty,error:'ses_identity_unavailable'};
    const quota=account.value.SendQuota||{};
    return {sender_verified:identity.value.VerifiedForSendingStatus===true,
     production_access:account.value.ProductionAccessEnabled===true,
     account_sending_enabled:account.value.SendingEnabled===true&&['HEALTHY',undefined].includes(account.value.EnforcementStatus),
     remaining:Math.max(0,Number(quota.Max24HourSend||0)-Number(quota.SentLast24Hours||0)),rate:Number(quota.MaxSendRate||0)};
   }catch{return {...empty,error:'ses_connection_unavailable'};}
  },
  async send(sender:Sender,message:{id:string;recipient:string;subject:string;text:string;html:string;unsubscribe?:string;attachments?:Attachment[]}):Promise<Outcome>{
   if(!credentials)return {status:'FAILED',error:'aws_credentials_missing'};
   const payload={FromEmailAddress:senderAddress(sender),Destination:{ToAddresses:[message.recipient]},
    ...(sender.reply_to?{ReplyToAddresses:[sender.reply_to]}:{}),...(sender.configuration_set?{ConfigurationSetName:sender.configuration_set}:{}),
    EmailTags:[{Name:'mbn_message_id',Value:message.id}],
    Content:{Simple:{Subject:{Charset:'UTF-8',Data:message.subject},Body:{Html:{Charset:'UTF-8',Data:message.html},Text:{Charset:'UTF-8',Data:message.text}},
     ...(message.attachments?.length?{Attachments:message.attachments.map(a=>({RawContent:a.base64,FileName:a.filename,ContentType:a.mime_type,ContentDisposition:'ATTACHMENT',ContentTransferEncoding:'BASE64'}))}:{}),
     ...(message.unsubscribe?{Headers:[{Name:'List-Unsubscribe',Value:`<${message.unsubscribe}>`},{Name:'List-Unsubscribe-Post',Value:'List-Unsubscribe=One-Click'}]}:{})}}};
   try{
    const {response,value}=await request(sender,'POST','/v2/email/outbound-emails',payload);
    if(response.ok&&typeof value.MessageId==='string'&&value.MessageId.length<200)return {status:'ACCEPTED',provider_id:value.MessageId};
    if(response.status>=500||response.ok)return {status:'UNCERTAIN',error:'ses_acceptance_uncertain'};
    return {status:'FAILED',error:response.status===429?'ses_throttled':'ses_request_rejected'};
   }catch{return {status:'UNCERTAIN',error:'ses_connection_interrupted'};}
  },
 };
}
