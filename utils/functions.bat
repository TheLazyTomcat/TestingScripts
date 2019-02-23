@ECHO OFF

REM redirect to proper function
GOTO %~1
EXIT /B

REM initializes directories and path variables for unit compilation tests
:compile_test_internal_init
  REM get directory where to store compiled binaries
  SET "path_out=%path_this%%~2_out"

  REM prepare log file name
  SET "file_log=%path_this%%~2_log.txt"

  REM obtain auxiliary paths (paths to compilers, paths to libraries, ...)
  CALL "%path_this%""utils\get_global_paths.bat"

  REM if the output directory exists, delete it
  IF EXIST "!path_out!" (
    RD "!path_out!" /S /Q)

  REM create output directories
  MKDIR "!path_out!"
  FOR %%a IN (%comp_modes%) DO (
    MKDIR "!path_out!""\""%%a"
  )

  REM delete log file if it exists
  IF EXIST "!file_log!" (
    DEL "!file_log!")
EXIT /B

REM get list of processed pas files and their count
:compile_test_enum_files
  ECHO Enumerating files, please wait... | "%script_tee%" "!file_log!"
  SET /A file_list_count=0
  SET file_list=
  FOR /R "%path_this%..\Dev" %%f IN ("*.pas") DO (
    SET "file_list=!file_list!,"%%~f""
    ECHO %%~f | "%script_tee%" "!file_log!"
    SET /A file_list_count+=1
  )
  ECHO ...%file_list_count% files found | "%script_tee%" "!file_log!"
  ECHO; | "%script_tee%" "!file_log!"
EXIT /B

REM shows legend for compilation cycles
:compile_test_show_legend
  ECHO ^[F: x/X; C: y/Y^]
  ECHO   x - index of processed file
  ECHO   X - total number of files
  ECHO   y - compilation/build cycle
  ECHO   Y - total number of compilation/build cycles
  ECHO;
EXIT /B

REM finalizes compilation
:compile_test_internal_final
  REM wait for user interaction
  @PAUSE

  REM delete the output folder, it is not needed anymore
  RD "!path_out!" /S /Q
EXIT /B

REM get list of project files and their count
:project_compile_test_enum_files
  ECHO Enumerating project files, please wait... | "%script_tee%" "!file_log!"
  SET /A file_list_count=0
  SET file_list=
  FOR /R "%path_this%..\Dev" %%f IN ("*.dpr","*.lpi") DO (
    SET "file_list=!file_list!,"%%~f""
    ECHO %%~f | "%script_tee%" "!file_log!"
    SET /A file_list_count+=1
  )
  ECHO ...%file_list_count% project files found | "%script_tee%" "!file_log!"
  ECHO; | "%script_tee%" "!file_log!"
EXIT /B