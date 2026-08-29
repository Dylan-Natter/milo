# Milo Engineering Constitution

## Core Principles

### I. Simplicity First (MUST)
Engineering choices MUST use the smallest architecture that satisfies known requirements. The repository MUST stay product-framework neutral until an approved specification requires concrete product technology.

### II. Security by Default (MUST)
Changes MUST enforce least privilege, explicit trust boundaries, and no committed secrets. Agents and humans MUST NOT weaken security controls to accelerate delivery.

### III. Spec-Driven Delivery (MUST)
Material changes MUST map to a governing specification and issue. Work MUST flow through Spec Kit artifacts (specification, plan, tasks) before implementation-ready execution.

### IV. Deterministic Validation (MUST)
Objective claims (tests, lint, policies, scans, schemas, checks) MUST be validated by deterministic systems. AI judgment MAY guide decisions but MUST NOT replace mechanical evidence.

### V. Reversible, Observable Improvement (SHOULD)
Changes SHOULD be small, vertically sliced, measurable, and reversible. Product success SHOULD be judged by post-deployment outcomes, not merge completion.

## Engineering Standards

- **Architecture discipline**: Consequential architecture changes MUST be captured as ADRs.
- **Dependency discipline**: New dependencies MUST include explicit purpose and risk review.
- **Data discipline**: Persistent-data/schema changes MUST include migration and rollback planning.
- **Documentation discipline**: Durable behavior changes MUST update canonical documentation.
- **Accessibility discipline**: User-facing features SHOULD include accessibility acceptance criteria.
- **AI neutrality**: Repository truth MUST remain usable by multiple capable engineering agents.

## Governance

This constitution is the highest engineering authority in this repository. Lower-level guidance MUST reference (not duplicate) constitution rules. Amendments require a standards PR that includes reason, evidence, affected scope, and conflict analysis.

**Version**: 1.0.0 | **Ratified**: 2026-08-29 | **Last Amended**: 2026-08-29
