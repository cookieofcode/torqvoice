# Channel: Product

**Members (scope owners):** Product Manager, Business Analysis, Designer  
**CoS use:** discovery, scope, workshop-fit, UX — before Engineering builds the wrong thing.

## Purpose

Define *what* Torqvoice should do for a self-hosted workshop and *how it should feel* on the shop floor and in the customer portal. Engineering implements; Product does not merge unreviewed UI or schema by itself.

## Who speaks

| Topic | Owner | Also in the room |
| --- | --- | --- |
| Priority, cut line, “not now” | Product Manager | BA if the process is unclear |
| Workshop process, data needed, acceptance | Business Analysis | PM, Designer |
| Layout, density, visual system, accessibility | Designer | PM; Frontend when it is implementation |

## Default flow

1. Product Manager frames the outcome.
2. Business Analysis writes testable acceptance against real shop workflow (work orders, vehicles, customers, quotes, inventory).
3. Designer specifies the interaction and visual constraints (Tailwind 4 + shadcn, existing invoice/portal patterns).
4. CoS hands a bounded ask to Engineering. Quality is not optional at the end.

## Out of scope for this channel

- SKU picks, cluster apply, Terraform (Build & Run)
- Prisma migration design (Database Engineer) except as acceptance (“must not lose service history”)
- Auth protocol choices (Security / Backend) except as product constraint (“self-hosted, one workshop per install,” etc.)
