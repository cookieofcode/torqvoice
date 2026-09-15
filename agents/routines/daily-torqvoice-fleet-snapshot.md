# Routine: Daily Torqvoice fleet snapshot

**Id:** `daily-torqvoice-fleet-snapshot`  
**Kind:** intent only (no baked MCP / tool schemas)

Once a day, inventory the live full team against this `agents/` tree. If there is drift, open a PR. If there is none, stay quiet. This file is trigger **intent**. It is not a runnable integration spec. Merging git does not arm the live routine; see [APPLY.md](../APPLY.md).

This is the automated daily safety net for the **live → git** drift SLA in [APPLY.md](../APPLY.md) (hotfix PR the same calendar day). It does not replace that SLA, and it does not apply git → live.

## Trigger

| | |
| --- | --- |
| Repo | `cookieofcode/torqvoice` |
| Events | Cron **`0 4 * * *`** — every day at **04:00** in the product owner's local timezone |
| Days | **All days**, including weekends — the product owner asked for this explicitly |

Wire the live routine with **this schedule**. Do not skip Saturday or Sunday.

## Intent

1. Inventory the live full team against [FLEET.md](../FLEET.md) (id ↔ live name, channels, skills, routines).
2. Diff live surfaces against `agents/` (standing rules, CoS, specialists, channels, skills, routines).
3. **Scrub secrets** before anything is written to git (see [APPLY.md](../APPLY.md) Scrub). No API keys, subscription/tenant IDs, private emails, transcripts, or tool/MCP JSON.
4. If there is **no drift**, stay quiet. Do not open a PR. Do not announce that the routine fired.
5. If there **is drift**, open a PR titled `chore(agents): daily fleet snapshot YYYY-MM-DD` with the sanitized snapshot of the live team into `agents/`.
6. **Mechanical** / transcription-only drift: merge is OK (CoS).
7. **Material** role, standing-rule, channel-membership, skill, or routine changes: specialists verify **before** the product owner is asked ([STANDING_RULES.md](../STANDING_RULES.md) rule 2).
8. After a **material** landing, refresh the team bot template so the portable snapshot matches git ([README.md](../README.md) complementarity).
9. If GitHub or product auth fails **repeatedly**, **pause** the routine and surface the failure to CoS / DevOps. Do not keep retrying silently.
10. Never `terraform apply`, never Azure provision, never announce that the routine fired.

## Not this routine

- Live apply of git → bots (that is [APPLY.md](../APPLY.md), after a merged PR)
- Azure provision or `terraform apply`
- FinOps cost reports (that is [torqvoice-infra-pr-finops-cost](torqvoice-infra-pr-finops-cost.md))
- Copying live MCP tool JSON, GitHub App private keys, or webhook secrets into git
- Embedding subscription IDs or private emails
- Announcing that the cron fired when there is no drift

## Binding

After merge, CoS/Bot **applies** this intent (cron + snapshot workflow) into the live routine and marks [APPLY.md](../APPLY.md). If the live schedule or workflow drifts, PR it back the same day.
