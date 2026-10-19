-- MBN Mail + CRM: every business mutation goes through the authenticated Edge API.
-- This migration is additive: existing prospects, applications and PINs are preserved.
grant select on public.school_memberships,public.school_campuses,public.campuses to service_role;
grant select,insert,update on public.crm_leads,public.crm_applications,public.crm_lead_events,public.crm_outreach_queue to service_role;
grant usage,select on sequence public.crm_lead_events_id_seq to service_role;
alter table public.school_memberships
 add column can_review_documents boolean not null default false,
 add column can_decide boolean not null default false,
 add column can_send_letters boolean not null default false,
 add column can_send_campaigns boolean not null default false;
alter table public.crm_leads
 add column email_suppressed_at timestamptz,
 add column email_suppression_reason text;
alter table public.crm_applications
 add column assigned_admissions_user uuid references public.profiles(user_id),
 add column routing_status text not null default 'UNASSIGNED' check(routing_status in ('ASSIGNED','UNASSIGNED')),
 add column decision_by uuid references public.profiles(user_id),
 add column decision_at timestamptz;
alter table public.application_documents
 add column review_status text not null default 'PENDING' check(review_status in ('PENDING','APPROVED','REJECTED')),
 add column review_note text,
 add column reviewed_by uuid references public.profiles(user_id),
 add column reviewed_at timestamptz;
grant update on public.application_documents to service_role;

create table public.admission_routing_rules(
 id uuid primary key default gen_random_uuid(),
 school_code text not null references public.schools(code),
 program_id uuid references public.school_programs(id),
 campus_code text references public.campuses(code),
 intake text,
 priority integer not null default 0 check(priority between 0 and 1000),
 primary_user uuid not null references public.profiles(user_id),
 backup_user uuid references public.profiles(user_id),
 is_active boolean not null default true,
 created_at timestamptz not null default now()
);
create index admission_routing_school_idx on public.admission_routing_rules(school_code,is_active);

create table public.mail_templates(
 id uuid primary key default gen_random_uuid(),
 school_code text not null references public.schools(code),
 name text not null check(length(name) between 1 and 120),
 subject text not null check(length(subject) between 1 and 200 and subject !~ E'[\r\n]'),
 body text not null check(length(body) between 1 and 20000),
 created_by uuid not null references public.profiles(user_id),
 updated_at timestamptz not null default now()
);
create table public.mail_campaigns(
 id uuid primary key default gen_random_uuid(),
 school_code text not null references public.schools(code),
 name text not null check(length(name) between 1 and 120),
 subject text not null check(length(subject) between 1 and 200 and subject !~ E'[\r\n]'),
 body text not null check(length(body) between 1 and 20000),
 status text not null default 'DRAFT' check(status in ('DRAFT','ACTIVE','PAUSED','COMPLETED')),
 starts_at timestamptz not null default now(),
 created_by uuid not null references public.profiles(user_id),
 created_at timestamptz not null default now(),
 launched_at timestamptz
);
alter table public.crm_outreach_queue add column campaign_id uuid references public.mail_campaigns(id);
create index crm_outreach_campaign_idx on public.crm_outreach_queue(campaign_id);

