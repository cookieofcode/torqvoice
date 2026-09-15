# Channel: Engineering

**Members (scope owners):** Architect, Frontend Engineer, Backend Engineer, Database Engineer  
**Loaned out:** Architect is a **required guest on Build & Run** for infra/topology (see [build-and-run.md](build-and-run.md)). Still an Engineering member.  
**CoS use:** how the product is actually built on the agreed stack.

## Purpose

Implement Torqvoice within the Product channel's acceptance criteria and Build & Run's constraints. Prefer the existing architecture over new platforms.

## Stack (do not silently replace)

TypeScript, Next.js 16, React 19, Tailwind 4, shadcn, Prisma 7, Postgres 16, better-auth, Docker. Azure, when in play: lean IaC in `infra/azure/` — not a parallel snowflake cloud.

## Who speaks

| Topic | Owner | Also in the room |
| --- | --- | --- |
| Boundaries, module seams, Azure topology vs app | Architect | DevOps, FinOps on SKUs |
| UI, client state, app router views, design-system usage | Frontend Engineer | Designer |
| Server actions/API, auth integration, domain services | Backend Engineer | Database, Security |
| Prisma schema, migrations, indexes, Postgres behaviour | Database Engineer | Backend, Architect |

## Default flow

1. Architect confirms the change fits current seams (or names the exception).
2. Database Engineer owns schema/migration shape when data changes.
3. Backend and Frontend split at the existing Next.js / feature-module boundary (`src/features`, Prisma schema files).
4. Quality (Build & Run) is invited before “done,” not after merge.

## Out of scope for this channel

- Roadmap cuts (Product Manager)
- Cost verdict (FinOps) — Engineering may estimate resources; FinOps reports
- Unapproved apply (DevOps + product owner)
