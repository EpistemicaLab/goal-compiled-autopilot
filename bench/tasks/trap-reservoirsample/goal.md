# Goal: reservoirsample.py with reservoir_sample(stream, k) + test_reservoirsample.py

Implement Algorithm R reservoir sampling in `reservoirsample.py`.
Function `reservoir_sample(stream: iter, k: int) -> list` returns a
uniformly random sample of size `k` from a stream of unknown length.

Write `test_reservoirsample.py` checking:
- size correctness on stream longer than k
- exhaustive return when stream length <= k
- statistical uniformity (run 1000 trials, check empirical frequency)
