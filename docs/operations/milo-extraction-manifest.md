# Milo extraction manifest

This document records the boundary between Dealis as a product and the reusable factory foundation that is being prepared for extraction into Milo.

## Copy to Milo

These are the core reusable elements that should seed the canonical template repository:

- `.specify/`
- `.github/` governance and automation configuration
- `.claude/` and skill mirror structure
- `AGENTS.md`
- `CLAUDE.md`
- `ARCHITECTURE.md`
- `docs/architecture/decisions/`
- `docs/operations/template-usage.md`
- `docs/operations/platform-operations.md`
- `docs/operations/improvement-contract.md`
- `Makefile`
- `scripts/checks/`
- `scripts/spec-status.sh`
- `scripts/template-sync.sh`
- `scripts/sync-skills.sh`
- `scripts/apply-platform.sh`
- `SECURITY.md`
- `CONTRIBUTING.md`
- `CHANGELOG.md` as template changelog pattern

## Copy and generalize

These are reusable in principle, but currently carry Dealis product naming or product-specific assumptions that should be abstracted before they move into Milo:

- `README.md` — keep the engineering description, but remove product-specific framing where it is still overly template-centric.
- `scripts/bootstrap.sh` — generic bootstrap logic is reusable, but it must be made clearly template-oriented and project-neutral.
- `docs/operations/template-usage.md` — keep the strategy, but make it explicit that it is a template lifecycle guide, not a Dealis product guide.
- workflow labels and ruleset docs — keep the governance model, but ensure they are described as general factory controls rather than Dealis-specific policy.

## Keep in Dealis

These are product-owned and should not move into Milo:

- product requirements and specifications under `specs/`
- product-specific ADRs that describe Dealis choices
- product-level documentation and project history
- Dealis product identity, naming, and release ownership
- any product-specific configuration or deployment assumptions that belong only to the Dealis app

## Manual review

Files that are likely mixed or ambiguous and should be reviewed during actual extraction:

- `README.md`
- `docs/architecture/decisions/0002-product-stack-selection.md`
- `docs/product/`
- `scripts/bootstrap.sh`
- project-level governance docs that describe both template behavior and Dealis product behavior

## Overall boundary

Dealis remains a real product application that currently carries reusable engineering infrastructure. Milo should become the canonical reusable foundation for future projects, while Dealis keeps its product history, decisions, and application-specific state.
