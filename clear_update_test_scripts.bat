@ECHO OFF

REM directory path where this script resides
SET this_path=%~dp0

REM search for CompileTests folder and copy the test file there
FOR /R ".." %%f IN (.) DO (
  IF /I "%%~nxf"=="CompileTests" (
    REM cleanup
    RD "%%~dpf""CompileTests" /S /Q
    MKDIR "%%~dpf""CompileTests"
  
    ECHO copying scripts to project: %%~dpf
    COPY /Y "%this_path%""out_split.bat" "%%~dpf""CompileTests\out_split.bat" >NUL
    COPY /Y "%this_path%""get_global_paths.bat" "%%~dpf""CompileTests\get_global_paths.bat" >NUL
    COPY /Y "%this_path%""compile_test_fpc.bat" "%%~dpf""CompileTests\compile_test_fpc.bat" >NUL
    COPY /Y "%this_path%""compile_test_old_fpc.bat" "%%~dpf""CompileTests\compile_test_old_fpc.bat" >NUL
    COPY /Y "%this_path%""compile_test_delphi.bat" "%%~dpf""CompileTests\compile_test_delphi.bat" >NUL
  )
  IF /I "%%~nxf"=="PrgCompileTests" (
    REM cleanup
    RD "%%~dpf""PrgCompileTests" /S /Q    
    MKDIR "%%~dpf""PrgCompileTests"
    
    ECHO copying scripts to project: %%~dpf
    COPY /Y "%this_path%""out_split.bat" "%%~dpf""PrgCompileTests\out_split.bat" >NUL
    COPY /Y "%this_path%""get_global_paths.bat" "%%~dpf""PrgCompileTests\get_global_paths.bat" >NUL
    COPY /Y "%this_path%""project_compile_test.bat" "%%~dpf""PrgCompileTests\project_compile_test.bat" >NUL
  )
)