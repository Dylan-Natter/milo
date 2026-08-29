#!/usr/bin/env bash
# Pulls template improvements into a project bootstrapped from this template.
#
# Strategy A (upstream merge): the template stays a git remote, and its
# improvements arrive as an ordinary merge. Simple and explicit; conflicts grow
# as the project diverges, which is the accepted tradeoff.
#
#   template-sync.sh              merge upstream/main into the current branch
#   template-sync.sh --check      report whether the template has moved (no writes)
#   template-sync.sh --url URL    set/override the template remote
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

REMOTE="template"
DEFAULT_URL="https://github.com/Dylan-Natter/milo.git"
CHECK_ONLY=false
URL=""

while [ $# -gt 0 ]; do
  case "$1" in
    --check) CHECK_ONLY=true ;;
    --url) URL="${2:?--url requires a value}"; shift ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
  shift
done

if ! git remote get-url "$REMOTE" >/dev/null 2>&1; then
  url="${URL:-$DEFAULT_URL}"
  echo "==> Adding '$REMOTE' remote: $url"
  git remote add "$REMOTE" "$url"
elif [ -n "$URL" ]; then
  git remote set-url "$REMOTE" "$URL"
  echo "==> Updated '$REMOTE' remote: $URL"
fi

echo "==> Fetching $REMOTE"
git fetch --no-tags "$REMOTE" main

ahead=$(git rev-list --count HEAD.."$REMOTE/main" 2>/dev/null || echo 0)
if [ "$ahead" -eq 0 ]; then
  echo "Up to date with the template."
  exit 0
fi

echo
echo "The template is $ahead commit(s) ahead:"
git log --oneline --no-decorate HEAD.."$REMOTE/main" | sed 's/^/  /'
echo

if [ "$CHECK_ONLY" = true ]; then
  echo "Run 'make template-sync' to merge these changes."
  exit 0
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "Working tree is not clean. Commit or stash before syncing." >&2
  exit 1
fi

echo "==> Merging $REMOTE/main"
# --allow-unrelated-histories is required on the first sync: "Use this template"
# starts a fresh history with no common ancestor.
if git merge "$REMOTE/main" --allow-unrelated-histories --no-edit; then
  echo
  echo "Merged cleanly. Now run: make check"
else
  cat <<'EOF'

Merge stopped with conflicts. This is expected where the project has customised
template files.

  Keep YOUR version   : git checkout --ours <file>
  Take the TEMPLATE's : git checkout --theirs <file>

Governance files (constitution, AGENTS.md, rulesets, CODEOWNERS) are usually
resolved in favour of the template — that is the point of syncing. Files you
have deliberately customised (README, LICENSE, CHANGELOG) usually keep yours.

Then: git add -A && git commit && make check
EOF
  exit 1
fi
