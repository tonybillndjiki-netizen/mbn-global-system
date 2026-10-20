-- Candidate files stay private and cannot be downloaded or approved before a clean verdict.
alter table public.application_documents drop constraint application_documents_scan_status_check;
alter table public.application_documents add constraint application_documents_scan_status_check
 check(scan_status in ('NOT_SCANNED','SCANNING','CLEAN','INFECTED','ERROR'));
alter table public.application_documents
 add column scan_attempts integer not null default 0,
 add column scan_attempt_id uuid,
 add column scan_claimed_at timestamptz,
 add column scan_available_at timestamptz not null default now(),
 add column scanned_at timestamptz,
 add column scan_engine text,
 add column scan_error text,
 add column scan_revision uuid not null default gen_random_uuid();
create index mbn_documents_scan_due on public.application_documents(scan_available_at,created_at) where scan_status in ('NOT_SCANNED','ERROR','SCANNING') and superseded_at is null;
create table private.mbn_scan_settings(id boolean primary key default true check(id),enabled boolean not null default false,revision uuid not null default gen_random_uuid());
insert into private.mbn_scan_settings(id) values(true);
alter table private.mbn_scan_settings enable row level security;
revoke all on private.mbn_scan_settings from public,anon,authenticated;
grant select,update on private.mbn_scan_settings to service_role;

create function private.mbn_scan_review_guard() returns trigger language plpgsql security invoker set search_path='' as $$begin
 if new.review_status='APPROVED' and new.review_status is distinct from old.review_status and new.scan_status<>'CLEAN' then
  raise sqlstate 'PT422' using message='document_scan_required';end if;
 if (new.bucket,new.object_path,new.sha256,new.byte_size) is distinct from (old.bucket,old.object_path,old.sha256,old.byte_size) then
  raise sqlstate 'PT409' using message='document_content_immutable';end if;
 return new;
end;$$;
-- Run after the existing version guard so a stale version keeps its explicit error.
create trigger mbn_z_scan_review_guard before update on public.application_documents for each row execute function private.mbn_scan_review_guard();
create function private.mbn_scan_decision_guard() returns trigger language plpgsql security invoker set search_path='' as $$begin
 if new.status is distinct from old.status and new.status in ('COMPLETE','READY_FOR_DECISION','ADMITTED') then
  perform 1 from public.application_documents where application_id=new.id and superseded_at is null for share;
  if exists(select 1 from public.application_documents where application_id=new.id and superseded_at is null and scan_status<>'CLEAN') then
   raise sqlstate 'PT422' using message='document_scan_required';end if;
 end if;return new;
end;$$;
create trigger mbn_z_scan_decision_guard before update of status on public.crm_applications for each row execute function private.mbn_scan_decision_guard();

create function public.mbn_scan_claim() returns jsonb language plpgsql security invoker set search_path='' as $$
declare v_doc public.application_documents;begin
 if not exists(select 1 from private.mbn_scan_settings where id and enabled) then return null;end if;
 update public.application_documents set scan_status='ERROR',scan_error='scanner_attempts_exhausted',scan_revision=gen_random_uuid()
  where scan_status='SCANNING' and scan_attempts>=5 and scan_claimed_at<now()-interval '90 seconds' and superseded_at is null;
 select * into v_doc from public.application_documents where superseded_at is null and scan_attempts<5 and
  ((scan_status in ('NOT_SCANNED','ERROR') and scan_available_at<=now()) or (scan_status='SCANNING' and scan_claimed_at<now()-interval '90 seconds'))
 order by scan_available_at,created_at,id limit 1 for update skip locked;
 if not found then return null;end if;
 update public.application_documents set scan_status='SCANNING',scan_attempts=scan_attempts+1,scan_attempt_id=gen_random_uuid(),scan_claimed_at=now(),scan_revision=gen_random_uuid()
 where id=v_doc.id returning * into v_doc;
 return jsonb_build_object('id',v_doc.id,'bucket',v_doc.bucket,'object_path',v_doc.object_path,'sha256',v_doc.sha256,'byte_size',v_doc.byte_size,'attempt_id',v_doc.scan_attempt_id);
end;$$;
create function public.mbn_scan_finish(p_id uuid,p_attempt uuid,p_sha256 text,p_status text,p_engine text,p_error text) returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_doc public.application_documents;v_lead uuid;begin
 select * into v_doc from public.application_documents where id=p_id for update;
 if not found or v_doc.scan_status<>'SCANNING' or v_doc.scan_attempt_id is distinct from p_attempt or v_doc.superseded_at is not null or v_doc.scan_claimed_at<now()-interval '90 seconds'
  or v_doc.sha256 is distinct from p_sha256 then return jsonb_build_object('status','STALE');end if;
 if p_status is null or p_status not in ('CLEAN','INFECTED','ERROR') or (p_status<>'ERROR' and coalesce(p_engine,'')!~'^[A-Za-z0-9 ./_():+-]{3,180}$')
  or (p_error is not null and p_error!~'^[a-z_]{3,80}$') then raise sqlstate 'PT422' using message='invalid_scan_result';end if;
 -- Pausing prevents new jobs; a completed detection on an existing lease is retained.
 update public.application_documents set scan_status=p_status,scan_engine=case when p_status<>'ERROR' then p_engine end,
  scanned_at=case when p_status<>'ERROR' then now() end,scan_error=p_error,scan_revision=gen_random_uuid(),
  scan_available_at=now()+make_interval(secs=>least(3600,(60*power(2,v_doc.scan_attempts-1))::integer))
 where id=p_id;
 select lead_id into v_lead from public.crm_applications where id=v_doc.application_id;
 insert into public.crm_lead_events(lead_id,event_type,event_metadata) values(v_lead,'DOCUMENT_SCANNED',jsonb_build_object('application_id',v_doc.application_id,'document_id',p_id,'status',p_status,'engine',case when p_status<>'ERROR' then p_engine end,'error',p_error));
 return jsonb_build_object('status',p_status);
