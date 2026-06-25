# Meta-repos & the `aylith-meta` topic

A **meta-repo** is anything in the org that isn't a shippable product: the umbrella site, the live
hub, infrastructure, shared libraries, research, this handbook. They must not appear in the public
product catalog.

## How a meta-repo is marked

Carry the GitHub topic **`aylith-meta`**:

```bash
gh repo edit aylith-labs/<repo> --add-topic aylith-meta
```

The catalog collector (`aylith-com/landing/scripts/collect.mjs`) reads each repo's topics and skips
any that carry `aylith-meta`. Two repos are skipped unconditionally regardless of topic: **archived**
repos, and **`aylith-com`** itself (the site can't list itself). The topic name is defined once in
`aylith-com/landing/src/lib/catalog/defaults.js` (`EXCLUDE_TOPIC`) — change it there and re-tag if it
ever needs to move.

## The current meta-repos and their roles

| Repo | Role |
| --- | --- |
| **aylith-com** | The umbrella marketing site + product catalog. Static SvelteKit → GitHub Pages → `aylith.com`. Aggregates every product repo's `.aylith/project.md` at build. Owns the manifest schema, the collector, the notifier template, and the brand/design tokens. |
| **aylith-hub** | The studio's *live* public hub. SSR (adapter-node) over a shared Turso DB: blog/news, cross-product changelog, live service status (a health poller pings each registered service), stats, newsletter. Keeps a lightweight product *registry* in the DB to group data by service — no marketing showcase. |
| **infra-hub** | Infrastructure dashboard + the docker-compose stacks the studio self-hosts (Traefik routing, auth/identity, host config). DevOps, monitoring, cost tracking. |
| **aylith-dashboard** | Personal/activity aggregation dashboard — a productivity surface, not a public product. |
| **entity-graph** | The shared cross-app data layer (`@aylith/entity-graph`). Apps keep their own databases; this gives them one place to link entities across app boundaries, tag globally, and read a unified timeline. A library/substrate, not a tool. See [data-flow.md](data-flow.md). |
| **research** | Market research, datasets, and analysis. Internal. |
| **aylith-handbook** | This repo — org conventions and shared knowledge. |

Keep this table current: when you add a meta-repo, tag it `aylith-meta` and add a row here.

## Why a topic (not a hardcoded list)

The exclusion is data on the repo itself, so the collector never needs editing when a meta-repo is
added or removed — the same principle as product repos owning their own manifests. Add the topic and
the repo drops out of the catalog on the next build.
