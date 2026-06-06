# pdoc Reference

Quick lookup when fixing pdoc build warnings. Docstring style rules live in [python-docstrings](../python-docstrings/SKILL.md).

## CLI

```bash
pdoc --http : my_package                              # dev server
pdoc --html --output-dir build my_package             # static HTML
pdoc --html --config show_source_code=False my_package
pdoc --html --template-dir ./templates my_package
```

## Broken cross-reference warnings

pdoc emits `UserWarning` when a backtick link cannot be resolved. Fix the target name on the **reported symbol only**:

- Same module: `` `open` ``, `` `Client` ``, `` `read_registers` ``
- Other module: must be fully qualified — `` `package.subpackage.module.member` ``

## `__pdoc__` overrides

Use only when pdoc cannot read a normal docstring (e.g. `namedtuple` fields) or when explicitly hiding a symbol from generated docs:

```python
__pdoc__: dict[str, bool | str] = {}
__pdoc__["Table.rows"] = "Lists corresponding to each row in the table."
__pdoc__["_internal_helper"] = False  # exclude from output
```

Keys: module-local (`C.variable`) or fully qualified (`pkg.mod.C.variable`).

## Public API visibility (when output is wrong)

| Rule | Effect |
|------|--------|
| Name starts with `_` | Hidden |
| Imported into module | Not listed as defined here |
| `__all__` defined | Only names in `__all__` are public |
| `__pdoc__[key] = True` | Force-include private symbol |
| `__pdoc__[key] = False` | Force-exclude symbol |

If a symbol is missing from HTML but pdoc did not warn, check visibility rules above before adding docstrings elsewhere.
