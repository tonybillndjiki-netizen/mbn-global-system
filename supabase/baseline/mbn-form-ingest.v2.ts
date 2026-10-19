
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2.57.2";

const json = (payload, status = 200) => new Response(JSON.stringify(payload), {
  status,
  headers: { "Content-Type": "application/json; charset=utf-8", "Cache-Control": "no-store" },
});
const txt = (value, limit = 180) => String(value ?? "").trim().slice(0, limit);
function eqSecret(a, b) {
  const encoder = new TextEncoder();
  const left = encoder.encode(a), right = encoder.encode(b);
  let diff = left.length ^ right.length;
  const max = Math.max(left.length, right.length);
  for (let i = 0; i < max; i++) diff |= (left[i] ?? 0) ^ (right[i] ?? 0);
  return diff === 0;
}
const allowedSources = new Set(["META_LEAD","META_MESSENGER","DIRECT","IMPORT","OTHER"]);
const schoolAliases = {
  "MARNE LA VALLEE BTS": "MLV BTS",
  "MARNE LA VALLEE BUSINESS SCHOOL": "MLV BS",
  "MARNE-LA-VALLEE BUSINESS SCHOOL": "MLV BS",
  "EVRY BUSINESS SCHOOL": "EVRY BS",
  "DCG FORMATION": "DCG FORMATIONS",
  "ESIA": "ESIIA",
  "ISMODE": "ISMOD",
  "ESMASS": "ESMAS",
};
const normalizeSchool = v => txt(v,120).normalize("NFD").replace(/[\u0300-\u036f]/g,"").toUpperCase();
const normalizeCampus = v => txt(v,60).normalize("NFD").replace(/[\u0300-\u036f]/g,"").toUpperCase();

