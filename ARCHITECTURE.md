# Architecture Overview (Genesis)

Dealis is the **product application**. The reusable software-factory foundation it
currently carries is being prepared for extraction into Milo, so the boundary
between product-owned work and reusable factory work remains explicit.

## Canonical truth hierarchy

1. Constitution: `.specify/memory/constitution.md`
2. Agent operation contract: `AGENTS.md`
3. Tool-specific instructions: `.github/copilot-instructions.md`
4. Path/tool specialization (only when needed): `.github/instructions/` or nested `AGENTS.md`
5. Specifications/plans/tasks: `specs/` and `.specify/`
6. Architecture decisions: `docs/architecture/decisions/`
7. Work execution records: GitHub Issues and Pull Requests

## System model

`Idea -> Spec Kit artifacts -> implementation branch -> PR -> deterministic validation -> merge`

The repository is intentionally product-stack neutral until requirements justify concrete technologies.

Worker-neutral model: `specified work -> repository truth -> engineering worker -> branch -> PR -> validation`.
Copilot is default at genesis; repository truth is structured to remain usable by other capable agents.

## Delivery strategy

Default strategy is vertical slicing: each issue should deliver a complete user capability with necessary validation.

## Specialized agent policy

At genesis, no additional repository-specific specialist agents are required beyond Spec Kit/Copilot baseline capabilities.
Specialized agents are added only when they measurably improve reliability for a bounded class of work.

## Environment model

Planned lifecycle: `local/agent -> preview -> staging -> production`, each with stricter controls and least-privilege secrets.

## Risk model

- R0: Non-runtime documentation/process
- R1: Isolated low-risk changes
- R2: Contained feature behavior
- R3: Business logic/API/integration impact
- R4: Security/data/schema/infra boundaries
- R5: Irreversible or broad production-critical change

Risk level should determine validation depth, approvals, deployment gates, and rollback preparation.
