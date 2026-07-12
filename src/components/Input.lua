local utils = require("../core/utils")
local make = utils.make
local addCorner = utils.addCorner
local addStroke = utils.addStroke
local applyFont = utils.applyFont
local tween = utils.tween

return function(page, args)
	args = args or {}
	local inputText = args.text or "Input"
	local placeholderText = args.placeholder or "type here..."
	local callback = args.callback
	
	local isVBar = page.Name == "VBar"
	local rowHeight = isVBar and 60 or 44

	local inputRow = make("Frame", {
		Name = inputText or "Input",
		Size = UDim2.new(1, 0, 0, rowHeight), -- Height
		BackgroundColor3 = Color3.fromRGB(24, 24, 28),
		BorderSizePixel = 0,
		Parent = page,
	})
	addCorner(inputRow, 10)
	local rowStroke = addStroke(inputRow, Color3.fromRGB(60, 60, 68), 0.65, 1)

	local label
	local textBox

	if isVBar then
		label = make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 6),
			Size = UDim2.new(1, -28, 0, 18),
			Text = tostring(inputText or "Input"),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = inputRow,
		})
		applyFont(label, 14, Color3.fromRGB(232, 232, 236), Enum.TextXAlignment.Left)

		textBox = make("TextBox", {
			Name = "InputField",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 28),
			Size = UDim2.new(1, -24, 0, 26),
			BackgroundColor3 = Color3.fromRGB(22, 22, 26),
			BorderSizePixel = 0,
			Text = tostring(args.default or ""),
			PlaceholderText = tostring(placeholderText),
			PlaceholderColor3 = Color3.fromRGB(100, 100, 110),
			TextColor3 = Color3.fromRGB(235, 235, 240),
			TextSize = 13,
			ClipsDescendants = true,
			Parent = inputRow,
		})
	else
		label = make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -170, 1, 0),
			Text = tostring(inputText or "Input"),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = inputRow,
		})
		applyFont(label, 14, Color3.fromRGB(232, 232, 236), Enum.TextXAlignment.Left)

		textBox = make("TextBox", {
			Name = "InputField",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(140, 26),
			BackgroundColor3 = Color3.fromRGB(22, 22, 26),
			BorderSizePixel = 0,
			Text = tostring(args.default or ""),
			PlaceholderText = tostring(placeholderText),
			PlaceholderColor3 = Color3.fromRGB(100, 100, 110),
			TextColor3 = Color3.fromRGB(235, 235, 240),
			TextSize = 13,
			ClipsDescendants = true,
			Parent = inputRow,
		})
	end

	addCorner(textBox, 8)
	local boxStroke = addStroke(textBox, Color3.fromRGB(52, 52, 60), 0.6, 1)
	applyFont(textBox, 13, Color3.fromRGB(235, 235, 240), Enum.TextXAlignment.Center)

	make("UIPadding", {
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		Parent = textBox
	})

	textBox.Focused:Connect(function()
		tween(textBox, {BackgroundColor3 = Color3.fromRGB(28, 28, 34)}, 0.15):Play()
		tween(boxStroke, {Color = Color3.fromRGB(80, 80, 92), Transparency = 0.2}, 0.15):Play()
	end)

	textBox.FocusLost:Connect(function(enterPressed)
		tween(textBox, {BackgroundColor3 = Color3.fromRGB(22, 22, 26)}, 0.15):Play()
		tween(boxStroke, {Color = Color3.fromRGB(52, 52, 60), Transparency = 0.6}, 0.15):Play()
		
		if callback then
			callback(textBox.Text, enterPressed)
		end
	end)

	return {
		Set = function(_, text)
			textBox.Text = tostring(text)
		end,
		Get = function()
			return textBox.Text
		end,
	}
end
