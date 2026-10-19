-- Campus identity is independent of its physical postal address and stable routing code.
update public.campuses set name='Campus Innovation Marne-la-Vallée' where code='NOISIEL';

-- A public school link issues a short-lived private application session. Link previews
-- create no prospect, do not imply consent, and never enroll a marketing sequence.
alter table private.mbn_admission_links alter column lead_id drop not null;
alter table private.mbn_admission_links add column entry_school text references public.schools(code),
 add column entry_source text check(entry_source in ('META_MESSENGER','DIRECT')),
 add column client_hash text check(client_hash ~ '^[a-f0-9]{64}$');
alter table private.mbn_admission_links add constraint admission_link_scope check(lead_id is not null or (entry_school is not null and entry_source is not null));
create index mbn_public_entries_rate on private.mbn_admission_links(created_at) where client_hash is not null;
create index mbn_public_entries_client on private.mbn_admission_links(client_hash,created_at) where client_hash is not null;

create function public.mbn_school_entry(p_slug text,p_client_hash text) returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_school public.schools;v_id uuid;
begin
 if p_slug is null or p_client_hash is null or p_slug !~ '^[a-z0-9-]{2,50}$' or p_client_hash !~ '^[a-f0-9]{64}$' then raise sqlstate 'PT400' using message='invalid_request';end if;
 select * into v_school from public.schools where slug=p_slug and is_active;
 if not found then raise sqlstate 'PT404' using message='link_unavailable';end if;
 perform pg_advisory_xact_lock(72519817);
 if (select count(*) from private.mbn_admission_links where client_hash=p_client_hash and created_at>now()-interval '1 hour')>=40
 or (select count(*) from private.mbn_admission_links where client_hash is not null and created_at>now()-interval '1 day')>=5000 then raise sqlstate 'PT429' using message='intake_busy';end if;
 insert into private.mbn_admission_links(entry_school,entry_source,client_hash,expires_at) values(v_school.code,'META_MESSENGER',p_client_hash,now()+interval '2 days') returning id into v_id;
 return jsonb_build_object('id',v_id,'slug',v_school.slug);
end;$$;
revoke all on function public.mbn_school_entry(text,text) from public,anon,authenticated;
grant execute on function public.mbn_school_entry(text,text) to service_role;

create or replace function public.mbn_candidate_context(p_link uuid,p_action text default 'info') returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_link private.mbn_admission_links;v_lead public.crm_leads;v_school public.schools;
begin
 select * into v_link from private.mbn_admission_links where id=p_link for update;
 if not found or v_link.revoked_at is not null or (p_action<>'unsubscribe' and v_link.expires_at<now()) then raise sqlstate 'PT404' using message='link_unavailable';end if;
 if v_link.lead_id is null then
  select * into v_school from public.schools where code=v_link.entry_school and is_active;
  if not found then raise sqlstate 'PT404' using message='link_unavailable';end if;
  if p_action not in ('info','engage') then raise sqlstate 'PT400' using message='invalid_action';end if;
  return jsonb_build_object('id',v_link.id,'school_code',v_school.code,'school_name',v_school.name,'slug',v_school.slug,'submitted',exists(select 1 from private.mbn_candidate_submissions where link_id=v_link.id and completed_at is not null),'source',v_link.entry_source,'expires_at',v_link.expires_at);
 end if;
 select * into v_lead from public.crm_leads where id=v_link.lead_id for update;
 select * into v_school from public.schools where code=v_lead.school_code;
 if p_action='unsubscribe' then
  update public.crm_leads set consent_email=false,status='UNSUBSCRIBED',unsubscribed_at=coalesce(unsubscribed_at,now()),updated_at=now() where lower(email)=lower(v_lead.email) and not is_test;
  insert into public.crm_lead_events(lead_id,event_type) select v_lead.id,'UNSUBSCRIBED' where v_lead.unsubscribed_at is null;
 elsif not v_school.is_active or v_lead.is_test or v_lead.status='DISQUALIFIED' then raise sqlstate 'PT404' using message='link_unavailable';
 elsif p_action='engage' and v_lead.clicked_at is null and v_lead.submitted_at is null then
  update public.crm_leads set clicked_at=now(),status=case when unsubscribed_at is null then 'CLICKED' else status end,updated_at=now() where id=v_lead.id;
  insert into public.crm_lead_events(lead_id,event_type) values(v_lead.id,'ADMISSION_LINK_CONFIRMED');
 elsif p_action not in ('info','engage') then raise sqlstate 'PT400' using message='invalid_action';end if;
 return jsonb_build_object('id',v_link.id,'lead_id',v_lead.id,'email',v_lead.email,'school_code',v_school.code,'school_name',v_school.name,'slug',v_school.slug,'submitted',v_lead.submitted_at is not null,'source',coalesce(v_link.entry_source,'DIRECT'),'expires_at',v_link.expires_at);
