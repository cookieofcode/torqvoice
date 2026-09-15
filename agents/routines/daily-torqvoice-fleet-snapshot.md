# Routine: Daily Torqvoice fleet snapshot

**Id:** `daily-torqvoice-fleet-snapshot`  
**Kind:** intent only (no baked MCP / tool schemas)

Once a day, inventory the live full team against this `agents/` tree. If there is drift, open a PR. If there is none, stay quiet. This file is trigger **intent**. It is not a runnable integration spec. Merging git does not arm the live routine; see [APPLY.md](../APPLY.md).

This is the automated daily safety net for the **live → git** drift SLA in [APPLY.md](../APPLY.md) (hotfix PR the same calendar day). It does not replace that SLA, and it does not apply git → live.

## Trigger

| | |
| --- | --- |
| Repo | `cookieofcode/torqvoice` |
| Events | Cron **`0 4 * * *`** — every day at **04:00** |
| Timezone | Product owner's local timezone, **pinned** — currently **Europe/Zurich** (`CRON_TZ=Europe/Zurich 0 4 * * *`). **04:00 is Zurich local**, not UTC |
| Days | **All days**, including weekends — the product owner asked for this explicitly |

Wire the live routine with **this schedule**. Do not skip Saturday or Sunday. This file is still **intent only** (cron + timezone pin; no baked MCP / tool schemas).

## Intent

1. Inventory the live full team against [FLEET.md](../FLEET.md) (id ↔ live name, channels, skills, routines).
2. Diff live surfaces against `agents/` (standing rules, CoS, specialists, channels, skills, routines).
3. **Scrub secrets** before anything is written to git (see [APPLY.md](../APPLY.md) Scrub). No API keys, subscription/tenant IDs, private emails, transcripts, or tool/MCP JSON.
4. If there is **no drift**, stay quiet. Do not open a PR. Do not announce that the routine fired.
5. If there **is drift**, open a PR titled `chore(agents): daily fleet snapshot YYYY-MM-DD` with the sanitized snapshot of the live team into `agents/`.
6. Classify the PR **before** any CoS merge. **Mechanical** is narrow: **only** pure doc, typo, or last-applied **marker** drift, with **no** role, standing-rules, channel-membership, skill, or routine-intent changes. CoS may merge those snapshot PRs.
7. **Material:** any change to roles, standing rules, channel membership, skills, or routine intent. Specialists verify **before** the product owner is asked ([STANDING_RULES.md](../STANDING_RULES.md) rule 2). CoS does **not** auto-merge material fleet changes.
8. After a **material** landing, refresh the team bot template so the portable snapshot matches git ([README.md](../README.md) complementarity).
9. If GitHub or product auth fails **repeatedly**, **pause** the routine and surface the failure to CoS / DevOps. Do not keep retrying silently.
10. Never `terraform apply`, never Azure provision, never announce that the routine fired.

## Not this routine

- Live apply of git → bots (that is [APPLY.md](../APPLY.md), after a merged PR)
- Azure provision or `terraform apply`
- FinOps cost reports (that is [torqvoice-infra-pr-finops-cost](torqvoice-infra-pr-finops-cost.md))
- Copying live MCP tool JSON, GitHub App private keys, or webhook secrets into git
- Embedding subscription IDs or private emails
- CoS auto-merging **material** fleet changes (roles, standing rules, membership, skills, routine intent)
- Announcing that the cron fired when there is no drift

## Binding

After merge, CoS/Bot **applies** this intent (cron + snapshot workflow) into the live routine and marks [APPLY.md](../APPLY.md). If the live schedule or workflow drifts, PR it back the same day.
