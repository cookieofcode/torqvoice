# Routine: Torqvoice CoS issue triage

**Id:** `torqvoice-cos-issue-triage`  
**Kind:** intent only (no baked MCP / tool schemas)

When an issue on the product repo is assigned to the product owner's GitHub handle, wake Chief of Staff / Bot to triage and route — not to implement alone.

## Trigger

| | |
| --- | --- |
| Repo | `cookieofcode/torqvoice` |
| Events | GitHub **issue assigned** to the product owner's handle (`@cookieofcode`) |
| Scope | Issues on that repo only |

Wire the live routine with **this trigger**. Do not bake MCP / tool schemas into git.

## Intent

1. Read the issue (title, body, labels). Scrub secrets if any appear in the text before routing.
2. Classify: bug / feature / support / infra / security / docs / other.
3. Route to the owning channel per [FLEET.md](../FLEET.md) (Product / Build & Run / Engineering). Assign the **scope owner**; pull adjacent specialists only when needed.
4. For infra/topology: ensure DevOps + FinOps path and **Architect** review as required for Build & Run before anything is presented to the product owner.
5. Reply on the issue with a short triage note (owner, next step). Do not dump internal debate.
6. Obey [STANDING_RULES.md](../STANDING_RULES.md): team verifies before the product owner; no secrets in git/state; EaC; no unapproved apply.

## Not this routine

- Implementing the fix in the same wake without the scope owner
- `terraform apply` or Azure provision
- FinOps cost reports for PRs (that is [torqvoice-infra-pr-finops-cost](torqvoice-infra-pr-finops-cost.md))
- Daily fleet snapshot (that is [daily-torqvoice-fleet-snapshot](daily-torqvoice-fleet-snapshot.md))
- Copying live MCP tool JSON, tokens, or private emails into git
- Auto-merging PRs

## Binding

After merge, CoS/Bot **applies** this intent into the live routine and marks [APPLY.md](../APPLY.md) when that apply happens. If the live assignee trigger drifts, PR it back the same day.
