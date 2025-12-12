@echo off

"d:\root\software\PL\zig-win64-0.1.1\zig.exe" build-obj main.zig --library c 
link.exe zig-cache\*.obj kernel32.lib ucrt.lib bufferoverflowU.lib /entry:main