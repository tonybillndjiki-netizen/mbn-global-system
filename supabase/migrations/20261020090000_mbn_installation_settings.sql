create table private.mbn_installation_settings(
 id boolean primary key default true check(id),project_url text not null,public_origin text not null,
 candidate_commit text not null,updated_at timestamptz not null default now()
);
alter table private.mbn_installation_settings enable row level security;
revoke all on private.mbn_installation_settings from public,anon,authenticated;
grant select,insert,update on private.mbn_installation_settings to service_role;

create function public.mbn_installation_configure(p_project_url text,p_public_origin text,p_commit text) returns jsonb
language plpgsql security invoker set search_path='' as $$begin
 if p_project_url!~'^https://[a-z0-9]{20}\.supabase\.co$'
  or p_public_origin!~'^https://[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?$'
  or p_commit!~'^[a-f0-9]{40}$' or p_project_url is null or p_public_origin is null or p_commit is null then raise sqlstate 'PT422' using message='invalid_installation';end if;
 insert into private.mbn_installation_settings(id,project_url,public_origin,candidate_commit) values(true,p_project_url,p_public_origin,p_commit)
  on conflict(id) do update set project_url=excluded.project_url,public_origin=excluded.public_origin,candidate_commit=excluded.candidate_commit,updated_at=now();
 return jsonb_build_object('configured',true);
end;$$;
create function public.mbn_installation_bootstrap_owner(p_email text) returns jsonb
language plpgsql security definer set search_path='' as $$
declare v_user auth.users;begin
 perform pg_advisory_xact_lock(72519822);
 if p_email is null or p_email<>lower(btrim(p_email)) or p_email!~'^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' then raise sqlstate 'PT422' using message='invalid_owner';end if;
 if exists(select 1 from private.admin_allowlist) then
  if (select count(*) from private.admin_allowlist)=1 and exists(select 1 from private.admin_allowlist where email=p_email) then return jsonb_build_object('already_configured',true);end if;
  raise sqlstate 'PT409' using message='owner_already_configured';end if;
 select u.* into v_user from auth.users u where lower(u.email)=p_email and u.email_confirmed_at is not null and u.deleted_at is null
  and (u.banned_until is null or u.banned_until<=now()) and not coalesce((to_jsonb(u)->>'is_anonymous')::boolean,false);
 if not found then raise sqlstate 'PT422' using message='confirmed_owner_required';end if;
 insert into private.admin_allowlist(email) values(p_email);
 insert into public.profiles(user_id,email,full_name,is_active,updated_at)
 values(v_user.id,lower(v_user.email),v_user.raw_user_meta_data->>'full_name',true,now())
 on conflict(user_id) do update set email=excluded.email,is_active=true,updated_at=now();
 return jsonb_build_object('configured',true);
end;$$;
revoke all on function public.mbn_installation_configure(text,text,text),public.mbn_installation_bootstrap_owner(text) from public,anon,authenticated;
grant execute on function public.mbn_installation_configure(text,text,text),public.mbn_installation_bootstrap_owner(text) to service_role;

create or replace function private.mbn_mail_tick() returns void language plpgsql security definer set search_path='' as $$
declare v_url text;begin
 select project_url into v_url from private.mbn_installation_settings where id;
 if v_url is null or not exists(select 1 from private.mbn_mail_settings where id and enabled) then return;end if;
 execute 'select net.http_post(url:=$1,headers:=$2,body:=$3,timeout_milliseconds:=55000)'
 using v_url||'/functions/v1/mbn-workspace',jsonb_build_object('Content-Type','application/json','x-mbn-worker',private.mbn_runtime_secret('worker')),'{}'::jsonb;
end;$$;
create or replace function private.mbn_meta_tick() returns void language plpgsql security definer set search_path='' as $$
declare v_url text;begin
 select project_url into v_url from private.mbn_installation_settings where id;
 if v_url is null or not exists(select 1 from private.mbn_meta_inbox i join private.mbn_meta_routes r on r.id=i.route_id where private.mbn_meta_route_ready(r)
  and ((i.status in ('PENDING','RETRY') and i.available_at<=now() and i.attempts<5) or (i.status='PROCESSING' and i.claimed_at<now()-interval '90 seconds'))) then return;end if;
 execute 'select net.http_post(url:=$1,headers:=$2,body:=$3,timeout_milliseconds:=55000)'
 using v_url||'/functions/v1/mbn-meta',jsonb_build_object('Content-Type','application/json','x-mbn-worker',private.mbn_runtime_secret('worker')),'{}'::jsonb;
end;$$;
revoke all on function private.mbn_mail_tick(),private.mbn_meta_tick() from public,anon,authenticated,service_role;
