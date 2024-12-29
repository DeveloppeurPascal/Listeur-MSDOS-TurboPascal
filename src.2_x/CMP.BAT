@echo off
set code=lis2
del *.tpu
bpc listeur2 
lha a c:\olf_soft\lzh\%code% listeur2.exe listeur2.hlp
set code=
echo on
