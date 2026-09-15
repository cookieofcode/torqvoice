# Fleet roster

Torqvoice specialist team. Live bots are named to match these ids. Update this file when the roster or channel membership changes.

## Chief of Staff

| Id | File | Role |
| --- | --- | --- |
| `cos` | [cos/PROFILE.md](cos/PROFILE.md) | Routes work, enforces standing rules, presents verified results to the product owner |

CoS is not a fourth channel. CoS **uses** the three channels below.

## Channels

| Channel | File | Members (scope owners) |
| --- | --- | --- |
| **Product** | [channels/product.md](channels/product.md) | Product Manager, Business Analysis, Designer |
| **Build & Run** | [channels/build-and-run.md](channels/build-and-run.md) | Quality, Security, DevOps, FinOps |
| **Engineering** | [channels/engineering.md](channels/engineering.md) | Architect, Frontend Engineer, Backend Engineer, Database Engineer |

## Specialists

| Id | Channel | Scope (short) | File |
| --- | --- | --- | --- |
| `product-manager` | Product | Outcomes, scope, roadmap | [specialists/product-manager.md](specialists/product-manager.md) |
| `business-analysis` | Product | Requirements, workshop processes, acceptance | [specialists/business-analysis.md](specialists/business-analysis.md) |
| `designer` | Product | UX, visual system, shop-floor and portal usability | [specialists/designer.md](specialists/designer.md) |
| `quality` | Build & Run | Test strategy, CI signal, regressions | [specialists/quality.md](specialists/quality.md) |
| `security` | Build & Run | Auth, secrets, threat model, no secrets in state | [specialists/security.md](specialists/security.md) |
| `devops` | Build & Run | Docker, AKS, IaC, pipelines; no unapproved apply | [specialists/devops.md](specialists/devops.md) |
| `finops` | Build & Run | Cost on every infra PR; lean Azure posture | [specialists/finops.md](specialists/finops.md) |
| `architect` | Engineering | Boundaries, stack, Azure lean topology | [specialists/architect.md](specialists/architect.md) |
| `frontend-engineer` | Engineering | Next.js / React / Tailwind / shadcn UI | [specialists/frontend-engineer.md](specialists/frontend-engineer.md) |
| `backend-engineer` | Engineering | App server, Prisma access, better-auth, integrations | [specialists/backend-engineer.md](specialists/backend-engineer.md) |
| `database-engineer` | Engineering | Prisma schema, Postgres 16, migrations | [specialists/database-engineer.md](specialists/database-engineer.md) |

## Skills and routines

| Kind | Id | File |
| --- | --- | --- |
| Skill | `infra-pr-cost-report` | [skills/infra-pr-cost-report/SKILL.md](skills/infra-pr-cost-report/SKILL.md) |
| Routine | `torqvoice-infra-pr-finops-cost` | [routines/torqvoice-infra-pr-finops-cost.md](routines/torqvoice-infra-pr-finops-cost.md) |
| Apply | last-applied + runbook | [APPLY.md](APPLY.md) |

## Default routing

1. Ambiguous or multi-scope work → CoS, then the owning channel.
2. Infra / SKU / region / cluster changes → DevOps + FinOps (+ Security if secrets or exposure; Architect if topology).
3. User-visible workflow → Product channel first, then Engineering.
4. Auth, tenancy, or secret handling → Security before merge.
