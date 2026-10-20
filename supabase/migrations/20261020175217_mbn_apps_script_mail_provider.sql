-- Provider selection never activates sending and never marks a Google send delivered.
alter table private.mbn_mail_settings drop constraint mbn_mail_settings_provider_check;
alter table private.mbn_mail_settings add constraint mbn_mail_settings_provider_check check(provider in ('BREVO','GOOGLE_APPS_SCRIPT'));
alter table public.mail_messages drop constraint mail_messages_provider_check;
alter table public.mail_messages add constraint mail_messages_provider_check check(provider in ('SES','BREVO','GOOGLE_APPS_SCRIPT'));
alter table public.mail_messages alter column provider drop default;
alter table private.mbn_mail_sender_groups add column test_confirmed_at timestamptz,
 add column test_confirmed_by uuid references public.profiles(user_id),
 add column test_confirmed_message uuid references public.mail_messages(id);

create function private.mbn_mail_profile_proof(p_group text) returns boolean language sql stable security invoker set search_path='' as $$
 select exists(select 1 from private.mbn_mail_sender_groups g cross join private.mbn_mail_settings s
  where s.id and g.code=p_group and case when s.provider='GOOGLE_APPS_SCRIPT' then
   g.test_confirmed_at is not null and exists(select 1 from public.mail_messages m where m.id=g.test_confirmed_message
    and m.is_test and m.created_by=g.test_confirmed_by and m.sender_group=g.code and m.provider='GOOGLE_APPS_SCRIPT'
    and m.status='ACCEPTED' and m.sender_revision=g.revision and m.sender_identity=g.from_email and m.credential_fingerprint=g.credential_fingerprint)
   else g.events_verified_at is not null end);
$$;
create or replace function private.mbn_mail_profile_ready(p_group text,p_test boolean default false) returns boolean
language sql stable security invoker set search_path='' as $$
 select exists(select 1 from private.mbn_mail_sender_groups g cross join private.mbn_mail_settings s
  where s.id and g.code=p_group and g.from_email<>'' and g.sender_verified and g.production_access and g.account_sending_enabled
   and g.provider_checked_at>=now()-interval '1 hour' and g.credential_fingerprint is not null
   and (s.provider='GOOGLE_APPS_SCRIPT' or (s.brevo_webhook_id is not null and g.credential_fingerprint=s.credential_fingerprint))
   and (p_test or (g.enabled and private.mbn_mail_profile_proof(g.code))));
$$;
create function private.mbn_appscript_reset_proof() returns trigger language plpgsql security invoker set search_path='' as $$begin
 if (old.from_email,old.from_name,old.credential_fingerprint) is distinct from (new.from_email,new.from_name,new.credential_fingerprint) then
  new.test_confirmed_at:=null;new.test_confirmed_by:=null;new.test_confirmed_message:=null;
 end if;return new;end;$$;
create trigger mbn_appscript_reset_proof before update on private.mbn_mail_sender_groups for each row execute function private.mbn_appscript_reset_proof();
create function private.mbn_mail_provider_changed() returns trigger language plpgsql security invoker set search_path='' as $$begin
 if old.provider is distinct from new.provider then
  update private.mbn_mail_sender_groups set enabled=false,sender_verified=false,production_access=false,account_sending_enabled=false,
   credential_fingerprint=null,provider_checked_at=null,provider_error=null,events_verified_at=null,
   test_confirmed_at=null,test_confirmed_by=null,test_confirmed_message=null,revision=gen_random_uuid(),updated_at=now();
 end if;return null;end;$$;
create trigger mbn_mail_provider_changed after update of provider on private.mbn_mail_settings for each row execute function private.mbn_mail_provider_changed();
create function private.mbn_mail_snapshot_provider() returns trigger language plpgsql security invoker set search_path='' as $$begin
 if (tg_op='INSERT' and new.provider is null) or (tg_op='UPDATE' and new.status='SENDING' and old.status is distinct from 'SENDING') then
  select provider into new.provider from private.mbn_mail_settings where id;
 end if;return new;end;$$;
create trigger mbn_mail_snapshot_provider before insert or update of status on public.mail_messages for each row execute function private.mbn_mail_snapshot_provider();

create or replace function public.mbn_mail_profile_settings(p_group text default null,p_school text default null) returns jsonb
language plpgsql stable security invoker set search_path='' as $$declare v_group text:=p_group;v_result jsonb;begin
 if p_school is not null then
  select sender_group into v_group from private.mbn_school_mail_routes where school_code=p_school;
  if v_group is null then raise sqlstate 'PT422' using message='mail_route_missing';end if;
 end if;
 select to_jsonb(g)||jsonb_build_object('reply_to',g.from_email,'daily_limit',s.daily_limit,'brevo_webhook_id',s.brevo_webhook_id,'provider',s.provider,
  'last_dispatch_at',(select max(m.claimed_at) from public.mail_messages m where m.sender_group=g.code and not m.is_test and m.claimed_at is not null))
  into v_result from private.mbn_mail_sender_groups g cross join private.mbn_mail_settings s where s.id and g.code=v_group;
 if v_result is null then raise sqlstate 'PT422' using message='invalid_sender_group';end if;return v_result;
