@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM check if this script is called from a global check script or not
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
SET /P comp_modes=<"%path_this%utils\comp_modes_delphi.txt"
SET /A comp_mode_count=0
FOR %%a IN (%comp_modes%) DO (SET /A comp_mode_count+=1)

REM do following only when not called from global check script
IF /I "%is_inner%" EQU "0" (
  CALL "%path_this%""utils\functions.bat", :compile_test_internal_init, "delphi"
)

REM prepare command line for compilation
SET cmd_line=dcc32 -Q -B -U"%%~pdf.";"%path_this%..\Dev";"%path_libs%" -I"%path_this%..\Dev";"%path_libs%"

REM enumerate processed files
CALL "%path_this%""utils\functions.bat", :compile_test_enum_files

REM show legend
IF /I "%is_inner%" EQU "0" (
  CALL "%path_this%""utils\functions.bat", :compile_test_show_legend | "%script_tee%" "!file_log!"
)

REM traverse all found *.pas files and compile them
SET /A file_list_index=1
FOR %%f IN (%file_list%) DO (
  REM show what file is about to be compiled
  ECHO ^[F: !file_list_index!/!file_list_count!^] Compiling file: | "%script_tee%" "!file_log!"
  ECHO ^[F: !file_list_index!/!file_list_count!^] %%~f | "%script_tee%" "!file_log!"
  ECHO; | "%script_tee%" "!file_log!"

  SET /A comp_mode_index=1
  FOR %%a IN (%comp_modes%) DO (
    FOR /F "tokens=1-3 delims=-" %%g in ("%%a") DO (
      IF /I "%%i"=="null" (
        ECHO ^[F: !file_list_index!/!file_list_count!^; C: !comp_mode_index!/!comp_mode_count!^] Delphi - %%g %%h | "%script_tee%" "!file_log!"
      ) ELSE (
        ECHO ^[F: !file_list_index!/!file_list_count!^; C: !comp_mode_index!/!comp_mode_count!^] Delphi - %%g %%h %%i | "%script_tee%" "!file_log!"
      )

      REM compilation
      %cmd_line% -D"%%i" -U"!path_out!\%%a" -N"!path_out!\%%a" "%%~f" | "%script_tee%" "!file_log!"

      ECHO; | "%script_tee%" "!file_log!"

      SET /A comp_mode_index+=1
    )
  )

  SET /A file_list_index+=1
)

REM do following only when not called from global check script
IF /I "%is_inner%" EQU "0" (
  CALL "%path_this%""utils\functions.bat", :compile_test_internal_final
)

ENDLOCAL