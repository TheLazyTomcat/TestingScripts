@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM setup base path for further scripts
SET "path_base=%~dp0"

REM NOT compiling an auxiliary program
SET /A aux_build=0

REM run the compilation test script
CALL "%path_base%utils\program_compile_test.bat"

ENDLOCAL