# Fleet apply (live Grok team)

Operator runbook for copying this `agents/` tree into the **live** specialist team. Merging a git PR does **not** mutate live bots by itself.

This is **not** `terraform apply`. Azure provision stays gated in `infra/azure/` and [STANDING_RULES.md](STANDING_RULES.md).

## Last applied

Placeholder until the first post-merge fleet apply. Update this table in a follow-up PR **as part of the apply**, not before.

| Field | Value |
| --- | --- |
| Git commit | _pending — not yet applied_ |
| Date (UTC) | _pending_ |
| Applied by | _pending_ (role: Chief of Staff / Bot) |

Record the short SHA of `main` (or the merge commit) that was copied live. No subscription IDs, no personal emails.

## Ownership and drift SLA

| | |
| --- | --- |
| **Who applies (default)** | **Chief of Staff / Bot** — the live CoS, or a human acting in that role. Not the product owner. |
| **When** | After `agents/` changes merge to the default branch. Same working day as merge when possible. |
| **Live hotfix** | If the live team is edited first (emergency instruction), **PR the drift back into `agents/` the same calendar day** (UTC). Git remains canonical. |
| **Who chases** | CoS is accountable for the SLA. If a live change is still not PR'd by end of that day, **DevOps** chases CoS. Escalate to the product owner only if still open the next working day. |

DevOps owns Azure/IaC apply (separately, still no unapproved `terraform apply`). DevOps does not own day-to-day fleet apply unless CoS is unavailable.

## File → live bot

Copy **text** from git. Do not paste MCP/tool JSON, transcripts, or secrets.

**Names:** use the **Id ↔ live name** table in [FLEET.md](FLEET.md). Example: `cos/PROFILE.md` → live title **Chief of Staff / Bot** (id `cos`). `specialists/architect.md` → live **Architect**. Do not leave live titles as kebab-case ids.

