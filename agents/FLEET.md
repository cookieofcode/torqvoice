# Fleet roster

Torqvoice specialist team. **Git id** is the filename stem / stable key. **Live name** is the title in the product. Do not rename live bots without updating this map in the same PR.

## Id ↔ live name

Canonical map for apply and smoke ([APPLY.md](APPLY.md)). Live **title** must match the Live name column (not the kebab id).

| Git path | Id | Live name |
| --- | --- | --- |
| [cos/PROFILE.md](cos/PROFILE.md) | `cos` | **Chief of Staff / Bot** |
| [specialists/product-manager.md](specialists/product-manager.md) | `product-manager` | Product Manager |
| [specialists/business-analysis.md](specialists/business-analysis.md) | `business-analysis` | Business Analysis |
| [specialists/designer.md](specialists/designer.md) | `designer` | Designer |
| [specialists/quality.md](specialists/quality.md) | `quality` | Quality |
| [specialists/security.md](specialists/security.md) | `security` | Security |
| [specialists/devops.md](specialists/devops.md) | `devops` | DevOps |
| [specialists/finops.md](specialists/finops.md) | `finops` | FinOps |
| [specialists/architect.md](specialists/architect.md) | `architect` | Architect |
| [specialists/frontend-engineer.md](specialists/frontend-engineer.md) | `frontend-engineer` | Frontend Engineer |
| [specialists/backend-engineer.md](specialists/backend-engineer.md) | `backend-engineer` | Backend Engineer |
| [specialists/database-engineer.md](specialists/database-engineer.md) | `database-engineer` | Database Engineer |
| [channels/product.md](channels/product.md) | `product` | Product |
| [channels/build-and-run.md](channels/build-and-run.md) | `build-and-run` | Build & Run |
| [channels/engineering.md](channels/engineering.md) | `engineering` | Engineering |
| [skills/infra-pr-cost-report/SKILL.md](skills/infra-pr-cost-report/SKILL.md) | `infra-pr-cost-report` | (skill id, same) |
| [routines/torqvoice-infra-pr-finops-cost.md](routines/torqvoice-infra-pr-finops-cost.md) | `torqvoice-infra-pr-finops-cost` | (routine id, same) |
| [routines/daily-torqvoice-fleet-snapshot.md](routines/daily-torqvoice-fleet-snapshot.md) | `daily-torqvoice-fleet-snapshot` | (routine id, same) |
| [routines/torqvoice-cos-issue-triage.md](routines/torqvoice-cos-issue-triage.md) | `torqvoice-cos-issue-triage` | (routine id, same) |

`cos/MEMORY.md` is conventions only — not a live bot. `APPLY.md` is the operator runbook, not pasted into a bot.

## Chief of Staff

| Id | Live name | File | Role |
| --- | --- | --- | --- |
| `cos` | Chief of Staff / Bot | [cos/PROFILE.md](cos/PROFILE.md) | Routes work, enforces standing rules, presents verified results to the product owner |

CoS is not a fourth channel. CoS **uses** the three channels below.

## Channels

| Channel (live) | File | Members (scope owners) | Required guest |
| --- | --- | --- | --- |
| **Product** | [channels/product.md](channels/product.md) | Product Manager, Business Analysis, Designer | — |
| **Build & Run** | [channels/build-and-run.md](channels/build-and-run.md) | Quality, Security, DevOps, FinOps, **Architect** (live member as of 2026-09-16; was guest-only in prior EaC — reconcile) | **Architect** still required on infra / topology |
| **Engineering** | [channels/engineering.md](channels/engineering.md) | Architect, Frontend Engineer, Backend Engineer, Database Engineer | — |

Architect stays an Engineering member. Live Build & Run currently also lists Architect as a **member** (2026-09-16 snapshot); prior EaC said guest-only for infra — reconcile with Architect/DevOps. On infra/topology, Architect review remains **required** before the product owner sees the PR.

## Specialists

| Id | Live name | Channel | Scope (short) | File |
| --- | --- | --- | --- | --- |
| `product-manager` | Product Manager | Product | Outcomes, scope, roadmap | [specialists/product-manager.md](specialists/product-manager.md) |
| `business-analysis` | Business Analysis | Product | Requirements, workshop processes, acceptance | [specialists/business-analysis.md](specialists/business-analysis.md) |
| `designer` | Designer | Product | UX, visual system, shop-floor and portal usability | [specialists/designer.md](specialists/designer.md) |
| `quality` | Quality | Build & Run | Test strategy, CI signal, regressions | [specialists/quality.md](specialists/quality.md) |
| `security` | Security | Build & Run | Auth, secrets, threat model, no secrets in state | [specialists/security.md](specialists/security.md) |
| `devops` | DevOps | Build & Run | Docker, AKS, IaC, pipelines; no unapproved apply | [specialists/devops.md](specialists/devops.md) |
| `finops` | FinOps | Build & Run | Cost on every infra PR; lean Azure posture | [specialists/finops.md](specialists/finops.md) |
| `architect` | Architect | Engineering | Boundaries, stack, Azure lean topology | [specialists/architect.md](specialists/architect.md) |
| `frontend-engineer` | Frontend Engineer | Engineering | Next.js / React / Tailwind / shadcn UI | [specialists/frontend-engineer.md](specialists/frontend-engineer.md) |
| `backend-engineer` | Backend Engineer | Engineering | App server, Prisma access, better-auth, integrations | [specialists/backend-engineer.md](specialists/backend-engineer.md) |
| `database-engineer` | Database Engineer | Engineering | Prisma schema, Postgres 16, migrations | [specialists/database-engineer.md](specialists/database-engineer.md) |

## Skills and routines

| Kind | Id | File |
| --- | --- | --- |
| Skill | `infra-pr-cost-report` | [skills/infra-pr-cost-report/SKILL.md](skills/infra-pr-cost-report/SKILL.md) |
| Routine | `torqvoice-infra-pr-finops-cost` | [routines/torqvoice-infra-pr-finops-cost.md](routines/torqvoice-infra-pr-finops-cost.md) |
| Routine | `daily-torqvoice-fleet-snapshot` | [routines/daily-torqvoice-fleet-snapshot.md](routines/daily-torqvoice-fleet-snapshot.md) |
| Routine | `torqvoice-cos-issue-triage` | [routines/torqvoice-cos-issue-triage.md](routines/torqvoice-cos-issue-triage.md) |
| Apply | last-applied + runbook | [APPLY.md](APPLY.md) |

## Default routing

1. Ambiguous or multi-scope work → CoS, then the owning channel.
2. Infra / SKU / region / cluster / topology changes → DevOps + FinOps, with **Architect as required Build & Run guest/reviewer** (+ Security if secrets or exposure).
3. User-visible workflow → Product channel first, then Engineering.
4. Auth, tenancy, or secret handling → Security before merge.
