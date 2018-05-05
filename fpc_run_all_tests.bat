@ECHO OFF

SET /A master_batch=1

CALL "get_global_paths.bat"

SET master_path=%~dp0

SET out_dir=%this_path%fpc_out
SET log_file=%this_path%fpc_log.txt

IF EXIST "%out_dir%" (
  RD "%out_dir%" /s /q)
  
MKDIR "%out_dir%"

IF EXIST "%log_file%" (
  DEL "%log_file%")
  
FOR /R ".." %%f IN ("*.bat") DO (
  IF /I "%%~nxf"=="fpc_compile_test.bat" (
    IF /I NOT "%%~dpf"=="%master_path%" (
      CALL "%%f"
    )
  )
)

RD "%out_dir%" /S /Q