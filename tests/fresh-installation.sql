-- Run by CI against a disposable local Supabase stack after db reset --local.
\set ON_ERROR_STOP on
begin;
do $$begin
 if (select count(*) from public.schools)<>19 or (select count(*) from public.school_programs)<>1275 then raise exception 'catalog_incomplete';end if;
 if exists(select 1 from private.admin_allowlist) or exists(select 1 from public.school_programs where is_active) then raise exception 'unexpected_activation';end if;
 if exists(select 1 from private.mbn_mail_settings where enabled) then raise exception 'mail_enabled';end if;
 if exists(select 1 from private.mbn_scan_settings where enabled) then raise exception 'scanner_enabled';end if;
 if (select count(*) from private.mbn_runtime_secrets r join vault.decrypted_secrets d on d.id=r.vault_id)<>3 then raise exception 'vault_incomplete';end if;
 if (select count(*) from cron.job where jobname in ('mbn-mail-due','mbn-meta-due','mbn-antivirus-due'))<>3 then raise exception 'scheduler_incomplete';end if;
 if (select count(*) from storage.buckets where id in ('mbn-native-test','mbn-admissions','mbn-mail-assets','mbn-admission-letters') and not public)<>4 then raise exception 'private_bucket_missing_or_exposed';end if;
 if has_function_privilege('anon','public.mbn_installation_bootstrap_owner(text)','execute') or has_function_privilege('authenticated','public.mbn_installation_configure(text,text,text)','execute') then raise exception 'installation_rpc_exposed';end if;
 perform private.mbn_scan_tick();perform private.mbn_mail_tick();perform private.mbn_meta_tick();
end;$$;
rollback;

-- PGlite does not ship the hosted safeupdate library. Exercise both reset paths
-- on the disposable Supabase database with the real protection loaded.
load 'safeupdate';
begin;
set local safeupdate.enabled=on;
create temporary table mbn_safeupdate_probe(id integer primary key, changed boolean default false);
insert into mbn_safeupdate_probe(id) values(1);
do $$begin
 begin
  update pg_temp.mbn_safeupdate_probe set changed=true;
  raise exception 'safeupdate_guard_inactive';
 exception when cardinality_violation then
  if sqlerrm<>'UPDATE requires a WHERE clause' then raise;end if;
 end;
end;$$;

create temporary table mbn_sender_revisions as select code,revision from private.mbn_mail_sender_groups;
update private.mbn_mail_sender_groups set sender_verified=true,production_access=true,account_sending_enabled=true,
 credential_fingerprint=repeat('a',64),provider_checked_at=now(),events_verified_at=now()
 where code in ('MBN_GLOBAL','CAMPUS_INNOVATION_MLV','ADMISSIONS_COMMUN');
update private.mbn_mail_settings set provider='GOOGLE_APPS_SCRIPT' where id;
do $$begin
 if (select provider from private.mbn_mail_settings where id)<>'GOOGLE_APPS_SCRIPT' then raise exception 'provider_not_selected';end if;
 if exists(select 1 from private.mbn_mail_sender_groups where enabled or sender_verified or production_access or account_sending_enabled
  or credential_fingerprint is not null or provider_checked_at is not null or events_verified_at is not null
  or test_confirmed_at is not null or test_confirmed_by is not null or test_confirmed_message is not null)
  then raise exception 'provider_proof_not_reset';end if;
 if exists(select 1 from private.mbn_mail_sender_groups g join pg_temp.mbn_sender_revisions r using(code) where g.revision=r.revision)
  then raise exception 'sender_revision_not_reset';end if;
 if exists(select 1 from private.mbn_mail_settings where enabled) then raise exception 'provider_selection_activated_mail';end if;
end;$$;

update private.mbn_mail_sender_groups set sender_verified=true,production_access=true,account_sending_enabled=true,
 credential_fingerprint=repeat('b',64),provider_checked_at=now(),events_verified_at=now()
 where code in ('MBN_GLOBAL','CAMPUS_INNOVATION_MLV','ADMISSIONS_COMMUN');
update private.mbn_mail_settings set credential_fingerprint=repeat('c',64) where id;
do $$begin
 if exists(select 1 from private.mbn_mail_sender_groups where enabled or sender_verified or production_access or account_sending_enabled
  or credential_fingerprint is not null or provider_checked_at is not null or events_verified_at is not null)
  then raise exception 'credential_proof_not_reset';end if;
 if exists(select 1 from private.mbn_mail_settings where enabled) then raise exception 'credential_rotation_activated_mail';end if;
 if current_setting('safeupdate.enabled')<>'on' then raise exception 'safeupdate_guard_disabled';end if;
end;$$;
rollback;
