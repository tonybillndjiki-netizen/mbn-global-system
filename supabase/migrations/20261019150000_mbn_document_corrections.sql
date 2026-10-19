create table private.mbn_document_requests(
 id uuid primary key,application_id uuid not null references public.crm_applications(id),
 items jsonb not null,status text not null default 'OPEN' check(status in ('OPEN','COMPLETED','CANCELED')),
 created_by uuid not null references public.profiles(user_id),created_at timestamptz not null default now(),
 expires_at timestamptz not null default now()+interval '14 days',completed_at timestamptz,canceled_at timestamptz,
 message_id uuid unique references public.mail_messages(id)
);
create index mbn_document_requests_application on private.mbn_document_requests(application_id,created_at desc);
create unique index mbn_document_one_open_request on private.mbn_document_requests(application_id) where status='OPEN';
create table private.mbn_correction_submissions(
 id uuid primary key default gen_random_uuid(),request_id uuid not null unique references private.mbn_document_requests(id),
 manifest jsonb not null,fingerprint text not null check(fingerprint ~ '^[a-f0-9]{64}$'),
 created_at timestamptz not null default now(),completed_at timestamptz
);
alter table private.mbn_document_requests enable row level security;
alter table private.mbn_correction_submissions enable row level security;
revoke all on private.mbn_document_requests,private.mbn_correction_submissions from public,anon,authenticated;
grant select,insert,update on private.mbn_document_requests,private.mbn_correction_submissions to service_role;
alter table public.application_documents add column correction_submission_id uuid references private.mbn_correction_submissions(id),
 add column superseded_at timestamptz;
alter table public.application_documents drop constraint application_documents_application_id_kind_key,
 drop constraint application_documents_origin_check;
create unique index application_documents_current_kind on public.application_documents(application_id,kind) where superseded_at is null;
alter table public.application_documents add constraint application_documents_origin_check check(
 (submission_id is not null and candidate_submission_id is null and correction_submission_id is null and bucket='mbn-native-test') or
 (submission_id is null and num_nonnulls(candidate_submission_id,correction_submission_id)=1 and bucket='mbn-admissions'));
alter table public.mail_messages add column document_request_id uuid references private.mbn_document_requests(id);

create function private.mbn_document_version_guard() returns trigger
language plpgsql security invoker set search_path='' as $$begin
 if old.superseded_at is not null and (new.review_status is distinct from old.review_status or new.review_note is distinct from old.review_note) then
  raise sqlstate 'PT409' using message='document_superseded';end if;return new;
end;$$;
create trigger mbn_document_version_guard before update on public.application_documents for each row execute function private.mbn_document_version_guard();
create function private.mbn_current_documents_guard() returns trigger
language plpgsql security invoker set search_path='' as $$
declare v_kind text;begin
 if new.status is distinct from old.status and new.status in ('COMPLETE','READY_FOR_DECISION','ADMITTED') and exists(select 1 from private.mbn_document_requests where application_id=new.id) then
  if exists(select 1 from private.mbn_document_requests where application_id=new.id and status='OPEN') then raise sqlstate 'PT422' using message='document_request_pending';end if;
  foreach v_kind in array case when new.admission_type='NATIONAL' then array['CV','DIPLOME','PIECE_IDENTITE','CARTE_VITALE'] else array['CV','DIPLOME','PIECE_IDENTITE'] end loop
   if not exists(select 1 from public.application_documents where application_id=new.id and kind=v_kind and superseded_at is null and review_status='APPROVED') then
    raise sqlstate 'PT422' using message='required_documents_not_approved';end if;
  end loop;
 end if;return new;
end;$$;
-- Existing decisions are preserved. Only requests created through this new
-- workflow opt an application into the additional version-aware guard.
create trigger mbn_current_documents_guard before update of status on public.crm_applications for each row execute function private.mbn_current_documents_guard();

create function public.mbn_document_requests_action(p_actor uuid,p_session uuid,p_action text,p_data jsonb default '{}') returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_ctx jsonb;v_app public.crm_applications;v_request private.mbn_document_requests;v_lead public.crm_leads;
 v_group private.mbn_mail_sender_groups;v_route private.mbn_school_mail_routes;v_msg public.mail_messages;
 v_item jsonb;v_id uuid;v_uuid text:='^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$';v_limit integer;
