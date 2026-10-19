-- Vault's hosted create_secret includes an optional fourth UUID parameter.
-- PostgreSQL resolves default arguments at call time, not in to_regprocedure.
do $$declare v_id uuid;v_name text;begin
 if to_regprocedure('vault.create_secret(text,text,text,uuid)') is not null
  or to_regprocedure('vault.create_secret(text,text,text)') is not null then
  foreach v_name in array array['link','worker'] loop
   if not exists(select 1 from private.mbn_runtime_secrets where name=v_name) then
    execute 'select vault.create_secret($1,$2,$3)' into v_id
    using gen_random_uuid()::text||gen_random_uuid()::text||gen_random_uuid()::text,
     'mbn_'||v_name||'_'||gen_random_uuid()::text,'MBN internal capability signing / scheduler authentication';
    insert into private.mbn_runtime_secrets values(v_name,v_id);
   end if;
  end loop;
 end if;
end;$$;
