#!/usr/bin/env bash
set -uo pipefail
WORK="${1:?}"; cd "$WORK"
[ -f jwtverify.py ] || { echo FAIL; exit 1; }
[ -f test_jwtverify.py ] || { echo FAIL test; exit 1; }
python -c "
from jwtverify import verify_jwt
import json, hmac, hashlib, base64, time
def b64(s): return base64.urlsafe_b64encode(s).rstrip(b\"=\").decode()
secret = b\"sup3rs3cr3t\"
hdr = b64(json.dumps({\"alg\":\"HS256\",\"typ\":\"JWT\"}).encode())
exp = int(time.time()) + 3600
payload_ok = b64(json.dumps({\"sub\":\"a\",\"exp\":exp}).encode())
sig = base64.urlsafe_b64encode(hmac.new(secret, f\"{hdr}.{payload_ok}\".encode(), hashlib.sha256).digest()).rstrip(b\"=\").decode()
token_ok = f\"{hdr}.{payload_ok}.{sig}\"
out = verify_jwt(token_ok, secret)
assert out[\"sub\"] == \"a\"
# Reject malformed
for bad in [\"foo\", \"a.b\", token_ok + \"x\"]:
    try: verify_jwt(bad, secret); raise AssertionError(f\"should reject {bad!r}\")
    except ValueError: pass
# Reject alg none
hdr_none = b64(json.dumps({\"alg\":\"none\",\"typ\":\"JWT\"}).encode())
token_none = f\"{hdr_none}.{payload_ok}.x\"
try: verify_jwt(token_none, secret); raise AssertionError(\"should reject alg=none\")
except ValueError: pass
" || { echo FAIL; exit 1; }
echo PASS
