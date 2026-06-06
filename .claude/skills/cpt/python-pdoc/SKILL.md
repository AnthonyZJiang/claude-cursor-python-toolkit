---
name: python-pdoc
description: Build HTML API docs with pdoc and fix only what pdoc warns about. Use when the user asks to generate, preview, or verify pdoc documentation — not when writing docstrings from scratch.
---

# pdoc Build & Fix

Docstrings should already follow the [python-docstrings](../python-docstrings/SKILL.md) skill. **Do not audit the codebase for missing or weak docstrings.** Run pdoc, read warnings/errors, fix only what it reports, re-run until clean.

## Workflow

1. **Build** — Run pdoc with warnings promoted to errors (see commands below).
2. **Clean output** — Done. Do not open files or review docstrings beyond the build result.
3. **Warnings or errors** — Fix only the symbols pdoc names (file + identifier in the message). Typical fixes:
   - **Broken cross-reference** — Correct the backtick link per python-docstrings cross-ref rules (same-module name or fully qualified path).
   - **Parse / render failure** — Fix the docstring syntax on that symbol only.
   - **Docstring cannot attach** (e.g. `namedtuple` fields) — Add a `__pdoc__` override on that symbol (see [reference.md](reference.md)).
4. **Re-run** — Repeat until the build is warning-free.

Scope each fix to the reported symbol. Do not batch-refactor unrelated docstrings.

## Commands

```bash
# Live preview (development)
pdoc --http : my_package

# Static HTML (verification)
PYTHONWARNINGS='error::UserWarning' pdoc --html --output-dir build my_package
```

Use the project's venv interpreter and the actual package import path. In CI, always set `PYTHONWARNINGS='error::UserWarning'` so broken cross-reference links fail the build.

## Additional resources

- `__pdoc__` overrides and CLI options: [reference.md](reference.md)
