@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM prepare prefix for file names (eg. log files)
IF NOT DEFINED str_modifier (
  SET "str_modifier=")

REM setup start and base path (if required)
IF NOT DEFINED path_start (
  SET "path_start=%~dp0")
IF NOT DEFINED path_base (  
  SET "path_base=%~dp0..")

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

REM directory path where this script resides
SET "path_this=%~dp0"

REM get path for script that is splitting output
SET "script_tee=%path_this%utils\out_split.bat"

REM prepare log file name
IF DEFINED script_reinit (
  SET "file_log=%path_this%reinit_log%str_modifier%.txt"
) ELSE (
  SET "file_log=%path_this%update_log%str_modifier%.txt"
)

REM delete log file if it exists
IF EXIST "%file_log%" (
  DEL "%file_log%")
  
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  

REM get list of compilation test folders and their count
ECHO Enumerating scripts, please wait... | "%script_tee%" "%file_log%"
ECHO; | "%script_tee%" "%file_log%"
SET /A count_procpaths=0
SET list_procpaths=
FOR /R %path_base% %%f IN (.) DO (
  IF /I "%%~nxf"=="CompileTests" (
    SET "list_procpaths=!list_procpaths!,"%%~f""
    SET /A count_procpaths+=1
    ECHO found ^(u^) script folder in: %%~dpf | "%script_tee%" "%file_log%"
  )
  IF /I "%%~nxf"=="PrgCompileTests" (
    SET "list_procpaths=!list_procpaths!,"%%~f""
    SET /A count_procpaths+=1
    ECHO found ^(p^) script folder in: %%~dpf | "%script_tee%" "%file_log%"
  )
  IF /I "%%~nxf"=="AuxCompileTests" (
    SET "list_procpaths=!list_procpaths!,"%%~f""
    SET /A count_procpaths+=1
    ECHO found ^(a^) script folder in: %%~dpf | "%script_tee%" "%file_log%"
  )
  IF /I "%%~nxf"=="LibsCompileTests" (
    SET "list_procpaths=!list_procpaths!,"%%~f""
    SET /A count_procpaths+=1
    ECHO found ^(l^) script folder in: %%~dpf | "%script_tee%" "%file_log%"
  )  
)
ECHO; | "%script_tee%" "%file_log%"
ECHO ...%count_procpaths% script folders found | "%script_tee%" "%file_log%"
ECHO; | "%script_tee%" "%file_log%"

