type RpcReply = { data: unknown; error: { code?: string; message?: string } | null };
export type Database = { rpc(name: string, args: Record<string, unknown>): PromiseLike<RpcReply> };
export type Dependencies = { secret(): string; database(): Database };
const MAX_BYTES = 16_384;
const fields: Record<string, number> = {
  reference_dossier: 90, email: 254, full_name: 180, school_code: 120,
  campus_code: 60, country_of_residence: 120, phone: 60, program_id: 36,
  program_name: 250, cycle: 180, academic_level: 120, domain: 180, pace: 180,
};
const required = new Set(['reference_dossier','email','full_name','school_code','campus_code','country_of_residence']);
const sources = new Set(['META_LEAD','META_MESSENGER','DIRECT','IMPORT','OTHER']);
const publicErrors = new Set([
  'invalid_payload','invalid_field','invalid_fields','invalid_program_id',
  'program_required','program_not_found','program_ambiguous','reference_conflict',
  'lead_identity_conflict','lead_identity_ambiguous','school_inactive_or_unknown','campus_not_allowed',
]);
const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), {
  status, headers: { 'Content-Type':'application/json; charset=utf-8', 'Cache-Control':'no-store' },
});
class InputError extends Error {
  constructor(public code: string, public status = 400) { super(code); }
}
function equalSecret(left: string, right: string) {
  const encoder = new TextEncoder();
  const a = encoder.encode(left), b = encoder.encode(right);
  let diff = a.length ^ b.length;
  for (let i = 0; i < Math.max(a.length,b.length); i++) diff |= (a[i] ?? 0) ^ (b[i] ?? 0);
  return diff === 0;
}
async function readBody(request: Request): Promise<unknown> {
  const contentLength = request.headers.get('content-length');
  if (contentLength && Number(contentLength)>MAX_BYTES) throw new InputError('payload_too_large',413);
  if (!request.body) throw new InputError('invalid_json');
  const reader = request.body.getReader();
  const chunks: Uint8Array[] = [];
  let total = 0;
  try {
    for (;;) {
      const {done,value} = await reader.read();
      if (done) break;
      total += value.byteLength;
      if (total>MAX_BYTES) { await reader.cancel(); throw new InputError('payload_too_large',413); }
      chunks.push(value);
    }
    const bytes = new Uint8Array(total);
    let offset = 0;
    for (const chunk of chunks) { bytes.set(chunk,offset); offset += chunk.length; }
    return JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes));
  } catch (error) {
    if (error instanceof InputError) throw error;
    throw new InputError('invalid_json');
  } finally { reader.releaseLock(); }
}
export function normalizePayload(value: unknown): Record<string, unknown> {
  if (!value || typeof value!=='object' || Array.isArray(value)) throw new InputError('invalid_data');
  const input = value as Record<string, unknown>;
  if (input.event!=='application_submitted') throw new InputError('unsupported_event');
  const payload: Record<string, unknown> = { event:'application_submitted' };
  for (const [field,max] of Object.entries(fields)) {
    const raw = input[field];
    if (raw !== undefined && raw !== null && typeof raw!=='string') throw new InputError('invalid_field');
    const text = typeof raw==='string' ? raw.trim() : '';
    if (text.length>max || (required.has(field) && !text)) throw new InputError('invalid_field');
    payload[field]=text;
  }
  if (!/^[A-Za-z0-9][A-Za-z0-9._-]{3,89}$/.test(String(payload.reference_dossier))) throw new InputError('invalid_reference');
  payload.email=String(payload.email).toLowerCase();
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(payload.email))) throw new InputError('invalid_email');
  for (const field of ['school_code','campus_code']) {
    payload[field]=String(payload[field]).normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/\s+/g,' ').toUpperCase();
  }
  if (payload.program_id && !/^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/i.test(String(payload.program_id))) throw new InputError('invalid_program_id');
  if (!payload.program_id && !payload.program_name) throw new InputError('program_required',422);
  const source=input.source ?? 'DIRECT';
  if (typeof source!=='string' || !sources.has(source)) throw new InputError('invalid_source');
  payload.source=source;
  payload.consent_email=input.consent_email===true;
  return payload;
}
export function createHandler(dependencies: Dependencies) {
  return async (request: Request): Promise<Response> => {
    if (request.method==='GET') return json({service:'mbn-form-ingest',status:'online',version:3});
    if (request.method!=='POST') return json({error:'method_not_allowed'},405);
    const expected=dependencies.secret();
    if (expected.length<32 || expected.length>512) return json({error:'server_not_configured'},503);
    const provided=request.headers.get('x-mbn-webhook-secret') ?? '';
    if (!provided || provided.length>512 || !equalSecret(provided,expected)) return json({error:'unauthorized'},401);
    if (request.headers.get('content-type')?.split(';')[0].trim().toLowerCase()!=='application/json') return json({error:'unsupported_media_type'},415);
    try {
      const payload=normalizePayload(await readBody(request));
      const {data,error}=await dependencies.database().rpc('mbn_ingest_application',{p_payload:payload});
      if (error) {
        const known=publicErrors.has(error.message ?? '');
        const status=known && /^PT(400|409|422)$/.test(error.code ?? '') ? Number(error.code!.slice(2)) : 503;
        return json({error:known ? error.message : 'synchronization_failed'},status);
      }
      const result=data as {success?:boolean;reference?:string;duplicated?:boolean} | null;
      if (result?.success!==true || result.reference!==payload.reference_dossier || typeof result.duplicated!=='boolean') return json({error:'invalid_database_response'},503);
      return json(result,result.duplicated ? 200 : 201);
    } catch (error) {
      if (error instanceof InputError) return json({error:error.code},error.status);
      return json({error:'synchronization_failed'},503);
    }
  };
}
