local utils = require("../core/utils")
local make = utils.make
local addCorner = utils.addCorner
local addStroke = utils.addStroke
local applyFont = utils.applyFont
local tween = utils.tween

return function(page, args)
	args = args or {}
	local isVBar = page.Name == "VBar"
	local titleText = args.text or "Target Body Parts"
	local isMultiple = args.multiple ~= false
	local callback = args.callback
	
	local disabled = {}
	if type(args.disabledParts) == "table" then
		for _, part in ipairs(args.disabledParts) do
			disabled[part] = true
		end
	elseif type(args.disabledParts) == "string" then
		disabled[args.disabledParts] = true
	end

	local selected = {}
	if type(args.default) == "table" then
		for _, part in ipairs(args.default) do
			if not disabled[part] then
				selected[part] = true
			end
		end
	elseif type(args.default) == "string" then
		if not disabled[args.default] then
			selected[args.default] = true
		end
	end

	local container = make("Frame", {
		Name = "TargetBodyContainer",
		Size = UDim2.new(1, 0, 0, 240),
		BackgroundColor3 = Color3.fromRGB(24, 24, 28),
		BorderSizePixel = 0,
		Parent = page,
	})
	addCorner(container, 10)
	addStroke(container, Color3.fromRGB(60, 60, 68), 0.65, 1)

	local titleLabel = make("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 10),
		Size = UDim2.new(1, -28, 0, 20),
		Text = tostring(titleText),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container,
	})
	applyFont(titleLabel, 14, Color3.fromRGB(232, 232, 236), Enum.TextXAlignment.Left)

	local bodyFrame = make("Frame", {
		Name = "BodyFrame",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = isVBar and UDim2.new(0.5, 0, 0, 42) or UDim2.new(0.25, 0, 0, 42),
		Size = UDim2.fromOffset(160, 180),
		BackgroundTransparency = 1,
		Parent = container,
	})

	local parts = {
		{ name = "Head", label = "H", size = UDim2.fromOffset(36, 36), pos = UDim2.new(0.5, -18, 0, 10) },
		{ name = "Torso", label = "T", size = UDim2.fromOffset(56, 56), pos = UDim2.new(0.5, -28, 0, 50) },
		{ name = "LeftArm", label = "LA", size = UDim2.fromOffset(24, 56), pos = UDim2.new(0.5, -56, 0, 50) },
		{ name = "RightArm", label = "RA", size = UDim2.fromOffset(24, 56), pos = UDim2.new(0.5, 32, 0, 50) },
		{ name = "LeftLeg", label = "LL", size = UDim2.fromOffset(26, 56), pos = UDim2.new(0.5, -28, 0, 110) },
		{ name = "RightLeg", label = "RL", size = UDim2.fromOffset(26, 56), pos = UDim2.new(0.5, 2, 0, 110) },
	}

	local partButtons = {}

	local function getSelectedList()
		local list = {}
		for name, state in pairs(selected) do
			if state then
				table.insert(list, name)
			end
		end
		return list
	end

	local listHolder = make("Frame", {
		Name = "SelectedList",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.75, 0, 0, 42),
		Size = UDim2.new(0.5, -40, 0, 180),
		BackgroundTransparency = 1,
		Visible = not isVBar,
		Parent = container,
	})

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.Name
	listLayout.Padding = UDim.new(0, 6)
	listLayout.Parent = listHolder

	local function updateSelectedList()
		if isVBar then return end
		for _, child in ipairs(listHolder:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end

		local activeParts = getSelectedList()
		table.sort(activeParts)

		if #activeParts == 0 then
			local noSelectionFrame = make("Frame", {
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundTransparency = 1,
				Parent = listHolder,
			})
			local lbl = make("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "No parts selected",
				Parent = noSelectionFrame,
			})
			applyFont(lbl, 13, Color3.fromRGB(110, 110, 120), Enum.TextXAlignment.Left)
		else
			for _, partName in ipairs(activeParts) do
				local displayName = partName
				if partName == "LeftArm" then displayName = "Left Arm"
				elseif partName == "RightArm" then displayName = "Right Arm"
				elseif partName == "LeftLeg" then displayName = "Left Leg"
				elseif partName == "RightLeg" then displayName = "Right Leg"
				end

				local itemRow = make("Frame", {
					Name = partName,
					Size = UDim2.new(1, 0, 0, 24),
					BackgroundTransparency = 1,
					Parent = listHolder,
				})

				local dot = make("Frame", {
					Size = UDim2.fromOffset(8, 8),
					Position = UDim2.new(0, 4, 0.5, -4),
					BorderSizePixel = 0,
					Parent = itemRow,
				})
				addCorner(dot, 4)
				utils.registerTheme(dot, "BackgroundColor3", "AccentColor")

				local lbl = make("TextLabel", {
					Position = UDim2.fromOffset(20, 0),
					Size = UDim2.new(1, -20, 1, 0),
					BackgroundTransparency = 1,
					Text = displayName,
					Parent = itemRow,
				})
				applyFont(lbl, 13, Color3.fromRGB(220, 220, 225), Enum.TextXAlignment.Left)
			end
		end
	end

	local function updatePartVisual(name)
		local btn = partButtons[name]
		if not btn then return end
		
		if disabled[name] then
			local targetColor = Color3.fromRGB(80, 20, 20) -- dark red background
			local targetStrokeColor = Color3.fromRGB(180, 30, 30) -- red outline
			local targetTextColor = Color3.fromRGB(240, 100, 100) -- light red text
			
			btn.BackgroundColor3 = targetColor
			if btn:FindFirstChildOfClass("UIStroke") then
				btn.UIStroke.Color = targetStrokeColor
			end
			local label = btn:FindFirstChildOfClass("TextLabel")
			if label then
				label.TextColor3 = targetTextColor
			end
			return
		end

		local isSelected = selected[name]
		local targetColor = isSelected and utils.theme.AccentColor or Color3.fromRGB(32, 32, 38)
		local targetStrokeColor = isSelected and utils.theme.AccentColor or Color3.fromRGB(60, 60, 68)
		local targetTextColor = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 170)
		
		tween(btn, { BackgroundColor3 = targetColor }, 0.15):Play()
		if btn:FindFirstChildOfClass("UIStroke") then
			tween(btn.UIStroke, { Color = targetStrokeColor }, 0.15):Play()
		end
		local label = btn:FindFirstChildOfClass("TextLabel")
		if label then
			tween(label, { TextColor3 = targetTextColor }, 0.15):Play()
		end
	end

	local function togglePart(name)
		if disabled[name] then return end
		
		if isMultiple then
			selected[name] = not selected[name]
		else
			for k in pairs(selected) do
				selected[k] = nil
			end
			selected[name] = true
		end

		for partName in pairs(partButtons) do
			updatePartVisual(partName)
		end

		updateSelectedList()

		if callback then
			task.spawn(callback, getSelectedList())
		end
	end

	for _, pInfo in ipairs(parts) do
		local partBtn = make("TextButton", {
			Name = pInfo.name,
			Position = pInfo.pos,
			Size = pInfo.size,
			BackgroundColor3 = Color3.fromRGB(32, 32, 38),
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
			Parent = bodyFrame,
		})
		addCorner(partBtn, 5)
		addStroke(partBtn, Color3.fromRGB(60, 60, 68), 0.65, 1)

		local partLabel = make("TextLabel", {
			Name = "Label",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = pInfo.label,
			Parent = partBtn,
		})
		applyFont(partLabel, 10, Color3.fromRGB(160, 160, 170), Enum.TextXAlignment.Center)

		partButtons[pInfo.name] = partBtn
		updatePartVisual(pInfo.name)

		partBtn.Activated:Connect(function()
			togglePart(pInfo.name)
		end)

		partBtn.MouseEnter:Connect(function()
			if not disabled[pInfo.name] and not selected[pInfo.name] then
				tween(partBtn, { BackgroundColor3 = Color3.fromRGB(42, 42, 50) }, 0.12):Play()
			end
		end)

		partBtn.MouseLeave:Connect(function()
			if not disabled[pInfo.name] and not selected[pInfo.name] then
				tween(partBtn, { BackgroundColor3 = Color3.fromRGB(32, 32, 38) }, 0.12):Play()
			end
		end)
	end

	utils.onThemeChanged(function(key, color)
		if key == "AccentColor" then
			for partName in pairs(partButtons) do
				updatePartVisual(partName)
			end
		end
	end)

	updateSelectedList()

	local customObject = {
		Set = function(_, list)
			selected = {}
			if type(list) == "table" then
				for _, part in ipairs(list) do
					if not disabled[part] then
						selected[part] = true
					end
				end
			elseif type(list) == "string" then
				if not disabled[list] then
					selected[list] = true
				end
			end
			for partName in pairs(partButtons) do
				updatePartVisual(partName)
			end
			updateSelectedList()
		end,
		Get = function()
			return getSelectedList()
		end
	}

	return customObject
end
