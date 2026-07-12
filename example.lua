local MonoUI = loadstring(game:HttpGet("http://192.168.100.101:6767/mono-ui.luau"))()

MonoUI.SetWatermark({
	visible = true,
	text = "MonoUI Premium",
})

task.spawn(function()
	task.wait(0.5)
	MonoUI.Notify({
		title = "System Initialized",
		content = "MonoUI has successfully loaded all modular assets.",
		icon = "check-circle",
		duration = 5,
	})
	task.wait(0.3)
	MonoUI.Notify({
		title = "Config Loaded",
		content = "Found and applied saved configuration file.",
		icon = "settings",
		duration = 4,
	})
	task.wait(0.3)
	MonoUI.Notify({
		title = "AutoExec Ready",
		content = "Persistence script queued for next teleport.",
		icon = "zap",
		duration = 3,
	})
end)

local window = MonoUI.CreateWindow({
	Title = "mono ui",
	Subtitle = "premium modular library",
	Size = UDim2.fromOffset(600, 400),
	Icon = "shield",
	ConfigName = "mono_demo_config",
	AutoSave = true,
	AutoExec = true,
})

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

local tab2 = window:CreateTab({
	text = "Settings",
	icon = "settings",
})

local hbar = tab2:CreateHBar()
local leftCol = hbar:CreateVBar()
local rightCol = hbar:CreateVBar()

leftCol:CreateSection({
	text = "Target Configurations"
})

leftCol:CreateTargetBody({
	text = "Body Hitboxes (Multi)",
	multiple = true,
	default = {"Head", "Torso"},
	disabledParts = {"LeftArm", "RightArm"},
	flag = "hitbox_multi_parts",
	callback = function(parts)
		logger:Log("INFO", "Active hitboxes: " .. table.concat(parts, ", "))
	end
})

rightCol:CreateSection({
	text = "UI Theme & Toggle"
})

rightCol:CreateColorPicker({
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

local visibleState = true
rightCol:CreateKeybind({
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

local playersTab = window:CreateTab({
	text = "Players",
	icon = "users",
})

playersTab:CreateSection({
	text = "Player list ESP & Teleport"
})

playersTab:CreateTargetBody({
	text = "Primary Hitbox (Single)",
	multiple = false,
	default = "Head",
	flag = "hitbox_single_part",
	callback = function(parts)
		logger:Log("INFO", "Primary hitbox: " .. table.concat(parts, ", "))
	end
})

playersTab:CreatePlayerList({
	text = "Active Server Players",
	height = 280,
	buttons = {
		{
			text = "TP",
			type = "button",
			callback = function(player)
				logger:Log("INFO", "Teleporting to: " .. player.Name)
				local localPlayer = game:GetService("Players").LocalPlayer
				if localPlayer and localPlayer.Character and player.Character then
					local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")
					local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
					if root and targetRoot then
						root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -3)
					end
				end
			end
		},
		{
			text = "ESP",
			type = "toggle",
			callback = function(player, active)
				logger:Log("INFO", "ESP for " .. player.Name .. ": " .. (active and "ON" or "OFF"))
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
					if char then
						local hl = char:FindFirstChild("MonoESP")
						if hl then
							hl:Destroy()
						end
					end
				end
			end
		}
	}
})

window:CreateTab({
	text = "Profile",
	icon = "user",
})

window:CreateTab({
	text = "Favorites",
	icon = "star",
})

logger:Log("SUCCESS", "All tabs loaded successfully!")

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