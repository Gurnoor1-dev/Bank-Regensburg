# Bank Regensburg

A community-operated virtual banking institution for the Infinite Flight ecosystem. The application includes a public institutional website, authenticated member portal, staff cheque-clearing desk, Supabase banking database and a separate Discord bot.

> **Important:** Bank Regensburg is fictional and uses virtual currency only (BRV). It is not a licensed bank, does not accept real deposits, and must never request real banking credentials or payment-card details.

## Application structure

- Website: React + Vite, including /portal member access, /staff clearing desk and /admin provisioning console.
- Identity and data: Supabase Auth + PostgreSQL with Row Level Security.
- Discord integration: Node.js 20+ bot in discord-bot/.
- Ledger: append-only double-entry entries. Browser clients cannot directly write balances.
- Currency: BRV, a fictional internal unit with no real-world monetary value.

## Website setup

Run npm install, copy .env.example to .env.local, add the Supabase URL and publishable key, then run npm run dev. Production builds use npm run build.

Vercel production project: bank-regensburg. The Vite environment variables VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY are configured for production, preview and development. The service-role key is never used in the browser.

## Discord bot

Follow discord-bot/Guide.md. Upload only the discord-bot directory to your bot host, configure its environment variables from discord-bot/.env.example, run npm install, npm run register and npm start. Bot token and Supabase service-role key belong only in the host's encrypted secret manager.

Commands: /link, /my-account, /bank-status and /clearing-queue. Account and staff replies are ephemeral. The bot polls the Supabase notification outbox and privately notifies linked members and staff. Discord is not used as a login credential; the portal issues a hashed, one-time code which the bot redeems.

## Supabase

Project: https://pfcmwxkphcgmupiltjti.supabase.co

The ordered migrations are stored in supabase/migrations/. They create profiles, accounts, memberships, double-entry ledger, cheque books, cheques, staff decisions, holiday calendar, allocation runs, audit log, notification outbox and Discord link codes. They also create the profile-on-signup trigger and the secured cheque workflow functions.

### Cheque flow

1. An authorised member creates a draft cheque from an issued cheque book.
2. Submission checks membership, account status and available funds, reserves funds against other queued cheques, and creates a staff notification.
3. Active clearing staff review queued cheques before 16:30 UTC on a weekday that is not in the bank holiday table.
4. Approval posts an atomic debit and credit with a cheque-specific idempotency key. Rejection is recorded. The action and decision are audited.

Personal cheque books contain 30 instruments; corporate books contain 150. The database enforces each book's instrument limit. Cheque IDs are generated server-side.

## First administrator bootstrap

1. Register through /portal and confirm the email address.
2. In Supabase SQL Editor, promote the exact Auth user UUID:

    update public.profiles set role='admin', status='active' where id='YOUR_AUTH_USER_UUID';

3. Create an active treasury and member/company accounts, account memberships and cheque books through a trusted admin provisioning workflow. Fund accounts only through balanced ledger transactions. Do not manually edit account balances.
4. Add bank holidays using UTC dates. Promote approved staff profiles to clearing_staff, auditor or admin as appropriate.
5. Link each staff Discord identity through the member portal and /link.

The member-facing app intentionally does not expose account creation, membership changes, staff role promotion, cheque-book issuance or treasury funding. These high-risk admin operations must remain restricted to trusted operators and be added as audited admin workflows before community launch.

## Security notes

- RLS is enabled on all public banking tables. No anonymous table access is granted.
- SECURITY DEFINER functions have explicit grants and validate the caller/role where required. Balance reads are restricted to account members and active staff.
- Never expose the Supabase service-role key to the browser or commit populated environment files.
- Enable MFA for all bank administrators and clearing staff.
- One-time Discord link codes are hashed at rest and expire after 10 minutes.
- Discord DMs are notifications only; the authenticated portal is the source of truth.
- The bot's clearing queue is read-only. Approvals and settlements happen in the authenticated staff console.
- Test using separate pilot, company officer, clearing staff and admin accounts before inviting members.

## Known rollout tasks

- Configure Supabase Auth email confirmation and production SMTP.
- Create the first admin profile, treasury account, accounts, memberships and cheque books.
- Deploy the Discord bot using discord-bot/Guide.md.
- Add the bank's custom domain to Vercel when ready.
- Perform role-based end-to-end tests with test accounts and test balances before issuing any virtual currency.
