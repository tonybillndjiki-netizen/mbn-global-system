begin;

-- Native test intake uses Supabase Auth; no Google runtime or shared webhook secret.
alter table public.crm_leads add column if not exists is_test boolean not null default false;
alter table public.crm_applications add column if not exists is_test boolean not null default false;
-- Keep test prospects out of ordinary collaborator views and real outreach.
alter policy "read_leads_by_school" on public.crm_leads
  using(not is_test and private.can_read_school(school_code));
alter policy "read_applications_by_school" on public.crm_applications
  using(not is_test and private.can_read_school(school_code));

create or replace function public.mbn_native_admin_access()
returns boolean language sql stable security invoker set search_path = '' as $$
  select private.is_mbn_admin() and exists(
    select 1 from public.profiles p where p.user_id=(select auth.uid()) and p.is_active
  );
$$;
revoke all on function public.mbn_native_admin_access() from public,anon;
grant execute on function public.mbn_native_admin_access() to authenticated;

-- Recheck the verified actor on every service-side reservation, completion or download.
create or replace function private.mbn_native_actor_allowed(p_actor uuid)
returns boolean language sql stable security invoker set search_path = '' as $$
  select exists(select 1 from auth.users u
    join private.admin_allowlist a on a.email=lower(u.email)
    join public.profiles p on p.user_id=u.id
    where u.id=p_actor and u.email_confirmed_at is not null and p.is_active);
$$;
revoke all on function private.mbn_native_actor_allowed(uuid) from public,anon,authenticated;
grant usage on schema private,auth to service_role;
grant select(id,email,email_confirmed_at) on auth.users to service_role;
grant select on private.admin_allowlist,public.profiles to service_role;
grant execute on function private.mbn_native_actor_allowed(uuid) to service_role;

create table public.native_test_submissions(
  id uuid primary key default gen_random_uuid(),
  reference text not null unique check(reference ~ '^MBNTEST-[a-f0-9-]{36}$'),
  actor_id uuid not null references public.profiles(user_id),
  fingerprint text not null check(fingerprint ~ '^[a-f0-9]{64}$'),
  payload jsonb not null check(jsonb_typeof(payload)='object'),
  details jsonb not null check(jsonb_typeof(details)='object'),
  manifest jsonb not null check(jsonb_typeof(manifest)='array'),
  application_id uuid unique references public.crm_applications(id) on delete cascade,
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  check((application_id is null)=(completed_at is null))
);
create index native_test_submissions_actor_idx on public.native_test_submissions(actor_id,created_at);
alter table public.native_test_submissions enable row level security;
create policy "native_tests_admin_read" on public.native_test_submissions
  for select to authenticated using((select public.mbn_native_admin_access()));
revoke all on public.native_test_submissions from anon,authenticated;
grant select on public.native_test_submissions to authenticated;
grant select,insert,update on public.native_test_submissions to service_role;

create table public.application_documents(
  id uuid primary key default gen_random_uuid(),
  submission_id uuid not null references public.native_test_submissions(id) on delete cascade,
  application_id uuid not null references public.crm_applications(id) on delete cascade,
  kind text not null check(kind in ('CV','DIPLOME','PIECE_IDENTITE','CARTE_VITALE','JUSTIFICATIF_HANDICAP','JUSTIFICATIF_PAIEMENT')),
  bucket text not null default 'mbn-native-test' check(bucket='mbn-native-test'),
  object_path text not null unique,
  original_name text not null check(length(original_name) between 1 and 180),
  mime_type text not null check(mime_type in ('application/pdf','image/png','image/jpeg')),
  byte_size integer not null check(byte_size between 1 and 5242880),
  sha256 text not null check(sha256 ~ '^[a-f0-9]{64}$'),
  scan_status text not null default 'NOT_SCANNED' check(scan_status='NOT_SCANNED'),
  created_at timestamptz not null default now(),
  unique(application_id,kind)
);
create index application_documents_submission_idx on public.application_documents(submission_id);
alter table public.application_documents enable row level security;
create policy "native_documents_admin_read" on public.application_documents
  for select to authenticated using((select public.mbn_native_admin_access()));
