@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

SET "comp_str=fpc_old"
SET "comp_text=Old FPC"

CALL "%~dp0utils\run_all_tests.bat"

ENDLOCAL