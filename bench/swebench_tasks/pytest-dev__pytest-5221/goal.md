# SWE-bench Lite task: pytest-dev__pytest-5221

**Repo:** pytest-dev/pytest
**Base commit:** 4a2fdce62b73944030cff9b3e52862868ca9584d

## Problem statement

Display fixture scope with `pytest --fixtures`
It would be useful to show fixture scopes with `pytest --fixtures`; currently the only way to learn the scope of a fixture is look at the docs (when that is documented) or at the source code.


## Acceptance criterion (held out from agent)

The patch must pass the project's existing test suite *plus* the test_patch
that was withheld from the agent. Oracle runs the held-out test patch and
checks for a clean pass.
