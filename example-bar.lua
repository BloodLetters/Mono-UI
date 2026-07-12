local MonoUI = loadstring(game:HttpGet("http://192.168.100.101:6767/mono-ui.luau"))()

-- Initial Notification
MonoUI.Notify({
    title = "Test Script Loaded",
    content = "MonoUI is running with 3-tab testing layout.",
    icon = "check-circle",
    duration = 5,
})

-- Create Window
local window = MonoUI.CreateWindow({
    Title = "MonoUI Ultimate Testing",
    Subtitle = "Full Component & Grid Test",
    Size = UDim2.fromOffset(620, 420),
    Icon = "shield",
    ConfigName = "mono_ultimate_test_config",
    AutoSave = true,
})

-- PreOpened Action Log
local logger
window.event.PreOpened(function(event)
    event.message("Setting up test tabs...")
    task.wait(0.5)
    event.message("Binding actions...")
    task.wait(0.3)
    event.done()
end)

-- TAB 1: Grid & Layouts (HBar + VBar)
local tabLayout = window:CreateTab({
    text = "Grid Layouts",
    icon = "grid",
})

tabLayout:CreateSection({ text = "Row 1 - 2 Column Grid (HBar + VBar)" })

local row1 = tabLayout:CreateHBar()
local leftCol = row1:CreateVBar()
local rightCol = row1:CreateVBar()

-- Left Column Elements
leftCol:CreateSection({ text = "Left Column (Target)" })
leftCol:CreateToggle({
    text = "Aimbot Active",
    default = false,
    flag = "grid_aimbot_enabled",
    callback = function(state)
        if logger then logger:Log("INFO", "Aimbot Active: " .. tostring(state)) end
    end,
})
leftCol:CreateSlider({
    text = "Smooth Value",
    min = 1, max = 20, default = 5,
    flag = "grid_aimbot_smooth",
    callback = function(value)
        if logger then logger:Log("INFO", "Aimbot Smooth: " .. math.floor(value)) end
    end,
})
leftCol:CreateDropdown({
    text = "Aimbot Target",
    list = {"Head", "Torso", "HumanoidRootPart"},
    default = "Head",
    flag = "grid_aimbot_target",
    callback = function(val)
        if logger then logger:Log("INFO", "Aimbot Target: " .. tostring(val[1] or val)) end
    end,
})

-- Right Column Elements
rightCol:CreateSection({ text = "Right Column (Visuals)" })
rightCol:CreateColorPicker({
    text = "Accent Color",
    default = Color3.fromRGB(0, 162, 255),
    flag = "grid_visual_color",
    callback = function(color)
        MonoUI.SetThemeColor("AccentColor", color)
        if logger then logger:Log("SUCCESS", "Accent Theme Color Updated!") end
    end,
})
rightCol:CreateKeybind({
    text = "Toggle GUI Key",
    default = Enum.KeyCode.RightControl,
    flag = "grid_menu_key",
    callback = function(key)
        if logger then logger:Log("WARNING", "GUI Toggle bind changed to: " .. key.Name) end
    end,
})
rightCol:CreateInput({
    text = "Config Name",
    placeholder = "Enter name...",
    default = "Default",
    flag = "grid_config_name",
    callback = function(text)
        if logger then logger:Log("INFO", "Config Name set to: " .. text) end
    end,
})

tabLayout:CreateSection({ text = "Row 2 - 3 Column Grid (HBar + VBar)" })

local row2 = tabLayout:CreateHBar()
local col1 = row2:CreateVBar()
local col2 = row2:CreateVBar()
local col3 = row2:CreateVBar()

col1:CreateButton({
    text = "Button A",
    callback = function()
        if logger then logger:Log("INFO", "Button A Pressed!") end
    end,
})
col2:CreateButton({
    text = "Button B",
    callback = function()
        if logger then logger:Log("INFO", "Button B Pressed!") end
    end,
})
col3:CreateButton({
    text = "Button C",
    callback = function()
        if logger then logger:Log("INFO", "Button C Pressed!") end
    end,
})


