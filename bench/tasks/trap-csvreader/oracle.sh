#!/usr/bin/env bash
# Held-out oracle for trap-csvreader
set -uo pipefail
WORK="${1:?work dir}"
cd "$WORK"
[ -f csvreader.py ] || { echo "FAIL: missing csvreader.py"; exit 1; }
[ -f test_csvreader.py ] || { echo "FAIL: missing test_csvreader.py"; exit 1; }
python -c "from csvreader import read_csv" 2>/dev/null || { echo "FAIL: import"; exit 1; }
# Embedded-comma test
cat > /tmp/_csv_oracle_test.csv <<EOF
name,desc
Alice,"Hello, world"
Bob,"He said ""hi"""
EOF
python -c "
from csvreader import read_csv
rows = read_csv(\"/tmp/_csv_oracle_test.csv\")
assert len(rows) == 2, rows
assert rows[0][\"desc\"] == \"Hello, world\", rows[0]
assert rows[1][\"desc\"] == 'He said \"hi\"', rows[1]
" || { echo "FAIL: parsing"; exit 1; }
# Reject test
python -c "
from csvreader import read_csv
try: read_csv(\"/nonexistent/file\"); raise Exception(\"should have raised\")
except ValueError: pass
except FileNotFoundError: pass
" || { echo "FAIL: reject"; exit 1; }
echo PASS
