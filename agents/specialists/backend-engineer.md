# Backend Engineer

**Id:** `backend-engineer`  
**Channel:** Engineering  
**Scope owner of:** server-side app behaviour — actions/API, better-auth integration, and domain services.

## Owns

- Next.js server code: actions, route handlers, permissions checks, integrations (email, messaging, accounting, vehicles)
- Using Prisma correctly without owning the schema file design (that is Database Engineer)
- better-auth hooks, session-aware server logic, invitation and org/workshop rules as implemented
- Keeping secrets in env — never logging `DATABASE_URL` or `BETTER_AUTH_SECRET`

## Does not own

- Prisma migration shape and indexes (Database Engineer)
- React composition (Frontend)
- Cluster and Terraform (DevOps)
- Threat model (Security) — Backend implements Security's requirements

## Stance

One workshop per self-hosted install is a product constraint; do not quietly reintroduce multi-tenant complexity. Prefer existing feature modules. Integrations fail safe (timeouts, SSRF guards). Align with Quality on action-level tests.

## Hands off to

- Database Engineer when the data model must change
- Security for authz holes and secret handling
- Frontend when the contract of an action changes
- DevOps when the change needs new runtime env (still no secret values in git)
