begin;
create table private.app_credentials(
 user_id uuid primary key references public.profiles(user_id) on delete cascade,
 username_key text unique not null check(username_key ~ '^[a-z0-9][a-z0-9 ._-]{1,58}[a-z0-9]$'),
 display_name text not null check(length(display_name) between 3 and 60),
 pin_hash text check(pin_hash ~ '^[a-f0-9]{64}$'),
 pin_salt text check(pin_salt ~ '^[a-f0-9]{32}$'),
 iterations integer not null default 600000 check(iterations=600000),
 version uuid not null default gen_random_uuid(),
 updated_at timestamptz not null default now(),
 check((pin_hash is null)=(pin_salt is null))
);
create table private.pin_attempts(
 username_key text primary key,period_start timestamptz not null default now(),
 attempts integer not null default 0,day_start date not null default current_date,
 day_attempts integer not null default 0,lease_id uuid,lease_until timestamptz
);
create index pin_attempts_period_idx on private.pin_attempts(period_start);
create table private.pin_sessions(
 session_id uuid primary key,user_id uuid not null references public.profiles(user_id) on delete cascade,
 credential_version uuid not null,created_at timestamptz not null default now()
);
create index pin_sessions_user_idx on private.pin_sessions(user_id);
create table private.app_access_audit(
 id bigint generated always as identity primary key,
 actor_id uuid references public.profiles(user_id) on delete set null,
 target_id uuid references public.profiles(user_id) on delete set null,
 event_type text not null check(event_type in ('PIN_CONFIGURED','PIN_LOGIN')),
 created_at timestamptz not null default now()
);
create index app_access_audit_actor_idx on private.app_access_audit(actor_id);
create index app_access_audit_target_idx on private.app_access_audit(target_id);
alter table private.app_credentials enable row level security;
alter table private.pin_attempts enable row level security;
alter table private.pin_sessions enable row level security;
alter table private.app_access_audit enable row level security;
revoke all on private.app_credentials,private.pin_attempts,private.pin_sessions,private.app_access_audit from public,anon,authenticated;
grant select,insert,update on private.app_credentials,private.pin_attempts,private.pin_sessions to service_role;
grant delete on private.pin_attempts to service_role;
grant insert on private.app_access_audit to service_role;
grant usage on sequence private.app_access_audit_id_seq to service_role;
grant select(id,user_id,created_at) on auth.sessions to service_role;
grant select(user_id,status) on auth.mfa_factors to service_role;
grant select(banned_until,deleted_at) on auth.users to service_role;

-- Preserve normal Supabase sessions; invalidate PIN sessions when their code is changed.
create function private.mbn_pin_session_allowed()
returns boolean language sql stable security definer set search_path='' as $$
 select exists(select 1 from auth.users u join public.profiles p on p.user_id=u.id where u.id=(select auth.uid()) and u.email_confirmed_at is not null and p.is_active and u.deleted_at is null and (u.banned_until is null or u.banned_until<now())) and not exists(
  select 1 from private.pin_sessions s left join private.app_credentials c on c.user_id=s.user_id
  where s.session_id::text=coalesce(nullif(current_setting('request.jwt.claims',true),'')::jsonb->>'session_id','')
   and (s.user_id<>(select auth.uid()) or c.version is distinct from s.credential_version or c.pin_hash is null or not exists(select 1 from auth.sessions a where a.id=s.session_id and a.user_id=(select auth.uid())))
 );
$$;
revoke all on function private.mbn_pin_session_allowed() from public,anon;
grant execute on function private.mbn_pin_session_allowed() to authenticated;
create or replace function private.is_mbn_admin()
returns boolean language sql stable security definer set search_path='' as $$
 select private.mbn_pin_session_allowed() and exists(
  select 1 from auth.users u join private.admin_allowlist a on a.email=lower(u.email)
  join public.profiles p on p.user_id=u.id
  where u.id=(select auth.uid()) and u.email_confirmed_at is not null and p.is_active
 );
$$;
create or replace function private.can_read_school(p_school_code text)
returns boolean language sql stable security definer set search_path='' as $$
 select private.mbn_pin_session_allowed() and (private.is_mbn_admin() or exists(
  select 1 from public.school_memberships m join public.profiles p on p.user_id=m.user_id
  join public.schools s on s.code=m.school_code
  where m.user_id=(select auth.uid()) and m.school_code=p_school_code and m.is_active and p.is_active and s.is_active
 ));