end;$$;
alter function public.mbn_mail_profile_checked(text,uuid,jsonb) rename to mbn_mail_profile_checked_brevo;
create function public.mbn_mail_profile_checked(p_group text,p_revision uuid,p_result jsonb) returns jsonb
language plpgsql security invoker set search_path='' as $$declare v_group private.mbn_mail_sender_groups;v_hash text:=p_result->>'credential_fingerprint';begin
 if (select provider from private.mbn_mail_settings where id)='BREVO' then return public.mbn_mail_profile_checked_brevo(p_group,p_revision,p_result);end if;
 if p_result->>'provider' is distinct from 'GOOGLE_APPS_SCRIPT' or (v_hash is not null and v_hash !~ '^[a-f0-9]{64}$') then
  raise sqlstate 'PT400' using message='invalid_provider';end if;
 perform pg_advisory_xact_lock(72519816);
 select * into v_group from private.mbn_mail_sender_groups where code=p_group and revision=p_revision for update;
 if not found then raise sqlstate 'PT409' using message='mail_configuration_changed';end if;
 update private.mbn_mail_sender_groups set sender_verified=coalesce((p_result->>'sender_verified')::boolean,false),
  production_access=coalesce((p_result->>'production_access')::boolean,false),account_sending_enabled=coalesce((p_result->>'account_sending_enabled')::boolean,false),
  provider_checked_at=now(),provider_error=p_result->>'error',credential_fingerprint=coalesce(v_hash,credential_fingerprint),
  revision=case when v_hash is not null and credential_fingerprint is distinct from v_hash then gen_random_uuid() else revision end,
  enabled=enabled and (v_hash is null or credential_fingerprint=v_hash) and coalesce((p_result->>'sender_verified')::boolean,false)
   and coalesce((p_result->>'production_access')::boolean,false) and coalesce((p_result->>'account_sending_enabled')::boolean,false),updated_at=now()
  where code=p_group;
 return public.mbn_mail_profile_settings(p_group);
end;$$;

create function public.mbn_appscript_admin(p_actor uuid,p_session uuid,p_action text,p_data jsonb default '{}') returns jsonb
language plpgsql security invoker set search_path='' as $$declare v_ctx jsonb;v_group private.mbn_mail_sender_groups;v_msg public.mail_messages;begin
 v_ctx:=public.mbn_pin_context(p_actor,p_session,p_actor);
 if not coalesce((v_ctx->>'admin')::boolean,false) then raise sqlstate 'PT403' using message='access_denied';end if;
 if jsonb_typeof(p_data) is distinct from 'object' then raise sqlstate 'PT400' using message='invalid_request';end if;
 perform pg_advisory_xact_lock(72519816);
 if p_action='select' then
  if p_data<>'{}' then raise sqlstate 'PT400' using message='invalid_request';end if;
  update private.mbn_mail_settings set provider='GOOGLE_APPS_SCRIPT',updated_at=now() where id and provider<>'GOOGLE_APPS_SCRIPT';
 elsif p_action='confirm_test' then
  if exists(select 1 from jsonb_object_keys(p_data) k where k not in ('sender_group','message_id','received')) or p_data->'received' is distinct from 'true'::jsonb
   or (select provider from private.mbn_mail_settings where id)<>'GOOGLE_APPS_SCRIPT' then raise sqlstate 'PT422' using message='appscript_test_required';end if;
  select * into v_group from private.mbn_mail_sender_groups where code=p_data->>'sender_group' for update;
  if not found or not private.mbn_mail_profile_ready(v_group.code,true) then raise sqlstate 'PT422' using message='sender_not_ready';end if;
  select * into v_msg from public.mail_messages where id::text=p_data->>'message_id' and is_test and created_by=p_actor
   and sender_group=v_group.code and sender_revision=v_group.revision and sender_identity=v_group.from_email
   and credential_fingerprint=v_group.credential_fingerprint and provider='GOOGLE_APPS_SCRIPT' and status='ACCEPTED'
   and accepted_at>=now()-interval '24 hours' and recipient=(select lower(email) from auth.users where id=p_actor and email_confirmed_at is not null);
  if not found then raise sqlstate 'PT422' using message='appscript_test_required';end if;
  update private.mbn_mail_sender_groups set test_confirmed_at=now(),test_confirmed_by=p_actor,test_confirmed_message=v_msg.id where code=v_group.code;
 else raise sqlstate 'PT400' using message='unknown_action';end if;
 return jsonb_build_object('success',true);
end;$$;
revoke all on function private.mbn_mail_profile_proof(text),private.mbn_appscript_reset_proof(),private.mbn_mail_provider_changed(),private.mbn_mail_snapshot_provider() from public,anon,authenticated;
grant execute on function private.mbn_mail_profile_proof(text) to service_role;
revoke all on function public.mbn_mail_profile_checked(text,uuid,jsonb),public.mbn_appscript_admin(uuid,uuid,text,jsonb) from public,anon,authenticated;
grant execute on function public.mbn_mail_profile_checked(text,uuid,jsonb),public.mbn_appscript_admin(uuid,uuid,text,jsonb) to service_role;

-- Retain the existing school routes and owner authorization.
create or replace function public.mbn_workspace_action(p_actor uuid,p_session uuid,p_action text,p_data jsonb default '{}') returns jsonb
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
  return jsonb_build_object('provider',(select provider from private.mbn_mail_settings where id),'daily_limit',(select daily_limit from private.mbn_mail_settings where id),
   'brevo_webhook_id',(select brevo_webhook_id from private.mbn_mail_settings where id),
   'groups',(select jsonb_agg((to_jsonb(g)-'credential_fingerprint')||jsonb_build_object('test_confirmation_valid',private.mbn_mail_profile_proof(g.code),'last_test',(select jsonb_build_object('id',m.id,'status',m.status,'created_at',m.created_at) from public.mail_messages m where m.sender_group=g.code and m.is_test and m.created_by=p_actor and m.provider=(select provider from private.mbn_mail_settings where id) order by m.created_at desc,m.id desc limit 1)) order by g.code) from private.mbn_mail_sender_groups g),
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
   if (p_data->>'enabled')::boolean and (v_changed or not private.mbn_mail_profile_ready(v_group.code,true) or not private.mbn_mail_profile_proof(v_group.code))
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

