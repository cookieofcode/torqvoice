# Security policy

This repository is **public** open source. Do not file vulnerabilities as public issues, and do not paste secrets, credentials, Azure subscription/tenant/object IDs, customer PII, kubeconfigs, or tfvars into issues, pull requests, or discussions.

**Screenshots count.** Workshop customer data in an image is still disclosure.

## How to report a vulnerability

Use **GitHub private vulnerability reporting** (repository Security Advisories). There is no separate security email published here.

1. Open https://github.com/cookieofcode/torqvoice
2. Open the **Security** tab (shown as **Security and quality** on some GitHub layouts)
3. Open **Advisories**, then **Report a vulnerability**
4. Describe the issue **privately** in the advisory form and submit

Direct form (available when maintainers have enabled private vulnerability reporting):

https://github.com/cookieofcode/torqvoice/security/advisories/new

GitHub’s reporter instructions: [Privately reporting a security vulnerability](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing/privately-reporting-a-security-vulnerability).

If **Report a vulnerability** is not visible, **do not** describe the vulnerability in a public issue. Open a public issue that only asks maintainers for a preferred private contact, or wait until private vulnerability reporting is enabled. Maintainers with admin or security permissions can [create a draft security advisory](https://docs.github.com/en/code-security/security-advisories/working-with-repository-security-advisories/creating-a-repository-security-advisory) directly.

## Product owner (ops, not IaC)

Enable GitHub **Private vulnerability reporting** on this repository: Settings → Code security → Private vulnerability reporting. That toggle is a GitHub UI/ops step; it cannot be set from files in this repo. See [Configuring private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/repository-security-advisories/configuring-private-vulnerability-reporting-for-a-repository).

## Product bugs and feature requests

Non-security product, bug, and docs work goes on public issues. See [CONTRIBUTING.md](CONTRIBUTING.md), [agents/COS_INTAKE.md](agents/COS_INTAKE.md), and the issue templates. Do not post secrets there.