$$;
create function private.mbn_pin_account_ready(p_user uuid)
returns boolean language sql stable security invoker set search_path='' as $$
 select exists(select 1 from auth.users u join public.profiles p on p.user_id=u.id
  where u.id=p_user and u.email_confirmed_at is not null and u.deleted_at is null
   and (u.banned_until is null or u.banned_until<now()) and p.is_active)
  and not exists(select 1 from auth.mfa_factors f where f.user_id=p_user and f.status='verified');
$$;
revoke all on function private.mbn_pin_account_ready(uuid) from public,anon,authenticated;
grant execute on function private.mbn_pin_account_ready(uuid) to service_role;

create function public.mbn_pin_begin(p_key text)
returns jsonb language plpgsql security invoker set search_path='' as $fn$
declare v_a private.pin_attempts%rowtype;v_g private.pin_attempts%rowtype;v_c private.app_credentials%rowtype;v_ticket uuid;
begin
 if p_key is null or p_key !~ '^[a-z0-9][a-z0-9 ._-]{1,58}[a-z0-9]$' then raise sqlstate 'PT400' using message='invalid_username';end if;
 perform pg_advisory_xact_lock(hashtextextended('mbn-pin-global',0));
 delete from private.pin_attempts where username_key<>'*' and period_start<now()-interval '2 days';
 insert into private.pin_attempts(username_key) values('*'),(p_key) on conflict do nothing;
 select * into v_g from private.pin_attempts where username_key='*' for update;
 if v_g.period_start<=now()-interval '5 minutes' then v_g.attempts:=0;v_g.period_start:=now();end if;
 if v_g.attempts>=300 then return jsonb_build_object('blocked',true);end if;
 update private.pin_attempts set attempts=v_g.attempts+1,period_start=v_g.period_start where username_key='*';
 select * into v_a from private.pin_attempts where username_key=p_key for update;
 if v_a.period_start<=now()-interval '15 minutes' then v_a.attempts:=0;v_a.period_start:=now();end if;
 if v_a.day_start<>current_date then v_a.day_attempts:=0;v_a.day_start:=current_date;end if;
 if v_a.attempts>=5 or v_a.day_attempts>=20 or v_a.lease_until>now() then return jsonb_build_object('blocked',true);end if;
 v_ticket:=gen_random_uuid();
 update private.pin_attempts set attempts=v_a.attempts+1,period_start=v_a.period_start,
  day_attempts=v_a.day_attempts+1,day_start=v_a.day_start,lease_id=v_ticket,lease_until=now()+interval '45 seconds' where username_key=p_key;
 select * into v_c from private.app_credentials where username_key=p_key;
 if v_c.pin_hash is null or not private.mbn_pin_account_ready(v_c.user_id) then
  return jsonb_build_object('blocked',false,'ticket',v_ticket,'credential',null);
 end if;
 return jsonb_build_object('blocked',false,'ticket',v_ticket,'credential',jsonb_build_object(
  'version',v_c.version,'user_id',v_c.user_id,'hash',v_c.pin_hash,'salt',v_c.pin_salt,'iterations',v_c.iterations));
end;$fn$;
create function public.mbn_pin_finish(p_key text,p_ticket uuid,p_success boolean,p_version uuid)
returns jsonb language plpgsql security invoker set search_path='' as $fn$
declare v_a private.pin_attempts%rowtype;v_c private.app_credentials%rowtype;v_email text;
begin
 select * into v_a from private.pin_attempts where username_key=p_key for update;
 if not found or v_a.lease_id is distinct from p_ticket or v_a.lease_until<now() then return jsonb_build_object('allowed',false);end if;
 update private.pin_attempts set lease_id=null,lease_until=null where username_key=p_key;
 select * into v_c from private.app_credentials where username_key=p_key;
 if p_success is not true or v_c.version is distinct from p_version or v_c.pin_hash is null or not private.mbn_pin_account_ready(v_c.user_id) then return jsonb_build_object('allowed',false);end if;
 select email into v_email from auth.users where id=v_c.user_id;
 update private.pin_attempts set attempts=0,day_attempts=greatest(day_attempts-1,0) where username_key=p_key;
 return jsonb_build_object('allowed',true,'user_id',v_c.user_id,'email',v_email,'version',v_c.version);
