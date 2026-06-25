# aylith-handbook

**How the Aylith lab is wired — conventions, catalog, design system, and the role of every repo.**

This is the shared knowledge base for the `aylith-labs` org. It is a **meta-repo**: it ships
no product and is excluded from the public catalog (it carries the `aylith-meta` topic). Read it
before spinning up a new repo, touching the catalog, or making a cross-repo design or data call.

## Start here

- **[Onboarding a repo](docs/onboarding-a-repo.md)** — how a new repo joins the lab. Product repos
  auto-appear in the catalog; meta-repos opt out. The 2-minute checklist.
- **[Meta-repos & the `aylith-meta` topic](docs/meta-repos.md)** — what counts as "not a product,"
  how it's marked, and the role each meta-repo plays.
- **[The catalog](docs/catalog.md)** — how `aylith.com` builds itself from each repo's
  `.aylith/project.md` manifest, the placeholder fallback, and the rebuild triggers.
- **[Design system](docs/design-system.md)** — palette, type, theming, and motion decisions shared
  across the studio's surfaces.
- **[Data flow](docs/data-flow.md)** — how data connects: the catalog, the live hub's Turso DB, and
  the shared entity layer.
- **[CI & runners](docs/ci-and-runners.md)** — which runner each repo uses (public → GitHub-hosted,
  private → self-hosted), why public repos stay off the self-hosted runner, and Actions-minute limits.

Every repo's `CLAUDE.md` carries a pointer back here — consulting this handbook before cross-repo,
catalog, design, CI, or data-flow work is **mandatory**, not optional.

## The one-paragraph model

Each **product** repo owns its own catalog entry in a `.aylith/project.md` file at its root.
`aylith-com` collects every product repo in the org at build time and renders the catalog — no
product data lives in `aylith-com` anymore. A repo with no manifest still appears, as a "Planning"
placeholder built from its GitHub name + description. **Meta-repos** (the umbrella site, the hub,
infra, this handbook, …) are kept out of the catalog by the `aylith-meta` GitHub topic. The catalog
rebuilds whenever any repo pushes to its default branch.

## Canonical locations (don't duplicate — point here)

| Thing | Lives in |
| --- | --- |
| Catalog collector | `aylith-com/landing/scripts/collect.mjs` |
| Manifest schema | `aylith-com/.aylith/project.schema.json` |
| Notifier workflow template | `aylith-com/.aylith/templates/notify-catalog.yml` |
| Notifier rollout script | `aylith-com/scripts/rollout-notifier.sh` |
| CLAUDE.md handbook-pointer rollout | `aylith-handbook/scripts/rollout-claude-pointer.sh` |
| Shared exclusion/default constants | `aylith-com/landing/src/lib/catalog/defaults.js` |
| Design tokens (live) | `aylith-com/landing/src/app.css` + the `/design` route |
| Brand mark / wordmark | `aylith-com` → the `aylith-brand-mark` skill |
