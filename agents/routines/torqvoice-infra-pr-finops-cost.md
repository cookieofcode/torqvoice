# Routine: Torqvoice infra PR → FinOps cost report

**Id:** `torqvoice-infra-pr-finops-cost`  
**Kind:** intent only (no baked MCP / tool schemas)

When infrastructure cost might change, ask FinOps and put a cost-only report in front of the product owner. Operators still apply live bots from git; this file is the **trigger intent**, not a runnable integration spec.

## Trigger (intent)

On GitHub **`pr-opened`** or **`pr-pushed`** for repository **`cookieofcode/torqvoice`**, if the pull request touches infrastructure paths or other cost-bearing deploy config.

Treat as infra-touching when the diff includes, for example:

- `infra/**` (Terraform, Helm, Kubernetes, bootstrap/state)
- SKU, node count, disk, public IP, region, HA, or equivalent cloud resource changes
- New always-on managed services

Do not fire this routine for unrelated app-only PRs.

## Intent

1. Identify that the PR can change run-rate.
2. Ask **FinOps** to produce a cost-only report using [../skills/infra-pr-cost-report/SKILL.md](../skills/infra-pr-cost-report/SKILL.md) (verdict, ballpark, blockers, should-fix, nice-to-have, risks).
3. Report that result to the **product owner** (via CoS). Do not wait for the product owner to notice the PR unaided.
4. If FinOps verdict is **block apply**, keep apply off the table until DevOps (and Architect/Security as needed) fix the cost issues in the PR.

## Not this routine

- `terraform apply` or any provision
- Security, Quality, or feature review (other specialists; standing rule still says they verify before the product owner)
- Copying live MCP tool JSON, GitHub App private keys, or webhook secrets into git
- Embedding subscription IDs or private emails in the report

## Binding

Live Grok routines should be **applied from this intent** after the PR that changes it merges. If the live routine drifts, PR the intent back here. Do not commit host-specific schema blobs.
