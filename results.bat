@echo off
@echo .
cmd /c "dir tmp /o:s /a:a" | grep exe
glow -w 150 -s light .\stable_results.mkd