begin
 v_ctx:=public.mbn_pin_context(p_actor,p_session,p_actor);
 if jsonb_typeof(p_data) is distinct from 'object' then raise sqlstate 'PT400' using message='invalid_request';end if;
 if p_action not in ('context','create','cancel','claim','authorized') or p_action is null then raise sqlstate 'PT400' using message='unknown_action';end if;
 if p_action<>'context' then perform pg_advisory_xact_lock(72519816);end if;
 if p_action in ('context','create') then
  if coalesce(p_data->>'application_id','') !~ v_uuid then raise sqlstate 'PT400' using message='invalid_request';end if;
  v_id:=(p_data->>'application_id')::uuid;
 else
  if coalesce(p_data->>'id','') !~ v_uuid then raise sqlstate 'PT400' using message='invalid_request';end if;
  select application_id into v_id from private.mbn_document_requests where id=(p_data->>'id')::uuid;
 end if;
 select * into v_app from public.crm_applications where id=v_id for update;
 if not found or v_app.is_test or not private.mbn_ws_can(p_actor,v_app.school_code,'review') then raise sqlstate 'PT404' using message='record_not_found';end if;
 select * into v_lead from public.crm_leads where id=v_app.lead_id;
 if p_action not in ('context','cancel','authorized') and (v_lead.is_test or v_lead.status='DISQUALIFIED' or not exists(select 1 from public.schools where code=v_app.school_code and is_active)) then raise sqlstate 'PT422' using message='document_request_unavailable';end if;
 if p_action='context' then
  if p_data?'id' then
   if coalesce(p_data->>'id','') !~ v_uuid then raise sqlstate 'PT404' using message='record_not_found';end if;
   if not exists(select 1 from private.mbn_document_requests where id=(p_data->>'id')::uuid and application_id=v_app.id) then raise sqlstate 'PT404' using message='record_not_found';end if;
  end if;
  return jsonb_build_object('school_code',v_app.school_code,'can_request',v_app.status in ('RECEIVED','IN_REVIEW','MISSING_DOCUMENTS','DOCUMENTS_TO_VERIFY') and not v_lead.is_test and v_lead.status<>'DISQUALIFIED' and exists(select 1 from public.schools where code=v_app.school_code and is_active),
   'documents',(select coalesce(jsonb_agg(to_jsonb(d)-'object_path'-'sha256' order by d.created_at,d.id),'[]') from public.application_documents d where d.application_id=v_app.id),
   'requests',(select coalesce(jsonb_agg(to_jsonb(q)||jsonb_build_object('mail_status',m.status,'mail_error',m.error_code) order by q.created_at desc,q.id desc),'[]') from private.mbn_document_requests q left join public.mail_messages m on m.id=q.message_id where q.application_id=v_app.id));
 elsif p_action='create' then
  if exists(select 1 from jsonb_object_keys(p_data) k where k not in ('application_id','request_id','items')) or coalesce(p_data->>'request_id','') !~ v_uuid
   or jsonb_typeof(p_data->'items') is distinct from 'array' then raise sqlstate 'PT422' using message='invalid_document_request';end if;
  if jsonb_array_length(p_data->'items') not between 1 and 6 then raise sqlstate 'PT422' using message='invalid_document_request';end if;
  if v_app.status not in ('RECEIVED','IN_REVIEW','MISSING_DOCUMENTS','DOCUMENTS_TO_VERIFY') then raise sqlstate 'PT422' using message='document_request_unavailable';end if;
  for v_item in select value from jsonb_array_elements(p_data->'items') loop
   if jsonb_typeof(v_item) is distinct from 'object' or exists(select 1 from jsonb_object_keys(v_item) k where k not in ('kind','reason'))
    or coalesce(v_item->>'kind','') not in ('CV','DIPLOME','PIECE_IDENTITE','CARTE_VITALE','JUSTIFICATIF_HANDICAP','JUSTIFICATIF_PAIEMENT')
    or length(btrim(coalesce(v_item->>'reason',''))) not between 3 and 1000 then raise sqlstate 'PT422' using message='invalid_document_request';end if;
   if exists(select 1 from public.application_documents where application_id=v_app.id and kind=v_item->>'kind' and superseded_at is null and review_status='APPROVED') then raise sqlstate 'PT422' using message='document_already_approved';end if;
  end loop;
  if (select count(distinct x->>'kind') from jsonb_array_elements(p_data->'items') x)<>jsonb_array_length(p_data->'items') then raise sqlstate 'PT422' using message='invalid_document_request';end if;
  select * into v_request from private.mbn_document_requests where id=(p_data->>'request_id')::uuid;
  if found then
   if v_request.application_id<>v_app.id or v_request.created_by<>p_actor or v_request.items<>p_data->'items' then raise sqlstate 'PT409' using message='document_request_changed';end if;
   return to_jsonb(v_request);
  end if;
  update private.mbn_document_requests set status='CANCELED',canceled_at=now() where application_id=v_app.id and status='OPEN' and expires_at<=now();
  if exists(select 1 from private.mbn_document_requests where application_id=v_app.id and status='OPEN') then raise sqlstate 'PT409' using message='document_request_exists';end if;
  if (select count(*) from private.mbn_document_requests where application_id=v_app.id and created_at>now()-interval '1 day')>=5 then raise sqlstate 'PT429' using message='document_request_rate_limited';end if;
  insert into private.mbn_document_requests(id,application_id,items,created_by) values((p_data->>'request_id')::uuid,v_app.id,p_data->'items',p_actor) returning * into v_request;
  update public.crm_applications set status='MISSING_DOCUMENTS',updated_at=now() where id=v_app.id;
  insert into public.crm_lead_events(lead_id,event_type,event_metadata) values(v_app.lead_id,'DOCUMENTS_REQUESTED',jsonb_build_object('application_id',v_app.id,'request_id',v_request.id,'actor_id',p_actor,'items',v_request.items));
  return to_jsonb(v_request);
 end if;
 select * into v_request from private.mbn_document_requests where id=(p_data->>'id')::uuid for update;
 if p_action='cancel' then
  update private.mbn_document_requests set status='CANCELED',canceled_at=now() where id=v_request.id and status='OPEN';
  if found then insert into public.crm_lead_events(lead_id,event_type,event_metadata) values(v_app.lead_id,'DOCUMENT_REQUEST_CANCELED',jsonb_build_object('request_id',v_request.id,'actor_id',p_actor));end if;
  return jsonb_build_object('success',true);
 end if;
 if v_request.status<>'OPEN' or v_request.expires_at<=now() or v_app.status<>'MISSING_DOCUMENTS' then
  if p_action='authorized' then
   update public.mail_messages set status='CANCELED',error_code='authorization_changed',updated_at=now() where id=v_request.message_id and status='SENDING';return 'false';end if;raise sqlstate 'PT422' using message='document_request_unavailable';end if;
 if p_action='authorized' then
  if coalesce(p_data->>'attempt_id','') !~ v_uuid then raise sqlstate 'PT400' using message='invalid_request';end if;
  select * into v_msg from public.mail_messages where id=v_request.message_id and attempt_id=(p_data->>'attempt_id')::uuid and status='SENDING';
  if not found then return 'false';end if;
  if not private.mbn_mail_message_current(v_msg) or v_msg.recipient is distinct from v_lead.email or v_lead.email_suppressed_at is not null or v_lead.is_test or v_lead.status='DISQUALIFIED' then
   update public.mail_messages set status='CANCELED',error_code='authorization_changed',updated_at=now() where id=v_msg.id;return 'false';end if;
  return 'true';
 end if;
 if v_request.message_id is not null then raise sqlstate 'PT409' using message='document_request_already_sent';end if;
 if v_lead.email_suppressed_at is not null or v_lead.status='DISQUALIFIED' then raise sqlstate 'PT422' using message='document_request_unavailable';end if;
 select * into v_route from private.mbn_school_mail_routes where school_code=v_app.school_code for share;
 if not found or v_route.sender_group is null or v_route.admissions_email='' then raise sqlstate 'PT422' using message='mail_route_missing';end if;
 select * into v_group from private.mbn_mail_sender_groups where code=v_route.sender_group for update;
 if not private.mbn_mail_profile_ready(v_group.code) then raise sqlstate 'PT422' using message='sender_not_ready';end if;
 select daily_limit into v_limit from private.mbn_mail_settings where id;
 if (select count(*) from public.mail_messages where accepted_at>=date_trunc('day',now()) or (status in ('SENDING','UNCERTAIN') and claimed_at>=date_trunc('day',now())))>=v_limit then raise sqlstate 'PT429' using message='daily_limit_reached';end if;
 insert into public.mail_messages(school_code,lead_id,recipient,subject,body,status,created_by,attempt_id,claimed_at,sender_group,sender_identity,sender_revision,credential_fingerprint,mail_route_revision,service_contact_email,document_request_id)
  values(v_app.school_code,v_app.lead_id,v_lead.email,'Documents à compléter','Demande de pièces complémentaires','SENDING',p_actor,gen_random_uuid(),now(),v_group.code,v_group.from_email,v_group.revision,v_group.credential_fingerprint,v_route.revision,v_route.admissions_email,v_request.id) returning * into v_msg;
 update private.mbn_document_requests set message_id=v_msg.id where id=v_request.id;
 return jsonb_build_object('request',to_jsonb(v_request),'reference',v_app.application_reference,'message',to_jsonb(v_msg),'sender',public.mbn_mail_profile_settings(v_group.code));
