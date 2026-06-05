---
name: subagent-scoping
description: >-
  Scope and invoke test-runner, test-robustness-reviewer, and verifier across
  multi-round uncommitted work. Use when spawning subagents, after a TDD slice,
  when tests change, or when the user iterates without committing between rounds.
---

# Subagent scoping across rounds

Subagents do not inherit chat history. Without per-round commits, `git diff`
shows all uncommitted work since the last commit — not "round 2 vs round 3".

The parent agent must pass explicit scope on every subagent invocation.

## Round log (parent maintains mentally or in the delegation prompt)

After each round of work, note:

- **Round N changed files** — production + tests
- **Round N new/changed tests** — `file::test_name`
- **Already reviewed** — files/tests cleared in prior subagent runs
- **Shared layers touched?** — e.g. `conftest.py`, `encoding.py`, `vfbus/`

## When to invoke subagents

| Event | Action |
|-------|--------|
| Single TDD slice (1 test + impl) | Parent runs targeted `pytest` inline — no subagent |
| Batch of new device/client tests | `test-robustness-reviewer` with narrow scope |
| `conftest` or shared transport changed | `test-robustness-reviewer` + broader `test-runner` |
| Failure diagnosis stuck | `test-runner` |
| User says "done" / milestone | Full `test-runner` → `test-robustness-reviewer` (full new area) → `verifier` |

Do not invoke both reviewers after every slice.

## Subagent prompt template (required)

When spawning a subagent, always include:

```
## Scope (this round only)
- Round: N
- Changed production files: [paths]
- Changed test files: [paths]
- Tests to focus on: [file::test_name, ...]
- Already reviewed (skip): [paths or tests from prior rounds]
- Shared code touched: yes/no — if yes, run [broader pytest path]

## Task
[specific instruction]
```

If scope is omitted, subagents must ask for it or use only the paths listed under
"Changed …" — not full `git diff`.

## Pytest scope guide

| Change | Run |
|--------|-----|
| One new test | That test |
| One test file | That file |
| New device package | `tests/devices/<device>/` |
| Shared layer | Full suite |

## Milestone commits (optional)

Commits are not required every round. Without them, cumulative `git diff` grows.
Suggest a milestone commit when a vertical slice is complete (e.g. register map done).

## Parent obligations

1. Never spawn a subagent with only "review the tests" — always pass the template above.
2. After subagent returns, add reviewed paths/tests to "Already reviewed" for the next round.
3. Re-invoke `test-robustness-reviewer` only for new/changed tests, not the whole device tree.
