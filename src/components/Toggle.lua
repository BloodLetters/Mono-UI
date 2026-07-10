local utils = require("../core/utils")
local make = utils.make
local addCorner = utils.addCorner
local addStroke = utils.addStroke
local applyFont = utils.applyFont
local tween = utils.tween

return function(page, args)
	args = args or {}
	local toggleText = args.text or "Toggle"
	local defaultValue = args.default
	local callback = args.callback
	
	local toggleRow = make("Frame", {
		Name = toggleText or "Toggle",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(24, 24, 28),
		BorderSizePixel = 0,
		Parent = page,
	})
	addCorner(toggleRow, 10)
	addStroke(toggleRow, Color3.fromRGB(60, 60, 68), 0.65, 1)
	
	local label = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, - 80, 1, 0),
		Text = tostring(toggleText or "Toggle"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = toggleRow,
	})
	applyFont(label, 14, Color3.fromRGB(232, 232, 236), Enum.TextXAlignment.Left)
	
	local toggleButton = make("TextButton", {
		Size = UDim2.fromOffset(56, 28),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(34, 34, 40),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Parent = toggleRow,
	})
	addCorner(toggleButton, 14)
	
	local knob = make("Frame", {
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.fromOffset(4, 4),
		BackgroundColor3 = Color3.fromRGB(235, 235, 235),
		BorderSizePixel = 0,
		Parent = toggleButton,
	})
	addCorner(knob, 10)
	
	local state = defaultValue == true
	local function render()
		local activeColor = Color3.fromRGB(235, 235, 235)
		local inactiveColor = Color3.fromRGB(34, 34, 40)
		toggleButton.BackgroundColor3 = state and activeColor or inactiveColor
		knob.Position = state and UDim2.fromOffset(32, 4) or UDim2.fromOffset(4, 4)
		knob.BackgroundColor3 = state and Color3.fromRGB(18, 18, 20) or Color3.fromRGB(235, 235, 235)
	end
	
	toggleButton.Activated:Connect(function()
		state = not state
		tween(toggleButton, {BackgroundColor3 = state and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(34, 34, 40)}, 0.2):Play()
		tween(knob, {Position = state and UDim2.fromOffset(32, 4) or UDim2.fromOffset(4, 4)}, 0.2):Play()
		if callback then callback(state) end
	end)
	
	render()
	
	return {
		Set = function(_, value)
			state = value == true
			render()
		end,
		Get = function()
			return state
		end,
	}
end
