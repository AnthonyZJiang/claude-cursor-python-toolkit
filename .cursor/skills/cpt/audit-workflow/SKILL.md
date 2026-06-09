---
name: audit-workflow
description: Runs the full code-quality audit workflow — thermo-nuclear audit, saved snagging report, then phased remediation via audit-orchestrator. Use when the user asks for an audit workflow, code quality audit with fix plan, snagging report, orchestrated audit remediation, or says "work in <package>" / "audit <package>" for any top-level package in the monorepo.
---

# Audit Workflow

End-to-end workflow: **resolve package → audit → save report → user confirms orchestrator mode → remediate in phases**.

Works for **any top-level package** under the monorepo root.

## Step 0 — Resolve package (required)

**Package** is the audit target — a relative path from **repo root** (no trailing slash).

### How to resolve

1. **Explicit** — user says `work in <pkg>`, `audit <pkg>`, `@<pkg>/…`, or names a path: use that package.
2. **Implicit** — if open/recent files share one top-level directory under repo root, use it.
3. **Ambiguous** — multiple packages or repo root only: **ask once** which package before Step 1.
4. **Validate** — path must exist, be a directory, and look like a project (source tree, `pyproject.toml`, `setup.py`, `package.xml`, `Cargo.toml`, `package.json`, etc.). Reject bare repo root unless the user insists.

Record resolved values and use them everywhere below:

| Symbol | Meaning |
|--------|---------|
| `{repo_root}` | Cursor workspace root (monorepo root) |
| `{package}` | Target package path relative to `{repo_root}` |
| `{git_root}` | `{package}` if `{package}/.git` exists, else `{repo_root}` |
| `{cursor_root}` | `{package}/.cursor` if it exists, else `{repo_root}/.cursor` |

**Git:** run `git` from `{git_root}` (nested repos stay scoped to their package).

**Cursor assets:** read skills and agent files from `{cursor_root}` (fallback keeps one shared toolkit at repo root).

### Derived paths (never hardcode package names)

