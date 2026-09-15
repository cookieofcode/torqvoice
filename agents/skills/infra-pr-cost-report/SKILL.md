---
name: infra-pr-cost-report
description: Produce a cost-only FinOps report for infrastructure PRs (Terraform, Kubernetes, SKUs, disks, IPs, databases, regions). Use on every infra-touching PR in cookieofcode/torqvoice. Output verdict, ballpark, blockers, should-fix, nice-to-have, and risks — no apply, no secret values.
---

# Infra PR cost-implications report

FinOps **how**. Scope owner: [finops.md](../../specialists/finops.md). Standing rule: cost report on every infra PR.

This skill produces a **cost-only** report. It is not a feature review, security review, or apply checklist (those belong to other specialists). Do not run `terraform apply`. Do not paste subscription IDs, account numbers, or secret values.

## When to run

**Canonical path filter:** the include/exclude lists in [torqvoice-infra-pr-finops-cost.md](../../routines/torqvoice-infra-pr-finops-cost.md). Run this skill when that routine fires — do not invent a second path heuristic.

In short: `infra/**`, root `docker-compose*.yml` / `compose*.yml`, `.github/workflows/deploy-*.yml`, `rollback-*.yml`, and `docker-publish.yml`. Not `src/**`, not `agents/**`, not `.devcontainer/**`, not app CI workflows.

## Inputs (non-secret)

- PR diff and proposed resource list (names, SKUs, counts, region)
- Stated posture: lean Azure — Switzerland North, AKS **Free** 1× **B2s**, Flexible Server **B1ms**, IaC only
- Whether HA, extra IPs, extra nodes, or observability add-ons appear

If a price sheet or live bill is unavailable, **say so** and still give a ballpark with assumptions.

## Output format (required)

Use these headings, in this order. Cost-only. Short bullets.

### Verdict

One of:

- **Acceptable (lean)** — stays inside the agreed posture; no material new spend
- **Acceptable with should-fix** — shippable for cost, but fix listed items soon
- **Block apply** — cost, waste, or SKU/region change must be resolved before the product owner is asked to approve apply

One sentence why.

### Ballpark

- Monthly run-rate for the *proposed* shape (CHF/USD band is enough)
- Delta vs current lean baseline (AKS Free 1× B2s + Flexible Server B1ms + one PIP + small disk + Key Vault/state storage pennies)
- What is **not** included (egress, snapshots, support, accidental `:latest` pull chatter, Let's Encrypt retry storms)

Do not claim cent-precision. Cite SKUs and counts, not account IDs.

### Blockers

Cost or waste that **must** change before apply approval. Empty list is allowed (“none”).

Examples: second public IP, paid AKS tier, larger VM family without product-owner buy-in, HA Postgres on a single-node app, App Gateway WAF, Log Analytics workspace “for completeness,” extra region.

### Should-fix

Items that should land in this PR or immediately after: missing budget *recommendation*, idle public IP, disk oversized vs stated need, TLS add-ons crowding the same B2s without a RAM note.

### Nice-to-have

Optional savings or clarity: better tags, documented PIP reuse, comment on single-node RWO downtime vs cost.

### Risks

Cost risks if this ships as-is: SKU autoscale not in git, NAT gateway surprise, backup retention, data-transfer, cert-manager on a memory-tight node, “temporary” resources that never turn off.

## Rules

- Compare against the **lean** baseline, not against a hypothetical large production estate.
- Single-node + RWO + no Postgres HA is an **accepted cost trade** unless the PR quietly reverses it (that is a cost *and* architecture event — still report the cost; Architect owns topology).
- Security-required controls can still be **cost blockers** if they add large always-on SKUs; say so and hand the control vs bill trade to CoS (Security owns whether the control is required).
- Never recommend apply. Never embed credentials, connection strings, or subscription IDs.

## Audience

CoS pastes this report (scrubbed) for the product owner. Specialists may argue in the PR; this artifact stays cost-only.
