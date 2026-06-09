# SWE-bench Lite task: psf__requests-2674

**Repo:** psf/requests
**Base commit:** 0be38a0c37c59c4b66ce908731da15b401655113

## Problem statement

urllib3 exceptions passing through requests API
I don't know if it's a design goal of requests to hide urllib3's exceptions and wrap them around requests.exceptions types.

(If it's not IMHO it should be, but that's another discussion)

If it is, I have at least two of them passing through that I have to catch in addition to requests' exceptions. They are requests.packages.urllib3.exceptions.DecodeError and requests.packages.urllib3.exceptions.TimeoutError (this one I get when a proxy timeouts)

Thanks!



## Acceptance criterion (held out from agent)

The patch must pass the project's existing test suite *plus* the test_patch
that was withheld from the agent. Oracle runs the held-out test patch and
checks for a clean pass.