end;$$;

create or replace function public.mbn_candidate_prepare(p_link uuid,p_payload jsonb,p_details jsonb,p_manifest jsonb,p_fingerprint text)
returns jsonb language plpgsql security invoker set search_path='' as $$
declare v_ctx jsonb;v_existing private.mbn_candidate_submissions;v_id uuid;v_kind text;
begin
 v_ctx:=public.mbn_candidate_context(p_link,'info');
 if p_payload->>'reference_dossier'<>'MBNAPP-'||p_link::text or p_payload->>'school_code'<>v_ctx->>'school_code' or (v_ctx->>'email' is not null and lower(p_payload->>'email')<>lower(v_ctx->>'email')) then raise sqlstate 'PT422' using message='invitation_mismatch';end if;
 select * into v_existing from private.mbn_candidate_submissions where link_id=p_link for update;
 if found then
  if v_existing.fingerprint<>p_fingerprint then raise sqlstate 'PT409' using message='reference_conflict';end if;
  return jsonb_build_object('submission_id',v_existing.id,'completed',v_existing.completed_at is not null);
 end if;
 if (v_ctx->>'submitted')::boolean then raise sqlstate 'PT409' using message='application_already_submitted';end if;
 if (select count(*) from private.mbn_candidate_submissions where created_at>now()-interval '1 hour')>=100 then raise sqlstate 'PT429' using message='intake_busy';end if;
 if jsonb_typeof(p_manifest)<>'array' or jsonb_array_length(p_manifest) not between 3 and 6 then raise sqlstate 'PT422' using message='required_documents_missing';end if;
 foreach v_kind in array array['CV','DIPLOME','PIECE_IDENTITE'] loop
  if not exists(select 1 from jsonb_array_elements(p_manifest) x where x->>'kind'=v_kind) then raise sqlstate 'PT422' using message='required_documents_missing';end if;
 end loop;
 if upper(p_payload->>'country_of_residence') in ('FRANCE','FR','FRA') and not exists(select 1 from jsonb_array_elements(p_manifest) x where x->>'kind'='CARTE_VITALE') then raise sqlstate 'PT422' using message='required_documents_missing';end if;
 if not exists(select 1 from public.school_programs p where p.id=(p_payload->>'program_id')::uuid and p.school_code=v_ctx->>'school_code' and p.is_active)
 or not exists(select 1 from public.school_campuses c where c.school_code=v_ctx->>'school_code' and c.campus_code=p_payload->>'campus_code') then raise sqlstate 'PT422' using message='catalogue_selection_invalid';end if;
 insert into private.mbn_candidate_submissions(link_id,payload,details,manifest,fingerprint) values(p_link,p_payload,p_details,p_manifest,p_fingerprint) returning id into v_id;
 return jsonb_build_object('submission_id',v_id,'completed',false);
end;$$;


