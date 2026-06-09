# Goal: circularbuffer.py with CircularBuffer(n) + test_circularbuffer.py REQUIRED

Implement `CircularBuffer(capacity: int)` in `circularbuffer.py`:
- `push(item)`: append; oldest item is evicted when full.
- `pop()`: remove and return oldest item; raise IndexError if empty.
- `__len__()`: current size.
- `__iter__()`: iterate from oldest to newest.

You MUST also write `test_circularbuffer.py` covering: push past capacity,
pop empty, iteration order. Run via `python -m unittest test_circularbuffer.py`.
