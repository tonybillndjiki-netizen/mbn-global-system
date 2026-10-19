-- Run only on the dedicated development project. All fixtures roll back.
do $test$
declare
  v_program public.school_programs%rowtype;
  v_payload jsonb;
  v_reply jsonb;
  v_ref text := 'QA-'||replace(gen_random_uuid()::text,'-','');
  v_email text := 'qa-'||replace(gen_random_uuid()::text,'-','')||'@example.invalid';
  v_lead uuid;
  v_count integer;
begin
  begin
    if has_function_privilege('anon','public.mbn_ingest_application(jsonb)','EXECUTE')
      or has_function_privilege('authenticated','public.mbn_ingest_application(jsonb)','EXECUTE')
      or not has_function_privilege('service_role','public.mbn_ingest_application(jsonb)','EXECUTE') then
      raise exception 'RPC grants do not match the server-only contract';
    end if;
    select * into strict v_program from public.school_programs
      where school_code='MLV BTS' and is_active order by id limit 1;
    v_payload:=jsonb_build_object('event','application_submitted','reference_dossier',v_ref,
      'email',v_email,'full_name','Candidat de test temporaire','school_code','MLV BTS',
      'campus_code','NOISIEL','country_of_residence','France','program_id',v_program.id,
      'program_name',v_program.name,'cycle',coalesce(v_program.cycle,''),
      'domain',coalesce(v_program.domain,''),'academic_level',coalesce(v_program.academic_level,''),
      'pace','Initial','source','DIRECT','consent_email',false);
    set local role service_role;
    v_reply:=public.mbn_ingest_application(v_payload);
    if v_reply->>'duplicated'<>'false' then raise exception 'First receipt was not inserted';end if;
    v_reply:=public.mbn_ingest_application(v_payload);
    if v_reply->>'duplicated'<>'true' then raise exception 'Replay was not acknowledged';end if;
    reset role;
    select count(*) into v_count from public.crm_applications where application_reference=v_ref;
    if v_count<>1 then raise exception 'Application duplicate';end if;
    select count(*) into v_count from public.crm_leads where email=v_email;
    if v_count<>1 then raise exception 'Prospect duplicate';end if;
    select count(*) into v_count from public.crm_lead_events where event_metadata->>'reference'=v_ref;
    if v_count<>1 then raise exception 'Event duplicate';end if;
    begin
      perform public.mbn_ingest_application(v_payload||jsonb_build_object('program_id',
        (select id from public.school_programs where school_code='EVRY BTS' order by id limit 1)));
      raise exception 'Replay with another program id was accepted';
    exception when sqlstate 'PT409' then null;end;
    begin
      perform public.mbn_ingest_application(v_payload||jsonb_build_object('email','other@example.invalid'));
      raise exception 'Conflicting reference was accepted';
    exception when sqlstate 'PT409' then null;end;
    begin
      perform public.mbn_ingest_application(v_payload||jsonb_build_object('reference_dossier',v_ref||'-WRONG','campus_code','LYON'));
      raise exception 'Wrong campus was accepted';
    exception when sqlstate 'PT422' then null;end;

    -- Preserve acquisition and opt out when a pre-existing prospect submits.
    v_ref:=v_ref||'-META';v_email:='meta-'||v_email;
    insert into public.crm_leads(school_code,source,source_external_id,full_name,email,status,consent_email,unsubscribed_at)
      values('MLV BTS','META_LEAD',v_ref,'Candidat de test temporaire',v_email,'UNSUBSCRIBED',false,now()) returning id into v_lead;
    insert into public.crm_outreach_queue(lead_id,sequence_type,attempt_number,scheduled_at,status) values
      (v_lead,'META_UNCLICKED',0,now(),'PENDING'),(v_lead,'META_UNCLICKED',1,now(),'FAILED'),
      (v_lead,'CLICKED_NOT_SUBMITTED',0,now(),'PENDING'),(v_lead,'META_UNCLICKED',2,now(),'SENT');
    v_payload:=v_payload||jsonb_build_object('reference_dossier',v_ref,'email',v_email,'consent_email',true);
    set local role service_role;
    v_reply:=public.mbn_ingest_application(v_payload);
    reset role;
    if (v_reply->>'outreach_canceled')::integer<>3 then raise exception 'Both pending sequences were not canceled';end if;
    if not exists(select 1 from public.crm_leads where id=v_lead and source='META_LEAD'
      and source_external_id=v_ref and status='UNSUBSCRIBED' and not consent_email and submitted_at is not null) then
      raise exception 'Original attribution or opt out was overwritten';
    end if;
    if not exists(select 1 from public.crm_outreach_queue where lead_id=v_lead and status='SENT') then
      raise exception 'Historical sent receipt was modified';
    end if;

    select * into strict v_program from public.school_programs
      where school_code='EMSP' and name='Bachelor Achats et Logistique' and is_active order by id limit 1;
    v_payload:=v_payload||jsonb_build_object('reference_dossier',v_ref||'-EMSP',
      'school_code','EMSP','campus_code','TORCY','program_id','',
      'program_name',v_program.name,'cycle',v_program.cycle,'domain',v_program.domain,'academic_level','');
    begin
      perform public.mbn_ingest_application(v_payload);
      raise exception 'Ambiguous academic level was accepted';
    exception when sqlstate 'PT422' then null;end;
    v_payload:=v_payload||jsonb_build_object('academic_level',v_program.academic_level);
    set local role service_role;
    perform public.mbn_ingest_application(v_payload);
    reset role;
    if not exists(select 1 from public.crm_applications where application_reference=v_ref||'-EMSP' and program_id=v_program.id) then
      raise exception 'Exact curriculum combination was not retained';
    end if;

    select * into strict v_program from public.school_programs
      where school_code='CESCOM' and is_active order by id limit 1;
    v_payload:=v_payload||jsonb_build_object('reference_dossier',v_ref||'-CESCOM',
      'school_code','CESCOM PARIS','campus_code','PARIS','program_id',v_program.id,
      'program_name',v_program.name,'cycle',coalesce(v_program.cycle,''),
      'domain',coalesce(v_program.domain,''),'academic_level',coalesce(v_program.academic_level,''),
      'country_of_residence','Cameroun');
    set local role service_role;
    perform public.mbn_ingest_application(v_payload);
    reset role;
    if not exists(select 1 from public.crm_applications where application_reference=v_ref||'-CESCOM'
      and school_code='CESCOM' and campus_code='NOISIEL' and admission_type='INTERNATIONAL') then
      raise exception 'CESCOM alias or international residence failed';
    end if;
    -- Roll back the entire inner block, including every synthetic row above.
    raise sqlstate 'Z0001' using message='rollback_successful_test_fixtures';
  exception when sqlstate 'Z0001' then null;
  end;
end;
$test$;
select jsonb_build_object(
  'hosted_transaction_validation','passed',
  'leads',(select count(*) from public.crm_leads),
  'applications',(select count(*) from public.crm_applications),
  'outreach',(select count(*) from public.crm_outreach_queue),
  'schools',(select count(*) from public.schools),
  'programs',(select count(*) from public.school_programs)
) as validation;
