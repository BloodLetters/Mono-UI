local utils = require("./utils")
local Players = utils.Players
local Workspace = utils.Workspace
local monoFont = utils.monoFont
local getIcon = require("./lucide")
local getGuiParent = utils.getGuiParent
local make = utils.make
local addCorner = utils.addCorner
local addStroke = utils.addStroke
local applyFont = utils.applyFont
local tween = utils.tween
local connectDrag = utils.connectDrag
local getResponsiveWindowSize = utils.getResponsiveWindowSize
local notification = require("./notification")
local watermark = require("./watermark")
local controlHUD = require("./controlHUD")
local Janitor = require("../../Packages/janitor")

-- Components
local Toggle = require("../components/Toggle")
local Section = require("../components/Section")
local Input = require("../components/Input")
local Dropdown = require("../components/Dropdown")
local Button = require("../components/Button")
local ColorPicker = require("../components/ColorPicker")
local Slider = require("../components/Slider")
local TargetBody = require("../components/TargetBody")
local Keybind = require("../components/Keybind")
local Logger = require("../components/Logger")
local PlayerList = require("../components/PlayerList")

local function CreateWindow(options)
	options = options or {}
	local windowJanitor = Janitor.new()
	local normalSize = options.Size or getResponsiveWindowSize()
	local animatingIntro = true
	local preOpenedCallback = nil
	local closedCallback = nil
	local minimizedCallback = nil
	local isPreOpenedDone = false

	local autoSave = options.AutoSave ~= false
	local configName = options.ConfigName or "mono_config"
	local windowObject = nil
	
	local screenGui = make("ScreenGui", {
		Name = options.Name or "MonoWindow",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = options.DisplayOrder or 1000,
		Parent = getGuiParent(),
	})
	windowJanitor:Add(screenGui)
	windowJanitor:LinkToInstance(screenGui)
	
	local window = make("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = options.Position or UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(0, 0),
		Visible = true,
		ClipsDescendants = true,
		BackgroundColor3 = Color3.fromRGB(16, 16, 18),
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		Parent = screenGui,
	})
	
	task.defer(function()
		local t = utils.TweenService:Create(window, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = normalSize})
		t:Play()
	end)

	addCorner(window, 12)
	local windowStroke = addStroke(window, Color3.fromRGB(72, 72, 80), 0.3, 1)
	local topBar = make("Frame", {
		Name = "TopBar",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 48),
		Visible = false,
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
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = Color3.fromRGB(26, 26, 30),
		BorderSizePixel = 0,
		Text = "x",
		AutoButtonColor = false,
		Parent = topBar,
	})
	applyFont(closeButton, 16, Color3.fromRGB(220, 220, 220), Enum.TextXAlignment.Center)
	addCorner(closeButton, 8)
	closeButton.MouseEnter:Connect(function()
		tween(closeButton, {BackgroundColor3 = Color3.fromRGB(255, 60, 60)}, 0.2):Play()
	end)
	closeButton.MouseLeave:Connect(function()
		tween(closeButton, {BackgroundColor3 = Color3.fromRGB(26, 26, 30)}, 0.2):Play()
	end)

	local minimizeButton = make("TextButton", {
		Name = "Minimize",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -46, 0.5, 0),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = Color3.fromRGB(26, 26, 30),
		BorderSizePixel = 0,
		Text = "_",
		AutoButtonColor = false,
		Parent = topBar,
	})
	applyFont(minimizeButton, 16, Color3.fromRGB(220, 220, 220), Enum.TextXAlignment.Center)
	addCorner(minimizeButton, 8)
	minimizeButton.MouseEnter:Connect(function()
		tween(minimizeButton, {BackgroundColor3 = Color3.fromRGB(60, 60, 68)}, 0.2):Play()
	end)
	minimizeButton.MouseLeave:Connect(function()
		tween(minimizeButton, {BackgroundColor3 = Color3.fromRGB(26, 26, 30)}, 0.2):Play()
	end)

	local searchContainer = make("Frame", {
		Name = "SearchContainer",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -92, 0.5, 0),
		Size = UDim2.fromOffset(150, 32),
		BackgroundColor3 = Color3.fromRGB(24, 24, 28),
		BorderSizePixel = 0,
		Active = true,
		Parent = topBar,
	})
	addCorner(searchContainer, 8)
	addStroke(searchContainer, Color3.fromRGB(60, 60, 68), 0.6, 1)

	local searchIcon = make("Frame", {
		Name = "SearchIcon",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 8, 0.5, 0),
		Size = UDim2.fromOffset(18, 18),
		BackgroundTransparency = 1,
		Parent = searchContainer,
	})
	utils.createIcon("search", searchIcon, UDim2.fromOffset(16, 16), UDim2.fromOffset(1, 1), Color3.fromRGB(150, 150, 160))

	local searchBox = make("TextBox", {
		Name = "SearchBox",
		Position = UDim2.fromOffset(30, 0),
		Size = UDim2.new(1, -34, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = "Search...",
		PlaceholderColor3 = Color3.fromRGB(110, 110, 120),
		TextSize = 13,
		TextColor3 = Color3.fromRGB(230, 230, 235),
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Active = true,
		Selectable = true,
		Parent = searchContainer,
	})
	applyFont(searchBox, 13, Color3.fromRGB(230, 230, 235), Enum.TextXAlignment.Left)

	searchContainer.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			searchBox:CaptureFocus()
		end
	end)

	local function applySearch()
		local query = searchBox.Text:lower()
		local activeTab = windowObject.ActiveTab
		if not activeTab then return end
		
		for _, child in ipairs(activeTab.Page:GetChildren()) do
			if child:IsA("Frame") then
				local textLabel = child:FindFirstChildWhichIsA("TextLabel", true)
				local text = textLabel and textLabel.Text:lower() or ""
				local name = child.Name:lower()
				
				if query == "" or string.find(text, query, 1, true) or string.find(name, query, 1, true) then
					child.Visible = true
				else
					child.Visible = false
				end
			end
		end
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(applySearch)

	local content = make("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(12, 56),
		Size = UDim2.new(1, - 24, 1, - 68),
		BackgroundColor3 = Color3.fromRGB(20, 20, 24),
		BorderSizePixel = 0,
		Visible = false,
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
			local newSize = getResponsiveWindowSize()
			if animatingIntro then
				normalSize = newSize
			else
				window.Size = newSize
			end
		end
	end
	updateWindowSize()
	if Workspace.CurrentCamera then
		windowJanitor:Add(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateWindowSize))
	end

	task.defer(function()
		local introSize = UDim2.fromOffset(280, 140)
		
		local sizeTween1 = utils.tween(window, { Size = introSize }, 0.5)
		sizeTween1:Play()
		sizeTween1.Completed:Wait()
		
		local introFrame = make("Frame", {
			Name = "IntroFrame",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Parent = window,
		})
		
		local displayName = Players.LocalPlayer and (Players.LocalPlayer.DisplayName or Players.LocalPlayer.Name) or "User"
		local helloLabel = make("TextLabel", {
			Name = "HelloLabel",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 12),
			Size = UDim2.new(1, -24, 0, 20),
			BackgroundTransparency = 1,
			Text = "Hello, " .. displayName,
			TextTransparency = 1,
			Parent = introFrame,
		})
		applyFont(helloLabel, 16, Color3.fromRGB(242, 242, 242), Enum.TextXAlignment.Center)

		local loadingMessageLabel = make("TextLabel", {
			Name = "LoadingMessage",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 34),
			Size = UDim2.new(1, -24, 0, 16),
			BackgroundTransparency = 1,
			Text = "Loading components...",
			TextTransparency = 1,
			Parent = introFrame,
		})
		applyFont(loadingMessageLabel, 12, Color3.fromRGB(150, 150, 160), Enum.TextXAlignment.Center)
		
		local loaderImage = nil
		local ok, loaderAsset = pcall(getIcon, "loader-2")
		if ok and loaderAsset and loaderAsset.id then
			loaderImage = make("ImageLabel", {
				Name = "Loader",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, -24),
				Size = UDim2.fromOffset(36, 36),
				BackgroundTransparency = 1,
				Image = "rbxassetid://" .. loaderAsset.id,
				ImageRectOffset = loaderAsset.imageRectOffset,
				ImageRectSize = loaderAsset.imageRectSize,
				ImageColor3 = Color3.fromRGB(0, 162, 255), -- vibrant accent blue
				ImageTransparency = 1,
				Parent = introFrame,
			})
		end
		
		local fadeTween = utils.tween(helloLabel, { TextTransparency = 0 }, 0.4)
		fadeTween:Play()
		utils.tween(loadingMessageLabel, { TextTransparency = 0 }, 0.4):Play()
		if loaderImage then
			utils.tween(loaderImage, { ImageTransparency = 0 }, 0.4):Play()
		end
		
		local RunService = game:GetService("RunService")
		local spinConnection
		if loaderImage then
			spinConnection = RunService.RenderStepped:Connect(function(dt)
				loaderImage.Rotation = (loaderImage.Rotation + 240 * dt) % 360
			end)
		end
		
		if preOpenedCallback then
			local eventObj = {
				message = function(text)
					loadingMessageLabel.Text = tostring(text)
				end,
				done = function()
					isPreOpenedDone = true
				end
			}
			task.spawn(preOpenedCallback, eventObj)
			local elapsed = 0
			while not isPreOpenedDone and elapsed < 15 do
				task.wait()
				elapsed = elapsed + 0.03
			end
		else
			task.wait(1.8)
		end
		
		local fadeOutTween = utils.tween(helloLabel, { TextTransparency = 1 }, 0.4)
		fadeOutTween:Play()
		utils.tween(loadingMessageLabel, { TextTransparency = 1 }, 0.4):Play()
		if loaderImage then
			utils.tween(loaderImage, { ImageTransparency = 1 }, 0.4):Play()
		end
		
		task.wait(0.4)
		
		if spinConnection then
			spinConnection:Disconnect()
		end
		introFrame:Destroy()
		
		animatingIntro = false
		local sizeTween2 = utils.tween(window, { Size = normalSize }, 0.6)
		sizeTween2:Play()
		sizeTween2.Completed:Wait()
		
		topBar.Visible = true
		content.Visible = true
	end)
	windowObject = {
		ScreenGui = screenGui,
		Frame = window,
		Content = content,
		Tabs = {},
		ActiveTab = nil,
		Notify = notification.notify,
		SetWatermark = watermark.set,
		SetThemeColor = utils.setThemeColor,
		CreateControlHUD = controlHUD.create,
		Flags = {},
		Components = {},
		QueuedLogs = {},
		AutoSave = autoSave,
		ConfigName = configName,
	}

	function windowObject:QueueLog(level, message)
		table.insert(self.QueuedLogs, { level = level, message = message })
		if self.LoggerComponent then
			self.LoggerComponent:Log(level, message)
		end
	end

	local autoExec = options.AutoExec
	local autoExecUrl = options.AutoExecUrl
	if autoExec or autoExecUrl then
		local queue = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
		if queue then
			local code
			if autoExecUrl then
				if type(autoExecUrl) == "string" then
					code = string.format("loadstring(game:HttpGet('%s'))()", autoExecUrl)
				elseif type(autoExecUrl) == "table" then
					local url = autoExecUrl.Url or autoExecUrl.url or ""
					local method = autoExecUrl.Method or autoExecUrl.method or "GET"
					local headers = autoExecUrl.Headers or autoExecUrl.headers or {}
					local body = autoExecUrl.Body or autoExecUrl.body
					local HttpService = game:GetService("HttpService")
					local headersJson = HttpService:JSONEncode(headers)

					if body then
						code = string.format([[
local req = (syn and syn.request or http_request or request)({
    Url = %q,
    Method = %q,
    Headers = %s,
    Body = %q
})
if req.Success and req.Body then
    local fn, err = loadstring(req.Body)
    if fn then fn() else warn("[MonoUI] AutoExec chunk error:", err) end
end
]], url, method, headersJson, tostring(body))
					else
						code = string.format([[
local req = (syn and syn.request or http_request or request)({
    Url = %q,
    Method = %q,
    Headers = %s
})
if req.Success and req.Body then
    local fn, err = loadstring(req.Body)
    if fn then fn() else warn("[MonoUI] AutoExec chunk error:", err) end
end
]], url, method, headersJson)
					end
				end
			else
				code = type(autoExec) == "string" and autoExec or "loadstring(game:HttpGet('http://localhost:6767/demo'))()"
			end
			local Players = game:GetService("Players")
			local LocalPlayer = Players.LocalPlayer
			if LocalPlayer then
				windowJanitor:Add(LocalPlayer.OnTeleport:Connect(function(state)
					if state == Enum.TeleportState.Started or state == Enum.TeleportState.InProgress then
						pcall(queue, code)
					end
				end))
				windowObject:QueueLog("SUCCESS", "AutoExec registered successfully")
			end
		else
			warn("[MonoUI] AutoExec Not Supported")
			windowObject:QueueLog("ERROR", "AutoExec Not Supported by this executor.")
		end
	end

	function windowObject:SaveConfig(name)
		name = name or self.ConfigName or "mono_config"
		local HttpService = game:GetService("HttpService")
		local success, err = pcall(function()
			if writefile then
				writefile(name .. ".json", HttpService:JSONEncode(self.Flags))
			end
		end)
		return success, err
	end

	function windowObject:LoadConfig(name)
		name = name or self.ConfigName or "mono_config"
		local HttpService = game:GetService("HttpService")
		if not readfile or not isfile or not isfile(name .. ".json") then return false end
		
		local success, data = pcall(function()
			return HttpService:JSONDecode(readfile(name .. ".json"))
		end)
		
		if success and type(data) == "table" then
			for flag, value in pairs(data) do
				self.Flags[flag] = value
				local comp = self.Components[flag]
				if comp then
					pcall(function()
						comp:Set(value)
					end)
				end
			end
			return true
		end
		return false
	end
	
	windowObject.PreOpened = {
		done = function()
			isPreOpenedDone = true
		end
	}

	windowObject.event = {
		PreOpened = function(arg)
			if type(arg) == "function" then
				preOpenedCallback = arg
			elseif type(arg) == "table" then
				for _, v in pairs(arg) do
					if type(v) == "function" then
						preOpenedCallback = v
						break
					end
				end
			end
		end,
		Closed = function(arg)
			if type(arg) == "function" then
				closedCallback = arg
			elseif type(arg) == "table" then
				for _, v in pairs(arg) do
					if type(v) == "function" then
						closedCallback = v
						break
					end
				end
			end
		end,
		Minimized = function(arg)
			if type(arg) == "function" then
				minimizedCallback = arg
			elseif type(arg) == "table" then
				for _, v in pairs(arg) do
					if type(v) == "function" then
						minimizedCallback = v
						break
					end
				end
			end
		end,
	}
	local floatingButton = make("TextButton", {
		Name = "FloatingRestore",
		Visible = false,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 15),
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
		if searchBox then
			searchBox.Text = ""
		end
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
			tArgs = tArgs or {}
			local originalCallback = tArgs.callback
			if tArgs.flag then
				tArgs.callback = function(val)
					windowObject.Flags[tArgs.flag] = val
					if windowObject.AutoSave then
						windowObject:SaveConfig()
					end
					if originalCallback then
						originalCallback(val)
					end
				end
			end
			local comp = Toggle(self.Page, tArgs)
			if tArgs.flag then
				windowObject.Components[tArgs.flag] = comp
				if windowObject.Flags[tArgs.flag] ~= nil then
					comp:Set(windowObject.Flags[tArgs.flag])
				else
					windowObject.Flags[tArgs.flag] = comp:Get()
				end
			end
			return comp
		end
		
		function tab:CreateSection(sArgs)
			return Section(self.Page, sArgs)
		end
		
		function tab:CreateInput(iArgs)
			iArgs = iArgs or {}
			local originalCallback = iArgs.callback
			if iArgs.flag then
				iArgs.callback = function(val)
					windowObject.Flags[iArgs.flag] = val
					if windowObject.AutoSave then
						windowObject:SaveConfig()
					end
					if originalCallback then
						originalCallback(val)
					end
				end
			end
			local comp = Input(self.Page, iArgs)
			if iArgs.flag then
				windowObject.Components[iArgs.flag] = comp
				if windowObject.Flags[iArgs.flag] ~= nil then
					comp:Set(windowObject.Flags[iArgs.flag])
				else
					windowObject.Flags[iArgs.flag] = comp:Get()
				end
			end
			return comp
		end
		
		function tab:CreateDropdown(dArgs)
			dArgs = dArgs or {}
			local originalCallback = dArgs.callback
			if dArgs.flag then
				dArgs.callback = function(val)
					windowObject.Flags[dArgs.flag] = val
					if windowObject.AutoSave then
						windowObject:SaveConfig()
					end
					if originalCallback then
						originalCallback(val)
					end
				end
			end
			local comp = Dropdown(self.Page, dArgs)
			if dArgs.flag then
				windowObject.Components[dArgs.flag] = comp
				if windowObject.Flags[dArgs.flag] ~= nil then
					comp:Set(windowObject.Flags[dArgs.flag])
				else
					windowObject.Flags[dArgs.flag] = comp:Get()
				end
			end
			return comp
		end
		
		function tab:CreateButton(bArgs)
			return Button(self.Page, bArgs)
		end
		
		function tab:CreateColorPicker(cArgs)
			cArgs = cArgs or {}
			local originalCallback = cArgs.callback
			if cArgs.flag then
				cArgs.callback = function(color)
					windowObject.Flags[cArgs.flag] = { color.R, color.G, color.B }
					if windowObject.AutoSave then
						windowObject:SaveConfig()
					end
					if originalCallback then
						originalCallback(color)
					end
				end
			end
			local comp = ColorPicker(self.Page, windowObject.ScreenGui, cArgs)
			if cArgs.flag then
				windowObject.Components[cArgs.flag] = {
					Set = function(_, val)
						if type(val) == "table" and #val == 3 then
							comp:Set(Color3.new(val[1], val[2], val[3]))
						end
					end,
					Get = function()
						local color = comp:Get()
						return { color.R, color.G, color.B }
					end
				}
				if windowObject.Flags[cArgs.flag] ~= nil then
					local val = windowObject.Flags[cArgs.flag]
					comp:Set(Color3.new(val[1], val[2], val[3]))
				else
					local color = comp:Get()
					windowObject.Flags[cArgs.flag] = { color.R, color.G, color.B }
				end
			end
			return comp
		end
		
		function tab:CreateSlider(slArgs)
			slArgs = slArgs or {}
			local originalCallback = slArgs.callback
			if slArgs.flag then
				slArgs.callback = function(val)
					windowObject.Flags[slArgs.flag] = val
					if windowObject.AutoSave then
						windowObject:SaveConfig()
					end
					if originalCallback then
						originalCallback(val)
					end
				end
			end
			local comp = Slider(self.Page, slArgs)
			if slArgs.flag then
				windowObject.Components[slArgs.flag] = comp
				if windowObject.Flags[slArgs.flag] ~= nil then
					comp:Set(windowObject.Flags[slArgs.flag])
				else
					windowObject.Flags[slArgs.flag] = comp:Get()
				end
			end
			return comp
		end

		function tab:CreateTargetBody(tbArgs)
			tbArgs = tbArgs or {}
			local originalCallback = tbArgs.callback
			if tbArgs.flag then
				tbArgs.callback = function(parts)
					windowObject.Flags[tbArgs.flag] = parts
					if windowObject.AutoSave then
						windowObject:SaveConfig()
					end
					if originalCallback then
						originalCallback(parts)
					end
				end
			end
			local comp = TargetBody(self.Page, tbArgs)
			if tbArgs.flag then
				windowObject.Components[tbArgs.flag] = comp
				if windowObject.Flags[tbArgs.flag] ~= nil then
					comp:Set(windowObject.Flags[tbArgs.flag])
				else
					windowObject.Flags[tbArgs.flag] = comp:Get()
				end
			end
			return comp
		end

		function tab:CreateKeybind(kbArgs)
			kbArgs = kbArgs or {}
			local originalCallback = kbArgs.callback
			if kbArgs.flag then
				kbArgs.callback = function(key)
					windowObject.Flags[kbArgs.flag] = key.Name
					if windowObject.AutoSave then
						windowObject:SaveConfig()
					end
					if originalCallback then
						originalCallback(key)
					end
				end
			end
			local comp = Keybind(self.Page, kbArgs)
			if kbArgs.flag then
				windowObject.Components[kbArgs.flag] = {
					Set = function(_, keyName)
						pcall(function()
							comp:Set(Enum.KeyCode[keyName])
						end)
					end,
					Get = function()
						return comp:Get().Name
					end
				}
				if windowObject.Flags[kbArgs.flag] ~= nil then
					local keyName = windowObject.Flags[kbArgs.flag]
					pcall(function()
						comp:Set(Enum.KeyCode[keyName])
					end)
				else
					windowObject.Flags[kbArgs.flag] = comp:Get().Name
				end
			end
			return comp
		end

		function tab:CreateLogger(lgArgs)
			local comp = Logger(self.Page, lgArgs)
			windowObject.LoggerComponent = comp
			for _, item in ipairs(windowObject.QueuedLogs) do
				comp:Log(item.level, item.message)
			end
			windowObject.QueuedLogs = {}
			return comp
		end

		function tab:CreatePlayerList(plArgs)
			return PlayerList(self.Page, plArgs)
		end

		tabButton.Activated:Connect(function()
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
	windowJanitor:Add(function()
		pcall(function()
			watermark.set({ visible = false })
		end)
		pcall(function()
			controlHUD.setVisible(false)
		end)
		local CoreGui = game:GetService("CoreGui")
		local PlayerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
		for _, parent in ipairs({CoreGui, PlayerGui}) do
			if parent then
				local monoNotif = parent:FindFirstChild("MonoNotification")
				if monoNotif then
					pcall(function() monoNotif:Destroy() end)
				end
				local monoControl = parent:FindFirstChild("MonoControlHUD")
				if monoControl then
					pcall(function() monoControl:Destroy() end)
				end
			end
		end
	end)

	local function cleanUpAllScreens()
		windowJanitor:Destroy()
	end

	closeButton.Activated:Connect(function()
		cleanUpAllScreens()
		if closedCallback then
			task.spawn(closedCallback)
		end
	end)
	local function setMinimized(minimized)
		window.Visible = not minimized
		floatingButton.Visible = minimized
		if minimized and minimizedCallback then
			task.spawn(minimizedCallback)
		end
	end
	local floatingDragging = false
	local floatingDragStart
	local floatingStartPosition
	local floatingMoved = false
	windowJanitor:Add(floatingButton.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		floatingDragging = true
		floatingMoved = false
		floatingDragStart = input.Position
		floatingStartPosition = floatingButton.Position
	end))
	windowJanitor:Add(utils.UserInputService.InputChanged:Connect(function(input)
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
	end))
	windowJanitor:Add(utils.UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			floatingDragging = false
		end
	end))
	windowJanitor:Add(minimizeButton.Activated:Connect(function()
		setMinimized(true)
	end))
	windowJanitor:Add(floatingButton.Activated:Connect(function()
		if floatingMoved then
			floatingMoved = false
			return
		end
		setMinimized(false)
	end))
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
		cleanUpAllScreens()
	end
	function windowObject:SetVisible(value)
		screenGui.Enabled = value == true
		if value == true then
			setMinimized(false)
		end
	end

	task.spawn(function()
		task.wait(0.1)
		windowObject:LoadConfig()
	end)

	return windowObject
end

return {
	CreateWindow = CreateWindow
}
