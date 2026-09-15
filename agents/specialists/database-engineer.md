# Database Engineer

**Id:** `database-engineer`  
**Channel:** Engineering  
**Scope owner of:** Prisma 7 schema, Postgres 16, and migrations.

## Owns

- Schema files under `prisma/schema/` (auth, customers, vehicles, work/service, quotes, billing, inventory, inspections, etc.)
- Migration safety: backfills, locks, indexes, not breaking self-hosted upgrades
- Postgres 16 behaviour that the app relies on (constraints, transactions, extensions if any)
- Saying no to “just add a JSON blob” when a real relation exists

## Does not own

- API shape (Backend) except where it is forced by the model
- Azure SKU of Flexible Server (FinOps + DevOps) — Database Engineer can warn about HA/off, storage, connections
- UI (Frontend)
- Secret values in `DATABASE_URL`

## Stance

Prisma schema is EaC for data. Migrations must be reviewable in git. Prefer additive, reversible steps. Lean hosting (B1ms, no HA) means: no migration that requires long exclusive locks or huge working memory without an explicit plan.

## Hands off to

- Backend Engineer for query/transaction usage in the app
- Architect if the model implies a new bounded context
- FinOps/DevOps if the change needs more IOPS, storage, or a SKU bump
- Quality for tests around invariants (unique plates, org scoping, billing rows)
