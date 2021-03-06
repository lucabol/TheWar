@echo off
copy zigpacked\zig-out\bin\zigpacked.exe tmp\ > nul 2>&1
copy zigmulti\zig-out\bin\zigmulti.exe tmp\ > nul 2>&1
copy zig\zig-out\bin\zig.exe tmp\ > nul 2>&1
copy zigcomp\zig-out\bin\zigcomp.exe tmp\ > nul 2>&1
copy rust\target\release\rust.exe tmp\ > nul 2>&1
copy csharp\bin\Release\net6.0\win-x64\publish\csharp.exe tmp\csharpAot.exe > nul 2>&1
hyperfine --warmup 10 tmp\zigpacked.exe tmp\zigmulti.exe tmp\zigcomp.exe tmp\zig.exe tmp\rust.exe tmp\csharpAot.exe csharp\bin\release\net6.0\csharp.exe --export-markdown result.mkd
echo.
echo ----------------------------------------------------------------------
echo.
cmd /c "dir tmp /o:s /a:a" | grep exe
glow -s light .\result.mkd
