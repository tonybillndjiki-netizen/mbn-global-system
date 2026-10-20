-- Admission letter parameters belong to the school and admission flow.
-- No historical fee, signatory or intake is silently adopted by this migration.
create table private.mbn_school_letter_settings(
 school_code text not null references public.schools(code),
 admission_type text not null check(admission_type in ('NATIONAL','INTERNATIONAL')),
 fields jsonb not null default '{}' check(jsonb_typeof(fields)='object'),
 enabled boolean not null default false,revision uuid not null default gen_random_uuid(),
 updated_by uuid references public.profiles(user_id),updated_at timestamptz not null default now(),
 primary key(school_code,admission_type)
);
alter table private.mbn_school_letter_settings enable row level security;
revoke all on private.mbn_school_letter_settings from public,anon,authenticated;
grant select,insert,update on private.mbn_school_letter_settings to service_role;
insert into private.mbn_school_letter_settings(school_code,admission_type)
 select s.code,t from public.schools s cross join unnest(array['NATIONAL','INTERNATIONAL']) t;

create table private.mbn_letter_settings_events(
 id uuid primary key default gen_random_uuid(),school_code text not null,admission_type text not null,
 actor_id uuid not null references public.profiles(user_id),revision uuid not null,
 fields jsonb not null,enabled boolean not null,created_at timestamptz not null default now()
);
alter table private.mbn_letter_settings_events enable row level security;
revoke all on private.mbn_letter_settings_events from public,anon,authenticated;
grant select,insert on private.mbn_letter_settings_events to service_role;

