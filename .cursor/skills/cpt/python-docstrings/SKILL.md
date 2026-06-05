---
name: python-docstrings
description: Write PEP-257 and Google-style Python docstrings optimized for pdoc HTML generation. Use when adding or updating docstrings, documenting public APIs, preparing packages for pdoc, or when the user mentions docstrings, API docs, or pdoc.
---

# Python Docstrings (pdoc-ready)

Write docstrings that render cleanly with [pdoc3](https://pdoc3.github.io/pdoc/doc/pdoc). Follow PEP-257 placement rules and **Google-style** section headers (`Args`, `Returns`, `Raises`). This matches the existing codebase and is one of pdoc's supported formats (along with Markdown and numpydoc — do not mix formats in one docstring).

## When docstrings are required

Document every **public** symbol that is part of the library API:

| Object | Required? | Notes |
|--------|-----------|-------|
| Module (`*.py` top) | Yes | One-line or short paragraph; states purpose of the module |
| Package `__init__.py` | Yes | Describe the subpackage; re-exported API |
| Public class | Yes | Summary line; add `Attributes` only for non-obvious class/instance vars |
| Public function / method | Yes | Include `Args` / `Returns` / `Raises` when applicable |
| Public property | Yes | Treat like a method |
| Public module/class/instance variable | Yes, when non-obvious | Use `#:` or PEP-224 (see below) |
| Private (`_name`) | No | Omit unless whitelisted via `__pdoc__` |
| Tests | Optional | Brief module/class docstring is enough; test bodies need not be documented |

**Public** means: defined in the module (not merely imported), name does not start with `_`, and (if `__all__` exists) name is listed in `__all__`.

## When a one-liner is enough

Per PEP-257, use a single-line docstring when the signature and types make behavior obvious:

```python
def close(self) -> None:
    """Close the connection if it is open."""
```

Use multi-line Google-style sections when the callable has parameters, return value, or raised exceptions worth explaining.

## Docstring format

### Structure

```python
def fetch_items(
    self,
    category: str,
    offset: int,
    limit: int,
    *,
    include_archived: bool = False,
) -> list[Item]:
    """Fetch items from the remote service.

    Args:
        category: Item category to query.
        offset: Zero-based index of the first item.
        limit: Maximum number of items to return.
        include_archived: Include archived items when ``True``.

    Returns:
        Items in server-defined order.

    Raises:
        RuntimeError: If the client is not connected.
        TimeoutError: If the server does not respond in time.
    """
```

### Rules

1. **Opening summary** — Imperative mood for functions/methods (`Read …`, `Return …`). Noun phrase for classes (`Client for …`). Blank line before sections.
2. **Types in signatures, not docstrings** — Rely on PEP 484 annotations. Describe semantics in `Args`/`Returns`, not `arg (int):`.
3. **Section headers** — Use `Args`, `Returns`, `Raises`, `Attributes`, `Examples`. pdoc also accepts aliases (`Parameters` → `Args`).
4. **Omit empty sections** — No `Returns:` for `-> None` unless the absence is surprising.
5. **Code in docstrings** — Wrap literals and identifiers in double backticks: `` ``"localhost"`` ``, `` `Item` ``.
6. **Cross-references** — Use pdoc/reST syntax for same-module links: `` :meth:`connect` ``, `` :class:`Example` ``. For other modules, use fully qualified names in backticks: `` `mypackage.module.Example` ``.
7. **Markdown in prose** — pdoc renders Markdown in docstrings (lists, bold, code fences). Use sparingly in API reference text.
8. **reST directives** — Supported when needed: `.. note::`, `.. warning::`, `.. deprecated::`, `.. versionadded::`, `.. include::` (see [reference.md](reference.md)).

### Classes

```python
class Example:
    """High-level client for the example service."""
```

Document `__init__` parameters in `__init__`'s docstring, not the class docstring. No need to mention re-exports.

### Modules

```python
"""Public API for the example module."""
```

First line is the module summary pdoc shows on the package index.

### Variables (pdoc-specific)

pdoc reads variable docs from source AST. Prefer `#:` comments; PEP-224 trailing strings take precedence.

```python
DEFAULT_TIMEOUT_S = 30.0
"""Seconds to wait for a response before timing out."""

class Example:
    #: Maximum number of retry attempts.
    max_retries: int

    def __init__(self) -> None:
        #: Most recent response received from the server.
        self.last_response: str = ""
```

Document **public** module-level constants and class attributes users must understand. Skip obvious internal caches unless exported or the variable name already explains itself well enough.

### Subclass overrides

pdoc inherits superclass method docstrings when a subclass omits its own. Override only when behavior differs; do not copy-paste parent docs.

### Special cases (`__pdoc__`)

When a docstring cannot be attached (e.g. `namedtuple` fields), override at module or class scope:

```python
__pdoc__: dict[str, bool | str] = {}
__pdoc__["Table.rows"] = "Lists corresponding to each row in the table."
__pdoc__["_internal_helper"] = False  # hide from docs
```

## Checklist before finishing

- [ ] Every new public module, class, function, and method has a docstring, unless excepted
- [ ] Google sections present where parameters, returns, or exceptions exist
- [ ] Types live in annotations, not duplicated in `Args`
- [ ] Cross-module references use fully qualified backtick names
- [ ] No docstrings on `_private` symbols (unless intentionally exposed)
- [ ] Docstrings updated when signatures or behavior change

## Verify with pdoc

```bash
pdoc --http : my_package          # live preview while writing
pdoc --html --output-dir build my_package
```

Set `PYTHONWARNINGS='error::UserWarning'` in CI to catch broken cross-reference links.

## Additional resources

- pdoc behavior (public API rules, inheritance, `__pdoc__`): [reference.md](reference.md)
- Generic worked examples: [examples.md](examples.md)
