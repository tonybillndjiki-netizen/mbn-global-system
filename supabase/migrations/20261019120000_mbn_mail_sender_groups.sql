-- Two sender identities share one Brevo account and one daily allowance.
-- No domain, service mailbox or school affiliation is inferred by this migration.
create table private.mbn_mail_sender_groups (
 code text primary key check(code in ('MBN_GLOBAL','CAMPUS_INNOVATION_MLV')),
 from_name text not null check(length(from_name) between 1 and 100 and from_name !~ E'[\r\n]'),
 from_email text not null default '' check(from_email='' or (length(from_email)<=254 and from_email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$')),
 revision uuid not null default gen_random_uuid(),
 enabled boolean not null default false,
 sender_verified boolean not null default false,
 production_access boolean not null default false,
 account_sending_enabled boolean not null default false,
 provider_checked_at timestamptz,
 provider_error text,
 credential_fingerprint text check(credential_fingerprint ~ '^[a-f0-9]{64}$'),
 events_verified_at timestamptz,
 updated_at timestamptz not null default now()
);
insert into private.mbn_mail_sender_groups(code,from_name) values
 ('MBN_GLOBAL','MBN Global Éducation'),('CAMPUS_INNOVATION_MLV','Campus Innovation Marne-la-Vallée');
create unique index mbn_mail_distinct_senders on private.mbn_mail_sender_groups(lower(from_email)) where from_email<>'';
create table private.mbn_school_mail_routes (
 school_code text primary key references public.schools(code),
 sender_group text references private.mbn_mail_sender_groups(code),
 admissions_email text not null default '' check(admissions_email='' or (length(admissions_email)<=254 and admissions_email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$')),
 revision uuid not null default gen_random_uuid(),
 updated_at timestamptz not null default now()
);
insert into private.mbn_school_mail_routes(school_code) select code from public.schools;
alter table private.mbn_mail_sender_groups enable row level security;
alter table private.mbn_school_mail_routes enable row level security;
revoke all on private.mbn_mail_sender_groups,private.mbn_school_mail_routes from public,anon,authenticated;
grant select,update on private.mbn_mail_sender_groups to service_role;
grant select,insert,update on private.mbn_school_mail_routes to service_role;
alter table public.mail_messages add column sender_group text references private.mbn_mail_sender_groups(code),
 add column sender_revision uuid,add column mail_route_revision uuid,add column service_contact_email text;
update private.mbn_mail_settings set enabled=false where id;

-- The scheduler is awake whenever at least one group is enabled. The worker
-- still checks each group's proof and school route before taking a send lease.
create function private.mbn_mail_refresh_enabled() returns trigger
language plpgsql security invoker set search_path='' as $$begin
 update private.mbn_mail_settings set enabled=exists(select 1 from private.mbn_mail_sender_groups where enabled) where id;
 return null;
end;$$;
create trigger mbn_mail_group_enabled after update on private.mbn_mail_sender_groups
 for each statement execute function private.mbn_mail_refresh_enabled();
create function private.mbn_mail_reset_group_credentials() returns trigger
language plpgsql security invoker set search_path='' as $$begin
 if old.credential_fingerprint is distinct from new.credential_fingerprint then
  update private.mbn_mail_sender_groups set enabled=false,sender_verified=false,production_access=false,account_sending_enabled=false,
   provider_checked_at=null,credential_fingerprint=null,events_verified_at=null,revision=gen_random_uuid(),updated_at=now();
 end if;
 return null;
end;$$;
create trigger mbn_mail_group_credentials after update of credential_fingerprint on private.mbn_mail_settings
 for each row execute function private.mbn_mail_reset_group_credentials();

create function public.mbn_mail_profile_settings(p_group text default null,p_school text default null) returns jsonb
language plpgsql stable security invoker set search_path='' as $$
declare v_group text:=p_group;v_result jsonb;begin
 if p_school is not null then
  select sender_group into v_group from private.mbn_school_mail_routes where school_code=p_school;
  if v_group is null then raise sqlstate 'PT422' using message='mail_route_missing';end if;
 end if;
 select to_jsonb(g)||jsonb_build_object('reply_to',g.from_email,'daily_limit',s.daily_limit,'brevo_webhook_id',s.brevo_webhook_id)
 into v_result from private.mbn_mail_sender_groups g cross join private.mbn_mail_settings s where s.id and g.code=v_group;
 if v_result is null then raise sqlstate 'PT422' using message='invalid_sender_group';end if;
 return v_result;
end;$$;
create function private.mbn_mail_profile_ready(p_group text,p_test boolean default false) returns boolean
language sql stable security invoker set search_path='' as $$
 select exists(select 1 from private.mbn_mail_sender_groups g cross join private.mbn_mail_settings s
  where s.id and g.code=p_group and g.from_email<>'' and g.sender_verified and g.production_access and g.account_sending_enabled
   and g.provider_checked_at>=now()-interval '1 hour' and s.brevo_webhook_id is not null
   and g.credential_fingerprint=s.credential_fingerprint
   and (p_test or (g.enabled and g.events_verified_at is not null)));
$$;
create function public.mbn_mail_profile_checked(p_group text,p_revision uuid,p_result jsonb) returns jsonb
language plpgsql security invoker set search_path='' as $$begin
 perform pg_advisory_xact_lock(72519816);
 perform 1 from private.mbn_mail_sender_groups where code=p_group and revision=p_revision for update;
 if not found then raise sqlstate 'PT409' using message='mail_configuration_changed';end if;
 -- The shared account helper detects key rotation; its trigger invalidates
 -- proofs for both groups before this particular sender is marked checked.
 perform public.mbn_mail_provider_checked(p_result);
 update private.mbn_mail_sender_groups set sender_verified=coalesce((p_result->>'sender_verified')::boolean,false),
  production_access=coalesce((p_result->>'production_access')::boolean,false),account_sending_enabled=coalesce((p_result->>'account_sending_enabled')::boolean,false),
  provider_checked_at=now(),provider_error=p_result->>'error',credential_fingerprint=p_result->>'credential_fingerprint',
  enabled=enabled and coalesce((p_result->>'sender_verified')::boolean,false) and coalesce((p_result->>'production_access')::boolean,false)
   and coalesce((p_result->>'account_sending_enabled')::boolean,false),updated_at=now() where code=p_group;
 return public.mbn_mail_profile_settings(p_group);
end;$$;
create or replace function public.mbn_brevo_webhook_configured(p_id bigint) returns void
language plpgsql security invoker set search_path='' as $$begin
 perform pg_advisory_xact_lock(72519816);
 if p_id is null or p_id<=0 then raise sqlstate 'PT400' using message='invalid_webhook';end if;
 update private.mbn_mail_settings set brevo_webhook_id=p_id,events_verified_at=null,last_test_accepted_at=null,enabled=false,updated_at=now() where id;
 update private.mbn_mail_sender_groups set enabled=false,events_verified_at=null,revision=gen_random_uuid(),updated_at=now();
end;$$;

alter function public.mbn_workspace_action(uuid,uuid,text,jsonb) rename to mbn_workspace_action_single_sender;
create function public.mbn_workspace_action(p_actor uuid,p_session uuid,p_action text,p_data jsonb default '{}') returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_ctx jsonb;v_group private.mbn_mail_sender_groups;v_school text;v_email text;v_id uuid;v_changed boolean;begin
 if p_action not in ('mail_config_get','mail_group_save','mail_route_save','mail_limit_save','mail_test_prepare') then
  return public.mbn_workspace_action_single_sender(p_actor,p_session,p_action,p_data);
 end if;
 v_ctx:=public.mbn_pin_context(p_actor,p_session,p_actor);
 if not coalesce((v_ctx->>'admin')::boolean,false) then raise sqlstate 'PT403' using message='access_denied';end if;
 if jsonb_typeof(p_data) is distinct from 'object' then raise sqlstate 'PT400' using message='invalid_request';end if;
 if p_action<>'mail_config_get' then perform pg_advisory_xact_lock(72519816);end if;
 if p_action='mail_config_get' then
  return jsonb_build_object('daily_limit',(select daily_limit from private.mbn_mail_settings where id),
   'brevo_webhook_id',(select brevo_webhook_id from private.mbn_mail_settings where id),
   'groups',(select jsonb_agg(to_jsonb(g)-'credential_fingerprint' order by g.code) from private.mbn_mail_sender_groups g),
   'schools',(select coalesce(jsonb_agg(jsonb_build_object('school_code',s.code,'school_name',s.name,'is_active',s.is_active,
    'sender_group',r.sender_group,'admissions_email',coalesce(r.admissions_email,'')) order by s.code),'[]')
    from public.schools s left join private.mbn_school_mail_routes r on r.school_code=s.code));
 elsif p_action='mail_limit_save' then
  if exists(select 1 from jsonb_object_keys(p_data) k where k<>'daily_limit') or coalesce(p_data->>'daily_limit','') !~ '^[0-9]{1,5}$'
   or (p_data->>'daily_limit')::integer not between 1 and 10000 then raise sqlstate 'PT422' using message='invalid_sender';end if;
  update private.mbn_mail_settings set daily_limit=(p_data->>'daily_limit')::integer,updated_at=now() where id;
 elsif p_action='mail_route_save' then
  if exists(select 1 from jsonb_object_keys(p_data) k where k not in ('school_code','sender_group','admissions_email'))
   or not exists(select 1 from public.schools where code=p_data->>'school_code')
   or (nullif(p_data->>'sender_group','') is not null and not exists(select 1 from private.mbn_mail_sender_groups where code=p_data->>'sender_group'))
   or (coalesce(p_data->>'admissions_email','')<>'' and (length(p_data->>'admissions_email')>254 or p_data->>'admissions_email' !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'))
   then raise sqlstate 'PT422' using message='invalid_mail_route';end if;
  insert into private.mbn_school_mail_routes(school_code,sender_group,admissions_email) values(p_data->>'school_code',nullif(p_data->>'sender_group',''),lower(coalesce(p_data->>'admissions_email','')))
   on conflict(school_code) do update set sender_group=excluded.sender_group,admissions_email=excluded.admissions_email,revision=gen_random_uuid(),updated_at=now()
   where mbn_school_mail_routes.sender_group is distinct from excluded.sender_group or mbn_school_mail_routes.admissions_email is distinct from excluded.admissions_email;
 else
  select * into v_group from private.mbn_mail_sender_groups where code=p_data->>'sender_group' for update;
  if not found then raise sqlstate 'PT422' using message='invalid_sender_group';end if;
  if p_action='mail_group_save' then
   if exists(select 1 from jsonb_object_keys(p_data) k where k not in ('sender_group','from_name','from_email','enabled'))
    or length(coalesce(p_data->>'from_name','')) not between 1 and 100 or p_data->>'from_name' ~ E'[\r\n]'
    or coalesce(p_data->>'from_email','') !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' or length(p_data->>'from_email')>254
    or jsonb_typeof(p_data->'enabled') is distinct from 'boolean' then raise sqlstate 'PT422' using message='invalid_sender';end if;
   if exists(select 1 from private.mbn_mail_sender_groups where code<>v_group.code and from_email=lower(p_data->>'from_email')) then raise sqlstate 'PT422' using message='sender_email_already_used';end if;
   v_changed:=v_group.from_email is distinct from lower(p_data->>'from_email') or v_group.from_name is distinct from p_data->>'from_name';
   if (p_data->>'enabled')::boolean and (v_changed or not private.mbn_mail_profile_ready(v_group.code,true) or v_group.events_verified_at is null)
    then raise sqlstate 'PT422' using message='sender_not_ready';end if;
   update private.mbn_mail_sender_groups set from_name=p_data->>'from_name',from_email=lower(p_data->>'from_email'),enabled=(p_data->>'enabled')::boolean,
    revision=case when v_changed then gen_random_uuid() else revision end,sender_verified=sender_verified and not v_changed,
    provider_checked_at=case when v_changed then null else provider_checked_at end,events_verified_at=case when v_changed then null else events_verified_at end,updated_at=now() where code=v_group.code;
  else
   if exists(select 1 from jsonb_object_keys(p_data) k where k<>'sender_group') then raise sqlstate 'PT400' using message='invalid_request';end if;
   if not private.mbn_mail_profile_ready(v_group.code,true) then raise sqlstate 'PT422' using message='sender_not_ready';end if;
   select r.school_code into v_school from private.mbn_school_mail_routes r join public.schools s on s.code=r.school_code
    where s.is_active and r.sender_group=v_group.code and r.admissions_email<>'' order by r.school_code limit 1;
   if v_school is null then raise sqlstate 'PT422' using message='mail_route_missing';end if;
   select lower(email) into v_email from auth.users where id=p_actor and email_confirmed_at is not null;
   if coalesce(v_email,'') !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' then raise sqlstate 'PT422' using message='test_recipient_missing';end if;
   if exists(select 1 from public.mail_messages where created_by=p_actor and is_test and sender_group=v_group.code and created_at>now()-interval '1 minute') then raise sqlstate 'PT429' using message='test_rate_limited';end if;
   insert into public.mail_messages(school_code,recipient,subject,body,is_test,created_by,sender_group)
    values(v_school,v_email,'MBN Mail — test de connexion','Bonjour, ce message permet de vérifier votre expéditeur et son suivi de livraison.',true,p_actor,v_group.code) returning id into v_id;
   return jsonb_build_object('id',v_id);
  end if;
 end if;
 return jsonb_build_object('success',true);
end;$$;

create function public.mbn_mail_profile_claim(p_group text,p_test_id uuid default null) returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_msg public.mail_messages;v_group private.mbn_mail_sender_groups;v_route private.mbn_school_mail_routes;v_limit integer;begin
 perform pg_advisory_xact_lock(72519816);
 select * into v_group from private.mbn_mail_sender_groups where code=p_group for update;
 if not found or not private.mbn_mail_profile_ready(p_group,p_test_id is not null) then return null;end if;
 select daily_limit into v_limit from private.mbn_mail_settings where id;
 update public.mail_messages set status='UNCERTAIN',error_code='attempt_expired_review_required',updated_at=now() where status='SENDING' and claimed_at<now()-interval '5 minutes';
 if (select count(*) from public.mail_messages where accepted_at>=date_trunc('day',now()) or (status in ('SENDING','UNCERTAIN') and claimed_at>=date_trunc('day',now())))>=v_limit then return null;end if;
 update public.mail_messages m set status='CANCELED',error_code='recipient_no_longer_eligible',updated_at=now()
  where m.status='QUEUED' and not m.is_test and m.lead_id is not null and not exists(select 1 from public.crm_leads l where l.id=m.lead_id and private.mbn_ws_eligible(l));
 select m.* into v_msg from public.mail_messages m join private.mbn_school_mail_routes r on r.school_code=m.school_code join public.schools s on s.code=m.school_code
  where m.status='QUEUED' and m.scheduled_at<=now() and s.is_active and r.sender_group=p_group and r.admissions_email<>''
   and ((p_test_id is not null and m.id=p_test_id and m.is_test and m.sender_group=p_group) or
    (p_test_id is null and not m.is_test and exists(select 1 from public.mail_campaigns c where c.id=m.campaign_id and c.status='ACTIVE')
     and exists(select 1 from public.crm_leads l where l.id=m.lead_id and private.mbn_ws_eligible(l))))
  order by m.scheduled_at,m.created_at,m.id for update of m skip locked limit 1;
 if not found then return null;end if;
 select * into v_route from private.mbn_school_mail_routes where school_code=v_msg.school_code for share;
 update public.mail_messages set status='SENDING',attempt_id=gen_random_uuid(),claimed_at=now(),updated_at=now(),
  sender_group=p_group,sender_identity=v_group.from_email,sender_revision=v_group.revision,credential_fingerprint=v_group.credential_fingerprint,
  mail_route_revision=v_route.revision,service_contact_email=v_route.admissions_email where id=v_msg.id returning * into v_msg;
 return to_jsonb(v_msg)||jsonb_build_object('sender',public.mbn_mail_profile_settings(p_group),
  'lead',(select jsonb_build_object('full_name',l.full_name,'email',l.email) from public.crm_leads l where l.id=v_msg.lead_id));
end;$$;
create function private.mbn_mail_message_current(p_message public.mail_messages) returns boolean
language sql stable security invoker set search_path='' as $$
 select exists(select 1 from private.mbn_mail_sender_groups g join private.mbn_school_mail_routes r on r.sender_group=g.code
  join public.schools s on s.code=r.school_code
  where g.code=p_message.sender_group and s.is_active and r.school_code=p_message.school_code and r.revision=p_message.mail_route_revision
   and r.admissions_email<>'' and r.admissions_email=p_message.service_contact_email and g.from_email=p_message.sender_identity
   and g.revision=p_message.sender_revision and g.credential_fingerprint=p_message.credential_fingerprint
   and private.mbn_mail_profile_ready(g.code,p_message.is_test));
$$;
create function public.mbn_mail_profile_authorized(p_id uuid,p_attempt uuid) returns boolean
language plpgsql security invoker set search_path='' as $$
declare v_msg public.mail_messages;begin
 select * into v_msg from public.mail_messages where id=p_id and attempt_id=p_attempt and status='SENDING' for update;
 if not found then return false;end if;
 if not private.mbn_mail_message_current(v_msg) then
  update public.mail_messages set status='CANCELED',error_code='mail_configuration_changed',updated_at=now() where id=p_id;
  update public.crm_outreach_queue set status='CANCELED',canceled_at=now() where id=v_msg.outreach_id;
  return false;
 end if;
 return public.mbn_mail_send_authorized(p_id,p_attempt);
end;$$;

-- The existing letter validation, access checks and PDF approval remain in
-- charge of the business decision; this wrapper binds its lease to a sender.
create function public.mbn_letter_profile_action(p_actor uuid,p_session uuid,p_action text,p_data jsonb) returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_row jsonb;v_group private.mbn_mail_sender_groups;v_route private.mbn_school_mail_routes;v_msg public.mail_messages;begin
 if p_action not in ('claim','authorized') then raise sqlstate 'PT400' using message='unknown_action';end if;
 perform pg_advisory_xact_lock(72519816);
 v_row:=public.mbn_letter_action(p_actor,p_session,'download',p_data);
 select * into v_route from private.mbn_school_mail_routes where school_code=v_row->>'school_code' for share;
 if not found or v_route.sender_group is null or v_route.admissions_email='' then
  if p_action='authorized' then return 'false'::jsonb;end if;
  raise sqlstate 'PT422' using message='mail_route_missing';
 end if;
 select * into v_group from private.mbn_mail_sender_groups where code=v_route.sender_group for update;
 if p_action='authorized' then
  select * into v_msg from public.mail_messages where id=(v_row->>'message_id')::uuid and status='SENDING' and attempt_id=(p_data->>'attempt_id')::uuid;
  return to_jsonb(found and private.mbn_mail_message_current(v_msg) and (public.mbn_letter_action(p_actor,p_session,'authorized',p_data))::boolean);
 end if;
 if not private.mbn_mail_profile_ready(v_group.code) then raise sqlstate 'PT422' using message='sender_not_ready';end if;
 v_row:=public.mbn_letter_action(p_actor,p_session,'claim',p_data);
 update public.mail_messages set sender_group=v_group.code,sender_identity=v_group.from_email,sender_revision=v_group.revision,
  credential_fingerprint=v_group.credential_fingerprint,mail_route_revision=v_route.revision,service_contact_email=v_route.admissions_email
  where id=(v_row->'message'->>'id')::uuid returning * into v_msg;
 return v_row||jsonb_build_object('message',to_jsonb(v_msg),'sender',public.mbn_mail_profile_settings(v_group.code));
end;$$;

alter function public.mbn_brevo_event(text,jsonb) rename to mbn_brevo_event_single_sender;
create function public.mbn_brevo_event(p_key text,p_event jsonb) returns boolean
language plpgsql security invoker set search_path='' as $$
declare v_applied boolean;begin
 perform pg_advisory_xact_lock(72519816);
 v_applied:=public.mbn_brevo_event_single_sender(p_key,p_event);
 if v_applied and p_event->>'event'='delivered' then
  update private.mbn_mail_sender_groups g set events_verified_at=now(),updated_at=now()
   from public.mail_messages m,private.mbn_mail_settings s where s.id and s.brevo_webhook_id is not null
    and m.id=(select message_id from private.mbn_brevo_events where event_key=p_key) and m.is_test and m.status='DELIVERED'
    and m.sender_group=g.code and m.sender_revision=g.revision and m.sender_identity=g.from_email
    and m.credential_fingerprint=g.credential_fingerprint and g.credential_fingerprint=s.credential_fingerprint;
 end if;
 return v_applied;
end;$$;

revoke all on function private.mbn_mail_refresh_enabled(),private.mbn_mail_reset_group_credentials(),private.mbn_mail_profile_ready(text,boolean),private.mbn_mail_message_current(public.mail_messages) from public,anon,authenticated;
grant execute on function private.mbn_mail_refresh_enabled(),private.mbn_mail_reset_group_credentials(),private.mbn_mail_profile_ready(text,boolean),private.mbn_mail_message_current(public.mail_messages) to service_role;
revoke all on function public.mbn_workspace_action(uuid,uuid,text,jsonb),public.mbn_workspace_action_single_sender(uuid,uuid,text,jsonb),
 public.mbn_mail_profile_settings(text,text),public.mbn_mail_profile_checked(text,uuid,jsonb),public.mbn_mail_profile_claim(text,uuid),public.mbn_mail_profile_authorized(uuid,uuid),
 public.mbn_letter_profile_action(uuid,uuid,text,jsonb),public.mbn_brevo_event(text,jsonb),public.mbn_brevo_event_single_sender(text,jsonb) from public,anon,authenticated;
grant execute on function public.mbn_workspace_action(uuid,uuid,text,jsonb),public.mbn_workspace_action_single_sender(uuid,uuid,text,jsonb),
 public.mbn_mail_profile_settings(text,text),public.mbn_mail_profile_checked(text,uuid,jsonb),public.mbn_mail_profile_claim(text,uuid),public.mbn_mail_profile_authorized(uuid,uuid),
 public.mbn_letter_profile_action(uuid,uuid,text,jsonb),public.mbn_brevo_event(text,jsonb),public.mbn_brevo_event_single_sender(text,jsonb) to service_role;
