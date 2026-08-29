# Milo

Milo is a governance-first, AI-native software factory template for building
production-ready application repositories from a consistent, reusable foundation.

This repository provides the specification workflow, validation gates, security
posture, and agent guardrails needed to start a new project with the right
engineering controls from day one. It is intended to be cloned or used as a GitHub
Template Repository for future app work.

## What makes it different

Most starter templates are a pile of configuration. This one is built on a
single rule, taken from its own engineering model:

> Prefer mechanical prevention (test/CI/policy) before adding prose-only rules.

Every governance claim in this repository has a mechanism behind it:

| Claim | Mechanism |
|---|---|
| Deterministic validation is mandatory | `make check` — the same scripts CI runs |
| Risk determines validation depth | `risk:R0`–`R5` labels enforced by `.github/workflows/risk-gate.yml` |
| Consequential decisions need an ADR | ADR structure validated in CI; required at R4+ |
| `main` is protected | `.github/rulesets/main.json` — protection as code, not prose |
| No committed secrets | gitleaks over full history + a fallback sweep |
| Governance can't be edited casually | Claude hook + a CI standards-branch guard |
| Repository truth is worker-neutral | Skills mirrored to Copilot *and* Claude, sync enforced |

## Quick start

```bash
make check          # the gate — run this first, it should pass on a clean clone
make help           # every available target
make spec-status    # specification inventory and progress
```

Bootstrapping a new project from this template:

```bash
bash scripts/bootstrap.sh
```

It rewrites the project identity, resets the changelog, and prints the ordered
next steps.

## The workflow

```
idea → /speckit-specify → /speckit-clarify → /speckit-plan → /speckit-tasks → /speckit-implement
```

Specification artifacts land in `specs/NNN-feature/`. Skills are available to
both Copilot (`.github/skills/`) and Claude Code (`.claude/skills/`, generated
by `make sync-skills`).

Spec Kit CLI, pinned:

```bash
pipx install 'git+https://github.com/github/spec-kit.git@v1.0.1'
```

## Canonical files

| File | Role |
|---|---|
| `.specify/memory/constitution.md` | Highest engineering authority |
| `AGENTS.md` | Universal agent contract |
| `CLAUDE.md` / `.github/copilot-instructions.md` | Tool-specific pointers |
| `ARCHITECTURE.md` | Operating model and R0–R5 risk ladder |
| `docs/architecture/decisions/` | ADRs — start at [README](docs/architecture/decisions/README.md) |
| `docs/agents/playbooks.md` | Procedures for high-risk operations |
| `Makefile` | The definition of done |

## Before you write product code

Two gates are deliberate and load-bearing:

1. **Answer the 11 genesis questions** in
   [`docs/product/genesis-workflow.md`](docs/product/genesis-workflow.md).
   Everything downstream generates from them.
2. **Decide [ADR-0002](docs/architecture/decisions/0002-product-stack-selection.md)**.
   The stack options matrix is written and the tradeoffs are analyzed; the
   decision is intentionally left open. Until it is accepted, `make lint`,
   `make typecheck`, and `make test` are honest no-ops — and the repository says
   so rather than pretending to validate.

## What is deliberately not built

- Product application code, framework, database, or cloud
- An identity provider or observability vendor
- Autonomous production deployment

These are deferred by
[`docs/standards/engineering-model.md`](docs/standards/engineering-model.md),
not forgotten. ADR-0002 is where the deferral ends.

## Applying the platform controls

Two things live outside the repository and must be applied once per project:

- **Branch protection** — import `.github/rulesets/main.json`
  (see [`.github/rulesets/README.md`](.github/rulesets/README.md))
- **Labels** — create from `.github/labels.yml`; the risk gate depends on them

Both are applied in one step by `make apply-platform` (requires `gh` with admin
rights on the repository).

## Keeping projects current

Projects created from this template keep it as a git remote and merge
improvements in:

```bash
make template-check   # has the template moved?
make template-sync    # merge them in
```

Full guidance, including conflict-resolution defaults and when to outgrow this
strategy: [`docs/operations/template-usage.md`](docs/operations/template-usage.md).

## Upgrade path

Track `github/spec-kit` stable releases, update the pinned version above, re-run
`specify init --here --force --non-interactive`, then `make check` and review the
diff — keeping local governance decisions while accepting upstream updates.
