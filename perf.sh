cp zigpacked/zig-out/bin/zigpacked /tmp/
cp zigmulti/zig-out/bin/zigmulti /tmp/
cp zig/zig-out/bin/zig /tmp/
cp zigcomp/zig-out/bin/zigcomp /tmp/
cp rust/target/release/rust /tmp/
cp csharp/bin/Release/net8.0/linux-x64/publish/csharp /tmp/csharpAot
hyperfine --warmup 10 /tmp/zigpacked /tmp/zigmulti /tmp/zigcomp /tmp/zig /tmp/rust /tmp/csharpAot --export-markdown result.mkd
echo
echo ----------------------------------------------------------------------
echo
strip -s /tmp/zigpacked /tmp/zigmulti /tmp/zigcomp /tmp/zig /tmp/rust /tmp/csharpAot
exa -alF /tmp/zigpacked /tmp/zigmulti /tmp/zigcomp /tmp/zig /tmp/rust /tmp/csharpAot 
glow -s light ./result.mkd