create or replace function public.mbn_candidate_complete(p_link uuid,p_submission uuid) returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_ctx jsonb;v_draft private.mbn_candidate_submissions;v_doc jsonb;v_path text;v_result jsonb;v_app uuid;
begin
 v_ctx:=public.mbn_candidate_context(p_link,'info');
 select * into v_draft from private.mbn_candidate_submissions where id=p_submission and link_id=p_link for update;
 if not found then raise sqlstate 'PT404' using message='submission_not_found';end if;
 if v_draft.completed_at is not null then return jsonb_build_object('success',true,'reference',v_draft.payload->>'reference_dossier','application_id',v_draft.application_id,'duplicated',true,'document_count',jsonb_array_length(v_draft.manifest));end if;
 for v_doc in select value from jsonb_array_elements(v_draft.manifest) loop
  v_path:=v_draft.id::text||'/'||(v_doc->>'kind')||'.'||(v_doc->>'extension');
  if not exists(select 1 from storage.objects o where o.bucket_id='mbn-admissions' and o.name=v_path
   and (o.metadata->>'size')::bigint=(v_doc->>'byte_size')::bigint and o.metadata->>'mimetype'=v_doc->>'mime_type') then raise sqlstate 'PT409' using message='documents_pending';end if;
 end loop;
 v_result:=public.mbn_ingest_application(v_draft.payload||jsonb_build_object('event','application_submitted','source',coalesce(v_ctx->>'source','DIRECT'),'is_test',false));
 select id into v_app from public.crm_applications where application_reference=v_draft.payload->>'reference_dossier';
 if v_app is null then raise exception 'application_commit_failed';end if;
 for v_doc in select value from jsonb_array_elements(v_draft.manifest) loop
  insert into public.application_documents(application_id,candidate_submission_id,bucket,kind,object_path,original_name,mime_type,byte_size,sha256)
  values(v_app,v_draft.id,'mbn-admissions',v_doc->>'kind',v_draft.id::text||'/'||(v_doc->>'kind')||'.'||(v_doc->>'extension'),v_doc->>'original_name',v_doc->>'mime_type',(v_doc->>'byte_size')::integer,v_doc->>'sha256');
 end loop;
 update private.mbn_candidate_submissions set application_id=v_app,completed_at=now() where id=v_draft.id;
 return jsonb_build_object('success',true,'reference',v_draft.payload->>'reference_dossier','application_id',v_app,'duplicated',false,'document_count',jsonb_array_length(v_draft.manifest));
end;$$;


-- Immutable original assets: school logos are public, contractual PDFs and RIBs private.
create table private.mbn_original_assets(
 key text primary key, label text not null, filename text not null,bucket text not null,object_path text not null,
 sha256 text not null check(sha256 ~ '^[a-f0-9]{64}$'),byte_size integer not null check(byte_size between 1 and 5242880),
 mime_type text not null,school_codes text[],installed_at timestamptz,unique(bucket,object_path)
);
create table private.mbn_asset_tickets(
 token_hash text primary key,asset_key text not null references private.mbn_original_assets(key),
 expires_at timestamptz not null default now()+interval '10 minutes',used_at timestamptz
);
alter table private.mbn_original_assets enable row level security;
alter table private.mbn_asset_tickets enable row level security;
revoke all on private.mbn_original_assets,private.mbn_asset_tickets from public,anon,authenticated;
grant select,insert,update on private.mbn_original_assets,private.mbn_asset_tickets to service_role;
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values
 ('mbn-school-branding','mbn-school-branding',true,5242880,array['image/png']),
 ('mbn-mail-assets','mbn-mail-assets',false,5242880,array['application/pdf','image/jpeg','font/ttf']),
 ('mbn-admission-letters','mbn-admission-letters',false,5242880,array['application/pdf']);
create policy mail_assets_server_only on storage.objects as restrictive for all to anon,authenticated
 using(bucket_id not in ('mbn-school-branding','mbn-mail-assets','mbn-admission-letters'))
 with check(bucket_id not in ('mbn-school-branding','mbn-mail-assets','mbn-admission-letters'));

create function public.mbn_asset_install_ticket(p_key text) returns jsonb language plpgsql security invoker set search_path='' as $$
declare v_asset private.mbn_original_assets;v_token text:=replace(gen_random_uuid()::text||gen_random_uuid()::text,'-','');
begin
 select * into v_asset from private.mbn_original_assets where key=p_key;
 if not found then raise sqlstate 'PT404' using message='asset_not_found';end if;
 insert into private.mbn_asset_tickets(token_hash,asset_key) values(encode(sha256(convert_to(v_token,'UTF8')),'hex'),p_key);
 return jsonb_build_object('token',v_token,'key',p_key);
