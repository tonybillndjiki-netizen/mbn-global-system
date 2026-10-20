-- Run only in the disposable local Supabase stack, as supabase_admin.
-- Load the hosted protection before exercising the application service role.
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
grant select on pg_temp.mbn_sender_revisions to service_role;
set local role service_role;
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
