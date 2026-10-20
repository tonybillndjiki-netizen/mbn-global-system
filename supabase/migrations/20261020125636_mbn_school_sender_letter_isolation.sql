-- Preserve the existing letter checks and snapshots while isolating sender readiness.
-- The shared settings still own the daily allowance; group proofs own authorization.
create or replace function public.mbn_letter_action_international_v1(p_actor uuid,p_session uuid,p_action text,p_data jsonb default '{}') returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_ctx jsonb;v_app public.crm_applications;v_lead public.crm_leads;v_letter private.mbn_admission_letters;
 v_fields jsonb;v_details jsonb;v_attachments text[];v_setting private.mbn_mail_settings;v_message public.mail_messages;v_key text;
begin
 v_ctx:=public.mbn_pin_context(p_actor,p_session,p_actor);
 if jsonb_typeof(p_data)<>'object' then raise sqlstate 'PT400' using message='invalid_request';end if;
 if p_action in ('context','prepare','asset') then
  select * into v_app from public.crm_applications where id=(p_data->>'application_id')::uuid for update;
 else
  select * into v_letter from private.mbn_admission_letters where id=(p_data->>'id')::uuid for update;
  if not found then raise sqlstate 'PT404' using message='record_not_found';end if;
  select * into v_app from public.crm_applications where id=v_letter.application_id for update;
 end if;
 if v_app.id is null or v_app.is_test or not private.mbn_ws_can(p_actor,v_app.school_code,'letters') then raise sqlstate 'PT403' using message='access_denied';end if;
 select * into v_lead from public.crm_leads where id=v_app.lead_id;
 if p_action='context' then
  select details into v_details from private.mbn_candidate_submissions where application_id=v_app.id;
  return jsonb_build_object('application',to_jsonb(v_app)-'form_payload','lead',jsonb_build_object('full_name',v_lead.full_name,'email',v_lead.email),
   'school',(select to_jsonb(s) from public.schools s where code=v_app.school_code),
   'campus',(select to_jsonb(c) from public.campuses c where code=v_app.campus_code),
   'program',(select to_jsonb(p) from public.school_programs p where id=v_app.program_id),'details',coalesce(v_details,'{}'),
   'assets',(select coalesce(jsonb_agg(to_jsonb(a)-'bucket'-'object_path'-'sha256'),'[]') from private.mbn_original_assets a where a.bucket='mbn-mail-assets' and a.mime_type in ('application/pdf','image/jpeg') and a.installed_at is not null and (a.school_codes is null or v_app.school_code=any(a.school_codes))),
   'letters',(select coalesce(jsonb_agg(jsonb_build_object('id',l.id,'generated_at',l.generated_at,'created_at',l.created_at,'status',m.status,'approved_at',l.approved_at,'message_id',m.id) order by l.created_at desc),'[]') from private.mbn_admission_letters l left join public.mail_messages m on m.id=l.message_id where l.application_id=v_app.id));
 elsif p_action='asset' then
  return (select to_jsonb(a) from private.mbn_original_assets a where a.key=p_data->>'key' and a.installed_at is not null and a.bucket='mbn-mail-assets' and a.mime_type in ('application/pdf','image/jpeg') and (a.school_codes is null or v_app.school_code=any(a.school_codes)));
 elsif p_action='prepare' then
  if v_app.status<>'ADMITTED' or v_app.admission_type<>'INTERNATIONAL' or v_app.program_id is null then raise sqlstate 'PT422' using message='international_admission_required';end if;
  v_fields:=p_data->'fields';
  if jsonb_typeof(v_fields)<>'object' or exists(select 1 from jsonb_object_keys(v_fields) k where k not in ('academic_year','intake','deferred_intake','registration_fee','tuition_deposit','confirmation_days','date_of_birth','place_of_birth','signatory','avi_mode','logo_variant'))
   or coalesce(v_fields->>'academic_year','') !~ '^20[0-9]{2}/20[0-9]{2}$'
   or length(coalesce(v_fields->>'intake','')) not between 3 and 80 or length(coalesce(v_fields->>'deferred_intake','')) not between 3 and 80
   or coalesce(v_fields->>'registration_fee','') !~ '^[0-9]{1,5}(\.[0-9]{1,2})?$' or (v_fields->>'registration_fee')::numeric<=0
   or coalesce(v_fields->>'tuition_deposit','') !~ '^[0-9]{1,5}(\.[0-9]{1,2})?$' or (v_fields->>'tuition_deposit')::numeric<=0
   or coalesce(v_fields->>'confirmation_days','') !~ '^[0-9]{1,2}$' or (v_fields->>'confirmation_days')::integer not between 1 and 90
   or coalesce(v_fields->>'date_of_birth','') !~ '^\d{4}-\d{2}-\d{2}$' or length(coalesce(v_fields->>'place_of_birth','')) not between 1 and 180
   or length(coalesce(v_fields->>'signatory','')) not between 1 and 120
   or coalesce(v_fields->>'avi_mode','') not in ('OPTIONAL','REQUIRED')
   or coalesce(v_fields->>'logo_variant','') not in ('SCHOOL','CAMPUS','CAMPUS_AND_SCHOOL')
   then raise sqlstate 'PT422' using message='invalid_letter';end if;
  if exists(select 1 from public.school_campuses where school_code=v_app.school_code and campus_code='NOISIEL') then
   if v_fields->>'logo_variant' not in ('CAMPUS','CAMPUS_AND_SCHOOL') then raise sqlstate 'PT422' using message='campus_brand_required';end if;
  elsif v_fields->>'logo_variant'<>'SCHOOL' then raise sqlstate 'PT422' using message='invalid_letter';end if;
  if jsonb_typeof(p_data->'attachments') is distinct from 'array' or jsonb_array_length(p_data->'attachments')>8 then raise sqlstate 'PT422' using message='invalid_attachments';end if;
  select coalesce(array_agg(distinct value order by value),'{}') into v_attachments from jsonb_array_elements_text(p_data->'attachments');
  foreach v_key in array v_attachments loop
   if not exists(select 1 from private.mbn_original_assets a where a.key=v_key and a.installed_at is not null and a.bucket='mbn-mail-assets' and a.mime_type in ('application/pdf','image/jpeg') and (a.school_codes is null or v_app.school_code=any(a.school_codes))) then raise sqlstate 'PT422' using message='invalid_attachments';end if;
  end loop;
  if v_fields->>'avi_mode'='OPTIONAL' and 'avi_attestation'=any(v_attachments) then raise sqlstate 'PT422' using message='avi_attachment_conflict';end if;
  if (v_fields->>'date_of_birth')::date>current_date or (v_fields->>'date_of_birth')::date<date '1900-01-01' then raise sqlstate 'PT422' using message='invalid_letter';end if;
  v_fields:=v_fields||jsonb_build_object('school_name',(select name from public.schools where code=v_app.school_code),'school_code',v_app.school_code,'campus_name',(select name from public.campuses where code=v_app.campus_code),
   'full_name',v_lead.full_name,'email',v_lead.email,'reference',v_app.application_reference,'program_name',(select name from public.school_programs where id=v_app.program_id),
   'academic_level',(select coalesce(academic_level,cycle) from public.school_programs where id=v_app.program_id),'domain',(select domain from public.school_programs where id=v_app.program_id),
   'pace',(select pace from public.school_programs where id=v_app.program_id),'rncp_code',(select rncp_code from public.school_programs where id=v_app.program_id),'template_version','international-v1-20261019');
  insert into private.mbn_admission_letters(id,application_id,school_code,created_by,fields,attachments,object_path)
   values((p_data->>'request_id')::uuid,v_app.id,v_app.school_code,p_actor,v_fields,v_attachments,(p_data->>'request_id')||'/admission.pdf') on conflict(id) do nothing;
  select * into v_letter from private.mbn_admission_letters where id=(p_data->>'request_id')::uuid;
  if v_letter.created_by<>p_actor or v_letter.application_id<>v_app.id or v_letter.fields<>v_fields or v_letter.attachments<>v_attachments then raise sqlstate 'PT409' using message='reference_conflict';end if;
 elsif p_action='generated' then
  if p_data->>'sha256' !~ '^[a-f0-9]{64}$' or (p_data->>'byte_size')::integer not between 1 and 5242880
   or not exists(select 1 from storage.objects where bucket_id='mbn-admission-letters' and name=v_letter.object_path and (metadata->>'size')::integer=(p_data->>'byte_size')::integer) then raise sqlstate 'PT409' using message='documents_pending';end if;
  if v_letter.generated_at is not null and v_letter.pdf_sha256<>p_data->>'sha256' then raise sqlstate 'PT409' using message='reference_conflict';end if;
  update private.mbn_admission_letters set pdf_sha256=p_data->>'sha256',pdf_bytes=(p_data->>'byte_size')::integer,generated_at=coalesce(generated_at,now()) where id=v_letter.id returning * into v_letter;
  insert into public.crm_lead_events(lead_id,event_type,event_metadata) values(v_lead.id,'ADMISSION_LETTER_GENERATED',jsonb_build_object('application_id',v_app.id,'letter_id',v_letter.id,'actor_id',p_actor));
 elsif p_action='claim' then
  perform pg_advisory_xact_lock(72519816);
  select * into v_setting from private.mbn_mail_settings where id;
  -- Sender verification belongs to this school's group. Inspecting another
  -- identity may change the retired single-sender cache and must not block it.
  if not exists(select 1 from private.mbn_school_mail_routes r where r.school_code=v_app.school_code
   and r.admissions_email<>'' and private.mbn_mail_profile_ready(r.sender_group)) then
   raise sqlstate 'PT422' using message='sender_not_ready';end if;
  if coalesce((p_data->>'confirmed')::boolean,false) is not true then raise sqlstate 'PT422' using message='letter_approval_required';end if;
  if v_letter.generated_at is null or v_app.status<>'ADMITTED' or v_lead.is_test or v_lead.email_suppressed_at is not null or v_lead.email<>v_letter.fields->>'email' then raise sqlstate 'PT422' using message='letter_not_sendable';end if;
  if v_letter.message_id is not null or exists(select 1 from private.mbn_admission_letters l join public.mail_messages m on m.id=l.message_id where l.application_id=v_app.id and m.status in ('SENDING','ACCEPTED','DELIVERED','UNCERTAIN')) then raise sqlstate 'PT409' using message='letter_already_sent';end if;
  if (('cgv_group'=any(v_letter.attachments))::int+('cgv_cescom'=any(v_letter.attachments))::int)<>1 then raise sqlstate 'PT422' using message='cgv_required';end if;
  if v_letter.fields->>'avi_mode'='REQUIRED' and not ('avi_attestation'=any(v_letter.attachments)) then raise sqlstate 'PT422' using message='avi_attachment_required';end if;
  if not exists(select 1 from public.schools where code=v_app.school_code and is_active) then raise sqlstate 'PT422' using message='school_inactive';end if;
  if (select count(*) from public.mail_messages where accepted_at>=date_trunc('day',now()) or (status in ('SENDING','UNCERTAIN') and claimed_at>=date_trunc('day',now())))>=v_setting.daily_limit then raise sqlstate 'PT429' using message='daily_limit_reached';end if;
  insert into public.mail_messages(school_code,lead_id,recipient,subject,body,created_by,status,attempt_id,claimed_at,admission_letter_id)
   values(v_app.school_code,v_lead.id,v_lead.email,'Votre admission · '||left(v_letter.fields->>'school_name',160),'Lettre d’admission et pièces jointes validées par le service admissions.',p_actor,'SENDING',gen_random_uuid(),now(),v_letter.id) returning * into v_message;
  update private.mbn_admission_letters set message_id=v_message.id,approved_by=p_actor,approved_at=now() where id=v_letter.id returning * into v_letter;
 elsif p_action not in ('download','authorized') then raise sqlstate 'PT400' using message='unknown_action';end if;
 if p_action='authorized' then
  return to_jsonb(v_app.status='ADMITTED' and exists(select 1 from public.schools where code=v_app.school_code and is_active) and v_lead.email_suppressed_at is null and exists(select 1 from private.mbn_school_mail_routes r where r.school_code=v_app.school_code and r.admissions_email<>'' and private.mbn_mail_profile_ready(r.sender_group)) and exists(select 1 from public.mail_messages where id=v_letter.message_id and status='SENDING' and attempt_id=(p_data->>'attempt_id')::uuid));
 end if;
 return to_jsonb(v_letter)||jsonb_build_object('message',to_jsonb(v_message),'assets',(select coalesce(jsonb_agg(to_jsonb(a)),'[]') from private.mbn_original_assets a where a.key=any(v_letter.attachments) or a.key='logo_'||lower(replace(v_app.school_code,' ','-')) or a.key='logo_campus-innovation-mlv' or a.key in ('font_regular','font_bold')));
