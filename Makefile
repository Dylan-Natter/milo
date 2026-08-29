# Milo — the one command that means "green".
#
# `make check` is the repository's definition of done. Humans run it before
# opening a PR; agents run it to self-verify; CI runs the identical targets, so
# a green local run and a green pipeline mean the same thing.
#
# Stack targets auto-detect the toolchain and no-op until an ADR selects one.
# That keeps the repository stack-neutral (Constitution I) while guaranteeing
# the gate exists from day one (Constitution IV).

.DEFAULT_GOAL := help
SHELL := /usr/bin/env bash

.PHONY: template-check help check governance secrets lint typecheck test build spec-status sync-skills apply-platform template-sync bootstrap hooks clean

help: ## Show available targets
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
	  | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

check: governance secrets lint typecheck test ## Full gate — run before every PR
	@echo
	@echo "════════════════════════════════════════════"
	@echo " All checks passed. Safe to open a PR."
	@echo "════════════════════════════════════════════"

governance: ## Validate repository governance invariants
	@bash scripts/checks/governance.sh

secrets: ## Scan for committed credential material
	@bash scripts/checks/secrets.sh

lint: ## Lint the product stack (no-op until a stack ADR lands)
	@if [ -f package.json ] && grep -q '"lint"' package.json; then \
	  echo "==> npm run lint"; npm run lint; \
	elif [ -f pyproject.toml ] && command -v ruff >/dev/null 2>&1; then \
	  echo "==> ruff check"; ruff check .; \
	elif [ -f go.mod ]; then \
	  echo "==> go vet"; go vet ./...; \
	else \
	  echo "==> lint: no product stack detected (skipped)"; \
	fi

typecheck: ## Type-check the product stack (no-op until a stack ADR lands)
	@if [ -f tsconfig.json ]; then \
	  echo "==> tsc --noEmit"; npx --no-install tsc --noEmit; \
	elif [ -f pyproject.toml ] && command -v mypy >/dev/null 2>&1; then \
	  echo "==> mypy"; mypy .; \
	else \
	  echo "==> typecheck: no product stack detected (skipped)"; \
	fi

test: ## Run the product test suite (no-op until a stack ADR lands)
	@if [ -f package.json ] && grep -q '"test"' package.json; then \
	  echo "==> npm test"; npm test; \
	elif [ -f pyproject.toml ] && command -v pytest >/dev/null 2>&1; then \
	  echo "==> pytest"; pytest -q; \
	elif [ -f go.mod ]; then \
	  echo "==> go test"; go test ./...; \
	else \
	  echo "==> test: no product stack detected (skipped)"; \
	  echo "    NOTE: Constitution IV requires deterministic validation."; \
	  echo "    The first product PR MUST add a real test suite here."; \
	fi

build: ## Build the product stack (no-op until a stack ADR lands)
	@if [ -f package.json ] && grep -q '"build"' package.json; then \
	  echo "==> npm run build"; npm run build; \
	else \
	  echo "==> build: no product stack detected (skipped)"; \
	fi

sync-skills: ## Regenerate .claude/skills from .github/skills
	@bash scripts/sync-skills.sh

spec-status: ## Show the specification inventory and lifecycle state
	@bash scripts/spec-status.sh

apply-platform: ## Apply labels, ruleset, and security settings via gh (needs admin)
	@bash scripts/apply-platform.sh

template-sync: ## Merge upstream template improvements into this project
	@bash scripts/template-sync.sh

template-check: ## Report whether the template has moved ahead (no writes)
	@bash scripts/template-sync.sh --check

bootstrap: ## Rename this template for a new project (interactive)
	@bash scripts/bootstrap.sh

hooks: ## Install the local pre-push governance hook
	@mkdir -p .git/hooks
	@printf '#!/usr/bin/env bash\nexec make check\n' > .git/hooks/pre-push
	@chmod +x .git/hooks/pre-push
	@echo "Installed .git/hooks/pre-push -> make check"

clean: ## Remove build and cache artifacts
	@rm -rf dist build coverage .pytest_cache .ruff_cache .mypy_cache .turbo
	@echo "Cleaned."
