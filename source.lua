local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local monoFont = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
local function getGuiParent()
	if typeof(gethui) == "function" then
		local ok, result = pcall(gethui)
		if ok and result then
			return result
		end
	end
	return playerGui
end
local function tween(instance, properties, duration)
	local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	return TweenService:Create(instance, info, properties)
end
local function make(className, properties)
	local instance = Instance.new(className)
	for property, value in pairs(properties or {}) do
		instance[property] = value
	end
	return instance
end
local function addCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
	return corner
end
local function addStroke(instance, color, transparency, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Transparency = transparency
	stroke.Thickness = thickness
	stroke.Parent = instance
	return stroke
end
local function applyFont(instance, size, color, alignment)
	instance.FontFace = monoFont
	instance.TextSize = size
	instance.TextColor3 = color
	if alignment then
		instance.TextXAlignment = alignment
	end
end
local function setVisible(group, visible)
	for _, child in ipairs(group:GetChildren()) do
		if child:IsA("GuiObject") then
			child.Visible = visible
		end
	end
end
local function connectDrag(handle, target)
	local dragging = false
	local dragStart
	local startPosition
	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		dragging = true
		dragStart = input.Position
		startPosition = target.Position
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local delta = input.Position - dragStart
		target.Position = UDim2.new(
				startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end
local function getResponsiveWindowSize()
	local camera = Workspace.CurrentCamera
	if not camera then
		return UDim2.fromOffset(560, 360)
	end
	local viewport = camera.ViewportSize
	local width = math.clamp(math.floor(viewport.X * 0.46), 520, 780)
	local height = math.clamp(math.floor(viewport.Y * 0.48), 340, 560)
	return UDim2.fromOffset(width, height)
end
function CreateWindow(options)
	options = options or {}
	local screenGui = make("ScreenGui", {
		Name = options.Name or "MonoWindow",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = options.DisplayOrder or 1000,
		Parent = getGuiParent(),
	})
	local window = make("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = options.Position or UDim2.fromScale(0.5, 0.5),
		Size = options.Size or getResponsiveWindowSize(),
		BackgroundColor3 = Color3.fromRGB(16, 16, 18),
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		Parent = screenGui,
	})
	addCorner(window, 12)
	local windowStroke = addStroke(window, Color3.fromRGB(72, 72, 80), 0.3, 1)
	local topBar = make("Frame", {
		Name = "TopBar",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 48),
		Parent = window,
	})
	local title = make("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 8),
		Size = UDim2.new(1, - 120, 0, 20),
		Text = options.Title or "mono window",
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topBar,
	})
	applyFont(title, 18, Color3.fromRGB(242, 242, 242), Enum.TextXAlignment.Left)
	local subtitle = make("TextLabel", {
		Name = "Subtitle",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 28),
		Size = UDim2.new(1, - 120, 0, 12),
		Text = options.Subtitle or "minimal tabbed gui",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(155, 155, 165),
		TextSize = 12,
		FontFace = monoFont,
		Parent = topBar,
	})
	local closeButton = make("TextButton", {
		Name = "Close",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, - 12, 0, 12),
		Size = UDim2.fromOffset(24, 24),
		BackgroundColor3 = Color3.fromRGB(26, 26, 30),
		BorderSizePixel = 0,
		Text = "x",
		AutoButtonColor = false,
		Parent = topBar,
	})
	applyFont(closeButton, 16, Color3.fromRGB(220, 220, 220), Enum.TextXAlignment.Center)
	addCorner(closeButton, 7)
	local minimizeButton = make("TextButton", {
		Name = "Minimize",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, - 42, 0, 12),
		Size = UDim2.fromOffset(24, 24),
		BackgroundColor3 = Color3.fromRGB(26, 26, 30),
		BorderSizePixel = 0,
		Text = "_",
		AutoButtonColor = false,
		Parent = topBar,
	})
	applyFont(minimizeButton, 16, Color3.fromRGB(220, 220, 220), Enum.TextXAlignment.Center)
	addCorner(minimizeButton, 7)
	local content = make("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(12, 56),
		Size = UDim2.new(1, - 24, 1, - 68),
		BackgroundColor3 = Color3.fromRGB(20, 20, 24),
		BorderSizePixel = 0,
		Parent = window,
	})
	addCorner(content, 10)
	addStroke(content, Color3.fromRGB(52, 52, 60), 0.55, 1)
	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingTop = UDim.new(0, 2)
	contentPadding.PaddingBottom = UDim.new(0, 8)
	contentPadding.PaddingLeft = UDim.new(0, 4)
	contentPadding.PaddingRight = UDim.new(0, 4)
	contentPadding.Parent = content
	local layoutRoot = make("Frame", {
		Name = "LayoutRoot",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = content,
	})
	layoutRoot.ClipsDescendants = true
	layoutRoot.ZIndex = 1
	local sidebar = make("ScrollingFrame", {
		Name = "TabBar",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 120, 1, 0),
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingEnabled = true,
		Active = true,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ClipsDescendants = true,
		Parent = layoutRoot,
	})
	sidebar.ZIndex = 3
	local sidebarRight = make("Frame", {
		Name = "SidebarDivider",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, - 2, 0, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = Color3.fromRGB(45, 45, 52),
		BorderSizePixel = 0,
		Parent = sidebar,
	})
	sidebarRight.ZIndex = 4
	local tabList = make("Frame", {
		Name = "Tabs",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = sidebar,
	})
	tabList.ZIndex = 3
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Vertical
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Padding = UDim.new(0, 3)
	tabLayout.Parent = tabList
	
	local tabPadding = Instance.new("UIPadding")
	tabPadding.PaddingLeft = UDim.new(0, 2)
	tabPadding.PaddingRight = UDim.new(0, 4)
	tabPadding.PaddingTop = UDim.new(0, 6)
	tabPadding.PaddingBottom = UDim.new(0, 0)
	tabPadding.Parent = tabList
	
	local pageHolder = make("ScrollingFrame", {
		Name = "Pages",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(124, 0),
		Size = UDim2.new(1, - 124, 1, 0),
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingEnabled = true,
		Active = true,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ClipsDescendants = true,
		Parent = layoutRoot,
	})
	pageHolder.ZIndex = 1
	local function updateWindowSize()
		if options.Size == nil then
			window.Size = getResponsiveWindowSize()
		end
	end
	updateWindowSize()
	if Workspace.CurrentCamera then
		Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateWindowSize)
	end
	local windowObject = {
		ScreenGui = screenGui,
		Frame = window,
		Content = content,
		Tabs = {},
		ActiveTab = nil,
	}
	local floatingButton = make("TextButton", {
		Name = "FloatingRestore",
		Visible = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(36, 36),
		BackgroundColor3 = Color3.fromRGB(240, 240, 240),
		BorderSizePixel = 0,
		Text = "A",
		AutoButtonColor = false,
		Parent = screenGui,
	})
	addCorner(floatingButton, 12)
	addStroke(floatingButton, Color3.fromRGB(0, 0, 0), 0, 1)
	applyFont(floatingButton, 18, Color3.fromRGB(18, 18, 20), Enum.TextXAlignment.Center)
	local floatingLabel = floatingButton:FindFirstChildOfClass("TextLabel")
	if floatingLabel then
		floatingLabel:Destroy()
	end
	local function showTab(tab)
		for _, item in ipairs(windowObject.Tabs) do
			local active = item == tab
			item.Page.Visible = active
			item.Button.BackgroundColor3 = active and Color3.fromRGB(42, 42, 50) or Color3.fromRGB(22, 22, 26)
			if item.Button:FindFirstChildOfClass("UIStroke") then
				item.Button.UIStroke.Color = active and Color3.fromRGB(120, 120, 130) or Color3.fromRGB(52, 52, 60)
				item.Button.UIStroke.Transparency = active and 0 or 0.55
			end
		end
		windowObject.ActiveTab = tab
	end
	
	function windowObject:CreateTab(args)
		args = args or {}
		local tabText = args.text or "Tab"
		local iconText = args.icon
		local tabButton = make("TextButton", {
			Name = tabText,
			Size = UDim2.new(1, -6, 0, 32),
			BackgroundColor3 = Color3.fromRGB(22, 22, 26),
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
			Parent = tabList,
		})
		addCorner(tabButton, 8)
		addStroke(tabButton, Color3.fromRGB(52, 52, 60), 0.55, 1)
		local hasIcon = iconText ~= nil and tostring(iconText) ~= ""
		if hasIcon then
			local iconBadge = make("Frame", {
				Name = "IconBadge",
				Position = UDim2.fromOffset(8, 7),
				Size = UDim2.fromOffset(20, 20),
				BackgroundColor3 = Color3.fromRGB(28, 28, 32),
				BorderSizePixel = 0,
				Parent = tabButton,
			})
			addCorner(iconBadge, 7)
			addStroke(iconBadge, Color3.fromRGB(64, 64, 72), 0.65, 1)
			local iconLabel = make("TextLabel", {
				Name = "Icon",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Text = tostring(iconText),
				TextColor3 = Color3.fromRGB(235, 235, 240),
				TextSize = 10,
				TextWrapped = false,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = iconBadge,
			})
			applyFont(iconLabel, 10, Color3.fromRGB(235, 235, 240), Enum.TextXAlignment.Center)
		end
		local tabLabel = make("TextLabel", {
			Name = "Label",
			BackgroundTransparency = 1,
			Position = hasIcon and UDim2.fromOffset(34, 0) or UDim2.fromOffset(10, 0),
			Size = hasIcon and UDim2.new(1, - 40, 1, 0) or UDim2.new(1, - 20, 1, 0),
			Text = tostring(tabText),
			TextXAlignment = hasIcon and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
			Parent = tabButton,
		})
		applyFont(tabLabel, 14, Color3.fromRGB(236, 236, 240), hasIcon and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center)
		tabLabel.TextTruncate = Enum.TextTruncate.AtEnd
		local page = make("Frame", {
			Name = tostring(tabText) .. "Page",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = false,
			Parent = pageHolder,
		})
		local pageLayout = Instance.new("UIListLayout")
		pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		pageLayout.Padding = UDim.new(0, 8)
		pageLayout.Parent = page
		local pagePadding = Instance.new("UIPadding")
		pagePadding.PaddingTop = UDim.new(0, 2)
		pagePadding.PaddingBottom = UDim.new(0, 8)
		pagePadding.PaddingLeft = UDim.new(0, 4)
		pagePadding.PaddingRight = UDim.new(0, 4)
		pagePadding.Parent = page
		local tab = {
			Button = tabButton,
			Page = page,
		}
		function tab:CreateToggle(args)
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
		function tab:CreateSection(args)
			args = args or {}
			local sectionText = args.text
			local sectionRow = make("Frame", {
				Name = sectionText or "Section",
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				Parent = page,
			})
			local sectionLabel = make("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(4, 4),
				Size = UDim2.new(1, - 8, 0, 20),
				Text = string.upper(tostring(sectionText or "Section")),
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = sectionRow,
			})
			applyFont(sectionLabel, 20, Color3.fromRGB(255, 255, 255), Enum.TextXAlignment.Left)
			local sectionLine = make("Frame", {
				Name = "Divider",
				BackgroundColor3 = Color3.fromRGB(218, 218, 224),
				BackgroundTransparency = 0.3,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 4, 1, - 2),
				Size = UDim2.new(1, - 8, 0, 1),
				Parent = sectionRow,
			})
			return sectionRow
		end
		function tab:CreateInput(args)
			args = args or {}
			local inputText = args.text or "Input"
			local placeholderText = args.placeholder or "type here..."
			local callback = args.callback
            -- 1. Wadah utama input (Row)
            local inputRow = make("Frame", {
                Name = inputText or "Input",
                Size = UDim2.new(1, 0, 0, 44), -- Tinggi 44px agar proporsional dan lega
                BackgroundColor3 = Color3.fromRGB(24, 24, 28),
                BorderSizePixel = 0,
                Parent = page,
            })
            addCorner(inputRow, 10)
            local rowStroke = addStroke(inputRow, Color3.fromRGB(60, 60, 68), 0.65, 1)

            -- 2. Label Teks di sebelah kiri
            local label = make("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(14, 0),
                Size = UDim2.new(1, -170, 1, 0),
                Text = tostring(inputText or "Input"),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = inputRow,
            })
            applyFont(label, 14, Color3.fromRGB(232, 232, 236), Enum.TextXAlignment.Left)

            -- 3. Kotak Input (TextBox) dengan warna 22, 22, 26
            local textBox = make("TextBox", {
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
            addCorner(textBox, 8)
            local boxStroke = addStroke(textBox, Color3.fromRGB(52, 52, 60), 0.6, 1)
            applyFont(textBox, 13, Color3.fromRGB(235, 235, 240), Enum.TextXAlignment.Center)

            -- Memberikan padding internal agar teks ketikan tidak menempel ke pinggir kotak
            make("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = textBox
            })

            -- 4. Efek Interaktif (Visual Feedback saat diklik/ketik)
            textBox.Focused:Connect(function()
                -- Saat fokus, box sedikit menerang dan stroke menjadi lebih tegas
                tween(textBox, {BackgroundColor3 = Color3.fromRGB(28, 28, 34)}, 0.15):Play()
                tween(boxStroke, {Color = Color3.fromRGB(80, 80, 92), Transparency = 0.2}, 0.15):Play()
            end)

            textBox.FocusLost:Connect(function(enterPressed)
                -- Kembali ke warna dasar semula
                tween(textBox, {BackgroundColor3 = Color3.fromRGB(22, 22, 26)}, 0.15):Play()
                tween(boxStroke, {Color = Color3.fromRGB(52, 52, 60), Transparency = 0.6}, 0.15):Play()
                
                if callback then
                    callback(textBox.Text, enterPressed)
                end
            end)

            -- 5. Return Object
            return {
                Set = function(_, text)
                    textBox.Text = tostring(text)
                end,
                Get = function()
                    return textBox.Text
                end,
            }
        end
		function tab:CreateDropdown(args)
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
			local label = make("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, - 120, 1, 0),
				Text = tostring(dropdownText or "Dropdown"),
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = header,
			})
			applyFont(label, 14, Color3.fromRGB(232, 232, 236), Enum.TextXAlignment.Left)
			local valueLabel = make("TextLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, - 30, 0.5, 0),
				Size = UDim2.fromOffset(90, 18),
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
				optionButton.MouseButton1Click:Connect(function()
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
			header.MouseButton1Click:Connect(function()
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
		function tab:CreateButton(args)
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
				if callback then
					callback()
				end
			end)
			return actionButton
		end
		function tab:CreateColorPicker(args)
			args = args or {}
			local pickerText = args.text or "Color"
			local defaultColor = args.default or Color3.fromRGB(100, 100, 110)
			local callback = args.callback

			local function contrastColor(bg)
				local lum = 0.299 * bg.R + 0.587 * bg.G + 0.114 * bg.B
				return lum > 0.5 and Color3.fromRGB(18, 18, 20) or Color3.fromRGB(235, 235, 240)
			end

			local function colorToRGB255(c)
				return math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5)
			end

			local function hexFromColor(c)
				local r, g, b = colorToRGB255(c)
				return string.format("#%02X%02X%02X", r, g, b)
			end

			local currentColor = defaultColor

			-- === ROW UTAMA ===
			local pickerRow = make("Frame", {
				Name = (pickerText or "Color") .. "Row",
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = Color3.fromRGB(24, 24, 28),
				BorderSizePixel = 0,
				Parent = page,
			})
			addCorner(pickerRow, 10)
			addStroke(pickerRow, Color3.fromRGB(60, 60, 68), 0.65, 1)

			local label = make("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -140, 1, 0),
				Text = tostring(pickerText or "Color"),
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = pickerRow,
			})
			applyFont(label, 14, Color3.fromRGB(232, 232, 236), Enum.TextXAlignment.Left)

			local colorBox = make("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 0),
				Size = UDim2.fromOffset(100, 28),
				BackgroundColor3 = currentColor,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				Parent = pickerRow,
			})
			addCorner(colorBox, 7)
			addStroke(colorBox, Color3.fromRGB(80, 80, 90), 0.5, 1)

			local hexLabel = make("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Text = hexFromColor(currentColor),
				TextColor3 = contrastColor(currentColor),
				FontFace = monoFont,
				TextSize = 11,
				Parent = colorBox,
			})
			applyFont(hexLabel, 11, contrastColor(currentColor), Enum.TextXAlignment.Center)

			-- === FUNGSI UPDATE UI ===
			local function updateColorDisplay(col)
				currentColor = col
				colorBox.BackgroundColor3 = col
				hexLabel.Text = hexFromColor(col)
				hexLabel.TextColor3 = contrastColor(col)
			end

			local function fireCallback(col)
				if callback then
					callback(col)
				end
			end

			-- === POPUP STATE ===
			local pickerOpen = false
			local pickerPopup
			local popupBody
			local popupR, popupG, popupB
			local popupPreview, popupHexLabel
			local popupRSlider, popupGSlider, popupBSlider
			local popupRFill, popupGFill, popupBFill
			local popupRThumb, popupGThumb, popupBThumb
			local popupRLabel, popupGLabel, popupBLabel
			local popupDragging = false

			local function closePicker()
				if pickerPopup then
					pickerPopup:Destroy()
					pickerPopup = nil
					popupBody = nil
				end
				pickerOpen = false
				popupDragging = false
			end

			local function setSliderVisual(track, fill, thumb, valLabel, value, maxVal)
				local ratio = math.clamp(value / maxVal, 0, 1)
				local trackW = track.AbsoluteSize.X > 0 and track.AbsoluteSize.X or track.Size.X.Offset
				local pos = ratio * trackW
				fill.Size = UDim2.fromOffset(pos, 8)
				thumb.Position = UDim2.fromOffset(math.clamp(pos, 6, math.max(6, trackW - 6)), 4)
				valLabel.Text = tostring(math.floor(value))
			end

			local function getSliderValueFromMouse(track, inputX, maxVal)
				local trackPos = track.AbsolutePosition
				local trackW = track.AbsoluteSize.X > 0 and track.AbsoluteSize.X or track.Size.X.Offset
				local rel = math.clamp((inputX - trackPos.X) / trackW, 0, 1)
				return rel * maxVal
			end

			local function refreshPopupSliders()
				setSliderVisual(popupRSlider, popupRFill, popupRThumb, popupRLabel, popupR, 255)
				setSliderVisual(popupGSlider, popupGFill, popupGThumb, popupGLabel, popupG, 255)
				setSliderVisual(popupBSlider, popupBFill, popupBThumb, popupBLabel, popupB, 255)
				-- Update gradient pada masing-masing track
				local rGrad = popupRSlider:FindFirstChildOfClass("UIGradient")
				local gGrad = popupGSlider:FindFirstChildOfClass("UIGradient")
				local bGrad = popupBSlider:FindFirstChildOfClass("UIGradient")
				if rGrad then
					rGrad.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(0, popupG, popupB)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, popupG, popupB)),
					})
				end
				if gGrad then
					gGrad.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(popupR, 0, popupB)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(popupR, 255, popupB)),
					})
				end
				if bGrad then
					bGrad.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(popupR, popupG, 0)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(popupR, popupG, 255)),
					})
				end
			end

			local function applyPopupColor(r, g, b)
				popupR, popupG, popupB = math.clamp(math.floor(r), 0, 255), math.clamp(math.floor(g), 0, 255), math.clamp(math.floor(b), 0, 255)
				local col = Color3.fromRGB(popupR, popupG, popupB)
				popupPreview.BackgroundColor3 = col
				popupHexLabel.Text = string.format("#%02X%02X%02X", popupR, popupG, popupB)
				popupHexLabel.TextColor3 = contrastColor(col)
				refreshPopupSliders()
				updateColorDisplay(col)
				fireCallback(col)
			end

			-- === OPEN POPUP ===
			local function openPicker()
				if pickerOpen then
					closePicker()
					return
				end
				pickerOpen = true

				local absPos = colorBox.AbsolutePosition
				local absSize = colorBox.AbsoluteSize
				local screenSize = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)

				local popupWidth, popupHeight = 254, 200
				local popupX = math.clamp(absPos.X + absSize.X - popupWidth, 0, math.max(0, screenSize.X - popupWidth))
				local popupY = absPos.Y + absSize.Y + 6
				if popupY + popupHeight > screenSize.Y then
					popupY = absPos.Y - popupHeight - 6
				end
				popupY = math.clamp(popupY, 0, math.max(0, screenSize.Y - popupHeight))

				pickerPopup = make("Frame", {
					Name = "ColorPickerPopup",
					Position = UDim2.fromOffset(popupX, popupY),
					Size = UDim2.fromOffset(popupWidth, popupHeight),
					BackgroundColor3 = Color3.fromRGB(18, 18, 22),
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					ZIndex = 10000,
					Parent = screenGui,
				})
				addCorner(pickerPopup, 8)
				addStroke(pickerPopup, Color3.fromRGB(55, 55, 65), 0.4, 1)

				-- Body container dengan padding
				popupBody = make("Frame", {
					Name = "Body",
					Size = UDim2.new(1, -20, 1, -20),
					Position = UDim2.fromOffset(10, 10),
					BackgroundTransparency = 1,
					ZIndex = 10001,
					Parent = pickerPopup,
				})

				-- TITLE
				local popupTitle = make("TextLabel", {
					Name = "Title",
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(0, 0),
					Size = UDim2.fromOffset(100, 14),
					Text = "COLOR PICKER",
					TextColor3 = Color3.fromRGB(130, 130, 140),
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 10002,
					Parent = popupBody,
				})
				applyFont(popupTitle, 10, Color3.fromRGB(130, 130, 140), Enum.TextXAlignment.Left)

				-- PREVIEW (kanan atas)
				popupPreview = make("Frame", {
					Name = "Preview",
					Position = UDim2.fromOffset(182, 0),
					Size = UDim2.fromOffset(52, 52),
					BackgroundColor3 = currentColor,
					BorderSizePixel = 0,
					ZIndex = 10002,
					Parent = popupBody,
				})
				addCorner(popupPreview, 8)
				addStroke(popupPreview, Color3.fromRGB(80, 80, 90), 0.5, 1)

				popupHexLabel = make("TextLabel", {
					Name = "Hex",
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(182, 56),
					Size = UDim2.fromOffset(52, 16),
					Text = hexFromColor(currentColor),
					TextColor3 = Color3.fromRGB(170, 170, 180),
					TextXAlignment = Enum.TextXAlignment.Center,
					ZIndex = 10002,
					Parent = popupBody,
				})
				applyFont(popupHexLabel, 11, Color3.fromRGB(170, 170, 180), Enum.TextXAlignment.Center)

				-- === RGB SLIDERS SECTION ===
				-- R
				local rLabel = make("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(0, 24),
					Size = UDim2.fromOffset(14, 16),
					Text = "R",
					TextColor3 = Color3.fromRGB(255, 90, 90),
					ZIndex = 10002,
					Parent = popupBody,
				})
				applyFont(rLabel, 11, Color3.fromRGB(255, 90, 90), Enum.TextXAlignment.Center)

				popupRSlider = make("Frame", {
					Name = "RSlider",
					Position = UDim2.fromOffset(18, 28),
					Size = UDim2.fromOffset(110, 8),
					BackgroundColor3 = Color3.fromRGB(20, 20, 26),
					BorderSizePixel = 0,
					ZIndex = 10002,
					Parent = popupBody,
				})
				addCorner(popupRSlider, 4)
				local rGrad = Instance.new("UIGradient")
				rGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
				})
				rGrad.Parent = popupRSlider

				popupRFill = make("Frame", {
					Size = UDim2.fromOffset(0, 8),
					BackgroundColor3 = Color3.fromRGB(255, 90, 90),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex = 10003,
					Parent = popupRSlider,
				})
				addCorner(popupRFill, 4)

				popupRThumb = make("Frame", {
					Name = "RThumb",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromOffset(0, 4),
					Size = UDim2.fromOffset(12, 12),
					BackgroundColor3 = Color3.fromRGB(235, 235, 240),
					BorderSizePixel = 0,
					ZIndex = 10004,
					Parent = popupRSlider,
				})
				addCorner(popupRThumb, 6)

				popupRLabel = make("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(134, 24),
					Size = UDim2.fromOffset(34, 16),
					Text = "0",
					TextColor3 = Color3.fromRGB(170, 170, 180),
					TextXAlignment = Enum.TextXAlignment.Right,
					ZIndex = 10002,
					Parent = popupBody,
				})
				applyFont(popupRLabel, 11, Color3.fromRGB(170, 170, 180), Enum.TextXAlignment.Right)

				-- G
				local gLabel = make("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(0, 50),
					Size = UDim2.fromOffset(14, 16),
					Text = "G",
					TextColor3 = Color3.fromRGB(90, 255, 90),
					ZIndex = 10002,
					Parent = popupBody,
				})
				applyFont(gLabel, 11, Color3.fromRGB(90, 255, 90), Enum.TextXAlignment.Center)

				popupGSlider = make("Frame", {
					Name = "GSlider",
					Position = UDim2.fromOffset(18, 54),
					Size = UDim2.fromOffset(110, 8),
					BackgroundColor3 = Color3.fromRGB(20, 20, 26),
					BorderSizePixel = 0,
					ZIndex = 10002,
					Parent = popupBody,
				})
				addCorner(popupGSlider, 4)
				local gGrad = Instance.new("UIGradient")
				gGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 0)),
				})
				gGrad.Parent = popupGSlider

				popupGFill = make("Frame", {
					Size = UDim2.fromOffset(0, 8),
					BackgroundColor3 = Color3.fromRGB(90, 255, 90),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex = 10003,
					Parent = popupGSlider,
				})
				addCorner(popupGFill, 4)

				popupGThumb = make("Frame", {
					Name = "GThumb",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromOffset(0, 4),
					Size = UDim2.fromOffset(12, 12),
					BackgroundColor3 = Color3.fromRGB(235, 235, 240),
					BorderSizePixel = 0,
					ZIndex = 10004,
					Parent = popupGSlider,
				})
				addCorner(popupGThumb, 6)

				popupGLabel = make("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(134, 50),
					Size = UDim2.fromOffset(34, 16),
					Text = "0",
					TextColor3 = Color3.fromRGB(170, 170, 180),
					TextXAlignment = Enum.TextXAlignment.Right,
					ZIndex = 10002,
					Parent = popupBody,
				})
				applyFont(popupGLabel, 11, Color3.fromRGB(170, 170, 180), Enum.TextXAlignment.Right)

				-- B
				local bLabel = make("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(0, 76),
					Size = UDim2.fromOffset(14, 16),
					Text = "B",
					TextColor3 = Color3.fromRGB(90, 130, 255),
					ZIndex = 10002,
					Parent = popupBody,
				})
				applyFont(bLabel, 11, Color3.fromRGB(90, 130, 255), Enum.TextXAlignment.Center)

				popupBSlider = make("Frame", {
					Name = "BSlider",
					Position = UDim2.fromOffset(18, 80),
					Size = UDim2.fromOffset(110, 8),
					BackgroundColor3 = Color3.fromRGB(20, 20, 26),
					BorderSizePixel = 0,
					ZIndex = 10002,
					Parent = popupBody,
				})
				addCorner(popupBSlider, 4)
				local bGrad = Instance.new("UIGradient")
				bGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255)),
				})
				bGrad.Parent = popupBSlider

				popupBFill = make("Frame", {
					Size = UDim2.fromOffset(0, 8),
					BackgroundColor3 = Color3.fromRGB(90, 130, 255),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex = 10003,
					Parent = popupBSlider,
				})
				addCorner(popupBFill, 4)

				popupBThumb = make("Frame", {
					Name = "BThumb",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromOffset(0, 4),
					Size = UDim2.fromOffset(12, 12),
					BackgroundColor3 = Color3.fromRGB(235, 235, 240),
					BorderSizePixel = 0,
					ZIndex = 10004,
					Parent = popupBSlider,
				})
				addCorner(popupBThumb, 6)

				popupBLabel = make("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(134, 76),
					Size = UDim2.fromOffset(34, 16),
					Text = "0",
					TextColor3 = Color3.fromRGB(170, 170, 180),
					TextXAlignment = Enum.TextXAlignment.Right,
					ZIndex = 10002,
					Parent = popupBody,
				})
				applyFont(popupBLabel, 11, Color3.fromRGB(170, 170, 180), Enum.TextXAlignment.Right)

				-- === PRESETS ===
				local presetLabel = make("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(0, 104),
					Size = UDim2.fromOffset(100, 14),
					Text = "PRESETS",
					TextColor3 = Color3.fromRGB(130, 130, 140),
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 10002,
					Parent = popupBody,
				})
				applyFont(presetLabel, 10, Color3.fromRGB(130, 130, 140), Enum.TextXAlignment.Left)

				local presetGrid = make("Frame", {
					Name = "PresetGrid",
					Position = UDim2.fromOffset(0, 120),
					Size = UDim2.new(1, 0, 0, 54),
					BackgroundTransparency = 1,
					ZIndex = 10002,
					Parent = popupBody,
				})

				local presetGridLayout = Instance.new("UIGridLayout")
				presetGridLayout.CellSize = UDim2.fromOffset(34, 24)
				presetGridLayout.CellPadding = UDim2.fromOffset(6, 6)
				presetGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
				presetGridLayout.FillDirection = Enum.FillDirection.Horizontal
				presetGridLayout.Parent = presetGrid

				local presetColors = {
					Color3.fromRGB(235, 64, 52),
					Color3.fromRGB(235, 128, 52),
					Color3.fromRGB(235, 210, 52),
					Color3.fromRGB(82, 210, 52),
					Color3.fromRGB(52, 180, 235),
					Color3.fromRGB(52, 82, 235),
					Color3.fromRGB(160, 52, 235),
					Color3.fromRGB(235, 52, 140),
					Color3.fromRGB(255, 255, 255),
					Color3.fromRGB(180, 180, 180),
					Color3.fromRGB(100, 100, 100),
					Color3.fromRGB(18, 18, 20),
				}

				for idx, presetColor in ipairs(presetColors) do
					local capturedColor = presetColor
					local pr, pg, pb = colorToRGB255(capturedColor)

					local btn = make("TextButton", {
						BackgroundColor3 = capturedColor,
						BackgroundTransparency = 0,
						BorderSizePixel = 0,
						Text = "",
						AutoButtonColor = false,
						LayoutOrder = idx,
						ZIndex = 10003,
						Parent = presetGrid,
					})
					addCorner(btn, 5)
					addStroke(btn, Color3.fromRGB(52, 52, 60), 0.5, 1)

					btn.MouseButton1Click:Connect(function()
						applyPopupColor(pr, pg, pb)
					end)
				end

				-- Init
				popupR, popupG, popupB = colorToRGB255(currentColor)
				refreshPopupSliders()
			end

			-- === SLIDER DRAG (per slider) ===
			local function makeSliderDraggable(track, component)
				local draggingThis = false

				UserInputService.InputBegan:Connect(function(input)
					if not pickerOpen then return end
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
					local mp = Vector2.new(input.Position.X, input.Position.Y)
					local ap = track.AbsolutePosition
					local sz = track.AbsoluteSize
					if mp.X >= ap.X - 2 and mp.X <= ap.X + sz.X + 2 and mp.Y >= ap.Y - 12 and mp.Y <= ap.Y + sz.Y + 12 then
						draggingThis = true
						popupDragging = true
						local v = getSliderValueFromMouse(track, input.Position.X, 255)
						if component == "R" then popupR = v elseif component == "G" then popupG = v else popupB = v end
						applyPopupColor(popupR, popupG, popupB)
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if not draggingThis then return end
					local ut = input.UserInputType
					if ut == Enum.UserInputType.MouseMovement or ut == Enum.UserInputType.Touch then
						local v = getSliderValueFromMouse(track, input.Position.X, 255)
						if component == "R" then popupR = v elseif component == "G" then popupG = v else popupB = v end
						applyPopupColor(popupR, popupG, popupB)
					end
				end)

				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						draggingThis = false
						popupDragging = false
					end
				end)
			end

			-- === CLICK OUTSIDE TO CLOSE ===
			UserInputService.InputBegan:Connect(function(input)
				if not pickerOpen then return end
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
				if popupDragging then return end
				local mx, my = input.Position.X, input.Position.Y
				local px, py = pickerPopup.AbsolutePosition.X, pickerPopup.AbsolutePosition.Y
				local ps = pickerPopup.AbsoluteSize
				if mx < px or mx > px + ps.X or my < py or my > py + ps.Y then
					closePicker()
				end
			end)

			-- === OPEN ON CLICK ===
			colorBox.MouseButton1Click:Connect(function()
				local wasJustClosed = not pickerOpen
				openPicker()
				-- Perlu bind drag setelah popup dibuat
				if wasJustClosed and popupRSlider then
					makeSliderDraggable(popupRSlider, "R")
					makeSliderDraggable(popupGSlider, "G")
					makeSliderDraggable(popupBSlider, "B")
				end
			end)

			return {
				Set = function(_, color)
					updateColorDisplay(color)
				end,
				Get = function()
					return currentColor
				end,
			}
		end
		function tab:CreateSlider(args)
			args = args or {}
			local sliderText = args.text or "Slider"
			local min = args.min or 0
			local max = args.max or 100
			local defaultValue = args.default or min
			local callback = args.callback
			local sliderRow = make("Frame", {
				Name = sliderText .. "Row",
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = Color3.fromRGB(24, 24, 28),
				BorderSizePixel = 0,
				Parent = page,
			})
			addCorner(sliderRow, 10)
			addStroke(sliderRow, Color3.fromRGB(60, 60, 68), 0.65, 1)
			local label = make("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, - 140, 1, 0),
				Text = tostring(sliderText),
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = sliderRow,
			})
			applyFont(label, 14, Color3.fromRGB(232, 232, 236), Enum.TextXAlignment.Left)
			local valueLabel = make("TextLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, - 12, 0.5, 0),
				Size = UDim2.fromOffset(40, 18),
				Text = tostring(defaultValue),
				TextColor3 = Color3.fromRGB(155, 155, 165),
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = sliderRow,
			})
			applyFont(valueLabel, 13, Color3.fromRGB(155, 155, 165), Enum.TextXAlignment.Right)
			local trackHolder = make("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, - 64, 0.5, 0),
				Size = UDim2.fromOffset(80, 8),
				BackgroundColor3 = Color3.fromRGB(22, 22, 26),
				BorderSizePixel = 0,
				Parent = sliderRow,
			})
			addCorner(trackHolder, 4)
			local fill = make("Frame", {
				Size = UDim2.fromOffset(0, 8),
				BackgroundColor3 = Color3.fromRGB(100, 100, 110),
				BorderSizePixel = 0,
				Parent = trackHolder,
			})
			addCorner(fill, 4)
			local thumb = make("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(0, 4),
				Size = UDim2.fromOffset(14, 14),
				BackgroundColor3 = Color3.fromRGB(235, 235, 240),
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				Parent = trackHolder,
			})
			addCorner(thumb, 7)
			local currentValue = defaultValue
			local dragging = false
			local function clamp(v)
				return math.max(min, math.min(max, v))
			end
			local function setValue(value)
				value = clamp(value)
				currentValue = value
				local ratio = (value - min) / (max - min)
				local trackWidth = trackHolder.AbsoluteSize.X
				local thumbPos = ratio * trackWidth
				fill.Size = UDim2.fromOffset(math.max(0, thumbPos), 8)
				thumb.Position = UDim2.fromOffset(math.max(7, math.min(trackWidth - 7, thumbPos)), 4)
				valueLabel.Text = tostring(math.floor(value * 10) / 10)
				if callback then
					callback(value)
				end
			end
			local function getValueFromMouse(inputPos)
				local trackPos = trackHolder.AbsolutePosition
				local trackWidth = trackHolder.AbsoluteSize.X
				local relativeX = inputPos.X - trackPos.X
				local ratio = math.clamp(relativeX / trackWidth, 0, 1)
				return min + ratio * (max - min)
			end
			thumb.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if not dragging then
					return
				end
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					setValue(getValueFromMouse(input.Position))
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			trackHolder.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					setValue(getValueFromMouse(input.Position))
				end
			end)
			task.wait()
			setValue(clamp(defaultValue))
			return {
				Set = function(_, value)
					setValue(clamp(value))
				end,
				Get = function()
					return currentValue
				end,
			}
		end
		tabButton.MouseButton1Click:Connect(function()
			showTab(tab)
		end)
		tabButton.MouseEnter:Connect(function()
			if windowObject.ActiveTab ~= tab then
				tween(tabButton, {
					BackgroundColor3 = Color3.fromRGB(32, 32, 38)
				}, 0.12):Play()
			end
		end)
		tabButton.MouseLeave:Connect(function()
			if windowObject.ActiveTab ~= tab then
				tween(tabButton, {
					BackgroundColor3 = Color3.fromRGB(22, 22, 26)
				}, 0.12):Play()
			end
		end)
		table.insert(windowObject.Tabs, tab)
		if not windowObject.ActiveTab then
			showTab(tab)
		end
		return tab
	end
	closeButton.MouseButton1Click:Connect(function()
		screenGui.Enabled = false
	end)
	local function setMinimized(minimized)
		window.Visible = not minimized
		floatingButton.Visible = minimized
	end
	local floatingDragging = false
	local floatingDragStart
	local floatingStartPosition
	local floatingMoved = false
	floatingButton.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		floatingDragging = true
		floatingMoved = false
		floatingDragStart = input.Position
		floatingStartPosition = floatingButton.Position
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not floatingDragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local delta = input.Position - floatingDragStart
		if delta.Magnitude > 3 then
			floatingMoved = true
		end
		floatingButton.Position = UDim2.new(
				floatingStartPosition.X.Scale, floatingStartPosition.X.Offset + delta.X, floatingStartPosition.Y.Scale, floatingStartPosition.Y.Offset + delta.Y)
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			floatingDragging = false
		end
	end)
	minimizeButton.MouseButton1Click:Connect(function()
		setMinimized(true)
	end)
	floatingButton.MouseButton1Click:Connect(function()
		if floatingMoved then
			floatingMoved = false
			return
		end
		setMinimized(false)
	end)
	connectDrag(topBar, window)
	window.BackgroundTransparency = 1
	windowStroke.Transparency = 1
	task.defer(function()
		tween(window, {
			BackgroundTransparency = 0.03
		}, 0.18):Play()
		tween(windowStroke, {
			Transparency = 0.3
		}, 0.18):Play()
	end)
	function windowObject:Destroy()
		screenGui:Destroy()
	end
	function windowObject:SetVisible(value)
		screenGui.Enabled = value == true
		if value == true then
			setMinimized(false)
		end
	end
	return windowObject
end

local window = CreateWindow({
	Title = "mono ui",
	Subtitle = "tabbed minimal gui",
	Size = UDim2.fromOffset(580, 380),
})

local tab1 = window:CreateTab({
	text = "example tab"
})
tab1:CreateSection({
	text = "Combat"
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