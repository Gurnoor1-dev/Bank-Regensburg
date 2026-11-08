alter table public.profiles drop constraint if exists profiles_status_check;
alter table public.profiles add constraint profiles_status_check check (status = any (array['pending','active','suspended','rejected']));

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path=public
as $$
begin
  insert into public.profiles(id,display_name,application_type,application_discord,application_reason,application_submitted_at)
  values(
    new.id,
    left(coalesce(new.raw_user_meta_data->>'full_name',''),100),
    case when new.raw_user_meta_data->>'application_type' in ('personal','corporate') then new.raw_user_meta_data->>'application_type' else 'personal' end,
    left(coalesce(new.raw_user_meta_data->>'discord_username',''),80),
    left(coalesce(new.raw_user_meta_data->>'application_reason',''),1000),
    now()
  ) on conflict(id) do nothing;
  return new;
end $$;

create or replace function public.admin_set_profile(p_user_id uuid,p_display_name text,p_role bank_role,p_status text)
returns void language plpgsql security definer set search_path=public
as $$
begin
 if not public.is_admin() then raise exception 'Administrator access required'; end if;
 if p_status not in ('pending','active','suspended','rejected') then raise exception 'Invalid profile status'; end if;
 update public.profiles set display_name=left(coalesce(p_display_name,''),100),role=p_role,status=p_status,updated_at=now() where id=p_user_id;
 if not found then raise exception 'Profile not found'; end if;
 insert into public.audit_events(actor_id,action,target_type,target_id,metadata)
 values(auth.uid(),'profile_updated','profile',p_user_id::text,jsonb_build_object('role',p_role,'status',p_status));
end $$;