create table public.mail_messages(
 id uuid primary key default gen_random_uuid(),
 school_code text not null references public.schools(code),
 lead_id uuid references public.crm_leads(id),
 campaign_id uuid references public.mail_campaigns(id),
 outreach_id uuid unique references public.crm_outreach_queue(id),
 recipient text not null check(length(recipient)<=254 and recipient !~ E'[\r\n]'),
 subject text not null check(length(subject) between 1 and 200 and subject !~ E'[\r\n]'),
 body text not null check(length(body) between 1 and 20000),
 status text not null default 'QUEUED' check(status in ('QUEUED','SENDING','ACCEPTED','DELIVERED','BOUNCED','COMPLAINED','CANCELED','FAILED','UNCERTAIN')),
 scheduled_at timestamptz not null default now(),
 created_by uuid references public.profiles(user_id),
 is_test boolean not null default false,
 attempt_id uuid,
 claimed_at timestamptz,
 accepted_at timestamptz,
 delivered_at timestamptz,
 provider_message_id text,
 error_code text,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create index mail_messages_due_idx on public.mail_messages(status,scheduled_at);
create index mail_messages_school_idx on public.mail_messages(school_code,created_at desc);
create index mail_messages_lead_idx on public.mail_messages(lead_id);
create index mail_messages_campaign_idx on public.mail_messages(campaign_id);

create table private.mbn_mail_settings(
 id boolean primary key default true check(id),
 from_name text not null default 'MBN GLOBAL ÉDUCATION',
 from_email text not null default '',
 reply_to text not null default '',
 identity text not null default '',
 region text not null default 'eu-west-3' check(region ~ '^[a-z]{2}-[a-z]+-[0-9]$'),
 configuration_set text not null default '',
 sns_topic_arn text not null default '',
 events_verified_at timestamptz,
 enabled boolean not null default false,
 daily_limit integer not null default 100 check(daily_limit between 1 and 10000),
 sender_verified boolean not null default false,
 production_access boolean not null default false,
 account_sending_enabled boolean not null default false,
 provider_checked_at timestamptz,
 provider_error text,
 last_test_accepted_at timestamptz,
 updated_at timestamptz not null default now()
);
insert into private.mbn_mail_settings(id) values(true);
alter table private.mbn_mail_settings enable row level security;
revoke all on private.mbn_mail_settings from public,anon,authenticated;
grant select,update on private.mbn_mail_settings to service_role;

create function private.mbn_ws_can(p_actor uuid,p_school text,p_permission text default 'read')
returns boolean language sql stable security invoker set search_path='' as $$
 select private.mbn_pin_account_ready(p_actor) and (private.mbn_native_actor_allowed(p_actor) or exists(
  select 1 from public.school_memberships m join public.profiles p on p.user_id=m.user_id
  join public.schools s on s.code=m.school_code
  where m.user_id=p_actor and m.school_code=p_school and m.is_active and p.is_active and s.is_active
  and case p_permission
   when 'read' then true
   when 'lead' then m.role in ('CM','ADMISSIONS','DIRECTION')
   when 'review' then m.can_review_documents
   when 'decide' then m.can_decide
   when 'letters' then m.can_send_letters
   when 'campaign' then m.can_send_campaigns
   else false end
 ));
$$;
revoke all on function private.mbn_ws_can(uuid,text,text) from public,anon,authenticated;
grant execute on function private.mbn_ws_can(uuid,text,text) to service_role;

create function private.mbn_ws_admissions_active(p_user uuid,p_school text)
returns boolean language sql stable security invoker set search_path='' as $$
 select p_user is not null and exists(
 select 1 from public.profiles p join auth.users u on u.id=p.user_id
 join public.school_memberships m on m.user_id=p.user_id
 where p.user_id=p_user and p.is_active and u.email_confirmed_at is not null
 and u.deleted_at is null and (u.banned_until is null or u.banned_until<now())
 and m.school_code=p_school and m.is_active and m.role in ('ADMISSIONS','DIRECTION'));
$$;
revoke all on function private.mbn_ws_admissions_active(uuid,text) from public,anon,authenticated;
grant execute on function private.mbn_ws_admissions_active(uuid,text) to service_role;

create function private.mbn_ws_route_application()
returns trigger language plpgsql security invoker set search_path='' as $$
declare v_user uuid;
begin
 select case when private.mbn_ws_admissions_active(r.primary_user,new.school_code) then r.primary_user
  when private.mbn_ws_admissions_active(r.backup_user,new.school_code) then r.backup_user end into v_user
 from public.admission_routing_rules r where r.school_code=new.school_code and r.is_active
 and (r.program_id is null or r.program_id=new.program_id)
 and (r.campus_code is null or r.campus_code=new.campus_code)
 and (r.intake is null or r.intake=new.form_payload->>'intake')
 order by ((r.program_id is not null)::int+(r.campus_code is not null)::int+(r.intake is not null)::int) desc,r.priority desc,r.created_at,r.id limit 1;
 new.assigned_admissions_user:=v_user;
 new.routing_status:=case when v_user is null then 'UNASSIGNED' else 'ASSIGNED' end;
 return new;
end;$$;
revoke all on function private.mbn_ws_route_application() from public,anon,authenticated;
grant execute on function private.mbn_ws_route_application() to service_role;
create trigger mbn_route_application before insert on public.crm_applications for each row execute function private.mbn_ws_route_application();

-- A withdrawal, submission or exclusion stops all unsent marketing messages.
create function private.mbn_ws_stop_outreach()
returns trigger language plpgsql security invoker set search_path='' as $$
begin
 -- The existing ingestion RPC cancels queues itself and reports its exact count.
 if new.submitted_at is not null and old.submitted_at is null then
  update public.mail_messages set status='CANCELED',updated_at=now(),error_code='application_submitted' where lead_id=new.id and status='QUEUED';
  return new;
 end if;
 if new.submitted_at is not null or new.clicked_at is not null or new.unsubscribed_at is not null
  or new.email_suppressed_at is not null or not new.consent_email or new.status in ('DISQUALIFIED','UNSUBSCRIBED','SUBMITTED','CLICKED','STARTED') then
  update public.crm_outreach_queue set status='CANCELED',canceled_at=now() where lead_id=new.id and status in ('PENDING','FAILED');
  update public.mail_messages set status='CANCELED',updated_at=now(),error_code='recipient_no_longer_eligible' where lead_id=new.id and status='QUEUED';
 end if;
 return new;
end;$$;
revoke all on function private.mbn_ws_stop_outreach() from public,anon,authenticated;
grant execute on function private.mbn_ws_stop_outreach() to service_role;
create trigger mbn_stop_outreach after update on public.crm_leads for each row execute function private.mbn_ws_stop_outreach();

do $$declare t text;begin
 foreach t in array array['admission_routing_rules','mail_templates','mail_campaigns','mail_messages'] loop
  execute format('alter table public.%I enable row level security',t);
  execute format('create policy workspace_school_read on public.%I for select to authenticated using (private.can_read_school(school_code))',t);
  execute format('revoke all on public.%I from anon,authenticated',t);
  execute format('grant select on public.%I to authenticated',t);
  execute format('grant all on public.%I to service_role',t);
 end loop;
end;$$;
-- Existing admin policies are retained for reads; business writes now require the API.
revoke insert,update,delete on public.crm_leads,public.crm_applications,public.crm_lead_events,public.crm_outreach_queue from authenticated;

create function private.mbn_ws_eligible(p_lead public.crm_leads)
returns boolean language sql stable security invoker set search_path='' as $$
 select not p_lead.is_test and p_lead.source='META_LEAD' and p_lead.consent_email
 and p_lead.status in ('NEW','INVITED') and p_lead.submitted_at is null
 and p_lead.clicked_at is null and p_lead.unsubscribed_at is null and p_lead.email_suppressed_at is null
 and p_lead.email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'
 and exists(select 1 from public.schools s where s.code=p_lead.school_code and s.is_active);
$$;
revoke all on function private.mbn_ws_eligible(public.crm_leads) from public,anon,authenticated;
grant execute on function private.mbn_ws_eligible(public.crm_leads) to service_role;

create function public.mbn_workspace_action(p_actor uuid,p_session uuid,p_action text,p_data jsonb default '{}'::jsonb)
returns jsonb language plpgsql security invoker set search_path='' as $$
declare
 v_ctx jsonb; v_admin boolean; v_result jsonb; v_school text; v_id uuid; v_lead public.crm_leads;
 v_app public.crm_applications; v_campaign public.mail_campaigns; v_rows jsonb; v_row jsonb;
 v_count integer; v_offset integer; v_query text; v_status text; v_email text; v_target uuid;
 v_settings private.mbn_mail_settings; v_now timestamptz:=now();
begin
 v_ctx:=public.mbn_pin_context(p_actor,p_session,p_actor); v_admin:=coalesce((v_ctx->>'admin')::boolean,false);
 if jsonb_typeof(p_data)<>'object' then raise sqlstate 'PT400' using message='invalid_request';end if;
 v_school:=nullif(p_data->>'school_code','');
 v_query:=left(coalesce(p_data->>'search',''),120);
 v_offset:=greatest(0,least(100000,coalesce((p_data->>'offset')::integer,0)));

 if p_action='bootstrap' then
  return jsonb_build_object('admin',v_admin,'schools',(select coalesce(jsonb_agg(to_jsonb(s) order by s.name),'[]') from public.schools s where private.mbn_ws_can(p_actor,s.code)),
   'permissions',(select coalesce(jsonb_agg(to_jsonb(m)),'[]') from public.school_memberships m where m.user_id=p_actor and m.is_active),
   'counts',jsonb_build_object(
    'leads',(select count(*) from public.crm_leads l where not l.is_test and private.mbn_ws_can(p_actor,l.school_code)),
    'applications',(select count(*) from public.crm_applications a where not a.is_test and private.mbn_ws_can(p_actor,a.school_code)),
    'unassigned',(select count(*) from public.crm_applications a where not a.is_test and a.routing_status='UNASSIGNED' and private.mbn_ws_can(p_actor,a.school_code)),
    'queued',(select count(*) from public.mail_messages m where not m.is_test and m.status='QUEUED' and private.mbn_ws_can(p_actor,m.school_code)),
    'accepted',(select count(*) from public.mail_messages m where not m.is_test and m.status in ('ACCEPTED','DELIVERED') and private.mbn_ws_can(p_actor,m.school_code)),
    'eligible',(select count(*) from public.crm_leads l where private.mbn_ws_eligible(l) and private.mbn_ws_can(p_actor,l.school_code))));
 elsif p_action='leads_list' then
  select jsonb_build_object('total',count(*)) into v_result from public.crm_leads l
   where not l.is_test and private.mbn_ws_can(p_actor,l.school_code) and (v_school is null or l.school_code=v_school)
   and (v_query='' or l.full_name ilike '%'||v_query||'%' or l.email ilike '%'||v_query||'%')
   and (nullif(p_data->>'status','') is null or l.status=p_data->>'status');
  select coalesce(jsonb_agg(to_jsonb(x)),'[]') into v_rows from (select l.* from public.crm_leads l
   where not l.is_test and private.mbn_ws_can(p_actor,l.school_code) and (v_school is null or l.school_code=v_school)
   and (v_query='' or l.full_name ilike '%'||v_query||'%' or l.email ilike '%'||v_query||'%')
   and (nullif(p_data->>'status','') is null or l.status=p_data->>'status') order by l.created_at desc,l.id limit 50 offset v_offset) x;
  return v_result||jsonb_build_object('rows',v_rows);
 elsif p_action in ('lead_save','leads_import') then
  v_rows:=case when p_action='lead_save' then jsonb_build_array(p_data) else p_data->'rows' end;
  if jsonb_typeof(v_rows)<>'array' or jsonb_array_length(v_rows) not between 1 and 500 then raise sqlstate 'PT400' using message='invalid_import';end if;
  v_count:=0;
  for v_row in select value from jsonb_array_elements(v_rows) loop
   v_school:=v_row->>'school_code';v_email:=lower(btrim(v_row->>'email'));
   if not private.mbn_ws_can(p_actor,v_school,'lead') then raise sqlstate 'PT403' using message='access_denied';end if;
   if not exists(select 1 from public.schools where code=v_school and is_active) then raise sqlstate 'PT422' using message='school_inactive';end if;
   if coalesce(length(btrim(v_row->>'full_name')),0) not between 2 and 200 or coalesce(length(v_email),0) not between 5 and 254
    or v_email !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'
    or coalesce(v_row->>'source','IMPORT') not in ('META_LEAD','META_MESSENGER','DIRECT','IMPORT','OTHER')
    or length(coalesce(v_row->>'phone',''))>50 or length(coalesce(v_row->>'consent_source',''))>300 then
    raise sqlstate 'PT422' using message='invalid_lead';
   end if;
   if coalesce((v_row->>'consent_email')::boolean,false) and length(btrim(coalesce(v_row->>'consent_source','')))<3 then raise sqlstate 'PT422' using message='consent_evidence_required';end if;
   -- Import never silently overwrites a withdrawal or merges ambiguous identities.
   if exists(select 1 from public.crm_leads where school_code=v_school and lower(email)=v_email and not is_test) then
    if p_action='lead_save' then raise sqlstate 'PT409' using message='lead_already_exists';end if;
    continue;
   end if;
   insert into public.crm_leads(school_code,full_name,email,phone,country_of_residence,source,source_external_id,consent_email,consent_recorded_at,consent_source)
   values(v_school,btrim(v_row->>'full_name'),v_email,nullif(v_row->>'phone',''),left(v_row->>'country_of_residence',100),coalesce(v_row->>'source','IMPORT'),nullif(left(v_row->>'source_external_id',200),''),
    coalesce((v_row->>'consent_email')::boolean,false),case when (v_row->>'consent_email')::boolean then v_now end,nullif(v_row->>'consent_source','')) returning id into v_id;
   insert into public.crm_lead_events(lead_id,event_type,event_metadata) values(v_id,'LEAD_CREATED',jsonb_build_object('actor_id',p_actor,'via',p_action));
   v_count:=v_count+1;
  end loop;
  return jsonb_build_object('created',v_count,'skipped',jsonb_array_length(v_rows)-v_count,'id',v_id);
 elsif p_action in ('lead_detail','lead_note','lead_exclude') then
  select * into v_lead from public.crm_leads where id=(p_data->>'id')::uuid for update;
  if not found or (v_lead.is_test and not v_admin) or not private.mbn_ws_can(p_actor,v_lead.school_code) then raise sqlstate 'PT404' using message='record_not_found';end if;
  if p_action='lead_detail' then
   return jsonb_build_object('lead',to_jsonb(v_lead),'can_manage',private.mbn_ws_can(p_actor,v_lead.school_code,'lead'),'events',(select coalesce(jsonb_agg(to_jsonb(x)),'[]') from (select id,event_type,event_metadata,created_at from public.crm_lead_events where lead_id=v_lead.id and (event_type<>'DOCUMENT_REVIEWED' or private.mbn_ws_can(p_actor,v_lead.school_code,'review')) order by created_at desc,id desc limit 100) x));
  end if;
  if not private.mbn_ws_can(p_actor,v_lead.school_code,'lead') then raise sqlstate 'PT403' using message='access_denied';end if;
  if length(btrim(coalesce(p_data->>'note',''))) not between 1 and 2000 then raise sqlstate 'PT422' using message='note_required';end if;
  if p_action='lead_exclude' then
   update public.crm_leads set status='DISQUALIFIED',consent_email=false,email_suppressed_at=v_now,email_suppression_reason='MANUAL',updated_at=v_now where id=v_lead.id;
  end if;
  insert into public.crm_lead_events(lead_id,event_type,event_metadata) values(v_lead.id,case when p_action='lead_note' then 'NOTE' else 'EXCLUDED' end,jsonb_build_object('actor_id',p_actor,'note',p_data->>'note'));
  return jsonb_build_object('success',true);
 elsif p_action='applications_list' then
  select jsonb_build_object('total',count(*)) into v_result from public.crm_applications a join public.crm_leads l on l.id=a.lead_id
   where not a.is_test and private.mbn_ws_can(p_actor,a.school_code) and (v_school is null or a.school_code=v_school)
   and (v_query='' or l.full_name ilike '%'||v_query||'%' or a.application_reference ilike '%'||v_query||'%' or l.email ilike '%'||v_query||'%')
   and (nullif(p_data->>'status','') is null or a.status=p_data->>'status');
  select coalesce(jsonb_agg(to_jsonb(x)),'[]') into v_rows from (select a.id,a.lead_id,a.school_code,a.campus_code,a.program_id,a.application_reference,a.admission_type,a.status,a.received_at,a.updated_at,a.routing_status,a.assigned_admissions_user,
   l.full_name,l.email,p.name as program_name,pr.full_name as assignee_name
   from public.crm_applications a join public.crm_leads l on l.id=a.lead_id left join public.school_programs p on p.id=a.program_id left join public.profiles pr on pr.user_id=a.assigned_admissions_user
   where not a.is_test and private.mbn_ws_can(p_actor,a.school_code) and (v_school is null or a.school_code=v_school)
   and (v_query='' or l.full_name ilike '%'||v_query||'%' or a.application_reference ilike '%'||v_query||'%' or l.email ilike '%'||v_query||'%')
   and (nullif(p_data->>'status','') is null or a.status=p_data->>'status') order by a.received_at desc,a.id limit 50 offset v_offset) x;
  return v_result||jsonb_build_object('rows',v_rows);
 elsif p_action in ('application_detail','application_transition','application_assign','document_review') then
  select * into v_app from public.crm_applications where id=(p_data->>'id')::uuid for update;
  if not found or (v_app.is_test and not v_admin) or not private.mbn_ws_can(p_actor,v_app.school_code) then raise sqlstate 'PT404' using message='record_not_found';end if;
  if p_action='application_detail' then
   select to_jsonb(l) into v_row from public.crm_leads l where id=v_app.lead_id;
   return jsonb_build_object('application',to_jsonb(v_app)-'form_payload','lead',v_row,
    'program',(select to_jsonb(p) from public.school_programs p where p.id=v_app.program_id),
    'can_review',private.mbn_ws_can(p_actor,v_app.school_code,'review'),'can_decide',private.mbn_ws_can(p_actor,v_app.school_code,'decide'),
    'can_assign',v_admin,
    'documents',case when private.mbn_ws_can(p_actor,v_app.school_code,'review') then (select coalesce(jsonb_agg(jsonb_build_object('id',d.id,'kind',d.kind,'original_name',d.original_name,'byte_size',d.byte_size,'scan_status',d.scan_status,'review_status',d.review_status,'review_note',d.review_note)),'[]') from public.application_documents d where d.application_id=v_app.id) else '[]'::jsonb end,
    'events',(select coalesce(jsonb_agg(to_jsonb(x)),'[]') from (select id,event_type,event_metadata,created_at from public.crm_lead_events where lead_id=v_app.lead_id and (event_type<>'DOCUMENT_REVIEWED' or private.mbn_ws_can(p_actor,v_app.school_code,'review')) order by created_at desc,id desc limit 100) x),
    'assignees',case when v_admin then (select coalesce(jsonb_agg(jsonb_build_object('id',p.user_id,'name',coalesce(nullif(p.full_name,''),p.email))),'[]') from public.profiles p where private.mbn_ws_admissions_active(p.user_id,v_app.school_code)) else '[]'::jsonb end);
  elsif p_action='application_assign' then
   v_target:=nullif(p_data->>'user_id','')::uuid;
   if not v_admin then raise sqlstate 'PT403' using message='access_denied';end if;
   if v_target is not null and not private.mbn_ws_admissions_active(v_target,v_app.school_code) then raise sqlstate 'PT422' using message='inactive_assignee';end if;
   update public.crm_applications set assigned_admissions_user=v_target,routing_status=case when v_target is null then 'UNASSIGNED' else 'ASSIGNED' end,updated_at=v_now where id=v_app.id;
   insert into public.crm_lead_events(lead_id,event_type,event_metadata) values(v_app.lead_id,'ASSIGNMENT_CHANGED',jsonb_build_object('application_id',v_app.id,'actor_id',p_actor,'previous',v_app.assigned_admissions_user,'assigned',v_target));
  elsif p_action='document_review' then
   if not private.mbn_ws_can(p_actor,v_app.school_code,'review') then raise sqlstate 'PT403' using message='access_denied';end if;
   if p_data->>'review_status' not in ('PENDING','APPROVED','REJECTED') or length(coalesce(p_data->>'note',''))>2000 then raise sqlstate 'PT422' using message='invalid_review';end if;
   update public.application_documents set review_status=p_data->>'review_status',review_note=p_data->>'note',reviewed_by=p_actor,reviewed_at=v_now where id=(p_data->>'document_id')::uuid and application_id=v_app.id;
   if not found then raise sqlstate 'PT404' using message='record_not_found';end if;
   insert into public.crm_lead_events(lead_id,event_type,event_metadata) values(v_app.lead_id,'DOCUMENT_REVIEWED',jsonb_build_object('application_id',v_app.id,'document_id',p_data->>'document_id','actor_id',p_actor,'status',p_data->>'review_status','note',p_data->>'note'));
  else
   v_status:=p_data->>'status';
   if p_data->>'expected_status' is distinct from v_app.status then raise sqlstate 'PT409' using message='record_changed';end if;
   if not private.mbn_ws_can(p_actor,v_app.school_code,case when v_status in ('ADMITTED','REJECTED') then 'decide' else 'review' end) then raise sqlstate 'PT403' using message='access_denied';end if;
   if not (
    (v_app.status='RECEIVED' and v_status in ('IN_REVIEW','CLOSED')) or
    (v_app.status='IN_REVIEW' and v_status in ('MISSING_DOCUMENTS','DOCUMENTS_TO_VERIFY','COMPLETE','CLOSED')) or
    (v_app.status in ('MISSING_DOCUMENTS','DOCUMENTS_TO_VERIFY') and v_status in ('IN_REVIEW','COMPLETE','CLOSED')) or
    (v_app.status='COMPLETE' and v_status in ('READY_FOR_DECISION','IN_REVIEW','CLOSED')) or
    (v_app.status='READY_FOR_DECISION' and v_status in ('ADMITTED','REJECTED','IN_REVIEW','CLOSED')) or
    (v_app.status in ('ADMITTED','REJECTED','LETTER_SENT') and v_status='CLOSED') or
    (v_app.status='LETTER_SENT' and v_status='ENROLLED') or (v_app.status='ENROLLED' and v_status='CLOSED')
   ) then raise sqlstate 'PT422' using message='invalid_transition';end if;
   if v_status in ('ADMITTED','REJECTED') and length(btrim(coalesce(p_data->>'note','')))<3 then raise sqlstate 'PT422' using message='decision_reason_required';end if;
   if v_status='COMPLETE' and (
    not exists(select 1 from public.application_documents where application_id=v_app.id and kind='CV' and review_status='APPROVED') or
    not exists(select 1 from public.application_documents where application_id=v_app.id and kind='DIPLOME' and review_status='APPROVED') or
    not exists(select 1 from public.application_documents where application_id=v_app.id and kind='PIECE_IDENTITE' and review_status='APPROVED') or
    (v_app.admission_type='NATIONAL' and not exists(select 1 from public.application_documents where application_id=v_app.id and kind='CARTE_VITALE' and review_status='APPROVED'))
   ) then raise sqlstate 'PT422' using message='required_documents_not_approved';end if;
   update public.crm_applications set status=v_status,updated_at=v_now,
    decision_by=case when v_status in ('ADMITTED','REJECTED') then p_actor else decision_by end,
    decision_at=case when v_status in ('ADMITTED','REJECTED') then v_now else decision_at end where id=v_app.id;
   insert into public.crm_lead_events(lead_id,event_type,event_metadata) values(v_app.lead_id,'APPLICATION_STATUS_CHANGED',jsonb_build_object('application_id',v_app.id,'actor_id',p_actor,'from',v_app.status,'to',v_status,'note',left(p_data->>'note',2000)));
  end if;
  return jsonb_build_object('success',true);
 elsif p_action in ('campaigns_list','templates_list') then
  if p_action='templates_list' then
   return (select coalesce(jsonb_agg(to_jsonb(t) order by t.updated_at desc),'[]') from public.mail_templates t where private.mbn_ws_can(p_actor,t.school_code) and (v_school is null or t.school_code=v_school));
  end if;
  return (select coalesce(jsonb_agg(to_jsonb(x)),'[]') from (select c.*,(select count(*) from public.mail_messages m where m.campaign_id=c.id) as messages,
   (select count(*) from public.mail_messages m where m.campaign_id=c.id and m.status in ('ACCEPTED','DELIVERED')) as accepted
   from public.mail_campaigns c where private.mbn_ws_can(p_actor,c.school_code) and (v_school is null or c.school_code=v_school) order by c.created_at desc limit 100) x);
 elsif p_action in ('campaign_save','template_save') then
  if not private.mbn_ws_can(p_actor,v_school,'campaign') then raise sqlstate 'PT403' using message='access_denied';end if;
  if not exists(select 1 from public.schools where code=v_school and is_active) then raise sqlstate 'PT422' using message='school_inactive';end if;
  if length(btrim(coalesce(p_data->>'name',''))) not between 1 and 120 or length(btrim(coalesce(p_data->>'subject',''))) not between 1 and 200
   or p_data->>'subject' ~ E'[\r\n]' or length(btrim(coalesce(p_data->>'body',''))) not between 1 and 20000 then raise sqlstate 'PT422' using message='invalid_message';end if;
  if p_action='template_save' then
   insert into public.mail_templates(school_code,name,subject,body,created_by) values(v_school,p_data->>'name',p_data->>'subject',p_data->>'body',p_actor) returning id into v_id;
  else
   insert into public.mail_campaigns(school_code,name,subject,body,starts_at,created_by) values(v_school,p_data->>'name',p_data->>'subject',p_data->>'body',coalesce((p_data->>'starts_at')::timestamptz,v_now),p_actor) returning id into v_id;
  end if;
  return jsonb_build_object('id',v_id);
 elsif p_action in ('campaign_preview','campaign_launch','campaign_pause','campaign_resume') then
  select * into v_campaign from public.mail_campaigns where id=(p_data->>'id')::uuid for update;
  if not found or not private.mbn_ws_can(p_actor,v_campaign.school_code,'campaign') then raise sqlstate 'PT403' using message='access_denied';end if;
  if p_action='campaign_preview' then
   return jsonb_build_object('campaign',to_jsonb(v_campaign),'eligible',(select count(*) from public.crm_leads l where l.school_code=v_campaign.school_code and private.mbn_ws_eligible(l) and not exists(select 1 from public.crm_outreach_queue q where q.lead_id=l.id and q.sequence_type='META_UNCLICKED')),
    'excluded',(select count(*) from public.crm_leads l where l.school_code=v_campaign.school_code and not l.is_test and (not private.mbn_ws_eligible(l) or exists(select 1 from public.crm_outreach_queue q where q.lead_id=l.id and q.sequence_type='META_UNCLICKED'))),
    'schedule_days',jsonb_build_array(0,2,4,6));
  elsif p_action='campaign_pause' then
   update public.mail_campaigns set status='PAUSED' where id=v_campaign.id and status='ACTIVE';
   return jsonb_build_object('success',found);
  elsif p_action='campaign_resume' then
   update public.mail_campaigns set status='ACTIVE' where id=v_campaign.id and status='PAUSED';
   return jsonb_build_object('success',found);
  end if;
  if v_campaign.status<>'DRAFT' then raise sqlstate 'PT409' using message='campaign_already_launched';end if;
  -- Planning is allowed before SES setup. Dispatch remains disabled until the owner enables it.
  with enrolled as (
   insert into public.crm_outreach_queue(lead_id,sequence_type,attempt_number,scheduled_at,status,campaign_id)
   select l.id,'META_UNCLICKED',n::smallint,greatest(v_campaign.starts_at,v_now)+make_interval(days=>n*2),'PENDING',v_campaign.id
   from public.crm_leads l cross join generate_series(0,3) n
   where l.school_code=v_campaign.school_code and private.mbn_ws_eligible(l)
   and not exists(select 1 from public.crm_outreach_queue q where q.lead_id=l.id and q.sequence_type='META_UNCLICKED')
   on conflict(lead_id,sequence_type,attempt_number) do nothing returning *
  ) insert into public.mail_messages(school_code,lead_id,campaign_id,outreach_id,recipient,subject,body,scheduled_at,created_by)
   select v_campaign.school_code,q.lead_id,v_campaign.id,q.id,l.email,v_campaign.subject,v_campaign.body,q.scheduled_at,p_actor from enrolled q join public.crm_leads l on l.id=q.lead_id;
  get diagnostics v_count=row_count;
  if v_count=0 then raise sqlstate 'PT422' using message='no_eligible_recipients';end if;
  update public.mail_campaigns set status='ACTIVE',launched_at=v_now where id=v_campaign.id;
  return jsonb_build_object('messages',v_count,'recipients',v_count/4);
 elsif p_action='messages_list' then
  select coalesce(jsonb_agg(to_jsonb(x)),'[]') into v_rows from (select m.id,m.school_code,m.lead_id,m.campaign_id,m.recipient,m.subject,m.status,m.scheduled_at,m.accepted_at,m.delivered_at,m.error_code,m.is_test,m.created_at
   from public.mail_messages m where private.mbn_ws_can(p_actor,m.school_code) and (v_school is null or m.school_code=v_school)
   and (nullif(p_data->>'status','') is null or m.status=p_data->>'status') order by m.created_at desc,m.id limit 100 offset v_offset) x;
  return v_rows;
 elsif p_action='message_cancel' then
  select school_code into v_school from public.mail_messages where id=(p_data->>'id')::uuid;
  if not private.mbn_ws_can(p_actor,v_school,'campaign') then raise sqlstate 'PT403' using message='access_denied';end if;
  update public.mail_messages set status='CANCELED',updated_at=v_now where id=(p_data->>'id')::uuid and status='QUEUED';
  update public.crm_outreach_queue set status='CANCELED',canceled_at=v_now where id=(select outreach_id from public.mail_messages where id=(p_data->>'id')::uuid) and status='PENDING';
  return jsonb_build_object('success',true);
 elsif p_action in ('settings_get','settings_save','test_prepare') then
  if not v_admin then raise sqlstate 'PT403' using message='access_denied';end if;
  select * into v_settings from private.mbn_mail_settings where id for update;
  if p_action='settings_save' then
   if p_data->>'from_email' !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' or length(p_data->>'from_email')>254
    or length(coalesce(p_data->>'from_name','')) not between 1 and 100 or p_data->>'from_name' ~ E'[\r\n]'
    or length(coalesce(p_data->>'identity','')) not between 3 and 254 or p_data->>'identity' ~ E'[\r\n/]'
    or (coalesce(p_data->>'reply_to','')<>'' and p_data->>'reply_to' !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$')
    or coalesce(p_data->>'configuration_set','') !~ '^[A-Za-z0-9_-]{0,64}$'
    or (coalesce(p_data->>'sns_topic_arn','')<>'' and p_data->>'sns_topic_arn' !~ '^arn:aws:sns:[a-z0-9-]+:[0-9]{12}:[A-Za-z0-9_-]{1,256}$')
    then raise sqlstate 'PT422' using message='invalid_sender';end if;
   if coalesce((p_data->>'enabled')::boolean,false) and (not v_settings.sender_verified or not v_settings.production_access or not v_settings.account_sending_enabled
    or v_settings.provider_checked_at is null or v_settings.provider_checked_at<v_now-interval '1 hour' or v_settings.last_test_accepted_at is null
    or v_settings.events_verified_at is null or coalesce(p_data->>'configuration_set','')='' or coalesce(p_data->>'sns_topic_arn','')=''
    or v_settings.configuration_set is distinct from p_data->>'configuration_set' or v_settings.sns_topic_arn is distinct from p_data->>'sns_topic_arn'
    or v_settings.from_email is distinct from p_data->>'from_email' or v_settings.identity is distinct from p_data->>'identity' or v_settings.region is distinct from p_data->>'region')
    then raise sqlstate 'PT422' using message='sender_not_ready';end if;
   update private.mbn_mail_settings set from_name=p_data->>'from_name',from_email=lower(p_data->>'from_email'),reply_to=coalesce(p_data->>'reply_to',''),identity=p_data->>'identity',region=p_data->>'region',configuration_set=coalesce(p_data->>'configuration_set',''),sns_topic_arn=coalesce(p_data->>'sns_topic_arn',''),
    events_verified_at=case when sns_topic_arn is distinct from coalesce(p_data->>'sns_topic_arn','') or configuration_set is distinct from coalesce(p_data->>'configuration_set','') then null else events_verified_at end,
    enabled=coalesce((p_data->>'enabled')::boolean,false),daily_limit=(p_data->>'daily_limit')::integer,
    sender_verified=case when from_email is distinct from lower(p_data->>'from_email') or identity is distinct from p_data->>'identity' or region is distinct from p_data->>'region' then false else sender_verified end,
    last_test_accepted_at=case when from_email is distinct from lower(p_data->>'from_email') or identity is distinct from p_data->>'identity' or region is distinct from p_data->>'region' then null else last_test_accepted_at end,
    updated_at=v_now where id returning * into v_settings;
  elsif p_action='test_prepare' then
   select lower(email) into v_email from auth.users where id=p_actor;
   select code into v_school from public.schools where is_active order by code limit 1;
   if v_school is null then raise sqlstate 'PT422' using message='school_inactive';end if;
   if exists(select 1 from public.mail_messages where created_by=p_actor and is_test and created_at>v_now-interval '1 minute') then raise sqlstate 'PT429' using message='test_rate_limited';end if;
   insert into public.mail_messages(school_code,recipient,subject,body,is_test,created_by)
   values(v_school,v_email,'MBN Mail — test de connexion','Bonjour,\n\nCe message confirme la connexion de MBN Mail à votre service d’expédition.\n\nMBN GLOBAL ÉDUCATION',true,p_actor) returning id into v_id;
   return jsonb_build_object('id',v_id);
  end if;
  return to_jsonb(v_settings)-'id';
 elsif p_action='routing_list' then
  if not v_admin then raise sqlstate 'PT403' using message='access_denied';end if;
  return (select coalesce(jsonb_agg(to_jsonb(x)),'[]') from (select r.*,p.full_name,p.email from public.admission_routing_rules r join public.profiles p on p.user_id=r.primary_user order by r.school_code,r.priority desc) x);
 elsif p_action='routing_save' then
  if not v_admin then raise sqlstate 'PT403' using message='access_denied';end if;
  v_target:=(p_data->>'primary_user')::uuid;
  if not private.mbn_ws_admissions_active(v_target,v_school) or (nullif(p_data->>'backup_user','') is not null and not private.mbn_ws_admissions_active((p_data->>'backup_user')::uuid,v_school)) then raise sqlstate 'PT422' using message='inactive_assignee';end if;
  if nullif(p_data->>'program_id','') is not null and not exists(select 1 from public.school_programs where id=(p_data->>'program_id')::uuid and school_code=v_school) then raise sqlstate 'PT422' using message='invalid_program';end if;
  if nullif(p_data->>'campus_code','') is not null and not exists(select 1 from public.school_campuses where school_code=v_school and campus_code=p_data->>'campus_code') then raise sqlstate 'PT422' using message='invalid_campus';end if;
  insert into public.admission_routing_rules(school_code,primary_user,backup_user,program_id,campus_code,intake,priority)
   values(v_school,v_target,nullif(p_data->>'backup_user','')::uuid,nullif(p_data->>'program_id','')::uuid,nullif(p_data->>'campus_code',''),nullif(left(p_data->>'intake',80),''),coalesce((p_data->>'priority')::integer,0)) returning id into v_id;
  return jsonb_build_object('id',v_id);
 elsif p_action='routing_toggle' then
  if not v_admin then raise sqlstate 'PT403' using message='access_denied';end if;
  update public.admission_routing_rules set is_active=not is_active where id=(p_data->>'id')::uuid;
  return jsonb_build_object('success',found);
 end if;
 raise sqlstate 'PT400' using message='unknown_action';
end;$$;
revoke all on function public.mbn_workspace_action(uuid,uuid,text,jsonb) from public,anon,authenticated;
grant execute on function public.mbn_workspace_action(uuid,uuid,text,jsonb) to service_role;

-- Transport functions are exclusively called by the service after authenticating the owner/worker.
create function public.mbn_mail_transport_settings() returns jsonb language sql stable security invoker set search_path='' as $$
 select to_jsonb(s)-'id' from private.mbn_mail_settings s where id;
$$;
create function public.mbn_mail_provider_checked(p_result jsonb) returns void language sql security invoker set search_path='' as $$
 update private.mbn_mail_settings set sender_verified=coalesce((p_result->>'sender_verified')::boolean,false),production_access=coalesce((p_result->>'production_access')::boolean,false),
 account_sending_enabled=coalesce((p_result->>'account_sending_enabled')::boolean,false),provider_error=p_result->>'error',provider_checked_at=now(),
 enabled=enabled and coalesce((p_result->>'sender_verified')::boolean,false) and coalesce((p_result->>'production_access')::boolean,false) and coalesce((p_result->>'account_sending_enabled')::boolean,false) where id;
$$;
create function public.mbn_mail_claim(p_test_id uuid default null)
returns jsonb language plpgsql security invoker set search_path='' as $$
declare v_setting private.mbn_mail_settings;v_msg public.mail_messages;v_count integer;
begin
 perform pg_advisory_xact_lock(72519816);
 select * into v_setting from private.mbn_mail_settings where id;
 update public.mail_messages set status='UNCERTAIN',error_code='attempt_expired_review_required',updated_at=now() where status='SENDING' and claimed_at<now()-interval '5 minutes';
 if not v_setting.sender_verified or not v_setting.account_sending_enabled then return null;end if;
 if p_test_id is null and (not v_setting.enabled or not v_setting.production_access or v_setting.provider_checked_at<now()-interval '1 hour') then return null;end if;
 select count(*) into v_count from public.mail_messages where (accepted_at>=date_trunc('day',now()) or (status in ('SENDING','UNCERTAIN') and claimed_at>=date_trunc('day',now())));
 if v_count>=v_setting.daily_limit then return null;end if;
 update public.mail_messages m set status='CANCELED',error_code='recipient_no_longer_eligible',updated_at=now()
  where m.status='QUEUED' and not m.is_test and m.lead_id is not null and not exists(select 1 from public.crm_leads l where l.id=m.lead_id and private.mbn_ws_eligible(l));
 select m.* into v_msg from public.mail_messages m
 where m.status='QUEUED' and m.scheduled_at<=now()
 and ((p_test_id is not null and m.id=p_test_id and m.is_test) or
  (p_test_id is null and not m.is_test and exists(select 1 from public.mail_campaigns c where c.id=m.campaign_id and c.status='ACTIVE')
   and exists(select 1 from public.crm_leads l where l.id=m.lead_id and private.mbn_ws_eligible(l))))
 order by m.scheduled_at,m.created_at,m.id for update skip locked limit 1;
 if not found then return null;end if;
 update public.mail_messages set status='SENDING',attempt_id=gen_random_uuid(),claimed_at=now(),updated_at=now() where id=v_msg.id returning * into v_msg;
 return to_jsonb(v_msg)||jsonb_build_object('lead',(select jsonb_build_object('full_name',l.full_name,'email',l.email) from public.crm_leads l where l.id=v_msg.lead_id));
end;$$;
create function public.mbn_mail_finish(p_id uuid,p_attempt uuid,p_status text,p_provider_id text default null,p_error text default null)
returns boolean language plpgsql security invoker set search_path='' as $$
declare v_msg public.mail_messages;
begin
 if p_status not in ('ACCEPTED','FAILED','UNCERTAIN') or (p_status='ACCEPTED' and coalesce(length(p_provider_id),0)<1) then raise sqlstate 'PT400' using message='invalid_outcome';end if;
 update public.mail_messages set status=p_status,provider_message_id=p_provider_id,error_code=left(p_error,100),accepted_at=case when p_status='ACCEPTED' then now() end,updated_at=now()
 where id=p_id and attempt_id=p_attempt and status='SENDING' returning * into v_msg;
 if not found then return false;end if;
 if v_msg.outreach_id is not null then
  update public.crm_outreach_queue set status=case when p_status='ACCEPTED' then 'SENT' else 'FAILED' end,sent_at=case when p_status='ACCEPTED' then now() end where id=v_msg.outreach_id;
 end if;
 if p_status='ACCEPTED' and v_msg.is_test then update private.mbn_mail_settings set last_test_accepted_at=now() where id;end if;
 if v_msg.lead_id is not null then
  if p_status='ACCEPTED' then update public.crm_leads set status='INVITED',updated_at=now() where id=v_msg.lead_id and status='NEW';end if;
  insert into public.crm_lead_events(lead_id,event_type,event_metadata) values(v_msg.lead_id,'MAIL_'||p_status,jsonb_build_object('message_id',v_msg.id,'campaign_id',v_msg.campaign_id,'error_code',p_error));
 end if;
 return true;
end;$$;
revoke all on function public.mbn_mail_transport_settings(),public.mbn_mail_provider_checked(jsonb),public.mbn_mail_claim(uuid),public.mbn_mail_finish(uuid,uuid,text,text,text) from public,anon,authenticated;
grant execute on function public.mbn_mail_transport_settings(),public.mbn_mail_provider_checked(jsonb),public.mbn_mail_claim(uuid),public.mbn_mail_finish(uuid,uuid,text,text,text) to service_role;

create table private.mbn_runtime_secrets(name text primary key,vault_id uuid not null);
alter table private.mbn_runtime_secrets enable row level security;
revoke all on private.mbn_runtime_secrets from public,anon,authenticated,service_role;
-- Vault is present on the hosted project. Local SQL tests don't require the extension.
do $$declare v_id uuid; v_name text;begin
 if to_regprocedure('vault.create_secret(text,text,text)') is not null then
  foreach v_name in array array['link','worker'] loop
   execute 'select vault.create_secret($1,$2,$3)' into v_id
   using gen_random_uuid()::text||gen_random_uuid()::text||gen_random_uuid()::text,
    'mbn_'||v_name||'_'||gen_random_uuid()::text,'MBN internal capability signing / scheduler authentication';
   insert into private.mbn_runtime_secrets values(v_name,v_id);
  end loop;
 end if;
end;$$;
create function private.mbn_runtime_secret(p_name text) returns text
language plpgsql security definer set search_path='' as $$
declare v_value text;begin
 if p_name not in ('link','worker') then raise sqlstate 'PT403' using message='access_denied';end if;
 execute 'select d.decrypted_secret from vault.decrypted_secrets d join private.mbn_runtime_secrets r on r.vault_id=d.id where r.name=$1' into v_value using p_name;
 if length(coalesce(v_value,''))<80 then raise exception 'runtime_secret_unavailable';end if;
 return v_value;
end;$$;
revoke all on function private.mbn_runtime_secret(text) from public,anon,authenticated,service_role;
create function public.mbn_runtime_key(p_name text) returns text language sql security invoker set search_path='' as $$select private.mbn_runtime_secret(p_name);$$;
revoke all on function public.mbn_runtime_key(text) from public,anon,authenticated;
grant execute on function private.mbn_runtime_secret(text),public.mbn_runtime_key(text) to service_role;

create table private.mbn_admission_links(
 id uuid primary key default gen_random_uuid(),lead_id uuid not null unique references public.crm_leads(id),
 expires_at timestamptz not null default now()+interval '30 days',revoked_at timestamptz,created_at timestamptz not null default now()
);
alter table private.mbn_admission_links enable row level security;
revoke all on private.mbn_admission_links from public,anon,authenticated;
grant select,insert,update on private.mbn_admission_links to service_role;
create function public.mbn_mail_link(p_lead uuid) returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_link private.mbn_admission_links;begin
 insert into private.mbn_admission_links(lead_id) values(p_lead) on conflict(lead_id) do nothing;
 select * into v_link from private.mbn_admission_links where lead_id=p_lead;
 return jsonb_build_object('id',v_link.id,'expires_at',v_link.expires_at,'revoked',v_link.revoked_at is not null);
end;$$;
create function public.mbn_candidate_context(p_link uuid,p_action text default 'info') returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_link private.mbn_admission_links;v_lead public.crm_leads;v_school public.schools;
begin
 select * into v_link from private.mbn_admission_links where id=p_link for update;
 if not found or v_link.revoked_at is not null or (p_action<>'unsubscribe' and v_link.expires_at<now()) then raise sqlstate 'PT404' using message='link_unavailable';end if;
 select * into v_lead from public.crm_leads where id=v_link.lead_id for update;
 select * into v_school from public.schools where code=v_lead.school_code;
 if p_action='unsubscribe' then
   update public.crm_leads set consent_email=false,status='UNSUBSCRIBED',unsubscribed_at=coalesce(unsubscribed_at,now()),updated_at=now() where lower(email)=lower(v_lead.email) and not is_test;
  insert into public.crm_lead_events(lead_id,event_type) select v_lead.id,'UNSUBSCRIBED' where v_lead.unsubscribed_at is null;
 elsif not v_school.is_active or v_lead.is_test or v_lead.status='DISQUALIFIED' then raise sqlstate 'PT404' using message='link_unavailable';
 elsif p_action='engage' and v_lead.clicked_at is null and v_lead.submitted_at is null then
  update public.crm_leads set clicked_at=now(),status=case when unsubscribed_at is null then 'CLICKED' else status end,updated_at=now() where id=v_lead.id;
  insert into public.crm_lead_events(lead_id,event_type) values(v_lead.id,'ADMISSION_LINK_CONFIRMED');
 elsif p_action not in ('info','engage') then raise sqlstate 'PT400' using message='invalid_action';
 end if;
 -- email is used only inside the service, never returned by the public handler.
 return jsonb_build_object('id',v_link.id,'lead_id',v_lead.id,'email',v_lead.email,'school_code',v_school.code,'school_name',v_school.name,'slug',v_school.slug,'submitted',v_lead.submitted_at is not null,'expires_at',v_link.expires_at);
end;$$;
revoke all on function public.mbn_mail_link(uuid),public.mbn_candidate_context(uuid,text) from public,anon,authenticated;
grant execute on function public.mbn_mail_link(uuid),public.mbn_candidate_context(uuid,text) to service_role;

create table private.mbn_candidate_submissions(
 id uuid primary key default gen_random_uuid(),link_id uuid not null unique references private.mbn_admission_links(id),
 payload jsonb not null,details jsonb not null,manifest jsonb not null,fingerprint text not null check(fingerprint ~ '^[a-f0-9]{64}$'),
 application_id uuid references public.crm_applications(id),created_at timestamptz not null default now(),completed_at timestamptz
);
alter table private.mbn_candidate_submissions enable row level security;
revoke all on private.mbn_candidate_submissions from public,anon,authenticated;
grant select,insert,update on private.mbn_candidate_submissions to service_role;
alter table public.application_documents alter column submission_id drop not null;
alter table public.application_documents add column candidate_submission_id uuid references private.mbn_candidate_submissions(id);
alter table public.application_documents drop constraint application_documents_bucket_check;
alter table public.application_documents add constraint application_documents_bucket_check check(bucket in ('mbn-native-test','mbn-admissions'));
alter table public.application_documents add constraint application_documents_origin_check check((submission_id is not null and candidate_submission_id is null and bucket='mbn-native-test') or (submission_id is null and candidate_submission_id is not null and bucket='mbn-admissions'));
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values('mbn-admissions','mbn-admissions',false,5242880,array['application/pdf','image/png','image/jpeg']);
create policy admissions_bucket_server_only on storage.objects as restrictive for all to anon,authenticated using(bucket_id<>'mbn-admissions') with check(bucket_id<>'mbn-admissions');

create function public.mbn_candidate_prepare(p_link uuid,p_payload jsonb,p_details jsonb,p_manifest jsonb,p_fingerprint text)
returns jsonb language plpgsql security invoker set search_path='' as $$
declare v_ctx jsonb;v_existing private.mbn_candidate_submissions;v_id uuid;v_kind text;
begin
 v_ctx:=public.mbn_candidate_context(p_link,'info');
 if p_payload->>'reference_dossier'<>'MBNAPP-'||p_link::text or p_payload->>'school_code'<>v_ctx->>'school_code' or lower(p_payload->>'email')<>lower(v_ctx->>'email') then raise sqlstate 'PT422' using message='invitation_mismatch';end if;
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
create function public.mbn_candidate_complete(p_link uuid,p_submission uuid) returns jsonb
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
 v_result:=public.mbn_ingest_application(v_draft.payload||jsonb_build_object('event','application_submitted','source','DIRECT','is_test',false));
 select id into v_app from public.crm_applications where application_reference=v_draft.payload->>'reference_dossier';
 if v_app is null then raise exception 'application_commit_failed';end if;
 for v_doc in select value from jsonb_array_elements(v_draft.manifest) loop
  insert into public.application_documents(application_id,candidate_submission_id,bucket,kind,object_path,original_name,mime_type,byte_size,sha256)
  values(v_app,v_draft.id,'mbn-admissions',v_doc->>'kind',v_draft.id::text||'/'||(v_doc->>'kind')||'.'||(v_doc->>'extension'),v_doc->>'original_name',v_doc->>'mime_type',(v_doc->>'byte_size')::integer,v_doc->>'sha256');
 end loop;
 update private.mbn_candidate_submissions set application_id=v_app,completed_at=now() where id=v_draft.id;
 return jsonb_build_object('success',true,'reference',v_draft.payload->>'reference_dossier','application_id',v_app,'duplicated',false,'document_count',jsonb_array_length(v_draft.manifest));
end;$$;
revoke all on function public.mbn_candidate_prepare(uuid,jsonb,jsonb,jsonb,text),public.mbn_candidate_complete(uuid,uuid) from public,anon,authenticated;
grant execute on function public.mbn_candidate_prepare(uuid,jsonb,jsonb,jsonb,text),public.mbn_candidate_complete(uuid,uuid) to service_role;

create function public.mbn_workspace_document(p_actor uuid,p_session uuid,p_document uuid) returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_doc public.application_documents;v_app public.crm_applications;v_ctx jsonb;
begin
 v_ctx:=public.mbn_pin_context(p_actor,p_session,p_actor);
 select * into v_doc from public.application_documents where id=p_document;
 select * into v_app from public.crm_applications where id=v_doc.application_id;
 if v_app.id is null or not private.mbn_ws_can(p_actor,v_app.school_code,'review') or (v_app.is_test and not (v_ctx->>'admin')::boolean) then raise sqlstate 'PT404' using message='record_not_found';end if;
 return jsonb_build_object('bucket',v_doc.bucket,'object_path',v_doc.object_path,'sha256',v_doc.sha256,'original_name',v_doc.original_name);
end;$$;
revoke all on function public.mbn_workspace_document(uuid,uuid,uuid) from public,anon,authenticated;
grant execute on function public.mbn_workspace_document(uuid,uuid,uuid) to service_role;

create table private.mbn_ses_events(message_id text primary key,received_at timestamptz not null default now());
alter table private.mbn_ses_events enable row level security;
revoke all on private.mbn_ses_events from public,anon,authenticated;
grant select,insert on private.mbn_ses_events to service_role;
create function public.mbn_mail_event(p_envelope_id text,p_event jsonb) returns boolean
language plpgsql security invoker set search_path='' as $$
declare v_type text;v_msg public.mail_messages;v_id uuid;v_provider text;begin
 insert into private.mbn_ses_events(message_id) values(p_envelope_id) on conflict do nothing;
 if not found then return false;end if;
 v_type:=coalesce(p_event->>'eventType',p_event->>'notificationType');
 v_provider:=p_event->'mail'->>'messageId';
 begin v_id:=(p_event->'mail'->'tags'->'mbn_message_id'->>0)::uuid;exception when invalid_text_representation then v_id:=null;end;
 select * into v_msg from public.mail_messages where (id=v_id and (provider_message_id is null or provider_message_id=v_provider)) or (v_provider is not null and provider_message_id=v_provider) for update;
 if not found then return false;end if;
 update private.mbn_mail_settings set events_verified_at=now() where id;
 if v_msg.is_test and v_type in ('Send','Delivery') then update private.mbn_mail_settings set last_test_accepted_at=now() where id;end if;
 if v_type='Send' then
  update public.mail_messages set status=case when status in ('SENDING','UNCERTAIN') then 'ACCEPTED' else status end,provider_message_id=v_provider,accepted_at=coalesce(accepted_at,now()),updated_at=now() where id=v_msg.id;
 elsif v_type='Delivery' then
  update public.mail_messages set status=case when status in ('BOUNCED','COMPLAINED') then status else 'DELIVERED' end,provider_message_id=v_provider,accepted_at=coalesce(accepted_at,now()),delivered_at=now(),updated_at=now() where id=v_msg.id;
 elsif v_type='Complaint' or (v_type='Bounce' and p_event->'bounce'->>'bounceType'='Permanent') then
  update public.mail_messages set status=case when v_type='Complaint' then 'COMPLAINED' else 'BOUNCED' end,provider_message_id=v_provider,updated_at=now() where id=v_msg.id;
  update public.crm_leads set email_suppressed_at=now(),email_suppression_reason=upper(v_type),consent_email=false,updated_at=now() where lower(email)=lower(v_msg.recipient) and not is_test;
 end if;
 if v_type in ('Send','Delivery') then update public.crm_outreach_queue set status='SENT',sent_at=coalesce(sent_at,now()) where id=v_msg.outreach_id;end if;
 if v_msg.lead_id is not null then insert into public.crm_lead_events(lead_id,event_type,event_metadata) values(v_msg.lead_id,'SES_'||upper(v_type),jsonb_build_object('message_id',v_msg.id));end if;
 return true;
end;$$;
revoke all on function public.mbn_mail_event(text,jsonb) from public,anon,authenticated;
grant execute on function public.mbn_mail_event(text,jsonb) to service_role;

-- CRM business rows are read through the scoped API so document observations cannot
-- accidentally be read through a broad table grant by a community manager.
revoke select on public.crm_leads,public.crm_applications,public.crm_lead_events,public.crm_outreach_queue,
 public.mail_campaigns,public.mail_templates,public.mail_messages,public.admission_routing_rules from authenticated;
create function public.mbn_mail_send_authorized(p_id uuid,p_attempt uuid) returns boolean
language plpgsql security invoker set search_path='' as $$
declare v_msg public.mail_messages; v_ok boolean;
begin
 select * into v_msg from public.mail_messages where id=p_id and attempt_id=p_attempt and status='SENDING' for update;
 if not found then return false;end if;
 if v_msg.is_test then
  v_ok:=private.mbn_native_actor_allowed(v_msg.created_by);
 else
  v_ok:=exists(select 1 from public.crm_leads l join public.mail_campaigns c on c.id=v_msg.campaign_id
   join private.mbn_mail_settings s on s.id
   where l.id=v_msg.lead_id and private.mbn_ws_eligible(l) and c.status='ACTIVE' and s.enabled
   and private.mbn_ws_can(c.created_by,c.school_code,'campaign'));
 end if;
 if not v_ok then
  update public.mail_messages set status='CANCELED',updated_at=now(),error_code='authorization_changed' where id=v_msg.id;
  update public.crm_outreach_queue set status='CANCELED',canceled_at=now() where id=v_msg.outreach_id;
 end if;
 return v_ok;
end;$$;
revoke all on function public.mbn_mail_send_authorized(uuid,uuid) from public,anon,authenticated;
grant execute on function public.mbn_mail_send_authorized(uuid,uuid) to service_role;

create function private.mbn_mail_tick() returns void language plpgsql security definer set search_path='' as $$
begin
 if not exists(select 1 from private.mbn_mail_settings where id and enabled) then return;end if;
 -- Both endpoint and body are constants. The dedicated worker credential never enters cron.job.
 execute 'select net.http_post(url:=$1,headers:=$2,body:=$3,timeout_milliseconds:=55000)'
 using 'https://ppqeuluykiknuujfaoid.supabase.co/functions/v1/mbn-workspace',
  jsonb_build_object('Content-Type','application/json','x-mbn-worker',private.mbn_runtime_secret('worker')),
  '{}'::jsonb;
end;$$;
revoke all on function private.mbn_mail_tick() from public,anon,authenticated,service_role;
do $$begin
 if exists(select 1 from pg_available_extensions where name='pg_cron') and exists(select 1 from pg_available_extensions where name='pg_net') then
  execute 'create extension if not exists pg_cron';
  execute 'create extension if not exists pg_net with schema extensions';
  execute 'select cron.schedule(''mbn-mail-due'',''* * * * *'',''select private.mbn_mail_tick();'')';
 end if;
end;$$;
