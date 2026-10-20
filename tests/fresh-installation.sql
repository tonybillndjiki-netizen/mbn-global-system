-- Run by CI against a disposable local Supabase stack after db reset --local.
\set ON_ERROR_STOP on
begin;
do $$begin
 if (select count(*) from public.schools)<>19 or (select count(*) from public.school_programs)<>1275 then raise exception 'catalog_incomplete';end if;
 if exists(select 1 from private.admin_allowlist) or exists(select 1 from public.school_programs where is_active) then raise exception 'unexpected_activation';end if;
 if exists(select 1 from private.mbn_mail_settings where enabled) then raise exception 'mail_enabled';end if;
 if (select count(*) from private.mbn_runtime_secrets r join vault.decrypted_secrets d on d.id=r.vault_id)<>3 then raise exception 'vault_incomplete';end if;
 if (select count(*) from cron.job where jobname in ('mbn-mail-due','mbn-meta-due'))<>2 then raise exception 'scheduler_incomplete';end if;
 if (select count(*) from storage.buckets where id in ('mbn-native-test','mbn-admissions','mbn-mail-assets','mbn-admission-letters') and not public)<>4 then raise exception 'private_bucket_missing_or_exposed';end if;
 if has_function_privilege('anon','public.mbn_installation_bootstrap_owner(text)','execute') or has_function_privilege('authenticated','public.mbn_installation_configure(text,text,text)','execute') then raise exception 'installation_rpc_exposed';end if;
 perform private.mbn_mail_tick();perform private.mbn_meta_tick();
end;$$;
rollback;