end;$fn$;
create function public.mbn_pin_context(p_actor uuid,p_session uuid,p_target uuid)
returns jsonb language plpgsql security invoker set search_path='' as $fn$
declare v_actor private.app_credentials%rowtype;v_target private.app_credentials%rowtype;v_admin boolean;v_fresh boolean;
begin
 if not private.mbn_pin_account_ready(p_actor) or not exists(select 1 from auth.sessions where id=p_session and user_id=p_actor) then raise sqlstate 'PT403' using message='access_denied';end if;
 select * into v_actor from private.app_credentials where user_id=p_actor;
 if exists(select 1 from private.pin_sessions s where s.session_id=p_session and (s.user_id<>p_actor or s.credential_version is distinct from v_actor.version)) then raise sqlstate 'PT403' using message='session_revoked';end if;
 v_admin:=private.mbn_native_actor_allowed(p_actor);
 if p_target is null or (p_target<>p_actor and not v_admin) or not exists(select 1 from public.profiles where user_id=p_target) then raise sqlstate 'PT403' using message='access_denied';end if;
 select * into v_target from private.app_credentials where user_id=p_target;
 select created_at>=now()-interval '10 minutes' into v_fresh from auth.sessions where id=p_session;
 return jsonb_build_object('actor',jsonb_build_object('user_id',p_actor,'username_key',v_actor.username_key,'configured',v_actor.pin_hash is not null,'version',v_actor.version,'fresh',v_fresh),
  'target',jsonb_build_object('user_id',p_target,'username',v_target.display_name,'configured',v_target.pin_hash is not null),'admin',v_admin);
end;$fn$;
create function public.mbn_pin_configure(p_actor uuid,p_session uuid,p_target uuid,p_actor_version uuid,p_key text,p_display text,p_hash text,p_salt text)
returns jsonb language plpgsql security invoker set search_path='' as $fn$
declare v_ctx jsonb;v_actor private.app_credentials%rowtype;
begin
 v_ctx:=public.mbn_pin_context(p_actor,p_session,p_target);
 select * into v_actor from private.app_credentials where user_id=p_actor for update;
 if v_actor.version is distinct from p_actor_version then raise sqlstate 'PT409' using message='access_changed';end if;
 if v_actor.pin_hash is null and (v_ctx#>>'{actor,fresh}')::boolean is not true then raise sqlstate 'PT403' using message='reauthentication_required';end if;
 if p_key is null or p_key !~ '^[a-z0-9][a-z0-9 ._-]{1,58}[a-z0-9]$' or p_display is null or length(p_display) not between 3 and 60
  or p_hash is null or p_hash !~ '^[a-f0-9]{64}$' or p_salt is null or p_salt !~ '^[a-f0-9]{32}$' then raise sqlstate 'PT400' using message='invalid_access';end if;
 begin
  insert into private.app_credentials(user_id,username_key,display_name,pin_hash,pin_salt)
   values(p_target,p_key,p_display,p_hash,p_salt)
   on conflict(user_id) do update set username_key=excluded.username_key,display_name=excluded.display_name,pin_hash=excluded.pin_hash,pin_salt=excluded.pin_salt,version=gen_random_uuid(),updated_at=now();
 exception when unique_violation then raise sqlstate 'PT409' using message='username_taken';end;
 -- Successful changes invalidate earlier PIN sessions through the RLS helper.
 insert into private.app_access_audit(actor_id,target_id,event_type) values(p_actor,p_target,'PIN_CONFIGURED');
 return jsonb_build_object('success',true,'username',p_display);
end;$fn$;
create function public.mbn_pin_register_session(p_user uuid,p_version uuid,p_session uuid)
returns boolean language plpgsql security invoker set search_path='' as $fn$
begin
 perform 1 from private.app_credentials where user_id=p_user and version=p_version and pin_hash is not null for share;
 if not found or not private.mbn_pin_account_ready(p_user) or not exists(select 1 from auth.sessions where id=p_session and user_id=p_user) then return false;end if;
 insert into private.pin_sessions(session_id,user_id,credential_version) values(p_session,p_user,p_version);
 insert into private.app_access_audit(actor_id,target_id,event_type) values(p_user,p_user,'PIN_LOGIN');
 return true;
end;$fn$;
revoke all on function public.mbn_pin_begin(text),public.mbn_pin_finish(text,uuid,boolean,uuid),public.mbn_pin_context(uuid,uuid,uuid),public.mbn_pin_configure(uuid,uuid,uuid,uuid,text,text,text,text),public.mbn_pin_register_session(uuid,uuid,uuid) from public,anon,authenticated;
grant execute on function public.mbn_pin_begin(text),public.mbn_pin_finish(text,uuid,boolean,uuid),public.mbn_pin_context(uuid,uuid,uuid),public.mbn_pin_configure(uuid,uuid,uuid,uuid,text,text,text,text),public.mbn_pin_register_session(uuid,uuid,uuid) to service_role;
-- Reserve the requested name, without installing any code disclosed in the conversation.
insert into private.app_credentials(user_id,username_key,display_name)
 select user_id,'tony bill','Tony Bill' from public.profiles where lower(email)='nbtonybill@gmail.com'
 on conflict(user_id) do nothing;
commit;
