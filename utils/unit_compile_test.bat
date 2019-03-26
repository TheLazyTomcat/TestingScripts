@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM exit if not called by a proper script
IF NOT DEFINED comp_str (
  EXIT /B)

REM get directory path where this batch resides
SET "path_this=%~dp0"

REM get path for script that is splitting output
SET "script_tee=%path_this%out_split.bat"

REM list of compilation modes
SET /P comp_modes=<"%path_this%comp_modes_%comp_str%.txt"
SET /A comp_mode_count=0
FOR %%a IN (!comp_modes!) DO (
  SET /A comp_mode_count+=1
)

REM do initialization only when not called from a global (run_all*) script
IF NOT DEFINED master_script (
  REM get directory where to store compiled binaries
  SET "path_out=%path_this%..\%comp_str%_out"

  REM prepare log file name
  SET "file_log=%path_this%..\%comp_str%_log.txt"

  REM obtain auxiliary paths (paths to compilers, paths to libraries, ...)
  CALL "%path_this%get_global_paths.bat"

  REM if the output directory exists, delete it
  IF EXIST "!path_out!" (
    RD "!path_out!" /S /Q)

  REM create output directories
  MKDIR "!path_out!"
  FOR %%a IN (!comp_modes!) DO (
    MKDIR "!path_out!\%%a"
  )

  REM delete log file if it exists
  IF EXIST "!file_log!" (
    DEL "!file_log!")
)

REM get list of processed pas files and their count
ECHO Enumerating files, please wait | "%script_tee%" "!file_log!"
SET /A file_list_count=0
SET file_list=
FOR /R "%path_this%..\..\Dev" %%f IN ("*.pas") DO (
  SET "file_list=!file_list!,"%%~f""
  ECHO %%~f | "%script_tee%" "!file_log!"
  SET /A file_list_count+=1
)
ECHO ...!file_list_count! file^(s^) found | "%script_tee%" "!file_log!"
ECHO; | "%script_tee%" "!file_log!"

REM show legend
IF NOT DEFINED master_script (
  CALL "%path_this%""functions.bat", :show_legend | "%script_tee%" "!file_log!"
)

REM traverse all found *.pas files and compile them
SET /A file_list_index=1
FOR %%f IN (!file_list!) DO (
  REM show what file is about to be compiled
  ECHO ^[F: !file_list_index!/!file_list_count!^] Compiling file: | "%script_tee%" "!file_log!"
  ECHO ^[F: !file_list_index!/!file_list_count!^] %%~f | "%script_tee%" "!file_log!"
  ECHO; | "%script_tee%" "!file_log!"

  SET /A comp_mode_index=1
  FOR %%a IN (!comp_modes!) DO (
    FOR /F "tokens=1-4 delims=-" %%g in ("%%a") DO (

      REM corrections for proper output
      IF /I "%%g"=="_" (SET "cmp_processor=i386 "
        ) ELSE (SET "cmp_processor=%%g ")
      IF /I "%%h"=="_" (SET "cmp_op_system=win32 "
        ) ELSE (SET "cmp_op_system=%%h ")
      IF /I "%%i"=="_" (SET "cmp_opt_level="
        ) ELSE (SET "cmp_opt_level=%%i ")
      IF /I "%%j"=="_" (SET "cmp_defines="
        ) ELSE (SET "cmp_defines=%%j ")

      REM following is due to fpc, it does not accept -d param with no actual symbol, se we declare one (null)
      IF ["%cmp_defines%"]==[] (SET "cmp_defines_cmd=null"
        ) ELSE (SET "cmp_defines_cmd=%%j")

      REM show info about compilation
      ECHO ^[F: !file_list_index!/!file_list_count!^; C: !comp_mode_index!/!comp_mode_count!^] %comp_text% - !cmp_processor!!cmp_op_system!!cmp_opt_level!!cmp_defines! | "%script_tee%" "%file_log%"

      REM compilation
      IF /I "%comp_str%"=="delphi" (
        REM delphi
        dcc32 -Q -B -U"%%~pdf.";"%path_this%..\Dev";"%path_libs%";"!path_out!\%%a" -I"%path_this%..\Dev";"%path_libs%" -N"!path_out!\%%a" -D"!cmp_defines_cmd!" "%%~f" | "%script_tee%" "%file_log%"
      )
      IF /I "%comp_str%"=="fpc_old" (
        REM old fpc
        "%path_fpc_old%" -vewnhq -dBARE_FPC -Fu"%path_libs%" -FU"!path_out!\%%a" -P"%%g" -T"%%h" -"%%i" -d"%%j" "%%~f" | "%script_tee%" "!file_log!"
      )
      IF /I "%comp_str%"=="fpc_xlin" (
        REM old fpc
        "%path_fpc_xlin%" -vewnhq -dBARE_FPC -Fu"%path_libs%" -FU"!path_out!\%%a" -P"%%g" -T"%%h" -"%%i" -d"%%j" "%%~f" | "%script_tee%" "!file_log!"
      )      
      IF /I "%comp_str%"=="fpc" (
        REM actual FPC
        "%path_fpc%" -vewnhq -dBARE_FPC -Fu"%path_libs%" -FU"!path_out!\%%a" -P"%%g" -T"%%h" -"%%i" -d"%%j" "%%~f" | "%script_tee%" "!file_log!"
      )

      ECHO; | "%script_tee%" "%file_log%"

      SET /A comp_mode_index+=1
    )
  )

  SET /A file_list_index+=1
)


REM do finalization only when not called from global script
IF NOT DEFINED master_script (
  REM wait for user interaction
  ECHO Done | "%script_tee%" "%file_log%"
  @PAUSE

  REM delete the output folder, it is not needed anymore
  RD "!path_out!" /S /Q
)

EXIT /B

ENDLOCAL