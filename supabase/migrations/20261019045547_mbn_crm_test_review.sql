create function public.mbn_workspace_tests(p_actor uuid,p_session uuid,p_kind text,p_data jsonb default '{}')
returns jsonb language plpgsql security invoker set search_path='' as $$
declare v_ctx jsonb;v_school text;v_query text;v_status text;v_offset integer;v_total integer;v_rows jsonb;
begin
 v_ctx:=public.mbn_pin_context(p_actor,p_session,p_actor);
 if coalesce((v_ctx->>'admin')::boolean,false) is not true then raise sqlstate 'PT403' using message='access_denied';end if;
 v_school:=nullif(p_data->>'school_code','');v_query:=left(coalesce(p_data->>'search',''),120);v_status:=nullif(p_data->>'status','');v_offset:=greatest(0,least(100000,coalesce((p_data->>'offset')::integer,0)));
 if p_kind='LEADS' then
  select count(*) into v_total from public.crm_leads l where l.is_test and (v_school is null or l.school_code=v_school) and (v_status is null or l.status=v_status) and (v_query='' or l.full_name ilike '%'||v_query||'%' or l.email ilike '%'||v_query||'%');
  select coalesce(jsonb_agg(to_jsonb(x)),'[]') into v_rows from (select l.* from public.crm_leads l where l.is_test and (v_school is null or l.school_code=v_school) and (v_status is null or l.status=v_status) and (v_query='' or l.full_name ilike '%'||v_query||'%' or l.email ilike '%'||v_query||'%') order by l.created_at desc,l.id limit 50 offset v_offset) x;
 elsif p_kind='APPLICATIONS' then
  select count(*) into v_total from public.crm_applications a join public.crm_leads l on l.id=a.lead_id where a.is_test and (v_school is null or a.school_code=v_school) and (v_status is null or a.status=v_status) and (v_query='' or l.full_name ilike '%'||v_query||'%' or a.application_reference ilike '%'||v_query||'%');
  select coalesce(jsonb_agg(to_jsonb(x)),'[]') into v_rows from (select a.id,a.lead_id,a.school_code,a.campus_code,a.program_id,a.application_reference,a.admission_type,a.status,a.received_at,a.updated_at,a.routing_status,a.assigned_admissions_user,a.is_test,l.full_name,l.email,p.name as program_name,pr.full_name as assignee_name
   from public.crm_applications a join public.crm_leads l on l.id=a.lead_id left join public.school_programs p on p.id=a.program_id left join public.profiles pr on pr.user_id=a.assigned_admissions_user
   where a.is_test and (v_school is null or a.school_code=v_school) and (v_status is null or a.status=v_status) and (v_query='' or l.full_name ilike '%'||v_query||'%' or a.application_reference ilike '%'||v_query||'%') order by a.received_at desc,a.id limit 50 offset v_offset) x;
 else raise sqlstate 'PT400' using message='unknown_action';end if;
 return jsonb_build_object('total',v_total,'rows',v_rows,'test_mode',true);
end;$$;
revoke all on function public.mbn_workspace_tests(uuid,uuid,text,jsonb) from public,anon,authenticated;
grant execute on function public.mbn_workspace_tests(uuid,uuid,text,jsonb) to service_role;
