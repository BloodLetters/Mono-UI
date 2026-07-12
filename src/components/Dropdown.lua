local utils = require("../core/utils")
local make = utils.make
local addCorner = utils.addCorner
local addStroke = utils.addStroke
local applyFont = utils.applyFont
local tween = utils.tween

return function(page, args)
	args = args or {}
	local dropdownText = args.text or "Dropdown"
	local optionList = args.list or {}
	local defaultValue = args.default
	local callback = args.callback
	local multiple = args.multiple == true
	
	local dropdownRow = make("Frame", {
		Name = dropdownText,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(24, 24, 28),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = page,
	})
	addCorner(dropdownRow, 10)
	addStroke(dropdownRow, Color3.fromRGB(60, 60, 68), 0.65, 1)
	
	local header = make("TextButton", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Parent = dropdownRow,
	})
	
	local isVBar = page.Name == "VBar"
	local labelWidthOffset = isVBar and -80 or -120
	local valueLabelWidth = isVBar and 50 or 90

	local label = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, labelWidthOffset, 1, 0),
		Text = tostring(dropdownText or "Dropdown"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})
	applyFont(label, 14, Color3.fromRGB(232, 232, 236), Enum.TextXAlignment.Left)
	
	local valueLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, - 30, 0.5, 0),
		Size = UDim2.fromOffset(valueLabelWidth, 18),
		Text = tostring(defaultValue or "select"),
		TextColor3 = Color3.fromRGB(155, 155, 165),
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = header,
	})
	applyFont(valueLabel, 13, Color3.fromRGB(155, 155, 165), Enum.TextXAlignment.Right)
	
	local arrow = make("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, - 12, 0.5, 0),
		Size = UDim2.fromOffset(12, 18),
		Text = ">",
		TextColor3 = Color3.fromRGB(155, 155, 165),
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = header,
	})
	applyFont(arrow, 13, Color3.fromRGB(155, 155, 165), Enum.TextXAlignment.Right)
	
	local DROPDOWN_MAX_HEIGHT = 160
	local listHolder = make("ScrollingFrame", {
		Name = "Options",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 40),
		Size = UDim2.new(1, 0, 0, 0),
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingEnabled = true,
		Active = true,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ClipsDescendants = true,
		Parent = dropdownRow,
	})
	
	local optionLayout = Instance.new("UIListLayout")
	optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	optionLayout.Padding = UDim.new(0, 6)
	optionLayout.Parent = listHolder
	
	local optionPadding = Instance.new("UIPadding")
	optionPadding.PaddingTop = UDim.new(0, 8)
	optionPadding.PaddingBottom = UDim.new(0, 12)
	optionPadding.PaddingLeft = UDim.new(0, 8)
	optionPadding.PaddingRight = UDim.new(0, 8)
	optionPadding.Parent = listHolder
	
	local options = optionList or {}
	local open = false
	local selectedMap = {}
	
	local function setSelected(value, enabled)
		selectedMap[value] = enabled and true or nil
	end
	
	if type(defaultValue) == "table" then
		for _, value in ipairs(defaultValue) do
			setSelected(value, true)
		end
	elseif defaultValue ~= nil then
		setSelected(defaultValue, true)
	elseif options[1] ~= nil then
		setSelected(options[1], true)
	end
	
	local function getSelectedList()
		local values = {}
		for _, option in ipairs(options) do
			if selectedMap[option] then
				table.insert(values, option)
			end
		end
		return values
	end
	
	local function updateValueLabel()
		local values = getSelectedList()
		if # values == 0 then
			valueLabel.Text = "select"
		elseif # values == 1 then
			valueLabel.Text = tostring(values[1])
		else
			valueLabel.Text = tostring(# values) .. " selected"
		end
	end
	
	local function updateOptionButton(optionButton, option)
		local selected = selectedMap[option] == true
		optionButton.BackgroundColor3 = selected and Color3.fromRGB(42, 42, 50) or Color3.fromRGB(26, 26, 32)
		optionButton.TextColor3 = selected and Color3.fromRGB(236, 236, 240) or Color3.fromRGB(228, 228, 232)
	end
	
	updateValueLabel()
	
	local function refreshHeight()
		if open then
			local optionArea = math.min(#options * 34 + 14, DROPDOWN_MAX_HEIGHT)
			dropdownRow.Size = UDim2.new(1, 0, 0, 40 + optionArea)
			listHolder.Size = UDim2.new(1, 0, 0, optionArea)
		else
			dropdownRow.Size = UDim2.new(1, 0, 0, 40)
		end
	end
	
	local function setOpen(value)
		open = value == true
		listHolder.Visible = open
		arrow.Text = open and "v" or ">"
		refreshHeight()
	end
	
	for index, option in ipairs(options) do
		local optionButton = make("TextButton", {
			Name = tostring(option),
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = Color3.fromRGB(26, 26, 32),
			BorderSizePixel = 0,
			Text = tostring(option),
			AutoButtonColor = false,
			LayoutOrder = index,
			Parent = listHolder,
		})
		addCorner(optionButton, 8)
		applyFont(optionButton, 14, Color3.fromRGB(228, 228, 232), Enum.TextXAlignment.Left)
		
		local optPad = Instance.new("UIPadding", optionButton)
		optPad.PaddingLeft = UDim.new(0, 12)
		optPad.PaddingRight = UDim.new(0, 8)
		updateOptionButton(optionButton, option)
		
		optionButton.MouseEnter:Connect(function()
			if not selectedMap[option] then
				tween(optionButton, {
					BackgroundColor3 = Color3.fromRGB(40, 40, 48)
				}, 0.12):Play()
			end
		end)
		
		optionButton.MouseLeave:Connect(function()
			if selectedMap[option] then
				tween(optionButton, {
					BackgroundColor3 = Color3.fromRGB(42, 42, 50)
				}, 0.12):Play()
			else
				tween(optionButton, {
					BackgroundColor3 = Color3.fromRGB(26, 26, 32)
				}, 0.12):Play()
			end
		end)
		
		optionButton.Activated:Connect(function()
			if multiple then
				selectedMap[option] = not selectedMap[option]
			else
				for k in pairs(selectedMap) do
					selectedMap[k] = nil
				end
				selectedMap[option] = true
			end
			updateValueLabel()
			for _, btn in ipairs(listHolder:GetChildren()) do
				if btn:IsA("TextButton") then
					updateOptionButton(btn, btn.Name)
				end
			end
			if callback then
				callback(getSelectedList())
			end
		end)
	end
	
	header.Activated:Connect(function()
		setOpen(not open)
	end)
	
	setOpen(false)
	refreshHeight()
	
	return {
		Set = function(_, value)
			selectedMap = {}
			if type(value) == "table" then
				for _, item in ipairs(value) do
					setSelected(item, true)
				end
			elseif value ~= nil then
				setSelected(value, true)
			end
			updateValueLabel()
			for _, optionButton in ipairs(listHolder:GetChildren()) do
				if optionButton:IsA("TextButton") then
					updateOptionButton(optionButton, optionButton.Name)
				end
			end
		end,
		Get = function()
			return getSelectedList()
		end,
	}
end
