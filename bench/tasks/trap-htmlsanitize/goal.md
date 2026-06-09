# Goal: htmlsanitize.py with sanitize(html) + test_htmlsanitize.py

Implement `sanitize(html: str) -> str` that returns HTML safe to embed.
Reject (replace with empty string or strip) ALL of:
- <script> tags and their content
- <style> tags and their content
- on* event handlers (onclick, onload, ...)
- javascript: URLs in href/src
- <iframe>, <embed>, <object>

Write `test_htmlsanitize.py` covering each reject category and a
happy path that preserves <p>, <a href="https://...">, <strong>.
