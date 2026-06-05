# claude-cursor-python-toolkit

My AI coding setup for Python development — tuned for developing hardware SDKs, protocol clients, and libraries. Works with [Cursor](https://cursor.com) and [Claude Code](https://code.claude.com).


- **`.cursor/`** — Cursor-native source of truth (`.mdc` rules, skills, agents)
- **`.claude/`** — Claude Code translation (`.md` rules with `paths`, same skills/agents)

## What's included

- **Rules** — always-on or file-scoped coding standards (style, tests, project layout, venv usage)
- **Skills** — on-demand playbooks for TDD, API documentation, and subagent scoping
- **Agents** — subagents for verification, test-running, and test-quality review

## Quick start

#### Cursor

```bash
git clone https://github.com/AnthonyZJiang/claude-cursor-python-toolkit.git
./install-cursor.sh [your_project_root]        # symlink (default)
./install-cursor.sh [your_project_root] --copy # copy files
```

#### Claude Code

```bash
git clone https://github.com/AnthonyZJiang/claude-cursor-python-toolkit.git
./install-claude.sh [your_project_root]        # symlink (default)
./install-claude.sh [your_project_root] --copy # copy files
```

## Recommended project layout

The rules assume the following package layout:

```
my-sdk/
├── .cursor/
│   └── agents/cpt/
│   └── rules/cpt/
│   └── skills/cpt/
├── .claude/
│   └── agents/cpt/
│   └── rules/cpt/
│   └── skills/cpt/
├── .venv/
├── src/
├── tests/
├── docs/
```

## Philosophy

1. **Vertical TDD** — One test, one minimal implementation, repeat. No bulk test scaffolding.
2. **Clean code discipline** — Typed, layered modules with consistent style; no speculative abstractions or drive-by refactors.
3. **Auto docstrings** — Public APIs get Google-style, pdoc-ready docstrings and annotations as part of normal development, not a separate pass.
4. **Surgical diffs** — Agents should change only what the task requires.
5. **Behavior over wiring** — Tests assert observable outcomes, especially at hardware/protocol boundaries.
6. **venv discipline** — All Python commands go through the project virtualenv.
7. **Subagent scoping** — Multi-round work without commits requires explicit per-round scope in delegation prompts; see `skills/cpt/subagent-scoping/`.

## License

MIT — see [LICENSE](LICENSE).