revoke all on public.application_documents from anon,authenticated;
grant select on public.application_documents to authenticated;
grant select,insert on public.application_documents to service_role;

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('mbn-native-test','mbn-native-test',false,5242880,array['application/pdf','image/png','image/jpeg'])
on conflict(id) do nothing;
-- Also deny this bucket if a broader storage policy is added in another module.
create policy "native_test_bucket_server_only" on storage.objects as restrictive
  for all to anon,authenticated
  using(bucket_id<>'mbn-native-test') with check(bucket_id<>'mbn-native-test');

create or replace function public.mbn_ingest_application(p_payload jsonb)
returns jsonb
language plpgsql
security invoker
set search_path = ''
as $function$
declare
  v_ref text := btrim(p_payload->>'reference_dossier');
  v_email text := lower(btrim(p_payload->>'email'));
  v_name text := btrim(p_payload->>'full_name');
  v_school text := upper(btrim(p_payload->>'school_code'));
  v_campus text := upper(btrim(p_payload->>'campus_code'));
  v_country text := btrim(p_payload->>'country_of_residence');
  v_source text := coalesce(nullif(p_payload->>'source',''),'DIRECT');
  v_is_test boolean := p_payload->'_native_test' = 'true'::jsonb;
  v_source_system text;
  v_program uuid;
  v_candidates uuid[];
  v_lead public.crm_leads%rowtype;
  v_existing record;
  v_alias record;
  v_application uuid;
  v_canceled integer := 0;
  v_form jsonb;
  v_key text;
  v_limit integer;
