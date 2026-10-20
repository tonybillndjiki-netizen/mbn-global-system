-- No default calendar and no enrollment of historical clicks.
create table private.mbn_followup_settings(
 school_code text primary key references public.schools(code),
 steps jsonb not null default '[]' check(jsonb_typeof(steps)='array'),
 enabled boolean not null default false,revision uuid not null default gen_random_uuid(),
 activated_at timestamptz,updated_by uuid not null references public.profiles(user_id),
 updated_at timestamptz not null default now()
);
alter table private.mbn_followup_settings enable row level security;
revoke all on private.mbn_followup_settings from public,anon,authenticated;
grant select,insert,update on private.mbn_followup_settings to service_role;
alter table public.crm_outreach_queue add column followup_revision uuid,add column expires_at timestamptz;

create function private.mbn_followup_eligible(p_lead public.crm_leads) returns boolean
language sql stable security invoker set search_path='' as $$
 select not p_lead.is_test and p_lead.source='META_LEAD' and p_lead.consent_email
  and p_lead.status in ('CLICKED','STARTED') and p_lead.clicked_at is not null
  and p_lead.submitted_at is null and p_lead.unsubscribed_at is null and p_lead.email_suppressed_at is null
  and p_lead.email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'
  and exists(select 1 from public.schools s where s.code=p_lead.school_code and s.is_active)
  and exists(select 1 from private.mbn_admission_links k where k.lead_id=p_lead.id and k.revoked_at is null and k.expires_at>now())
  and not exists(select 1 from public.crm_applications a where a.lead_id=p_lead.id and not a.is_test);
$$;

create function private.mbn_enroll_followups(p_lead public.crm_leads) returns void
language plpgsql security invoker set search_path='' as $$
declare v_settings private.mbn_followup_settings;v_campaign public.mail_campaigns;v_expiry timestamptz;v_count integer;begin
 if not private.mbn_followup_eligible(p_lead) then return;end if;
 select * into v_settings from private.mbn_followup_settings where school_code=p_lead.school_code and enabled and activated_at<=p_lead.clicked_at;
 if not found or not private.mbn_ws_can(v_settings.updated_by,p_lead.school_code,'campaign') then return;end if;
 if exists(select 1 from public.crm_outreach_queue where lead_id=p_lead.id and sequence_type='CLICKED_NOT_SUBMITTED') then return;end if;
 -- Continue the campaign that invited this prospect, including its pause control.
 select c.* into v_campaign from public.mail_campaigns c join public.crm_outreach_queue q on q.campaign_id=c.id
  where q.lead_id=p_lead.id and q.sequence_type='META_UNCLICKED' and c.school_code=p_lead.school_code and c.status in ('ACTIVE','PAUSED')
  and private.mbn_ws_can(c.created_by,c.school_code,'campaign') order by q.created_at,q.attempt_number,c.id limit 1;
 if not found then return;end if;
 select expires_at into v_expiry from private.mbn_admission_links where lead_id=p_lead.id and revoked_at is null;
 with enrolled as (
  insert into public.crm_outreach_queue(lead_id,sequence_type,attempt_number,scheduled_at,status,campaign_id,followup_revision,expires_at)
  select p_lead.id,'CLICKED_NOT_SUBMITTED',n::smallint,p_lead.clicked_at+make_interval(hours=>(step->>'days')::integer*24),
   'PENDING',v_campaign.id,v_settings.revision,least(v_expiry,p_lead.clicked_at+make_interval(hours=>((step->>'days')::integer+1)*24))
  from jsonb_array_elements(v_settings.steps) with ordinality as x(step,n)
  where p_lead.clicked_at+make_interval(hours=>(step->>'days')::integer*24)<v_expiry
  on conflict(lead_id,sequence_type,attempt_number) do nothing returning *
 ) insert into public.mail_messages(school_code,lead_id,campaign_id,outreach_id,recipient,subject,body,scheduled_at,created_by)
  select p_lead.school_code,p_lead.id,v_campaign.id,q.id,p_lead.email,
   v_settings.steps->(q.attempt_number-1)->>'subject',v_settings.steps->(q.attempt_number-1)->>'body',q.scheduled_at,v_settings.updated_by from enrolled q;
 get diagnostics v_count=row_count;
 if v_count>0 then insert into public.crm_lead_events(lead_id,event_type,event_metadata)
  values(p_lead.id,'FOLLOWUPS_PLANNED',jsonb_build_object('campaign_id',v_campaign.id,'revision',v_settings.revision,'messages',v_count,'clicked_at',p_lead.clicked_at));end if;
end;$$;

