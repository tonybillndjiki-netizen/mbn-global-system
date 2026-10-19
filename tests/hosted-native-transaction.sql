-- Development project only. No Storage objects are written through SQL.
-- Every synthetic CRM record below is rolled back.
begin;
set local role service_role;
do $native$
declare
  v_actor uuid;
  v_program public.school_programs%rowtype;
  v_payload jsonb;
  v_draft jsonb;
  v_result jsonb;
  v_pending boolean := false;
begin
  select user_id into strict v_actor from public.profiles
    where email='nbtonybill@gmail.com' and is_active;
  select p.* into strict v_program from public.school_programs p
    join public.schools s on s.code=p.school_code and s.is_active
    where p.school_code='EVRY BTS' and p.is_active order by p.id limit 1;
  v_payload:=jsonb_build_object('event','application_submitted',
    'reference_dossier','MBNTEST-50000000-0000-4000-8000-000000009901',
    'email','qa-native-transaction@example.invalid','full_name','QA Native Synthetic',
    'school_code','EVRY BTS','campus_code','EVRY','country_of_residence','Cameroun',
    'program_id',v_program.id,'program_name',v_program.name,
    'cycle',coalesce(v_program.cycle,''),'academic_level',coalesce(v_program.academic_level,''),
    'domain',coalesce(v_program.domain,''),'pace',coalesce(v_program.pace,''),
    'source','DIRECT','consent_email',false);
  v_draft:=public.mbn_prepare_native_test(v_actor,v_payload,'{}',
    jsonb_build_array(jsonb_build_object('kind','CV','original_name','synthetic.pdf',
      'mime_type','application/pdf','extension','pdf','byte_size',100,'sha256',repeat('a',64))),repeat('b',64));
  begin
    perform public.mbn_complete_native_test(v_actor,(v_draft->>'submission_id')::uuid);
  exception when sqlstate 'PT409' then v_pending:=true;
  end;
  if not v_pending then raise exception 'Missing files were accepted';end if;
  if exists(select 1 from public.crm_applications where application_reference=v_payload->>'reference_dossier') then
    raise exception 'Pending files created a premature application';
  end if;
  v_payload:=jsonb_set(v_payload,'{reference_dossier}','"MBNTEST-50000000-0000-4000-8000-000000009902"');
  v_draft:=public.mbn_prepare_native_test(v_actor,v_payload,'{}','[]',repeat('c',64));
  v_result:=public.mbn_complete_native_test(v_actor,(v_draft->>'submission_id')::uuid);
  if v_result->>'success'<>'true' or v_result->>'test'<>'true' then raise exception 'Native receipt invalid';end if;
  if not exists(select 1 from public.crm_applications a join public.crm_leads l on l.id=a.lead_id
    where a.id=(v_result->>'application_id')::uuid and a.is_test and l.is_test
      and a.source_system='MBN_SUPABASE_NATIVE_TEST' and a.admission_type='INTERNATIONAL'
      and a.program_id=v_program.id and a.school_code='EVRY BTS' and a.campus_code='EVRY') then
    raise exception 'Native test did not preserve its school/program/environment';
  end if;
  v_result:=public.mbn_complete_native_test(v_actor,(v_draft->>'submission_id')::uuid);
  if v_result->>'duplicated'<>'true' then raise exception 'Replay created a new application';end if;
  if (select count(*) from public.crm_applications where application_reference=v_payload->>'reference_dossier')<>1 then
    raise exception 'Duplicate native application';
  end if;
end;$native$;
reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','90000000-0000-4000-8000-000000000001',true);
do $rls$
begin
  if exists(select 1 from public.native_test_submissions)
    or exists(select 1 from public.crm_applications where is_test)
    or exists(select 1 from public.application_documents) then
    raise exception 'Native test data leaked to an unauthorized identity';
  end if;
end;$rls$;
reset role;
rollback;
select jsonb_build_object('native_transaction_checks','passed; fixtures rolled back',
  'native_submissions_remaining',(select count(*) from public.native_test_submissions),
  'test_applications_remaining',(select count(*) from public.crm_applications where is_test),
  'private_bucket',(select not public from storage.buckets where id='mbn-native-test')) as validation;
