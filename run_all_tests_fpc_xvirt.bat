@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM setup all-base path for further scripts
SET "path_all_base=%~dp0"

REM initialize compilation variables
SET "comp_str=fpc_xvirt"
SET "comp_text=VM crosscompilling FPC"

REM run common script
CALL "%path_base%utils\run_all_tests.bat"

ENDLOCAL