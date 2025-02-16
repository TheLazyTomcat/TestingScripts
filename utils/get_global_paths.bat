@ECHO OFF

REM Note that content of this script is user- and system-specific, so it is in
REM its current form of no use for most people

REM path to latest installed fpc and lazbuild
SET "compiler_fpc=C:\Lazarus\fpc\3.0.4\bin\i386-win32\fpc.exe"
SET "compiler_lazb=C:\Lazarus\lazbuild.exe"

REM path to older (before 3.0.0) fpc and lazbuild
SET "compiler_fpc_old=C:\Lazarus_1_4_4\fpc\2.6.4\bin\i386-win32\fpc.exe"
SET "compiler_lazb_old=C:\Lazarus_1_4_4\lazbuild.exe"

REM path to fpc and lazbuild set up for crosscompilation into linux
SET "compiler_fpc_xlin=C:\Lazarus_ex\install\fpc\bin\i386-win32\fpc.exe"
SET "compiler_lazb_xlin=C:\Lazarus_ex\install\lazarus\lazbuild.exe"

REM path to crosscompiling fpc in virtual machine
SET "compiler_fpc_xvirt=C:\Lazarus_ex\install\fpc\bin\i386-win32\fpc.exe"
SET "path_libs_xvirt=X:\Libraries\__Libs"

REM well, libraries
SET "path_libs=F:\Programy\Libraries\__Libs"