export const storageFixture=`
  alter table auth.users add column banned_until timestamptz,add column deleted_at timestamptz;
  create table auth.sessions(id uuid primary key,user_id uuid references auth.users(id),created_at timestamptz not null default now());
  create table auth.mfa_factors(user_id uuid references auth.users(id),status text);
  create schema storage;
  create table storage.buckets(id text primary key,name text not null,public boolean not null default false,file_size_limit bigint,allowed_mime_types text[]);
  create table storage.objects(id uuid primary key default gen_random_uuid(),bucket_id text not null references storage.buckets(id),name text not null,metadata jsonb,unique(bucket_id,name));
  alter table storage.objects enable row level security;
  grant usage on schema storage to anon,authenticated,service_role;
`;
