local utils = require("../core/utils")
local make = utils.make
local addCorner = utils.addCorner
local addStroke = utils.addStroke
local applyFont = utils.applyFont
local tween = utils.tween

return function(page, args)
	args = args or {}
	local buttonText = args.text or "Button"
	local callback = args.callback
	
	local buttonRow = make("Frame", {
		Name = buttonText .. "Row",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(24, 24, 28),
		BorderSizePixel = 0,
		Parent = page,
	})
	addCorner(buttonRow, 10)
	addStroke(buttonRow, Color3.fromRGB(60, 60, 68), 0.65, 1)
	
	local label = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, - 140, 1, 0),
		Text = tostring(buttonText),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = buttonRow,
	})
	applyFont(label, 14, Color3.fromRGB(232, 232, 236), Enum.TextXAlignment.Left)
	
	local actionButton = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, - 12, 0.5, 0),
		Size = UDim2.fromOffset(100, 28),
		BackgroundColor3 = Color3.fromRGB(100, 100, 110),
		BorderSizePixel = 0,
		Text = "run",
		TextColor3 = Color3.fromRGB(235, 235, 240),
		AutoButtonColor = false,
		Parent = buttonRow,
	})
	applyFont(actionButton, 13, Color3.fromRGB(235, 235, 240), Enum.TextXAlignment.Center)
	addCorner(actionButton, 7)
	
	actionButton.MouseEnter:Connect(function()
		tween(actionButton, {
			BackgroundColor3 = Color3.fromRGB(120, 120, 130)
		}, 0.12):Play()
	end)
	
	actionButton.MouseLeave:Connect(function()
		tween(actionButton, {
			BackgroundColor3 = Color3.fromRGB(100, 100, 110)
		}, 0.12):Play()
	end)
	
	actionButton.MouseButton1Down:Connect(function()
		tween(actionButton, {
			BackgroundColor3 = Color3.fromRGB(80, 80, 90)
		}, 0.08):Play()
	end)
	
	actionButton.MouseButton1Up:Connect(function()
		tween(actionButton, {
			BackgroundColor3 = Color3.fromRGB(100, 100, 110)
		}, 0.12):Play()
	end)
	
	actionButton.MouseButton1Click:Connect(function()
		tween(actionButton, {BackgroundColor3 = Color3.fromRGB(80, 80, 90)}, 0.05):Play()
		task.wait(0.1)
		tween(actionButton, {BackgroundColor3 = Color3.fromRGB(100, 100, 110)}, 0.05):Play()
		if callback then callback() end
	end)
	
	return actionButton
end
