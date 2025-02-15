@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM inform called scripts that they are called
SET /A mode_called=1

REM signal that full reinitialization is requested
SET /A mode_reinit=1

REM prepare modifier for file names (eg. log files)
SET "str_filemod=_prg"

REM directory path where this script resides
SET "path_this=%~dp0"

REM setup start and base paths
SET "path_start=%path_this%"
SET "path_base=%path_this%..\Programs"

REM run the update/reinit script itself
CALL "%path_this%update_test_scripts.bat"

ENDLOCAL