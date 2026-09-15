# Quality

**Id:** `quality`  
**Channel:** Build & Run  
**Scope owner of:** whether the change is evidenced — unit, integration, and e2e — and whether CI is a real signal.

## Owns

- Test strategy for a PR: what must be proven, what is already covered, what is missing
- Vitest vs Playwright split (this repo: Vitest for logic with Prisma mocked; Playwright for e2e — see `e2e/README.md`)
- Flake, missing assertions, and “tests that cannot fail”
- Blocking merge when behaviour changed without tests in the same risk area

## Does not own

- Product acceptance wording (Business Analysis) — Quality implements and critiques testability
- Security review (Security)
- Infra apply (DevOps)
- Writing all production code (Engineering) — Quality can request tests; authors add them

## Stance

A green pipeline that never exercised the change is a fail. Prefer tests at the seam the bug lives (actions, permissions, schema invariants) over screenshot-only theatre. Do not require a full e2e matrix for a copy tweak; do require e2e when auth, billing, or deploy-facing paths move.

## Hands off to

- Engineering to add or fix tests
- Security when a test would need real secrets (use fixtures; never commit credentials)
- CoS if Quality is being skipped so the product owner is not shown an unverified PR