| Git path | Live surface |
| --- | --- |
| [STANDING_RULES.md](STANDING_RULES.md) | Team standing instructions / team rules |
| [cos/PROFILE.md](cos/PROFILE.md) | Agent **Chief of Staff / Bot** (`cos`) |
| [cos/MEMORY.md](cos/MEMORY.md) | CoS memory *conventions* only (not an episode log) |
| [FLEET.md](FLEET.md) | Roster + id↔live name map (not a separate bot) |
| [specialists/*.md](specialists/) | Specialist agent whose **live name** matches the FLEET map |
| [channels/*.md](channels/) | Channel **Product** / **Build & Run** / **Engineering** + membership |
| [skills/infra-pr-cost-report/SKILL.md](skills/infra-pr-cost-report/SKILL.md) | Skill `infra-pr-cost-report` |
| [routines/torqvoice-infra-pr-finops-cost.md](routines/torqvoice-infra-pr-finops-cost.md) | Routine `torqvoice-infra-pr-finops-cost` (intent + **path include list**; wire the GitHub trigger in the product — no baked schemas in git) |
| [routines/daily-torqvoice-fleet-snapshot.md](routines/daily-torqvoice-fleet-snapshot.md) | Routine `daily-torqvoice-fleet-snapshot` (intent + **daily cron** `CRON_TZ=Europe/Zurich 0 4 * * *`; wire in the product — no baked schemas in git). This is **live → git** drift capture, not fleet apply. |
| [routines/torqvoice-cos-issue-triage.md](routines/torqvoice-cos-issue-triage.md) | Routine `torqvoice-cos-issue-triage` (intent + **issue-assigned** to product owner handle; wire in the product — no baked schemas in git) |
| This file (`APPLY.md`) | Operator runbook + last-applied marker — **not** pasted into a bot |

## Apply order

Do this sequence so rules exist before agents that must obey them, and the routine exists only after FinOps and the skill are in place.

1. **Standing rules** — `STANDING_RULES.md` → team rules.
2. **CoS** — `cos/PROFILE.md` → live **Chief of Staff / Bot** (then `cos/MEMORY.md` conventions if the host has a memory-config slot).
3. **Specialists** — each `specialists/<id>.md` to the live agent whose **title** is the FLEET live name (e.g. `frontend-engineer.md` → Frontend Engineer). Create missing agents from the map; do not rename ids or titles ad hoc.
4. **Channels** — `channels/product.md`, `build-and-run.md`, `engineering.md` (membership must match FLEET.md).
5. **Skill** — `infra-pr-cost-report`.
6. **Routines** — arm in this order when applying:
   - `torqvoice-infra-pr-finops-cost`: GitHub `pr-opened` / `pr-pushed` on `cookieofcode/torqvoice`; **path filter = the include list in the routine file**. Confirm **armed**.
   - `daily-torqvoice-fleet-snapshot`: cron `CRON_TZ=Europe/Zurich 0 4 * * *` (all days). Confirm **armed** when that file (or its APPLY wiring) changed.
   - `torqvoice-cos-issue-triage`: GitHub issue-assigned to the product owner handle on `cookieofcode/torqvoice`. Confirm **armed** when that file changed.
7. **Marker** — set *Last applied* above; open/push that git update if the apply happened on already-merged `main`. (A live→git **snapshot** PR does **not** update this marker.)
8. **Template (material changes)** — re-export the team bot template so the portable snapshot matches git. Do not treat the export as the change log.

Partial apply: if the PR only changed one specialist, still **verify** standing rules, channel membership, and that the routine is armed (smoke below). You may skip re-pasting unchanged profiles.

## CoS checklist

Default applier is **Chief of Staff / Bot**. Walk this list on every fleet apply **and** whenever live was edited first.

1. Apply git → live in the order above (or confirm unchanged profiles still match).
2. Run the **verify** smoke below (names, membership, routine armed).
3. **Hotfix → same-day PR:** if live was changed before git, open/update the `agents/` PR **the same calendar day (UTC)**. Do not wait for DevOps to chase. This is the drift SLA; CoS owns it.
4. If the change was infra/topology: confirm **Architect review still required** in Build & Run.
5. Update *Last applied* (follow-up commit on `main` if apply was after merge).
6. On material fleet changes: re-export the team template after smoke passes.

## Verify live matches git (smoke)

After apply, all of these must pass:

- **Id ↔ live name:** every row in [FLEET.md](FLEET.md) exists live; **live title equals the Live name column** (`cos` is titled Chief of Staff / Bot, not `cos`); no extra specialists unless documented in the same PR.
- **Channel membership:** Product / Build & Run / Engineering members match FLEET.md and the three channel files. Live Build & Run lists Architect as a **member** (not guest-only). Architect review remains **required** on infra/topology. If live membership and docs still disagree, reconcile explicitly — do not leave split-brain.
- **Routine armed:** `torqvoice-infra-pr-finops-cost` is enabled; repo is `cookieofcode/torqvoice`; events include `pr-opened` and `pr-pushed`; path include list matches the routine file (so app-only PRs do not wake FinOps).
- **Routine armed (when those files changed):** `daily-torqvoice-fleet-snapshot` cron matches the routine file; `torqvoice-cos-issue-triage` issue-assigned trigger matches the routine file.
- **Skill present:** `infra-pr-cost-report` is attached or callable from the FinOps routine. Prefer the curated git skill body over a thinner live workflow copy when they diverge.
- **Rules present:** team standing instructions still match `STANDING_RULES.md` (spot-check all rules, including no fleet email connector and owned GHCR images).
- **Marker:** *Last applied* commit is the SHA you copied.
- **Hotfix PR:** if this apply was catching up to a live edit, the git PR exists **today**.

If smoke fails, fix live **or** git the same day — do not leave split-brain.

## Scrub

Never copy into live or git: API keys, subscription/tenant IDs, private emails, transcripts, Terraform state, kubeconfigs. Say **product owner**.