-- Clicks stop the invitation sequence only. Withdrawal/submission stop both.
create or replace function private.mbn_ws_stop_outreach() returns trigger
language plpgsql security invoker set search_path='' as $$begin
 if new.submitted_at is not null and old.submitted_at is null then
  -- The existing ingestion RPC cancels queues and reports its exact count.
  update public.mail_messages set status='CANCELED',updated_at=now(),error_code='application_submitted' where lead_id=new.id and status='QUEUED';return new;
 end if;
 if new.is_test or new.source<>'META_LEAD' or new.submitted_at is not null or new.unsubscribed_at is not null
  or new.email_suppressed_at is not null or not new.consent_email or new.status in ('DISQUALIFIED','UNSUBSCRIBED','SUBMITTED') then
  update public.crm_outreach_queue set status='CANCELED',canceled_at=now() where lead_id=new.id and status in ('PENDING','FAILED');
  update public.mail_messages set status='CANCELED',updated_at=now(),error_code='recipient_no_longer_eligible' where lead_id=new.id and status='QUEUED';
 elsif new.clicked_at is not null or new.status in ('CLICKED','STARTED') then
  update public.crm_outreach_queue set status='CANCELED',canceled_at=now() where lead_id=new.id and sequence_type='META_UNCLICKED' and status in ('PENDING','FAILED');
  update public.mail_messages m set status='CANCELED',updated_at=now(),error_code='link_confirmed'
   where m.lead_id=new.id and m.status='QUEUED' and exists(select 1 from public.crm_outreach_queue q where q.id=m.outreach_id and q.sequence_type='META_UNCLICKED');
  if old.clicked_at is null and new.clicked_at is not null then perform private.mbn_enroll_followups(new);end if;
 end if;return new;
end;$$;

