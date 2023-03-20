@echo OFF

cd src

SET ROMNAME=refurb

del %ROMNAME%.min

cd src\includes
call buildgfx.bat
cd..
cd..

bin\pmas.exe src\%ROMNAME%.asm %ROMNAME%.min %ROMNAME%.sym

echo "Done"
