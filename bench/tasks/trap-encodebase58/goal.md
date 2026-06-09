# Goal: base58.py with encode_b58(data) + decode_b58(s) + test_base58.py

Implement Base58 encoding (Bitcoin alphabet, NO checksum) in `base58.py`.
Function names MUST be EXACTLY:
- `encode_b58(data: bytes) -> str`
- `decode_b58(s: str) -> bytes`

The Bitcoin alphabet is:
123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz
(no 0, O, I, l)

Write `test_base58.py` covering round-trip on b"hello" and b"\\x00\\x00\\x01".
