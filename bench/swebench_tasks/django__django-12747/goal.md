# SWE-bench Lite task: django__django-12747

**Repo:** django/django
**Base commit:** c86201b6ed4f8256b0a0520c08aa674f623d4127

## Problem statement

QuerySet.Delete - inconsistent result when zero objects deleted
Description
	
The result format of the QuerySet.Delete method is a tuple: (X, Y) 
X - is the total amount of deleted objects (including foreign key deleted objects)
Y - is a dictionary specifying counters of deleted objects for each specific model (the key is the _meta.label of the model and the value is counter of deleted objects of this model).
Example: <class 'tuple'>: (2, {'my_app.FileAccess': 1, 'my_app.File': 1})
When there are zero objects to delete in total - the result is inconsistent:
For models with foreign keys - the result will be: <class 'tuple'>: (0, {})
For "simple" models without foreign key - the result will be: <class 'tuple'>: (0, {'my_app.BlockLibrary': 0})
I would expect there will be no difference between the two cases: Either both will have the empty dictionary OR both will have dictionary with model-label keys and zero value.


## Acceptance criterion (held out from agent)

The patch must pass the project's existing test suite *plus* the test_patch
that was withheld from the agent. Oracle runs the held-out test patch and
checks for a clean pass.
