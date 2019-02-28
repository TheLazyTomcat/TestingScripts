@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

SET "comp_str=fpc_old"
SET "comp_text=Old FPC"

CALL "%~dp0utils\unit_compile_test.bat"

ENDLOCAL