local Guard = loadstring(game:HttpGet("http://192.168.100.101:6767/Guard.luau"))()

-- Initialize Guard Key System with Dark Monochrome style options
local guardInstance = Guard.new({
    Title = "AshLabs Security Guard",
    Subtitle = "Enter key to authenticate",
    Logo = "shield-check",
    Key = "mono-2026", -- Test Key
    GetKeyUrl = "https://ashlabs.vercel.app/get-key",
    DiscordUrl = "https://discord.gg/ashlabs",
    NoteText = "Join our Discord community to get the test key: mono-2026",
    ConfigName = "ashlabs_guard_test",
    AccentColor = Color3.fromRGB(240, 240, 245), -- Dark monochrome accent
    OnSuccess = function()
        print("[Guard] Verification success! Loading Mono-UI...")
        
        -- Load Mono-UI from Local Dev Server
        local MonoUI = loadstring(game:HttpGet("http://localhost:6767/mono-ui.luau"))()
        
        MonoUI.Notify({
            title = "Access Granted",
            content = "Welcome to MonoUI Hub!",
            icon = "check-circle",
            duration = 4
        })

        local window = MonoUI.CreateWindow({
            Title = "AshLabs Hub",
            Subtitle = "Dark Monochrome Edition",
            Size = UDim2.fromOffset(580, 380),
            Icon = "shield",
            ConfigName = "ashlabs_mono_config",
            AutoSave = true
        })

        local mainTab = window:CreateTab({
            text = "Dashboard",
            icon = "grid"
        })

        mainTab:CreateSection({ text = "System Status" })
        mainTab:CreateParagraph({
            title = "Authentication Status",
            content = "Successfully authenticated via Guard Key System (Dark Monochrome Edition)."
        })

        -- Example Timer using MonoUI.CreateTimer
        if MonoUI.CreateTimer then
            local timer = MonoUI.CreateTimer(1, function()
                print("[AshLabs] Heartbeat check running via MonoUI.CreateTimer...")
            end)
            timer:Start()
        end
    end
})
