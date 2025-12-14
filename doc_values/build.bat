@echo off

"D:\root\software\lang\zig-win64-0.1.1\zig.exe" build-obj main.zig --library c 
link.exe zig-cache\*.obj kernel32.lib ucrt.lib bufferoverflowU.lib /entry:main