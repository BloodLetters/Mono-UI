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
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = utils.getGuiParent(),
	})

	local GuiService = game:GetService("GuiService")
	local updatingSelection = false
	local selectedConn
	selectedConn = GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
		if not screenGui or not screenGui.Parent then
			if selectedConn then selectedConn:Disconnect() end
			return
		end
		if updatingSelection then return end
		if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(screenGui) then
			updatingSelection = true
			GuiService.SelectedObject = nil
			updatingSelection = false
		end
	end)

	container = make("Frame", {
		Name = "HUDContainer",
		Position = UDim2.new(0.5, 0, 0, 40),
		AnchorPoint = Vector2.new(0.5, 0),
		Size = UDim2.fromOffset(120, 40),
		BackgroundColor3 = Color3.fromRGB(18, 18, 22),
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Parent = screenGui,
	})
	addCorner(container, 8)
	local stroke = addStroke(container, Color3.fromRGB(60, 60, 68), 0.6, 1)
	utils.registerTheme(stroke, "Color", "BorderColor")

	local hudScale = Instance.new("UIScale")
	hudScale.Name = "HUDScale"
	hudScale.Scale = 1
	hudScale.Parent = container

	local function updateHUDScale()
		local camera = utils.Workspace.CurrentCamera
		local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
		local scale = 1
		if viewport.X < 768 or viewport.Y < 480 then
			scale = math.clamp(math.min(viewport.X / 750, viewport.Y / 480), 0.65, 1)
		end
		hudScale.Scale = scale
	end

	updateHUDScale()
	if utils.Workspace.CurrentCamera then
		utils.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateHUDScale)
	end

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 6)
	layout.Parent = container

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 6)
	padding.PaddingRight = UDim.new(0, 6)
	padding.Parent = container

	connectDrag(container, container)

	return screenGui, container
end

function controlHUD.create(buttons)
	buttons = buttons or {}
	local _, hudContainer = getHUDGui()

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
	hudContainer.Size = UDim2.fromOffset(buttonCount * 36 + 12, 40)

	for i, btnArgs in ipairs(buttons) do
		local iconName = btnArgs.icon or "setting"
		local state = btnArgs.default == true
		local callback = btnArgs.callback

		local btn = make("TextButton", {
			Name = "Button_" .. i,
			Size = UDim2.fromOffset(30, 30),
			BackgroundColor3 = Color3.fromRGB(28, 28, 34),
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Parent = hudContainer,
		})
		addCorner(btn, 7)
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

			for _, child in ipairs(iconContainer:GetChildren()) do
				child:Destroy()
			end

			utils.createIcon(iconName, iconContainer, UDim2.fromOffset(16, 16), UDim2.fromOffset(7, 7), targetIcon)

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
					local camera = utils.Workspace.CurrentCamera
					local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)

					local rawX = startPos.X.Scale * viewport.X + startPos.X.Offset + delta.X
					local rawY = startPos.Y.Scale * viewport.Y + startPos.Y.Offset + delta.Y

					local absSize = hudContainer.AbsoluteSize
					local anchor = hudContainer.AnchorPoint

					local minX = absSize.X * anchor.X
					local maxX = viewport.X - absSize.X * (1 - anchor.X)
					local minY = absSize.Y * anchor.Y
					local maxY = viewport.Y - absSize.Y * (1 - anchor.Y)

					local clampedX = (maxX >= minX) and math.clamp(rawX, minX, maxX) or rawX
					local clampedY = (maxY >= minY) and math.clamp(rawY, minY, maxY) or rawY

					hudContainer.Position = UDim2.fromOffset(clampedX, clampedY)
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

		if callback and btnArgs.default ~= nil then
			task.spawn(callback, state)
		end

		table.insert(buttonsList, {
			btn = btn,
			btnStroke = btnStroke,
			iconContainer = iconContainer,
			iconName = iconName,
			conn1 = inputChangedConn,
			conn2 = inputEndedConn,
			getState = function() return state end,
			setState = function(val, fireCallback)
				state = val == true
				updateColors(true)
				if fireCallback ~= false and callback then
					task.spawn(callback, state)
				end
			end
		})
	end

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