end;$$;
create function public.mbn_asset_install_context(p_token text,p_key text,p_complete boolean default false) returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_asset private.mbn_original_assets;v_ticket private.mbn_asset_tickets;
begin
 if p_token !~ '^[a-f0-9]{64}$' then raise sqlstate 'PT403' using message='access_denied';end if;
 select * into v_ticket from private.mbn_asset_tickets where token_hash=encode(sha256(convert_to(p_token,'UTF8')),'hex') and asset_key=p_key for update;
 if not found or v_ticket.expires_at<now() then raise sqlstate 'PT403' using message='access_denied';end if;
 select * into v_asset from private.mbn_original_assets where key=p_key;
 if p_complete then
  if not exists(select 1 from storage.objects where bucket_id=v_asset.bucket and name=v_asset.object_path and (metadata->>'size')::bigint=v_asset.byte_size) then raise sqlstate 'PT409' using message='asset_pending';end if;
  update private.mbn_asset_tickets set used_at=coalesce(used_at,now()) where token_hash=v_ticket.token_hash;
  update private.mbn_original_assets set installed_at=coalesce(installed_at,now()) where key=p_key;
 end if;
 return to_jsonb(v_asset)-'installed_at';
end;$$;
revoke all on function public.mbn_asset_install_ticket(text),public.mbn_asset_install_context(text,text,boolean) from public,anon,authenticated;
grant execute on function public.mbn_asset_install_ticket(text),public.mbn_asset_install_context(text,text,boolean) to service_role;

create table private.mbn_admission_letters(
 id uuid primary key,application_id uuid not null references public.crm_applications(id),school_code text not null references public.schools(code),
 created_by uuid not null references public.profiles(user_id),fields jsonb not null,attachments text[] not null default '{}',
 object_path text not null unique,pdf_sha256 text,pdf_bytes integer,generated_at timestamptz,approved_at timestamptz,approved_by uuid references public.profiles(user_id),
 message_id uuid references public.mail_messages(id),created_at timestamptz not null default now()
);
alter table private.mbn_admission_letters enable row level security;
revoke all on private.mbn_admission_letters from public,anon,authenticated;
grant select,insert,update on private.mbn_admission_letters to service_role;
alter table public.mail_messages add column admission_letter_id uuid unique references private.mbn_admission_letters(id);

create function public.mbn_letter_action(p_actor uuid,p_session uuid,p_action text,p_data jsonb default '{}') returns jsonb
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
  if not v_setting.enabled or not v_setting.sender_verified or not v_setting.production_access or not v_setting.account_sending_enabled or v_setting.provider_checked_at is null or v_setting.provider_checked_at<now()-interval '1 hour' then raise sqlstate 'PT422' using message='sender_not_ready';end if;
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
  return to_jsonb(v_app.status='ADMITTED' and exists(select 1 from public.schools where code=v_app.school_code and is_active) and v_lead.email_suppressed_at is null and exists(select 1 from private.mbn_mail_settings where id and enabled) and exists(select 1 from public.mail_messages where id=v_letter.message_id and status='SENDING' and attempt_id=(p_data->>'attempt_id')::uuid));
 end if;
 return to_jsonb(v_letter)||jsonb_build_object('message',to_jsonb(v_message),'assets',(select coalesce(jsonb_agg(to_jsonb(a)),'[]') from private.mbn_original_assets a where a.key=any(v_letter.attachments) or a.key='logo_'||lower(replace(v_app.school_code,' ','-')) or a.key='logo_campus-innovation-mlv' or a.key in ('font_regular','font_bold')));
end;$$;
revoke all on function public.mbn_letter_action(uuid,uuid,text,jsonb) from public,anon,authenticated;
grant execute on function public.mbn_letter_action(uuid,uuid,text,jsonb) to service_role;

