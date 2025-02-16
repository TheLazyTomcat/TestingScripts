@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM inform called scripts that they are called
SET /A mode_called=1

REM directory path where this script resides
SET "path_this=%~dp0"

REM setup start and base paths
SET "path_start=%path_this%"
SET "path_base=%path_this%.."

REM initialize string variables
SET "str_compiler=fpc_old"
SET "str_compilername=Old FPC"

REM run common script
CALL "%path_this%utils\run_all_tests.bat"

ENDLOCAL