@echo off
echo [BUILD] Compiling MonoUI using Darklua...
darklua process src/init.lua dist/mono-ui.luau
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Build failed!
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] Build succeeded! File saved to dist/mono-ui.luau
