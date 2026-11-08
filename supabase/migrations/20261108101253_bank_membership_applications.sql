alter table public.profiles
  add column if not exists application_type text not null default 'personal',
  add column if not exists application_discord text,
  add column if not exists application_reason text,
  add column if not exists application_submitted_at timestamptz,
  add column if not exists application_decision_note text,
  add column if not exists application_reviewed_at timestamptz;

create or replace function public.submit_bank_application(p_full_name text,p_application_type text,p_discord_username text,p_reason text)
returns void language plpgsql security definer set search_path=public
as $$
declare v_uid uuid := auth.uid();
begin
  if v_uid is null then raise exception 'Sign in required'; end if;
  if length(trim(coalesce(p_full_name,''))) < 2 then raise exception 'Enter your full name'; end if;
  if p_application_type not in ('personal','corporate') then raise exception 'Invalid application type'; end if;
  if length(trim(coalesce(p_discord_username,''))) < 2 then raise exception 'Enter your Discord username'; end if;
  if length(trim(coalesce(p_reason,''))) < 10 then raise exception 'Please provide a little more detail'; end if;
  update public.profiles set display_name=left(trim(p_full_name),100),application_type=p_application_type,
    application_discord=left(trim(p_discord_username),80),application_reason=left(trim(p_reason),1000),
    application_submitted_at=now(),application_decision_note=null,application_reviewed_at=null,
    status='pending',updated_at=now() where id=v_uid;
  if not found then raise exception 'Member profile not found'; end if;
  insert into public.audit_events(actor_id,action,target_type,target_id,metadata)
  values(v_uid,'membership_application_submitted','profile',v_uid::text,jsonb_build_object('type',p_application_type));
end $$;

create or replace function public.admin_review_application(p_user_id uuid,p_decision text,p_note text default '')
returns void language plpgsql security definer set search_path=public
as $$
begin
  if not public.is_admin() then raise exception 'Administrator access required'; end if;
  if p_decision not in ('approve','reject') then raise exception 'Invalid decision'; end if;
  update public.profiles set status=case when p_decision='approve' then 'active' else 'rejected' end,
    application_decision_note=left(coalesce(p_note,''),500),application_reviewed_at=now(),updated_at=now()
  where id=p_user_id and application_submitted_at is not null;
  if not found then raise exception 'Application not found'; end if;
  insert into public.audit_events(actor_id,action,target_type,target_id,metadata)
  values(auth.uid(),'membership_application_'||p_decision,'profile',p_user_id::text,jsonb_build_object('note',left(coalesce(p_note,''),500)));
  insert into public.notification_outbox(recipient_user_id,event_type,payload)
  values(p_user_id,'membership_application_decision',jsonb_build_object('decision',p_decision,'note',left(coalesce(p_note,''),500)));
end $$;

revoke all on function public.submit_bank_application(text,text,text,text) from public,anon;
grant execute on function public.submit_bank_application(text,text,text,text) to authenticated;
revoke all on function public.admin_review_application(uuid,text,text) from public,anon;
grant execute on function public.admin_review_application(uuid,text,text) to authenticated;
