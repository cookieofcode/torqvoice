# Standing rules

Fleet-wide. Chief of Staff enforces these; specialists apply them in their scope. Product-owner exceptions are explicit and PR'd.

## 1. Everything-as-Code

Product, Azure topology, and this agent fleet are defined in git.

- Change the live Grok team **from** this `agents/` tree after a merged PR, using [APPLY.md](APPLY.md). Default applier: **Chief of Staff / Bot**. Live hotfix: PR back **the same day**; CoS owns the SLA, DevOps chases if it is still missing.
- Change Azure **from** `infra/azure/` (Terraform / checked-in manifests). No console snowflakes.
- Do not `terraform apply` (or otherwise provision) without the product owner's explicit approval. Plan/validate/fmt are fine. Fleet apply ≠ Terraform apply.

## 2. Team verifies and fixes before the product owner

Specialists review, reproduce, and **fix** in the PR. The product owner sees work that already passed the relevant channels — not a pile of open blockers.

- Route by [FLEET.md](FLEET.md) and the channel files.
- CoS does not substitute for Quality, Security, DevOps, or FinOps sign-off in their scopes.
- Present a short verified summary, not raw specialist debate.

## 3. FinOps cost on every infra PR

Any PR whose diff matches the **path include list** in [routines/torqvoice-infra-pr-finops-cost.md](routines/torqvoice-infra-pr-finops-cost.md) **must** include a cost-implications report from FinOps. App-only PRs (`src/**`, `agents/**`, and other excludes in that file) do not.

- Use [skills/infra-pr-cost-report/SKILL.md](skills/infra-pr-cost-report/SKILL.md).
- Cost-only: verdict, ballpark, blockers, should-fix, nice-to-have, risks.
- No Azure apply. No “we’ll see the bill later.”

## 4. No secrets in Terraform state (or in this tree)

Secret **values** do not belong in Terraform state, git, live-bot memory dumps, or specialist transcripts checked in here.

- Passwords, `BETTER_AUTH_SECRET`, API keys, kube admin client keys: Key Vault / out-of-band seed, not `random_password` in state, not `kubernetes_secret` data managed by Terraform.
- Prefer write-only / ephemeral patterns over attributes Terraform would persist.
- This `agents/` tree names **roles and flows**, never credentials, subscription IDs, or private emails.

If a PR would store a secret in state or git: **blocker**. Do not present it to the product owner until Security + DevOps have a design that keeps values out.

## 5. No email connection for the team fleet

The specialist team does **not** use an email connector / inbox integration for CoS or specialists.

- Do not connect team bots to personal or shared mailboxes.
- Product email features inside Torqvoice (templates, sending from the app) are product Engineering scope — not a fleet mail connector.
- Prefer in-product channels, GitHub, and the checked-in routines for ops signal.

## 6. Torqvoice images via owned GHCR

Publish and pull Torqvoice deploy images from the **owned** package namespace `ghcr.io/cookieofcode/torqvoice`.

- Do **not** rely on upstream `ghcr.io/torqvoice/torqvoice` for continuous deploy when the product owner has no write access there.
- Prefer the owned GHCR path (with `packages:write` on the publishing token) over Azure ACR unless the product owner explicitly asks for ACR.
- Image tags and publish workflows stay in git (EaC); no portal snowflake registries.
