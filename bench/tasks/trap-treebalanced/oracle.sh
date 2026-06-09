#!/usr/bin/env bash
set -uo pipefail
WORK="${1:?}"; cd "$WORK"
[ -f treebalanced.py ] || { echo FAIL; exit 1; }
[ -f test_treebalanced.py ] || { echo FAIL test; exit 1; }
python -c "
from treebalanced import is_balanced, Node
# Balanced
t = Node(1, Node(2), Node(3, None, Node(4)))
assert is_balanced(t) is True
# Unbalanced (left subtree has depth 3, right depth 0)
t2 = Node(1, Node(2, Node(3, Node(4))))
assert is_balanced(t2) is False
assert is_balanced(None) is True
" || { echo FAIL; exit 1; }
echo PASS
