# Docstring Examples

Generic patterns following Google-style conventions for pdoc.

## Module

```python
"""Utilities for parsing and validating user input."""
```

## Simple function

```python
def encode(data: bytes) -> str:
    """Encode binary data as a text representation.

    Args:
        data: Binary payload.

    Returns:
        Encoded text string.
    """
```

## Function with exceptions

```python
def decode(text: str) -> bytes:
    """Decode a text string into binary data.

    Args:
        text: Encoded input string.

    Returns:
        Decoded bytes.

    Raises:
        ValueError: If ``text`` is not valid input.
    """
```

## Class and constructor

```python
class Example:
    """High-level client for the example service."""

    def __init__(self, host: str, *, port: int = 8080) -> None:
        """Configure an example client (call :meth:`connect` before use).

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

## Package `__init__.py`

```python
"""Public API for the example subpackage."""
```

## Using `.. note::` for caveats

```python
def fetch_items(self, limit: int) -> list[Item]:
    """Fetch items from the remote service.

    .. note::
        Requests are batched; ``limit`` may be capped by the server.

    Args:
        limit: Maximum number of items to return.

    Returns:
        Items in server-defined order.
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

# BAD: documents private helper meant for pdoc exclusion
def _parse_header(data: bytes) -> int:
    """Parse the header bytes."""  # omit; name starts with _
```
