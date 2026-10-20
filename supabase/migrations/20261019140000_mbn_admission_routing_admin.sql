-- No real staff assignments are inferred or installed by this migration.
alter table public.admission_routing_rules
 add column revision uuid not null default gen_random_uuid(),
 add column updated_at timestamptz not null default now();

create function private.mbn_routing_revision() returns trigger
language plpgsql security invoker set search_path='' as $$begin
 new.revision:=gen_random_uuid();new.updated_at:=now();return new;
end;$$;
create trigger mbn_routing_revision before update on public.admission_routing_rules
 for each row execute function private.mbn_routing_revision();

-- Preserve the existing ordering: specificity, priority, creation time, id.
-- An unavailable specific rule requires review rather than silently choosing
-- a different team from a less specific rule.
create function private.mbn_routing_pick(p_school text,p_program uuid,p_campus text,p_intake text)
returns table(rule_id uuid,rule_revision uuid,user_id uuid)
language sql stable security invoker set search_path='' as $$
 select r.id,r.revision,case when private.mbn_ws_admissions_active(r.primary_user,p_school) then r.primary_user
  when private.mbn_ws_admissions_active(r.backup_user,p_school) then r.backup_user end
 from public.admission_routing_rules r where r.school_code=p_school and r.is_active
 and (r.program_id is null or r.program_id=p_program) and (r.campus_code is null or r.campus_code=p_campus)
 and (r.intake is null or r.intake=p_intake)
 order by ((r.program_id is not null)::int+(r.campus_code is not null)::int+(r.intake is not null)::int) desc,
  r.priority desc,r.created_at,r.id limit 1;
$$;
create or replace function private.mbn_ws_route_application() returns trigger
language plpgsql security invoker set search_path='' as $$begin
 select p.user_id into new.assigned_admissions_user from private.mbn_routing_pick(new.school_code,new.program_id,new.campus_code,new.form_payload->>'intake') p;
 new.routing_status:=case when new.assigned_admissions_user is null then 'UNASSIGNED' else 'ASSIGNED' end;
 return new;
end;$$;

create function public.mbn_routing_action(p_actor uuid,p_session uuid,p_action text,p_data jsonb default '{}') returns jsonb
language plpgsql security invoker set search_path='' as $$
declare
 v_ctx jsonb;v_school text;v_rule public.admission_routing_rules;v_app public.crm_applications;
 v_id uuid;v_primary uuid;v_backup uuid;v_program uuid;v_campus text;v_intake text;v_priority integer;
 v_uuid text:='^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$';
 v_rows jsonb;v_item jsonb;v_pick record;v_assigned integer:=0;v_skipped integer:=0;v_total integer;
