import {digest} from '../mbn-form-ingest/handler.ts';
export class ScanError extends Error{constructor(public code:string){super(code);}}
export function createScanner(url?:string,token?:string,fetcher:typeof fetch=fetch){
 const configured=Boolean(url&&/^https:\/\/[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?\.[a-z]{2,}\/v1\/scan$/.test(url)&&token&&/^[A-Za-z0-9_-]{80,200}$/.test(token));
 return {configured,async scan(bytes:Uint8Array,sha256:string){
  if(!configured)throw new ScanError('scanner_configuration_missing');
  if(bytes.length<1||bytes.length>5242880||await digest(bytes)!==sha256)throw new ScanError('document_integrity_failed');
  let response:Response;
  try{response=await fetcher(url!,{method:'POST',redirect:'error',headers:{Authorization:'Bearer '+token,'Content-Type':'application/octet-stream'},body:bytes as BodyInit,signal:AbortSignal.timeout(20000)});}
  catch{throw new ScanError('scanner_unavailable');}
  if(!response.ok||!response.body){await response.body?.cancel();throw new ScanError('scanner_unavailable');}
  const reader=response.body.getReader(),chunks:Uint8Array[]=[];let length=0;
  try{for(;;){const {done,value}=await reader.read();if(done)break;length+=value.length;if(length>4096){await reader.cancel();throw new ScanError('scanner_invalid_result');}chunks.push(value);}}finally{reader.releaseLock();}
  const all=new Uint8Array(length);let offset=0;for(const chunk of chunks){all.set(chunk,offset);offset+=chunk.length;}
  let result:any;try{result=JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(all));}catch{throw new ScanError('scanner_invalid_result');}
  if(!result||result.sha256!==sha256||!['CLEAN','INFECTED'].includes(result.status)||typeof result.engine!=='string'||! /^[A-Za-z0-9 ./_():+-]{3,180}$/.test(result.engine))throw new ScanError('scanner_invalid_result');
  return {status:result.status as 'CLEAN'|'INFECTED',engine:result.engine as string};
 }};
}
