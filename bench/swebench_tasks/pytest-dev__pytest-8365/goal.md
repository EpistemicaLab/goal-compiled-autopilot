# SWE-bench Lite task: pytest-dev__pytest-8365

**Repo:** pytest-dev/pytest
**Base commit:** 4964b468c83c06971eb743fbc57cc404f760c573

## Problem statement

tmpdir creation fails when the username contains illegal characters for directory names
`tmpdir`, `tmpdir_factory` and `tmp_path_factory` rely on `getpass.getuser()` for determining the `basetemp` directory. I found that the user name returned by `getpass.getuser()` may return characters that are not allowed for directory names. This may lead to errors while creating the temporary directory.

The situation in which I reproduced this issue was while being logged in through an ssh connection into my Windows 10 x64 Enterprise version (1909) using an OpenSSH_for_Windows_7.7p1 server. In this configuration the command `python -c "import getpass; print(getpass.getuser())"` returns my domain username e.g. `contoso\john_doe` instead of `john_doe` as when logged in regularly using a local session.

When trying to create a temp directory in pytest through e.g. `tmpdir_factory.mktemp('foobar')` this fails with the following error message:
```
self = WindowsPath('C:/Users/john_doe/AppData/Local/Temp/pytest-of-contoso/john_doe')
mode = 511, parents = False, exist_ok = True

    def mkdir(self, mode=0o777, parents=False, exist_ok=False):
        """
        Create a new directory at this given path.
        """
        if self._closed:
            self._raise_closed()
        try:
>           self._accessor.mkdir(self, mode)
E           FileNotFoundError: [WinError 3] The system cannot find the path specified: 'C:\\Users\\john_doe\\AppData\\Local\\Temp\\pytest-of-contoso\\john_doe'

C:\Python38\lib\pathlib.py:1266: FileNotFoundError
```

I could also reproduce this without the complicated ssh/windows setup with pytest 6.2.2 using the following commands from a `cmd`:
```bat
echo def test_tmpdir(tmpdir):>test_tmp.py
echo   pass>>test_tmp.py
set LOGNAME=contoso\john_doe
py.test test_tmp.py
```

Thanks for having a look at this!


## Acceptance criterion (held out from agent)

The patch must pass the project's existing test suite *plus* the test_patch
that was withheld from the agent. Oracle runs the held-out test patch and
checks for a clean pass.