-- TAB 2: Standard Layout (Full Width)
local tabStandard = window:CreateTab({
    text = "Standard Width",
    icon = "maximize",
})

tabStandard:CreateSection({ text = "Standard Components (Full-width)" })
tabStandard:CreateToggle({
    text = "Esp Chams",
    default = true,
    flag = "std_chams_enabled",
    callback = function(state)
        if logger then logger:Log("INFO", "ESP Chams: " .. tostring(state)) end
    end,
})
tabStandard:CreateSlider({
    text = "Esp Render Distance",
    min = 50, max = 2000, default = 500,
    flag = "std_render_distance",
    callback = function(value)
        if logger then logger:Log("INFO", "Chams distance: " .. math.floor(value)) end
    end,
})
tabStandard:CreateDropdown({
    text = "Chams Type",
    list = {"Outline", "Fill", "Highlight", "Both"},
    default = "Highlight",
    flag = "std_chams_type",
    callback = function(val)
        if logger then logger:Log("INFO", "Chams style: " .. tostring(val[1] or val)) end
    end,
})
tabStandard:CreateInput({
    text = "Custom Player Tag",
    placeholder = "Default: Guest",
    default = "",
    flag = "std_player_tag",
    callback = function(text)
        if logger then logger:Log("INFO", "Tag changed: " .. text) end
    end,
})
tabStandard:CreateTargetBody({
    text = "Body Hitboxes (Multi)",
    multiple = true,
    default = {"Head", "Torso"},
    disabledParts = {"LeftArm", "RightArm"},
    flag = "std_hitbox_parts",
    callback = function(parts)
        if logger then logger:Log("INFO", "Active hitboxes: " .. table.concat(parts, ", ")) end
    end,
})
tabStandard:CreateButton({
    text = "Force Re-render Visuals",
    callback = function()
        if logger then logger:Log("SUCCESS", "Forcing render refresh...") end
    end,
})


-- TAB 3: Console & Players
local tabWidgets = window:CreateTab({
    text = "Widgets Console",
    icon = "terminal",
})

tabWidgets:CreateSection({ text = "Activity Console Logs" })
logger = tabWidgets:CreateLogger({
    text = "Mono Console",
    height = 140,
})

tabWidgets:CreateSection({ text = "Active Server Players" })
tabWidgets:CreatePlayerList({
    text = "Roblox Active Players",
    height = 160,
    buttons = {
        {
            text = "TP",
            type = "button",
            callback = function(player)
                if logger then logger:Log("INFO", "Attempting TP to: " .. player.Name) end
                local localPlayer = game:GetService("Players").LocalPlayer
                if localPlayer and localPlayer.Character and player.Character then
                    local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    if root and targetRoot then
                        root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -3)
                    end
                end
            end,
        },
        {
            text = "ESP",
            type = "toggle",
            callback = function(player, active)
                if logger then logger:Log("INFO", "ESP state for " .. player.Name .. ": " .. (active and "ON" or "OFF")) end
                if active then
                    local char = player.Character
                    if char then
                        local hl = Instance.new("Highlight")
                        hl.Name = "MonoESP"
                        hl.FillColor = Color3.fromRGB(0, 162, 255)
                        hl.FillTransparency = 0.5
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.OutlineTransparency = 0
                        hl.Adornee = char
                        hl.Parent = char
                    end
                else
                    local char = player.Character
                    local hl = char and char:FindFirstChild("MonoESP")
                    if hl then hl:Destroy() end
                end
            end,
        }
    }
})

-- Create Control HUD (Floating)
MonoUI.CreateControlHUD({
    {
        icon = "shield",
        default = false,
        callback = function(active)
            if logger then logger:Log("INFO", "HUD Aimbot State: " .. (active and "ON" or "OFF")) end
        end
    },
    {
        icon = "eye",
        default = true,
        callback = function(active)
            if logger then logger:Log("INFO", "HUD Visuals State: " .. (active and "ON" or "OFF")) end
        end
    }
})

logger:Log("SUCCESS", "Ultimate testing script initialized successfully!")
