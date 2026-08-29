#!/usr/bin/env bash
# Prints the specification inventory and lifecycle state.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

printf '%-28s %-12s %-6s %-6s %-6s\n' "FEATURE" "STATUS" "SPEC" "PLAN" "TASKS"
printf '%-28s %-12s %-6s %-6s %-6s\n' "----------------------------" "------------" "----" "----" "-----"

shopt -s nullglob
found=0
for d in specs/*/; do
  name="$(basename "$d")"
  [ "$name" = "README.md" ] && continue
  found=1
  status="unknown"
  if [ -f "$d/spec.md" ]; then
    status="$(grep -m1 -iE '^\*\*Status\*\*:|^- \*\*Status\*\*:' "$d/spec.md" 2>/dev/null \
      | sed -E 's/.*\*\*Status\*\*:[[:space:]]*//' | cut -c1-11)"
    [ -z "$status" ] && status="draft"
  fi
  mark() { [ -f "$1" ] && echo "yes" || echo "-"; }
  progress="-"
  if [ -f "$d/tasks.md" ]; then
    done_n=$(grep -c '^\- \[x\]' "$d/tasks.md" 2>/dev/null || echo 0)
    all_n=$(grep -c '^\- \[[ x]\]' "$d/tasks.md" 2>/dev/null || echo 0)
    progress="${done_n}/${all_n}"
  fi
  printf '%-28s %-12s %-6s %-6s %-6s\n' \
    "$name" "$status" "$(mark "$d/spec.md")" "$(mark "$d/plan.md")" "$progress"
done

if [ "$found" -eq 0 ]; then
  echo "(no specifications yet — run /speckit-specify to create the first)"
fi