end;$$;

create function public.mbn_correction_info(p_request uuid) returns jsonb
language plpgsql stable security invoker set search_path='' as $$
declare q private.mbn_document_requests;a public.crm_applications;s public.schools;begin
 select * into q from private.mbn_document_requests where id=p_request;
 select * into a from public.crm_applications where id=q.application_id;
 select * into s from public.schools where code=a.school_code;
 if q.id is null or q.status='CANCELED' or q.expires_at<=now() or not s.is_active or a.is_test or exists(select 1 from public.crm_leads where id=a.lead_id and (is_test or status='DISQUALIFIED')) or (q.status<>'COMPLETED' and a.status<>'MISSING_DOCUMENTS') then raise sqlstate 'PT404' using message='link_unavailable';end if;
 return jsonb_build_object('school_code',s.code,'school_name',s.name,'reference',a.application_reference,'items',q.items,'expires_at',q.expires_at,'completed',q.status='COMPLETED');
end;$$;
create function public.mbn_correction_prepare(p_request uuid,p_manifest jsonb,p_fingerprint text) returns jsonb
language plpgsql security invoker set search_path='' as $$
declare q private.mbn_document_requests;d private.mbn_correction_submissions;x jsonb;v_total integer:=0;begin
 perform 1 from public.crm_applications where id=(select application_id from private.mbn_document_requests where id=p_request) for update;
 perform public.mbn_correction_info(p_request);
 select * into q from private.mbn_document_requests where id=p_request for update;
 select * into d from private.mbn_correction_submissions where request_id=p_request for update;
 if found then
  if d.fingerprint is distinct from p_fingerprint then raise sqlstate 'PT409' using message='reference_conflict';end if;
  return jsonb_build_object('submission_id',d.id,'completed',d.completed_at is not null);
 end if;
 if q.status<>'OPEN' or p_fingerprint is null or p_fingerprint !~ '^[a-f0-9]{64}$' or jsonb_typeof(p_manifest) is distinct from 'array' then raise sqlstate 'PT422' using message='invalid_document_request';end if;
 if jsonb_array_length(p_manifest)<>jsonb_array_length(q.items) then raise sqlstate 'PT422' using message='requested_documents_only';end if;
 for x in select value from jsonb_array_elements(p_manifest) loop
  if not exists(select 1 from jsonb_array_elements(q.items) i where i->>'kind'=x->>'kind') or coalesce(x->>'sha256','') !~ '^[a-f0-9]{64}$'
   or coalesce(x->>'byte_size','') !~ '^[0-9]{1,7}$' or (x->>'byte_size')::integer not between 1 and 5242880
   or length(coalesce(x->>'original_name','')) not between 1 and 180 or x->>'original_name' ~ E'[/\\\\\r\n]'
   or not ((coalesce(x->>'mime_type','')='application/pdf' and coalesce(x->>'extension','')='pdf') or (coalesce(x->>'mime_type','')='image/png' and coalesce(x->>'extension','')='png') or (coalesce(x->>'mime_type','')='image/jpeg' and coalesce(x->>'extension','')='jpg')) then raise sqlstate 'PT422' using message='invalid_document';end if;
  v_total:=v_total+(x->>'byte_size')::integer;
 end loop;
 if v_total>20971520 or (select count(distinct i->>'kind') from jsonb_array_elements(p_manifest) i)<>jsonb_array_length(q.items) then raise sqlstate 'PT422' using message='requested_documents_only';end if;
 insert into private.mbn_correction_submissions(request_id,manifest,fingerprint) values(p_request,p_manifest,p_fingerprint) returning * into d;
 return jsonb_build_object('submission_id',d.id,'completed',false);
