@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM directory path where this script resides
SET "path_this=%~dp0"

REM get path for script that is splitting output
SET "script_tee=%path_this%utils\out_split.bat"

REM prepare log file name
IF DEFINED reinit_scripts (
  SET "file_log=%path_this%%reinit_log.txt"
) ELSE (
  SET "file_log=%path_this%%update_log.txt"
)

REM delete log file if it exists
IF EXIST "!file_log!" (
  DEL "!file_log!")

REM get list of compilation test folders and their count
ECHO Enumerating scripts, please wait... | "%script_tee%" "!file_log!"
SET /A file_list_count=0
SET file_list=
FOR /R ".." %%f IN (.) DO (
  IF /I "%%~nxf"=="CompileTests" (
    SET "file_list=!file_list!,"%%~f""
    SET /A file_list_count+=1
    ECHO found scripts folder: %%~dpf | "%script_tee%" "!file_log!"
  )
  IF /I "%%~nxf"=="PrgCompileTests" (
    SET "file_list=!file_list!,"%%~f""
    SET /A file_list_count+=1
    ECHO found scripts folder: %%~dpf | "%script_tee%" "!file_log!"
  )
  IF /I "%%~nxf"=="AuxCompileTests" (
    SET "file_list=!file_list!,"%%~f""
    SET /A file_list_count+=1
    ECHO found scripts folder: %%~dpf | "%script_tee%" "!file_log!"
  )  
)
ECHO ...%file_list_count% script folders found | "%script_tee%" "!file_log!"
ECHO; | "%script_tee%" "!file_log!"

REM traverse the list and process individual entries
SET /A file_list_index=1
FOR %%f IN (%file_list%) DO (
  REM unit compile tests...
  IF /I "%%~nxf"=="CompileTests" (
    REM cleanup
    IF DEFINED reinit_scripts (
      REM delete and then reconstruct directories
      RD "%%~dpf""CompileTests" /S /Q
      MKDIR "%%~dpf""CompileTests"
      MKDIR "%%~dpf""CompileTests\utils"
      ECHO ^[!file_list_index!/!file_list_count!^] initializing scripts in project: %%~dpf | "%script_tee%" "!file_log!"
    ) ELSE (
      ECHO ^[!file_list_index!/!file_list_count!^] updating scripts in project: %%~dpf | "%script_tee%" "!file_log!"
    )
    REM copy the script files
    COPY /Y "%path_this%""utils\comp_modes_delphi.txt" "%%~dpf""CompileTests\utils\comp_modes_delphi.txt" >NUL
    COPY /Y "%path_this%""utils\comp_modes_fpc_old.txt" "%%~dpf""CompileTests\utils\comp_modes_fpc_old.txt" >NUL
    COPY /Y "%path_this%""utils\comp_modes_fpc.txt" "%%~dpf""CompileTests\utils\comp_modes_fpc.txt" >NUL
    COPY /Y "%path_this%""utils\functions.bat" "%%~dpf""CompileTests\utils\functions.bat" >NUL
    COPY /Y "%path_this%""utils\out_split.bat" "%%~dpf""CompileTests\utils\out_split.bat" >NUL
    COPY /Y "%path_this%""utils\get_global_paths.bat" "%%~dpf""CompileTests\utils\get_global_paths.bat" >NUL
    COPY /Y "%path_this%""utils\unit_compile_test.bat" "%%~dpf""CompileTests\utils\unit_compile_test.bat" >NUL
    COPY /Y "%path_this%""compile_test_fpc.bat" "%%~dpf""CompileTests\compile_test_fpc.bat" >NUL
    COPY /Y "%path_this%""compile_test_fpc_old.bat" "%%~dpf""CompileTests\compile_test_fpc_old.bat" >NUL
    COPY /Y "%path_this%""compile_test_delphi.bat" "%%~dpf""CompileTests\compile_test_delphi.bat" >NUL
    SET /A file_list_index+=1
  )

  REM project compile tests...
  IF /I "%%~nxf"=="PrgCompileTests" (
    REM cleanup
    IF DEFINED reinit_scripts (
      REM backup build modes
      SET /P fpc_build_modes_bck=<"%%~dpf""PrgCompileTests\build_modes_fpc.txt"

      REM delete and then reconstruct directories
      RD "%%~dpf""PrgCompileTests" /S /Q
      MKDIR "%%~dpf""PrgCompileTests"
      MKDIR "%%~dpf""PrgCompileTests\utils"

      REM restore build modes
      ECHO;!fpc_build_modes_bck!>"%%~dpf""PrgCompileTests\build_modes_fpc.txt"

      ECHO ^[!file_list_index!/!file_list_count!^] initializing scripts in project: %%~dpf | "%script_tee%" "!file_log!"
    ) ELSE (
      ECHO ^[!file_list_index!/!file_list_count!^] updating scripts in project: %%~dpf | "%script_tee%" "!file_log!"
    )
    REM copy the script files
    COPY /Y "%path_this%""utils\functions.bat" "%%~dpf""PrgCompileTests\utils\functions.bat" >NUL
    COPY /Y "%path_this%""utils\out_split.bat" "%%~dpf""PrgCompileTests\utils\out_split.bat" >NUL
    COPY /Y "%path_this%""utils\get_global_paths.bat" "%%~dpf""PrgCompileTests\utils\get_global_paths.bat" >NUL
    COPY /Y "%path_this%""utils\program_compile_test.bat" "%%~dpf""PrgCompileTests\utils\program_compile_test.bat" >NUL
    COPY /Y "%path_this%""project_compile_test.bat" "%%~dpf""PrgCompileTests\project_compile_test.bat" >NUL
    SET /A file_list_index+=1
  )
  
  REM auxiliary compile tests...
  IF /I "%%~nxf"=="AuxCompileTests" (
    REM cleanup
    IF DEFINED reinit_scripts (
      REM backup build modes
      SET /P fpc_build_modes_bck=<"%%~dpf""AuxCompileTests\build_modes_fpc.txt"
          
      REM delete and then reconstruct directories
      RD "%%~dpf""AuxCompileTests" /S /Q
      MKDIR "%%~dpf""AuxCompileTests"
      MKDIR "%%~dpf""AuxCompileTests\utils"
      
      REM restore build modes
      ECHO;!fpc_build_modes_bck!>"%%~dpf""AuxCompileTests\build_modes_fpc.txt"      

      ECHO ^[!file_list_index!/!file_list_count!^] initializing scripts in project: %%~dpf | "%script_tee%" "!file_log!"
    ) ELSE (
      ECHO ^[!file_list_index!/!file_list_count!^] updating scripts in project: %%~dpf | "%script_tee%" "!file_log!"
    )
    REM copy the script files
    COPY /Y "%path_this%""utils\functions.bat" "%%~dpf""AuxCompileTests\utils\functions.bat" >NUL
    COPY /Y "%path_this%""utils\out_split.bat" "%%~dpf""AuxCompileTests\utils\out_split.bat" >NUL
    COPY /Y "%path_this%""utils\get_global_paths.bat" "%%~dpf""AuxCompileTests\utils\get_global_paths.bat" >NUL
    COPY /Y "%path_this%""utils\program_compile_test.bat" "%%~dpf""AuxCompileTests\utils\program_compile_test.bat" >NUL
    COPY /Y "%path_this%""auxiliary_compile_test.bat" "%%~dpf""AuxCompileTests\auxiliary_compile_test.bat" >NUL
    SET /A file_list_index+=1
  )
)

ENDLOCAL