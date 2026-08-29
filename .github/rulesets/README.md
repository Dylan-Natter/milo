# Branch protection as code

`docs/operations/platform-operations.md` describes the intended protection for
`main`. This directory is that description made executable — the repository's
own engineering model requires mechanical prevention over prose-only rules.

## Applying

GitHub can import a ruleset JSON directly:

**UI** — Settings → Rules → Rulesets → New ruleset → Import a ruleset →
select `main.json`.

**CLI** — requires admin scope on the repository:

```bash
gh api --method POST /repos/{owner}/{repo}/rulesets \
  --input .github/rulesets/main.json
```

To update an existing ruleset, `PUT` to `/repos/{owner}/{repo}/rulesets/{id}`.

## What `main.json` enforces

| Rule | Effect |
|---|---|
| `deletion`, `non_fast_forward` | `main` cannot be deleted or force-pushed |
| `pull_request` | 1 approval, code-owner review, stale reviews dismissed on push, review threads resolved before merge |
| `required_status_checks` | Governance, stack, risk gate, and secret scan must pass; branch must be up to date |
| `required_signatures` | Commits must be signed |

## Two deliberate strictness choices

`require_last_push_approval` means an author cannot approve their own final
push — this is what stops an agent from self-approving its way to merge, and is
the single most important line in the file for an AI-native repository.

`required_signatures` will reject unsigned commits, including those from some
automation. Verify your agents and bots sign their commits before enabling it,
or drop that rule and record the exception as an ADR.

## Bypass actors

`bypass_actors` is intentionally empty. Every exception granted here is an
un-audited path around the gates. If one becomes genuinely necessary, add it
with an ADR recording who, why, and when it expires.
