#!/usr/bin/env bash
# Adapts a fresh copy of this template to a new project.
#
# Run once, immediately after creating a repository from the template. It
# rewrites the project identity, resets the ADR log to the genesis decision, and
# leaves the stack decision (ADR-0002) staged but undecided — that choice
# belongs to the new project, not to the template.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "════════════════════════════════════════════════"
echo " Milo template bootstrap"
echo "════════════════════════════════════════════════"
echo

if [ -f .bootstrapped ]; then
  echo "This repository has already been bootstrapped ($(cat .bootstrapped))."
  read -r -p "Run again anyway? [y/N] " again
  [[ "$again" =~ ^[Yy]$ ]] || exit 0
fi

detected_owner=""
if remote=$(git config --get remote.origin.url 2>/dev/null); then
  detected_owner="$(printf '%s' "$remote" | sed -E 's#.*[:/]([^/]+)/[^/]+(\.git)?$#\1#')"
fi

read -r -p "Project name (e.g. Acme Billing): " project_name
[ -n "$project_name" ] || { echo "Project name is required." >&2; exit 1; }

read -r -p "GitHub owner [${detected_owner}]: " owner
owner="${owner:-$detected_owner}"

read -r -p "Copyright holder [${owner}]: " holder
holder="${holder:-$owner}"

echo
echo "Will rewrite:"
echo "  Project name    : Milo  ->  ${project_name}"
echo "  GitHub owner    : Dylan-Natter  ->  ${owner}"
echo "  Copyright holder: ${holder}"
echo
read -r -p "Proceed? [y/N] " go
[[ "$go" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

# Extension-matching alone misses .github/CODEOWNERS, which has no extension.
# Leaving it behind would keep every ownership entry pointing at the template
# maintainer — and once `make apply-platform` turns on require_code_owner_review,
# reviews in the new project would be unsatisfiable.
targets=$( { git ls-files \
    | grep -vE '^(scripts/bootstrap\.sh|CHANGELOG\.md|LICENSE)$' \
    | grep -E '\.(md|json|yml|yaml)$'
  git ls-files -- .github/CODEOWNERS
} | sort -u || true)

for f in $targets; do
  sed -i.bak "s/Milo/${project_name}/g; s/Dylan-Natter/${owner}/g" "$f"
  rm -f "$f.bak"
done

# LICENSE gets only the holder substituted, so the proprietary default and its
# guidance survive intact.
sed -i.bak "s/Dylan Natter/${holder}/" LICENSE && rm -f LICENSE.bak

# Reset the decision log: the new project inherits the genesis decision but must
# make its own stack decision.
cat > CHANGELOG.md <<EOF
# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Bootstrapped from the Milo software-factory template on $(date +%Y-%m-%d).
EOF

date -u +%Y-%m-%dT%H:%M:%SZ > .bootstrapped

echo
echo "════════════════════════════════════════════════"
echo " Bootstrap complete."
echo "════════════════════════════════════════════════"
cat <<EOF

Next steps, in order:

  1. make check
       Confirm the gate is green before changing anything.

  2. make apply-platform
       Creates the labels, imports the branch ruleset, and enables secret
       scanning. Needs gh with admin rights. Read .github/rulesets/README.md
       first: it enables required commit signatures.

  3. Answer the 11 genesis questions
       docs/product/genesis-workflow.md — this is the real starting line.

  4. Decide ADR-0002 (product stack)
       docs/architecture/decisions/0002-product-stack-selection.md
       The options matrix is prepared; the decision is yours.

  5. /speckit-specify
       First specification. Everything downstream generates from it.

EOF
