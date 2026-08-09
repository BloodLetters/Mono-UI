@echo off
echo [BUILD] Compiling MonoUI core using Darklua...
darklua process src/init.lua dist/mono-ui.luau
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] MonoUI Build failed!
    exit /b %ERRORLEVEL%
)

echo [BUILD] Compiling Guard module using Darklua...
darklua process modules/Guard/init.lua dist/Guard.luau
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Guard Build failed!
    exit /b %ERRORLEVEL%
)

echo [BUILD] Compiling Lead module using Darklua...
darklua process modules/Lead/init.lua dist/Lead.luau
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Lead Build failed!
    exit /b %ERRORLEVEL%
)

echo [BUILD] Compiling Vanity module using Darklua...
darklua process modules/Vanity/init.lua dist/Vanity.luau
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Vanity Build failed!
    exit /b %ERRORLEVEL%
)

echo [BUILD] Post-processing for executor compatibility...
:: Prepend Packages global shim so bundled Janitor Promise type-shim works without Roblox Packages service
powershell -Command "$c = Get-Content dist/mono-ui.luau -Raw; $s = '--[MonoUI Executor Shim]' + [char]10 + 'do local function _() end; Packages = setmetatable({FindFirstChild=_,FindFirstChildWhichIsA=_,FindFirstChildOfClass=_,WaitForChild=_,GetChildren=function() return{} end},{__index=function() return nil end}); end' + [char]10 + [char]10; Set-Content dist/mono-ui.luau -Value ($s + $c) -NoNewline"
echo [SUCCESS] Build succeeded! Files saved to dist/mono-ui.luau, dist/Guard.luau, dist/Lead.luau, and dist/Vanity.luau
