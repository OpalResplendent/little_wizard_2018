@echo off

REM TODO: debug/release from cli

set NOCRT=1
set SGE_DEBUG=1
set UNICODE=1

REM Compiler options
set BuildStyle=-Od -W4 -WX -Oi -Zo -Z7
IF DEFINED UNICODE set BuildStyle=%BuildStyle% -DUNICODE -D_UNICODE

set AlwaysIgnore=-wd4201 -wd4244 -wd4100
set WarningSurpression=-wd4189 -wd4505 -wd4127 -wd4267 -wd4313 -wd4996 -wd4700 -wd4701 -wd4703 -wd4800 -wd4456 %AlwaysIgnore%
set Includes=-IC:\DEV\lib\stb -IC:\DEV\lib\

set CommonCompilerFlags=%BuildStyle% -nologo -Gm- -GR- -EHa- -fp:except- -fp:fast -FC -WL %WarningSurpression% %Includes% -EHsc
IF DEFINED NOCRT set CommonCompilerFlags=%CommonCompilerFlags% /GS- /Gs9999999 /DNOCRT
set LibraryCompilerFlags=%CommonCompilerFlags% -LD
REM -MTd

REM Linker options
set LinkerLibraries=kernel32.lib user32.lib gdi32.lib winmm.lib opengl32.lib ws2_32.lib
REM dsound.lib

set CommonLinkerFlags=-incremental:no -opt:ref %LinkerLibraries%
IF DEFINED NOCRT set CommonLinkerFlags=%CommonLinkerFlags% /STACK:0x100000,0x100000 /nodefaultlib /subsystem:windows

set ExecutableLinkerFlags=%CommonLinkerFlags% 
set LibraryLinkerFlags=%CommonLinkerFlags% -PDB:%ProjectName%_%random%.pdb -EXPORT:GameUpdateAndRender -ENTRY:DLLEntry

IF DEFINED NOCRT set ExecutableLinkerFlags=%ExecutableLinkerFlags%

IF NOT EXIST %ProjectDirectory%\build mkdir %ProjectDirectory%\build
pushd %ProjectDirectory%\build
del .%ProjectName%_*.dll > NUL 2> NUL
del %ProjectName%_*.pdb > NUL 2> NUL
echo WAITING FOR PDB > lock.tmp

cl %LibraryCompilerFlags% %ProjectDirectory%\code\%ProjectName%.cpp -Fm%ProjectName%.map /link %LibraryLinkerFlags%

set EXITCODE=%ERRORLEVEL%
del lock.tmp

cl %CommonCompilerFlags% %ProjectDirectory%\code\win32_%ProjectName%.cpp -Fmwin32_%ProjectName%.map -Fe%ProjectName% /link %ExecutableLinkerFlags% 
REM /showIncludes

set /a EXITCODE=%EXITCODE%+%ERRORLEVEL%
popd
EXIT /B %EXITCODE%
