# Bank Regensburg

A virtual banking network for the Infinite Flight community. This repository currently contains the public-facing website foundation and the proposed product rules.

> **Important:** Bank Regensburg is fictional, community-operated and uses virtual currency only. It is not a licensed bank, does not accept real deposits, and must never request real banking credentials or payment-card details.

## Run locally

```bash
npm install
npm run dev
```

Create a production build with `npm run build`.

## Current scope

- Responsive public website explaining the institution, services and operating model.
- Public disclosure that the project is virtual and not a real financial institution.
- No real account credentials, cheque data or balances are collected by this static website.
- Member portal, staff console, Discord bot and ledger are planned backend phases, not simulated in this first foundation.

## Recommended system architecture

- **Web application:** React + Vite, deployed on Vercel.
- **Identity and data:** Supabase Auth + PostgreSQL with Row Level Security (RLS).
- **Discord integration:** a server-side bot/service only. Keep the Discord bot token and Supabase service-role key in server environment secrets; never in browser code.
- **Financial ledger:** append-only, double-entry journal. Never let a browser directly edit an account balance.
- **Cheque clearing:** private cheque record, immutable submission snapshot, staff decision, idempotent settlement transaction and audit event.
- **Scheduled operations:** a server-side banking calendar and UTC cut-off processor; do not rely on a browser clock.

## Product rules to settle before enabling money movement

1. Define the virtual currency unit, opening balances, maximum balances and whether negative balances are forbidden.
2. Publish the airline allocation formula, measurement period, data source and manual adjustment policy.
3. Define account ownership and roles: pilot, company officer, teller/clearing staff, auditor and super-admin.
4. Require verified Discord identity, but use a secure web sign-in (OAuth or email magic link) for the portal. Discord DMs are notifications, not authentication.
5. Give every cheque a unique unpredictable public reference and a private, authenticated detail view. Do not send cheque details or bearer links in Discord embeds.
6. Define cheque lifecycle: draft → submitted → queued → approved/rejected → settled/voided. A submitted cheque must not be editable.
7. At settlement, lock both accounts, verify available funds, write debit and credit journal entries atomically, and prevent duplicate settlement with an idempotency key.
8. Define clearing days using an explicit holiday calendar and timezone UTC. A 16:30Z cut-off is not the same as the local browser time.
9. Define dispute, stop-payment, lost cheque book, account suspension, reversal and correction procedures.
10. Define staff separation of duties, limits, approval thresholds and immutable audit retention.

## Suggested database entities

- `profiles` — user identity and account status
- `bank_accounts` — individual/company account metadata
- `account_memberships` — company officers and delegated permissions
- `ledger_transactions` + `ledger_entries` — immutable double-entry ledger
- `cheque_books` + `cheques` — numbered instruments and state transitions
- `clearing_sessions` + `staff_decisions` — daily workflow
- `allocation_runs` — published company capital allocations and input snapshots
- `bank_holidays` — non-clearing dates
- `audit_events` — security-sensitive actions
- `discord_links` + `notification_outbox` — verified Discord identities and safe notifications

## Security baseline

- Enable RLS on every exposed table; deny by default.
- Use least-privilege policies and server-side authorization for all privileged actions.
- Keep service-role keys, bot tokens and signing secrets server-side only.
- Use MFA for staff and administrators.
- Rate-limit sign-in, cheque creation and sensitive actions.
- Use CSRF protection where cookie sessions are used; validate all inputs server-side.
- Store no passwords, card details or real-world bank account information.
- Log actor, timestamp, action, target and outcome; never log secrets.
- Test authorization with separate pilot, company officer, staff and administrator accounts before launch.

## Environment

No secrets are required for the public website. Backend environment variables should be added only when the Supabase project and server deployment are configured. Never commit a populated `.env` file.
