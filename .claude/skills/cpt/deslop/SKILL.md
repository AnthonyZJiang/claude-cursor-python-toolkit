---
name: deslop
description: Remove AI-generated code slop and clean up code style
---

# Remove AI code slop

Remove AI-generated slop and clean up code style within the chosen scope.

## Scope

Use exactly one scope per run:

1. **Pre-commit (default)** — diff against `main`. Only review and edit lines changed on the current branch.
2. **Single file** — only when the user names a specific file. Review and edit that file only; ignore other changes.

If the user does not specify a file, use the pre-commit scope.

## Focus Areas

- Extra comments that are unnecessary or inconsistent with local style
- Defensive checks or try/catch blocks that are abnormal for trusted code paths
- Casts to `any` used only to bypass type issues
- Deeply nested code that should be simplified with early returns
- Other patterns inconsistent with the file and surrounding codebase

## Guardrails

- Keep behavior unchanged unless fixing a clear bug.
- Prefer minimal, focused edits over broad rewrites.
- Preserve documentation-oriented docstrings — if a docstring looks written for API docs (reST cross-links, admonitions, or structured parameter/return detail), leave it alone even when it is longer than a one-liner.
- Slop cleanup applies to comments and inline narration, not to docstrings that document public API behavior.
- Keep the final summary concise (1-3 sentences).
