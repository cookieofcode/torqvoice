# Routine: Torqvoice infra PR → FinOps cost report

**Id:** `torqvoice-infra-pr-finops-cost`  
**Kind:** intent only (no baked MCP / tool schemas)

When a PR can change **run-rate**, ask FinOps and put a cost-only report in front of the product owner. This file is trigger **intent** plus an explicit **path filter**. It is not a runnable integration spec. Merging git does not arm the live routine; see [APPLY.md](../APPLY.md).

## Trigger

| | |
| --- | --- |
| Repo | `cookieofcode/torqvoice` |
| Events | GitHub **`pr-opened`**, **`pr-pushed`** |
| Paths | Fire only if the PR diff matches **at least one include** below |

## Path include (wake FinOps)

Treat the PR as infra-touching **only** when a changed file matches any of these globs (GitHub-style, repo-relative):

```
infra/**
docker-compose.yml
docker-compose*.yml
compose.yml
compose*.yml
.github/workflows/deploy-*.yml
.github/workflows/rollback-*.yml
.github/workflows/docker-publish.yml
```

| Glob | Meaning |
| --- | --- |
| `infra/**` | Azure Terraform, Helm, Kubernetes, bootstrap/state (all deploy IaC under `infra/`) |
| `docker-compose.yml`, `docker-compose*.yml`, `compose.yml`, `compose*.yml` | **Repository root** compose for the self-hosted runtime — not nested paths |
| `.github/workflows/deploy-*.yml` | Cloud deploy workflows |
| `.github/workflows/rollback-*.yml` | Cloud rollback workflows |
| `.github/workflows/docker-publish.yml` | Image publish used by those deploys |

Wire the live routine with **this list**. Do not use a vague “might affect cost” heuristic. Nested compose (for example `.devcontainer/docker-compose.yml`) is **not** included.

## Path exclude (do not wake FinOps)

Do **not** fire on app-only or fleet-doc PRs, including:

- `src/**`, `messages/**`, `prisma/**`, `e2e/**`, `assets/**`
- `agents/**` (this EaC tree does not change Azure spend)
- `.devcontainer/**` (local/dev compose, not production run-rate)
- `.github/workflows/ci.yml`, `e2e.yml`, `labeler.yml`, `release-drafter.yml`, `docker-dev.yml`
- `package.json` / lockfile-only changes without an include-path hit

A PR that only touches excluded paths is **not** an infra PR. Standing rule 3 still means “every infra PR,” not “every PR.”

## Intent (when include matched)

1. Ask **FinOps** for a cost-only report via [../skills/infra-pr-cost-report/SKILL.md](../skills/infra-pr-cost-report/SKILL.md) (verdict, ballpark, blockers, should-fix, nice-to-have, risks).
2. Report that result to the **product owner** (via CoS). Do not wait for them to notice the PR.
3. If verdict is **block apply**, keep Azure apply off the table until DevOps (and Architect/Security as needed) fix the PR.

## Not this routine

- `terraform apply` or any provision
- Security, Quality, or feature review
- Copying live MCP tool JSON, GitHub App private keys, or webhook secrets into git
- Embedding subscription IDs or private emails in the report
- Firing because someone mentioned SKUs in a comment with no include-path diff

## Binding

After merge, CoS/Bot **applies** this intent (path filter included) into the live routine and marks [APPLY.md](../APPLY.md). If the live filter drifts, PR it back the same day.
