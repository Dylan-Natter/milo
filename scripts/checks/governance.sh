#!/usr/bin/env bash
# Validates the repository's governance invariants.
#
# This script is the single source of truth for governance validation: `make
# check` and the CI workflow both call it, so a green local run means the same
# thing a green pipeline does.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

fail=0
note() { printf '  %s\n' "$*"; }
err() { printf '  FAIL: %s\n' "$*" >&2; fail=1; }

echo "==> Canonical truth files present"
required_files=(
  .specify/memory/constitution.md
  AGENTS.md
  ARCHITECTURE.md
  CONTRIBUTING.md
  SECURITY.md
  LICENSE
  .gitignore
  .github/copilot-instructions.md
  .github/pull_request_template.md
  .github/CODEOWNERS
  specs/README.md
  docs/product/genesis-workflow.md
  docs/standards/engineering-model.md
  docs/operations/platform-operations.md
  docs/operations/improvement-contract.md
  docs/operations/template-usage.md
  docs/agents/playbooks.md
  scripts/checks/pr_body.py
  docs/architecture/decisions/0001-genesis-foundation.md
  docs/architecture/decisions/template.md
  docs/architecture/decisions/README.md
)
for f in "${required_files[@]}"; do
  [ -f "$f" ] || err "missing required file: $f"
done
[ "$fail" -eq 0 ] && note "all ${#required_files[@]} canonical files present"

echo "==> Constitution is ratified (no template placeholders)"
if grep -qE '\[PROJECT_NAME\]|\[PRINCIPLE_|\[GUIDING|TODO\(' .specify/memory/constitution.md; then
  err "constitution still contains template placeholders"
else
  note "constitution has no unresolved placeholders"
fi

echo "==> Issue forms conform to the GitHub issue-forms schema"
shopt -s nullglob
forms=(.github/ISSUE_TEMPLATE/*.yml)
for f in "${forms[@]}"; do
  base="$(basename "$f")"
  [ "$base" = "config.yml" ] && continue
  # Issue FORMS require `description:`. `about:` is legacy markdown-template
  # frontmatter and makes the form fail to render in the issue chooser.
  grep -q '^description:' "$f" || err "$f: missing required top-level 'description:' key"
  grep -q '^about:' "$f" && err "$f: uses legacy 'about:' key; issue forms require 'description:'"
  grep -q '^name:' "$f" || err "$f: missing required top-level 'name:' key"
  grep -q '^body:' "$f" || err "$f: missing required top-level 'body:' key"
done
note "checked ${#forms[@]} issue template file(s)"

echo "==> ADRs are well-formed"
for adr in docs/architecture/decisions/[0-9]*.md; do
  grep -qE '^\- \*\*Status\*\*:' "$adr" || err "$adr: missing '- **Status**:' field"
  grep -q '^## Context' "$adr" || err "$adr: missing '## Context' section"
  grep -q '^## Decision' "$adr" || err "$adr: missing '## Decision' section"
  grep -q '^## Consequences' "$adr" || err "$adr: missing '## Consequences' section"
done
note "validated $(ls -1 docs/architecture/decisions/[0-9]*.md 2>/dev/null | wc -l | tr -d ' ') ADR(s)"

echo "==> GitHub Actions are pinned to immutable SHAs"
# Mutable tags (@v4) can be repointed by an upstream compromise; SHAs cannot.
if grep -rnE '^\s*uses:\s+[^#]*@v[0-9]' .github/workflows/ 2>/dev/null; then
  err "workflow action(s) pinned to a mutable tag; pin to a full commit SHA"
else
  note "all workflow actions pinned to commit SHAs"
fi

echo "==> Workflow and template YAML parses"
if command -v python3 >/dev/null 2>&1 && python3 -c 'import yaml' 2>/dev/null; then
  python3 - <<'PYEOF' || fail=1
import yaml, glob, sys
bad = 0
for f in sorted(glob.glob(".github/workflows/*.yml") + glob.glob(".github/*.yml")
                + glob.glob(".github/ISSUE_TEMPLATE/*.yml")):
    try:
        yaml.safe_load(open(f))
    except Exception as e:
        print(f"  FAIL: {f}: {e}", file=sys.stderr)
        bad = 1
sys.exit(bad)
PYEOF
  note "all YAML parses"
else
  note "PyYAML unavailable; YAML parse check skipped"
fi

echo "==> PR body section checker behaves correctly"
python3 scripts/checks/pr_body.py --self-test || fail=1

echo "==> PR template is scaffolding-only (no section reads as pre-filled)"
leaked=0
for s in "Linked Issue / Spec" "Architecture impact" "Security impact" \
         "Data / migration impact" "Validation evidence" "Meaningful risks" \
         "Rollback / recovery" "Expected outcome"; do
  if python3 scripts/checks/pr_body.py --section "$s" \
       < .github/pull_request_template.md 2>/dev/null; then
    err "pull_request_template.md: section '$s' reads as filled; the risk gate would pass an untouched template"
    leaked=1
  fi
done
[ "$leaked" -eq 0 ] && note "no template section reads as pre-filled"

echo "==> Agent skill mirror is in sync"
bash scripts/sync-skills.sh --check || fail=1

echo "==> Workflows declare least-privilege permissions"
for wf in .github/workflows/*.yml; do
  grep -q '^permissions:' "$wf" || err "$wf: missing top-level 'permissions:' block"
done
note "checked $(ls -1 .github/workflows/*.yml | wc -l | tr -d ' ') workflow(s)"

echo
if [ "$fail" -ne 0 ]; then
  echo "GOVERNANCE CHECKS FAILED" >&2
  exit 1
fi
echo "Governance checks passed."
