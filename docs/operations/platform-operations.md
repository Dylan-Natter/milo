# Platform Operations Baseline

## Environment and deployment principles

- Lifecycle: local/agent -> preview -> staging -> production
- Promote artifacts through environments; do not rebuild differently per environment
- Separate secrets by environment with least privilege
- Require deployment approvals for production-class environments
- Keep auditable deployment history in GitHub

## Ruleset/branch protection recommendations

For `main`:
- Require pull requests
- Require at least one approval
- Require required status checks
- Block force-push and deletion
- Restrict direct pushes

For production environment:
- Required reviewers
- Optional wait timer for high-risk releases
- Branch restrictions (main and release tags only)

## Applying these controls

These recommendations are implemented as code, not left as prose:

- **Branch protection** — `.github/rulesets/main.json`, importable via
  Settings → Rules → Rulesets → Import. See `.github/rulesets/README.md`.
- **Labels** — `.github/labels.yml`. The `risk:*` labels are load-bearing:
  `.github/workflows/risk-gate.yml` reads them to set required evidence depth.
- **Required status checks** — the contexts listed in the ruleset correspond to
  the job names in `.github/workflows/`.

Changing a control here without changing the corresponding file leaves the
repository claiming a protection it does not have.
