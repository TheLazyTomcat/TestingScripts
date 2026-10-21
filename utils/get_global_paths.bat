@ECHO OFF

REM Note that content of this script is user- and system-specific, so it is in
REM its current form of no use for most people

REM path to default delphi compiler
SET "compiler_dcc=C:\Program Files (x86)\Borland\Delphi7\Bin\dcc32.exe"

REM path to latest installed fpc and lazbuild
SET "compiler_fpc=C:\Apps\Lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe"
SET "compiler_lazb=C:\Apps\Lazarus\lazbuild.exe"

REM path to older (before 3.0.0) fpc and lazbuild
SET "compiler_fpc_old=C:\Apps\Lazarus_1_4_4\fpc\2.6.4\bin\i386-win32\fpc.exe"
SET "compiler_lazb_old=C:\Apps\Lazarus_1_4_4\lazbuild.exe"

REM path to fpc and lazbuild set up for crosscompilation into linux
SET "compiler_fpc_xlin=C:\Apps\Lazarus_ex\install\fpc\bin\x86_64-win64\fpc.exe"
SET "compiler_lazb_xlin=C:\Apps\Lazarus_ex\install\lazarus\lazbuild.exe"

REM well, libraries
SET "path_libs=D:\Programy\Libraries\__Libs"