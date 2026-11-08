
create table public.discord_link_codes(id uuid primary key default gen_random_uuid(),user_id uuid not null references auth.users(id) on delete cascade,code_hash text not null unique,expires_at timestamptz not null,used_at timestamptz,created_at timestamptz not null default now());
alter table public.discord_link_codes enable row level security;
create function public.claim_discord_link(p_code text,p_discord_id text,p_discord_username text) returns boolean language plpgsql security definer set search_path=public as $$ declare uid uuid; begin
 if length(p_code)<8 or length(p_code)>32 or p_discord_id !~ '^[0-9]{16,22}$' then return false; end if;
 select user_id into uid from public.discord_link_codes where code_hash=encode(digest(p_code,'sha256'),'hex') and used_at is null and expires_at>now() for update;
 if uid is null then return false; end if;
 if exists(select 1 from public.profiles where discord_user_id=p_discord_id and id<>uid) then return false; end if;
 update public.profiles set discord_user_id=p_discord_id,discord_username=left(p_discord_username,100),updated_at=now() where id=uid;
 update public.discord_link_codes set used_at=now() where code_hash=encode(digest(p_code,'sha256'),'hex');
 insert into public.audit_events(actor_id,action,target_type,target_id) values(uid,'discord_linked','profile',uid::text); return true; end $$;