end;$$;
revoke all on function public.mbn_letter_action_international_v1(uuid,uuid,text,jsonb) from public,anon,authenticated;
grant execute on function public.mbn_letter_action_international_v1(uuid,uuid,text,jsonb) to service_role;

-- Prioritize the least recently served sender between worker calls and days.
-- Tests do not change this order, and no cursor or new credential is required.
create index mbn_mail_sender_dispatch_idx on public.mail_messages(sender_group,claimed_at desc)
 where not is_test and claimed_at is not null;
create or replace function public.mbn_mail_profile_settings(p_group text default null,p_school text default null) returns jsonb
language plpgsql stable security invoker set search_path='' as $$
declare v_group text:=p_group;v_result jsonb;begin
 if p_school is not null then
  select sender_group into v_group from private.mbn_school_mail_routes where school_code=p_school;
  if v_group is null then raise sqlstate 'PT422' using message='mail_route_missing';end if;
 end if;
 select to_jsonb(g)||jsonb_build_object('reply_to',g.from_email,'daily_limit',s.daily_limit,'brevo_webhook_id',s.brevo_webhook_id,
  'last_dispatch_at',(select max(m.claimed_at) from public.mail_messages m where m.sender_group=g.code and not m.is_test and m.claimed_at is not null))
 into v_result from private.mbn_mail_sender_groups g cross join private.mbn_mail_settings s where s.id and g.code=v_group;
 if v_result is null then raise sqlstate 'PT422' using message='invalid_sender_group';end if;
 return v_result;
end;$$;
revoke all on function public.mbn_mail_profile_settings(text,text) from public,anon,authenticated;
grant execute on function public.mbn_mail_profile_settings(text,text) to service_role;
