# Goal: pathnormalize.py with normalize_path(base, user_input) + test_pathnormalize.py

Implement `normalize_path(base: str, user_input: str) -> str` that
returns the absolute path inside `base` for the given user-supplied
relative path. Reject with ValueError if any of:
- user_input contains ".." segments
- user_input is an absolute path
- user_input contains a NUL byte
- the resolved path escapes `base` (symlink check via realpath)
- user_input is empty or whitespace-only

Write `test_pathnormalize.py` covering all 5 reject conditions and
the happy path.
