# Architecture Decision Records

An ADR captures a consequential architecture decision, the options weighed, and
the consequences accepted. The constitution requires one for any consequential
architecture change.

## Index

| ADR | Title | Status | Date |
|---|---|---|---|
| [0001](0001-genesis-foundation.md) | Genesis governance-first foundation | Accepted | 2026-08-29 |
| [0002](0002-product-stack-selection.md) | Product stack selection | Proposed | 2026-08-29 |

## Writing an ADR

1. Copy [`template.md`](template.md) to `NNNN-short-title.md`, using the next
   free four-digit number.
2. Fill every section. `make governance` fails an ADR missing **Status**,
   **Context**, **Decision**, or **Consequences**.
3. Set the status to `Proposed` while under review; move to `Accepted` on merge.
4. Never rewrite an accepted ADR to reflect a new decision. Write a new ADR and
   mark the old one `Superseded by ADR-NNNN` — the record is the value.
5. Add a row to the index above.

## When an ADR is required

- Selecting or replacing a framework, datastore, cloud, or identity provider
- Introducing a new service, deployment boundary, or trust boundary
- Changing a persistent data model in a way that requires migration
- Adopting a dependency with material lock-in or licensing consequence
- Any change assessed at risk level R4 or R5

When in doubt, write one. An unnecessary ADR costs an hour; an unrecorded
decision costs the next engineer a week.
