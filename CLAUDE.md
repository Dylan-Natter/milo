# Claude Code — repository entry point

This file is a pointer, not a second rulebook. Duplicated guidance drifts; the
constitution requires lower-level guidance to reference rather than restate.

## Read these first

| Order | File | Authority |
|---|---|---|
| 1 | `.specify/memory/constitution.md` | Highest engineering authority |
| 2 | `AGENTS.md` | Universal agent behavior contract (22 rules) |
| 3 | `ARCHITECTURE.md` | Operating model, truth hierarchy, R0–R5 risk ladder |
| 4 | `docs/architecture/decisions/` | Accepted architecture decisions |
| 5 | `specs/` | The governing specification for the work in hand |

## The gate

```bash
make check
```

This is the definition of done. CI runs the identical scripts, so a green local
run and a green pipeline mean the same thing. Run it before every push.

## Workflow

Spec-driven delivery is mandatory for material change (Constitution III):

```
/speckit-specify → /speckit-clarify → /speckit-plan → /speckit-tasks → /speckit-implement
```

Skills live in `.claude/skills/`, mirrored from `.github/skills/` by
`make sync-skills`. Edit the `.github/` copy; the mirror is generated.

## Guardrails you will encounter

- **Governance is protected in two tiers.**

  *Authority documents* — `.specify/memory/constitution.md` and `AGENTS.md` —
  may only be **amended** on a `standards/*` branch. The constitution requires
  amendments to carry reason, evidence, affected scope, and conflict analysis.
  CI enforces this on every PR. Adding a file that did not previously exist is
  not an amendment and is always allowed.

  *Enforcement configuration* — `.github/CODEOWNERS`, `.github/rulesets/`,
  `.claude/settings.json` — is protected by required code-owner review. The
  ruleset sets `require_code_owner_review`, so these cannot merge without the
  owner regardless of branch.

  The local `Edit`/`Write` hook is deliberately stricter than CI: it blocks the
  enforcement-configuration paths too. Erring toward stricter locally is cheap.
  Note the hook cannot see changes made through Bash or any other path — CI and
  CODEOWNERS are the real backstop.
- **Every PR needs exactly one `risk:R0`…`risk:R5` label.** The risk gate
  requires evidence proportional to the level; R4+ additionally requires a
  linked ADR.
- **No stack is chosen yet.** `make lint`, `typecheck`, and `test` are no-ops
  until ADR-0002 is accepted. Do not add product code before that decision —
  and do not quietly pick a stack by writing a `package.json`.

## Before you finish

1. `make check` passes.
2. The change maps to a governing issue/spec.
3. Consequential architecture decisions have an ADR.
4. Durable behavior changes updated the canonical docs.
