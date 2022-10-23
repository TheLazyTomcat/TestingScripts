@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM exit if the compilation variables are not prepared
IF NOT DEFINED comp_str (
  EXIT /B)

REM get directory path where this batch resides
SET "path_this=%~dp0"

REM do initialization only when not called from a master (eg. run_all*) script
IF NOT DEFINED path_master (
  REM obtain global paths (paths to compilers, paths to libraries, ...)
  CALL "%path_this%get_global_paths.bat"  

  REM get path for script that is splitting output
  SET "script_tee=%path_this%out_split.bat"

  REM load list of compilation modes
  SET /P comp_modes=<"%path_this%comp_modes_%comp_str%.txt"
  SET /A comp_mode_count=0
  FOR %%a IN (!comp_modes!) DO (
    SET /A comp_mode_count+=1
  )
  
  REM get directory where to store compiled binaries
  SET "path_out=%path_base%%comp_str%_out" 
 
  REM if the output directory exists, delete it
  IF EXIST "!path_out!" (
    RD "!path_out!" /S /Q)

  REM create output directories
  MKDIR "!path_out!"
  FOR %%a IN (!comp_modes!) DO (
    MKDIR "!path_out!\%%a"
  )
  
  REM get log file name
  SET "file_log=%path_base%%comp_str%_log.txt"

  REM delete log file if it exists
  IF EXIST "!file_log!" (
    DEL "!file_log!")
)

REM get list of processed *.pas files and their count
ECHO Enumerating files, please wait... | "%script_tee%" "%file_log%"
ECHO; | "%script_tee%" "%file_log%"
SET file_list=
SET /A file_list_count=0
FOR /R "%path_base%..\Dev" %%f IN ("*.pas") DO (
  SET "file_list=!file_list!,"%%~f""
  SET /A file_list_count+=1  
  ECHO %%~f | "%script_tee%" "%file_log%"
)
ECHO; | "%script_tee%" "%file_log%"
ECHO ...%file_list_count% file^(s^) found | "%script_tee%" "%file_log%"
ECHO; | "%script_tee%" "%file_log%"

REM show legend
IF NOT DEFINED path_master (
  CALL "%path_this%functions.bat", :show_legend | "%script_tee%" "%file_log%"
)

REM traverse all found *.pas files and compile them
SET /A file_list_index=1
FOR %%f IN (%file_list%) DO (

  REM show what file is about to be compiled
  ECHO ^[F: !file_list_index!/%file_list_count%^] Compiling file: | "%script_tee%" "%file_log%"
  ECHO ^[F: !file_list_index!/%file_list_count%^] %%~f | "%script_tee%" "%file_log%"
  ECHO; | "%script_tee%" "%file_log%"

  SET /A comp_mode_index=1
  FOR %%a IN (%comp_modes%) DO (
    FOR /F "tokens=1-4 delims=-" %%g in ("%%a") DO (

      REM corrections for proper output (default values)
      IF /I "%%g"=="_" (SET "comp_cpu=i386 "
        ) ELSE (SET "comp_cpu=%%g ")
      IF /I "%%h"=="_" (SET "comp_system=win32 "
        ) ELSE (SET "comp_system=%%h ")
      IF /I "%%i"=="_" (SET "comp_olevel="
        ) ELSE (SET "comp_olevel=%%i ")
      IF /I "%%j"=="_" (SET "comp_define="
        ) ELSE (SET "comp_define=%%j")

      REM some rectifications
      IF "!comp_define!"=="" (
        SET "comp_define_cmd="
      ) ELSE (
        SET "comp_define_cmd=-d!comp_define!"
      )
      
      IF "!comp_olevel!"=="" (
        SET "comp_olevel_cmd="
      ) ELSE (
        SET "comp_olevel_cmd=-!comp_olevel!"
      )      

      REM show info about compilation
      ECHO ^[F: !file_list_index!/%file_list_count%^; C: !comp_mode_index!/%comp_mode_count%^] %comp_text% - !comp_cpu!!comp_system!!comp_olevel!!comp_define! | "%script_tee%" "%file_log%"
      
      REM compilation
      IF /I "%comp_str%"=="delphi" (
        REM delphi
        dcc32 -Q -B -dCOMPTEST -U"%path_base%..\Dev";"%path_libs%";"%path_out%\%%a" -I"%path_base%..\Dev";"%path_libs%" -N"%path_out%\%%a" !comp_define_cmd! "%%~f" | "%script_tee%" "%file_log%"
      )
      IF /I "%comp_str%"=="fpc" (
        REM actual FPC
        "%path_fpc%" -vewnhq -dCOMPTEST -dBARE_FPC -Fu"%path_libs%" -FU"%path_out%\%%a" -P%%g -T%%h !comp_olevel_cmd! !comp_define_cmd! "%%~f" | "%script_tee%" "%file_log%"
      )      
      IF /I "%comp_str%"=="fpc_old" (
        REM old fpc
        "%path_fpc_old%" -vewnhq -dCOMPTEST -dBARE_FPC -Fu"%path_libs%" -FU"%path_out%\%%a" -P%%g -T%%h !comp_olevel_cmd! !comp_define_cmd! "%%~f" | "%script_tee%" "%file_log%"
      )
      IF /I "%comp_str%"=="fpc_xlin" (
        REM cross-compiling fpc
        "%path_fpc_xlin%" -vewnhq -dCOMPTEST -dBARE_FPC -Fu"%path_libs%" -FU"%path_out%\%%a" -P%%g -T%%h !comp_olevel_cmd! !comp_define_cmd! "%%~f" | "%script_tee%" "%file_log%"
      ) 

      ECHO; | "%script_tee%" "%file_log%"

      SET /A comp_mode_index+=1
    )
  )

  SET /A file_list_index+=1
)


REM do finalization only when not called from global script
IF NOT DEFINED path_master (
  REM wait for user interaction
  ECHO Done | "%script_tee%" "%file_log%"
  @PAUSE

  REM delete the output folder, it is not needed anymore    
  RD "%path_out%" /S /Q
)

ENDLOCAL