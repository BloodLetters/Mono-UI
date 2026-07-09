local utils = require("../core/utils")
local make = utils.make
local addCorner = utils.addCorner
local addStroke = utils.addStroke
local applyFont = utils.applyFont
local tween = utils.tween

return function(page, args)
	args = args or {}
	local bindText = args.text or "Keybind"
	local currentKey = args.default or Enum.KeyCode.None
	local callback = args.callback
	
	local binding = false

	-- UI Row
	local row = make("Frame", {
		Name = bindText .. "KeybindRow",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(24, 24, 28),
		BorderSizePixel = 0,
		Parent = page,
	})
	addCorner(row, 10)
	addStroke(row, Color3.fromRGB(60, 60, 68), 0.65, 1)

	local label = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -140, 1, 0),
		Text = tostring(bindText),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
	applyFont(label, 14, Color3.fromRGB(232, 232, 236), Enum.TextXAlignment.Left)

	local bindBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(100, 28),
		BackgroundColor3 = Color3.fromRGB(32, 32, 38),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Parent = row,
	})
	addCorner(bindBtn, 7)
	local stroke = addStroke(bindBtn, Color3.fromRGB(60, 60, 68), 0.55, 1)

	local btnLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = currentKey == Enum.KeyCode.None and "[None]" or currentKey.Name,
		Parent = bindBtn,
	})
	applyFont(btnLabel, 11, Color3.fromRGB(200, 200, 210), Enum.TextXAlignment.Center)

	local function updateBtnText()
		btnLabel.Text = binding and "[Press Key]" or (currentKey == Enum.KeyCode.None and "[None]" or currentKey.Name)
		local textColor = binding and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(200, 200, 210)
		btnLabel.TextColor3 = textColor
	end

	-- Listen for key presses globally to trigger callback
	local globalConnection
	globalConnection = utils.UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == currentKey and currentKey ~= Enum.KeyCode.None then
				if callback then
					task.spawn(callback, currentKey)
				end
			end
		end
	end)

	-- Handle binding state
	bindBtn.MouseButton1Click:Connect(function()
		if binding then return end
		binding = true
		updateBtnText()
		
		local connection
		connection = utils.UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				-- Accept key (except Escape to cancel/clear)
				if input.KeyCode == Enum.KeyCode.Escape then
					currentKey = Enum.KeyCode.None
				else
					currentKey = input.KeyCode
				end
				connection:Disconnect()
				binding = false
				updateBtnText()
				if callback then
					task.spawn(callback, currentKey)
				end
			end
		end)
	end)

	bindBtn.MouseEnter:Connect(function()
		if not binding then
			tween(bindBtn, { BackgroundColor3 = Color3.fromRGB(42, 42, 50) }, 0.12):Play()
		end
	end)

	bindBtn.MouseLeave:Connect(function()
		if not binding then
			tween(bindBtn, { BackgroundColor3 = Color3.fromRGB(32, 32, 38) }, 0.12):Play()
		end
	end)

	return {
		Set = function(_, key)
			currentKey = key
			updateBtnText()
		end,
		Get = function()
			return currentKey
		end,
		Destroy = function()
			if globalConnection then
				globalConnection:Disconnect()
			end
			row:Destroy()
		end
	}
end
