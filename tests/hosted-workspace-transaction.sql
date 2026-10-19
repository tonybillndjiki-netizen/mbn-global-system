-- Hosted integration verification. All synthetic CRM and Storage metadata roll back.
-- No provider request, email or real document is involved.
begin;
create temporary table mbn_workspace_qa_report(result jsonb);
grant insert,select on mbn_workspace_qa_report to service_role;
set local role service_role;
do $$
declare
 v_actor uuid:='2ff99980-92ce-4cb0-80c0-c3903b76fdee';v_session uuid;v_lead uuid;v_campaign uuid;v_link uuid;v_submission uuid;v_app uuid;
 v_result jsonb;v_payload jsonb;v_manifest jsonb;v_doc jsonb;v_program public.school_programs;
 v_email text:='qa-'||gen_random_uuid()::text||'@example.invalid';v_before_leads bigint;v_before_apps bigint;
begin
 select id into v_session from auth.sessions where user_id=v_actor order by created_at desc limit 1;
 if v_session is null then raise exception 'A real owner session is required for this check';end if;
 select count(*) into v_before_leads from public.crm_leads;
 select count(*) into v_before_apps from public.crm_applications;
 v_result:=public.mbn_workspace_action(v_actor,v_session,'lead_save',jsonb_build_object('school_code','MLV BTS','full_name','SYNTHETIC QA · MBN','email',v_email,'source','META_LEAD','consent_email',true,'consent_source','Synthetic integration fixture'));
 v_lead:=(v_result->>'id')::uuid;
 v_result:=public.mbn_workspace_action(v_actor,v_session,'campaign_save','{"school_code":"MLV BTS","name":"SYNTHETIC QA · transaction only","subject":"Synthetic integration","body":"Synthetic integration"}'::jsonb);
 v_campaign:=(v_result->>'id')::uuid;
 v_result:=public.mbn_workspace_action(v_actor,v_session,'campaign_launch',jsonb_build_object('id',v_campaign));
 if (v_result->>'messages')::integer<>4 then raise exception 'Expected exactly four scheduled messages';end if;
 v_result:=public.mbn_mail_link(v_lead);v_link:=(v_result->>'id')::uuid;
 perform public.mbn_candidate_context(v_link,'info');
 if (select clicked_at is not null from public.crm_leads where id=v_lead) then raise exception 'Info must not confirm engagement';end if;
 perform public.mbn_candidate_context(v_link,'engage');
 if exists(select 1 from public.mail_messages where lead_id=v_lead and status='QUEUED') then raise exception 'Engagement must cancel pending marketing';end if;
 select * into v_program from public.school_programs where school_code='MLV BTS' and is_active order by id limit 1;
 v_payload:=jsonb_build_object('event','application_submitted','reference_dossier','MBNAPP-'||v_link::text,'school_code','MLV BTS','campus_code','NOISIEL',
  'program_id',v_program.id,'program_name',v_program.name,'cycle',coalesce(v_program.cycle,''),'academic_level',coalesce(v_program.academic_level,''),'domain',coalesce(v_program.domain,''),'pace',coalesce(v_program.pace,''),
  'full_name','SYNTHETIC QA · MBN','email',v_email,'country_of_residence','Cameroun','source','DIRECT','consent_email',false);
 select jsonb_agg(jsonb_build_object('kind',kind,'original_name',kind||'.pdf','mime_type','application/pdf','extension','pdf','byte_size',20,'sha256',repeat('a',64))) into v_manifest from unnest(array['CV','DIPLOME','PIECE_IDENTITE']) kind;
 v_result:=public.mbn_candidate_prepare(v_link,v_payload,'{}',v_manifest,repeat('b',64));v_submission:=(v_result->>'submission_id')::uuid;
 for v_doc in select value from jsonb_array_elements(v_manifest) loop
  insert into storage.objects(bucket_id,name,metadata) values('mbn-admissions',v_submission::text||'/'||(v_doc->>'kind')||'.pdf','{"size":20,"mimetype":"application/pdf"}');
 end loop;
 v_result:=public.mbn_candidate_complete(v_link,v_submission);v_app:=(v_result->>'application_id')::uuid;
 if (v_result->>'document_count')::integer<>3 then raise exception 'Expected three private document records';end if;
 v_result:=public.mbn_candidate_complete(v_link,v_submission);
 if (v_result->>'duplicated')::boolean is not true then raise exception 'Replay was not acknowledged';end if;
 for v_doc in select jsonb_build_object('id',id) from public.application_documents where application_id=v_app loop
  perform public.mbn_workspace_action(v_actor,v_session,'document_review',jsonb_build_object('id',v_app,'document_id',v_doc->>'id','review_status','APPROVED','note','Synthetic integration check'));
 end loop;
 perform public.mbn_workspace_action(v_actor,v_session,'application_transition',jsonb_build_object('id',v_app,'expected_status','RECEIVED','status','IN_REVIEW'));
 perform public.mbn_workspace_action(v_actor,v_session,'application_transition',jsonb_build_object('id',v_app,'expected_status','IN_REVIEW','status','COMPLETE'));
 perform public.mbn_workspace_action(v_actor,v_session,'application_transition',jsonb_build_object('id',v_app,'expected_status','COMPLETE','status','READY_FOR_DECISION'));
 perform public.mbn_workspace_action(v_actor,v_session,'application_transition',jsonb_build_object('id',v_app,'expected_status','READY_FOR_DECISION','status','ADMITTED','note','Synthetic test only; transaction rolled back'));
 v_result:=public.mbn_workspace_action(v_actor,v_session,'application_detail',jsonb_build_object('id',v_app));
 if v_result->'application'->>'status'<>'ADMITTED' then raise exception 'CRM transition did not commit inside the transaction';end if;
 if (select count(*) from public.crm_leads)<>v_before_leads+1 or (select count(*) from public.crm_applications)<>v_before_apps+1 then raise exception 'Unexpected duplicate record';end if;
 insert into mbn_workspace_qa_report values(jsonb_build_object('passed',true,'prospect_created',true,'scheduled_steps',4,'scanner_visit_does_not_engage',true,'engagement_stops_outreach',true,'private_document_records',3,'replay_deduplicated',true,'crm_review_and_decision',true,'rollback',true,'emails_sent',0));
end;$$;
select result from mbn_workspace_qa_report;
rollback;
