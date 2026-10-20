-- Meta credentials remain in Edge Function secrets. Only form routing and
-- authenticated notification identifiers are retained here.
create table private.mbn_meta_routes(
 id uuid primary key default gen_random_uuid(),page_id text not null check(page_id~'^[0-9]{5,30}$'),
 form_id text not null unique check(form_id~'^[0-9]{5,30}$'),label text not null,
 school_code text not null references public.schools(code),campus_code text references public.campuses(code),program_id uuid references public.school_programs(id),
 field_map jsonb not null,consent_field text not null default '',consent_value text not null default '',consent_statement text not null default '',
 enabled boolean not null default false,revision uuid not null default gen_random_uuid(),
 updated_by uuid not null references public.profiles(user_id),updated_at timestamptz not null default now()
);
create table private.mbn_meta_inbox(
 id uuid primary key default gen_random_uuid(),leadgen_id text not null unique check(leadgen_id~'^[0-9]{5,30}$'),
 page_id text not null,form_id text not null,route_id uuid references private.mbn_meta_routes(id),
 status text not null default 'UNMAPPED' check(status in ('UNMAPPED','PENDING','PROCESSING','RETRY','FAILED','IMPORTED','DUPLICATE')),
 attempts integer not null default 0 check(attempts between 0 and 5),attempt_id uuid,claimed_at timestamptz,available_at timestamptz not null default now(),
 revision uuid not null default gen_random_uuid(),error_code text,lead_id uuid references public.crm_leads(id),consent_evidence jsonb,
 received_at timestamptz not null default now(),updated_at timestamptz not null default now(),completed_at timestamptz
);
create index mbn_meta_inbox_due on private.mbn_meta_inbox(status,available_at,received_at);
create table private.mbn_meta_admin_events(
 id uuid primary key default gen_random_uuid(),actor_id uuid not null references public.profiles(user_id),
 action text not null,metadata jsonb not null,created_at timestamptz not null default now()
);
alter table private.mbn_meta_routes enable row level security;
alter table private.mbn_meta_inbox enable row level security;
alter table private.mbn_meta_admin_events enable row level security;
revoke all on private.mbn_meta_routes,private.mbn_meta_inbox,private.mbn_meta_admin_events from public,anon,authenticated;
grant select,insert,update on private.mbn_meta_routes,private.mbn_meta_inbox to service_role;
grant select,insert on private.mbn_meta_admin_events to service_role;

create function private.mbn_meta_route_ready(p_route private.mbn_meta_routes) returns boolean
language sql stable security invoker set search_path='' as $$
 select p_route.enabled and exists(select 1 from public.schools where code=p_route.school_code and is_active)
 and (p_route.campus_code is null or exists(select 1 from public.school_campuses where school_code=p_route.school_code and campus_code=p_route.campus_code))
 and (p_route.program_id is null or exists(select 1 from public.school_programs where id=p_route.program_id and school_code=p_route.school_code and is_active));