create function private.mbn_letter_validate_settings(p_type text,p_fields jsonb) returns void
language plpgsql security invoker set search_path='' as $$
begin
 if p_type not in ('NATIONAL','INTERNATIONAL') or jsonb_typeof(p_fields) is distinct from 'object'
  then raise sqlstate 'PT422' using message='invalid_letter_settings';end if;
 if exists(select 1 from jsonb_each(p_fields) e where e.key not in
  ('academic_year','intake','deferred_intake','registration_fee','tuition_deposit','confirmation_days','signatory','avi_mode')
  or jsonb_typeof(e.value)<>'string' or (e.value#>>'{}')<>btrim(e.value#>>'{}') or (e.value#>>'{}')~'[[:cntrl:]]')
  or coalesce(p_fields->>'academic_year','')!~'^20[0-9]{2}/20[0-9]{2}$'
  or length(coalesce(p_fields->>'intake','')) not between 3 and 80
  or length(coalesce(p_fields->>'signatory','')) not between 1 and 120
  or coalesce(p_fields->>'registration_fee','')!~'^[0-9]{1,5}(\.[0-9]{1,2})?$'
  or coalesce(p_fields->>'tuition_deposit','')!~'^[0-9]{1,5}(\.[0-9]{1,2})?$'
  or coalesce(p_fields->>'confirmation_days','')!~'^[0-9]{1,2}$'
  then raise sqlstate 'PT422' using message='invalid_letter_settings';end if;
 if substring(p_fields->>'academic_year',6,4)::integer<>substring(p_fields->>'academic_year',1,4)::integer+1
  or (p_fields->>'confirmation_days')::integer not between 1 and 90
  or (p_type='NATIONAL' and (coalesce(p_fields->>'avi_mode','')<>'NONE' or coalesce(p_fields->>'deferred_intake','')<>''))
  or (p_type='INTERNATIONAL' and (coalesce(p_fields->>'avi_mode','') not in ('OPTIONAL','REQUIRED')
   or length(coalesce(p_fields->>'deferred_intake','')) not between 3 and 80))
  then raise sqlstate 'PT422' using message='invalid_letter_settings';end if;
end;$$;

create function public.mbn_letter_config_action(p_actor uuid,p_session uuid,p_action text,p_data jsonb default '{}') returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_ctx jsonb;v_setting private.mbn_school_letter_settings;v_school text;v_type text;
begin
 v_ctx:=public.mbn_pin_context(p_actor,p_session,p_actor);
 if not coalesce((v_ctx->>'admin')::boolean,false) then raise sqlstate 'PT403' using message='access_denied';end if;
 if jsonb_typeof(p_data) is distinct from 'object' then raise sqlstate 'PT400' using message='invalid_request';end if;
 if p_action='get' then
  if p_data<>'{}'::jsonb then raise sqlstate 'PT400' using message='invalid_request';end if;
  return jsonb_build_object('schools',(select coalesce(jsonb_agg(jsonb_build_object('code',code,'name',name,'is_active',is_active) order by name),'[]') from public.schools),
   'settings',(select coalesce(jsonb_agg(to_jsonb(s) order by school_code,admission_type),'[]') from private.mbn_school_letter_settings s));
 elsif p_action<>'save' then raise sqlstate 'PT400' using message='unknown_action';end if;
 v_school:=p_data->>'school_code';v_type:=p_data->>'admission_type';
 if exists(select 1 from jsonb_object_keys(p_data) k where k not in ('school_code','admission_type','expected_revision','fields','enabled'))
  or coalesce(v_type,'') not in ('NATIONAL','INTERNATIONAL')
  or jsonb_typeof(p_data->'enabled') is distinct from 'boolean'
  or not exists(select 1 from public.schools where code=v_school and is_active)
  then raise sqlstate 'PT422' using message='invalid_letter_settings';end if;
 perform private.mbn_letter_validate_settings(v_type,p_data->'fields');
 select * into v_setting from private.mbn_school_letter_settings where school_code=v_school and admission_type=v_type for update;
 if not found or v_setting.revision::text is distinct from p_data->>'expected_revision' then raise sqlstate 'PT409' using message='letter_settings_changed';end if;
 if v_setting.fields=p_data->'fields' and v_setting.enabled=(p_data->>'enabled')::boolean then return to_jsonb(v_setting);end if;
 update private.mbn_school_letter_settings set fields=p_data->'fields',enabled=(p_data->>'enabled')::boolean,revision=gen_random_uuid(),updated_by=p_actor,updated_at=now()
  where school_code=v_school and admission_type=v_type returning * into v_setting;
 insert into private.mbn_letter_settings_events(school_code,admission_type,actor_id,revision,fields,enabled)
  values(v_school,v_type,p_actor,v_setting.revision,v_setting.fields,v_setting.enabled);
 return to_jsonb(v_setting);
end;$$;

-- Historical PDF snapshots remain downloadable. New preparations always use
-- the server's school settings; the client cannot supply a fee or a signatory.
alter function public.mbn_letter_action(uuid,uuid,text,jsonb) rename to mbn_letter_action_international_v1;

create function private.mbn_letter_snapshot_current(p_letter private.mbn_admission_letters) returns boolean
language sql stable security invoker set search_path='' as $$
 select exists(select 1 from public.crm_applications a join public.crm_leads l on l.id=a.lead_id
  join private.mbn_school_letter_settings s on s.school_code=a.school_code and s.admission_type=a.admission_type
  where a.id=p_letter.application_id and not a.is_test and not l.is_test and a.status='ADMITTED' and s.enabled
   and p_letter.fields->>'config_revision'=s.revision::text and p_letter.fields->>'admission_type'=a.admission_type
   and p_letter.fields->>'school_code'=a.school_code and p_letter.fields->>'campus_code'=a.campus_code
   and p_letter.fields->>'program_id'=a.program_id::text and p_letter.fields->>'full_name'=l.full_name
   and p_letter.fields->>'email'=l.email and l.email_suppressed_at is null);
$$;

create function public.mbn_letter_action(p_actor uuid,p_session uuid,p_action text,p_data jsonb default '{}') returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_ctx jsonb;v_app public.crm_applications;v_lead public.crm_leads;v_letter private.mbn_admission_letters;
 v_setting private.mbn_school_letter_settings;v_fields jsonb;v_birth date;v_attachments text[];v_key text;v_result jsonb;v_assets jsonb;
begin
 v_ctx:=public.mbn_pin_context(p_actor,p_session,p_actor);
 if jsonb_typeof(p_data) is distinct from 'object' then raise sqlstate 'PT400' using message='invalid_request';end if;
 if p_action='context' then
  v_result:=public.mbn_letter_action_international_v1(p_actor,p_session,p_action,p_data);
  select * into v_app from public.crm_applications where id=(p_data->>'application_id')::uuid;
  select * into v_setting from private.mbn_school_letter_settings where school_code=v_app.school_code and admission_type=v_app.admission_type;
  if v_app.admission_type='NATIONAL' then
   select coalesce(jsonb_agg(a),'[]') into v_assets from jsonb_array_elements(v_result->'assets') a where a->>'key' not in ('avi_attestation','visa_refusal','rib_cameroun');
   v_result:=jsonb_set(v_result,'{assets}',v_assets);
  end if;
  return v_result||jsonb_build_object('letter_settings',to_jsonb(v_setting),'can_configure',(v_ctx->>'admin')::boolean);
 elsif p_action='prepare' then
  select * into v_app from public.crm_applications where id=(p_data->>'application_id')::uuid for update;
  if not found or v_app.is_test or not private.mbn_ws_can(p_actor,v_app.school_code,'letters') then raise sqlstate 'PT403' using message='access_denied';end if;
  if v_app.status<>'ADMITTED' or v_app.program_id is null or v_app.admission_type not in ('NATIONAL','INTERNATIONAL')
   then raise sqlstate 'PT422' using message='admission_required';end if;
  if exists(select 1 from jsonb_object_keys(p_data) k where k not in ('application_id','request_id','expected_config_revision','fields','attachments'))
   or coalesce(p_data->>'request_id','')!~'^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$'
   or jsonb_typeof(p_data->'fields') is distinct from 'object' then raise sqlstate 'PT422' using message='invalid_letter';end if;
  v_fields:=p_data->'fields';
  if exists(select 1 from jsonb_each(v_fields) e where e.key not in ('date_of_birth','place_of_birth','logo_variant') or jsonb_typeof(e.value)<>'string')
   or coalesce(v_fields->>'date_of_birth','')!~'^\d{4}-\d{2}-\d{2}$'
   or length(btrim(coalesce(v_fields->>'place_of_birth',''))) not between 1 and 180
   or coalesce(v_fields->>'logo_variant','') not in ('SCHOOL','CAMPUS','CAMPUS_AND_SCHOOL')
   then raise sqlstate 'PT422' using message='invalid_letter';end if;
  begin v_birth:=(v_fields->>'date_of_birth')::date;exception when others then raise sqlstate 'PT422' using message='invalid_letter';end;
  if v_birth>current_date or v_birth<date '1900-01-01' then raise sqlstate 'PT422' using message='invalid_letter';end if;
  if exists(select 1 from public.school_campuses where school_code=v_app.school_code and campus_code='NOISIEL') then
   if v_fields->>'logo_variant' not in ('CAMPUS','CAMPUS_AND_SCHOOL') then raise sqlstate 'PT422' using message='campus_brand_required';end if;
  elsif v_fields->>'logo_variant'<>'SCHOOL' then raise sqlstate 'PT422' using message='invalid_letter';end if;
  select * into v_setting from private.mbn_school_letter_settings where school_code=v_app.school_code and admission_type=v_app.admission_type for share;
  if not found or not v_setting.enabled then raise sqlstate 'PT422' using message='letter_settings_missing';end if;
  if v_setting.revision::text is distinct from p_data->>'expected_config_revision' then raise sqlstate 'PT409' using message='letter_settings_changed';end if;
  perform private.mbn_letter_validate_settings(v_app.admission_type,v_setting.fields);
  if jsonb_typeof(p_data->'attachments') is distinct from 'array' then raise sqlstate 'PT422' using message='invalid_attachments';end if;
  if jsonb_array_length(p_data->'attachments')>8 or exists(select 1 from jsonb_array_elements(p_data->'attachments') a where jsonb_typeof(a)<>'string')
   then raise sqlstate 'PT422' using message='invalid_attachments';end if;
  select coalesce(array_agg(distinct value order by value),'{}') into v_attachments from jsonb_array_elements_text(p_data->'attachments');
  foreach v_key in array v_attachments loop
   if not exists(select 1 from private.mbn_original_assets a where a.key=v_key and a.installed_at is not null and a.bucket='mbn-mail-assets'
    and a.mime_type in ('application/pdf','image/jpeg') and (a.school_codes is null or v_app.school_code=any(a.school_codes)))
    then raise sqlstate 'PT422' using message='invalid_attachments';end if;
   if v_app.admission_type='NATIONAL' and v_key in ('avi_attestation','visa_refusal','rib_cameroun') then raise sqlstate 'PT422' using message='national_attachment_conflict';end if;
  end loop;
  if v_setting.fields->>'avi_mode'='OPTIONAL' and 'avi_attestation'=any(v_attachments) then raise sqlstate 'PT422' using message='avi_attachment_conflict';end if;
  select * into v_lead from public.crm_leads where id=v_app.lead_id;
  v_fields:=v_setting.fields||v_fields||jsonb_build_object('school_name',(select name from public.schools where code=v_app.school_code),'school_code',v_app.school_code,
   'campus_name',(select name from public.campuses where code=v_app.campus_code),'campus_code',v_app.campus_code,'program_id',v_app.program_id,
   'full_name',v_lead.full_name,'email',v_lead.email,'reference',v_app.application_reference,
   'program_name',(select name from public.school_programs where id=v_app.program_id),
   'academic_level',(select coalesce(academic_level,cycle) from public.school_programs where id=v_app.program_id),
   'domain',(select domain from public.school_programs where id=v_app.program_id),'pace',(select pace from public.school_programs where id=v_app.program_id),
   'rncp_code',(select rncp_code from public.school_programs where id=v_app.program_id),
   'admission_type',v_app.admission_type,'config_revision',v_setting.revision,
   'template_version',case v_app.admission_type when 'NATIONAL' then 'national-v1-20261019' else 'international-v1-20261019' end);
  insert into private.mbn_admission_letters(id,application_id,school_code,created_by,fields,attachments,object_path)
   values((p_data->>'request_id')::uuid,v_app.id,v_app.school_code,p_actor,v_fields,v_attachments,(p_data->>'request_id')||'/admission.pdf') on conflict(id) do nothing;
  select * into v_letter from private.mbn_admission_letters where id=(p_data->>'request_id')::uuid;
  if v_letter.created_by<>p_actor or v_letter.application_id<>v_app.id or v_letter.fields<>v_fields or v_letter.attachments<>v_attachments then raise sqlstate 'PT409' using message='reference_conflict';end if;
  return to_jsonb(v_letter)||jsonb_build_object('assets',(select coalesce(jsonb_agg(to_jsonb(a)),'[]') from private.mbn_original_assets a
   where a.key=any(v_letter.attachments) or a.key='logo_'||lower(replace(v_app.school_code,' ','-')) or a.key='logo_campus-innovation-mlv' or a.key in ('font_regular','font_bold')));
 elsif p_action in ('claim','authorized') then
  -- Keep the same lock order as mbn_letter_profile_action and serialize profile changes.
  perform pg_advisory_xact_lock(72519816);
  select * into v_letter from private.mbn_admission_letters where id=(p_data->>'id')::uuid for update;
  if not found or not private.mbn_ws_can(p_actor,v_letter.school_code,'letters') then raise sqlstate 'PT403' using message='access_denied';end if;
  perform 1 from public.crm_applications where id=v_letter.application_id for update;
  perform 1 from private.mbn_school_letter_settings where school_code=v_letter.school_code and admission_type=v_letter.fields->>'admission_type' for share;
  if not private.mbn_letter_snapshot_current(v_letter) then
   if p_action='authorized' then return 'false'::jsonb;end if;
   raise sqlstate 'PT409' using message='letter_settings_changed';end if;
 end if;
 return public.mbn_letter_action_international_v1(p_actor,p_session,p_action,p_data);
end;$$;

revoke all on function private.mbn_letter_validate_settings(text,jsonb),private.mbn_letter_snapshot_current(private.mbn_admission_letters),
 public.mbn_letter_config_action(uuid,uuid,text,jsonb),public.mbn_letter_action(uuid,uuid,text,jsonb),public.mbn_letter_action_international_v1(uuid,uuid,text,jsonb) from public,anon,authenticated;
grant execute on function private.mbn_letter_validate_settings(text,jsonb),private.mbn_letter_snapshot_current(private.mbn_admission_letters),
 public.mbn_letter_config_action(uuid,uuid,text,jsonb),public.mbn_letter_action(uuid,uuid,text,jsonb),public.mbn_letter_action_international_v1(uuid,uuid,text,jsonb) to service_role;
