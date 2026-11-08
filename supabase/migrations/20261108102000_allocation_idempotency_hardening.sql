create or replace function public.admin_record_allocation(p_account_id uuid,p_treasury_id uuid,p_pilot_count integer,p_fleet_count integer,p_route_count integer,p_amount numeric,p_notes text,p_idempotency_key text) returns uuid language plpgsql security definer set search_path=public as $$ declare tx uuid; begin
 if not public.is_admin() then raise exception 'Administrator access required'; end if;
 if not exists(select 1 from public.bank_accounts where id=p_account_id and kind='corporate' and status='active') then raise exception 'An active corporate account is required'; end if;
 if not exists(select 1 from public.bank_accounts where id=p_treasury_id and kind='treasury' and status='active') then raise exception 'An active treasury account is required'; end if;
 if p_account_id=p_treasury_id then raise exception 'Treasury and airline accounts must be different'; end if;
 if p_pilot_count<0 or p_fleet_count<0 or p_route_count<0 or p_amount<=0 or length(coalesce(p_idempotency_key,''))<8 then raise exception 'Invalid allocation inputs'; end if;
 select id into tx from public.ledger_transactions where idempotency_key=p_idempotency_key; if tx is not null then return tx; end if;
 tx:=public.post_ledger_transaction('Airline capital allocation',p_treasury_id,p_account_id,p_amount,p_idempotency_key);
 insert into public.allocation_runs(airline_account_id,pilot_count,fleet_count,route_count,amount,notes,created_by) values(p_account_id,p_pilot_count,p_fleet_count,p_route_count,p_amount,left(p_notes,500),auth.uid());
 insert into public.audit_events(actor_id,action,target_type,target_id,metadata) values(auth.uid(),'airline_allocation_recorded','account',p_account_id::text,jsonb_build_object('pilots',p_pilot_count,'fleet',p_fleet_count,'routes',p_route_count,'amount',p_amount)); return tx; end $$;
