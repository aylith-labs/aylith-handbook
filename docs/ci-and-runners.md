# CI & runners

How CI is wired across the org, which runner each repo uses and why, and the GitHub Actions billing
that constrains it. These are operational rules learned the hard way — follow them when adding or
debugging a workflow.

## Runner choice — public vs private

Every workflow job uses:

```yaml
runs-on: ${{ vars.CI_RUNNER || 'ubuntu-latest' }}
```

The `CI_RUNNER` **repo variable** decides the runner:

| Repo visibility | `CI_RUNNER` | Runs on |
| --- | --- | --- |
| **Public** (aylith-com, clipwell, aylith-handbook) | `ubuntu-latest` | GitHub-hosted |
| **Private** (everything else) | `self-hosted` | the org's self-hosted runner (`srv1102189-hostinger`) |

Set it per repo: `gh variable set CI_RUNNER --repo aylith-labs/<repo> --body <value>`.

## Public repos must NOT use the self-hosted runner

This is a hard rule, not a preference:

- The org's **Default** runner group keeps **`allows_public_repositories: false`** on purpose. A
  self-hosted runner serving a public repo is GitHub's top-warned risk — a fork PR with a
  `pull_request`-triggered workflow can execute arbitrary code on the runner host, next to your
  private-repo secrets and checkouts.
- So a public repo pinned to `self-hosted` will **queue forever** (the runner group refuses it) — the
  symptom is a job stuck "queued" while the runner sits idle. Fix: set that repo's `CI_RUNNER` to
  `ubuntu-latest`.
- Public repos get **free, unlimited** GitHub-hosted minutes anyway (see below), so there's no cost
  reason to use self-hosted for them.
- Defense in depth: org **fork-PR approval** is set to `all_external_contributors` — no outside
  contributor's fork workflow runs without a maintainer's approval.

Keep public and private CI isolated: the self-hosted runner is **private-repos-only**. If a public
repo ever genuinely needs self-hosted hardware, stand up a *separate* ephemeral runner in its own
runner group scoped to just that repo — never reuse the private Default group.

## Actions-minutes economics

- **Public repos:** free, unlimited standard GitHub-hosted minutes. They never count against the
  included allowance.
- **Private repos:** share **2,000 GitHub-hosted minutes/month** (GitHub Free plan), **reset on the
  1st of each month**. When exhausted, private-repo *hosted* jobs pause until reset.
- **Self-hosted minutes are free** — you pay for the Hostinger box, not per-minute. Private repos on
  `self-hosted` don't touch the 2,000-minute pool.
- `cohesa` is the dominant minute consumer (heavy hosted CI). If the pool runs out before month-end,
  the levers are: wait for the reset, set a small Actions **spending limit**, or move that repo's CI
  to the **self-hosted** runner.

## Catalog resilience under minute limits

The catalog rebuild ([catalog.md](catalog.md)) does **not** break when private repos run out of
minutes. Each product repo's `notify-catalog` workflow runs on hosted minutes, so for a private repo
it can pause — but `aylith-com`'s **hourly cron** runs on the public (free) repo and re-collects the
org regardless. Worst case, a change shows up within the hour instead of instantly.
