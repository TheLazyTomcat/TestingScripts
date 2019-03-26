@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

SET "comp_str=fpc_xlin"
SET "comp_text=Crosscompilling FPC"

CALL "%~dp0utils\unit_compile_test.bat"

ENDLOCAL