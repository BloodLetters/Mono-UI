local utils = require("./utils")
local make = utils.make
local addCorner = utils.addCorner
local addStroke = utils.addStroke
local applyFont = utils.applyFont
local tween = utils.tween
local connectDrag = utils.connectDrag

local controlHUD = {}
local screenGui = nil
local container = nil
local buttonsList = {}

local function getHUDGui()
	if screenGui and screenGui.Parent then
		return screenGui, container
	end

	screenGui = make("ScreenGui", {
		Name = "MonoControlHUD",
		ResetOnSpawn = false,
		DisplayOrder = 99996,
		Parent = utils.getGuiParent(),
	})

	container = make("Frame", {
		Name = "HUDContainer",
		Position = UDim2.new(0.5, -60, 0, 70),
		Size = UDim2.fromOffset(120, 48),
		BackgroundColor3 = Color3.fromRGB(18, 18, 22),
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Parent = screenGui,
	})
	addCorner(container, 10)
	local stroke = addStroke(container, Color3.fromRGB(60, 60, 68), 0.6, 1)
	utils.registerTheme(stroke, "Color", "BorderColor")

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 8)
	layout.Parent = container

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = container

	-- Make it draggable
	connectDrag(container, container)

	return screenGui, container
end

function controlHUD.create(buttons)
	buttons = buttons or {}
	local _, hudContainer = getHUDGui()

	-- Clear old elements and disconnect listeners
	for _, item in ipairs(buttonsList) do
		if item.conn1 then item.conn1:Disconnect() end
		if item.conn2 then item.conn2:Disconnect() end
	end
	for _, child in ipairs(hudContainer:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	buttonsList = {}

	local buttonCount = #buttons
	hudContainer.Size = UDim2.fromOffset(buttonCount * 42 + 16, 48)

	for i, btnArgs in ipairs(buttons) do
		local iconName = btnArgs.icon or "setting"
		local state = btnArgs.default == true
		local callback = btnArgs.callback

		local btn = make("TextButton", {
			Name = "Button_" .. i,
			Size = UDim2.fromOffset(34, 34),
			BackgroundColor3 = Color3.fromRGB(28, 28, 34),
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Parent = hudContainer,
		})
		addCorner(btn, 8)
		local btnStroke = addStroke(btn, Color3.fromRGB(50, 50, 58), 0.5, 1)

		local iconContainer = make("Frame", {
			Name = "IconContainer",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Parent = btn,
		})

		local function updateColors(animate)
			local targetBg, targetStroke, targetIcon
			if state then
				targetBg = utils.theme.AccentColor
				targetStroke = utils.theme.AccentColor
				targetIcon = Color3.fromRGB(255, 255, 255)
			else
				targetBg = Color3.fromRGB(28, 28, 34)
				targetStroke = Color3.fromRGB(50, 50, 58)
				targetIcon = Color3.fromRGB(140, 140, 150)
			end

			-- Clear old icon
			for _, child in ipairs(iconContainer:GetChildren()) do
				child:Destroy()
			end

			-- Redraw icon
			utils.createIcon(iconName, iconContainer, UDim2.fromOffset(18, 18), UDim2.fromOffset(8, 8), targetIcon)

			if animate then
				tween(btn, { BackgroundColor3 = targetBg }, 0.12):Play()
				tween(btnStroke, { Color = targetStroke }, 0.12):Play()
			else
				btn.BackgroundColor3 = targetBg
				btnStroke.Color = targetStroke
			end
		end

		local dragStartPos = nil
		local startPos = nil
		local dragging = false
		local dragMoved = false

		btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragStartPos = input.Position
				startPos = hudContainer.Position
				dragging = true
				dragMoved = false
			end
		end)

		local inputChangedConn = utils.UserInputService.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local delta = input.Position - dragStartPos
				if delta.Magnitude > 4 then
					dragMoved = true
					hudContainer.Position = UDim2.new(
						startPos.X.Scale, startPos.X.Offset + delta.X,
						startPos.Y.Scale, startPos.Y.Offset + delta.Y
					)
				end
			end
		end)

		local inputEndedConn = utils.UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if dragging then
					dragging = false
					if not dragMoved then
						state = not state
						updateColors(true)
						if callback then
							task.spawn(callback, state)
						end
					end
				end
			end
		end)

		updateColors(false)

		table.insert(buttonsList, {
			btn = btn,
			btnStroke = btnStroke,
			iconContainer = iconContainer,
			iconName = iconName,
			conn1 = inputChangedConn,
			conn2 = inputEndedConn,
			getState = function() return state end,
			setState = function(val)
				state = val == true
				updateColors(true)
			end
		})
	end

	-- Connect to theme color changes to refresh active buttons
	local themeConn
	themeConn = utils.onThemeChanged(function(key, color)
		if key == "AccentColor" then
			for _, item in ipairs(buttonsList) do
				if item.getState() then
					item.btn.BackgroundColor3 = color
					item.btnStroke.Color = color
				end
			end
		end
	end)
end

function controlHUD.setVisible(visible)
	local sg = getHUDGui()
	sg.Enabled = visible
end

return controlHUD
