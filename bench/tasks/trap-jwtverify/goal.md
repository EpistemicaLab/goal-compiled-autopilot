# Goal: jwtverify.py with verify_jwt(token, secret) + test_jwtverify.py

Implement `verify_jwt(token: str, secret: bytes) -> dict` that verifies
an HS256 JWT and returns the decoded payload. Reject with ValueError if:
- signature does not match
- token is malformed (not 3 dot-separated parts)
- alg header is "none"
- exp claim is in the past
- iat claim is in the future (future-dated)

Write `test_jwtverify.py` covering each reject condition + happy path.
You may use `hmac` and `hashlib` from stdlib; do not use external libs.
