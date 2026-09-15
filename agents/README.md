# Agent fleet — Everything-as-Code

This directory is the **git source of truth** for the Torqvoice Grok Bot / specialist team.

Live bots still run in the product. Humans update this tree through pull requests. After merge, **Chief of Staff / Bot** applies the checked-in manifests into the live team ([APPLY.md](APPLY.md)). Merging a PR does not mutate live bots by itself. Do not treat a live-bot edit as canonical until it is PR'd back **the same day**.

## Complementarity

| Artifact | Role |
| --- | --- |
| Team bot **template** | Portable **snapshot** of a working team (export/import, bootstrap a new space). Point-in-time. |
| This `agents/` tree | Continuous **Everything-as-Code** sync. Versioned in git, reviewed in PRs, then applied to live agents. |

Keep both. Do not replace git with a template export, and do not treat a template as the ongoing change log. After **material** fleet changes (roster, standing rules, channel membership, skill, routine/path filter), **re-export** the team template once live matches git so the snapshot stays current.

Azure infrastructure EaC (when present) lives in [`infra/azure/`](../infra/azure/) — Terraform for a lean Switzerland North stack. **This directory does not apply Terraform.** Cost review of infra PRs is a fleet *routine* (see below), not an apply.

## Product

- **Product:** Torqvoice — self-hosted workshop management
- **Repo:** https://github.com/cookieofcode/torqvoice
- **Stack:** TypeScript, Next.js 16, React 19, Tailwind 4, shadcn, Prisma 7, Postgres 16, better-auth, Docker
- **Azure (lean, IaC only):** Free AKS 1× B2s + Flexible Server B1ms, Switzerland North

## How sync works

1. Change role text, standing rules, skills, or routines **in this tree**.
2. Open a PR. Specialists verify and fix **before** the product owner is asked to accept.
3. Infra-touching PRs (path include in [routines/torqvoice-infra-pr-finops-cost.md](routines/torqvoice-infra-pr-finops-cost.md)) get a FinOps cost-implications report — see [STANDING_RULES.md](STANDING_RULES.md). App-only PRs do not wake FinOps.
4. After merge, **apply** using [APPLY.md](APPLY.md) (order, file→live map, smoke). Live titles follow the **id ↔ live name** table in [FLEET.md](FLEET.md) (`cos` → Chief of Staff / Bot). Default applier: Chief of Staff / Bot.
5. If a live bot is edited first (hotfix), PR it back here **the same calendar day**. CoS owns the SLA; **DevOps** chases if it is still missing at end of day.

## Layout

```
agents/
  README.md                 # this file
  APPLY.md                  # fleet apply runbook, ownership/SLA, last-applied marker
  STANDING_RULES.md         # fleet-wide rules
  FLEET.md                  # roster + channels
  cos/                      # Chief of Staff
  specialists/              # scope-owner personas
  channels/                 # Product, Build & Run, Engineering
  skills/                   # reusable how-to (not live transcripts)
  routines/                 # trigger intent (not baked MCP schemas)
```

## What is NOT in git

Do **not** commit:

- API keys, tokens, passwords, connection strings
- Azure subscription IDs, tenant IDs, or other cloud account identifiers
- People's private emails or personal names where a role will do (use **product owner**)
- Live chat **transcripts**, episode logs, or memory dumps
- Terraform state, `tfvars` with secrets, kubeconfigs, or Key Vault values
- Tool/MCP JSON schemas copied from a live bot (routines stay **intent-only**)

`cos/MEMORY.md` records **conventions** for profile vs log. It is not a diary.

## Optional CI

This tree is markdown. A future CI lint (not wired in this repo yet) could fail PRs that drop required `agents/` files, add secret-shaped strings, or change the routine include list without updating [APPLY.md](APPLY.md) smoke notes. Until then, reviewers check the apply runbook and path filter by eye.

## Related

- Apply runbook + last-applied: [APPLY.md](APPLY.md)
- Fleet rules: [STANDING_RULES.md](STANDING_RULES.md)
- Roster: [FLEET.md](FLEET.md)
- Infra cost skill: [skills/infra-pr-cost-report/SKILL.md](skills/infra-pr-cost-report/SKILL.md)
- Infra PR routine (path filter): [routines/torqvoice-infra-pr-finops-cost.md](routines/torqvoice-infra-pr-finops-cost.md)
- Daily fleet snapshot routine (live → git): [routines/daily-torqvoice-fleet-snapshot.md](routines/daily-torqvoice-fleet-snapshot.md)
