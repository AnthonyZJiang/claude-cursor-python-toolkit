---
description: Specifies comprehensive testing practices using pytest within the 'tests' directory to ensure code reliability and quality.
paths:
  - "/tests/**/*.py"
---
- pytest + factory_boy + pytest-asyncio, do NOT use the unittest module
- asyncio_mode = "auto"
- Coverage minimum: 80% (`--cov-fail-under=80`)
- Test files mirror source: `app/services/x.py` → `tests/unit/services/test_x.py`
- Use factory_boy for test data — never hardcode inline
- Descriptive names: `test_create_user_with_duplicate_email_raises_conflict`
- Each test: one behavior, independent, no shared mutable state
- Happy path + edge cases + error paths
- Fully annotate all tests with docstrings and type hints
- Use "mock" instead of "fake" for mocking classes
