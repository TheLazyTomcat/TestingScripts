@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM exit if not called by a proper script
IF NOT DEFINED comp_str (
  EXIT /B)

REM get directory path where this batch resides
SET "path_master=%~dp0"

REM obtain global paths
CALL "%path_master%get_global_paths.bat"

REM get path for script that is splitting output
SET "script_tee=%path_master%out_split.bat"

REM prepare log file name
SET "file_log=%path_all_base%%comp_str%_log.txt"

REM delete log file if it exists
IF EXIST "%file_log%" (
  DEL "%file_log%")

REM get directory where to store compiled units
SET "path_out=%path_all_base%%comp_str%_out"

REM reinit output directories
IF EXIST "%path_out%" (
  RD "%path_out%" /S /Q)

REM create output directories, also loads list of compilation modes
MKDIR "%path_out%"
SET /P comp_modes=<"%path_master%comp_modes_%comp_str%.txt"
SET /A comp_mode_count=0
FOR %%a IN (%comp_modes%) DO (
  MKDIR "%path_out%\%%a"
  SET /A comp_mode_count+=1
)

REM show legend
CALL "%path_master%functions.bat", :show_legend | "%script_tee%" "%file_log%"

REM search for compilation test scripts and call them one by one
FOR /R "%path_all_base%.." %%f IN ("*.bat") DO (
  IF /I "%%~nxf"=="compile_test_%comp_str%.bat" (
    IF /I NOT "%%~dpf"=="%path_all_base%" (
    
      REM get name of the script's parent directory and check if it is not disabled 
      SET "x="%%~pdf."" 
      FOR %%a IN (!x!) DO (
        SET "x=%%~na")
    
      IF /I "!x!"=="CompileTests" (      
        ECHO Running test: | "%script_tee%" "!file_log!"
        ECHO %%~f | "%script_tee%" "!file_log!"
        ECHO; | "%script_tee%" "!file_log!"

        CALL "%%f"
      )
    )
  )
)

REM delete binaries
RD "%path_out%" /S /Q

ENDLOCAL