begin
 v_ctx:=public.mbn_pin_context(p_actor,p_session,p_actor);
 if not coalesce((v_ctx->>'admin')::boolean,false) then raise sqlstate 'PT403' using message='access_denied';end if;
 if jsonb_typeof(p_data) is distinct from 'object' then raise sqlstate 'PT400' using message='invalid_request';end if;
 if p_action not in ('routing_context','routing_save','routing_toggle','routing_reassign_preview','routing_reassign_apply') then
  raise sqlstate 'PT400' using message='unknown_action';end if;
 if p_action in ('routing_save','routing_toggle','routing_reassign_apply') then perform pg_advisory_xact_lock(72519819);end if;
 v_school:=nullif(p_data->>'school_code','');

 if p_action='routing_context' then
  if p_data<>'{}'::jsonb then raise sqlstate 'PT400' using message='invalid_request';end if;
  return jsonb_build_object(
   'schools',(select coalesce(jsonb_agg(to_jsonb(x) order by x.name),'[]') from (
    select s.code,s.name,s.is_active,
     (select count(*) from public.admission_routing_rules r where r.school_code=s.code and r.is_active) active_rules,
     exists(select 1 from private.mbn_routing_pick(s.code,null,null,null) chosen where chosen.user_id is not null) general_ready,
     (select count(*) from public.crm_applications a where a.school_code=s.code and not a.is_test
      and a.assigned_admissions_user is null and a.routing_status='UNASSIGNED' and a.status not in ('CLOSED','REJECTED','ENROLLED')) unassigned
    from public.schools s) x),
   'campuses',(select coalesce(jsonb_agg(jsonb_build_object('school_code',sc.school_code,'code',c.code,'name',c.name) order by c.name),'[]')
    from public.school_campuses sc join public.campuses c on c.code=sc.campus_code),
   'programs',(select coalesce(jsonb_agg(jsonb_build_object('id',p.id,'school_code',p.school_code,'name',p.name,'cycle',p.cycle) order by p.name),'[]') from public.school_programs p where p.is_active),
   'people',(select coalesce(jsonb_agg(jsonb_build_object('school_code',m.school_code,'id',p.user_id,'name',coalesce(nullif(p.full_name,''),p.email),'email',p.email) order by p.full_name,p.email),'[]')
    from public.school_memberships m join public.profiles p on p.user_id=m.user_id where private.mbn_ws_admissions_active(p.user_id,m.school_code)),
   'rules',(select coalesce(jsonb_agg(to_jsonb(x) order by x.school_code,x.priority desc,x.created_at,x.id),'[]') from (
    select r.*,s.name school_name,p.name program_name,c.name campus_name,
     coalesce(nullif(u.full_name,''),u.email) primary_name,coalesce(nullif(b.full_name,''),b.email) backup_name,
     private.mbn_ws_admissions_active(r.primary_user,r.school_code) primary_available,
     private.mbn_ws_admissions_active(r.backup_user,r.school_code) backup_available
    from public.admission_routing_rules r join public.schools s on s.code=r.school_code
     join public.profiles u on u.user_id=r.primary_user left join public.profiles b on b.user_id=r.backup_user
     left join public.school_programs p on p.id=r.program_id left join public.campuses c on c.code=r.campus_code) x));
 elsif p_action='routing_save' then
  if exists(select 1 from jsonb_object_keys(p_data) k where k not in ('id','expected_revision','school_code','program_id','campus_code','intake','priority','primary_user','backup_user'))
   or not exists(select 1 from public.schools where code=v_school and is_active)
   or coalesce(p_data->>'primary_user','') !~ v_uuid
   or (nullif(p_data->>'backup_user','') is not null and p_data->>'backup_user' !~ v_uuid)
   or (nullif(p_data->>'program_id','') is not null and p_data->>'program_id' !~ v_uuid)
   or (nullif(p_data->>'id','') is not null and (p_data->>'id' !~ v_uuid or coalesce(p_data->>'expected_revision','') !~ v_uuid))
   or coalesce(p_data->>'priority','0') !~ '^[0-9]{1,4}$' or length(coalesce(p_data->>'intake',''))>80
   then raise sqlstate 'PT422' using message='invalid_routing_rule';end if;
  v_primary:=(p_data->>'primary_user')::uuid;v_backup:=nullif(p_data->>'backup_user','')::uuid;v_program:=nullif(p_data->>'program_id','')::uuid;
  v_campus:=nullif(p_data->>'campus_code','');v_intake:=nullif(btrim(p_data->>'intake'),'');v_priority:=coalesce((p_data->>'priority')::integer,0);
  if v_priority>1000 or v_primary=v_backup then raise sqlstate 'PT422' using message='invalid_routing_rule';end if;
  if not private.mbn_ws_admissions_active(v_primary,v_school) or (v_backup is not null and not private.mbn_ws_admissions_active(v_backup,v_school)) then
   raise sqlstate 'PT422' using message='inactive_assignee';end if;
  if v_program is not null and not exists(select 1 from public.school_programs where id=v_program and school_code=v_school and is_active) then raise sqlstate 'PT422' using message='invalid_program';end if;
  if v_campus is not null and not exists(select 1 from public.school_campuses where school_code=v_school and campus_code=v_campus) then raise sqlstate 'PT422' using message='invalid_campus';end if;
  v_id:=nullif(p_data->>'id','')::uuid;
  if v_id is not null then
   select * into v_rule from public.admission_routing_rules where id=v_id for update;
   if not found then raise sqlstate 'PT404' using message='record_not_found';end if;
   if v_rule.revision is distinct from (p_data->>'expected_revision')::uuid then raise sqlstate 'PT409' using message='routing_changed';end if;
  end if;
  if exists(select 1 from public.admission_routing_rules r where r.id is distinct from v_id and r.school_code=v_school
   and r.program_id is not distinct from v_program and r.campus_code is not distinct from v_campus and r.intake is not distinct from v_intake and r.priority=v_priority) then
   raise sqlstate 'PT422' using message='routing_rule_exists';end if;
  if v_id is null then
   insert into public.admission_routing_rules(school_code,program_id,campus_code,intake,priority,primary_user,backup_user)
    values(v_school,v_program,v_campus,v_intake,v_priority,v_primary,v_backup) returning id into v_id;
  else
   update public.admission_routing_rules set school_code=v_school,program_id=v_program,campus_code=v_campus,intake=v_intake,priority=v_priority,primary_user=v_primary,backup_user=v_backup where id=v_id;
  end if;
  return jsonb_build_object('id',v_id);
 elsif p_action='routing_toggle' then
  if exists(select 1 from jsonb_object_keys(p_data) k where k not in ('id','expected_revision'))
   or coalesce(p_data->>'id','') !~ v_uuid or coalesce(p_data->>'expected_revision','') !~ v_uuid then raise sqlstate 'PT422' using message='invalid_routing_rule';end if;
  select * into v_rule from public.admission_routing_rules where id=(p_data->>'id')::uuid for update;
  if not found then raise sqlstate 'PT404' using message='record_not_found';end if;
  if v_rule.revision is distinct from (p_data->>'expected_revision')::uuid then raise sqlstate 'PT409' using message='routing_changed';end if;
  if not v_rule.is_active and not (private.mbn_ws_admissions_active(v_rule.primary_user,v_rule.school_code) or private.mbn_ws_admissions_active(v_rule.backup_user,v_rule.school_code)) then raise sqlstate 'PT422' using message='inactive_assignee';end if;
  update public.admission_routing_rules set is_active=not is_active where id=v_rule.id;
  return jsonb_build_object('success',true);
 elsif p_action='routing_reassign_preview' then
  if exists(select 1 from jsonb_object_keys(p_data) k where k<>'school_code') or (v_school is not null and not exists(select 1 from public.schools where code=v_school)) then raise sqlstate 'PT400' using message='invalid_request';end if;
  select count(*) into v_total from public.crm_applications a join public.schools s on s.code=a.school_code and s.is_active
   where not a.is_test and a.assigned_admissions_user is null and a.routing_status='UNASSIGNED' and a.status not in ('CLOSED','REJECTED','ENROLLED') and (v_school is null or a.school_code=v_school);
  select coalesce(jsonb_agg(to_jsonb(x) order by x.application_reference,x.id),'[]') into v_rows from (
   select a.id,a.application_reference,a.school_code,a.campus_code,p.name program_name,a.updated_at expected_updated_at,
    chosen.rule_id,chosen.rule_revision,chosen.user_id,coalesce(nullif(u.full_name,''),u.email) assignee_name
   from public.crm_applications a join public.schools s on s.code=a.school_code and s.is_active
    left join lateral private.mbn_routing_pick(a.school_code,a.program_id,a.campus_code,a.form_payload->>'intake') chosen on true
    left join public.profiles u on u.user_id=chosen.user_id left join public.school_programs p on p.id=a.program_id
   where not a.is_test and a.assigned_admissions_user is null and a.routing_status='UNASSIGNED' and a.status not in ('CLOSED','REJECTED','ENROLLED') and (v_school is null or a.school_code=v_school)
   order by (chosen.user_id is not null) desc,a.received_at,a.id limit 200) x;
  return jsonb_build_object('rows',v_rows,'total_unassigned',v_total,'has_more',v_total>jsonb_array_length(v_rows));
 else
  if exists(select 1 from jsonb_object_keys(p_data) k where k<>'rows') or jsonb_typeof(p_data->'rows') is distinct from 'array' then raise sqlstate 'PT400' using message='invalid_request';end if;
  if jsonb_array_length(p_data->'rows') not between 1 and 200 then raise sqlstate 'PT422' using message='invalid_routing_preview';end if;
  if (select count(distinct item->>'id') from jsonb_array_elements(p_data->'rows') item)<>jsonb_array_length(p_data->'rows') then raise sqlstate 'PT422' using message='invalid_routing_preview';end if;
  for v_item in select value from jsonb_array_elements(p_data->'rows') loop
   if jsonb_typeof(v_item) is distinct from 'object' or exists(select 1 from jsonb_object_keys(v_item) k where k not in ('id','expected_updated_at','rule_id','rule_revision','user_id'))
    or coalesce(v_item->>'id','') !~ v_uuid or coalesce(v_item->>'rule_id','') !~ v_uuid or coalesce(v_item->>'rule_revision','') !~ v_uuid or coalesce(v_item->>'user_id','') !~ v_uuid
    or jsonb_typeof(v_item->'expected_updated_at') is distinct from 'string' then raise sqlstate 'PT422' using message='invalid_routing_preview';end if;
   select a.* into v_app from public.crm_applications a join public.schools s on s.code=a.school_code and s.is_active
    where a.id=(v_item->>'id')::uuid and not a.is_test and a.assigned_admissions_user is null and a.routing_status='UNASSIGNED'
     and a.status not in ('CLOSED','REJECTED','ENROLLED') for update of a;
   if not found then v_skipped:=v_skipped+1;continue;end if;
   select * into v_pick from private.mbn_routing_pick(v_app.school_code,v_app.program_id,v_app.campus_code,v_app.form_payload->>'intake');
   if not found or v_pick.user_id is null or v_pick.rule_id::text is distinct from v_item->>'rule_id'
    or v_pick.rule_revision::text is distinct from v_item->>'rule_revision' or v_pick.user_id::text is distinct from v_item->>'user_id'
    or (to_jsonb(v_app.updated_at)#>>'{}') is distinct from v_item->>'expected_updated_at' then v_skipped:=v_skipped+1;continue;end if;
   update public.crm_applications set assigned_admissions_user=v_pick.user_id,routing_status='ASSIGNED',updated_at=now() where id=v_app.id;
   insert into public.crm_lead_events(lead_id,event_type,event_metadata) values(v_app.lead_id,'ASSIGNMENT_CHANGED',jsonb_build_object('application_id',v_app.id,'actor_id',p_actor,'previous',null,'assigned',v_pick.user_id,'routing_rule_id',v_pick.rule_id,'source','ROUTING_REVIEW'));
   v_assigned:=v_assigned+1;
  end loop;
  return jsonb_build_object('assigned',v_assigned,'skipped',v_skipped);
 end if;
end;$$;

revoke all on function private.mbn_routing_revision(),private.mbn_routing_pick(text,uuid,text,text),public.mbn_routing_action(uuid,uuid,text,jsonb) from public,anon,authenticated;
grant execute on function private.mbn_routing_revision(),private.mbn_routing_pick(text,uuid,text,text),public.mbn_routing_action(uuid,uuid,text,jsonb) to service_role;
