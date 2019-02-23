@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM directory path where this script resides
SET "path_this=%~dp0"

REM get list of compilation test folders and their count
ECHO Enumerating scripts, please wait...
SET /A file_list_count=0
SET file_list=
FOR /R ".." %%f IN (.) DO (
  IF /I "%%~nxf"=="CompileTests" (
    SET "file_list=!file_list!,"%%~f""
    SET /A file_list_count+=1
  )
  IF /I "%%~nxf"=="PrgCompileTests" (
    SET "file_list=!file_list!,"%%~f""
    SET /A file_list_count+=1
  )
)
ECHO;

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
      ECHO ^[!file_list_index!/!file_list_count!^] initializing scripts in project: %%~dpf
    ) ELSE (
      ECHO ^[!file_list_index!/!file_list_count!^] updating scripts in project: %%~dpf
    )
    REM copy the script files
    COPY /Y "%path_this%""utils\comp_modes_delphi.txt" "%%~dpf""CompileTests\utils\comp_modes_delphi.txt" >NUL
    COPY /Y "%path_this%""utils\comp_modes_fpc_old.txt" "%%~dpf""CompileTests\utils\comp_modes_fpc_old.txt" >NUL   
    COPY /Y "%path_this%""utils\comp_modes_fpc.txt" "%%~dpf""CompileTests\utils\comp_modes_fpc.txt" >NUL    
    COPY /Y "%path_this%""utils\functions.bat" "%%~dpf""CompileTests\utils\functions.bat" >NUL
    COPY /Y "%path_this%""utils\out_split.bat" "%%~dpf""CompileTests\utils\out_split.bat" >NUL
    COPY /Y "%path_this%""utils\get_global_paths.bat" "%%~dpf""CompileTests\utils\get_global_paths.bat" >NUL
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

      ECHO ^[!file_list_index!/!file_list_count!^] initializing scripts in project: %%~dpf
    ) ELSE (
      ECHO ^[!file_list_index!/!file_list_count!^] updating scripts in project: %%~dpf
    )
    REM copy the script files
    COPY /Y "%path_this%""utils\functions.bat" "%%~dpf""PrgCompileTests\utils\functions.bat" >NUL
    COPY /Y "%path_this%""utils\out_split.bat" "%%~dpf""PrgCompileTests\utils\out_split.bat" >NUL
    COPY /Y "%path_this%""utils\get_global_paths.bat" "%%~dpf""PrgCompileTests\utils\get_global_paths.bat" >NUL
    COPY /Y "%path_this%""project_compile_test.bat" "%%~dpf""PrgCompileTests\project_compile_test.bat" >NUL
    SET /A file_list_index+=1
  )
)

ENDLOCAL