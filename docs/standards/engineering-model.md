# Engineering Model

## Deterministic authority

Use deterministic systems for objective facts: checks, tests, policies, scans, schema and build validity.
AI assists reasoning and synthesis, not final objective pass/fail authority.

## Closed improvement loop

`observe -> understand -> hypothesize -> prioritize -> specify -> build -> validate -> deploy -> measure -> learn -> repeat`

## Standards improvement loop

When failures occur, prefer mechanical prevention (test/CI/policy) before adding prose-only rules.
Standards changes require reason, evidence, scope, and conflict analysis.

## Deferred capabilities

Intentionally deferred until justified by specifications:
- application framework and runtime stack
- database and data platform
- cloud/hosting provider
- identity provider
- observability vendor
- autonomous production deployment
- multi-agent orchestration beyond bounded specialization

## Where deterministic authority lives

`make check` is the mechanical authority for this repository. It is the entry
point for humans, agents, and CI alike:

| Target | Enforces |
|---|---|
| `make governance` | Canonical files, constitution ratification, issue-form schema, ADR structure, action SHA pinning, workflow permissions, YAML validity, skill-mirror sync |
| `make secrets` | Committed credential material (gitleaks over full history) |
| `make lint` / `typecheck` / `test` | Product stack — honest no-ops until ADR-0002 is accepted |

The stack targets are deliberately no-ops rather than absent. A gate that exists
and reports "no stack detected" is auditable; a gate that does not exist yet is
how a repository ends up merging untested code while claiming Principle IV.

## Deferred capabilities — how the deferral ends

The deferrals above are lifted by
`docs/architecture/decisions/0002-product-stack-selection.md`, which is
pre-staged with an options matrix and left deliberately undecided. Accepting it
is the transition from software factory to product.
