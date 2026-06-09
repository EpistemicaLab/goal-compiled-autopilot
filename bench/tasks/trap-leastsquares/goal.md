# Goal: leastsquares.py with fit(xs, ys) + test_leastsquares.py REQUIRED

Implement ordinary least-squares linear fit in `leastsquares.py`:
`fit(xs: list[float], ys: list[float]) -> tuple[float, float]` returns
`(slope, intercept)`. Use stdlib only.

You MUST also write `test_leastsquares.py` containing at minimum 2
unittest.TestCase methods covering: a perfect line (y = 2x + 1) and a
noisy line. Run with `python -m unittest test_leastsquares.py`.
