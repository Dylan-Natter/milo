# Changelog

All notable changes to this template are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Projects bootstrapped from this template should reset this file — see
`scripts/bootstrap.sh`.

## [Unreleased]

### Fixed

Five defects found by automated review on PR #5, four of which weakened the
gates themselves.

- **Risk gate passed an untouched PR template.** Section emptiness was tested
  with `inside && NF`, which counted the template's own HTML comment hints,
  placeholder bullets and checkboxes as content — so every required section read
  as filled and an R0–R3 PR could merge with no evidence, issue link, outcome,
  risk or rollback at all. Section detection moved to
  `scripts/checks/pr_body.py`, which ignores comments, bare code fences,
  unchecked boxes and value-less labels. It ships 14 unit tests and `make
  governance` additionally asserts that no section of the real template reads as
  pre-filled, so the regression cannot return silently
- **Risk gate accepted multiple risk labels**, taking the first via `head -1`;
  a PR labelled both R0 and R5 could be graded R0 by label order. It now
  requires exactly one, as ARCHITECTURE.md always specified
- **Risk gate failed open on an API error.** `|| true` collapsed a failed label
  query into "no labels defined", so an outage or token problem triggered the
  bootstrap escape and passed the gate. Request failure is now distinguished
  from an empty result and fails closed
- **`bootstrap.sh` skipped `.github/CODEOWNERS`.** The rewrite set matched by
  file extension and CODEOWNERS has none, so every generated project kept the
  template maintainer as owner of all paths — and once `make apply-platform`
  enables `require_code_owner_review`, those reviews are unsatisfiable
- **`apply-platform.sh` reported success after partial label failure**, leaving
  the load-bearing risk taxonomy incomplete while automation believed setup had
  succeeded. Failures now accumulate and exit non-zero


## [0.2.0] - 2026-08-29

Turns the governance model from documentation into enforced mechanism.

### Added

- `Makefile` — `make check` as the single definition of done, shared verbatim
  with CI so local and pipeline results cannot drift
- `scripts/checks/governance.sh` — validates canonical files, constitution
  ratification, issue-form schema, ADR structure, action SHA pinning, workflow
  permissions, YAML validity, and skill-mirror sync
- `scripts/checks/secrets.sh` — gitleaks with a 12-pattern fallback sweep
- `.github/workflows/risk-gate.yml` — makes the R0–R5 ladder executable;
  requires evidence proportional to risk and an ADR at R4+
- `.github/workflows/codeql.yml`, `.github/workflows/security.yml` — CodeQL,
  history-aware secret scanning, and dependency review
- `.github/rulesets/main.json` — branch protection as importable code
- `.github/labels.yml` — canonical taxonomy including the load-bearing `risk:*` labels
- `.github/dependabot.yml` — keeps SHA-pinned actions and future deps current
- `.claude/` — skills mirror, permission guardrails, and a hook blocking
  governance edits outside a `standards/*` branch, with a CI backstop
- `CLAUDE.md` — pointer-only entry point for Claude Code
- `.devcontainer/` — reproducible toolchain for humans and agents
- `docs/architecture/decisions/` — ADR template, index, and pre-staged
  ADR-0002 stack options matrix
- `docs/agents/playbooks.md` — procedures for dependencies, migrations, ADRs,
  CI failures, secret exposure, and escalation
- `scripts/bootstrap.sh` — one-shot template adaptation
- `scripts/apply-platform.sh` — applies labels, the branch ruleset, and
  secret scanning, which GitHub's template mechanism does not copy
- `scripts/template-sync.sh` + `make template-sync` / `template-check` —
  upstream-merge strategy for pulling template improvements downstream
- `docs/operations/template-usage.md` — creating a project from the template,
  what the template does not carry, conflict-resolution defaults, and the
  signals that the upstream-merge strategy has been outgrown
- `LICENSE`, `.gitignore`, `CHANGELOG.md`, `.github/ISSUE_TEMPLATE/config.yml`

### Changed

- PR template now carries an outcome contract (hypothesis, baseline, target,
  measurement window), implementing `docs/operations/improvement-contract.md`
- `.specify/templates/plan-template.md` — the Constitution Check placeholder is
  replaced with the five principles as explicit gates
- `.github/CODEOWNERS` — path-scoped so governance files need stricter review
- `.specify/integration.json` — registers `claude` alongside `copilot`

### Fixed

- CodeQL hung indefinitely on "Initialize CodeQL" (>10 minutes, no
  conclusion) on a repository without code scanning available. It now probes
  availability first and carries `timeout-minutes: 20`, so the job always
  reaches a conclusion instead of occupying a runner
- Secret scan failed with a 403: the workflow granted only `contents: read`,
  but gitleaks lists a PR's commits and needs `pull-requests: read`
- Dependency review hard-failed on repositories without the dependency graph
  (which a private repo needs GitHub Advanced Security for). It now probes
  availability and skips with an actionable warning instead of blocking a repo
  that cannot enable it, while still running strictly where it is supported
- Standards guard was over-scoped: it required a `standards/*` branch for any
  change to CODEOWNERS, rulesets, or agent settings, which made the very PR
  that introduces those files unmergeable. The constitution's Governance clause
  governs amendments to the constitution and the agent contract, not to
  enforcement configuration. The guard now requires a standards branch only to
  **amend** an authority document; enforcement config is protected by required
  code-owner review, and file additions are always allowed
- Risk gate was unsatisfiable on a fresh template repository: the `risk:*`
  labels it requires do not exist until `make apply-platform` runs. It now
  detects a repository with no risk labels defined, warns, and passes — and
  becomes strict automatically once the labels exist

- All four issue forms used `about:`, a legacy markdown-template field. The
  issue-forms schema requires `description:`; as written the forms would not
  render in the issue chooser
- GitHub Actions were pinned to mutable tags; now pinned to commit SHAs
- Residual `Dealis-OS` naming left by the rename in `a36ec79`

### Removed

- `.github/workflows/bootstrap-governance.yml` — superseded by
  `governance.yml`, which delegates to the shared scripts

## [0.1.0] - 2026-08-29

### Added

- Spec Kit v1.0.1 governance foundation: constitution, agent contract,
  architecture model, ADR-0001, issue/PR templates, and initial CI