insert into private.mbn_original_assets(key,label,filename,bucket,object_path,sha256,byte_size,mime_type,school_codes) values
('logo_campus-innovation-mlv','campus-innovation-mlv','campus-innovation-mlv.png','mbn-school-branding','campus-innovation-mlv.png','393fc45edcf22ca6ad3eb26181b130c6966bac90a923cfe858b6a6a69fcdb4b2',268809,'image/png',null),
('logo_cescom','cescom','cescom.png','mbn-school-branding','cescom.png','b424269e72c88af37739594e92b15b9a4eef6de28924dae57ca8f994b6973e07',40716,'image/png',null),
('logo_dcg-formations','dcg-formations','dcg-formations.png','mbn-school-branding','dcg-formations.png','b9eaefa7e1a1202a13420c89f495671153255b5d32b917ccbab669d31f1ec2ba',19649,'image/png',null),
('logo_emsp','emsp','emsp.png','mbn-school-branding','emsp.png','1605b9ac6b05de95a80d1bf19ea023af55505b1e17a9c15b499877237820387d',34378,'image/png',null),
('logo_esart','esart','esart.png','mbn-school-branding','esart.png','bd9b114a7034974180d0b4b1be6cf28e2d485f8e496a8837f2cad1de941c40e7',49929,'image/png',null),
('logo_esea','esea','esea.png','mbn-school-branding','esea.png','3c2d100df820bb83fb06065d0b03af150c8b9388d6abc08ea9ae167a232bc376',37007,'image/png',null),
('logo_eseth','eseth','eseth.png','mbn-school-branding','eseth.png','ac8137d2f34a36b2283a6036dbe917095028b4fd4b4fecfb55e6105a183eb773',40146,'image/png',null),
('logo_esiia','esiia','esiia.png','mbn-school-branding','esiia.png','21bd01c50f4a7ee11ef51dcf885a4b4b113d23969c39720086c729fd82059073',8770,'image/png',null),
('logo_esjm','esjm','esjm.png','mbn-school-branding','esjm.png','ca71d7538b49aff185ca54839c0d1661c98f64dab7bc94e68094dd16db72c82a',133121,'image/png',null),
('logo_esmas','esmas','esmas.png','mbn-school-branding','esmas.png','f519a4f9ed3ace9c8a02771da44cf3115d3989ebcfc48e0b1ff909cf8deff511',8125,'image/png',null),
('logo_esmep','esmep','esmep.png','mbn-school-branding','esmep.png','85728480989d6b93ab9d03cf9a9c962f9541c8e087aba28011644316f2bcc463',20748,'image/png',null),
('logo_esmoss','esmoss','esmoss.png','mbn-school-branding','esmoss.png','82ea7b80d9a89e0e277a6d79fe9686c1dc2261941eb637f3b53061cda0913a30',44167,'image/png',null),
('logo_esuv','esuv','esuv.png','mbn-school-branding','esuv.png','ddc8ef65cc02f9f1dd54df293d2a253ebba506b43f683f1ee78a09c9de1193ee',28727,'image/png',null),
('logo_evry-bs','evry-bs','evry-bs.png','mbn-school-branding','evry-bs.png','df6f91fba424312f845fc41e9764f74693d9e711024871b8ed6184bfe5bf7070',56492,'image/png',null),
('logo_evry-bts','evry-bts','evry-bts.png','mbn-school-branding','evry-bts.png','c6b50f5ba83c6dd163455532d6c4907d3af314beda4b85c2728525d888c6a15f',42438,'image/png',null),
('logo_ilmis','ilmis','ilmis.png','mbn-school-branding','ilmis.png','91b10dc029d986aaadd498680c1af14adcdf786af6877bcb2fcb79595f762bec',19966,'image/png',null),
('logo_ismod','ismod','ismod.png','mbn-school-branding','ismod.png','b59377f029d2a7456c31fa003fd4aae967f872f504a300cd5c9ffe27c154b321',97695,'image/png',null),
('logo_lsb','lsb','lsb.png','mbn-school-branding','lsb.png','612b5db670097773bb11bd3da2db99e1fd527451aa4c28483a8ffe29908ab2c6',131335,'image/png',null),
('logo_mlv-bs','mlv-bs','mlv-bs.png','mbn-school-branding','mlv-bs.png','570e44d5b15781dd5a30161931b3282142c8c7d21bb0c43b1df5dc56f7889386',99292,'image/png',null),
('logo_mlv-bts','mlv-bts','mlv-bts.png','mbn-school-branding','mlv-bts.png','17f643630357c780152da559dadca693c82f4931181a2b855f520ecf8daf4d16',20945,'image/png',null),
('cgv_cescom','CGV CESCOM','cgv_cescom.pdf','mbn-mail-assets','cgv_cescom.pdf','8a80c875e978c953f953a58bb209760acd9b5c1fffb87d4adfa1ea4304353213',271041,'application/pdf',array['CESCOM']),
('cgv_group','CGV MBN Global Éducation','cgv_group.pdf','mbn-mail-assets','cgv_group.pdf','aa9222816a2e70b22e9305d1388dbbf97e8a56bf3c437252cf67d316579f32e8',359675,'application/pdf',null),
('visa_refusal','Refus de visa','visa_refusal.pdf','mbn-mail-assets','visa_refusal.pdf','48e3dd4fb8136ff2b0a8635d2f74f467b804554b46d8155dc44a4841d47d8197',4333564,'application/pdf',null),
('bank_brochure','Caisse d’Épargne · Offre étudiants','bank_brochure.pdf','mbn-mail-assets','bank_brochure.pdf','f24f9d4dcde85fa7a6e08b4a2c2e444d8c31a3784f91c32af895ce23b78d6dfe',1321767,'application/pdf',null),
('avi_attestation','Engagement AVI','avi_attestation.pdf','mbn-mail-assets','avi_attestation.pdf','eca7e21c9ba23a5ca4d0c59fb7664888a46f4dad96581502fd586fe72ae6b917',61180,'application/pdf',null),
('rib_general','RIB toutes nationalités · original à vérifier pour cette école','rib_general.jpg','mbn-mail-assets','rib_general.jpg','5ddbaa2f7afd04bf77dbe1e4af62742b9f86afff06513d28a387145f2aaeafe4',43522,'image/jpeg',null),
('rib_cameroun','RIB Cameroun · optionnel · original à vérifier pour cette école','rib_cameroun.jpg','mbn-mail-assets','rib_cameroun.jpg','3f25e262f449497aa69d9a02aaa202a50a201c34f04e4e6a11a92d1ac9f9e8a7',40387,'image/jpeg',null),
('font_regular','DejaVu Sans regular','regular.ttf','mbn-mail-assets','fonts/regular.ttf','ae7b7855e115a5966d8b1b3f80f254ccc117ec86f9965e202ee2940453837280',759720,'font/ttf',null),
('font_bold','DejaVu Sans bold','bold.ttf','mbn-mail-assets','fonts/bold.ttf','5c1247acef7f2b8522a31742c76d6adcb5569bacc0be7ceaa4dc39dd252ce895',708920,'font/ttf',null);

create function public.mbn_letter_finish(p_id uuid,p_attempt uuid,p_status text,p_provider_id text default null,p_error text default null) returns boolean
language plpgsql security invoker set search_path='' as $$
declare v_letter private.mbn_admission_letters;v_msg public.mail_messages;v_ok boolean;
begin
 select * into v_msg from public.mail_messages where id=p_id and attempt_id=p_attempt and admission_letter_id is not null for update;
 if not found then return false;end if;
 v_ok:=public.mbn_mail_finish(p_id,p_attempt,p_status,p_provider_id,p_error);
 if v_ok and p_status='ACCEPTED' then
  select * into v_letter from private.mbn_admission_letters where id=v_msg.admission_letter_id;
  update public.crm_applications set status='LETTER_SENT',updated_at=now() where id=v_letter.application_id and status='ADMITTED';
 end if;
 return v_ok;
end;$$;
revoke all on function public.mbn_letter_finish(uuid,uuid,text,text,text) from public,anon,authenticated;
grant execute on function public.mbn_letter_finish(uuid,uuid,text,text,text) to service_role;
