#!/usr/bin/env bash
# Ensure every aylith-labs repo's CLAUDE.md carries the mandatory handbook pointer.
# Idempotent (marker-gated). Inserts the block after the first line of an existing
# CLAUDE.md; repos WITHOUT a CLAUDE.md are left for the /init pass (this script
# never stubs one). Mirrors aylith-com/scripts/rollout-notifier.sh. Operates via
# the GitHub contents API — no local clone. Needs `gh` with repo + workflow scope.
#
# Usage:
#   scripts/rollout-claude-pointer.sh            # apply
#   scripts/rollout-claude-pointer.sh --dry-run  # report only
set -euo pipefail

ORG="aylith-labs"
SELF_REPO="aylith-handbook"   # the handbook doesn't point at itself
FILE="CLAUDE.md"
START="<!-- aylith-handbook:start -->"

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

# The pointer block (single source of truth). Marker-wrapped for idempotency.
read -r -d '' BLOCK <<'EOF' || true
<!-- aylith-handbook:start -->
> **📖 Aylith handbook (authoritative).** This repo is part of the `aylith-labs` lab. Before any
> cross-repo, catalog, design-system, CI/runner, or data-flow work you **must** consult the org
> handbook — the single source of truth for these conventions:
> https://github.com/aylith-labs/aylith-handbook (locally `../aylith-handbook/`, skill `aylith-labs`).
<!-- aylith-handbook:end -->
EOF

echo "Listing repos for org \"$ORG\"…"
mapfile -t REPOS < <(
  gh repo list "$ORG" --no-archived --limit 500 --json name --jq '.[].name' \
    | grep -vx "$SELF_REPO"
)
echo "${#REPOS[@]} candidate repos."

inserted=0; skipped=0; missing=0
for repo in "${REPOS[@]}"; do
  full="$ORG/$repo"
  cur="$(mktemp)"; new="$(mktemp)"

  # Fetch current CLAUDE.md (gate on exit code — a 404 dumps an error body to stdout).
  if gh api "repos/$full/contents/$FILE" --jq '.content' 2>/dev/null | base64 -d > "$cur" 2>/dev/null; then
    sha="$(gh api "repos/$full/contents/$FILE" --jq '.sha')"
  else
    echo "MISSING $full — no $FILE (leave for /init pass)"; missing=$((missing+1)); rm -f "$cur" "$new"; continue
  fi

  if grep -qF "$START" "$cur"; then
    echo "SKIP    $full — pointer already present"; skipped=$((skipped+1)); rm -f "$cur" "$new"; continue
  fi

  # Insert the block (with surrounding blank lines) right after the first line.
  awk -v block="$BLOCK" 'NR==1{print; print ""; print block; print ""; next} {print}' "$cur" > "$new"

  if [[ "$DRY_RUN" == "1" ]]; then
    echo "INSERT  $full"; rm -f "$cur" "$new"; continue
  fi

  payload="$(mktemp)"
  jq -n --arg msg "chore: add Aylith handbook pointer to CLAUDE.md" \
        --arg content "$(base64 -w0 "$new")" --arg sha "$sha" \
        '{message:$msg, content:$content, sha:$sha}' > "$payload"
  gh api -X PUT "repos/$full/contents/$FILE" --input "$payload" >/dev/null
  echo "INSERT  $full ✓"; inserted=$((inserted+1))
  rm -f "$cur" "$new" "$payload"
  sleep 1
done

echo
echo "Done. inserted=$inserted skipped=$skipped missing(no CLAUDE.md)=$missing"
