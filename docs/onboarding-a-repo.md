# Onboarding a repo

Every repo in `aylith-labs` is one of two kinds. Decide which, then follow that checklist.

- **Product** — a shippable tool that belongs in the public catalog at aylith.com.
- **Meta** — infrastructure, the umbrella site, the hub, this handbook, research. Not a product;
  stays out of the catalog. See [meta-repos.md](meta-repos.md).

## Product repo

A product repo appears in the catalog automatically. You control how much detail it shows.

1. **(Recommended) Add a manifest** at `.aylith/project.md` — frontmatter + a Markdown body. This
   becomes the tool's catalog card and detail page. The slug is the repo name. Minimum required
   frontmatter: `name`, `tagline`, `description`, `category`, `status`. Full field list +
   validation: `aylith-com/.aylith/project.schema.json`. See [catalog.md](catalog.md) for an example.
2. **(Recommended) Add the rebuild notifier** at `.github/workflows/notify-catalog.yml` so a push to
   the default branch rebuilds aylith.com immediately. Copy it from
   `aylith-com/.aylith/templates/notify-catalog.yml`, or let
   `aylith-com/scripts/rollout-notifier.sh` add it across all eligible repos. Without it, the
   hourly cron still picks the repo up — just not instantly.
3. **Do nothing else and it still works.** With no manifest, the repo shows as a **Planning
   placeholder** — name from the repo, blurb from the GitHub description, status `planning`,
   category `uncategorized`, plus a "Source" link. Fill in the manifest whenever you're ready.

That's it — no edit to `aylith-com` is ever needed to add or change a tool.

## Every repo (product or meta)

- **Set `CI_RUNNER`** if the repo has workflows: `ubuntu-latest` for public repos, `self-hosted` for
  private. Public repos must not use the self-hosted runner — see [ci-and-runners.md](ci-and-runners.md).
- **Add a `CLAUDE.md`** following the structure below — every repo has one.

## What `CLAUDE.md` should contain

Every repo's `CLAUDE.md` follows this shape:

1. `# <Repo> — Claude Code guidance` (H1, first line)
2. **The handbook pointer block** — mandatory, marker-wrapped (`<!-- aylith-handbook:start -->` …
   `:end`), right after the H1. It's added and kept in sync by
   `aylith-handbook/scripts/rollout-claude-pointer.sh`, so any agent finds the handbook at session
   start. Don't hand-edit the block.
3. `## Project Overview` — what it is + stack, 2-4 sentences.
4. `## Commands` — the real install/dev/build/test/lint commands (verify them; don't invent).
5. `## Architecture` — key directories and how the pieces fit.
6. `## Conventions` — genuine house rules only (omit the section if none).

Keep it concise — it's read every session: no filler, no historical/migration commentary, no secrets.

**New repo:** run `/init` to generate sections 3-6, then run `rollout-claude-pointer.sh` (or copy the
block) to insert the pointer. Repos without a `CLAUDE.md` are picked up by the rollout's `/init` pass.

## Meta repo

1. **Tag it with the `aylith-meta` GitHub topic** — `gh repo edit aylith-labs/<repo> --add-topic
   aylith-meta`. The collector skips any repo carrying it (archived repos and `aylith-com` itself
   are skipped unconditionally).
2. **Do not add a `.aylith/project.md`.** Meta-repos have no catalog entry.
3. Describe its role in [meta-repos.md](meta-repos.md) so the next person knows what it's for.

## Quick reference

| | Product | Meta |
| --- | --- | --- |
| `aylith-meta` topic | no | **yes** |
| `.aylith/project.md` | yes (or placeholder) | no |
| `notify-catalog.yml` | yes | optional (only if it should still trigger rebuilds) |
| In the catalog | yes | no |