begin
  v_is_test := coalesce(v_is_test,false);
  v_source_system := case when v_is_test then 'MBN_SUPABASE_NATIVE_TEST' else 'MBN_SUPABASE_NATIVE' end;
  if p_payload is null or jsonb_typeof(p_payload) <> 'object'
    or p_payload->>'event' is distinct from 'application_submitted' then
    raise sqlstate 'PT400' using message = 'invalid_payload';
  end if;
  for v_key,v_limit in select * from (values
    ('reference_dossier',90),('email',254),('full_name',180),
    ('school_code',120),('campus_code',60),('country_of_residence',120),
    ('phone',60),('program_id',36),('program_name',250),('cycle',180),
    ('academic_level',120),('domain',180),('pace',180),('source',30)
  ) limits(field_name,max_length) loop
    if p_payload ? v_key and (
      jsonb_typeof(p_payload->v_key) not in ('string','null')
      or length(p_payload->>v_key)>v_limit
    ) then
      raise sqlstate 'PT400' using message = 'invalid_field';
    end if;
  end loop;
  if v_ref is null or v_ref !~ '^[A-Za-z0-9][A-Za-z0-9._-]{3,89}$'
    or v_email is null or v_email !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'
    or coalesce(v_name,'')='' or coalesce(v_school,'')=''
    or coalesce(v_campus,'')='' or coalesce(v_country,'')=''
    or v_source not in ('META_LEAD','META_MESSENGER','DIRECT','IMPORT','OTHER') then
    raise sqlstate 'PT400' using message = 'invalid_fields';
  end if;
  if nullif(p_payload->>'program_id','') is not null then
    if p_payload->>'program_id' !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then
      raise sqlstate 'PT400' using message = 'invalid_program_id';
    end if;
    v_program := (p_payload->>'program_id')::uuid;
  elsif coalesce(btrim(p_payload->>'program_name'),'')='' then
    raise sqlstate 'PT422' using message = 'program_required';
  end if;

  select target_school,target_campus into v_alias
  from public.form_route_aliases
  where source_school=v_school and source_campus=v_campus and is_active
  for share;
  if found then
    v_school:=v_alias.target_school;
    v_campus:=v_alias.target_campus;
  else
    v_school:=case v_school
      when 'MARNE LA VALLEE BTS' then 'MLV BTS'
      when 'MLV-BS' then 'MLV BS'
      when 'MLV BUSINESS SCHOOL' then 'MLV BS'
      when 'MARNE LA VALLEE BUSINESS SCHOOL' then 'MLV BS'
      when 'MARNE-LA-VALLEE BUSINESS SCHOOL' then 'MLV BS'
      when 'EVRY BUSINESS SCHOOL' then 'EVRY BS'
      when 'EVRY-BTS' then 'EVRY BTS'
      when 'DCG FORMATION' then 'DCG FORMATIONS'
      when 'DCG' then 'DCG FORMATIONS'
      when 'ESIA' then 'ESIIA'
      when 'ISMODE' then 'ISMOD'
      when 'ESMASS' then 'ESMAS'
      else v_school end;
  end if;
  v_form:=jsonb_build_object(
    'cycle',coalesce(btrim(p_payload->>'cycle'),''),
    'academic_level',coalesce(btrim(p_payload->>'academic_level'),''),
    'domain',coalesce(btrim(p_payload->>'domain'),''),
    'formation',coalesce(btrim(p_payload->>'program_name'),''),
    'pace',coalesce(btrim(p_payload->>'pace'),'')
  );

  -- Serialize both replays of one reference and simultaneous submissions by one contact.
  perform pg_advisory_xact_lock(hashtextextended('mbn-ref:'||v_ref,0));
  perform pg_advisory_xact_lock(hashtextextended('mbn-contact:'||v_is_test::text||':'||v_school||':'||v_email,0));
  select a.id,a.is_test,a.school_code,a.campus_code,a.program_id,a.form_payload,l.email as lead_email
    into v_existing
  from public.crm_applications a join public.crm_leads l on l.id=a.lead_id
  where a.application_reference=v_ref;
  if found then
    if v_existing.is_test<>v_is_test or v_existing.school_code<>v_school or v_existing.campus_code<>v_campus
      or lower(v_existing.lead_email)<>v_email or v_existing.form_payload<>v_form
      or (v_program is not null and v_existing.program_id is distinct from v_program) then
      raise sqlstate 'PT409' using message = 'reference_conflict';
    end if;
    -- An already accepted submission can be acknowledged after a school is closed.
    return jsonb_build_object('success',true,'reference',v_ref,'duplicated',true);
  end if;

  perform 1 from public.schools where code=v_school and is_active for share;
  if not found then
    raise sqlstate 'PT422' using message = 'school_inactive_or_unknown';
  end if;
  perform 1 from public.school_campuses
    where school_code=v_school and campus_code=v_campus for share;
  if not found then
    raise sqlstate 'PT422' using message = 'campus_not_allowed';
  end if;
  select array_agg(candidate.id) into v_candidates from (
    select p.id from public.school_programs p
    where p.school_code=v_school and p.is_active
      and (v_program is null or p.id=v_program)
      and (coalesce(p_payload->>'program_name','')='' or lower(btrim(p.name))=lower(btrim(p_payload->>'program_name')))
      and (coalesce(p_payload->>'cycle','')='' or p.cycle is null or lower(btrim(p.cycle))=lower(btrim(p_payload->>'cycle')))
      and (coalesce(p_payload->>'academic_level','')='' or p.academic_level is null or lower(btrim(p.academic_level))=lower(btrim(p_payload->>'academic_level')))
      and (coalesce(p_payload->>'domain','')='' or p.domain is null or lower(btrim(p.domain))=lower(btrim(p_payload->>'domain')))
      and (coalesce(p_payload->>'pace','')='' or p.pace is null or lower(btrim(p.pace))=lower(btrim(p_payload->>'pace')))
    for share
  ) candidate;
  if coalesce(array_length(v_candidates,1),0)=0 then
    raise sqlstate 'PT422' using message = 'program_not_found';
  elsif array_length(v_candidates,1)>1 then
    raise sqlstate 'PT422' using message = 'program_ambiguous';
  end if;
  v_program:=v_candidates[1];

  select * into v_lead from public.crm_leads
    where source=v_source and source_external_id=v_ref and is_test=v_is_test for update;
  if found then
    if v_lead.school_code<>v_school or lower(v_lead.email)<>v_email then
      raise sqlstate 'PT409' using message = 'lead_identity_conflict';
    end if;
  else
    select array_agg(candidate.id) into v_candidates from (
      select l.id from public.crm_leads l
      where l.school_code=v_school and lower(l.email)=v_email and l.is_test=v_is_test for update
    ) candidate;
    if coalesce(array_length(v_candidates,1),0)>1 then
      raise sqlstate 'PT409' using message = 'lead_identity_ambiguous';
    elsif array_length(v_candidates,1)=1 then
      select * into v_lead from public.crm_leads where id=v_candidates[1];
    end if;
  end if;
  if v_lead.id is null then
    insert into public.crm_leads(
      source,source_external_id,school_code,campus_code,full_name,email,phone,
      country_of_residence,program_id,consent_email,consent_recorded_at,
      consent_source,status,submitted_at,is_test
    ) values (
      v_source,v_ref,v_school,v_campus,v_name,v_email,nullif(btrim(p_payload->>'phone'),''),
      v_country,v_program,coalesce(p_payload->'consent_email'='true'::jsonb,false),
      case when p_payload->'consent_email'='true'::jsonb then now() end,
      case when p_payload->'consent_email'='true'::jsonb then 'MBN_FORM' end,'SUBMITTED',now(),v_is_test
    ) returning * into v_lead;
  else
    -- Do not turn a new submission into renewed marketing consent, or erase attribution.
    update public.crm_leads set
      status=case when status in ('UNSUBSCRIBED','DISQUALIFIED') then status else 'SUBMITTED' end,
      submitted_at=coalesce(submitted_at,now()),updated_at=now(),
      campus_code=v_campus,program_id=v_program
    where id=v_lead.id;
  end if;
  insert into public.crm_applications(
    lead_id,school_code,campus_code,program_id,application_reference,
    admission_type,form_payload,source_system,external_crm_reference,is_test
  ) values (
    v_lead.id,v_school,v_campus,v_program,v_ref,
    case when upper(translate(v_country,'éÉçÇ','eEcC')) in ('FRANCE','FR','FRA','REPUBLIQUE FRANCAISE')
      then 'NATIONAL' else 'INTERNATIONAL' end,
    v_form,v_source_system,v_ref,v_is_test
  ) returning id into v_application;
  update public.crm_outreach_queue set status='CANCELED',canceled_at=now()
    where lead_id=v_lead.id and status in ('PENDING','FAILED');
  get diagnostics v_canceled=row_count;
  insert into public.crm_lead_events(lead_id,event_type,event_metadata)
    values(v_lead.id,'APPLICATION_SUBMITTED',jsonb_build_object(
      'reference',v_ref,'source_system',v_source_system,'outreach_canceled',v_canceled));
  return jsonb_build_object('success',true,'reference',v_ref,'duplicated',false,
    'outreach_canceled',v_canceled);
