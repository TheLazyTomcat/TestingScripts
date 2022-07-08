@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM setup base path for further scripts
SET "path_base=%~dp0"

REM signal that full reinitialization is requested
SET /A reinit_scripts=1

REM run the update/reinit script itself
CALL "%path_base%update_test_scripts.bat"

ENDLOCAL