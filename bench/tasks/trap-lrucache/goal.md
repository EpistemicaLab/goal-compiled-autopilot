# Goal: lrucache.py with LRUCache(max_size) + test_lrucache.py

Implement `LRUCache(max_size: int)` in `lrucache.py` with O(1) get/put:
- `get(key)` -> value or None; touches recency.
- `put(key, value)` -> None; evicts LRU when size exceeds max_size.
- `__len__()` -> int.

Write `test_lrucache.py` covering eviction order, recency update on get,
and edge cases (max_size=1, max_size=0).
