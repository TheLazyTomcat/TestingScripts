@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM exit if this script is not properly called
IF NOT DEFINED mode_called (
  EXIT /B)
  
REM running master script
SET /A mode_mastercall=1  

REM get directory path where this batch resides
SET "path_this=%~dp0"

REM obtain global paths
CALL "%path_this%\get_global_paths.bat"

REM get path for script that is splitting output
SET "script_tee=%path_this%\out_split.bat"

REM prepare log file name
SET "file_log=%path_start%\%str_compiler%_log.txt"

REM delete log file if it exists
IF EXIST "%file_log%" (
  DEL "%file_log%")

REM get directory where to store compiled units
SET "path_out=%path_start%\%str_compiler%_out"

REM reinit output directories
IF EXIST "%path_out%" (
  RD "%path_out%" /S /Q)

REM create output directories, also loads list of compilation modes
MKDIR "%path_out%"
SET /P list_compilation_modes=<"%path_this%comp_modes_%str_compiler%.txt"
SET /A count_compilation_modes=0
FOR %%a IN (%list_compilation_modes%) DO (
  MKDIR "%path_out%\%%a"
  SET /A count_compilation_modes+=1
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

REM show legend
CALL "%path_this%functions.bat", :show_legend | "%script_tee%" "%file_log%"

REM search for compilation test scripts and call them one by one
FOR /R %path_base% %%f IN ("*.bat") DO (
  IF /I "%%~nxf"=="compile_test_%str_compiler%.bat" (
    IF /I NOT "%%~dpf"=="%path_start%" (
    
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