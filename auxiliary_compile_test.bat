@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM inform called scripts that they are called
SET /A mode_called=1

REM directory path where this script resides
SET "path_this=%~dp0"

REM setup start and base paths
SET "path_start=%path_this%"
SET "path_base=%path_this%"   

REM compiling an auxiliary program
SET /A mode_aux_build=1

REM run the compilation test script
CALL "%path_this%utils\program_compile_test.bat"

ENDLOCAL