# Channel: Build & Run

**Members (scope owners):** Quality, Security, DevOps, FinOps, **Architect**  
**Live note (2026-09-16 snapshot):** Architect is a **live member** of Build & Run (present in channel memberIds). Prior EaC policy treated Architect as Engineering member + **required guest** on infra/topology only. Reconcile member-vs-guest with Architect / DevOps before treating either as final.  
**Infra/topology:** Architect review remains **required** before the product owner sees the work.  
**CoS use:** “can we ship and operate this without blowing the bill, the threat model, CI, or the agreed architecture?”

## Purpose

Keep Torqvoice shippable: tests that mean something, secrets that never land in Terraform state or git, lean Azure that stays IaC-only, and a cost report on every infra PR.

## Who speaks

| Topic | Owner | Also in the room |
| --- | --- | --- |
| Test plan, flake, coverage of the change, e2e vs unit | Quality | Engineering authors |
| Auth, RBAC, SSRF, secret flow, exposure | Security | Backend, DevOps |
| Docker, AKS, pipelines, Terraform layout, apply/no-apply | DevOps | **Architect (required)**, FinOps, Security |
| SKU, region, idle waste, budget, infra PR cost report | FinOps | DevOps, **Architect (required if topology/SKU class changes)** |
| Topology vs lean Azure posture (B2s / B1ms / CH North / single-node) | Architect (guest) | DevOps, FinOps |

## Default flow

1. DevOps states what will change in runtime topology (or “app-only, no infra”).
2. If infra or topology changes: **Architect reviews as guest** (shape vs lean posture) in this channel — required, not optional.
3. If infra paths change: FinOps runs [infra-pr-cost-report](../skills/infra-pr-cost-report/SKILL.md) **before** the product owner is asked to accept. See [torqvoice-infra-pr-finops-cost](../routines/torqvoice-infra-pr-finops-cost.md).
4. Security signs secret handling and attack surface (no secrets in state).
5. Quality says what evidence is required to merge.
6. **No `terraform apply`** until the product owner explicitly approves.

## Standing constraints

- Azure: Switzerland North, lean — Free AKS 1× B2s, Flexible Server B1ms, IaC only.
- Secret values: out of band (Key Vault / seed scripts), not in git, not in TF state.
- Cost report is cost-only (verdict, ballpark, blockers, should-fix, nice-to-have, risks) — not a feature review.