REM temp folder for backups
IF DEFINED script_reinit (
  IF NOT EXIST "%TEMP%\comp_tests_baks" (
    MKDIR "%TEMP%\comp_tests_baks"
  )
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

REM traverse the list and process individual entries
SET /A index_procpaths=1
FOR %%f IN (%list_procpaths%) DO (

  IF DEFINED script_reinit (
    ECHO ^[!index_procpaths!/%count_procpaths%^] initializing scripts in project: %%~dpf | "%script_tee%" "%file_log%"
  ) ELSE (
    ECHO ^[!index_procpaths!/%count_procpaths%^] updating scripts in project: %%~dpf | "%script_tee%" "%file_log%"
  ) 
  
  REM unit compile tests...
  IF /I "%%~nxf"=="CompileTests" (     
    REM cleanup
    IF DEFINED script_reinit (
      REM delete and then reconstruct directories
      RD "%%~dpfCompileTests" /S /Q
      MKDIR "%%~dpfCompileTests"
      MKDIR "%%~dpfCompileTests\utils"
    )
    REM copy the script files
    COPY /Y "%path_this%utils\comp_modes_delphi.txt" "%%~dpfCompileTests\utils\comp_modes_delphi.txt" >NUL
    COPY /Y "%path_this%utils\comp_modes_fpc.txt" "%%~dpfCompileTests\utils\comp_modes_fpc.txt" >NUL
    COPY /Y "%path_this%utils\comp_modes_fpc_old.txt" "%%~dpfCompileTests\utils\comp_modes_fpc_old.txt" >NUL
    COPY /Y "%path_this%utils\comp_modes_fpc_xlin.txt" "%%~dpfCompileTests\utils\comp_modes_fpc_xlin.txt" >NUL
    COPY /Y "%path_this%utils\comp_modes_fpc_xvirt.txt" "%%~dpfCompileTests\utils\comp_modes_fpc_xvirt.txt" >NUL    
    COPY /Y "%path_this%utils\functions.bat" "%%~dpfCompileTests\utils\functions.bat" >NUL
    COPY /Y "%path_this%utils\out_split.bat" "%%~dpfCompileTests\utils\out_split.bat" >NUL
    COPY /Y "%path_this%utils\get_global_paths.bat" "%%~dpfCompileTests\utils\get_global_paths.bat" >NUL
    COPY /Y "%path_this%utils\unit_compile_test.bat" "%%~dpfCompileTests\utils\unit_compile_test.bat" >NUL
    COPY /Y "%path_this%compile_test_delphi.bat" "%%~dpfCompileTests\compile_test_delphi.bat" >NUL
    COPY /Y "%path_this%compile_test_fpc.bat" "%%~dpfCompileTests\compile_test_fpc.bat" >NUL
    COPY /Y "%path_this%compile_test_fpc_old.bat" "%%~dpfCompileTests\compile_test_fpc_old.bat" >NUL
    COPY /Y "%path_this%compile_test_fpc_xlin.bat" "%%~dpfCompileTests\compile_test_fpc_xlin.bat" >NUL
    COPY /Y "%path_this%compile_test_fpc_xvirt.bat" "%%~dpfCompileTests\compile_test_fpc_xvirt.bat" >NUL    
    
    SET /A index_procpaths+=1
  )  
  
  REM project compile tests...
  IF /I "%%~nxf"=="PrgCompileTests" ( 
    REM cleanup
    IF DEFINED script_reinit (
      REM backup build modes
      COPY /Y "%%~dpfPrgCompileTests\build_modes_fpc.txt" "%TEMP%\comp_tests_baks\temp.bak" >NUL

      REM delete and then reconstruct directories
      RD "%%~dpfPrgCompileTests" /S /Q
      MKDIR "%%~dpfPrgCompileTests"
      MKDIR "%%~dpfPrgCompileTests\utils"

      REM restore build modes
      COPY /Y "%TEMP%\comp_tests_baks\temp.bak" "%%~dpfPrgCompileTests\build_modes_fpc.txt" >NUL
    )    
    REM copy the script files
    COPY /Y "%path_this%utils\functions.bat" "%%~dpfPrgCompileTests\utils\functions.bat" >NUL
    COPY /Y "%path_this%utils\out_split.bat" "%%~dpfPrgCompileTests\utils\out_split.bat" >NUL
    COPY /Y "%path_this%utils\get_global_paths.bat" "%%~dpfPrgCompileTests\utils\get_global_paths.bat" >NUL
    COPY /Y "%path_this%utils\program_compile_test.bat" "%%~dpfPrgCompileTests\utils\program_compile_test.bat" >NUL
    COPY /Y "%path_this%project_compile_test.bat" "%%~dpfPrgCompileTests\project_compile_test.bat" >NUL
    
    SET /A index_procpaths+=1
  )
  
  REM auxiliary compile tests...
  IF /I "%%~nxf"=="AuxCompileTests" (
    REM cleanup
    IF DEFINED script_reinit (
      REM backup build modes
      COPY /Y "%%~dpfAuxCompileTests\build_modes_fpc.txt" "%TEMP%\comp_tests_baks\temp.bak" >NUL

      REM delete and then reconstruct directories
      RD "%%~dpfAuxCompileTests" /S /Q
      MKDIR "%%~dpfAuxCompileTests"
      MKDIR "%%~dpfAuxCompileTests\utils"

      REM restore build modes
      COPY /Y "%TEMP%\comp_tests_baks\temp.bak" "%%~dpfAuxCompileTests\build_modes_fpc.txt" >NUL
    )
    REM copy the script files
    COPY /Y "%path_this%utils\functions.bat" "%%~dpfAuxCompileTests\utils\functions.bat" >NUL
    COPY /Y "%path_this%utils\out_split.bat" "%%~dpfAuxCompileTests\utils\out_split.bat" >NUL
    COPY /Y "%path_this%utils\get_global_paths.bat" "%%~dpfAuxCompileTests\utils\get_global_paths.bat" >NUL
    COPY /Y "%path_this%utils\program_compile_test.bat" "%%~dpfAuxCompileTests\utils\program_compile_test.bat" >NUL
    COPY /Y "%path_this%auxiliary_compile_test.bat" "%%~dpfAuxCompileTests\auxiliary_compile_test.bat" >NUL
    
    SET /A index_procpaths+=1
  )  
  
  REM libraries compile tests...
  IF /I "%%~nxf"=="LibsCompileTests" (     
    REM cleanup
    IF DEFINED script_reinit (
      REM delete and then reconstruct directories
      RD "%%~dpfLibsCompileTests" /S /Q
      MKDIR "%%~dpfLibsCompileTests"
      MKDIR "%%~dpfLibsCompileTests\utils"
    )
    REM copy the script files
    REM todo
    
    SET /A index_procpaths+=1
  )    
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

REM remove temp folder
IF DEFINED script_reinit (
  IF EXIST "%TEMP%\comp_tests_baks" (
    RD "%TEMP%\comp_tests_baks" /S /Q
  )
)

REM wait for user input
ECHO; | "%script_tee%" "%file_log%"
ECHO Done | "%script_tee%" "%file_log%"
@PAUSE

ENDLOCAL