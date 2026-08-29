#!/usr/bin/env bash
# Provisions the toolchain every worker — human or agent — is expected to have.
set -euo pipefail

echo "==> Installing Spec Kit CLI (pinned)"
pipx install 'git+https://github.com/github/spec-kit.git@v1.0.1' 2>/dev/null \
  || pip install --user 'git+https://github.com/github/spec-kit.git@v1.0.1' \
  || echo "    WARNING: Spec Kit install failed; install manually (see README)"

echo "==> Installing gitleaks"
GITLEAKS_VERSION="8.21.2"
if ! command -v gitleaks >/dev/null 2>&1; then
  tmp="$(mktemp -d)"
  if curl -sSfL \
    "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" \
    -o "$tmp/gitleaks.tar.gz"; then
    tar -xzf "$tmp/gitleaks.tar.gz" -C "$tmp" gitleaks
    sudo install -m 0755 "$tmp/gitleaks" /usr/local/bin/gitleaks
    echo "    gitleaks $(gitleaks version 2>/dev/null || echo installed)"
  else
    echo "    WARNING: gitleaks download failed; make secrets will use the weaker fallback"
  fi
  rm -rf "$tmp"
fi

echo "==> Installing local pre-push hook"
make hooks

echo
echo "Ready. Run 'make check' to verify the repository gate."
