---
description: Enforces logging discipline — use structlog or logging instead of print() in production code.
paths:
  - "**/*.py"
---

# Never print()

- Use structlog or logging for logging for production code — never print()
- print() is only allowed for test code
