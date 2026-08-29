# Using this template

How to create a project from this repository, and how to keep it current.

## Creating a project

```bash
gh repo create <owner>/<project> --template Dylan-Natter/milo --private --clone
cd <project>
bash scripts/bootstrap.sh    # rewrites identity, resets the changelog
make apply-platform          # labels, branch ruleset, secret scanning
make check                   # confirm the gate is green
```

Or from the UI: **Use this template → Create a new repository**, then run the
same three commands in the clone.

## What the template does not carry

"Use this template" copies files and directory structure. It does **not** copy:

| Not copied | Restored by |
|---|---|
| Labels (including the load-bearing `risk:*` set) | `make apply-platform` |
| Rulesets and branch protection | `make apply-platform` |
| Secret scanning settings | `make apply-platform` |
| Secrets, variables, environments | Manual — by design |
| Git history, branches, tags, issues, PRs | Not restored; a template starts fresh |

Until `make apply-platform` runs, the risk gate detects that no `risk:*` labels
exist and passes with a warning rather than blocking. That is a deliberate
bootstrap allowance, and it ends automatically the moment the labels exist.

## Staying current — upstream merge (Strategy A)

The template remains a git remote. Improvements arrive as an ordinary merge.

```bash
make template-check   # has the template moved? (read-only)
make template-sync    # merge template/main into the current branch
make check            # verify the gate still passes
```

The first sync needs `--allow-unrelated-histories`, because a repository created
from a template starts with a fresh history and shares no common ancestor.
`scripts/template-sync.sh` passes it automatically.

### Resolving sync conflicts

Conflicts are normal and grow with divergence. The useful default:

| File class | Usually resolve to | Why |
|---|---|---|
| `.specify/memory/constitution.md`, `AGENTS.md`, `.github/rulesets/`, `.github/CODEOWNERS`, `scripts/checks/` | **Template** | These are the governance improvements you are syncing for |
| `README.md`, `LICENSE`, `CHANGELOG.md`, `specs/`, product code | **Yours** | Project-specific by definition |
| `Makefile`, workflows | **Merge by hand** | Template gates plus your stack targets both matter |

```bash
git checkout --theirs .specify/memory/constitution.md   # take the template's
git checkout --ours README.md                           # keep yours
git add -A && git commit && make check
```

### Cadence

Sync when the template publishes something you want, not on a schedule. Check
`CHANGELOG.md` in the template to decide. A quarterly `make template-check` is
enough for most projects.

### When Strategy A stops working

Upstream merge is deliberately simple and has a ceiling. Move to reusable
workflows (`workflow_call`) when any of these become true:

- More than roughly five downstream projects
- The same conflict is resolved the same way in every project, every sync
- A governance fix needs to reach every project the day it lands, not eventually

At that point CI moves into the template and downstream repos reference it,
so improvements propagate without a merge. That migration is an ADR-worthy
change; it is not a reason to avoid Strategy A now.

## Maintaining the template itself

1. Change the template on a branch; `make check` must pass.
2. Record the change in the template's `CHANGELOG.md` — that file is how
   downstream projects decide whether a sync is worth it.
3. Governance changes need a `standards/*` branch; the CI standards guard
   enforces it.
4. Tag releases (`v0.2.0`) so a project can sync to a known point rather than
   to a moving `main`.

## Security features that depend on your GitHub plan

Three checks depend on repository capabilities rather than on anything in the
code. All three degrade to a warning instead of blocking, so the template works
unchanged in every configuration:

| Check | Needs | Without it |
|---|---|---|
| CodeQL | Code scanning — free on public repos, GitHub Advanced Security on private | Probe warns and skips; job still concludes |
| Dependency review | Dependency graph — same requirement | Probe warns and skips |
| Secret scanning + push protection | GHAS on private repos | `make apply-platform` reports it is unavailable and continues |

gitleaks in the `Security` workflow has no such dependency: it runs everywhere
and is the secret-scanning backstop on repositories without GHAS.

To turn the skipped checks on: Settings → Code security and analysis, or make
the repository public.
