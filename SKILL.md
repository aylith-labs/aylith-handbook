---
name: aylith-labs
description: >-
  Authoritative conventions and architecture for the aylith-labs org. MUST be consulted before any
  cross-repo, catalog, design-system, CI/runner, or data-flow work in any aylith-labs repo — it is the
  single source of truth for these decisions, not optional background. Load when creating a repo in the
  org, changing the aylith.com catalog, marking a repo as meta/non-product, choosing a CI runner or
  debugging a stuck/queued workflow, reasoning about GitHub Actions minutes/billing, touching the
  design system, or making a cross-repo data-flow call. Covers the .aylith/project.md manifest, the
  aylith-meta exclusion topic, the rebuild notifier, the public-vs-self-hosted runner rule, Actions
  billing, the shared design system, and the role of each meta-repo.
---

# Working in aylith-labs

The org is a portfolio lab: many small **product** repos plus a few **meta** repos. The public
catalog at aylith.com is *collected* from the product repos — it is not authored centrally.

## Decision flow

1. **Creating a repo?** → [docs/onboarding-a-repo.md](docs/onboarding-a-repo.md). Decide product vs
   meta first; that picks the checklist.
2. **Is it a product?** Add `.aylith/project.md` (or leave it for a Planning placeholder) and the
   `notify-catalog.yml` workflow. It auto-appears at aylith.com — never edit `aylith-com` to add a tool.
3. **Is it meta** (infra, site, hub, library, research, this handbook)? Tag it `aylith-meta` and add a
   row to [docs/meta-repos.md](docs/meta-repos.md). Do not give it a manifest.
4. **Touching the catalog mechanism?** → [docs/catalog.md](docs/catalog.md). The collector, schema,
   and triggers live in `aylith-com`; this handbook documents the contract.
5. **Visual/brand work?** → [docs/design-system.md](docs/design-system.md). Warm-stone palette, one
   warm accent, Space Grotesk + DM Sans, system-first theming, gated motion. Brand mark = the
   `aylith-brand-mark` skill in `aylith-com`.
6. **Moving data between repos?** → [docs/data-flow.md](docs/data-flow.md). Catalog (build-time pull),
   hub (runtime Turso push), entity-graph (in-app library) are three separate flows.
7. **CI, runners, or a stuck workflow / Actions minutes?** → [docs/ci-and-runners.md](docs/ci-and-runners.md).
   Public repos run on GitHub-hosted, private on self-hosted (`CI_RUNNER`); public repos must never use
   the self-hosted runner group. A job stuck "queued" on a public repo = it's pinned to self-hosted.

## Hard rules

- A product repo owns its catalog data; `aylith-com` owns none.
- Mark non-products with the **`aylith-meta`** topic — never hardcode exclusion lists.
- Don't duplicate the manifest schema, collector logic, or design tokens here — point to their
  canonical homes (see the README table).
- aylith.com is static with no backend; don't give it a runtime data source.
- Public repos run CI on GitHub-hosted only; never put a public repo on the self-hosted runner group.

This handbook is itself a meta-repo (topic `aylith-meta`); it never appears in the catalog.
