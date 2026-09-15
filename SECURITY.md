# Security policy

This repository is **public** open source. Do not describe vulnerabilities, publish a PoC, paste secrets, or attach screenshots of a security bug in public issues, pull requests, or discussions.

There is **no** published security email. Do not guess or invent one.

This policy does **not** use GitHub Private vulnerability reporting (the self-serve **Report a vulnerability** / `/security/advisories/new` reporter form). Do not wait for that feature to be turned on.

**Screenshots count.** Workshop customer data or a vulnerability in an image is still disclosure.

## Reporter path

1. Open a **public** issue titled exactly `Security contact request` (use the **Security contact request** issue template).
2. **@mention** `cookieofcode`.
3. Optional **one line** only: that you need a private channel for a security report.
4. Include **zero** vulnerability detail, PoC, secrets, credentials, Azure IDs, customer PII, kubeconfigs, tfvars, or screenshots of the bug.

If you cannot wait: **still do not dump the vulnerability publicly.** Wait for a maintainer to open a private channel.

## Maintainer path

Repository admins can **create a draft Repository Security Advisory** themselves. That does **not** require enabling Private vulnerability reporting.

1. Create a [draft repository security advisory](https://docs.github.com/en/code-security/security-advisories/working-with-repository-security-advisories/creating-a-repository-security-advisory).
2. Invite the reporter as a collaborator on that draft, **or** agree another private channel.
3. Coordinate the fix and coordinated disclosure **there** — not in the public issue.

This is a **maintainer-created** advisory, not self-serve reporter PVR.

## Optional later

A real security contact address may be added later **only if the product owner publishes one**. Until then, use the public `Security contact request` issue. Do not invent or use an unpublished address.

## Product bugs and feature requests

Non-security product, bug, and docs work goes on public issues. See [CONTRIBUTING.md](CONTRIBUTING.md), [agents/COS_INTAKE.md](agents/COS_INTAKE.md), and the issue templates. Do not post secrets there.
