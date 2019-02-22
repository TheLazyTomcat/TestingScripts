@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM check is this script is called from a global check script or not
IF DEFINED master_script (
  SET /A is_inner=1
) ELSE (
  SET /A is_inner=0
)

REM get directory path where this batch resides
SET "path_this=%~dp0"

REM get path for script that is splitting output
SET "script_tee=%path_this%utils\out_split.bat"

REM list of compilation modes
SET "comp_modes=i386-win32-O1-null i386-win32-O3-null i386-win32-O1-PurePascal i386-win32-O3-PurePascal x86_64-win64-O1-null x86_64-win64-O3-null x86_64-win64-O1-PurePascal x86_64-win64-O3-PurePascal"
SET /A comp_mode_count=0
FOR %%a IN (%comp_modes%) DO (SET /A comp_mode_count+=1)

REM do following only when not called from global check script
IF /I "%is_inner%" EQU "0" (
  IF DEFINED old_fpc (
    CALL "%path_this%""utils\common.bat", :compile_test_internal_init, "fpc_old"
  ) ELSE (
    CALL "%path_this%""utils\common.bat", :compile_test_internal_init, "fpc"
  )
)

REM prepare command line for compilation
IF DEFINED old_fpc (
  SET cmd_line="%path_fpc_old%" -vewnhq -dBARE_FPC -Fu"%path_libs%"
) ELSE (
  SET cmd_line="%path_fpc%" -vewnhq -dBARE_FPC -Fu"%path_libs%"
)

REM enumerate processed files
CALL "%path_this%""utils\common.bat", :compile_test_enum_files

REM show legend
CALL "%path_this%""utils\common.bat", :compile_test_show_legend | "%script_tee%" "!file_log!"

REM traverse all found *.pas files and compile them
SET /A file_list_index=1
FOR %%f IN (%file_list%) DO (
  REM show what file is about to be compiled
  ECHO ^[F: !file_list_index!/!file_list_count!^] Compiling file: | "%script_tee%" "!file_log!"
  ECHO ^[F: !file_list_index!/!file_list_count!^] %%~f | "%script_tee%" "!file_log!"
  ECHO; | "%script_tee%" "!file_log!"

  SET /A comp_mode_index=1
  FOR %%a IN (%comp_modes%) DO (
    FOR /F "tokens=1-4 delims=-" %%g in ("%%a") DO (
      IF /I "%%j"=="null" (
        ECHO ^[F: !file_list_index!/!file_list_count!^; C: !comp_mode_index!/!comp_mode_count!^] FPC - %%g %%h %%i | "%script_tee%" "!file_log!"
      ) ELSE (
        ECHO ^[F: !file_list_index!/!file_list_count!^; C: !comp_mode_index!/!comp_mode_count!^] FPC - %%g %%h %%i %%j | "%script_tee%" "!file_log!"
      )

      REM compilation
      %cmd_line% -FU"!path_out!\%%a" -P"%%g" -T"%%h" -"%%i" -d"%%j" "%%~f" | "%script_tee%" "!file_log!"

      ECHO; | "%script_tee%" "!file_log!"

      SET /A comp_mode_index+=1
    )
  )

  SET /A file_list_index+=1
)

REM do following only when not called from global check script
IF /I "%is_inner%" EQU "0" (
  CALL "%path_this%""utils\common.bat", :compile_test_internal_final
)

ENDLOCAL