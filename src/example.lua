local MonoUI = require("./init")

local window = MonoUI.CreateWindow({
	Title = "mono ui",
	Subtitle = "tabbed minimal gui",
	Size = UDim2.fromOffset(580, 380),
	Icon = "shield", -- Optional window icon (using Lucide preset)
})

local tab1 = window:CreateTab({
	text = "Combat",
	icon = "swords", -- Optional tab icon (using Lucide preset)
})

tab1:CreateSection({
	text = "Combat Hacks"
})
tab1:CreateInput({
	text = "Key",
	placeholder = "type here",
	default = "",
	callback = function(value)
		print(value)
	end
})
tab1:CreateToggle({
	text = "example toggle",
	default = false,
	callback = function(state)
		print("toggle:", state)
	end
})
tab1:CreateDropdown({
	text = "example dropdown",
	list = {
		"one",
		"two",
		"three",
		"421312313",
		"diwajidawijdiawdjawidjiwa",
		"dwaijdwiadjawijdiwajdjiwadjiw",
		"dawijdawijdwai",
		"dawiojdwaijdiawdjijwadiwajdiawidijwad",
		"dwaijdawijdaiwjidwja"
	},
	default = "one",
	multiple = true,
	callback = function(value)
		print("dropdown:", value)
	end
})
tab1:CreateToggle({
	text = "example toggle 2",
	default = false,
	callback = function(state)
		print("toggle:", state)
	end
})
tab1:CreateButton({
	text = "Execute",
	callback = function()
		print("button clicked!")
	end
})
tab1:CreateColorPicker({
	text = "Pick Color",
	default = Color3.fromRGB(100, 100, 110),
	callback = function(color)
		print("color:", color)
	end
})
tab1:CreateSlider({
	text = "Speed",
	min = 0,
	max = 100,
	default = 50,
	callback = function(value)
		print("slider:", value)
	end
})

local tab2 = window:CreateTab({
	text = "Settings",
	icon = "settings", -- Settings icon
})

local tab3 = window:CreateTab({
	text = "Profile",
	icon = "user", -- Profile icon
})

local tab4 = window:CreateTab({
	text = "Favorites",
	icon = "star", -- Star icon
})

-- The remaining tabs demonstrate that the icon is indeed optional
local tab5 = window:CreateTab({
	text = "Tab No Icon"
})

local tab6 = window:CreateTab({
	text = "Tab Text Icon",
	icon = "🔥", -- Emoji icon
})

local tab7 = window:CreateTab({
	text = "Custom ID Icon",
	icon = 10723351906, -- Custom Roblox Asset ID (Info Icon)
})