-- Initial application schema restored from the retained baseline.
-- No administrator address is installed automatically.
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
