-- Brevo replaces SES. Existing records and school permissions are preserved.
alter table private.mbn_mail_settings add column provider text not null default 'BREVO' check(provider='BREVO'),
 add column brevo_webhook_id bigint check(brevo_webhook_id>0),
 add column credential_fingerprint text check(credential_fingerprint ~ '^[a-f0-9]{64}$');
update private.mbn_mail_settings set enabled=false,sender_verified=false,production_access=false,account_sending_enabled=false,
 provider_checked_at=null,provider_error=null,last_test_accepted_at=null,events_verified_at=null,sns_topic_arn='',configuration_set='';
alter table public.mail_messages add column provider text not null default 'SES' check(provider in ('SES','BREVO')),
 add column sender_identity text,add column credential_fingerprint text;
alter table public.mail_messages alter column provider set default 'BREVO';
create unique index mail_brevo_provider_id_idx on public.mail_messages(provider_message_id) where provider='BREVO' and provider_message_id is not null;

do $$declare v_id uuid;begin
 if exists(select 1 from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='vault' and p.proname='create_secret') then
  execute 'select vault.create_secret($1,$2,$3)' into v_id
   using gen_random_uuid()::text||gen_random_uuid()::text||gen_random_uuid()::text,
   'mbn_brevo_webhook_'||gen_random_uuid()::text,'MBN Brevo callback authentication';
  insert into private.mbn_runtime_secrets(name,vault_id) values('brevo_webhook',v_id);
 end if;
end;$$;
-- Extend the existing internal Vault helper; its grants remain server-only.
create or replace function private.mbn_runtime_secret(p_name text) returns text
language plpgsql security definer set search_path='' as $$
declare v_value text;begin
 if p_name not in ('link','worker','brevo_webhook') then raise sqlstate 'PT403' using message='access_denied';end if;
 execute 'select d.decrypted_secret from vault.decrypted_secrets d join private.mbn_runtime_secrets r on r.vault_id=d.id where r.name=$1' into v_value using p_name;
 if length(coalesce(v_value,''))<80 then raise exception 'runtime_secret_unavailable';end if;
 return v_value;
end;$$;

