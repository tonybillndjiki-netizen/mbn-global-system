-- Keep Supabase's safeupdate protection active when invalidating sender proofs.
-- A provider or shared credential change affects only the three managed groups.
create or replace function private.mbn_mail_provider_changed() returns trigger
language plpgsql security invoker set search_path='' as $$begin
 if old.provider is distinct from new.provider then
  update private.mbn_mail_sender_groups set enabled=false,sender_verified=false,production_access=false,account_sending_enabled=false,
   credential_fingerprint=null,provider_checked_at=null,provider_error=null,events_verified_at=null,
   test_confirmed_at=null,test_confirmed_by=null,test_confirmed_message=null,revision=gen_random_uuid(),updated_at=now()
   where code in ('MBN_GLOBAL','CAMPUS_INNOVATION_MLV','ADMISSIONS_COMMUN');
 end if;
 return null;
end;$$;

create or replace function private.mbn_mail_reset_group_credentials() returns trigger
language plpgsql security invoker set search_path='' as $$begin
 if old.credential_fingerprint is distinct from new.credential_fingerprint then
  update private.mbn_mail_sender_groups set enabled=false,sender_verified=false,production_access=false,account_sending_enabled=false,
   provider_checked_at=null,credential_fingerprint=null,events_verified_at=null,revision=gen_random_uuid(),updated_at=now()
   where code in ('MBN_GLOBAL','CAMPUS_INNOVATION_MLV','ADMISSIONS_COMMUN');
 end if;
 return null;
end;$$;
