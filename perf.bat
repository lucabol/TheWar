@echo off
copy zig\zig-out\bin\zig.exe tmp\ > nul 2>&1
copy zigcomp\zig-out\bin\zigcomp.exe tmp\ > nul 2>&1
copy rust\target\release\rust.exe tmp\ > nul 2>&1
copy csharp\bin\Release\net6.0\win-x64\publish\csharp.exe tmp\ > nul 2>&1
hyperfine --warmup 3 --min-runs 200 tmp\zig.exe tmp\zigcomp.exe tmp\rust.exe tmp\csharp.exe --export-markdown result.mkd
echo.
echo ----------------------------------------------------------------------
echo.
cmd /c "dir tmp /o:s /a:a" | grep /
glow -s light .\result.mkd
