@ECHO OFF

REM redirect to proper function
GOTO %~1
EXIT /B

REM shows legend for compilation cycles
:show_legend
  ECHO ^[F: x/X; C: y/Y^]
  ECHO   x - index of processed file
  ECHO   X - total number of files
  ECHO   y - compilation/build cycle
  ECHO   Y - total number of compilation/build cycles
  ECHO;
EXIT /B