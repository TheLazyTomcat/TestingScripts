@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM setup base path for further scripts
SET "path_base=%~dp0"

REM initialize compilation variables
SET "comp_str=delphi"
SET "comp_text=Delphi"

REM run the compilation test script
CALL "%path_base%utils\unit_compile_test.bat"

ENDLOCAL