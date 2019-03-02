@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM exit if not called by a proper script
IF NOT DEFINED aux_build (
  EXIT /B)

REM get directory path where this batch resides
SET "path_this=%~pd0"

REM get path for script that is splitting output
SET "script_tee=%path_this%out_split.bat"

REM load build modes
SET /A build_modes_group_count=0
FOR /F "usebackq tokens=1* delims=\" %%f IN ("%path_this%..\build_modes_fpc.txt") DO (
  SET fpc_build_modes[!build_modes_group_count!].item=%%~f
  SET fpc_build_modes[!build_modes_group_count!].line=%%g
  SET /A build_modes_group_count+=1
)

REM prepare log file name
SET "file_log=%path_this%..\log.txt"

REM obtain auxiliary paths (path to compiler in fpc_path, path to libraries in libs_path)
CALL "%path_this%""get_global_paths.bat"

REM delete log file if it exists
IF EXIST "!file_log!" (
  DEL "!file_log!")

REM prepare command lines for compilation
SET "cmd_delphi=dcc32 -Q -B"
SET "cmd_lazarus_old=-B --bm="
SET "cmd_lazarus=-B --no-write-project --bm="

REM get list of project files and their count
ECHO Enumerating project files, please wait... | "%script_tee%" "!file_log!"
SET /A file_list_count=0
SET file_list=
IF /I "%aux_build%" EQU "1" (
  FOR /R "%path_this%..\..\TestBed_Delphi" %%f IN ("*.dpr") DO (
    SET "file_list=!file_list!,"%%~f""
    ECHO %%~f | "%script_tee%" "!file_log!"
    SET /A file_list_count+=1
  )
  FOR /R "%path_this%..\..\TestBed_Lazarus" %%f IN ("*.lpi") DO (
    SET "file_list=!file_list!,"%%~f""
    ECHO %%~f | "%script_tee%" "!file_log!"
    SET /A file_list_count+=1
  )
) ELSE (
  FOR /R "%path_this%..\..\Dev" %%f IN ("*.dpr","*.lpi") DO (
    SET "file_list=!file_list!,"%%~f""
    ECHO %%~f | "%script_tee%" "!file_log!"
    SET /A file_list_count+=1
  )
)

ECHO ...%file_list_count% project file(s) found | "%script_tee%" "!file_log!"
ECHO; | "%script_tee%" "!file_log!"

REM show legend
CALL "%path_this%""functions.bat", :show_legend | "%script_tee%" "!file_log!"

REM search for projects and compile them
SET /A file_list_index=1
FOR %%f IN (!file_list!) DO (

  REM write what project is about to be build
  ECHO ^[F: !file_list_index!/!file_list_count!^] Building project: | "%script_tee%" "!file_log!"
  ECHO ^[F: !file_list_index!/!file_list_count!^] %%~f | "%script_tee%" "!file_log!"
  ECHO; | "%script_tee%" "!file_log!"

  REM Delphi builds
  IF /I "%%~xf"==".dpr" (
    ECHO ^[F: !file_list_index!/!file_list_count!^; C: 1/1^] Delphi | "%script_tee%" "!file_log!"

    CD "%%~dpf"

    %cmd_delphi% "%%~f" | "%script_tee%" "!file_log!"

    ECHO; | "%script_tee%" "!file_log!"
  )

  REM Lazarus builds
  IF /I "%%~xf"==".lpi" (
    CD "%%~dpf"

    REM select build modes group
    SET /A group_index=0
    CALL :select_build_modes_group "%%~nxf" group_index
    FOR %%i in (!group_index!) DO (
      SET "current_modes=!fpc_build_modes[%%i].line!"
    )

    REM get number of build modes
    SET /A fpc_build_mode_count=0
    FOR %%a IN (!current_modes!) DO (SET /A fpc_build_mode_count+=1)

    REM iterate modes
    SET /A fpc_build_mode_index=1
    FOR %%m in (!current_modes!) DO (
      REM building in old lazarus
      ECHO ^[F: !file_list_index!/!file_list_count!^; C: !fpc_build_mode_index!/!fpc_build_mode_count!^] Old Lazarus - %%m | "%script_tee%" "!file_log!"

      %path_lazb_old% %cmd_lazarus_old%%%m "%%~f" | "%script_tee%" "!file_log!"

      ECHO; | "%script_tee%" "!file_log!"

      REM building in current lazarus
      ECHO ^[F: !file_list_index!/!file_list_count!^; C: !fpc_build_mode_index!/!fpc_build_mode_count!^] Actual Lazarus - %%m | "%script_tee%" "!file_log!"

      %path_lazb% %cmd_lazarus%%%m "%%~f" | "%script_tee%" "!file_log!"

      ECHO; | "%script_tee%" "!file_log!"

      SET /A fpc_build_mode_index+=1
    )
  )

  SET /A file_list_index+=1
)

REM wait for user interaction
ECHO Done | "%script_tee%" "%file_log%"
@PAUSE

EXIT /B

REM function selectiong proper build group
REM parameter 1 is name of the file for which the group is being selected
REM result is stored in second parameter reference
:select_build_modes_group
  REM find build group for the file
  SET /A index=!build_modes_group_count!

  :group_loop
    SET /A index-=1
    IF /I "!fpc_build_modes[%index%].item!"=="%~1" (
      GOTO group_loop_end)
  IF /I !index! GTR 0 GOTO group_loop
  :group_loop_end

  SET "%2=!index!"

EXIT /B

ENDLOCAL