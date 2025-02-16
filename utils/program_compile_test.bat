@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM exit if not properly called
IF NOT DEFINED mode_called (
  EXIT /B)

REM get directory path where this batch resides
SET "path_this=%~dp0"

REM get path for script that is splitting output
SET "script_tee=%path_this%\out_split.bat"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

REM load build modes
SET /A count_fpc_build_mode_groups=0
FOR /F "usebackq tokens=1* delims=\" %%f IN ("%path_start%\build_modes_fpc.txt") DO (
  SET "count_fpc_build_mode_groups[!count_fpc_build_mode_groups!].item=%%~f"
  SET "count_fpc_build_mode_groups[!count_fpc_build_mode_groups!].line=%%g"

  SET /A count_fpc_build_mode_groups+=1
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

REM obtain auxiliary paths (path to compilers, path to libraries)
CALL "%path_this%\get_global_paths.bat"

REM prepare log file name
SET "file_log=%path_start%\log.txt"

REM delete log file if it exists
IF EXIST "%file_log%" (
  DEL "%file_log%")
  
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

REM get list of project files and their count
ECHO Enumerating project files, please wait... | "%script_tee%" "%file_log%"
ECHO; | "%script_tee%" "%file_log%"
SET /A count_projects=0
SET list_projects=
IF /I "%mode_aux_build%" NEQ "0" (
  REM compiling auxiliary program (programs used for unit testing)
  FOR /R "%path_start%..\TestBed_Delphi" %%f IN ("*.dpr") DO (
    SET "list_projects=!list_projects!,"%%~f""
    ECHO %%~f | "%script_tee%" "%file_log%"
    SET /A count_projects+=1
  )
  FOR /R "%path_start%..\TestBed_Lazarus" %%f IN ("*.lpi") DO (
    SET "list_projects=!list_projects!,"%%~f""
    ECHO %%~f | "%script_tee%" "%file_log%"
    SET /A count_projects+=1
  )
) ELSE (
  REM building classic program project
  FOR /R "%path_start%..\Dev" %%f IN ("*.dpr","*.lpi") DO (
    SET "list_projects=!list_projects!,"%%~f""
    ECHO %%~f | "%script_tee%" "%file_log%"
    SET /A count_projects+=1
  )
)
ECHO; | "%script_tee%" "%file_log%"
ECHO ...%count_projects% project file(s) found | "%script_tee%" "%file_log%"
ECHO; | "%script_tee%" "%file_log%"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

REM show legend
CALL "%path_this%functions.bat", :show_legend | "%script_tee%" "%file_log%"

REM prepare command lines for compilation
SET "var_cmd_delphi=dcc32 -Q -B"
SET "var_cmd_lazarus_old=-B --bm="
SET "var_cmd_lazarus=-B --no-write-project --bm="

REM traverse projects and compile them
SET /A index_projects=1
FOR %%f IN (%list_projects%) DO (

  REM write what project is about to be build
  ECHO ^[F: !index_projects!/%count_projects%^] Building project: | "%script_tee%" "%file_log%"
  ECHO ^[F: !index_projects!/%count_projects%^] %%~f | "%script_tee%" "%file_log%"

  REM Delphi builds
  IF /I "%%~xf"==".dpr" (
    ECHO; | "%script_tee%" "%file_log%"
    ECHO ^[F: !index_projects!/%count_projects%^; C: 1/1^] Delphi | "%script_tee%" "%file_log%"

    CD "%%~dpf"

    %var_cmd_delphi% "%%~f" | "%script_tee%" "%file_log%"
  )

  REM Lazarus builds
  IF /I "%%~xf"==".lpi" (
    CD "%%~dpf"

    REM select build modes group
    SET /A var_group_index=0
    CALL :select_build_modes_group "%%~nxf" var_group_index
    FOR %%i in (!var_group_index!) DO (
      SET "list_fpc_build_modes=!count_fpc_build_mode_groups[%%i].line!"
    )

    REM get number of build modes
    SET /A count_fpc_build_modes=0
    FOR %%a IN (!list_fpc_build_modes!) DO (
      SET /A count_fpc_build_modes+=1
    )

    REM iterate build modes
    SET /A index_fpc_build_modes=1
    FOR %%m in (!list_fpc_build_modes!) DO (
      REM building in old lazarus
      ECHO; | "%script_tee%" "%file_log%"
      ECHO ^[F: !index_projects!/%count_projects%^; C: !index_fpc_build_modes!/!count_fpc_build_modes!^] Old Lazarus - %%m | "%script_tee%" "%file_log%"

      %compiler_lazb_old% %var_cmd_lazarus_old%%%m "%%~f" | "%script_tee%" "%file_log%"      

      REM building in current lazarus
      ECHO; | "%script_tee%" "%file_log%"
      ECHO ^[F: !index_projects!/%count_projects%^; C: !index_fpc_build_modes!/!count_fpc_build_modes!^] Actual Lazarus - %%m | "%script_tee%" "%file_log%"

      %compiler_lazb% %var_cmd_lazarus%%%m "%%~f" | "%script_tee%" "%file_log%"
      
      REM crossbuilding in lazarus
      ECHO; | "%script_tee%" "%file_log%"
      ECHO ^[F: !index_projects!/%count_projects%^; C: !index_fpc_build_modes!/!count_fpc_build_modes!^] Crosscompiling Lazarus - %%m | "%script_tee%" "%file_log%"

      %compiler_lazb_xlin% %var_cmd_lazarus%%%m "%%~f" | "%script_tee%" "%file_log%"      

      SET /A index_fpc_build_modes+=1
    )
  )

  ECHO; | "%script_tee%" "%file_log%"

  SET /A index_projects+=1
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

REM wait for user interaction
ECHO Done | "%script_tee%" "%file_log%"
@PAUSE

EXIT /B

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

REM function selecting proper build group
REM parameter 1 is name of the file for which the group is being selected
REM result is stored in second parameter reference
:select_build_modes_group
  REM find build group for the file
  SET /A var_index=%count_fpc_build_mode_groups%

  :group_loop
    SET /A var_index-=1
    IF /I "!count_fpc_build_mode_groups[%var_index%].item!"=="%~1" (
      GOTO group_loop_end)
  IF /I %var_index% GTR 0 GOTO group_loop
  :group_loop_end

  SET "%2=%var_index%"

EXIT /B

ENDLOCAL