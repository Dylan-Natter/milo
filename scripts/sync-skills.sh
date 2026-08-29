#!/usr/bin/env bash
# Keeps .claude/skills in sync with .github/skills.
#
# `.github/skills/` is the source of truth (it is what the Specify CLI writes).
# `.claude/skills/` is a generated mirror so Claude Code discovers the same
# workflow. ARCHITECTURE.md claims a worker-neutral model; this is what makes
# that claim true rather than aspirational.
#
#   --check   exit non-zero if the mirror is stale (used by `make governance`)
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

SRC=".github/skills"
DST=".claude/skills"

if [ "${1:-}" = "--check" ]; then
  if ! diff -rq "$SRC" "$DST" >/dev/null 2>&1; then
    echo "  FAIL: $DST is out of sync with $SRC" >&2
    diff -rq "$SRC" "$DST" 2>&1 | sed 's/^/    /' >&2
    echo "    Run: make sync-skills" >&2
    exit 1
  fi
  echo "  skills mirror in sync ($(ls -1 "$SRC" | wc -l | tr -d ' ') skills)"
  exit 0
fi

rm -rf "$DST"
cp -R "$SRC" "$DST"
echo "Synced $(ls -1 "$DST" | wc -l | tr -d ' ') skills: $SRC -> $DST"
