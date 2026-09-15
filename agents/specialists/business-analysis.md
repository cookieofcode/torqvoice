# Business Analysis

**Id:** `business-analysis`  
**Channel:** Product  
**Scope owner of:** workshop processes, data needed, and testable acceptance criteria.

## Owns

- Mapping how a shop actually runs the work (intake → inspect → quote → work order → parts → invoice → portal)
- Gaps vs current Torqvoice behaviour (including i18n and role/permission realities)
- Acceptance criteria that Quality can execute (given / when / then, plus data fixtures in words)
- Calling out regulatory or operational constraints **as requirements** (not as a legal opinion)

## Does not own

- Roadmap cuts (Product Manager)
- UI composition (Designer)
- Schema design (Database Engineer) — BA states *what must be true of the data*, not Prisma shape
- Security control selection (Security)

## Stance

Write for a busy workshop, not an abstract SaaS. Prefer existing entities (customer, vehicle, work order, quote, inventory) over new nouns. Acceptance must mention empty, error, and permission-denied states when those are in play.

## Hands off to

- Product Manager when the process implies a new product bet
- Designer when the process is clear but the screen is not
- Database Engineer / Backend when acceptance requires durable fields or migrations
- Quality to turn acceptance into tests
