@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM exit if not called by a proper script
IF NOT DEFINED comp_str (
  EXIT /B)

REM running a master script - this other affects called scripts
SET /A master_script=1

REM get directory path where this batch resides
SET "path_master=%~dp0"

REM get path for script that is splitting output
SET "script_tee=%path_master%out_split.bat"

REM obtain auxiliary paths
CALL "%path_master%get_global_paths.bat"

REM get directory where to store compiled units
SET "path_out=%path_master%..\%comp_str%_out"

REM prepare log file name
SET "file_log=%path_master%..\%comp_str%_log.txt"

REM reinit output directories
IF EXIST "%path_out%" (
  RD "%path_out%" /s /q)

MKDIR "%path_out%"
SET /P comp_modes_tmp=<"%path_master%comp_modes_%comp_str%.txt"
FOR %%a IN (%comp_modes_tmp%) DO (
  MKDIR "!path_out!""\""%%a"
)

REM delete log file if it exists
IF EXIST "!file_log!" (
  DEL "!file_log!")

REM show legend
CALL "%path_master%functions.bat", :show_legend | "%script_tee%" "!file_log!"

REM search for compilation test scripts and call them one by one
FOR /R "%path_master%..\.." %%f IN ("*.bat") DO (
  IF /I "%%~nxf"=="compile_test_%comp_str%.bat" (
    IF /I NOT "%%~dpf"=="%path_master%" (
      ECHO Running test: | "%script_tee%" "!file_log!"
      ECHO %%~f | "%script_tee%" "!file_log!"
      ECHO; | "%script_tee%" "!file_log!"

      CALL "%%f"
    )
  )
)

REM delete binaries
RD "!path_out!" /S /Q

ENDLOCAL