end;$$;
create function public.mbn_scan_admin_action(p_actor uuid,p_session uuid,p_action text,p_data jsonb default '{}') returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_ctx jsonb;v_settings private.mbn_scan_settings;begin
 v_ctx:=public.mbn_pin_context(p_actor,p_session,p_actor);
 if not coalesce((v_ctx->>'admin')::boolean,false) then raise sqlstate 'PT403' using message='access_denied';end if;
 if jsonb_typeof(p_data) is distinct from 'object' then raise sqlstate 'PT400' using message='invalid_request';end if;
 if p_action='save' then
  if jsonb_typeof(p_data->'enabled') is distinct from 'boolean' then raise sqlstate 'PT422' using message='invalid_request';end if;
  update private.mbn_scan_settings set enabled=(p_data->>'enabled')::boolean,revision=gen_random_uuid() where id and revision::text=p_data->>'expected_revision';
  if not found then raise sqlstate 'PT409' using message='scan_changed';end if;
 elsif p_action='retry' then
  update public.application_documents set scan_status='NOT_SCANNED',scan_attempts=0,scan_attempt_id=null,scan_claimed_at=null,scan_available_at=now(),scan_revision=gen_random_uuid()
   where id::text=p_data->>'id' and scan_revision::text=p_data->>'expected_revision' and scan_status='ERROR' and superseded_at is null;
  if not found then raise sqlstate 'PT409' using message='scan_changed';end if;
 elsif p_action<>'context' or p_action is null then raise sqlstate 'PT400' using message='unknown_action';end if;
 select * into v_settings from private.mbn_scan_settings where id;
 return jsonb_build_object('settings',to_jsonb(v_settings),
  'counts',(select coalesce(jsonb_object_agg(scan_status,n),'{}') from (select scan_status,count(*) as n from public.application_documents where superseded_at is null group by scan_status) s),
  'errors',(select coalesce(jsonb_agg(to_jsonb(e)),'[]') from (select id,kind,scan_status,scan_attempts,scan_error,scan_revision from public.application_documents where superseded_at is null and scan_status in ('ERROR','INFECTED') order by created_at desc,id limit 50) e));
end;$$;
revoke all on function public.mbn_scan_claim(),public.mbn_scan_finish(uuid,uuid,text,text,text,text),public.mbn_scan_admin_action(uuid,uuid,text,jsonb) from public,anon,authenticated;
grant execute on function public.mbn_scan_claim(),public.mbn_scan_finish(uuid,uuid,text,text,text,text),public.mbn_scan_admin_action(uuid,uuid,text,jsonb) to service_role;

create or replace function public.mbn_workspace_document(p_actor uuid,p_session uuid,p_document uuid) returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_doc public.application_documents;v_app public.crm_applications;v_ctx jsonb;begin
 v_ctx:=public.mbn_pin_context(p_actor,p_session,p_actor);
 select * into v_doc from public.application_documents where id=p_document;
 select * into v_app from public.crm_applications where id=v_doc.application_id;
 if v_app.id is null or not private.mbn_ws_can(p_actor,v_app.school_code,'review') or (v_app.is_test and not (v_ctx->>'admin')::boolean) then raise sqlstate 'PT404' using message='record_not_found';end if;
 if v_doc.scan_status<>'CLEAN' then raise sqlstate 'PT422' using message='document_scan_required';end if;
 return jsonb_build_object('bucket',v_doc.bucket,'object_path',v_doc.object_path,'sha256',v_doc.sha256,'original_name',v_doc.original_name);
end;$$;
create or replace function public.mbn_native_document(p_actor uuid,p_document uuid) returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_doc public.application_documents;begin
 if not private.mbn_native_actor_allowed(p_actor) then raise sqlstate 'PT403' using message='admin_required';end if;
 select * into v_doc from public.application_documents where id=p_document;
 if not found then raise sqlstate 'PT404' using message='document_not_found';end if;
 if v_doc.scan_status<>'CLEAN' then raise sqlstate 'PT422' using message='document_scan_required';end if;
 return jsonb_build_object('bucket',v_doc.bucket,'object_path',v_doc.object_path,'original_name',v_doc.original_name,'mime_type',v_doc.mime_type,'sha256',v_doc.sha256);
end;$$;
-- Historical approvals and decisions remain recorded. Only future downloads, approvals and decisions are guarded.
create function private.mbn_scan_tick() returns void language plpgsql security definer set search_path='' as $$
declare v_url text;begin
 select project_url into v_url from private.mbn_installation_settings where id;
 if v_url is null or not exists(select 1 from private.mbn_scan_settings where id and enabled) then return;end if;
 execute 'select net.http_post(url:=$1,headers:=$2,body:=$3,timeout_milliseconds:=55000)'
 using v_url||'/functions/v1/mbn-antivirus',jsonb_build_object('Content-Type','application/json','x-mbn-worker',private.mbn_runtime_secret('worker')),'{}'::jsonb;
end;$$;
revoke all on function private.mbn_scan_review_guard(),private.mbn_scan_decision_guard(),private.mbn_scan_tick() from public,anon,authenticated,service_role;
do $$begin
 if to_regprocedure('cron.schedule(text,text,text)') is not null then
  execute 'select cron.schedule(''mbn-antivirus-due'',''* * * * *'',''select private.mbn_scan_tick();'')';end if;
end;$$;
