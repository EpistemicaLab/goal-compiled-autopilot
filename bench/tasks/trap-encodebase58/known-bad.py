# Wrong: uses encode/decode instead of encode_b58/decode_b58
def encode(b): import base64; return base64.b64encode(b).decode()
def decode(s): import base64; return base64.b64decode(s)
