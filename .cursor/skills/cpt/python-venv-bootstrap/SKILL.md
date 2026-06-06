---
name: python-venv-bootstrap
description: >-
  Bootstrap or recreate Python virtual environments with pyenv, pymanager, or
  plain python3. Use when .venv is missing, the user asks to set up Python,
  create a venv, or install project dependencies from requirements.txt or
  pyproject.toml.
---

# Python Virtual Environment Bootstrap

Do **not** fall back to system/pyenv Python for routine commands. This skill applies only when `.venv` is missing or the user explicitly asks to create or recreate it.

## Before creating `.venv`

Stop and ask the user:

1. Which Python version to use (e.g. 3.11, 3.12)
2. Where to create the venv (workspace root vs. subproject)
3. Whether to install dependencies from `requirements.txt` / `pyproject.toml`

Only after the user confirms, create the venv using a **version manager when available**, then install deps into it.

## Interpreter resolution (after `.venv` exists)

Before running Python, pip, pytest, or any tool installed in the venv, resolve the interpreter in this order:

1. `<workspace-root>/.venv/bin/python`
2. `<current-project-dir>/.venv/bin/python` (if different from workspace root)

Use absolute paths, for example:

```bash
<workspace-root>/.venv/bin/python -m pytest
<workspace-root>/.venv/bin/pip install -r requirements.txt
```

## macOS / Linux — prefer pyenv

```bash
# Check: command -v pyenv
pyenv install -s 3.11.12          # skip if already installed
PYENV_VERSION=3.11.12 pyenv exec python -m venv .venv
.venv/bin/pip install -r requirements.txt
```

Use the version the user chose (e.g. `3.12.8`) in place of `3.11.12`.

## Windows — prefer pymanager (Python Install Manager)

```bash
# Check: pymanager --version  (or: py --version)
pymanager install 3.11
pymanager exec -3.11 -m venv .venv
.venv\Scripts\pip install -r requirements.txt
```

If `pymanager` is unavailable but the `py` launcher is, use `py -3.11 -m venv .venv` instead.

## Fallback — no version manager

```bash
python3.11 -m venv .venv
# Unix:  .venv/bin/pip install -r requirements.txt
# Win:   .venv\Scripts\pip install -r requirements.txt
```

**Resolution order for bootstrap Python:** pyenv → pymanager/`py` → plain `python3.<minor>`. Use pyenv/pymanager only to *create* `.venv`; all later commands use `.venv/bin/python` (or `.venv\Scripts\python` on Windows).

## Package installs

Install packages only into `.venv` (`.venv/bin/pip install ...`), never `pip install` against a global interpreter.
