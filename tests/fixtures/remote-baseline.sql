-- Remote baseline 20261018162317 mbn_core_19_schools_access

create schema if not exists private;
revoke all on schema private from public;

create table if not exists private.admin_allowlist (
 email text primary key check (email = lower(email)),
 created_at timestamptz not null default now()
);
insert into private.admin_allowlist(email) values ('nbtonybill@gmail.com')
on conflict (email) do nothing;

create table if not exists public.schools (
 code text primary key,
 name text not null,
 school_type text not null check (school_type in ('MONO','MULTI')),
 is_active boolean not null default false,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table if not exists public.campuses (
 code text primary key,
 name text not null,
 address text,
 created_at timestamptz not null default now()
);
create table if not exists public.school_campuses (
 school_code text not null references public.schools(code) on delete cascade,
 campus_code text not null references public.campuses(code),
 primary key (school_code, campus_code)
);
create table if not exists public.profiles (
 user_id uuid primary key references auth.users(id) on delete cascade,
 email text not null,
 full_name text,
 is_active boolean not null default false,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table if not exists public.school_memberships (
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 school_code text not null references public.schools(code) on delete cascade,
 role text not null check (role in ('DIRECTION','ADMISSIONS','CM','LECTURE')),
 is_active boolean not null default false,
 created_at timestamptz not null default now(),
 primary key (user_id,school_code)
);
create table if not exists public.school_programs (
 id uuid primary key default gen_random_uuid(),
 school_code text not null references public.schools(code) on delete cascade,
 name text not null,
 cycle text,
 academic_level text,
 domain text,
 rncp_code text,
 pace text,
 is_active boolean not null default false,
 cloned_from_id uuid references public.school_programs(id),
 created_at timestamptz not null default now()
);
create index if not exists school_programs_school_idx on public.school_programs(school_code);

create or replace function private.handle_new_auth_user()
returns trigger
language plpgsql security definer set search_path = ''
as $$
begin
 insert into public.profiles(user_id,email,full_name)
 values(new.id, coalesce(new.email,''), new.raw_user_meta_data->>'full_name')
 on conflict (user_id) do update set email = excluded.email;
 return new;
end; $$;
revoke all on function private.handle_new_auth_user() from public, anon, authenticated;
drop trigger if exists mbn_on_auth_user_created on auth.users;
create trigger mbn_on_auth_user_created after insert on auth.users
for each row execute function private.handle_new_auth_user();

create or replace function private.is_mbn_admin()
returns boolean
language sql stable security definer set search_path = ''
as $$
 select exists (
  select 1 from auth.users u
  join private.admin_allowlist a on lower(u.email)=a.email
  where u.id=(select auth.uid()) and u.email_confirmed_at is not null
 );
$$;

create or replace function private.can_read_school(p_school_code text)
returns boolean
language sql stable security definer set search_path = ''
as $$
 select private.is_mbn_admin() or exists (
   select 1
   from public.school_memberships m
   join public.profiles p on p.user_id=m.user_id
   join public.schools s on s.code=m.school_code
   where m.user_id=(select auth.uid())
   and m.school_code=p_school_code
   and m.is_active and p.is_active and s.is_active
 );
$$;
revoke all on function private.is_mbn_admin() from public, anon;
revoke all on function private.can_read_school(text) from public, anon;
grant usage on schema private to authenticated;
grant execute on function private.is_mbn_admin() to authenticated;
grant execute on function private.can_read_school(text) to authenticated;

insert into public.schools(code,name,school_type) values
('LSB','LSB','MONO'), ('ESUV','ESUV','MONO'), ('ESEA','ESEA','MONO'),
('MLV BS','MLV BS','MONO'), ('MLV BTS','MLV BTS','MONO'),
('ESMOSS','ESMOSS','MONO'), ('ESMAS','ESMAS','MONO'),
('ESART','ESART','MONO'), ('CESCOM','CESCOM','MONO'),
('ESJM','ESJM','MONO'), ('EVRY BS','EVRY BS','MONO'),
('EVRY BTS','EVRY BTS','MONO'), ('ESETH','ESETH','MONO'),
('ISMOD','ISMOD','MULTI'), ('ILMIS','ILMIS','MULTI'),
('DCG FORMATIONS','DCG FORMATIONS','MULTI'), ('ESIIA','ESIIA','MULTI'),
('ESMEP','ESMEP','MULTI'), ('EMSP','EMSP','MULTI')
on conflict(code) do nothing;

insert into public.campuses(code,name,address) values
('LYON','Lyon',null),('NOISIEL','Noisiel','47 Grande Allée du 12 février 1934, 77186 Noisiel'),
('EVRY','Évry',null),('TORCY','Torcy',null)
on conflict(code) do nothing;

insert into public.school_campuses(school_code,campus_code) values
('LSB','LYON'), ('ESUV','LYON'), ('ESEA','NOISIEL'),
('MLV BS','NOISIEL'),('MLV BTS','NOISIEL'),('ESMOSS','NOISIEL'),
('ESMAS','NOISIEL'),('ESART','NOISIEL'),('CESCOM','NOISIEL'),
('ESJM','NOISIEL'),('EVRY BS','EVRY'),('EVRY BTS','EVRY'),
('ESETH','EVRY'),
('ISMOD','TORCY'),('ISMOD','EVRY'),('ISMOD','LYON'),
('ILMIS','TORCY'),('ILMIS','EVRY'),('ILMIS','LYON'),
('DCG FORMATIONS','TORCY'),('DCG FORMATIONS','EVRY'),('DCG FORMATIONS','LYON'),
('ESIIA','TORCY'),('ESIIA','EVRY'),('ESIIA','LYON'),
('ESMEP','TORCY'),('ESMEP','EVRY'),('ESMEP','LYON'),
('EMSP','TORCY'),('EMSP','EVRY'),('EMSP','LYON')
on conflict do nothing;

alter table public.schools enable row level security;
alter table public.campuses enable row level security;
alter table public.school_campuses enable row level security;
alter table public.profiles enable row level security;
alter table public.school_memberships enable row level security;
alter table public.school_programs enable row level security;

create policy "public_active_schools" on public.schools
for select to anon using(is_active);
create policy "staff_visible_schools" on public.schools
for select to authenticated using(is_active or (select private.is_mbn_admin()));
create policy "admin_manage_schools" on public.schools
for all to authenticated using((select private.is_mbn_admin()))
with check((select private.is_mbn_admin()));

create policy "campus_public_read" on public.campuses
for select to anon,authenticated using(true);
create policy "campus_admin_write" on public.campuses
for all to authenticated using((select private.is_mbn_admin()))
with check((select private.is_mbn_admin()));

create policy "public_school_campuses" on public.school_campuses
for select to anon using(exists(select 1 from public.schools s where s.code=school_code and s.is_active));
create policy "authenticated_school_campuses" on public.school_campuses
for select to authenticated using(
 (select private.is_mbn_admin()) or
 exists(select 1 from public.schools s where s.code=school_code and s.is_active)
);
create policy "admin_manage_school_campuses" on public.school_campuses
for all to authenticated using((select private.is_mbn_admin()))
with check((select private.is_mbn_admin()));

create policy "own_or_admin_profile_read" on public.profiles
for select to authenticated using(user_id=(select auth.uid()) or (select private.is_mbn_admin()));
create policy "admin_manage_profiles" on public.profiles
for all to authenticated using((select private.is_mbn_admin()))
with check((select private.is_mbn_admin()));

create policy "own_or_admin_membership_read" on public.school_memberships
for select to authenticated using(user_id=(select auth.uid()) or (select private.is_mbn_admin()));
create policy "admin_manage_memberships" on public.school_memberships
for all to authenticated using((select private.is_mbn_admin()))
with check((select private.is_mbn_admin()));

create policy "active_public_programs" on public.school_programs
for select to anon using(is_active and exists (
 select 1 from public.schools s where s.code=school_code and s.is_active
));
create policy "authenticated_programs_read" on public.school_programs
for select to authenticated using(
 (select private.is_mbn_admin()) or
 (is_active and exists(select 1 from public.schools s where s.code=school_code and s.is_active))
 or private.can_read_school(school_code)
);
create policy "admin_manage_programs" on public.school_programs
for all to authenticated using((select private.is_mbn_admin()))
with check((select private.is_mbn_admin()));

grant select on public.schools, public.campuses, public.school_campuses, public.school_programs to anon;
grant select,insert,update,delete on public.schools, public.campuses, public.school_campuses, public.profiles, public.school_memberships, public.school_programs to authenticated;

;
-- Remote baseline 20261018163159 mbn_crm_funnel_source_tracking

alter table public.schools
 add column if not exists slug text,
 add column if not exists source_status text,
 add column if not exists source_notes text;
alter table public.school_programs
 add column if not exists review_status text,
 add column if not exists source_file text,
 add column if not exists source_version text;

create table if not exists public.crm_leads (
 id uuid primary key default gen_random_uuid(),
 school_code text not null references public.schools(code),
 campus_code text references public.campuses(code),
 program_id uuid references public.school_programs(id),
 source text not null check (source in ('META_LEAD','META_MESSENGER','DIRECT','IMPORT','OTHER')),
 source_external_id text,
 full_name text not null,
 email text not null,
 phone text,
 country_of_residence text,
 consent_email boolean not null default false,
 consent_recorded_at timestamptz,
 consent_source text,
 status text not null default 'NEW'
  check(status in ('NEW','INVITED','CLICKED','STARTED','SUBMITTED','UNSUBSCRIBED','DISQUALIFIED')),
 assigned_admissions_user uuid references public.profiles(user_id),
 assigned_cm_user uuid references public.profiles(user_id),
 submitted_at timestamptz,
 clicked_at timestamptz,
 unsubscribed_at timestamptz,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 constraint email_len check (length(email)<=254),
 constraint email_contains_at check(position('@' in email)>1)
);
create unique index if not exists crm_lead_external_uniq
 on public.crm_leads(source,source_external_id)
 where source_external_id is not null;
create index if not exists crm_lead_school_status on public.crm_leads(school_code,status,created_at);
create index if not exists crm_lead_email_idx on public.crm_leads(lower(email));

create table if not exists public.crm_applications (
 id uuid primary key default gen_random_uuid(),
 lead_id uuid not null references public.crm_leads(id),
 school_code text not null references public.schools(code),
 campus_code text not null references public.campuses(code),
 program_id uuid references public.school_programs(id),
 application_reference text unique,
 admission_type text not null check(admission_type in ('NATIONAL','INTERNATIONAL')),
 status text not null default 'RECEIVED',
 form_payload jsonb not null default '{}'::jsonb,
 source_system text not null default 'MBN_FORM',
 external_crm_reference text,
 received_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create index if not exists crm_applications_school on public.crm_applications(school_code,received_at);

create table if not exists public.crm_lead_events (
 id bigint generated always as identity primary key,
 lead_id uuid not null references public.crm_leads(id) on delete cascade,
 event_type text not null,
 event_metadata jsonb not null default '{}'::jsonb,
 created_at timestamptz not null default now()
);
create index if not exists crm_lead_events_by_lead on public.crm_lead_events(lead_id,created_at desc);

create table if not exists public.crm_outreach_queue (
 id uuid primary key default gen_random_uuid(),
 lead_id uuid not null references public.crm_leads(id) on delete cascade,
 sequence_type text not null check(sequence_type in ('META_UNCLICKED','CLICKED_NOT_SUBMITTED')),
 attempt_number smallint not null check (attempt_number between 0 and 3),
 scheduled_at timestamptz not null,
 status text not null default 'PENDING' check (status in ('PENDING','SENT','CANCELED','FAILED')),
 sent_at timestamptz,
 canceled_at timestamptz,
 created_at timestamptz not null default now(),
 unique(lead_id,sequence_type,attempt_number)
);
create index if not exists crm_outreach_due on public.crm_outreach_queue(status,scheduled_at);

alter table public.crm_leads enable row level security;
alter table public.crm_applications enable row level security;
alter table public.crm_lead_events enable row level security;
alter table public.crm_outreach_queue enable row level security;

create policy "read_leads_by_school" on public.crm_leads for select to authenticated
using(private.can_read_school(school_code));
create policy "admin_write_leads" on public.crm_leads for all to authenticated
using((select private.is_mbn_admin())) with check((select private.is_mbn_admin()));

create policy "read_applications_by_school" on public.crm_applications for select to authenticated
using(private.can_read_school(school_code));
create policy "admin_write_applications" on public.crm_applications for all to authenticated
using((select private.is_mbn_admin())) with check((select private.is_mbn_admin()));

create policy "read_events_by_school" on public.crm_lead_events for select to authenticated
using(exists(select 1 from public.crm_leads l where l.id=lead_id and private.can_read_school(l.school_code)));
create policy "admin_write_events" on public.crm_lead_events for all to authenticated
using((select private.is_mbn_admin())) with check((select private.is_mbn_admin()));

create policy "read_outreach_by_school" on public.crm_outreach_queue for select to authenticated
using(exists(select 1 from public.crm_leads l where l.id=lead_id and private.can_read_school(l.school_code)));
create policy "admin_write_outreach" on public.crm_outreach_queue for all to authenticated
using((select private.is_mbn_admin())) with check((select private.is_mbn_admin()));

grant select,insert,update,delete on
 public.crm_leads, public.crm_applications, public.crm_lead_events, public.crm_outreach_queue
 to authenticated;
grant usage,select on sequence public.crm_lead_events_id_seq to authenticated;

;
-- Remote baseline 20261018163634 mbn_form_cescom_aliases

create table if not exists public.form_route_aliases (
 source_school text not null,
 source_campus text not null default '',
 target_school text not null references public.schools(code),
 target_campus text not null references public.campuses(code),
 is_active boolean not null default true,
 created_at timestamptz not null default now(),
 primary key(source_school,source_campus)
);
alter table public.form_route_aliases enable row level security;
create policy "active_aliases_visible" on public.form_route_aliases
for select to anon,authenticated using(is_active and exists(
select 1 from public.schools s where s.code=target_school and s.is_active));
create policy "admin_manage_aliases" on public.form_route_aliases
for all to authenticated using((select private.is_mbn_admin()))
with check((select private.is_mbn_admin()));
grant select on public.form_route_aliases to anon;
grant select,insert,update,delete on public.form_route_aliases to authenticated;
insert into public.form_route_aliases(source_school,source_campus,target_school,target_campus)
values ('CESCOM PARIS','PARIS','CESCOM','NOISIEL'),
('CESCOM','PARIS','CESCOM','NOISIEL')
on conflict(source_school,source_campus) do update set target_school=excluded.target_school,target_campus=excluded.target_campus,is_active=true;