end;
$function$;


-- Reserve before uploading. The durable manifest makes timeouts resumable, without
-- deleting documents whose final database commit may already have succeeded.
create or replace function public.mbn_prepare_native_test(
  p_actor uuid,p_payload jsonb,p_details jsonb,p_manifest jsonb,p_fingerprint text)
returns jsonb language plpgsql security invoker set search_path = '' as $fn$
declare
  v_row public.native_test_submissions%rowtype;
  v_doc jsonb;
  v_total bigint := 0;
  v_kinds text[] := '{}';
  v_ref text := p_payload->>'reference_dossier';
begin
  if not private.mbn_native_actor_allowed(p_actor) then
    raise sqlstate 'PT403' using message='admin_required';
  end if;
  if p_fingerprint is null or p_fingerprint !~ '^[a-f0-9]{64}$'
    or v_ref is null or v_ref !~ '^MBNTEST-[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$'
    or jsonb_typeof(p_payload) is distinct from 'object'
    or jsonb_typeof(p_details) is distinct from 'object'
    or jsonb_typeof(p_manifest) is distinct from 'array'
    or length(p_payload::text)>16384 or length(p_details::text)>8192
    or jsonb_array_length(p_manifest)>6 then
    raise sqlstate 'PT400' using message='invalid_payload';
  end if;
  perform pg_advisory_xact_lock(hashtextextended('mbn-native:'||v_ref,0));
  select * into v_row from public.native_test_submissions where reference=v_ref for update;
  if found then
    if v_row.actor_id<>p_actor or v_row.fingerprint<>p_fingerprint
      or v_row.payload<>p_payload or v_row.details<>p_details or v_row.manifest<>p_manifest then
      raise sqlstate 'PT409' using message='reference_conflict';
    end if;
    return jsonb_build_object('submission_id',v_row.id,'reference',v_ref,
      'completed',v_row.completed_at is not null,'application_id',v_row.application_id);
  end if;
  -- Only known active catalogue identifiers may allocate document storage.
  if not exists(select 1 from public.schools s
    join public.school_campuses c on c.school_code=s.code
    join public.school_programs p on p.school_code=s.code
    where s.code=p_payload->>'school_code' and c.campus_code=p_payload->>'campus_code'
      and p.id::text=p_payload->>'program_id' and p.is_active and s.is_active) then
    raise sqlstate 'PT422' using message='catalogue_selection_invalid';
  end if;
  for v_doc in select value from jsonb_array_elements(p_manifest) loop
    if jsonb_typeof(v_doc) is distinct from 'object'
      or coalesce(v_doc->>'kind','') not in ('CV','DIPLOME','PIECE_IDENTITE','CARTE_VITALE','JUSTIFICATIF_HANDICAP','JUSTIFICATIF_PAIEMENT')
      or v_doc->>'kind'=any(v_kinds)
      or coalesce(v_doc->>'mime_type','') not in ('application/pdf','image/png','image/jpeg')
      or coalesce(v_doc->>'byte_size','') !~ '^[0-9]{1,8}$'
      or coalesce(v_doc->>'sha256','') !~ '^[a-f0-9]{64}$'
      or coalesce(v_doc->>'extension','') not in ('pdf','png','jpg')
      or (v_doc->>'mime_type'='application/pdf' and v_doc->>'extension'<>'pdf')
      or (v_doc->>'mime_type'='image/png' and v_doc->>'extension'<>'png')
      or (v_doc->>'mime_type'='image/jpeg' and v_doc->>'extension'<>'jpg')
      or coalesce(length(v_doc->>'original_name'),0) not between 1 and 180 then
      raise sqlstate 'PT400' using message='invalid_document';
    end if;
    if (v_doc->>'byte_size')::bigint not between 1 and 5242880 then
      raise sqlstate 'PT413' using message='file_too_large';
    end if;
    v_total:=v_total+(v_doc->>'byte_size')::bigint;
    v_kinds:=array_append(v_kinds,v_doc->>'kind');
  end loop;
  if v_total>20971520 then raise sqlstate 'PT413' using message='files_too_large'; end if;
  perform pg_advisory_xact_lock(hashtextextended('mbn-native-actor:'||p_actor::text,0));
  if (select count(*) from public.native_test_submissions where actor_id=p_actor
      and created_at>now()-interval '1 hour')>=50 then
    raise sqlstate 'PT429' using message='test_quota_reached';
  end if;
  insert into public.native_test_submissions(reference,actor_id,fingerprint,payload,details,manifest)
    values(v_ref,p_actor,p_fingerprint,p_payload,p_details,p_manifest) returning * into v_row;
  return jsonb_build_object('submission_id',v_row.id,'reference',v_ref,'completed',false);
