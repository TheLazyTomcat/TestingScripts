@ECHO OFF

REM path to latest installed fpc and lazbuild
SET "path_fpc=C:\Lazarus\fpc\3.2.2\bin\i386-win32\fpc.exe"
SET "path_lazb=C:\Lazarus\lazbuild.exe"

REM path to older (before 3.0.0) fpc and lazbuild
SET "path_fpc_old=C:\Lazarus_1_4_4\fpc\2.6.4\bin\i386-win32\fpc.exe"
SET "path_lazb_old=C:\Lazarus_1_4_4\lazbuild.exe"

REM path to fpc and lazbuild set up for crosscompilation into linux
SET "path_fpc_xlin=C:\Lazarus_ex\install\fpc\bin\i386-win32\fpc.exe"
SET "path_lazb_xlin=C:\Lazarus_ex\install\lazarus\lazbuild.exe"

REM well, libraries
SET "path_libs=F:\Programy\Libraries\__Libs"