Deno.serve(async req => {
  if (req.method === "GET") return json({ service: "mbn-form-ingest", status: "online" });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const expected = Deno.env.get("MBN_WEBHOOK_SECRET") || "";
  if (expected.length < 32) return json({ error: "server_not_configured" }, 503);
  const provided = req.headers.get("x-mbn-webhook-secret") || "";
  if (!provided || !eqSecret(provided, expected)) return json({ error: "unauthorized" }, 401);

  let incoming;
  try {
    const body = await req.text();
    if (body.length > 16000) return json({ error: "payload_too_large" }, 413);
    incoming = JSON.parse(body);
  } catch (_) { return json({ error: "invalid_json" }, 400); }
  if (!incoming || typeof incoming !== "object" || Array.isArray(incoming)) return json({ error: "invalid_data" }, 400);
  if (incoming.event !== "application_submitted") return json({ error: "unsupported_event" }, 400);

  const ref = txt(incoming.reference_dossier, 90);
  const email = txt(incoming.email, 254).toLowerCase();
  const name = txt(incoming.full_name, 180);
  const country = txt(incoming.country_of_residence, 120);
  const phone = txt(incoming.phone, 60);
  let schoolCode = normalizeSchool(incoming.school_code);
  let campusCode = normalizeCampus(incoming.campus_code);
  if (!/^[A-Za-z0-9][A-Za-z0-9._-]{3,89}$/.test(ref)
    || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
    || !name || !schoolCode || !campusCode || !country)
    return json({ error: "missing_or_invalid_fields" }, 400);

  const url = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !serviceKey) return json({ error: "db_not_configured" }, 503);
  const db = createClient(url, serviceKey, { auth: { autoRefreshToken: false, persistSession: false } });

  const { data: alias, error: aliasError } = await db.from("form_route_aliases")
    .select("target_school,target_campus")
    .eq("source_school", schoolCode).eq("source_campus", campusCode)
    .eq("is_active", true).maybeSingle();
  if (aliasError) return json({ error: "routing_lookup_failed" }, 500);
  if (alias) {
    schoolCode = alias.target_school;
    campusCode = alias.target_campus;
  } else {
    schoolCode = schoolAliases[schoolCode] || schoolCode;
  }

  const { data: school, error: schoolError } = await db.from("schools")
    .select("code,is_active").eq("code",schoolCode).maybeSingle();
  if (schoolError) return json({ error: "school_lookup_failed" }, 500);
  if (!school || !school.is_active) return json({ error: "school_inactive_or_unknown" }, 422);
  const { data: route, error: routeError } = await db.from("school_campuses")
    .select("campus_code").eq("school_code",schoolCode).eq("campus_code",campusCode).maybeSingle();
  if (routeError) return json({ error: "campus_lookup_failed" }, 500);
  if (!route) return json({ error: "campus_not_allowed" }, 422);

  let programId = null;
  if (incoming.program_id) {
    const { data: program } = await db.from("school_programs")
      .select("id").eq("id",txt(incoming.program_id,80))
      .eq("school_code",schoolCode).eq("is_active",true).maybeSingle();
    if (!program) return json({ error: "program_not_found" }, 422);
    programId = program.id;
  } else if (incoming.program_name) {
    const { data: programs } = await db.from("school_programs")
      .select("id").eq("school_code",schoolCode).eq("name",txt(incoming.program_name,250))
      .eq("is_active",true).limit(1);
    programId = programs?.[0]?.id ?? null;
  }
  const src = allowedSources.has(incoming.source) ? incoming.source : "DIRECT";
  const { data: found, error: foundError } = await db.from("crm_leads")
    .select("id").eq("source",src).eq("source_external_id",ref).maybeSingle();
  if (foundError) return json({ error: "lead_lookup_failed" }, 500);
  let leadId = found?.id ?? null;
  if (!leadId) {
    const { data: inserted, error } = await db.from("crm_leads")
      .insert({
        source:src, source_external_id:ref, school_code:schoolCode, campus_code:campusCode,
        full_name:name, email, phone: phone || null,
        country_of_residence:country, program_id:programId,
        consent_email:incoming.consent_email === true,
        consent_recorded_at:incoming.consent_email === true ? new Date().toISOString() : null,
        consent_source:incoming.consent_email === true ? "MBN_FORM" : null,
        status:"SUBMITTED", submitted_at:new Date().toISOString(),
      }).select("id").single();
    if (error) {
      if (error.code !== "23505") return json({ error: "lead_insert_failed" }, 500);
      const retry = await db.from("crm_leads").select("id")
        .eq("source",src).eq("source_external_id",ref).maybeSingle();
      leadId = retry.data?.id ?? null;
      if (!leadId) return json({ error: "idempotency_failed" }, 500);
    } else leadId = inserted.id;
  }
  const { data: existingApp, error: existingError } = await db.from("crm_applications")
    .select("id").eq("application_reference",ref).maybeSingle();
  if (existingError) return json({ error: "application_lookup_failed" }, 500);
  if (existingApp) return json({ success:true, reference:ref, duplicated:true },200);

  const countryNorm = country.normalize("NFD").replace(/[\u0300-\u036f]/g,"").toUpperCase();
  const admissionType = ["FRANCE","FR","FRA","REPUBLIQUE FRANCAISE"].includes(countryNorm)
    ? "NATIONAL" : "INTERNATIONAL";
  const safeForm = {
    cycle:txt(incoming.cycle,180), academic_level:txt(incoming.academic_level,120),
    domain:txt(incoming.domain,180), formation:txt(incoming.program_name,250),
    pace:txt(incoming.pace,180),
  };
  const { error: appError } = await db.from("crm_applications").insert({
    lead_id:leadId, school_code:schoolCode, campus_code:campusCode,
    program_id:programId, application_reference:ref,
    admission_type:admissionType, form_payload:safeForm,
    source_system:"MBN_GAS_V12", external_crm_reference:ref,
  });
  if (appError) {
    if(appError.code === "23505") return json({ success:true, reference:ref, duplicated:true },200);
    return json({ error:"application_insert_failed" },500);
  }
  await db.from("crm_lead_events").insert({ lead_id:leadId,
    event_type:"APPLICATION_SUBMITTED", event_metadata: { reference:ref, source_system:"MBN_GAS_V12" } });
  return json({ success:true, reference:ref, duplicated:false },201);
});

