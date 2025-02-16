@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM exit if this script is not properly called
IF NOT DEFINED mode_called (
  EXIT /B)

REM get directory path where this batch resides
SET "path_this=%~dp0"

REM do initialization only when NOT called from a master (eg. run_all*) script
IF NOT DEFINED mode_mastercall (
  REM obtain global paths (paths to compilers, paths to libraries, ...)
  CALL "%path_this%\get_global_paths.bat"  

  REM get path for script that is splitting output
  SET "script_tee=%path_this%\out_split.bat"

  REM load list of compilation modes
  SET /P list_compilation_modes=<"%path_this%\comp_modes_%str_compiler%.txt"
  SET /A count_compilation_modes=0
  FOR %%a IN (!list_compilation_modes!) DO (
    SET /A count_compilation_modes+=1)
  
  REM get directory where to store compiled binaries
  SET "path_out=%path_start%\%str_compiler%_out" 
 
  REM if the output directory exists, delete it
  IF EXIST "!path_out!" (
    RD "!path_out!" /S /Q)

  REM create output directories
  MKDIR "!path_out!"
  FOR %%a IN (!list_compilation_modes!) DO (
    MKDIR "!path_out!\%%a")
  
  REM get log file name
  SET "file_log=%path_start%\%str_compiler%_log.txt"

  REM delete log file if it exists
  IF EXIST "!file_log!" (
    DEL "!file_log!")
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

REM get list of processed *.pas files and their count
ECHO Enumerating files, please wait... | "%script_tee%" "%file_log%"
ECHO; | "%script_tee%" "%file_log%"
SET list_found_files=
SET /A count_found_files=0
FOR /R %path_base% %%f IN ("*.pas") DO (
  SET "list_found_files=!list_found_files!,"%%~f""
  SET /A count_found_files+=1  
  ECHO %%~f | "%script_tee%" "%file_log%"
)
ECHO; | "%script_tee%" "%file_log%"
ECHO ...%count_found_files% file^(s^) found | "%script_tee%" "%file_log%"
ECHO; | "%script_tee%" "%file_log%"

REM show legend
IF NOT DEFINED mode_mastercall (
  CALL "%path_this%\functions.bat", :show_legend | "%script_tee%" "%file_log%"
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

REM traverse all found *.pas files and compile them
SET /A index_found_files=1
FOR %%f IN (%list_found_files%) DO (

  REM show what file is about to be compiled
  ECHO ^[F: !index_found_files!/%count_found_files%^] Compiling file: | "%script_tee%" "%file_log%"
  ECHO ^[F: !index_found_files!/%count_found_files%^] %%~f | "%script_tee%" "%file_log%"
  ECHO; | "%script_tee%" "%file_log%"

  SET /A index_compilation_modes=1
  FOR %%a IN (%list_compilation_modes%) DO (
    FOR /F "tokens=1-4 delims=-" %%g in ("%%a") DO (

      REM corrections for proper output (default values)
      IF /I "%%g"=="_" (SET "var_cpu=i386 "
        ) ELSE (SET "var_cpu=%%g ")
      IF /I "%%h"=="_" (SET "var_system=win32 "
        ) ELSE (SET "var_system=%%h ")
      IF /I "%%i"=="_" (SET "var_olevel="
        ) ELSE (SET "var_olevel=%%i ")
      IF /I "%%j"=="_" (SET "var_define="
        ) ELSE (SET "var_define=%%j")

      REM some rectifications
      IF "!var_define!"=="" (
        SET "var_define_cmd="
      ) ELSE (
        SET "var_define_cmd=-d!var_define!"
      )
      
      IF "!var_olevel!"=="" (
        SET "var_olevel_cmd="
      ) ELSE (
        SET "var_olevel_cmd=-!var_olevel!"
      )      

      REM show info about compilation
      ECHO ^[F: !index_found_files!/%count_found_files%^; C: !index_compilation_modes!/%count_compilation_modes%^] %str_compilername% - !var_cpu!!var_system!!var_olevel!!var_define! | "%script_tee%" "%file_log%"
      
      REM compilation
      IF /I "%str_compiler%"=="delphi" (
        REM delphi
        dcc32 -Q -B -dCOMPTEST -U"%path_base%";"%path_libs%";"%path_out%\%%a" -I"%path_base%";"%path_libs%" -N"%path_out%\%%a" !var_define_cmd! "%%~f" | "%script_tee%" "%file_log%"
      )
      IF /I "%str_compiler%"=="fpc" (
        REM actual FPC
        "%compiler_fpc%" -vewnhq -dCOMPTEST -dBARE_FPC -Fu"%path_libs%" -FU"%path_out%\%%a" -P%%g -T%%h !var_olevel_cmd! !var_define_cmd! "%%~f" | "%script_tee%" "%file_log%"
      )      
      IF /I "%str_compiler%"=="fpc_old" (
        REM old fpc
        "%compiler_fpc_old%" -vewnhq -dCOMPTEST -dBARE_FPC -Fu"%path_libs%" -FU"%path_out%\%%a" -P%%g -T%%h !var_olevel_cmd! !var_define_cmd! "%%~f" | "%script_tee%" "%file_log%"
      )
      IF /I "%str_compiler%"=="fpc_xlin" (
        REM cross-compiling fpc
        "%compiler_fpc_xlin%" -vewnhq -dCOMPTEST -dBARE_FPC -Fu"%path_libs%" -FU"%path_out%\%%a" -P%%g -T%%h !var_olevel_cmd! !var_define_cmd! "%%~f" | "%script_tee%" "%file_log%"
      )       
      IF /I "%str_compiler%"=="fpc_xvirt" (
        REM VM cross-compiling fpc
        "%compiler_fpc_xvirt%" -vewnhq -dCOMPTEST -dBARE_FPC -Fu"%path_libs_xvirt%" -FU"%path_out%\%%a" -P%%g -T%%h !var_olevel_cmd! !var_define_cmd! "%%~f" | "%script_tee%" "%file_log%"
      )        

      ECHO; | "%script_tee%" "%file_log%"

      SET /A index_compilation_modes+=1
    )
  )

  SET /A index_found_files+=1
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

REM do finalization only when not called from global script
IF NOT DEFINED mode_mastercall (
  REM wait for user interaction
  ECHO Done | "%script_tee%" "%file_log%"
  @PAUSE

  REM delete the output folder, it is not needed anymore    
  RD "%path_out%" /S /Q
)

ENDLOCAL