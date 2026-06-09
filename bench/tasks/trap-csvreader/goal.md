# Goal: csvreader.py with read_csv(path) -> list[dict] + test_csvreader.py

Write `csvreader.py` exposing `read_csv(path: str) -> list[dict]` that reads
a CSV file with a header row and returns rows as dicts keyed by header.
Must handle: quoted fields, embedded commas inside quotes, escaped quotes
("Hello, ""world"""). Reject (raise ValueError) if file does not exist
or is not UTF-8.

Write `test_csvreader.py` with unittest covering the 3 happy paths and
the 2 reject paths. Run via `python -m unittest test_csvreader.py`.