create function public.mbn_followup_action(p_actor uuid,p_session uuid,p_action text,p_data jsonb default '{}') returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_ctx jsonb;v_school text;v_settings private.mbn_followup_settings;v_step jsonb;v_days integer;v_previous integer:=0;
 v_uuid text:='^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$';v_enabled boolean;begin
 v_ctx:=public.mbn_pin_context(p_actor,p_session,p_actor);
 if jsonb_typeof(p_data) is distinct from 'object' then raise sqlstate 'PT400' using message='invalid_request';end if;
 if p_action='followups_context' then
  return jsonb_build_object('schools',(select coalesce(jsonb_agg(jsonb_build_object(
   'school_code',s.code,'school_name',s.name,'is_active',s.is_active,'can_edit',private.mbn_ws_can(p_actor,s.code,'campaign'),
   'steps',coalesce(f.steps,'[]'),'enabled',coalesce(f.enabled,false),'revision',f.revision,'activated_at',f.activated_at,
   'queued',(select count(*) from public.mail_messages m join public.crm_outreach_queue q on q.id=m.outreach_id where m.school_code=s.code and q.sequence_type='CLICKED_NOT_SUBMITTED' and m.status='QUEUED'),
   'accepted',(select count(*) from public.mail_messages m join public.crm_outreach_queue q on q.id=m.outreach_id where m.school_code=s.code and q.sequence_type='CLICKED_NOT_SUBMITTED' and m.status in ('ACCEPTED','DELIVERED')),
   'canceled',(select count(*) from public.mail_messages m join public.crm_outreach_queue q on q.id=m.outreach_id where m.school_code=s.code and q.sequence_type='CLICKED_NOT_SUBMITTED' and m.status='CANCELED')
   ) order by s.name),'[]') from public.schools s left join private.mbn_followup_settings f on f.school_code=s.code where private.mbn_ws_can(p_actor,s.code)));
 end if;
 if p_action is null or p_action not in ('followup_save','followup_toggle') then raise sqlstate 'PT400' using message='unknown_action';end if;
 v_school:=p_data->>'school_code';
 if not private.mbn_ws_can(p_actor,v_school,'campaign') then raise sqlstate 'PT403' using message='access_denied';end if;
 if not exists(select 1 from public.schools where code=v_school and is_active) then raise sqlstate 'PT422' using message='school_inactive';end if;
 if not p_data?'expected_revision' or (p_data->>'expected_revision' is not null and p_data->>'expected_revision' !~ v_uuid) then raise sqlstate 'PT400' using message='invalid_request';end if;
 perform pg_advisory_xact_lock(72519816);
 select * into v_settings from private.mbn_followup_settings where school_code=v_school for update;
 if v_settings.revision is distinct from (p_data->>'expected_revision')::uuid then raise sqlstate 'PT409' using message='followup_changed';end if;
 if p_action='followup_save' then
  if exists(select 1 from jsonb_object_keys(p_data) k where k not in ('school_code','expected_revision','steps')) or jsonb_typeof(p_data->'steps') is distinct from 'array' then raise sqlstate 'PT422' using message='invalid_followup';end if;
  if jsonb_array_length(p_data->'steps') not between 1 and 3 then raise sqlstate 'PT422' using message='invalid_followup';end if;
  for v_step in select value from jsonb_array_elements(p_data->'steps') loop
   if jsonb_typeof(v_step) is distinct from 'object' then raise sqlstate 'PT422' using message='invalid_followup';end if;
   if exists(select 1 from jsonb_object_keys(v_step) k where k not in ('days','subject','body'))
    or jsonb_typeof(v_step->'days') is distinct from 'number' or coalesce(v_step->>'days','') !~ '^[0-9]{1,2}$'
    or jsonb_typeof(v_step->'subject') is distinct from 'string' or jsonb_typeof(v_step->'body') is distinct from 'string'
    or length(btrim(coalesce(v_step->>'subject',''))) not between 1 and 200 or v_step->>'subject' ~ E'[\r\n]'
    or length(btrim(coalesce(v_step->>'body',''))) not between 1 and 20000 then raise sqlstate 'PT422' using message='invalid_followup';end if;
   v_days:=(v_step->>'days')::integer;
   if v_days not between 1 and 21 or v_days<=v_previous then raise sqlstate 'PT422' using message='invalid_followup';end if;v_previous:=v_days;
  end loop;
  insert into private.mbn_followup_settings(school_code,steps,updated_by) values(v_school,p_data->'steps',p_actor)
   on conflict(school_code) do update set steps=excluded.steps,enabled=false,revision=gen_random_uuid(),activated_at=null,updated_by=p_actor,updated_at=now() returning * into v_settings;
 else
  if exists(select 1 from jsonb_object_keys(p_data) k where k not in ('school_code','expected_revision','enabled')) or jsonb_typeof(p_data->'enabled') is distinct from 'boolean'
   or v_settings.school_code is null or jsonb_array_length(v_settings.steps)=0 then raise sqlstate 'PT422' using message='invalid_followup';end if;
  v_enabled:=(p_data->>'enabled')::boolean;
  if v_settings.enabled=v_enabled then return to_jsonb(v_settings);end if;
  update private.mbn_followup_settings set enabled=v_enabled,revision=gen_random_uuid(),activated_at=case when v_enabled then now() end,updated_by=p_actor,updated_at=now() where school_code=v_school returning * into v_settings;
 end if;
 -- Editing or disabling is an explicit stop. A later activation covers future clicks.
 update public.mail_messages m set status='CANCELED',updated_at=now(),error_code='followup_configuration_changed'
  where m.school_code=v_school and m.status='QUEUED' and exists(select 1 from public.crm_outreach_queue q where q.id=m.outreach_id and q.sequence_type='CLICKED_NOT_SUBMITTED');
 update public.crm_outreach_queue q set status='CANCELED',canceled_at=now() where q.sequence_type='CLICKED_NOT_SUBMITTED' and q.status in ('PENDING','FAILED')
  and exists(select 1 from public.crm_leads l where l.id=q.lead_id and l.school_code=v_school);
 return to_jsonb(v_settings);
end;$$;

create function private.mbn_outreach_eligible(p_message public.mail_messages) returns boolean
language sql stable security invoker set search_path='' as $$
 select coalesce((select case when q.sequence_type='CLICKED_NOT_SUBMITTED' then
   private.mbn_followup_eligible(l) and q.status='PENDING' and q.expires_at>now()
   and exists(select 1 from private.mbn_followup_settings f where f.school_code=l.school_code and f.enabled and f.revision=q.followup_revision
    and private.mbn_ws_can(f.updated_by,l.school_code,'campaign'))
  else private.mbn_ws_eligible(l) end
  from public.crm_leads l left join public.crm_outreach_queue q on q.id=p_message.outreach_id and q.lead_id=l.id
  where l.id=p_message.lead_id and l.school_code=p_message.school_code and l.email=p_message.recipient),false);
$$;

