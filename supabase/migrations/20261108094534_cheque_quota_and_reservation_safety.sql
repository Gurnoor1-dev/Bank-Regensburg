
create or replace function public.submit_cheque(p_cheque uuid) returns public.cheques language plpgsql security definer set search_path=public as $$ declare c public.cheques; available numeric; reserved numeric; begin
 select * into c from public.cheques where id=p_cheque for update;
 if not found or not public.has_account_access(c.account_id,'operate') then raise exception 'Cheque not found or not authorised'; end if;
 if c.status<>'draft' then raise exception 'Only draft cheques can be submitted'; end if;
 perform 1 from public.bank_accounts where id=c.account_id for update;
 available:=public.account_balance(c.account_id);
 select coalesce(sum(amount),0) into reserved from public.cheques where account_id=c.account_id and status='queued';
 if c.amount+reserved>available then raise exception 'Insufficient available balance after pending cheque reservations'; end if;
 update public.cheques set status='queued',submitted_by=auth.uid(),submitted_at=now() where id=p_cheque returning * into c;
 insert into public.notification_outbox(recipient_user_id,event_type,payload) select p.id,'cheque_submitted',jsonb_build_object('cheque_id',c.id,'cheque_number',c.cheque_number) from public.profiles p where p.role in ('clearing_staff','admin') and p.status='active';
 insert into public.audit_events(actor_id,action,target_type,target_id) values(auth.uid(),'cheque_submitted','cheque',c.id::text); return c; end $$;
create or replace function public.create_cheque(p_book uuid,p_payee_account uuid,p_amount numeric,p_memo text default '') returns public.cheques language plpgsql security definer set search_path=public as $$ declare b public.cheque_books; c public.cheques; serial text; used integer; begin
 select * into b from public.cheque_books where id=p_book for update;
 if not found or not public.has_account_access(b.account_id,'operate') then raise exception 'Cheque book not found or not authorised'; end if;
 if p_amount<=0 or p_amount>10000000 then raise exception 'Invalid amount'; end if;
 if not exists(select 1 from public.bank_accounts where id=p_payee_account and status='active') then raise exception 'Payee account unavailable'; end if;
 select count(*) into used from public.cheques where book_id=p_book; if used>=b.book_size then raise exception 'This cheque book has no unused instruments remaining'; end if;
 serial:=b.serial_prefix||'-'||upper(substr(encode(gen_random_bytes(4),'hex'),1,8));
 insert into public.cheques(cheque_number,book_id,account_id,payee_account_id,amount,memo) values(serial,p_book,b.account_id,p_payee_account,p_amount,left(p_memo,160)) returning * into c;
 insert into public.audit_events(actor_id,action,target_type,target_id) values(auth.uid(),'cheque_created','cheque',c.id::text); return c; end $$;
