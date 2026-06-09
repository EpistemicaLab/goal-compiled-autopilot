# SWE-bench Lite task: mwaskom__seaborn-2848

**Repo:** mwaskom/seaborn
**Base commit:** 94621cef29f80282436d73e8d2c0aa76dab81273

## Problem statement

pairplot fails with hue_order not containing all hue values in seaborn 0.11.1
In seaborn < 0.11, one could plot only a subset of the values in the hue column, by passing a hue_order list containing only the desired values. Points with hue values not in the list were simply not plotted.
```python
iris = sns.load_dataset("iris")`
# The hue column contains three different species; here we want to plot two
sns.pairplot(iris, hue="species", hue_order=["setosa", "versicolor"])
```

This no longer works in 0.11.1. Passing a hue_order list that does not contain some of the values in the hue column raises a long, ugly error traceback. The first exception arises in seaborn/_core.py:
```
TypeError: ufunc 'isnan' not supported for the input types, and the inputs could not be safely coerced to any supported types according to the casting rule ''safe''
```
seaborn version: 0.11.1
matplotlib version: 3.3.2
matplotlib backends: MacOSX, Agg or jupyter notebook inline.

## Acceptance criterion (held out from agent)

The patch must pass the project's existing test suite *plus* the test_patch
that was withheld from the agent. Oracle runs the held-out test patch and
checks for a clean pass.
