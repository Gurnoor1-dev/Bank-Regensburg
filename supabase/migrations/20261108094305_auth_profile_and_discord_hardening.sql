
create function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$ begin insert into public.profiles(id,display_name) values(new.id,coalesce(new.raw_user_meta_data->>'full_name','')) on conflict(id) do nothing; return new; end $$;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
drop policy if exists profile_self_update on public.profiles;
revoke update on public.profiles from authenticated;
create function public.issue_discord_link_code(p_code_hash text) returns void language plpgsql security definer set search_path=public as $$ begin if auth.uid() is null or p_code_hash !~ '^[a-f0-9]{64}$' then raise exception 'Not authorised'; end if; insert into public.discord_link_codes(user_id,code_hash,expires_at) values(auth.uid(),p_code_hash,now()+interval '10 minutes'); end $$;
