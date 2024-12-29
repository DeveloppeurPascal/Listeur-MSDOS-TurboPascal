@echo off
set code=demolis2
del *.tpu
bpc listeur2 /ddemo_vers
lha a c:\olf_soft\lzh\%code% listeur2.exe listeur2.hlp
set code=
echo on
