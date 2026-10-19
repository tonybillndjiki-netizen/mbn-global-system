export type RpcReply = { data: unknown; error: { code?: string; message?: string } | null };
export type DocumentManifest = {
  kind: string; original_name: string; mime_type: string; byte_size: number;
  sha256: string; extension: string;
};
export type NativeFile = { manifest: DocumentManifest; bytes: Uint8Array };
export type Dependencies = {
  authenticate(token: string): Promise<string | null>;
  rpc(name: string, args: Record<string, unknown>): PromiseLike<RpcReply>;
  upload(path: string, file: NativeFile): Promise<void>;
  download(path: string): Promise<Uint8Array>;
};
export const BUCKET = 'mbn-native-test';
export const MAX_FILE_BYTES = 5 * 1024 * 1024;
export const MAX_TOTAL_BYTES = 20 * 1024 * 1024;
const MAX_BODY_BYTES = MAX_TOTAL_BYTES + 65536;
const UUID = /^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/;
const kinds = new Set(['CV','DIPLOME','PIECE_IDENTITE','CARTE_VITALE','JUSTIFICATIF_HANDICAP','JUSTIFICATIF_PAIEMENT']);
const coreFields: Record<string, number> = {
  reference_dossier: 90, email: 254, full_name: 180, school_code: 120,
  campus_code: 60, country_of_residence: 120, phone: 60, program_id: 36,
  program_name: 250, cycle: 180, academic_level: 120, domain: 180, pace: 180,
};
const required = new Set(['reference_dossier','email','full_name','school_code','campus_code','country_of_residence','program_id']);
const detailFields: Record<string, number> = {
  nom: 100, prenom: 100, date_naissance: 10, lieu_naissance: 120,
  ville: 120, adresse: 300, telephone_proche: 60, financement: 180, handicap: 3,
};
const errors: Record<string, number> = {
  invalid_payload:400,invalid_field:400,invalid_fields:400,invalid_program_id:400,
  invalid_document:400,program_required:422,program_not_found:422,program_ambiguous:422,
  reference_conflict:409,lead_identity_conflict:409,lead_identity_ambiguous:409,
  school_inactive_or_unknown:422,campus_not_allowed:422,catalogue_selection_invalid:422,
  documents_pending:409,admin_required:403,submission_not_found:404,document_not_found:404,
  file_too_large:413,files_too_large:413,test_quota_reached:429,
};
const cors = {
  'Access-Control-Allow-Origin':'*',
  'Access-Control-Allow-Headers':'authorization, apikey, content-type, x-client-info',
  'Access-Control-Allow-Methods':'GET, POST, OPTIONS',
  'Access-Control-Expose-Headers':'Content-Disposition',
  'Cache-Control':'no-store',
  'X-Content-Type-Options':'nosniff',
};
const json = (body: unknown, status=200) => new Response(JSON.stringify(body), {
  status,headers:{...cors,'Content-Type':'application/json; charset=utf-8'},
});
export class InputError extends Error {
  constructor(public code: string, public status=400) { super(code); }
}
function object(value: unknown): Record<string, unknown> {
  if (!value || typeof value!=='object' || Array.isArray(value)) throw new InputError('invalid_payload');
  return value as Record<string, unknown>;
}
function clean(input: Record<string, unknown>, fields: Record<string, number>, needed=new Set<string>()) {
  const output: Record<string,string> = {};
  for (const [key,max] of Object.entries(fields)) {
    const value=input[key] ?? '';
    if (typeof value!=='string' || value.length>max || /[\u0000-\u0008\u000b-\u001f\u007f]/.test(value)) throw new InputError('invalid_field');
    output[key]=value.trim();
    if (needed.has(key) && !output[key]) throw new InputError('invalid_field');
  }
  return output;
}
export function normalizeNativePayload(value: unknown,mode:'TEST'|'CANDIDATE'='TEST') {
  const raw=object(value);
  if (Object.keys(raw).some(key=>!(key in coreFields) && !['details','consent_email'].includes(key))) throw new InputError('unknown_field');
  const payload: Record<string,unknown> = clean(raw,coreFields,required);
  const prefix=mode==='TEST'?'MBNTEST-':'MBNAPP-';
  if (!String(payload.reference_dossier).startsWith(prefix) || !UUID.test(String(payload.reference_dossier).slice(prefix.length))) throw new InputError('invalid_reference');
  if (!UUID.test(String(payload.program_id))) throw new InputError('invalid_program_id');
  payload.email=String(payload.email).toLowerCase();
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(payload.email))) throw new InputError('invalid_email');
  for (const key of ['school_code','campus_code']) payload[key]=String(payload[key]).normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/\s+/g,' ').toUpperCase();
  payload.source='DIRECT';payload.event='application_submitted';payload.consent_email=raw.consent_email===true;
  const detailInput=object(raw.details ?? {});
  if (Object.keys(detailInput).some(key=>!(key in detailFields))) throw new InputError('unknown_detail');
  const details=clean(detailInput,detailFields);
  if (details.handicap && !['Oui','Non'].includes(details.handicap)) throw new InputError('invalid_field');
  if (details.date_naissance) {
    const date=new Date(details.date_naissance+'T00:00:00Z');
    if (!/^\d{4}-\d{2}-\d{2}$/.test(details.date_naissance) || !Number.isFinite(date.getTime()) || date.toISOString().slice(0,10)!==details.date_naissance || date.getTime()>Date.now()) throw new InputError('invalid_birth_date');
  }
  return {payload,details};
}
export async function digest(bytes: Uint8Array) {
  return Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256',new Uint8Array(bytes).buffer)))
    .map(n=>n.toString(16).padStart(2,'0')).join('');
}
async function bodyBytes(request: Request, max: number) {
  const length=request.headers.get('content-length');
  if (length && (!/^\d+$/.test(length) || Number(length)>max)) throw new InputError('payload_too_large',413);
  if (!request.body) throw new InputError('invalid_payload');
  const reader=request.body.getReader(), chunks:Uint8Array[]=[];
  let total=0;
  try {
    for (;;) {
      const {done,value}=await reader.read();if(done)break;
      total+=value.byteLength;
      if(total>max){await reader.cancel();throw new InputError('payload_too_large',413);}
      chunks.push(value);
    }
  } finally {reader.releaseLock();}
  const bytes=new Uint8Array(total);let at=0;
  for(const chunk of chunks){bytes.set(chunk,at);at+=chunk.byteLength;}
  return bytes;
}
export async function parseSubmission(request: Request,mode:'TEST'|'CANDIDATE'='TEST') {
  let form:FormData;
  try {
    const bytes=await bodyBytes(request,MAX_BODY_BYTES);
    form=await new Response(bytes,{headers:{'Content-Type':request.headers.get('content-type')!}}).formData();
  } catch(error) {
    if(error instanceof InputError)throw error;
    throw new InputError('invalid_multipart');
  }
  if(form.getAll('payload').length!==1 || typeof form.get('payload')!=='string' || String(form.get('payload')).length>16384) throw new InputError('invalid_payload');
  let raw:unknown;
  try {raw=JSON.parse(String(form.get('payload')));} catch {throw new InputError('invalid_json');}
  const normalized=normalizeNativePayload(raw,mode), files:NativeFile[]=[];
  let total=0;
  for(const [kind,value] of form.entries()) {
    if(kind==='payload')continue;
    if(!kinds.has(kind) || typeof value==='string' || form.getAll(kind).length!==1)throw new InputError('invalid_document');
    if(!value.size || value.size>MAX_FILE_BYTES)throw new InputError('file_too_large',413);
    total+=value.size;if(total>MAX_TOTAL_BYTES)throw new InputError('files_too_large',413);
    const name=value.name.normalize('NFC');
    if(name.length>180 || !name.trim() || /[\/\\\u0000-\u001f\u007f]/.test(name))throw new InputError('invalid_document_name');
    const bytes=new Uint8Array(await value.arrayBuffer());
    let mime='',extension='';
    if(bytes.length>=5 && new TextDecoder().decode(bytes.slice(0,5))==='%PDF-'){mime='application/pdf';extension='pdf';}
    else if([137,80,78,71,13,10,26,10].every((n,i)=>bytes[i]===n)){mime='image/png';extension='png';}
    else if(bytes[0]===255 && bytes[1]===216 && bytes[2]===255){mime='image/jpeg';extension='jpg';}
    if(!mime || value.type!==mime || !(extension==='jpg' ? /\.jpe?g$/i : new RegExp('\\.'+extension+'$','i')).test(name))throw new InputError('document_type_mismatch',415);
    files.push({bytes,manifest:{kind,original_name:name,mime_type:mime,extension,byte_size:bytes.length,sha256:await digest(bytes)}});
  }
  files.sort((a,b)=>a.manifest.kind.localeCompare(b.manifest.kind));
  const manifest=files.map(file=>file.manifest);
  const fingerprint=await digest(new TextEncoder().encode(JSON.stringify({...normalized,manifest})));
  return {...normalized,files,manifest,fingerprint};
}
function databaseError(error: NonNullable<RpcReply['error']>) {
  const code=error.message ?? '',status=errors[code];
  if(status && error.code===`PT${status}`)throw new InputError(code,status);
  throw new Error('database_unavailable');
}
function receipt(data:unknown,reference?:unknown) {
  const result=object(data);
  if(result.success!==true || result.test!==true || !UUID.test(String(result.application_id)) || typeof result.duplicated!=='boolean' || (reference && result.reference!==reference))throw new Error('invalid_receipt');
  return result;
}
export function createHandler(dependencies: Dependencies) {
  return async (request:Request):Promise<Response> => {
    if(request.method==='OPTIONS')return new Response(null,{status:204,headers:cors});
    if(!['GET','POST'].includes(request.method))return json({error:'method_not_allowed'},405);
    const match=/^Bearer ([^\s]{20,8192})$/.exec(request.headers.get('authorization') ?? '');
    if(!match)return json({error:'authentication_required'},401);
    try {
      const actor=await dependencies.authenticate(match[1]);
      if(!actor)return json({error:'admin_required'},403);
      if(request.method==='GET')return json({service:'mbn-form-ingest',version:4,mode:'ADMIN_TEST',emails_enabled:false});
      const contentType=request.headers.get('content-type')?.split(';')[0].trim().toLowerCase();
      if(contentType==='application/json') {
        let input:Record<string,unknown>;
        try {input=object(JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(await bodyBytes(request,1024))));}
        catch(error){if(error instanceof InputError)throw error;throw new InputError('invalid_json');}
        if(input.action!=='download' || !UUID.test(String(input.document_id)) || Object.keys(input).some(k=>!['action','document_id'].includes(k)))throw new InputError('invalid_action');
        const result=await dependencies.rpc('mbn_native_document',{p_actor:actor,p_document:input.document_id});
        if(result.error)databaseError(result.error);
        const doc=object(result.data);
        if(doc.bucket!==BUCKET || !/^[a-f0-9-]{36}\/[A-Z_]+\.(pdf|png|jpg)$/.test(String(doc.object_path)))throw new Error('invalid_document_path');
        const bytes=await dependencies.download(String(doc.object_path));
        if(bytes.length>MAX_FILE_BYTES || await digest(bytes)!==doc.sha256)throw new Error('document_integrity_failure');
        return new Response(new Uint8Array(bytes).buffer,{headers:{...cors,
          'Content-Type':'application/octet-stream',
          'Content-Disposition':`attachment; filename="document"; filename*=UTF-8''${encodeURIComponent(String(doc.original_name)).replace(/['()*]/g,c=>'%'+c.charCodeAt(0).toString(16))}`,
          'Content-Security-Policy':"sandbox; default-src 'none'",
        }});
      }
      if(contentType!=='multipart/form-data')return json({error:'unsupported_media_type'},415);
      const submission=await parseSubmission(request);
      const prepared=await dependencies.rpc('mbn_prepare_native_test',{
        p_actor:actor,p_payload:submission.payload,p_details:submission.details,
        p_manifest:submission.manifest,p_fingerprint:submission.fingerprint,
      });
      if(prepared.error)databaseError(prepared.error);
      const draft=object(prepared.data);
      if(!UUID.test(String(draft.submission_id)) || draft.reference!==submission.payload.reference_dossier || typeof draft.completed!=='boolean')throw new Error('invalid_reservation');
      if(!draft.completed) {
        for(const file of submission.files) {
          await dependencies.upload(`${draft.submission_id}/${file.manifest.kind}.${file.manifest.extension}`,file);
        }
      }
      const completed=await dependencies.rpc('mbn_complete_native_test',{p_actor:actor,p_submission:draft.submission_id});
      if(completed.error)databaseError(completed.error);
      const result=receipt(completed.data,submission.payload.reference_dossier);
      return json(result,result.duplicated ? 200 : 201);
    } catch(error) {
      if(error instanceof InputError)return json({error:error.code},error.status);
      return json({error:'temporarily_unavailable',retryable:true},503);
    }
  };
}
