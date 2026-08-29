#!/usr/bin/env bash
# Applies the platform controls that live outside the repository.
#
# "Use this template" copies files. It does NOT copy labels, rulesets, branch
# protection, secrets, or repository settings — those are per-repository state.
# This script applies the ones this template depends on.
#
# Requires the GitHub CLI, authenticated with admin rights on the repository.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

command -v gh >/dev/null 2>&1 || {
  echo "gh CLI is required: https://cli.github.com/" >&2; exit 1; }

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
echo "Target repository: $REPO"
echo

echo "==> Applying labels from .github/labels.yml"
python3 - "$REPO" <<'PY'
import json, subprocess, sys, re
repo = sys.argv[1]
text = open(".github/labels.yml").read()

# Deliberately a tiny parser rather than a PyYAML dependency: the file is a
# flat list of name/color/description and must work on a bare runner.
labels, cur = [], None
for line in text.splitlines():
    line = line.rstrip()
    if line.startswith("- name:"):
        if cur: labels.append(cur)
        cur = {"name": line.split(":", 1)[1].strip().strip('"')}
    elif cur is not None and re.match(r'^\s+(color|description):', line):
        k, v = line.strip().split(":", 1)
        cur[k] = v.strip().strip('"')
if cur: labels.append(cur)

failed = []
for l in labels:
    args = ["gh", "label", "create", l["name"], "--repo", repo, "--force"]
    if l.get("color"): args += ["--color", l["color"]]
    if l.get("description"): args += ["--description", l["description"]]
    r = subprocess.run(args, capture_output=True, text=True)
    if r.returncode == 0:
        print(f"  {l['name']:<24} ok")
    else:
        failed.append(l["name"])
        print(f"  {l['name']:<24} FAILED: {r.stderr.strip()}")

print(f"\n  {len(labels) - len(failed)}/{len(labels)} labels applied")
if failed:
    # The risk:* labels are load-bearing: the risk gate reads them. Reporting
    # success after a partial install would leave automation believing the
    # taxonomy exists when it does not.
    print(f"\n  ERROR: {len(failed)} label(s) failed: {', '.join(failed)}", file=sys.stderr)
    sys.exit(1)
PY

echo
echo "==> Applying branch ruleset from .github/rulesets/main.json"
if gh api "/repos/$REPO/rulesets" --jq '.[].name' 2>/dev/null | grep -qx 'main-protection'; then
  id=$(gh api "/repos/$REPO/rulesets" --jq '.[] | select(.name=="main-protection") | .id')
  gh api --method PUT "/repos/$REPO/rulesets/$id" --input .github/rulesets/main.json >/dev/null
  echo "  updated existing ruleset (id $id)"
else
  gh api --method POST "/repos/$REPO/rulesets" --input .github/rulesets/main.json >/dev/null
  echo "  created ruleset 'main-protection'"
fi

echo
echo "==> Enabling security features"
gh api --method PATCH "/repos/$REPO" \
  -f 'security_and_analysis[secret_scanning][status]=enabled' \
  -f 'security_and_analysis[secret_scanning_push_protection][status]=enabled' \
  >/dev/null 2>&1 && echo "  secret scanning + push protection enabled" \
  || echo "  NOTE: secret scanning unavailable (private repo without GitHub Advanced Security)"

echo
echo "Platform controls applied."
echo "Verify: Settings -> Rules -> Rulesets, and the repository's Labels page."
