@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM inform called scripts that they are called
SET /A script_called=1

REM prepare prefix for file names (eg. log files)
SET "str_modifier=_prg"

REM setup start and bases
SET "path_start=%~dp0"
SET "path_base=%~dp0..\Programs"

REM directory path where this script resides
SET "path_this=%~dp0"

REM run the update/reinit script itself
CALL "%path_this%update_test_scripts.bat"

ENDLOCAL