$$;
create function public.mbn_meta_admin_action(p_actor uuid,p_session uuid,p_action text,p_data jsonb default '{}') returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_ctx jsonb;v_route private.mbn_meta_routes;v_job private.mbn_meta_inbox;v_fields jsonb;v_school text;v_campus text;v_program uuid;v_id uuid;
begin
 v_ctx:=public.mbn_pin_context(p_actor,p_session,p_actor);
 if not coalesce((v_ctx->>'admin')::boolean,false) then raise sqlstate 'PT403' using message='access_denied';end if;
 if jsonb_typeof(p_data) is distinct from 'object' then raise sqlstate 'PT400' using message='invalid_request';end if;
 if p_action='context' then
  if p_data<>'{}'::jsonb then raise sqlstate 'PT400' using message='invalid_request';end if;
  return jsonb_build_object(
   'schools',(select coalesce(jsonb_agg(jsonb_build_object('code',code,'name',name,'is_active',is_active) order by name),'[]') from public.schools),
   'campuses',(select coalesce(jsonb_agg(jsonb_build_object('school_code',sc.school_code,'code',c.code,'name',c.name) order by c.name),'[]') from public.school_campuses sc join public.campuses c on c.code=sc.campus_code),
   'programs',(select coalesce(jsonb_agg(jsonb_build_object('id',id,'school_code',school_code,'name',name) order by name),'[]') from public.school_programs where is_active),
   'routes',(select coalesce(jsonb_agg(to_jsonb(r)||jsonb_build_object('ready',private.mbn_meta_route_ready(r)) order by r.label),'[]') from private.mbn_meta_routes r),
   'counts',(select coalesce(jsonb_object_agg(status,n),'{}') from (select status,count(*) n from private.mbn_meta_inbox group by status) x),
   'events',(select coalesce(jsonb_agg(to_jsonb(x) order by received_at desc,id desc),'[]') from (
    select id,leadgen_id,page_id,form_id,route_id,revision,status,attempts,error_code,lead_id,received_at,updated_at,completed_at
    from private.mbn_meta_inbox order by received_at desc,id desc limit 50) x));
 end if;
 perform pg_advisory_xact_lock(72519821);
 if p_action='save' then
  if exists(select 1 from jsonb_object_keys(p_data) k where k not in ('id','expected_revision','page_id','form_id','label','school_code','campus_code','program_id','field_map','consent_field','consent_value','consent_statement','enabled'))
   or exists(select 1 from jsonb_each(p_data) e where e.key in ('page_id','form_id','label','school_code','campus_code','program_id','consent_field','consent_value','consent_statement') and jsonb_typeof(e.value)<>'string')
   or coalesce(p_data->>'page_id','')!~'^[0-9]{5,30}$' or coalesce(p_data->>'form_id','')!~'^[0-9]{5,30}$'
   or length(btrim(coalesce(p_data->>'label',''))) not between 1 and 120 or coalesce(p_data->>'label','')~'[[:cntrl:]]' or jsonb_typeof(p_data->'enabled') is distinct from 'boolean'
   or jsonb_typeof(p_data->'field_map') is distinct from 'object' then raise sqlstate 'PT422' using message='invalid_meta_route';end if;
  v_school:=p_data->>'school_code';v_campus:=nullif(p_data->>'campus_code','');
  begin v_program:=nullif(p_data->>'program_id','')::uuid;v_id:=nullif(p_data->>'id','')::uuid;exception when others then raise sqlstate 'PT422' using message='invalid_meta_route';end;
  if not exists(select 1 from public.schools where code=v_school and is_active)
   or (v_campus is not null and not exists(select 1 from public.school_campuses where school_code=v_school and campus_code=v_campus))
   or (v_program is not null and not exists(select 1 from public.school_programs where id=v_program and school_code=v_school and is_active)) then raise sqlstate 'PT422' using message='invalid_meta_route';end if;
  v_fields:=p_data->'field_map';
  if exists(select 1 from jsonb_each(v_fields) e where e.key not in ('name','email','phone','country') or jsonb_typeof(e.value)<>'string'
    or length(e.value#>>'{}')>100 or (e.value#>>'{}')~'[[:cntrl:]]' or (e.value#>>'{}')<>btrim(e.value#>>'{}'))
   or length(coalesce(v_fields->>'name',''))<1 or length(coalesce(v_fields->>'email',''))<1
   or length(coalesce(p_data->>'consent_field',''))>100 or length(coalesce(p_data->>'consent_value',''))>160
   or length(coalesce(p_data->>'consent_statement',''))>300
   or coalesce(p_data->>'consent_field','')~'[[:cntrl:]]' or coalesce(p_data->>'consent_value','')~'[[:cntrl:]]'
   or (coalesce(p_data->>'consent_field','')='' and (coalesce(p_data->>'consent_value','')<>'' or coalesce(p_data->>'consent_statement','')<>''))
   or (coalesce(p_data->>'consent_field','')<>'' and (length(btrim(coalesce(p_data->>'consent_value','')))<1 or length(btrim(coalesce(p_data->>'consent_statement','')))<3))
   then raise sqlstate 'PT422' using message='invalid_meta_route';end if;
  if v_id is not null then
   select * into v_route from private.mbn_meta_routes where id=v_id;
   if not found or v_route.revision::text is distinct from p_data->>'expected_revision' then raise sqlstate 'PT409' using message='meta_route_changed';end if;
  end if;
  if exists(select 1 from private.mbn_meta_routes where form_id=p_data->>'form_id' and id is distinct from v_id) then raise sqlstate 'PT409' using message='meta_form_already_mapped';end if;
  insert into private.mbn_meta_routes(id,page_id,form_id,label,school_code,campus_code,program_id,field_map,consent_field,consent_value,consent_statement,enabled,updated_by)
   values(coalesce(v_id,gen_random_uuid()),p_data->>'page_id',p_data->>'form_id',btrim(p_data->>'label'),v_school,v_campus,v_program,v_fields,
    coalesce(p_data->>'consent_field',''),coalesce(p_data->>'consent_value',''),coalesce(p_data->>'consent_statement',''),(p_data->>'enabled')::boolean,p_actor)
   on conflict(id) do update set page_id=excluded.page_id,form_id=excluded.form_id,label=excluded.label,school_code=excluded.school_code,campus_code=excluded.campus_code,
    program_id=excluded.program_id,field_map=excluded.field_map,consent_field=excluded.consent_field,consent_value=excluded.consent_value,consent_statement=excluded.consent_statement,
    enabled=excluded.enabled,revision=gen_random_uuid(),updated_by=p_actor,updated_at=now() returning * into v_route;
  update private.mbn_meta_inbox set revision=gen_random_uuid(),route_id=v_route.id,status='PENDING',updated_at=now()
   where status='UNMAPPED' and page_id=v_route.page_id and form_id=v_route.form_id;
  insert into private.mbn_meta_admin_events(actor_id,action,metadata) values(p_actor,'ROUTE_SAVED',to_jsonb(v_route));
  return to_jsonb(v_route);
 elsif p_action='retry' then
  if exists(select 1 from jsonb_object_keys(p_data) k where k not in ('id','expected_revision')) then raise sqlstate 'PT400' using message='invalid_request';end if;
  select * into v_job from private.mbn_meta_inbox where id=(p_data->>'id')::uuid;
  if not found then raise sqlstate 'PT404' using message='record_not_found';end if;
  if v_job.status not in ('UNMAPPED','RETRY','FAILED') or v_job.revision::text is distinct from p_data->>'expected_revision' then raise sqlstate 'PT409' using message='meta_event_changed';end if;
  select * into v_route from private.mbn_meta_routes where form_id=v_job.form_id and page_id=v_job.page_id;
  if not found or not private.mbn_meta_route_ready(v_route) then raise sqlstate 'PT422' using message='meta_route_missing';end if;
  update private.mbn_meta_inbox set revision=gen_random_uuid(),status='PENDING',attempts=0,attempt_id=null,claimed_at=null,error_code=null,available_at=now(),route_id=v_route.id,updated_at=now()
   where id=v_job.id;
  insert into private.mbn_meta_admin_events(actor_id,action,metadata) values(p_actor,'EVENT_RETRIED',jsonb_build_object('id',v_job.id,'route_revision',v_route.revision));
  return jsonb_build_object('queued',true);
 end if;
 raise sqlstate 'PT400' using message='unknown_action';
end;$$;

create function public.mbn_meta_receive(p_events jsonb) returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_event jsonb;v_route private.mbn_meta_routes;v_job private.mbn_meta_inbox;v_inserted integer:=0;v_new boolean;
begin
 if jsonb_typeof(p_events) is distinct from 'array' then raise sqlstate 'PT400' using message='invalid_meta_event';end if;
 if jsonb_array_length(p_events)>100 then raise sqlstate 'PT400' using message='invalid_meta_event';end if;
 perform pg_advisory_xact_lock(72519821);
 for v_event in select value from jsonb_array_elements(p_events) loop
  if jsonb_typeof(v_event)<>'object' or coalesce(v_event->>'page_id','')!~'^[0-9]{5,30}$' or coalesce(v_event->>'form_id','')!~'^[0-9]{5,30}$'
   or coalesce(v_event->>'leadgen_id','')!~'^[0-9]{5,30}$' then raise sqlstate 'PT400' using message='invalid_meta_event';end if;
  select * into v_route from private.mbn_meta_routes where page_id=v_event->>'page_id' and form_id=v_event->>'form_id';
  insert into private.mbn_meta_inbox(leadgen_id,page_id,form_id,route_id,status)
   values(v_event->>'leadgen_id',v_event->>'page_id',v_event->>'form_id',v_route.id,case when v_route.id is null then 'UNMAPPED' else 'PENDING' end)
   on conflict(leadgen_id) do nothing;
  v_new:=found;if v_new then v_inserted:=v_inserted+1;end if;
  select * into v_job from private.mbn_meta_inbox where leadgen_id=v_event->>'leadgen_id';
  if v_job.page_id<>v_event->>'page_id' or v_job.form_id<>v_event->>'form_id' then raise sqlstate 'PT400' using message='invalid_meta_event';end if;
 end loop;
 return jsonb_build_object('received',jsonb_array_length(p_events),'created',v_inserted);
end;$$;
create function public.mbn_meta_claim() returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_job private.mbn_meta_inbox;v_route private.mbn_meta_routes;
begin
 perform pg_advisory_xact_lock(72519821);
 update private.mbn_meta_inbox set revision=gen_random_uuid(),status=case when attempts>=5 then 'FAILED' else 'RETRY' end,error_code='meta_processing_interrupted',available_at=now(),updated_at=now()
  where status='PROCESSING' and claimed_at<now()-interval '90 seconds';
 select i.* into v_job from private.mbn_meta_inbox i join private.mbn_meta_routes r on r.id=i.route_id and r.page_id=i.page_id and r.form_id=i.form_id
  where i.status in ('PENDING','RETRY') and i.attempts<5 and i.available_at<=now() and private.mbn_meta_route_ready(r)
  order by i.available_at,i.received_at,i.id limit 1 for update of i skip locked;
 if not found then return null;end if;
 select * into v_route from private.mbn_meta_routes where id=v_job.route_id;
 update private.mbn_meta_inbox set revision=gen_random_uuid(),status='PROCESSING',attempts=attempts+1,attempt_id=gen_random_uuid(),claimed_at=now(),updated_at=now() where id=v_job.id returning * into v_job;
 return jsonb_build_object('id',v_job.id,'page_id',v_job.page_id,'form_id',v_job.form_id,'leadgen_id',v_job.leadgen_id,'attempt_id',v_job.attempt_id,'route_revision',v_route.revision);
end;$$;
create function private.mbn_meta_scalar(p_fields jsonb,p_key text) returns text
language plpgsql immutable security invoker set search_path='' as $$
begin
 if coalesce(p_key,'')='' or jsonb_typeof(p_fields->p_key) is distinct from 'array' then return null;end if;
 if jsonb_array_length(p_fields->p_key)<>1 or jsonb_typeof(p_fields->p_key->0)<>'string' then return null;end if;
 return nullif(btrim(p_fields->p_key->>0),'');
end;$$;
create function public.mbn_meta_finish(p_id uuid,p_attempt uuid,p_revision uuid,p_lead jsonb,p_error text default null,p_retryable boolean default false) returns jsonb
language plpgsql security invoker set search_path='' as $$
declare v_job private.mbn_meta_inbox;v_route private.mbn_meta_routes;v_lead public.crm_leads;v_fields jsonb;v_name text;v_email text;v_phone text;v_country text;
 v_created timestamptz;v_consent boolean;v_withdrawn boolean;v_suppressed boolean;v_id uuid;v_count integer;v_error text:=p_error;v_retry boolean:=p_retryable;v_evidence jsonb;
begin
 perform pg_advisory_xact_lock(72519821);
 select * into v_job from private.mbn_meta_inbox where id=p_id for update;
 if not found or v_job.status<>'PROCESSING' or v_job.attempt_id is distinct from p_attempt or v_job.claimed_at<now()-interval '90 seconds' then return jsonb_build_object('status','STALE');end if;
 select * into v_route from private.mbn_meta_routes where id=v_job.route_id;
 if not found or v_route.revision is distinct from p_revision or not private.mbn_meta_route_ready(v_route) or v_route.page_id<>v_job.page_id or v_route.form_id<>v_job.form_id then
  v_error:='meta_route_changed';v_retry:=false;
 elsif v_error is null then
  if jsonb_typeof(p_lead) is distinct from 'object' or p_lead->>'id' is distinct from v_job.leadgen_id or p_lead->>'form_id' is distinct from v_job.form_id
   or jsonb_typeof(p_lead->'fields') is distinct from 'object' then v_error:='meta_identity_mismatch';v_retry:=false;
  else
   v_fields:=p_lead->'fields';v_name:=private.mbn_meta_scalar(v_fields,v_route.field_map->>'name');
   if v_name is null and v_route.field_map->>'name'='full_name' then v_name:=nullif(btrim(concat_ws(' ',private.mbn_meta_scalar(v_fields,'first_name'),private.mbn_meta_scalar(v_fields,'last_name'))),'');end if;
   v_email:=lower(private.mbn_meta_scalar(v_fields,v_route.field_map->>'email'));v_phone:=private.mbn_meta_scalar(v_fields,v_route.field_map->>'phone');v_country:=private.mbn_meta_scalar(v_fields,v_route.field_map->>'country');
   begin v_created:=(p_lead->>'created_time')::timestamptz;exception when others then v_created:=null;end;
   if coalesce(length(v_name),0) not between 2 and 200 or coalesce(length(v_email),0) not between 5 and 254
    or v_email!~'^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' or length(coalesce(v_phone,''))>50 or length(coalesce(v_country,''))>100
    or v_created is null or v_created<date '2004-01-01' or v_created>now()+interval '1 day' then v_error:='meta_required_fields_missing';v_retry:=false;end if;
  end if;
 end if;
 if v_error is not null then
  if v_error!~'^[a-z_]{3,80}$' then v_error:='meta_processing_failed';end if;
  update private.mbn_meta_inbox set revision=gen_random_uuid(),status=case when coalesce(v_retry,false) and attempts<5 then 'RETRY' else 'FAILED' end,error_code=v_error,
   available_at=now()+make_interval(mins=>case attempts when 1 then 1 when 2 then 5 when 3 then 15 else 60 end),updated_at=now()
   where id=p_id returning * into v_job;
  return jsonb_build_object('status',v_job.status,'error_code',v_error);
 end if;
 select * into v_lead from public.crm_leads where source='META_LEAD' and source_external_id=v_job.leadgen_id;
 if found then
  if v_lead.school_code<>v_route.school_code or v_lead.is_test then
   update private.mbn_meta_inbox set revision=gen_random_uuid(),status='FAILED',error_code='meta_source_conflict',updated_at=now() where id=p_id;
   return jsonb_build_object('status','FAILED');end if;
  update private.mbn_meta_inbox set revision=gen_random_uuid(),status='DUPLICATE',lead_id=v_lead.id,completed_at=now(),updated_at=now(),error_code=null where id=p_id;
  return jsonb_build_object('status','DUPLICATE');
 end if;
 select count(*),(array_agg(id order by created_at,id))[1] into v_count,v_id from public.crm_leads where school_code=v_route.school_code and lower(email)=v_email and not is_test;
 if v_count>0 then
  update private.mbn_meta_inbox set revision=gen_random_uuid(),status='DUPLICATE',lead_id=case when v_count=1 then v_id end,completed_at=now(),updated_at=now(),error_code=null where id=p_id;
  return jsonb_build_object('status','DUPLICATE');end if;
 v_consent:=v_route.consent_field<>'' and private.mbn_meta_scalar(v_fields,v_route.consent_field)=v_route.consent_value;
 v_consent:=coalesce(v_consent,false);
 select exists(select 1 from public.crm_leads where lower(email)=v_email and not is_test and (unsubscribed_at is not null or status='UNSUBSCRIBED')),
  exists(select 1 from public.crm_leads where lower(email)=v_email and not is_test and email_suppressed_at is not null) into v_withdrawn,v_suppressed;
 v_evidence:=jsonb_build_object('form_id',v_job.form_id,'field',v_route.consent_field,'expected_value',v_route.consent_value,
  'received_value',private.mbn_meta_scalar(v_fields,v_route.consent_field),'statement',v_route.consent_statement,'meta_created_at',v_created,
  'matched',v_consent,'effective',v_consent and not v_withdrawn and not v_suppressed);
 v_consent:=v_consent and not v_withdrawn and not v_suppressed;
 insert into public.crm_leads(school_code,campus_code,program_id,source,source_external_id,full_name,email,phone,country_of_residence,
  consent_email,consent_recorded_at,consent_source,status,unsubscribed_at,email_suppressed_at,email_suppression_reason)
 values(v_route.school_code,v_route.campus_code,v_route.program_id,'META_LEAD',v_job.leadgen_id,v_name,v_email,v_phone,v_country,v_consent,
  case when v_consent then v_created end,case when v_consent then left('Meta formulaire '||v_job.form_id||' : '||v_route.consent_statement,300) end,
  case when v_withdrawn then 'UNSUBSCRIBED' else 'NEW' end,case when v_withdrawn then now() end,
  case when v_suppressed then now() end,case when v_suppressed then 'META_EXISTING_SUPPRESSION' end) returning id into v_id;
 insert into public.crm_lead_events(lead_id,event_type,event_metadata) values(v_id,'LEAD_CREATED',jsonb_build_object('via','META_WEBHOOK','meta_event_id',v_job.id,'form_id',v_job.form_id,'consent_email',v_consent));
 update private.mbn_meta_inbox set revision=gen_random_uuid(),status='IMPORTED',lead_id=v_id,consent_evidence=v_evidence,completed_at=now(),updated_at=now(),error_code=null where id=p_id;
 return jsonb_build_object('status','IMPORTED');
end;$$;

revoke all on function private.mbn_meta_route_ready(private.mbn_meta_routes),private.mbn_meta_scalar(jsonb,text),public.mbn_meta_admin_action(uuid,uuid,text,jsonb),
 public.mbn_meta_receive(jsonb),public.mbn_meta_claim(),public.mbn_meta_finish(uuid,uuid,uuid,jsonb,text,boolean) from public,anon,authenticated;
grant execute on function private.mbn_meta_route_ready(private.mbn_meta_routes),private.mbn_meta_scalar(jsonb,text),public.mbn_meta_admin_action(uuid,uuid,text,jsonb),
 public.mbn_meta_receive(jsonb),public.mbn_meta_claim(),public.mbn_meta_finish(uuid,uuid,uuid,jsonb,text,boolean) to service_role;

create function private.mbn_meta_tick() returns void language plpgsql security definer set search_path='' as $$
begin
 if not exists(select 1 from private.mbn_meta_inbox i join private.mbn_meta_routes r on r.id=i.route_id where private.mbn_meta_route_ready(r)
  and ((i.status in ('PENDING','RETRY') and i.available_at<=now() and i.attempts<5) or (i.status='PROCESSING' and i.claimed_at<now()-interval '90 seconds'))) then return;end if;
 execute 'select net.http_post(url:=$1,headers:=$2,body:=$3,timeout_milliseconds:=55000)'
 using 'https://ppqeuluykiknuujfaoid.supabase.co/functions/v1/mbn-meta',jsonb_build_object('Content-Type','application/json','x-mbn-worker',private.mbn_runtime_secret('worker')),'{}'::jsonb;
end;$$;
revoke all on function private.mbn_meta_tick() from public,anon,authenticated,service_role;
do $$begin
 if exists(select 1 from pg_extension where extname='pg_cron') and exists(select 1 from pg_extension where extname='pg_net') then
  execute 'select cron.schedule(''mbn-meta-due'',''* * * * *'',''select private.mbn_meta_tick();'')';end if;
end;$$;
