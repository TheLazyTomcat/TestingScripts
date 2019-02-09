@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION ENABLEEXTENSIONS

REM get directory path where this batch resides
SET bat_dir=%~pd0

REM obtain auxiliary paths (path to compiler in fpc_path, path to libraries in libs_path)
CALL ..\..\..\TestingScripts\get_global_paths.bat

REM prepare log file name
SET log_file=%bat_dir%log.txt

REM delete log file if it exists
IF EXIST "%log_file%" (
  DEL "%log_file%")

REM set of tried build modes for FPC
SET build_modes=Default_win_x86 Default_win_x64 Devel_win_x86 Devel_win_x64 Release_win_x86 Release_win_x64 Debug_win_x86 Debug_win_x64

REM build full command lines for compilation
SET delphi_cmd=dcc32 -Q -B
SET lazarus_cmd=-B --no-write-project --bm=
SET old_lazarus_cmd=-B --bm=

REM search for projects and compile them
FOR /R "..\Dev" %%f IN ("*.dpr","*.lpi") DO (

  REM Delphi builds
  IF /I "%%~xf"==".dpr" (
    ECHO %%f | out_split.bat "%log_file%"
    CD "%%~dpf"

    %delphi_cmd% "%%f" | out_split.bat "%log_file%"
    ECHO; | out_split.bat "%log_file%"
  )

  REM Lazarus builds
  IF /I "%%~xf"==".lpi" (
    ECHO %%f | out_split.bat "%log_file%"
    CD "%%~dpf"

    REM iterate modes
    FOR %%m in (%build_modes%) DO (
      "%old_lazb_path%" %old_lazarus_cmd%%%m "%%f" | out_split.bat "%log_file%"
      ECHO; | out_split.bat "%log_file%"
      "%lazb_path%" %lazarus_cmd%%%m "%%f" | out_split.bat "%log_file%"
      ECHO; | out_split.bat "%log_file%"
    )
  )
)