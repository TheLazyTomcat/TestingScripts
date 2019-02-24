@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

SET "comp_str=delphi"
SET "comp_text=Delphi"

CALL "%~dp0utils\run_all_tests.bat"

ENDLOCAL