# Agent playbooks

Procedures for the recurring operations where an agent is most likely to cause
damage. Each is deliberately mechanical: the point is that the same sequence
runs every time, regardless of which worker executes it.

---

## Adding a dependency

The constitution requires explicit purpose and risk review (Constitution
"Dependency discipline").

1. Search the codebase first — AGENTS.md rule 7. Most "missing" functionality
   already exists.
2. Justify in the PR body: what it does, why it beats the alternatives, and what
   the cost of removing it later is.
3. Check licence, maintenance signal, and transitive weight. The dependency
   review workflow fails high-severity advisories and denies AGPL/GPL-3.0.
4. Pin the version. Dependabot keeps it current.
5. Label the PR `risk:R1` (dev dependency) or `risk:R3` (runtime dependency in
   the request path).

---

## Changing persistent data

The most common way to cause unrecoverable damage.

1. **Never edit an applied migration.** Write a new one.
2. Every migration needs a tested rollback. If a change cannot be rolled back
   (dropping a column, destroying data), say so explicitly and treat it as R5.
3. Expand/contract for anything live:
   - *Expand* — add the new column/table, deploy, keep writing to both.
   - *Backfill* — batch, resumable, monitored.
   - *Contract* — remove the old path only once nothing reads it.
4. Test the migration against a copy with realistic volume. A migration that
   passes on ten rows and locks the table on ten million is not tested.
5. Label `risk:R4` minimum. An ADR is required.

---

## Writing an ADR

1. Copy `docs/architecture/decisions/template.md` to the next free number.
2. Fill **Options considered** honestly, including "do nothing". An options
   table with one real candidate is advocacy, not a decision record.
3. State consequences you dislike. An ADR listing only benefits is not credible.
4. Never rewrite an accepted ADR — supersede it.
5. Add the row to `docs/architecture/decisions/README.md`.

---

## Responding to a CI failure

1. **Reproduce locally first**: `make check`. Never push a speculative fix.
2. Fix the cause, not the symptom. Never skip, disable, or quarantine a test to
   get green — AGENTS.md rule 14, and CI passing is meaningless once it is
   optional.
3. "Flake" is a diagnosis requiring evidence: the same commit passing earlier,
   or a failure before any test body ran. Otherwise the failure is real.
4. If the failure is genuinely unrelated to the change, say so in the PR with
   the evidence rather than silently re-running.

---

## Handling a secret exposure

Speed matters more than tidiness.

1. **Rotate the credential first.** The commit is already public to anyone with
   read access; removing it does not un-disclose it.
2. Then purge it from history (`git filter-repo`, or BFG) and force-push with
   the owner's approval.
3. Verify: `make secrets` with gitleaks installed scans full history.
4. Record what leaked, for how long, and what it could reach.
5. Add the pattern to `scripts/checks/secrets.sh` so the same class cannot
   recur — mechanical prevention over a reminder to be careful.

---

## Escalating instead of guessing

AGENTS.md rule 20 requires stopping on contradictory requirements. Stop and ask
when:

- The spec and an existing ADR disagree.
- Two readings of a requirement produce materially different implementations.
- The smallest correct change requires touching a governance file.
- A fix requires weakening a security control or removing a check.

State the contradiction, the options, and a recommendation. Do not pick silently
and note it in a comment — that is how a repository loses its truth hierarchy.