end;$$;
create function public.mbn_correction_complete(p_request uuid,p_submission uuid) returns jsonb
language plpgsql security invoker set search_path='' as $$
declare q private.mbn_document_requests;d private.mbn_correction_submissions;x jsonb;v_path text;begin
 perform 1 from public.crm_applications where id=(select application_id from private.mbn_document_requests where id=p_request) for update;
 perform public.mbn_correction_info(p_request);
 select * into q from private.mbn_document_requests where id=p_request for update;
 select * into d from private.mbn_correction_submissions where id=p_submission and request_id=p_request for update;
 if not found then raise sqlstate 'PT404' using message='submission_not_found';end if;
 if d.completed_at is not null then return jsonb_build_object('success',true,'duplicated',true,'document_count',jsonb_array_length(d.manifest));end if;
 for x in select value from jsonb_array_elements(d.manifest) loop
  if exists(select 1 from public.application_documents where application_id=q.application_id and kind=x->>'kind' and superseded_at is null and review_status='APPROVED') then raise sqlstate 'PT409' using message='document_request_changed';end if;
  v_path:=d.id::text||'/'||(x->>'kind')||'.'||(x->>'extension');
  if not exists(select 1 from storage.objects where bucket_id='mbn-admissions' and name=v_path and (metadata->>'size')::integer=(x->>'byte_size')::integer and metadata->>'mimetype'=x->>'mime_type') then raise sqlstate 'PT409' using message='documents_pending';end if;
 end loop;
 for x in select value from jsonb_array_elements(d.manifest) loop
  update public.application_documents set superseded_at=now() where application_id=q.application_id and kind=x->>'kind' and superseded_at is null;
  insert into public.application_documents(application_id,correction_submission_id,bucket,kind,object_path,original_name,mime_type,byte_size,sha256)
   values(q.application_id,d.id,'mbn-admissions',x->>'kind',d.id::text||'/'||(x->>'kind')||'.'||(x->>'extension'),x->>'original_name',x->>'mime_type',(x->>'byte_size')::integer,x->>'sha256');
 end loop;
 update private.mbn_correction_submissions set completed_at=now() where id=d.id;
 update private.mbn_document_requests set status='COMPLETED',completed_at=now() where id=q.id;
 update public.crm_applications set status='DOCUMENTS_TO_VERIFY',updated_at=now() where id=q.application_id;
 insert into public.crm_lead_events(lead_id,event_type,event_metadata) select lead_id,'DOCUMENTS_RESUBMITTED',jsonb_build_object('application_id',q.application_id,'request_id',q.id,'document_count',jsonb_array_length(d.manifest)) from public.crm_applications where id=q.application_id;
 return jsonb_build_object('success',true,'duplicated',false,'document_count',jsonb_array_length(d.manifest));
end;$$;

revoke all on function private.mbn_document_version_guard(),private.mbn_current_documents_guard(),public.mbn_document_requests_action(uuid,uuid,text,jsonb),public.mbn_correction_info(uuid),public.mbn_correction_prepare(uuid,jsonb,text),public.mbn_correction_complete(uuid,uuid) from public,anon,authenticated;
grant execute on function private.mbn_document_version_guard(),private.mbn_current_documents_guard(),public.mbn_document_requests_action(uuid,uuid,text,jsonb),public.mbn_correction_info(uuid),public.mbn_correction_prepare(uuid,jsonb,text),public.mbn_correction_complete(uuid,uuid) to service_role;
