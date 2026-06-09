# Goal: ratelimiter.py with TokenBucket(rate, capacity) class + test_ratelimiter.py

Implement `TokenBucket(rate: float, capacity: int)` in `ratelimiter.py`.
Methods:
- `allow() -> bool`: returns True if a token is available, consumes one.
- `tokens() -> float`: current token count (refills at `rate` per second).

Write `test_ratelimiter.py` testing burst capacity, steady-state rate,
and refill timing (use time.sleep). Use unittest.
