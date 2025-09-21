@set ASEPRITE="C:\Program Files (x86)\Steam\steamapps\common\Aseprite\Aseprite.exe"

for %%G IN (*.png) DO (%ASEPRITE% -b "%%G" --scale 2 --save-as ".\2x\!$%%~nG.png")