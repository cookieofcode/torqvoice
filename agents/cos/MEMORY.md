# CoS memory conventions

Portable **profile and log conventions** only. This file is not a memory store.

Do not check in episodes, chat transcripts, tool traces, secrets, subscription IDs, or people's private emails.

## Two durable layers (in git)

| Layer | Lives in | Contains |
| --- | --- | --- |
| **Profile** | `agents/cos/PROFILE.md`, `agents/specialists/*`, `agents/STANDING_RULES.md` | Role, scope, stance, standing rules |
| **Roster** | `agents/FLEET.md`, `agents/channels/*` | Who is on which channel |

Change those via PR. That is the EaC memory of *who we are*.

## What live bots may remember (not in this repo)

Live product memory (if the host stores it) may hold **working** notes: current PR number, “waiting on FinOps report,” operator apply-status. Treat that as **ephemeral**.

If a live note becomes a lasting decision (“we stay on B2s,” “no secrets in TF state”), **promote it** into standing rules, a specialist file, or `infra/azure/` — then drop it from the live scratchpad.

## Log conventions (when a host keeps a CoS log)

Use a short, scrubbed line. No payloads.

```
YYYY-MM-DD  decision|handoff|rule  <scope>  <one sentence, no secrets>
```

Examples:

- `2026-09-15  rule  infra  FinOps cost report required on every infra PR`
- `2026-09-15  handoff  devops  Azure apply remains blocked until product owner approval`

Do **not** log:

- Tokens, passwords, `DATABASE_URL`, Key Vault values
- Subscription / tenant / object IDs
- Private email addresses or personal names (use **product owner**, **operator**)
- Full specialist replies or GitHub review bodies
- Terraform plan JSON or kubeconfig

## Profile vs episode

- **Profile:** stable instructions (this tree).
- **Episode:** one conversation. Never commit episodes.
- **Template export:** snapshot of a live team. Useful to bootstrap; not the change history. See [README.md](../README.md).

## Scrub before any export

Before copying live config back into git: strip keys, account IDs, emails, transcript tails, and MCP/tool JSON schemas. Routines in this repo stay **intent-only**.
