# Bank Regensburg Discord bot — setup guide

This bot is a separate Node.js service inside the repository. Upload the **contents of this `discord-bot` directory** to your bot host, not the whole website repository. Node.js 20 or newer is required.

## 1. Create the Discord application

1. Open the Discord Developer Portal and create an application named **Bank Regensburg**.
2. Under **Bot**, add a bot and copy its token. Keep it private.
3. Under **OAuth2 → General**, copy the Application (Client) ID.
4. Use OAuth2 URL Generator with the `bot` and `applications.commands` scopes. Invite it to your bank server. It does not need Administrator permission; the slash commands and ephemeral replies need no privileged message intents.
5. Copy your server ID (enable Developer Mode in Discord, then right-click the server → Copy Server ID). Set it as `DISCORD_GUILD_ID` for instant guild command registration during setup. Remove it later if you prefer global commands.

## 2. Prepare Supabase

The database migration is in `supabase/migrations/`. It is also already applied to the configured Bank Regensburg project. In Supabase Project Settings → API, copy the **Project URL** and the **service_role** secret. The service-role key bypasses Row Level Security: it belongs only in your bot host's encrypted environment settings and must never be committed, shared in Discord, or added to Vite variables.

Set these environment variables in your host:

| Variable | Value |
|---|---|
| `DISCORD_TOKEN` | Bot token from Discord Developer Portal |
| `DISCORD_CLIENT_ID` | Discord application ID |
| `DISCORD_GUILD_ID` | Your bank server ID (optional, recommended for setup) |
| `SUPABASE_URL` | `https://pfcmwxkphcgmupiltjti.supabase.co` |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service_role secret |
| `PORTAL_URL` | Your deployed website URL |
| `POLL_INTERVAL_MS` | Optional; defaults to 15000 |

Do not commit a populated `.env` file.

## 3. Install and register commands

In the bot directory run:

```bash
npm install
npm run register
npm start
```

Configure your host's start command as `npm start`. Keep the process running continuously. Use `npm run register` again after changing slash-command definitions.

## 4. Commands

- `/link code:<code>` — links a member's Discord ID to their authenticated bank profile. The one-time code is generated inside the signed-in portal, expires after 10 minutes, and is stored only as a SHA-256 hash. The response is ephemeral.
- `/my-account` — displays the linked member's account numbers and virtual balances privately.
- `/bank-status` — displays the UTC clearing schedule.
- `/clearing-queue` — staff-only view of queued cheque references and amounts. Staff authorization is checked against the active Supabase profile role, not a Discord role name.

The bot polls the notification outbox and sends a short private DM when a cheque is submitted or reviewed. Detailed cheque information remains in the authenticated web portal. If a user has DMs closed, the bot logs the delivery attempt and continues; it does not expose private details in a public channel.

## 5. First administrator and staff setup

1. Create your first user through the website portal and confirm their email.
2. In Supabase SQL Editor, promote that exact Auth user UUID to active admin (replace the placeholder):

```sql
update public.profiles
set role = 'admin', status = 'active'
where id = 'YOUR_AUTH_USER_UUID';
```

3. Promote your profile to active admin, then open /admin. Create an operating treasury account and issue its initial virtual supply using the controlled issuance tool. Create personal/corporate accounts, assign members, issue cheque books, and configure bank holidays from the administration console. Do not manually edit balances; balances are calculated from the ledger.
4. Create member/company accounts and memberships, issue 30-cheque personal books or 150-cheque corporate books, and assign active staff roles. The current starter portal intentionally does not expose account creation, book issuance, treasury funding, or role promotion to public users.
5. For every staff member, link their Discord identity and set the approved role/status in Supabase.

## 6. Cheque clearing rules

Cheques are submitted from the signed-in portal and enter the staff queue. The database settlement function enforces active staff, queued status, Monday–Friday, the UTC 16:30 cut-off, bank holidays, sufficient funds, and an idempotency key. The staff review operation is exposed to authenticated staff in the database; the public bot queue command is read-only. Use the web staff console for review once the staff dashboard is enabled.

## 7. Security checklist

- Never share or commit the Discord token or Supabase service-role key.
- Do not grant the bot Administrator permission.
- Enable MFA for all bank staff and Supabase administrators.
- Keep the bot process and dependencies updated; rotate credentials immediately if exposed.
- Test with separate pilot, company officer, staff and admin users before issuing virtual funds.
- Use a private Discord server and keep the bot's replies ephemeral/DM-only.
- This system is for fictional virtual currency only. Do not connect real payment rails or collect real banking credentials.

## Troubleshooting

- **Commands do not appear:** check `DISCORD_CLIENT_ID`, token and guild ID, then run `npm run register` again.
- **Invalid/expired link code:** generate a fresh code in the portal and run `/link` within 10 minutes.
- **Bot starts then exits:** check Node.js 20+, all required environment variables and host logs.
- **Supabase permission errors:** confirm the URL and service-role key belong to the Bank Regensburg project. Never put the service-role key in the website.
- **DMs fail:** members must allow server-member DMs. Their portal and cheque data remain accessible without Discord DMs.
