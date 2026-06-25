# Design system

Shared visual decisions across the studio's surfaces (aylith.com, the hub, dashboards). The **live**
source of truth is `aylith-com/landing/src/app.css` (Tailwind v4 `@theme` tokens) and the rendered
`/design` route — this page records the *decisions*, not a second copy of the values.

## Palette

Three ramps, all warm — the brand is "warm stone," never cool gray.

- **`surface`** — the warm-stone neutral ramp, from near-white `#f8f7f4` (`surface-50`) to near-black
  `#0a0907` (`surface-950`). Backgrounds, text, borders. This is the workhorse.
- **`accent`** — a single warm orange, defined in `oklch` at hue ~50 (e.g. `accent-600 ≈ #c97a3a`).
  Used sparingly for emphasis, links, and active states. One accent, applied with restraint.
- **`warm`** — warm off-whites/creams (`#faf8f5` …) for dark-mode foreground text and soft fills.

Per-tool accent gradients (`gradientFrom`/`gradientTo` in each manifest) are the *only* place
arbitrary colors live, and they're scoped to that tool's card/detail. Everything else stays on the
ramps above. New literal colors are drift — add a token instead.

## Type

- **Display:** `Space Grotesk` (headings, wordmark lockups).
- **Body:** `DM Sans`.
- Both load via Google Fonts. Keep the pairing consistent across surfaces.

## Theming — system-first, always

- Default to the **system** preference (`prefers-color-scheme`); ship both light and dark.
- Resolve theme **before first paint** (an inline script in `app.html`) so nothing flashes.
- Offer an explicit override (System / Light / Dark) where it makes sense, persisted; force a mode
  by setting `data-theme` on the root, leave it unset for system.

## Motion — gated

- All reveal / tilt / draw / count-up motion honors `prefers-reduced-motion` **and** an explicit user
  motion preference (`html[data-motion]`). Motion is an enhancement, never required to read content.
- No layout shift: hover/state swaps keep identical box dimensions; reserve space for media.

## Brand mark

The tally-mark + wordmark (with a monthly-rotating wordmark variant) and the console signature are
brand assets owned by `aylith-com`. To change the logo, name backstory, or favicons, use the
**`aylith-brand-mark`** skill in `aylith-com` — it owns the locked geometry, the asset-sync graph,
and the org-avatar upload flow. Don't hand-edit mark assets.

## Voice

Quietly confident. Evidence over adjectives. No superlatives, no future-tense marketing, no
"revolutionary." Restraint is the brand — copy included.
