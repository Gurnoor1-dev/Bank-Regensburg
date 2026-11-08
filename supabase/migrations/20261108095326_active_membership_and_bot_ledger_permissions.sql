
create or replace function public.has_account_access(aid uuid,min_permission text default 'view') returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.account_memberships m join public.profiles p on p.id=m.user_id where m.account_id=aid and m.user_id=auth.uid() and p.status='active' and (case min_permission when 'manage' then m.permission='manage' when 'operate' then m.permission in ('operate','manage') else true end)) $$;
grant execute on function public.account_balance(uuid) to service_role;
grant execute on function public.post_ledger_transaction(text,uuid,uuid,numeric,text) to service_role;
