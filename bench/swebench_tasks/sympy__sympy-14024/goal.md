# SWE-bench Lite task: sympy__sympy-14024

**Repo:** sympy/sympy
**Base commit:** b17abcb09cbcee80a90f6750e0f9b53f0247656c

## Problem statement

Inconsistency when simplifying (-a)**x * a**(-x), a a positive integer
Compare:

```
>>> a = Symbol('a', integer=True, positive=True)
>>> e = (-a)**x * a**(-x)
>>> f = simplify(e)
>>> print(e)
a**(-x)*(-a)**x
>>> print(f)
(-1)**x
>>> t = -S(10)/3
>>> n1 = e.subs(x,t)
>>> n2 = f.subs(x,t)
>>> print(N(n1))
-0.5 + 0.866025403784439*I
>>> print(N(n2))
-0.5 + 0.866025403784439*I
```

vs

```
>>> a = S(2)
>>> e = (-a)**x * a**(-x)
>>> f = simplify(e)
>>> print(e)
(-2)**x*2**(-x)
>>> print(f)
(-1)**x
>>> t = -S(10)/3
>>> n1 = e.subs(x,t)
>>> n2 = f.subs(x,t)
>>> print(N(n1))
0.5 - 0.866025403784439*I
>>> print(N(n2))
-0.5 + 0.866025403784439*I
```


## Acceptance criterion (held out from agent)

The patch must pass the project's existing test suite *plus* the test_patch
that was withheld from the agent. Oracle runs the held-out test patch and
checks for a clean pass.
