@echo off
echo [BUILD] Compiling MonoUI using Darklua...
darklua process src/init.lua dist/mono-ui.luau
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Build failed!
    exit /b %ERRORLEVEL%
)

echo [BUILD] Post-processing for executor compatibility...
:: Prepend Packages global shim so bundled Janitor Promise type-shim works without Roblox Packages service
powershell -Command "$c = Get-Content dist/mono-ui.luau -Raw; $s = '--[MonoUI Executor Shim]' + [char]10 + 'do local function _() end; Packages = setmetatable({FindFirstChild=_,FindFirstChildWhichIsA=_,FindFirstChildOfClass=_,WaitForChild=_,GetChildren=function() return{} end},{__index=function() return nil end}); end' + [char]10 + [char]10; Set-Content dist/mono-ui.luau -Value ($s + $c) -NoNewline"
echo [SUCCESS] Build succeeded! File saved to dist/mono-ui.luau