end;$fn$;
revoke all on function public.mbn_prepare_native_test(uuid,jsonb,jsonb,jsonb,text) from public,anon,authenticated;
grant execute on function public.mbn_prepare_native_test(uuid,jsonb,jsonb,jsonb,text) to service_role;

create or replace function public.mbn_complete_native_test(p_actor uuid,p_submission uuid)
returns jsonb language plpgsql security invoker set search_path = '' as $fn$
declare
  v_row public.native_test_submissions%rowtype;
  v_result jsonb;
  v_app uuid;
  v_doc jsonb;
  v_path text;
begin
  if not private.mbn_native_actor_allowed(p_actor) then
    raise sqlstate 'PT403' using message='admin_required';
  end if;
  select * into v_row from public.native_test_submissions where id=p_submission for update;
  if not found or v_row.actor_id<>p_actor then
    raise sqlstate 'PT404' using message='submission_not_found';
  end if;
  if v_row.completed_at is not null then
    return jsonb_build_object('success',true,'reference',v_row.reference,
      'duplicated',true,'test',true,'application_id',v_row.application_id,
      'document_count',jsonb_array_length(v_row.manifest));
  end if;
  -- The Storage API has to have durably accepted each immutable object first.
  for v_doc in select value from jsonb_array_elements(v_row.manifest) loop
    v_path:=v_row.id::text||'/'||(v_doc->>'kind')||'.'||(v_doc->>'extension');
    if not exists(select 1 from storage.objects o
      where o.bucket_id='mbn-native-test' and o.name=v_path
      and o.metadata->>'size'=v_doc->>'byte_size'
      and o.metadata->>'mimetype'=v_doc->>'mime_type') then
      raise sqlstate 'PT409' using message='documents_pending';
    end if;
  end loop;
  v_result:=public.mbn_ingest_application(v_row.payload||jsonb_build_object('_native_test',true));
  select id into v_app from public.crm_applications
    where application_reference=v_row.reference and is_test;
  if v_app is null then raise exception 'native_application_missing'; end if;
  for v_doc in select value from jsonb_array_elements(v_row.manifest) loop
    insert into public.application_documents(submission_id,application_id,kind,object_path,
      original_name,mime_type,byte_size,sha256)
    values(v_row.id,v_app,v_doc->>'kind',v_row.id::text||'/'||(v_doc->>'kind')||'.'||(v_doc->>'extension'),
      v_doc->>'original_name',v_doc->>'mime_type',(v_doc->>'byte_size')::integer,v_doc->>'sha256');
  end loop;
  update public.native_test_submissions set application_id=v_app,completed_at=now() where id=v_row.id;
  return v_result||jsonb_build_object('test',true,'application_id',v_app,
    'document_count',jsonb_array_length(v_row.manifest));
end;$fn$;
revoke all on function public.mbn_complete_native_test(uuid,uuid) from public,anon,authenticated;
grant execute on function public.mbn_complete_native_test(uuid,uuid) to service_role;
grant select on storage.objects to service_role;

-- No public object paths are accepted by the HTTP download endpoint.
create or replace function public.mbn_native_document(p_actor uuid,p_document uuid)
returns jsonb language plpgsql security invoker set search_path = '' as $fn$
declare v_doc public.application_documents%rowtype;
begin
  if not private.mbn_native_actor_allowed(p_actor) then
    raise sqlstate 'PT403' using message='admin_required';
  end if;
  select * into v_doc from public.application_documents where id=p_document;
  if not found then raise sqlstate 'PT404' using message='document_not_found'; end if;
  return jsonb_build_object('bucket',v_doc.bucket,'object_path',v_doc.object_path,
    'original_name',v_doc.original_name,'mime_type',v_doc.mime_type,'sha256',v_doc.sha256);
end;$fn$;
revoke all on function public.mbn_native_document(uuid,uuid) from public,anon,authenticated;
grant execute on function public.mbn_native_document(uuid,uuid) to service_role;

commit;
