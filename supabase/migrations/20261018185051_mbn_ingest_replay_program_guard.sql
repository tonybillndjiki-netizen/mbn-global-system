begin;

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
  perform pg_advisory_xact_lock(hashtextextended('mbn-contact:'||v_school||':'||v_email,0));
  select a.id,a.school_code,a.campus_code,a.program_id,a.form_payload,l.email as lead_email
    into v_existing
  from public.crm_applications a join public.crm_leads l on l.id=a.lead_id
  where a.application_reference=v_ref;
  if found then
    if v_existing.school_code<>v_school or v_existing.campus_code<>v_campus
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
    where source=v_source and source_external_id=v_ref for update;
  if found then
    if v_lead.school_code<>v_school or lower(v_lead.email)<>v_email then
      raise sqlstate 'PT409' using message = 'lead_identity_conflict';
    end if;
  else
    select array_agg(candidate.id) into v_candidates from (
      select l.id from public.crm_leads l
      where l.school_code=v_school and lower(l.email)=v_email for update
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
      consent_source,status,submitted_at
    ) values (
      v_source,v_ref,v_school,v_campus,v_name,v_email,nullif(btrim(p_payload->>'phone'),''),
      v_country,v_program,coalesce(p_payload->'consent_email'='true'::jsonb,false),
      case when p_payload->'consent_email'='true'::jsonb then now() end,
      case when p_payload->'consent_email'='true'::jsonb then 'MBN_FORM' end,'SUBMITTED',now()
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
    admission_type,form_payload,source_system,external_crm_reference
  ) values (
    v_lead.id,v_school,v_campus,v_program,v_ref,
    case when upper(translate(v_country,'éÉçÇ','eEcC')) in ('FRANCE','FR','FRA','REPUBLIQUE FRANCAISE')
      then 'NATIONAL' else 'INTERNATIONAL' end,
    v_form,'MBN_GAS_V12',v_ref
  ) returning id into v_application;
  update public.crm_outreach_queue set status='CANCELED',canceled_at=now()
    where lead_id=v_lead.id and status in ('PENDING','FAILED');
  get diagnostics v_canceled=row_count;
  insert into public.crm_lead_events(lead_id,event_type,event_metadata)
    values(v_lead.id,'APPLICATION_SUBMITTED',jsonb_build_object(
      'reference',v_ref,'source_system','MBN_GAS_V12','outreach_canceled',v_canceled));
  return jsonb_build_object('success',true,'reference',v_ref,'duplicated',false,
    'outreach_canceled',v_canceled);
end;
$function$;

commit;
