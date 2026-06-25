# The catalog

The public catalog at **aylith.com** is *collected*, not authored. No per-tool data lives in the
`aylith-com` repo — each product repo describes itself, and the site aggregates the org at build time.
Implementation detail lives in `aylith-com` (README + `landing/scripts/collect.mjs`); this page is the
org-level "how it works / how to participate" view.

## The manifest — `.aylith/project.md`

Frontmatter + a Markdown body, at the product repo's root. The slug is the repo name.

```markdown
---
name: Gitdex
tagline: An index for every repo you own
description: A GitHub repository inventory that categorizes, scores, and tracks your repos.
category: developer-tools          # see categories below
status: building                   # research | planning | building | beta | live
features:
  - Inventory of every repo across your orgs
  - Health and activity scoring per repository
targetUser: Engineers with sprawling repos who need to see the whole estate at once
# curation — all optional, defaults applied if omitted
featured: false
order: 19                          # ascending; unset sorts last, then alphabetically
icon: 'M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5'   # SVG stroke path
gradientFrom: '#475569'
gradientTo: '#94a3b8'
---

## Vision
…long-form body, rendered on the detail page…
```

Canonical, validating schema: **`aylith-com/.aylith/project.schema.json`**.

- **Categories:** `ai-infrastructure`, `developer-tools`, `design-tools`, `productivity`,
  `data-tools`, `wellness`, `testing`. Placeholders land in `uncategorized` ("Unsorted").
- **Statuses:** `research`, `planning`, `building`, `beta`, `live`. `planning` drives the amber
  placeholder treatment.
- **`repoUrl`** is injected by the collector (the repo's GitHub URL) — don't set it in the manifest.

## The fallback chain (a repo always appears)

1. **Manifest present** → full card + detail page from its frontmatter and body.
2. **No manifest** → a **Planning placeholder**: name from the repo, tagline/description from the
   GitHub repo description, `status: planning`, `category: uncategorized`, a "Source" link, and the
   README's first paragraph as the body if one exists.
3. **`aylith-meta` topic / archived / `aylith-com`** → excluded entirely.

This is why a brand-new repo shows up on the next build with zero configuration.

## How it rebuilds

`aylith-com`'s deploy workflow runs the collector (`npm run collect`) before building. It triggers on:

- **`repository_dispatch` (`catalog-refresh`)** — fired by each product repo's
  `.github/workflows/notify-catalog.yml` on push to its default branch (near-instant). Requires the
  org-level Actions secret **`CATALOG_DISPATCH_TOKEN`**.
- **Hourly `schedule`** — safety net for brand-new or not-yet-adopted repos.
- **push to `aylith-com` `main`** and manual **`workflow_dispatch`**.

Collection auth: a dedicated **`CATALOG_GITHUB_TOKEN`** (repo secret on `aylith-com`,
`metadata:read` + `contents:read` org-wide) is preferred; it falls back to the workflow's default
`GITHUB_TOKEN`, which can read public repos. If collection fails, the build falls back to the
committed snapshot in `aylith-com/landing/src/content/projects/` so a deploy never ships a broken
catalog. The snapshot is a dev/offline fallback, not the source of truth.

## Rolling the notifier out to repos

`aylith-com/scripts/rollout-notifier.sh` writes `notify-catalog.yml` into every eligible org repo
(skips archived, `aylith-com`, and `aylith-meta`-tagged repos). Run it after the
`CATALOG_DISPATCH_TOKEN` org secret exists, so the notifiers don't fail.
