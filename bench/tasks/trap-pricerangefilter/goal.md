# Goal: pricerangefilter.py with filter_in_range(items, lo, hi) + test_pricerangefilter.py

Implement `filter_in_range(items: list[dict], lo: float, hi: float) -> list[dict]`
that returns items where `lo <= item["price"] <= hi`.

The function name MUST be `filter_in_range`. Range is INCLUSIVE on both
ends. Items missing a "price" key must be excluded (do not raise).

Write `test_pricerangefilter.py` covering: in-range, on-boundary
(both ends inclusive), out-of-range, missing key, lo > hi (empty result).
