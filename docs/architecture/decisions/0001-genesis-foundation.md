# ADR 0001: Genesis governance-first foundation

- **Status**: Accepted
- **Date**: 2026-08-29

## Context

The repository starts empty and must become a reusable AI-native software factory without prematurely selecting product frameworks or infrastructure.

## Decision

- Initialize GitHub Spec Kit in this repository using stable `specify-cli` release `v1.0.1`.
- Make the Spec Kit constitution file (`.specify/memory/constitution.md`) the canonical engineering authority.
- Keep implementation intentionally product-neutral and focused on governance, deterministic validation, and secure defaults.

## Consequences

- Future product work starts from spec/plan/tasks rather than ad-hoc coding.
- Tooling remains upgradeable by tracking Spec Kit releases and updating the pinned CLI version.
- Additional complexity (custom orchestration, app stack, deployment platform) is deferred until justified by approved specs.
