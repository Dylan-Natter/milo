#!/usr/bin/env bash
# Scans the repository for committed credential material.
#
# Prefers gitleaks (scans full history, maintained rule set). Falls back to a
# deliberately conservative regex sweep of the working tree when gitleaks is
# unavailable, and says so loudly — the fallback is a smoke test, not a
# guarantee.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

if command -v gitleaks >/dev/null 2>&1; then
  echo "==> gitleaks detect (full history)"
  gitleaks detect --redact --no-banner --exit-code 1
  echo "gitleaks found no leaks."
  exit 0
fi

echo "==> gitleaks not installed; running fallback pattern sweep (working tree only)"
echo "    Install gitleaks for history-aware scanning: https://github.com/gitleaks/gitleaks"

patterns=(
  'AKIA[0-9A-Z]{16}'                                  # AWS access key id
  'ASIA[0-9A-Z]{16}'                                  # AWS temporary key id
  'gh[pousr]_[A-Za-z0-9]{36,}'                        # GitHub classic tokens
  'github_pat_[A-Za-z0-9_]{22,}'                      # GitHub fine-grained PAT
  'xox[abprs]-[A-Za-z0-9-]{10,}'                      # Slack tokens
  'sk-[A-Za-z0-9]{20,}'                               # OpenAI-style keys
  'sk-ant-[A-Za-z0-9_-]{20,}'                         # Anthropic keys
  '(sk|pk|rk)_(live|test)_[A-Za-z0-9]{16,}'           # Stripe keys
  'AIza[0-9A-Za-z_-]{35}'                             # Google API key
  'glpat-[A-Za-z0-9_-]{20,}'                          # GitLab PAT
  'eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.'    # JWT
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'                # PEM private keys
)

found=0
for p in "${patterns[@]}"; do
  # -I skips binaries. Only file NAMES are printed: never echo the secret into
  # CI logs, which are themselves a disclosure surface.
  if git grep -I -l -E "$p" -- . ':(exclude)scripts/checks/secrets.sh' >/dev/null 2>&1; then
    echo "  FAIL: credential-shaped content matched in:" >&2
    git grep -I -l -E "$p" -- . ':(exclude)scripts/checks/secrets.sh' | sed 's/^/    /' >&2
    found=1
  fi
done

if [ "$found" -ne 0 ]; then
  echo "SECRET SCAN FAILED — remove the material and rotate the credential." >&2
  exit 1
fi
echo "Fallback secret sweep passed (working tree only)."
