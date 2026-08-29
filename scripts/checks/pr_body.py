#!/usr/bin/env python3
"""Decide whether a PR body section carries substantive content.

The risk gate requires evidence proportional to risk. That is only meaningful if
"the section is filled in" means a human wrote something — not that the template's
own scaffolding is still sitting there. An earlier version tested for any
non-blank line, which the untouched template satisfied in every section, so the
gate passed PRs with no evidence at all.

Lives in a file rather than inline in YAML so it can be unit-tested; run
`python3 scripts/checks/pr_body.py --self-test` (wired into `make governance`).

Usage:
    pr_body.py --section "Validation evidence" < body.md   # exit 0 if filled
    pr_body.py --self-test
"""
from __future__ import annotations

import argparse
import re
import sys

# Template hints live in HTML comments; they are never content.
_COMMENT = re.compile(r"<!--.*?-->", re.DOTALL)
_LIST_MARKER = re.compile(r"^[-*+]\s+")
_CHECKBOX = re.compile(r"^[-*+]\s*\[([ xX])\]\s*")
_EMPHASIS = re.compile(r"[*_`]")
# "Issue:", "**Baseline** (current measured value):", "ADR (required at R4+):" —
# any short run without an internal colon, ending in one, is a label with no
# value. Enumerating allowed characters was fragile: '+' was missing, so
# "ADR (required at R4+):" counted as content.
_BARE_LABEL = re.compile(r"^[^:]{0,80}:$")


def _is_substantive(line: str) -> bool:
    s = line.strip()
    if not s:
        return False
    if s.startswith("```"):          # bare code fence
        return False
    if s.startswith(">"):            # blockquote hint
        return False

    m = _CHECKBOX.match(s)
    if m:
        # An UNCHECKED box is scaffolding, not evidence. A checked one is a
        # claim the author made, so its text counts.
        if m.group(1) == " ":
            return False
        s = _CHECKBOX.sub("", s)
    else:
        s = _LIST_MARKER.sub("", s)

    s = _EMPHASIS.sub("", s).strip()
    if not s:
        return False
    if _BARE_LABEL.match(s):
        return False
    return len(s) >= 2


def section_filled(body: str, section: str) -> bool:
    body = _COMMENT.sub("", body)
    want = section.strip()
    inside = False
    for raw in body.splitlines():
        if raw.startswith("## "):
            inside = raw[3:].strip() == want
            continue
        if inside and _is_substantive(raw):
            return True
    return False


_TEMPLATE_SECTION = """## Validation evidence

<!--
Deterministic evidence, not assertion. Paste the relevant output.
-->

- [ ] `make check` passes locally

```
```

## Next
"""

_CASES = [
    # (body, section, expected)
    (_TEMPLATE_SECTION, "Validation evidence", False),      # untouched template
    ("## A\n\n<!-- hint -->\n\n## B", "A", False),           # comment only
    ("## A\n\n- Issue:\n\n## B", "A", False),                # bare label
    ("## A\n\n- **Baseline**:\n\n## B", "A", False),         # bold bare label
    ("## A\n\n- ADR (required at R4+):\n\n## B", "A", False), # label with punctuation
    ("## A\n\n- Issue: #42 and notes\n\n## B", "A", True),    # colon with a value
    ("## A\n\n```\n```\n\n## B", "A", False),                # empty fence
    ("## A\n\n- [ ] make check passes\n\n## B", "A", False), # unchecked box
    ("## A\n\n- [x] make check passes\n\n## B", "A", True),  # checked box
    ("## A\n\n- Issue: #42\n\n## B", "A", True),             # real value
    ("## A\n\nNo new components.\n\n## B", "A", True),       # prose
    ("## A\n\n<!-- hint -->\nNone.\n\n## B", "A", True),     # prose after hint
    ("## A\n\ntext\n\n## B", "Missing", False),              # absent section
    ("## Rollback / recovery\n\ngit revert\n", "Rollback / recovery", True),
]


def _self_test() -> int:
    failures = 0
    for i, (body, section, expected) in enumerate(_CASES, 1):
        got = section_filled(body, section)
        if got != expected:
            failures += 1
            print(f"  FAIL case {i}: section={section!r} expected={expected} got={got}",
                  file=sys.stderr)
    if failures:
        print(f"pr_body self-test: {failures}/{len(_CASES)} failed", file=sys.stderr)
        return 1
    print(f"  pr_body self-test: {len(_CASES)}/{len(_CASES)} cases passed")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--section")
    ap.add_argument("--self-test", action="store_true")
    args = ap.parse_args()

    if args.self_test:
        return _self_test()
    if not args.section:
        ap.error("--section is required unless --self-test is given")
    return 0 if section_filled(sys.stdin.read(), args.section) else 1


if __name__ == "__main__":
    sys.exit(main())
