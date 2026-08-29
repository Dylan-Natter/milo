# ADR 0002: Product stack selection

- **Status**: Proposed — decide before the first product specification is implemented
- **Date**: 2026-08-29
- **Risk level**: R4 (broad, expensive to reverse once code exists)
- **Governing spec/issue**: Genesis Issue #2 — Define the First Product Specification

## Context

`docs/standards/engineering-model.md` deliberately defers the application
framework, datastore, cloud, identity provider, and observability vendor until a
specification justifies them. That deferral is correct, but it leaves every new
project starting from a blank research page.

This ADR is pre-staged so the first stack decision is a review, not a research
project. The analysis below is prepared; the **decision is not made**. A human
must choose an option, fill in the Decision section, and move the status to
Accepted before any product code merges.

The choice is R4 because framework and datastore decisions become effectively
irreversible once a schema and a test suite exist on top of them.

## Options considered

| Option | Summary | Pros | Cons | Est. effort to first slice |
|---|---|---|---|---|
| **A. TypeScript end-to-end**<br>Next.js + Postgres + Prisma, Vercel or Fly.io | One language across UI and API | Single toolchain; largest hiring pool; strong AI-agent training coverage; fastest UI iteration | Weak for CPU-bound or data-science work; ORM abstraction leaks at scale | 2–3 days |
| **B. Python API + thin UI**<br>FastAPI + Postgres + SQLAlchemy + Alembic, containers on Fly.io/Cloud Run | Backend-first, data/AI-native | Best-in-class for AI/ML and data work; excellent typed-schema story via Pydantic; Alembic is a mature migration path | Two languages if a rich UI is needed; slower cold starts | 3–4 days |
| **C. Go API + TypeScript UI**<br>Go + Postgres + sqlc, containers | Performance and operational simplicity | Single static binary; excellent concurrency; low runtime cost | Slowest feature velocity; smallest agent training coverage; more boilerplate | 5–7 days |
| **D. Defer further** | Keep deferring the decision | No premature lock-in | Blocks all product work; the deferral itself becomes the bottleneck | n/a |

### Cross-cutting choices that travel with the stack

| Concern | Recommended default | Rationale |
|---|---|---|
| Datastore | PostgreSQL | Relational integrity, JSONB escape hatch, universally supported, portable across clouds |
| Migrations | Versioned, checked-in, forward-and-rollback | Constitution "Data discipline" requires migration and rollback planning |
| Identity | Managed provider (Auth0/Clerk/Cognito) over hand-rolled | Constitution II — authentication is the worst place to build bespoke |
| Observability | OpenTelemetry SDK + vendor-neutral exporter | Keeps `improvement-contract.md` vendor-neutral; swap backends without recoding |
| Hosting | Container-based (Fly.io / Cloud Run) over raw VMs or heavy k8s | Constitution I — smallest thing that satisfies the requirement |
| CI | GitHub Actions, already in use | No new system to operate |

### Decision criteria

Weight these against the answers to `docs/product/genesis-workflow.md`:

1. **Team fluency** — the stack the maintainers can debug at 2am outranks the
   theoretically better one.
2. **Workload shape** — CRUD/UI-heavy favours A; data/AI-heavy favours B;
   latency/throughput-critical favours C.
3. **Agent leverage** — this is an AI-native factory. Model training coverage is
   a real input: A and B materially outperform C for autonomous implementation.
4. **Operational surface** — prefer managed services until scale justifies
   otherwise.
5. **Reversibility** — keep business logic free of framework types so the
   framework, not the domain, is what gets replaced.

## Decision

> **NOT YET DECIDED.** Replace this block with the chosen option, in the active
> voice ("We will build on …"), and state explicitly what was rejected and why.
> Then set Status to `Accepted`.

## Consequences

### Positive

- To be completed on decision.

### Negative / accepted tradeoffs

- To be completed on decision.

### Follow-on work required

Once this ADR is accepted, the same PR (or its immediate successor) MUST:

1. Add the toolchain so `make lint`, `make typecheck`, and `make test` stop
   being no-ops — Constitution IV is not satisfied until they execute.
2. Add the stack's `.gitignore` section and prune the unused ecosystems.
3. Add a `.devcontainer` toolchain matching the stack.
4. Record the migration tool and directory convention.
5. Update `docs/standards/engineering-model.md` to move the chosen items out of
   "Deferred capabilities".

## Constitution check

- [ ] **I. Simplicity First** — chosen stack is the smallest that satisfies the spec
- [ ] **II. Security by Default** — identity and secret handling named, not deferred
- [ ] **III. Spec-Driven Delivery** — decision traces to the first product spec
- [ ] **IV. Deterministic Validation** — the stack ships a working test gate
- [ ] **V. Reversible, Observable Improvement** — domain logic isolated from framework types

## Reversibility

Cheap before a schema exists. Expensive once migrations and a test suite are
built on it. Effectively irreversible after the first production data lands.
The window to change your mind is measured in weeks, not months — which is why
this ADR is staged rather than left to be written under delivery pressure.
