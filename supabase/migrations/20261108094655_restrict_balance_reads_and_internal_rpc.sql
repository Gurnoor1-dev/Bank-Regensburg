
create or replace function public.account_balance(aid uuid) returns numeric language plpgsql stable security definer set search_path=public as $$ declare result numeric; begin
 if auth.uid() is not null and not public.has_account_access(aid,'view') and not public.is_staff() then raise exception 'Not authorised to view this account balance'; end if;
 select coalesce(sum(e.amount),0) into result from public.ledger_entries e join public.ledger_transactions t on t.id=e.transaction_id where e.account_id=aid and t.status='posted'; return result; end $$;
revoke all on function public.account_balance(uuid) from public,anon,authenticated;
grant execute on function public.account_balance(uuid) to authenticated;
revoke all on function public.rls_auto_enable() from public,anon,authenticated;
