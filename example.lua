local MonoUI = loadstring(game:HttpGet("http://localhost:6767/mono-ui.luau"))()

-- Enable Sleek Watermark & Stats Overlay
MonoUI.SetWatermark({
	visible = true,
	text = "MonoUI Premium",
})

-- Send initial load notifications
task.spawn(function()
	task.wait(0.5)
	MonoUI.Notify({
		title = "System Initialized",
		content = "MonoUI has successfully loaded all modular assets.",
		icon = "check-circle",
		duration = 4,
	})
end)

local window = MonoUI.CreateWindow({
	Title = "mono ui",
	Subtitle = "premium modular library",
	Size = UDim2.fromOffset(600, 400),
	Icon = "shield",
	ConfigName = "mono_demo_config",
	AutoSave = true,
	AutoExec = true, -- Fitur AutoExec Aktif!
})


-- Logger setup first so other components can log to it
local consoleTab = window:CreateTab({
	text = "Console",
	icon = "terminal",
})

consoleTab:CreateSection({
	text = "System Action Logs"
})
local logger = consoleTab:CreateLogger({
	text = "Mono Console Output",
	height = 280,
})

-- Register premium GUI events
window.event.PreOpened(function(event)
	logger:Log("INFO", "PreOpened event triggered!")
	event.message("Booting MonoUI Library...")
	task.wait(1.0)
	event.message("Loading Config File...")
	task.wait(0.8)
	event.message("Done!")
	task.wait(0.4)
	event.done()
end)

window.event.Closed(function()
	logger:Log("WARNING", "Main GUI has been closed!")
end)

window.event.Minimized(function()
	logger:Log("INFO", "Main GUI minimized.")
end)

-- Combat Tab
local tab1 = window:CreateTab({
	text = "Combat",
	icon = "swords",
})

tab1:CreateSection({
	text = "Combat Hacks"
})

tab1:CreateInput({
	text = "Aimbot Key",
	placeholder = "Type custom text...",
	default = "Headshot",
	flag = "aimbot_key_text",
	callback = function(value)
		logger:Log("INFO", "Aimbot text set to long text: " .. value)
	end
})

tab1:CreateToggle({
	text = "Silent Aim",
	default = false,
	flag = "silent_aim_state",
	callback = function(state)
		logger:Log("INFO", "Silent Aim: " .. (state and "ENABLED" or "DISABLED"))
	end
})

tab1:CreateDropdown({
	text = "Target Mode",
	list = {"Distance", "FOV", "Health"},
	default = "Distance",
	multiple = false,
	flag = "target_mode_dropdown",
	callback = function(value)
		logger:Log("INFO", "Target Mode set to: " .. tostring(value[1] or value))
	end
})

tab1:CreateSlider({
	text = "Aimbot FOV Range",
	min = 10,
	max = 300,
	default = 90,
	flag = "aimbot_fov_slider",
	callback = function(value)
		logger:Log("INFO", "Aimbot FOV range: " .. math.floor(value))
	end
})

tab1:CreateButton({
	text = "Force Reset Aim",
	callback = function()
		logger:Log("SUCCESS", "Aim system forcefully reset!")
	end
})

-- Settings Tab
local tab2 = window:CreateTab({
	text = "Settings",
	icon = "settings",
})

tab2:CreateSection({
	text = "Target Configurations"
})

tab2:CreateTargetBody({
	text = "Body Hitboxes (Multi)",
	multiple = true,
	default = {"Head", "Torso"},
	disabledParts = {"LeftArm", "RightArm"},
	flag = "hitbox_multi_parts",
	callback = function(parts)
		logger:Log("INFO", "Active hitboxes: " .. table.concat(parts, ", "))
	end
})

tab2:CreateTargetBody({
	text = "Primary Hitbox (Single)",
	multiple = false,
	default = "Head",
	flag = "hitbox_single_part",
	callback = function(parts)
		logger:Log("INFO", "Primary hitbox: " .. table.concat(parts, ", "))
	end
})

tab2:CreateSection({
	text = "UI Theme & Toggle"
})

-- Color Picker for Accent Theme Color (Real-time Theme Customizer!)
tab2:CreateColorPicker({
	text = "Accent Color",
	default = Color3.fromRGB(0, 162, 255),
	flag = "ui_theme_accent",
	callback = function(color)
		MonoUI.SetThemeColor("AccentColor", color)
		MonoUI.Notify({
			title = "Theme Updated",
			content = "GUI accent theme color has been customized.",
			icon = "palette",
			duration = 2.5,
		})
		logger:Log("SUCCESS", "Accent theme color customized.")
	end
})

-- Keybind Selector to toggle GUI open state
local visibleState = true
tab2:CreateKeybind({
	text = "Toggle Menu Key",
	default = Enum.KeyCode.RightControl,
	flag = "menu_toggle_keybind",
	callback = function(key)
		visibleState = not visibleState
		window:SetVisible(visibleState)
		MonoUI.Notify({
			title = "GUI Toggle",
			content = "Main window visibility set to: " .. tostring(visibleState),
			icon = "eye",
			duration = 2.5,
		})
		logger:Log("WARNING", "GUI visibility toggled using: " .. key.Name)
	end
})

-- Players Tab
local playersTab = window:CreateTab({
	text = "Players",
	icon = "users",
})

playersTab:CreateSection({
	text = "Player list ESP & Teleport"
})

playersTab:CreatePlayerList({
	text = "Active Server Players",
	height = 280,
})

-- Unused original tabs to preserve demo aesthetic
window:CreateTab({
	text = "Profile",
	icon = "user",
})

window:CreateTab({
	text = "Favorites",
	icon = "star",
})

logger:Log("SUCCESS", "All tabs loaded successfully!")

-- Create Draggable Floating Control HUD (with icons only, rounded, changes colors on state)
MonoUI.CreateControlHUD({
	{
		icon = "swords",
		default = false,
		callback = function(active)
			logger:Log("INFO", "Control HUD - Silent Aim toggled: " .. (active and "ON" or "OFF"))
		end
	},
	{
		icon = "eye",
		default = true,
		callback = function(active)
			logger:Log("INFO", "Control HUD - Player ESP toggled: " .. (active and "ON" or "OFF"))
		end
	},
	{
		icon = "gauge",
		default = false,
		callback = function(active)
			logger:Log("INFO", "Control HUD - Speed Hack toggled: " .. (active and "ON" or "OFF"))
		end
	}
})