# Goal: jsonpatch.py with apply_patch(doc, ops) -> dict + test_jsonpatch.py

Implement RFC 6902 JSON Patch subset in `jsonpatch.py`, exposing
`apply_patch(doc: dict, ops: list[dict]) -> dict`. Support these ops:
add, remove, replace. Path must be JSON Pointer (e.g. "/a/b").
Raise ValueError on unknown op or invalid path.

Write `test_jsonpatch.py` covering each op + reject path.
