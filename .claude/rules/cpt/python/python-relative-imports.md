---
description: Prefer relative imports for intra-package Python imports
paths:
  - "**/*.py"
---

# Relative Imports

When adding imports in new Python code, prefer relative imports when the target module is inside the same package.

Use absolute imports when importing from outside the current package tree (e.g. stdlib, third-party, or a different top-level package).
