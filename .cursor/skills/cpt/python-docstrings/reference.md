# pdoc Reference

Condensed from [pdoc API documentation](https://pdoc3.github.io/pdoc/doc/pdoc).

## What pdoc documents

pdoc extracts docs for:

- modules and submodules
- functions, methods, properties, coroutines
- classes
- variables (module globals, class variables, instance variables on `self` in `__init__`)

Source: live objects' `__doc__` attribute; variables additionally from AST (`#:` comments and PEP-224 strings).

## Public API visibility

| Rule | Effect |
|------|--------|
| Name starts with `_` | Hidden by default |
| Defined via import in this module | Not documented as belonging here |
| `__all__` defined | Only names in `__all__` are public |
| `__pdoc__[key] = True` | Force-include private symbol |
| `__pdoc__[key] = False` | Force-exclude symbol |
| `__pdoc__[key] = "text"` | Override docstring |

Keys are module-local identifiers (`C.variable`) or fully-qualified refnames (`pkg.mod.C.variable`).

## Supported docstring formats

pdoc auto-detects and converts:

1. **Google-style** (project default) — `Args`, `Returns`, `Raises`, `Attributes`, `Examples`
2. **numpydoc** — `Parameters`, `Returns`, `Raises`, etc.
3. **Markdown** — pure Markdown with extensions
4. **reST directives** — subset listed below

Pick one style per project; do not combine Google and numpydoc headers in the same docstring.

### Google section aliases (pdoc)

| Alias | Normalized to |
|-------|---------------|
| `Parameters`, `Params`, `Arguments` | `Args` |
| `Raise` | `Raises` |
| `Keyword Arguments` | `Keyword Args` |

### Supported reST directives

- Admonitions: `attention`, `caution`, `danger`, `error`, `hint`, `important`, `note`, `tip`, `warning`, `admonition`
- `.. image::`, `.. figure::` (no options)
- `.. include::` with `:start-line:`, `:end-line:`, `:start-after:`, `:end-before:`
- `.. math::`
- `.. versionadded::`, `.. versionchanged::`, `.. deprecated::`, `.. todo::`

## Cross-linking

Surround identifiers with backticks for automatic HTML links:

- Same module: `` `read_registers` ``, `` :meth:`open` ``
- Other module: `` `package.subpackage.module.member` `` (must be fully qualified)

## Docstring inheritance

If subclass method has no docstring, pdoc shows the superclass method's docstring (greyed in default HTML template). Write an override only when behavior changes.

## Variable documentation mechanisms

```python
# PEP-224 (trailing string after assignment)
TIMEOUT_S = 1.3
"""Default read timeout in seconds."""

# #: doc-comments (parsed from AST)
class C:
    #: Public class constant.
    MAX_RETRIES = 3

    def __init__(self):
        #: Per-instance state visible to API consumers.
        self.state = 0
        """PEP-224 wins over #: if both are present."""
```

Instance variables are those assigned to `self` inside `__init__`.

## CLI quick reference

```bash
# Development server
pdoc --http : my_package

# Static HTML
pdoc --html --output-dir build my_package

# Hide source in output
pdoc --html --config show_source_code=False my_package

# Custom template directory
pdoc --html --template-dir ./templates my_package
```

## PEP-257 recap

- Docstring is first statement in module/class/function/method body.
- One-line: `"""Summary."""` — fits on one line, closing quotes on same line.
- Multi-line: summary line, blank line, body/sections, closing `"""` on its own line.
- Class docstring: summary of the class; `__init__` documented separately.
