local utils = require("../core/utils")
local make = utils.make
local addCorner = utils.addCorner
local addStroke = utils.addStroke
local applyFont = utils.applyFont

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
		Size = UDim2.fromOffset(48, 22),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, - 12, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(34, 34, 40),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Parent = toggleRow,
	})
	addCorner(toggleButton, 12)
	
	local knob = make("Frame", {
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = Color3.fromRGB(235, 235, 235),
		BorderSizePixel = 0,
		Parent = toggleButton,
	})
	addCorner(knob, 8)
	
	local state = defaultValue == true
	local function render()
		local activeColor = Color3.fromRGB(235, 235, 235)
		local inactiveColor = Color3.fromRGB(34, 34, 40)
		toggleButton.BackgroundColor3 = state and activeColor or inactiveColor
		knob.Position = state and UDim2.fromOffset(29, 3) or UDim2.fromOffset(3, 3)
		knob.BackgroundColor3 = state and Color3.fromRGB(18, 18, 20) or Color3.fromRGB(235, 235, 235)
	end
	
	toggleButton.MouseButton1Click:Connect(function()
		state = not state
		render()
		if callback then
			callback(state)
		end
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