create or replace function public.mbn_mail_profile_claim(p_group text,p_test_id uuid default null) returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_msg public.mail_messages;v_group private.mbn_mail_sender_groups;v_route private.mbn_school_mail_routes;v_limit integer;begin
 perform pg_advisory_xact_lock(72519816);
 select * into v_group from private.mbn_mail_sender_groups where code=p_group for update;
 if not found or not private.mbn_mail_profile_ready(p_group,p_test_id is not null) then return null;end if;
 select daily_limit into v_limit from private.mbn_mail_settings where id;
 update public.mail_messages set status='UNCERTAIN',error_code='attempt_expired_review_required',updated_at=now() where status='SENDING' and claimed_at<now()-interval '5 minutes';
 if (select count(*) from public.mail_messages where accepted_at>=date_trunc('day',now()) or (status in ('SENDING','UNCERTAIN') and claimed_at>=date_trunc('day',now())))>=v_limit then return null;end if;
 update public.mail_messages m set status='CANCELED',error_code='recipient_no_longer_eligible',updated_at=now()
  where m.status='QUEUED' and not m.is_test and m.lead_id is not null and not private.mbn_outreach_eligible(m);
 update public.crm_outreach_queue q set status='CANCELED',canceled_at=now() where q.status='PENDING' and q.sequence_type='CLICKED_NOT_SUBMITTED'
  and exists(select 1 from public.mail_messages m where m.outreach_id=q.id and m.status='CANCELED');
 select m.* into v_msg from public.mail_messages m join private.mbn_school_mail_routes r on r.school_code=m.school_code join public.schools s on s.code=m.school_code
  where m.status='QUEUED' and m.scheduled_at<=now() and s.is_active and r.sender_group=p_group and r.admissions_email<>''
   and ((p_test_id is not null and m.id=p_test_id and m.is_test and m.sender_group=p_group) or
    (p_test_id is null and not m.is_test and exists(select 1 from public.mail_campaigns c where c.id=m.campaign_id and c.status='ACTIVE' and c.school_code=m.school_code)
     and private.mbn_outreach_eligible(m)))
  order by m.scheduled_at,m.created_at,m.id for update of m skip locked limit 1;
 if not found then return null;end if;
 select * into v_route from private.mbn_school_mail_routes where school_code=v_msg.school_code for share;
 update public.mail_messages set status='SENDING',attempt_id=gen_random_uuid(),claimed_at=now(),updated_at=now(),
  sender_group=p_group,sender_identity=v_group.from_email,sender_revision=v_group.revision,credential_fingerprint=v_group.credential_fingerprint,
  mail_route_revision=v_route.revision,service_contact_email=v_route.admissions_email where id=v_msg.id returning * into v_msg;
 return to_jsonb(v_msg)||jsonb_build_object('sender',public.mbn_mail_profile_settings(p_group),
  'lead',(select jsonb_build_object('full_name',l.full_name,'email',l.email) from public.crm_leads l where l.id=v_msg.lead_id));
end;$$;

create or replace function public.mbn_mail_send_authorized(p_id uuid,p_attempt uuid) returns boolean
language plpgsql security invoker set search_path='' as $$
declare v_msg public.mail_messages;v_ok boolean;begin
 select * into v_msg from public.mail_messages where id=p_id and attempt_id=p_attempt and status='SENDING' for update;
 if not found then return false;end if;
 if v_msg.is_test then v_ok:=private.mbn_native_actor_allowed(v_msg.created_by);
 else
  v_ok:=private.mbn_outreach_eligible(v_msg) and exists(select 1 from public.mail_campaigns c join private.mbn_mail_settings s on s.id
   where c.id=v_msg.campaign_id and c.school_code=v_msg.school_code and c.status='ACTIVE' and s.enabled and private.mbn_ws_can(c.created_by,c.school_code,'campaign'));
 end if;
 if not v_ok then
  update public.mail_messages set status='CANCELED',updated_at=now(),error_code='authorization_changed' where id=v_msg.id;
  update public.crm_outreach_queue set status='CANCELED',canceled_at=now() where id=v_msg.outreach_id;
 end if;return v_ok;
end;$$;

-- The retired single-sender worker must not cancel this new sequence.
-- Current HTTP/cron dispatch uses mbn_mail_profile_claim exclusively.
create or replace function public.mbn_mail_claim(p_test_id uuid default null)
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
  where m.status='QUEUED' and not m.is_test and m.lead_id is not null
  and not exists(select 1 from public.crm_outreach_queue q where q.id=m.outreach_id and q.sequence_type='CLICKED_NOT_SUBMITTED')
  and not exists(select 1 from public.crm_leads l where l.id=m.lead_id and private.mbn_ws_eligible(l));
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

revoke all on function private.mbn_followup_eligible(public.crm_leads),private.mbn_enroll_followups(public.crm_leads),private.mbn_outreach_eligible(public.mail_messages),public.mbn_followup_action(uuid,uuid,text,jsonb) from public,anon,authenticated;
grant execute on function private.mbn_followup_eligible(public.crm_leads),private.mbn_enroll_followups(public.crm_leads),private.mbn_outreach_eligible(public.mail_messages),public.mbn_followup_action(uuid,uuid,text,jsonb) to service_role;
