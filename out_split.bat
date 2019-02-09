@ECHO OFF  

SETLOCAL 

SET LogFile=%1 

REM FIND will take input from pipe and returns list of all lines with 
REM numbers in the format [line_number]line_text
REM these are then processed one by one, each line is split onto two 
REM using ] as delimited
REM %%A contains [line_number and automatically allocated %%B contains 
REM the line_text
REM this is then echoed into both console and log file that was passed 
REM to this script as first parameter
FOR /F "tokens=1* delims=]" %%A IN ('FIND /N /V ""') DO (
	ECHO:%%B >  CON    
	ECHO:%%B >> %LogFile%
) 

ENDLOCAL