| Purpose | Path |
|---------|------|
| Audit reports | `{package}/.audit/CODE_QUALITY_AUDIT*.md` |
| Progress tracker | `{package}/.audit/AUDIT_PROGRESS.md` |
| Phase reviews | `{package}/.audit/audit-XX-phase-NN-pass-MM.md` |
| Python venv | see [Runtime discovery](#runtime-discovery) |
| Tests | see [Runtime discovery](#runtime-discovery) |
| Primary source | see [Runtime discovery](#runtime-discovery) |

### Runtime discovery

Resolve once after Step 0; pass results to subagents in Step 5.

**Python interpreter** (first match):

1. `{package}/.venv/bin/python`
2. `{repo_root}/.venv/bin/python`
3. If missing, read and follow `{cursor_root}/skills/cpt/python-venv-bootstrap/SKILL.md` for `{package}` before pytest.

**Test command** (first match):

| Signal | Default command (from `{git_root}`) |
|--------|-------------------------------------|
| `{package}/tests/` or `pytest.ini` or `[tool.pytest]` in `pyproject.toml` | `{python} -m pytest {package}/tests/` (narrow to paths from delegation when scoped) |
| `{package}/test/` | `{python} -m pytest {package}/test/` |
| `package.json` with `"test"` script | `npm test` (or `pnpm` / `yarn` per lockfile) |
| `Cargo.toml` | `cargo test` |
| No tests yet | `none` — implementer documents manual verification; audit notes the gap |

**Primary source tree** (Mode B default scope):

- Python: package module dir from `pyproject.toml` / `setup.cfg`, else `src/`, else top-level package folder.
- ROS: `{package}/` excluding `docs/`, `build/`, `install/`.
- Other: main source dirs; exclude `.venv`, `node_modules`, `dist`, `build`, generated artifacts.

**Commit scope** (milestone messages): `{package}` basename; strip a trailing `_sdk` or `-sdk` suffix if present (e.g. `vfcomms_sdk` → `vfcomms`).

### First-time package setup

If `{package}/.audit/` is missing, create it (and `.gitkeep` if the directory is new) before saving the report.

## Overview

```
Task Progress:
- [ ] Step 0 — Resolve package + runtime discovery
- [ ] Step 1 — Run thermo-nuclear audit (Mode B unless user specifies)
- [ ] Step 2 — Save audit report to {package}/.audit/
- [ ] Step 3 — Present audit summary in chat
- [ ] Step 4 — Ask user: auto-proceed? auto-commit?
- [ ] Step 5 — Launch audit-orchestrator with package + preferences + runtime
```

---

## Step 1 — Generate audit

Read and follow `{cursor_root}/skills/cpt/thermo-nuclear-code-quality-review/SKILL.md`.

**Default:** Mode B scoped to the discovered primary source tree under `{package}/` (plus tests and CLI entry points when present).

**Override when the user says:** diff-only (Mode A), a subdirectory under `{package}`, or a named subsystem.

Apply the thermo skill's core prompt, non-negotiable standards, and codebase-mode output expectations. Be ambitious about code-judo restructuring opportunities.

---

## Step 2 — Save audit report

Choose the output path under `{package}/.audit/`:

1. If `CODE_QUALITY_AUDIT.md` does **not** exist → write `{package}/.audit/CODE_QUALITY_AUDIT_01.md`
2. If `_01` already exist → increment (`_02`, `_03`, …) until an unused filename is found

**Report structure** (match existing audits in that directory):

```markdown
# Thermo-Nuclear Code Quality Audit: `<scope>/`

**Date:** <YYYY-MM-DD>
**Mode:** Full codebase audit (Mode B) | Local diff (Mode A)
**Scope:** <what was audited>
**Package:** `{package}`

---

## Audit scope
<deep-read vs sampled; size notes>

## Top issues
### 1. <title>
**Location:** ...
**Smell:** ...
**Code-judo fix:** ...
**Leverage:** High | Medium

(repeat for each issue)

## What is working well
(brief — honest positives)

## Suggested order of attack
| Phase | Action | Expected outcome |
|-------|--------|------------------|
| **1** | ... | ... |

## Verdict
```text
Audit scope: ...
Top issues: ...
Suggested order of attack: ...
```
```

Write the full report to disk. Do not skip saving because a prior audit exists — use the incremented filename.

---

## Step 3 — Present audit as context

In chat, give a **concise summary** (not the full file):

- **Package** and audit scope (one paragraph)
- Top 3–5 issues with leverage ratings
- Phased attack plan (table or numbered list)
- Path to the saved report file

Point the user to the file for full detail. Do not paste the entire audit into chat.

---

## Step 4 — Ask orchestrator preferences (required gate)

**Stop here.** Do not launch the orchestrator until the user answers.

Use `AskQuestion` when available; otherwise ask conversationally:

1. **Auto-proceed** — After a phase passes thermo review, should the orchestrator automatically start the **next** phase without waiting for confirmation?
   - Default if unspecified: **no** (orchestrator waits between phases)

2. **Auto-commit** — After thermo `Ready to commit: yes`, should the orchestrator **create milestone commits** without asking?
   - Default if unspecified: **no** (recommend commit message only)

Record both answers verbatim for Step 5.

---

## Step 5 — Launch audit-orchestrator

Spawn the orchestrator with the Task tool:

- `subagent_type`: `audit-orchestrator`
- Instruct it to read and follow `{cursor_root}/agents/cpt/audit-workflow/audit-orchestrator.md`

**Delegation must include:**

```
Read and follow {cursor_root}/agents/cpt/audit-workflow/audit-orchestrator.md.

## Package
<relative path, e.g. ros_vfcomms>

## Repo layout
- Repo root: <repo_root>
- Git root: <git_root>
- Cursor root: <cursor_root>

## Runtime (from Step 0 discovery)
- Python: <path or n/a>
- Test command: <default pytest/npm/cargo/none>
- Primary source: <paths>
- Commit scope: <scope from basename rule>

## Audit report
- Path: <package>/.audit/<saved-filename>.md
- Progress file: <package>/.audit/AUDIT_PROGRESS.md

## User preferences
- Auto-proceed to next phase: <yes | no>
- Auto-commit milestone commits: <yes | no>

## Task
Start (or resume) the phased remediation workflow for the package above.
If AUDIT_PROGRESS.md is missing or refers to a superseded audit, initialize or reset it from the new audit's "Suggested order of attack" before beginning Phase 1.
Pass Package and runtime discovery to every subagent spawn. Honor user preferences: when auto-proceed is yes, continue to the next pending phase after each successful phase; when auto-commit is yes, commit after thermo approval using the orchestrator's commit message pattern.
When auto-proceed or auto-commit is no, follow the orchestrator's default wait-for-user behavior.
```

Return the orchestrator's phase status and next action to the user. Keep chat summaries short; reference `{package}/.audit/audit-XX-phase-NN-pass-MM.md` for long review output.

---

## Constraints

- Run Step 1 yourself (do not delegate the initial audit to a subagent).
- Never skip Step 4 — always ask about auto-proceed and auto-commit before spawning the orchestrator.
- Use discovered `{python}` for any pytest the parent agent runs; run git from `{git_root}`.
- One audit file per workflow run; do not overwrite an existing `CODE_QUALITY_AUDIT.md` — use incremented names.
- Do not commit during Steps 1–4 unless the user explicitly asks outside this workflow.
- Artifacts always live under `{package}/.audit/`, never at repo root.

## Related files

| Role | Path |
|------|------|
| Audit skill | `{cursor_root}/skills/cpt/thermo-nuclear-code-quality-review/SKILL.md` |
| Orchestrator | `{cursor_root}/agents/cpt/audit-workflow/audit-orchestrator.md` |
| Implementer | `{cursor_root}/agents/cpt/audit-workflow/audit-implementer.md` |
| Diff reviewer | `{cursor_root}/agents/cpt/audit-workflow/thermo-diff-reviewer.md` |

## Examples

| User says | `{package}` |
|-----------|-------------|
| "audit my_package" | `my_package` |
| "work in my_package" | `my_package` |
| "@my_package/ run audit workflow" | `my_package` |
| (files open only under `my_package/`) | `my_package` |
