local utils = require("./utils")
local Workspace = utils.Workspace
local monoFont = utils.monoFont
local getGuiParent = utils.getGuiParent
local make = utils.make
local addCorner = utils.addCorner
local addStroke = utils.addStroke
local applyFont = utils.applyFont
local tween = utils.tween
local connectDrag = utils.connectDrag
local getResponsiveWindowSize = utils.getResponsiveWindowSize

-- Components
local Toggle = require("../components/Toggle")
local Section = require("../components/Section")
local Input = require("../components/Input")
local Dropdown = require("../components/Dropdown")
local Button = require("../components/Button")
local ColorPicker = require("../components/ColorPicker")
local Slider = require("../components/Slider")

local function CreateWindow(options)
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
	local hasWindowIcon = options.Icon ~= nil and tostring(options.Icon) ~= ""
	if hasWindowIcon then
		local iconContainer = make("Frame", {
			Name = "IconContainer",
			Position = UDim2.fromOffset(16, 8),
			Size = UDim2.fromOffset(32, 32),
			BackgroundColor3 = Color3.fromRGB(24, 24, 28),
			BorderSizePixel = 0,
			Parent = topBar,
		})
		addCorner(iconContainer, 8)
		addStroke(iconContainer, Color3.fromRGB(64, 64, 72), 0.65, 1)

		utils.createIcon(options.Icon, iconContainer, UDim2.fromOffset(20, 20), UDim2.fromOffset(6, 6), Color3.fromRGB(242, 242, 242))
	end
	local title = make("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = hasWindowIcon and UDim2.fromOffset(60, 8) or UDim2.fromOffset(16, 8),
		Size = hasWindowIcon and UDim2.new(1, - 164, 0, 20) or UDim2.new(1, - 120, 0, 20),
		Text = options.Title or "mono window",
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topBar,
	})
	applyFont(title, 18, Color3.fromRGB(242, 242, 242), Enum.TextXAlignment.Left)
	local subtitle = make("TextLabel", {
		Name = "Subtitle",
		BackgroundTransparency = 1,
		Position = hasWindowIcon and UDim2.fromOffset(60, 28) or UDim2.fromOffset(16, 28),
		Size = hasWindowIcon and UDim2.new(1, - 164, 0, 12) or UDim2.new(1, - 120, 0, 12),
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
				Position = UDim2.fromOffset(8, 6),
				Size = UDim2.fromOffset(20, 20),
				BackgroundColor3 = Color3.fromRGB(28, 28, 32),
				BorderSizePixel = 0,
				Parent = tabButton,
			})
			addCorner(iconBadge, 7)
			addStroke(iconBadge, Color3.fromRGB(64, 64, 72), 0.65, 1)
			
			utils.createIcon(iconText, iconBadge, UDim2.fromOffset(14, 14), UDim2.fromOffset(3, 3), Color3.fromRGB(235, 235, 240))
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
		
		function tab:CreateToggle(tArgs)
			return Toggle(self.Page, tArgs)
		end
		
		function tab:CreateSection(sArgs)
			return Section(self.Page, sArgs)
		end
		
		function tab:CreateInput(iArgs)
			return Input(self.Page, iArgs)
		end
		
		function tab:CreateDropdown(dArgs)
			return Dropdown(self.Page, dArgs)
		end
		
		function tab:CreateButton(bArgs)
			return Button(self.Page, bArgs)
		end
		
		function tab:CreateColorPicker(cArgs)
			return ColorPicker(self.Page, windowObject.ScreenGui, cArgs)
		end
		
		function tab:CreateSlider(slArgs)
			return Slider(self.Page, slArgs)
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
	utils.UserInputService.InputChanged:Connect(function(input)
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
	utils.UserInputService.InputEnded:Connect(function(input)
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

return {
	CreateWindow = CreateWindow
}
