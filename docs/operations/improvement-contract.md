# Improvement, Observability, and Conformance Contracts

## Observability contract (vendor-neutral)

Future product systems should expose measurable signals for:
- Reliability: errors, failures, latency, availability
- Product behavior: key workflow progression and abandonment
- Engineering: deployment correlation and regressions
- AI usage: model latency, token usage, cost, failures, quality signals
- Security: authz/authn failures and suspicious activity
- Economics: infrastructure and third-party cost

## "Improve this app" contract

Expected lifecycle:
`feedback -> normalize -> deduplicate -> understand -> value/risk/effort assessment -> issue -> specification`

Context can include route, version, role, client context, relevant telemetry, and safeguards for sensitive data.

## Machine-generated improvement signals

Future sources should converge into the same governed lifecycle: user feedback, errors, performance, support trends, accessibility findings, security findings, dependency findings, and architecture drift.

## Outcome contract

Material improvements should include explicit problem, hypothesis, baseline, target, and measurement window. Merge is not success; measured outcome is success.

## Conformance loop

Continuously answer:
1. Where is truth?
2. What is current truth?
3. Does implementation conform?
4. Is truth still correct?
5. Should truth improve?
