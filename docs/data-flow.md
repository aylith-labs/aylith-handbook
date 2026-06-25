# Data flow

How information moves between repos. There are three independent flows — keep them separate in your
head; they share no runtime.

## 1. Catalog (build-time, pull)

```
product repos (.aylith/project.md)
        │  octokit, at build
        ▼
aylith-com/scripts/collect.mjs ──► .generated/projects/*.md ──► prerendered static site ──► aylith.com
```

- **Direction:** aylith-com *pulls* from every repo at build. Repos never push catalog data.
- **Trigger:** a push to any product repo fires `catalog-refresh` at aylith-com (or the hourly cron).
- **Source of truth:** each repo's manifest. aylith-com holds none. See [catalog.md](catalog.md).
- No database, no runtime — the output is a folder of HTML on GitHub Pages.

## 2. Live hub (runtime, push)

```
products + jobs ──► shared Turso DB ──► aylith-hub (SSR, adapter-node) ──► hub.* surfaces
                          ▲
            health poller writes uptime/incidents
```

- **Direction:** products and scheduled jobs *push* live data (changelog entries, stats, health
  pings) into a shared **Turso** database; `aylith-hub` reads and renders it server-side.
- The hub keeps a lightweight **product registry** row per service so changelog/stats/health can be
  grouped by product. This registry is operational grouping — it is **not** the marketing catalog
  (that's flow 1).
- Unlike the catalog, this is dynamic: it's SSR precisely because everything it shows is live.

## 3. Shared entity layer (library, in-app)

```
each app's own DB ──┐
                    ├──► @aylith/entity-graph (libSQL/SQLite or Turso) ──► cross-app links, global tags, unified timeline
each app's own DB ──┘
```

- **`entity-graph`** is a library, not a service. Each app stays the owner of its own database; the
  package gives them one substrate to point at each other, link entities across app boundaries, tag
  anything globally, and read one cross-app timeline.
- Apps depend on it as a package; there's no central server in this flow.

## What does NOT connect

- The catalog (flow 1) and the hub (flow 2) do not share storage. The catalog is static files derived
  from repo manifests; the hub is live data in Turso. A tool's *existence* comes from its manifest; a
  tool's *activity* (changelog, status, stats) comes from the hub DB.
- Don't wire the static site to the hub DB at runtime — aylith.com has no backend by design. If the
  umbrella site ever needs live receipts, surface them at build time or via the hub, not by adding a
  server to aylith-com.
