# Docstring Examples

Specialized patterns and anti-patterns. Core structure and rules are in [SKILL.md](SKILL.md).

## Class and constructor

```python
class Example:
    """High-level client for the example service."""

    def __init__(self, host: str, *, port: int = 8080) -> None:
        """Configure an example client (call ``connect`` before use).

        Args:
            host: Server hostname or IP address.
            port: TCP port number.
        """
```

## Context manager methods

```python
def __enter__(self) -> Example:
    """Connect and return this client for a ``with`` block."""

def __exit__(self, *args: object) -> None:
    """Disconnect when leaving a ``with`` block."""
```

## Dataclass / typed container

```python
@dataclass(frozen=True)
class Record:
    """Immutable snapshot of a single data record."""

    name: str
    value: int
```

Add `Attributes` only when field meaning is not clear from the name and type.

## Caveat in prose

```python
def fetch_items(self, limit: int) -> list[Item]:
    """Fetch items from the remote service.

    Requests are batched; ``limit`` may be capped by the server.

    Args:
        limit: Maximum number of items to return.

    Returns:
        Items in server-defined order.
    """
```

## reST directives

Use for caveats and versioning in pdoc HTML output:

```python
def connect(self) -> None:
    """Open a connection to the remote service.

    .. note::
        Call :meth:`disconnect` when finished.

    .. warning::
        Not thread-safe; use one client per thread.

    .. deprecated:: 2.0
        Use :meth:`connect_async` instead.

    .. versionadded:: 1.4
    """
```

## Anti-patterns

```python
# BAD: duplicates type annotations
def process(x: int) -> str:
    """Do something.

    Args:
        x (int): The x value.  # redundant — type is in signature
    """

# BAD: missing blank line before sections
def run() -> None:
    """Summary.
    Args:
        ...

# BAD: documents private helper
def _parse_header(data: bytes) -> int:
    """Parse the header bytes."""  # omit; name starts with _
```
