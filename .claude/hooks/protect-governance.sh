#!/usr/bin/env bash
# Blocks edits to canonical governance files unless the branch is an explicit
# standards branch.
#
# AGENTS.md rule 5 says an agent must not bypass protected paths. A rule an
# agent can silently ignore is not a control — this is the mechanism behind it.
# Amending the constitution requires a standards PR with reason, evidence,
# scope, and conflict analysis; a feature branch is not the place for it.
set -euo pipefail

payload="$(cat)"
file_path="$(printf '%s' "$payload" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' 2>/dev/null || true)"
[ -z "$file_path" ] && exit 0

protected=(
  ".specify/memory/constitution.md"
  "AGENTS.md"
  ".github/rulesets/main.json"
  ".github/CODEOWNERS"
  ".claude/settings.json"
)

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
case "$branch" in
  standards/*|governance/*) exit 0 ;;
esac

for p in "${protected[@]}"; do
  if [[ "$file_path" == *"$p" ]]; then
    cat >&2 <<MSG
BLOCKED: $p is a canonical governance file.

Changing it is a standards change and requires a dedicated branch plus a PR
carrying reason, evidence, affected scope, and conflict analysis
(.specify/memory/constitution.md, "Governance").

Current branch: $branch
To proceed:     git switch -c standards/<short-description>
MSG
    exit 2
  fi
done
exit 0
