@ECHO OFF

SETLOCAL

REM FIND takes input from pipe and returns list of all lines with numbers in
REM the format [line_number]line_text     
REM these are then processed one by one, each line is split into two
REM using ] as a delimited    
REM %%a contains [line_number and automatically allocated %%b contains 
REM the line_text      
REM this text is then echoed into both console and log file that was passed
REM to this script as first parameter  
FOR /F "tokens=1* delims=]" %%a IN ('FIND /N /V ""') DO (
	ECHO:%%b>CON
	ECHO:%%b>>%1
)

ENDLOCAL