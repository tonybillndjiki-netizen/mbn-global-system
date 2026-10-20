-- Initial application schema restored from the retained baseline.
-- No administrator address is installed automatically.
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
on conflict(source_school,source_campus) do update set target_school=excluded.target_school,target_campus=excluded.target_campus,is_active=true
