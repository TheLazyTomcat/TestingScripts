@ECHO OFF

REM directory path where this script resides
SET this_path=%~dp0

REM search for CompileTests folder and copy the test file there
FOR /R ".." %%f IN (.) DO (
  IF /I "%%~nxf"=="CompileTests" (
    ECHO copying scripts to project: %%~dpf
    COPY /Y "%this_path%""fpc_compile_test.bat" "%%~dpf""CompileTests\fpc_compile_test.bat" >NUL
    COPY /Y "%this_path%""old_fpc_compile_test.bat" "%%~dpf""CompileTests\old_fpc_compile_test.bat" >NUL
    COPY /Y "%this_path%""delphi_compile_test.bat" "%%~dpf""CompileTests\delphi_compile_test.bat" >NUL
  )
  IF /I "%%~nxf"=="PrgCompileTests" (
    ECHO copying scripts to project: %%~dpf
    COPY /Y "%this_path%""project_compile_test.bat" "%%~dpf""PrgCompileTests\project_compile_test.bat" >NUL
  )
)