alter function public.mbn_workspace_action(uuid,uuid,text,jsonb) rename to mbn_workspace_action_legacy;
create function public.mbn_workspace_action(p_actor uuid,p_session uuid,p_action text,p_data jsonb default '{}')
returns jsonb language plpgsql security invoker set search_path='' as $$
declare v_settings private.mbn_mail_settings;v_ctx jsonb;v_changed boolean;v_result jsonb;begin
 if p_action not in ('settings_get','settings_save','test_prepare') then
  return public.mbn_workspace_action_legacy(p_actor,p_session,p_action,p_data);
 end if;
 v_ctx:=public.mbn_pin_context(p_actor,p_session,p_actor);
 if not coalesce((v_ctx->>'admin')::boolean,false) then raise sqlstate 'PT403' using message='access_denied';end if;
 if jsonb_typeof(p_data)<>'object' then raise sqlstate 'PT400' using message='invalid_request';end if;
 select * into v_settings from private.mbn_mail_settings where id for update;
 if p_action='test_prepare' then
  v_result:=public.mbn_workspace_action_legacy(p_actor,p_session,p_action,p_data);
  update public.mail_messages set sender_identity=v_settings.from_email,credential_fingerprint=v_settings.credential_fingerprint where id=(v_result->>'id')::uuid;
  return v_result;
 elsif p_action='settings_save' then
  if exists(select 1 from jsonb_object_keys(p_data) k where k not in ('from_name','from_email','reply_to','daily_limit','enabled'))
   or coalesce(p_data->>'from_email','') !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'
   or length(p_data->>'from_email')>254 or length(coalesce(p_data->>'from_name','')) not between 1 and 100
   or p_data->>'from_name' ~ E'[\r\n]' or length(coalesce(p_data->>'reply_to',''))>254
   or (coalesce(p_data->>'reply_to','')<>'' and p_data->>'reply_to' !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$')
   or coalesce(p_data->>'daily_limit','') !~ '^[0-9]{1,5}$' or (p_data->>'daily_limit')::integer not between 1 and 10000
   or jsonb_typeof(p_data->'enabled') is distinct from 'boolean'
   then raise sqlstate 'PT422' using message='invalid_sender';end if;
  v_changed:=v_settings.from_email is distinct from lower(p_data->>'from_email');
  if (p_data->>'enabled')::boolean and (v_changed or not v_settings.sender_verified or not v_settings.production_access or not v_settings.account_sending_enabled
   or v_settings.provider_checked_at is null or v_settings.provider_checked_at<now()-interval '1 hour'
   or v_settings.last_test_accepted_at is null or v_settings.events_verified_at is null or v_settings.brevo_webhook_id is null or v_settings.credential_fingerprint is null)
   then raise sqlstate 'PT422' using message='sender_not_ready';end if;
  update private.mbn_mail_settings set from_name=p_data->>'from_name',from_email=lower(p_data->>'from_email'),reply_to=coalesce(p_data->>'reply_to',''),daily_limit=(p_data->>'daily_limit')::integer,enabled=(p_data->>'enabled')::boolean,
   sender_verified=case when v_changed then false else sender_verified end,
   provider_checked_at=case when v_changed then null else provider_checked_at end,
   last_test_accepted_at=case when v_changed then null else last_test_accepted_at end,
   events_verified_at=case when v_changed then null else events_verified_at end,
   updated_at=now() where id returning * into v_settings;
 end if;
 return to_jsonb(v_settings)-array['id','identity','region','configuration_set','sns_topic_arn','credential_fingerprint'];
end;$$;
revoke all on function public.mbn_workspace_action(uuid,uuid,text,jsonb),public.mbn_workspace_action_legacy(uuid,uuid,text,jsonb) from public,anon,authenticated;
grant execute on function public.mbn_workspace_action(uuid,uuid,text,jsonb),public.mbn_workspace_action_legacy(uuid,uuid,text,jsonb) to service_role;

create or replace function public.mbn_mail_provider_checked(p_result jsonb) returns void
language plpgsql security invoker set search_path='' as $$
declare v_hash text:=p_result->>'credential_fingerprint';v_changed boolean;begin
 if v_hash is not null and v_hash !~ '^[a-f0-9]{64}$' then raise sqlstate 'PT400' using message='invalid_provider';end if;
 select v_hash is not null and credential_fingerprint is distinct from v_hash into v_changed from private.mbn_mail_settings where id for update;
 update private.mbn_mail_settings set sender_verified=coalesce((p_result->>'sender_verified')::boolean,false),production_access=coalesce((p_result->>'production_access')::boolean,false),
  account_sending_enabled=coalesce((p_result->>'account_sending_enabled')::boolean,false),provider_error=p_result->>'error',provider_checked_at=now(),
  credential_fingerprint=coalesce(v_hash,credential_fingerprint),
  brevo_webhook_id=case when v_changed then null else brevo_webhook_id end,
  last_test_accepted_at=case when v_changed then null else last_test_accepted_at end,
  events_verified_at=case when v_changed then null else events_verified_at end,
  enabled=enabled and not v_changed and coalesce((p_result->>'sender_verified')::boolean,false) and coalesce((p_result->>'production_access')::boolean,false) and coalesce((p_result->>'account_sending_enabled')::boolean,false) where id;
end;$$;
create function public.mbn_brevo_webhook_configured(p_id bigint) returns void
language plpgsql security invoker set search_path='' as $$begin
 if p_id is null or p_id<=0 then raise sqlstate 'PT400' using message='invalid_webhook';end if;
 update private.mbn_mail_settings set brevo_webhook_id=p_id,events_verified_at=null,last_test_accepted_at=null,enabled=false,updated_at=now() where id;
end;$$;
revoke all on function public.mbn_brevo_webhook_configured(bigint) from public,anon,authenticated;
grant execute on function public.mbn_brevo_webhook_configured(bigint) to service_role;

create table private.mbn_brevo_events(
 event_key text primary key check(event_key ~ '^[a-f0-9]{64}$'),message_id uuid not null references public.mail_messages(id),
 event_type text not null,created_at timestamptz not null default now()
);
alter table private.mbn_brevo_events enable row level security;
revoke all on private.mbn_brevo_events from public,anon,authenticated;
grant select,insert on private.mbn_brevo_events to service_role;
create function public.mbn_brevo_event(p_key text,p_event jsonb) returns boolean
language plpgsql security invoker set search_path='' as $$
declare v_msg public.mail_messages;v_setting private.mbn_mail_settings;v_id uuid;v_type text:=p_event->>'event';v_provider text:=p_event->>'provider_id';begin
 if p_key is null or p_key !~ '^[a-f0-9]{64}$' or v_type is null or v_type not in ('request','sent','delivered','hard_bounce','soft_bounce','blocked','spam','invalid_email','deferred','unsubscribed','error')
  or coalesce(length(v_provider),0) not between 1 and 199 then raise sqlstate 'PT400' using message='invalid_event';end if;
 if exists(select 1 from private.mbn_brevo_events where event_key=p_key) then return false;end if;
 begin v_id:=(p_event->>'message_id')::uuid;exception when invalid_text_representation then raise sqlstate 'PT400' using message='invalid_event';end;
 select * into v_msg from public.mail_messages where provider='BREVO' and lower(recipient)=lower(p_event->>'email')
  and (v_id is null or id=v_id) and (provider_message_id=v_provider or (id=v_id and provider_message_id is null)) for update;
 if not found or v_msg.status in ('QUEUED','CANCELED','FAILED') then return false;end if;
 -- A callback can beat the HTTP response. Ask Brevo to retry after the send finishes.
 if v_msg.status='SENDING' then raise sqlstate 'PT409' using message='message_pending';end if;
 insert into private.mbn_brevo_events values(p_key,v_msg.id,v_type,now()) on conflict do nothing;
 if not found then return false;end if;
 select * into v_setting from private.mbn_mail_settings where id for update;
 if v_type in ('request','sent','delivered') then
  update public.mail_messages set status=case when status in ('BOUNCED','COMPLAINED') then status when v_type='delivered' then 'DELIVERED' when status='UNCERTAIN' then 'ACCEPTED' else status end,
   provider_message_id=v_provider,accepted_at=coalesce(accepted_at,now()),delivered_at=case when v_type='delivered' then coalesce(delivered_at,now()) else delivered_at end,updated_at=now() where id=v_msg.id;
  update public.crm_outreach_queue set status='SENT',sent_at=coalesce(sent_at,now()) where id=v_msg.outreach_id;
  update public.crm_applications set status='LETTER_SENT',updated_at=now() where id=(select application_id from private.mbn_admission_letters where id=v_msg.admission_letter_id) and status='ADMITTED';
  if v_type='delivered' and v_msg.is_test and v_setting.brevo_webhook_id is not null
   and v_msg.sender_identity=v_setting.from_email and v_msg.credential_fingerprint=v_setting.credential_fingerprint then
   update private.mbn_mail_settings set events_verified_at=now(),last_test_accepted_at=coalesce(last_test_accepted_at,now()) where id;
  end if;
 elsif v_type in ('hard_bounce','invalid_email','spam') then
  update public.mail_messages set status=case when v_type='spam' or status='COMPLAINED' then 'COMPLAINED' else 'BOUNCED' end,provider_message_id=v_provider,updated_at=now() where id=v_msg.id;
  update public.crm_leads set email_suppressed_at=coalesce(email_suppressed_at,now()),email_suppression_reason='BREVO_'||upper(v_type),consent_email=false,updated_at=now() where lower(email)=lower(v_msg.recipient) and not is_test;
 elsif v_type='unsubscribed' then
  update public.crm_leads set consent_email=false,status='UNSUBSCRIBED',unsubscribed_at=coalesce(unsubscribed_at,now()),updated_at=now() where lower(email)=lower(v_msg.recipient) and not is_test;
 elsif v_type in ('blocked','error') then
  update public.mail_messages set status=case when status in ('UNCERTAIN','ACCEPTED') then 'FAILED' else status end,error_code='brevo_'||v_type,updated_at=now() where id=v_msg.id;
 end if;
 if v_msg.lead_id is not null then insert into public.crm_lead_events(lead_id,event_type,event_metadata) values(v_msg.lead_id,'BREVO_'||upper(v_type),jsonb_build_object('message_id',v_msg.id));end if;
 return true;
end;$$;
revoke all on function public.mbn_brevo_event(text,jsonb) from public,anon,authenticated;
grant execute on function public.mbn_brevo_event(text,jsonb) to service_role;

-- Legacy SNS notifications cannot mutate messages transported by Brevo.
create or replace function public.mbn_mail_event(p_envelope_id text,p_event jsonb) returns boolean
language plpgsql security invoker set search_path='' as $$
declare v_type text;v_msg public.mail_messages;v_id uuid;v_provider text;begin
 insert into private.mbn_ses_events(message_id) values(p_envelope_id) on conflict do nothing;
 if not found then return false;end if;
 v_type:=coalesce(p_event->>'eventType',p_event->>'notificationType');
 v_provider:=p_event->'mail'->>'messageId';
 begin v_id:=(p_event->'mail'->'tags'->'mbn_message_id'->>0)::uuid;exception when invalid_text_representation then v_id:=null;end;
 select * into v_msg from public.mail_messages where provider='SES' and ((id=v_id and (provider_message_id is null or provider_message_id=v_provider)) or (v_provider is not null and provider_message_id=v_provider)) for update;
 if not found then return false;end if;
 update private.mbn_mail_settings set events_verified_at=now() where id;
 if v_msg.is_test and v_type in ('Send','Delivery') then update private.mbn_mail_settings set last_test_accepted_at=now() where id;end if;
 if v_type='Send' then
  update public.mail_messages set status=case when status in ('SENDING','UNCERTAIN') then 'ACCEPTED' else status end,provider_message_id=v_provider,accepted_at=coalesce(accepted_at,now()),updated_at=now() where id=v_msg.id;
 elsif v_type='Delivery' then
  update public.mail_messages set status=case when status in ('BOUNCED','COMPLAINED') then status else 'DELIVERED' end,provider_message_id=v_provider,accepted_at=coalesce(accepted_at,now()),delivered_at=now(),updated_at=now() where id=v_msg.id;
 elsif v_type='Complaint' or (v_type='Bounce' and p_event->'bounce'->>'bounceType'='Permanent') then
  update public.mail_messages set status=case when v_type='Complaint' then 'COMPLAINED' else 'BOUNCED' end,provider_message_id=v_provider,updated_at=now() where id=v_msg.id;
  update public.crm_leads set email_suppressed_at=now(),email_suppression_reason=upper(v_type),consent_email=false,updated_at=now() where lower(email)=lower(v_msg.recipient) and not is_test;
 end if;
 if v_type in ('Send','Delivery') then update public.crm_outreach_queue set status='SENT',sent_at=coalesce(sent_at,now()) where id=v_msg.outreach_id;end if;
 if v_msg.lead_id is not null then insert into public.crm_lead_events(lead_id,event_type,event_metadata) values(v_msg.lead_id,'SES_'||upper(v_type),jsonb_build_object('message_id',v_msg.id));end if;
 return true;
end;$$;
