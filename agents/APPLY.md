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

## File → live surface

Copy **text** from git. Do not paste MCP/tool JSON, transcripts, or secrets. Live agent **ids** must match [FLEET.md](FLEET.md).

| Git path | Live surface |
| --- | --- |
| [STANDING_RULES.md](STANDING_RULES.md) | Team standing instructions / team rules |
| [cos/PROFILE.md](cos/PROFILE.md) | CoS agent profile (id `cos`) |
| [cos/MEMORY.md](cos/MEMORY.md) | CoS memory *conventions* only (not an episode log) |
| [FLEET.md](FLEET.md) | Roster check: names, ids, channel membership (not a separate bot) |
| [specialists/*.md](specialists/) | Specialist agent profile per file id |
| [channels/*.md](channels/) | Channel description + membership |
| [skills/infra-pr-cost-report/SKILL.md](skills/infra-pr-cost-report/SKILL.md) | Skill `infra-pr-cost-report` |
| [routines/torqvoice-infra-pr-finops-cost.md](routines/torqvoice-infra-pr-finops-cost.md) | Routine `torqvoice-infra-pr-finops-cost` (intent + **path include list**; wire the GitHub trigger in the product — no baked schemas in git) |
| This file (`APPLY.md`) | Operator runbook + last-applied marker — **not** pasted into a bot |

## Apply order

Do this sequence so rules exist before agents that must obey them, and the routine exists only after FinOps and the skill are in place.

1. **Standing rules** — `STANDING_RULES.md` → team rules.
2. **CoS** — `cos/PROFILE.md` (then `cos/MEMORY.md` conventions if the host has a memory-config slot).
3. **Specialists** — each `specialists/*.md` to the matching live agent id (`product-manager`, `architect`, …). Create missing agents from [FLEET.md](FLEET.md); do not rename ids.
4. **Channels** — `channels/product.md`, `build-and-run.md`, `engineering.md` (membership must match FLEET.md).
5. **Skill** — `infra-pr-cost-report`.
6. **Routine** — `torqvoice-infra-pr-finops-cost`: instructions from the markdown; GitHub `pr-opened` / `pr-pushed` on `cookieofcode/torqvoice`; **path filter = the include list in the routine file**. Confirm it is **armed**.
7. **Marker** — set *Last applied* above; open/push that git update if the apply happened on already-merged `main`.
8. **Template (material changes)** — re-export the team bot template so the portable snapshot matches git. Do not treat the export as the change log.

Partial apply: if the PR only changed one specialist, still **verify** standing rules, channel membership, and that the routine is armed (smoke below). You may skip re-pasting unchanged profiles.

## Verify live matches git (smoke)

After apply, all of these must pass:

- **Names:** every id in [FLEET.md](FLEET.md) exists live; live names match ids; no extra specialists unless documented in the same PR.
- **Channel membership:** Product / Build & Run / Engineering members match FLEET.md and the three channel files.
- **Routine armed:** `torqvoice-infra-pr-finops-cost` is enabled; repo is `cookieofcode/torqvoice`; events include `pr-opened` and `pr-pushed`; path include list matches the routine file (so app-only PRs do not wake FinOps).
- **Skill present:** `infra-pr-cost-report` is attached or callable from that routine.
- **Rules present:** team standing instructions still match `STANDING_RULES.md` (spot-check the four rules).
- **Marker:** *Last applied* commit is the SHA you copied.

If smoke fails, fix live **or** git the same day — do not leave split-brain.

## Scrub

Never copy into live or git: API keys, subscription/tenant IDs, private emails, transcripts, Terraform state, kubeconfigs. Say **product owner**.
