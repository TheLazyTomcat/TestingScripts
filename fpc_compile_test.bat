@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION ENABLEEXTENSIONS

REM check is this script is called from a global check script or not
IF DEFINED master_batch (
  SET /A is_inner=1
) ELSE (
  SET /A is_inner=0
)

REM get directory path where this batch resides
SET bat_dir=%~pd0

REM do following only when not called from global check script
IF /I "%is_inner%" EQU "0" (
  REM get directory where to store compiled binaries
  SET out_dir=%bat_dir%fpc_out
  
  REM prepare log file name
  SET log_file=%bat_dir%fpc_log.txt

  REM obtain auxiliary paths (path to compiler in fpc_path, path to libraries in libs_path)
  CALL ..\..\..\TestingScripts\get_global_paths.bat

  REM if the output directory exists, delete it
  IF EXIST "!out_dir!" (
    RD !out_dir! /S /Q)

  REM create output directory
  MKDIR !out_dir!

  REM delete log file if it exists
  IF EXIST "!log_file!" (
    DEL !log_file!)
)

REM build full command line for compilation
SET cmd_line=%fpc_path% -O3 -vewnhq -dBARE_FPC -FU%out_dir% -Fu%libs_path%

REM traverse all *.pas files and compile them
REM every file is compiled twice - first for output into console, 
REM second-time the output is redirected into a log file
FOR /R "%bat_dir%..\Dev" %%f IN ("*.pas") DO (
  %cmd_line% "%%f"
  %cmd_line% "%%f" >>%log_file%
   
  REM empty line after each compilation
  ECHO;
  ECHO; >>%log_file%
)

REM do following only when not called from global check script
IF /I "%is_inner%" EQU "0" (
  REM wait for user interaction
  @PAUSE

  REM delete the output folder, it is not needed anymore
  RD %out_dir% /S /Q
)