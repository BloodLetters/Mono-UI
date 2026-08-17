local utils = require("./utils")
local make = utils.make
local addCorner = utils.addCorner
local addStroke = utils.addStroke
local applyFont = utils.applyFont
local tween = utils.tween

local popup = {}

local STATE_CONFIGS = {
	warning = {
		color = Color3.fromRGB(245, 158, 11),
		icon = "alert-triangle",
	},
	error = {
		color = Color3.fromRGB(239, 68, 68),
		icon = "alert-circle",
	},
	information = {
		color = Color3.fromRGB(59, 130, 246),
		icon = "info",
	},
	info = {
		color = Color3.fromRGB(59, 130, 246),
		icon = "info",
	},
	success = {
		color = Color3.fromRGB(34, 197, 94),
		icon = "circle-check",
	},
}

local function createSignal()
	local listeners = {}
	local signal = {}

	function signal:Connect(fn)
		table.insert(listeners, fn)
		return {
			Disconnect = function()
				for i, listener in ipairs(listeners) do
					if listener == fn then
						table.remove(listeners, i)
						break
					end
				end
			end,
		}
	end

	function signal:Fire(...)
		for _, fn in ipairs(listeners) do
			task.spawn(fn, ...)
		end
	end

	return signal
end

local function normalizeButtons(args)
	local buttons = {}
	local raw = args.buttons or args.callback or args.actions

	if type(raw) == "function" then
		buttons = {
			{ text = "Cancel", style = "secondary", callback = raw },
			{ text = "OK", style = "primary", callback = raw },
		}
	elseif type(raw) == "table" then
		local isArray = #raw > 0
		if isArray then
			for i, item in ipairs(raw) do
				if type(item) == "string" then
					local lower = item:lower()
					local style = "primary"
					if lower == "cancel" or lower == "no" or lower == "close" then
						style = "secondary"
					elseif lower == "delete" or lower == "remove" or lower == "destroy" or lower == "kick" or lower == "ban" then
						style = "danger"
					end
					table.insert(buttons, { text = item, style = style })
				elseif type(item) == "table" then
					table.insert(buttons, {
						text = item.text or item.Text or ("Button " .. i),
						style = item.style or item.Style or "primary",
						callback = item.callback or item.Callback,
						autoClose = item.autoClose ~= false,
					})
				end
			end
		else
			-- Dictionary format: { ["Cancel"] = fn1, ["Delete"] = fn2 }
			for text, fn in pairs(raw) do
				local lower = tostring(text):lower()
				local style = "primary"
				if lower == "cancel" or lower == "no" or lower == "close" then
					style = "secondary"
				elseif lower == "delete" or lower == "remove" or lower == "destroy" then
					style = "danger"
				end
				table.insert(buttons, {
					text = tostring(text),
					style = style,
					callback = type(fn) == "function" and fn or nil,
				})
			end
		end
	end

	if #buttons == 0 then
		table.insert(buttons, { text = "OK", style = "primary" })
	end

	return buttons
end

function popup.create(args)
	args = args or {}
	local stateKey = type(args.state) == "string" and args.state:lower() or "information"
	local stateCfg = STATE_CONFIGS[stateKey] or STATE_CONFIGS.information

	local stateColor = args.accentColor or args.stateColor or stateCfg.color
	local iconName = args.icon or stateCfg.icon
	local titleText = args.title or "Notice"
	local contentText = args.content or args.description or args.text or ""

	local buttonsList = normalizeButtons(args)

	local screenGui = make("ScreenGui", {
		Name = "MonoPopup",
		ResetOnSpawn = false,
		DisplayOrder = 100000,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = utils.getGuiParent(),
	})

	local overlay = make("Frame", {
		Name = "Overlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = true,
		Parent = screenGui,
	})

	local dialog = make("Frame", {
		Name = "Dialog",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(380, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(20, 20, 24),
		BorderSizePixel = 0,
		Parent = overlay,
	})
	addCorner(dialog, 12)
	local dialogStroke = addStroke(dialog, stateColor, 0.45, 1.5)

	local dialogScale = Instance.new("UIScale")
	dialogScale.Scale = 0.85
	dialogScale.Parent = dialog

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 18)
	padding.PaddingBottom = UDim.new(0, 18)
	padding.PaddingLeft = UDim.new(0, 20)
	padding.PaddingRight = UDim.new(0, 20)
	padding.Parent = dialog

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 14)
	layout.Parent = dialog

	-- Header Frame
	local header = make("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = dialog,
	})

	local iconBadge = make("Frame", {
		Name = "IconBadge",
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(32, 32),
		BackgroundColor3 = stateColor,
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
		Parent = header,
	})
	addCorner(iconBadge, 8)
	addStroke(iconBadge, stateColor, 0.6, 1)

	local iconContainer = make("Frame", {
		Name = "IconContainer",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = iconBadge,
	})
	utils.createIcon(iconName, iconContainer, UDim2.fromOffset(18, 18), UDim2.fromOffset(7, 7), stateColor)

	local titleLabel = make("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(42, 0),
		Size = UDim2.new(1, -74, 1, 0),
		BackgroundTransparency = 1,
		Text = tostring(titleText),
		Parent = header,
	})
	applyFont(titleLabel, 15, Color3.fromRGB(240, 240, 245), Enum.TextXAlignment.Left)
	titleLabel.Font = Enum.Font.RobotoMono

	local closeBtn = make("TextButton", {
		Name = "CloseButton",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(24, 24),
		BackgroundTransparency = 1,
		Text = "×",
		TextColor3 = Color3.fromRGB(150, 150, 160),
		TextSize = 20,
		AutoButtonColor = false,
		Parent = header,
	})

	-- Content Label
	local contentLabel = make("TextLabel", {
		Name = "Content",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = tostring(contentText),
		TextWrapped = true,
		LayoutOrder = 2,
		Parent = dialog,
	})
	applyFont(contentLabel, 13, Color3.fromRGB(170, 170, 180), Enum.TextXAlignment.Left)

	-- Button Bar Container
	local buttonContainer = make("Frame", {
		Name = "ButtonContainer",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Parent = dialog,
	})

	local btnLayout = Instance.new("UIListLayout")
	btnLayout.FillDirection = Enum.FillDirection.Horizontal
	btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	btnLayout.Padding = UDim.new(0, 10)
	btnLayout.Parent = buttonContainer

	-- Handle Object & Signals
	local onButtonClickedSignal = createSignal()
	local onClosedSignal = createSignal()
	local isClosing = false

	local handle = {
		ScreenGui = screenGui,
		Dialog = dialog,
		OnButtonClicked = onButtonClickedSignal,
		OnClosed = onClosedSignal,
	}

	local function closePopup()
		if isClosing then return end
		isClosing = true

		tween(overlay, { BackgroundTransparency = 1 }, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
		local scaleTween = tween(dialogScale, { Scale = 0.85 }, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		scaleTween:Play()

		scaleTween.Completed:Connect(function()
			screenGui:Destroy()
			onClosedSignal:Fire(handle)
		end)
	end

	function handle:Close()
		closePopup()
	end

	function handle:Destroy()
		closePopup()
	end

	function handle:On(target, callbackFn)
		if type(callbackFn) ~= "function" then return handle end
		onButtonClickedSignal:Connect(function(buttonText, buttonIndex)
			if type(target) == "number" and buttonIndex == target then
				callbackFn(buttonText, buttonIndex, handle)
			elseif type(target) == "string" and string.lower(tostring(buttonText)) == string.lower(tostring(target)) then
				callbackFn(buttonText, buttonIndex, handle)
			end
		end)
		return handle
	end

	function handle:OnCallback(callbackFn)
		if type(callbackFn) == "function" then
			onButtonClickedSignal:Connect(callbackFn)
		end
		return handle
	end

	closeBtn.MouseEnter:Connect(function()
		closeBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
	end)
	closeBtn.MouseLeave:Connect(function()
		closeBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
	end)
	closeBtn.Activated:Connect(function()
		closePopup()
	end)

	-- Generate buttons
	for idx, btnSpec in ipairs(buttonsList) do
		local btnStyle = btnSpec.style:lower()
		local bgCol, strokeCol, textCol

		if btnStyle == "danger" then
			bgCol = Color3.fromRGB(220, 38, 38)
			strokeCol = Color3.fromRGB(239, 68, 68)
			textCol = Color3.fromRGB(255, 255, 255)
		elseif btnStyle == "secondary" or btnStyle == "cancel" then
			bgCol = Color3.fromRGB(30, 30, 36)
			strokeCol = Color3.fromRGB(55, 55, 65)
			textCol = Color3.fromRGB(200, 200, 210)
		else -- primary
			bgCol = stateColor
			strokeCol = stateColor
			textCol = Color3.fromRGB(255, 255, 255)
		end

		local actionBtn = make("TextButton", {
			Name = "Button_" .. idx,
			Size = UDim2.fromOffset(90, 32),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = bgCol,
			BorderSizePixel = 0,
			Text = tostring(btnSpec.text),
			AutoButtonColor = false,
			Parent = buttonContainer,
		})
		applyFont(actionBtn, 13, textCol, Enum.TextXAlignment.Center)
		addCorner(actionBtn, 7)
		local btnStroke = addStroke(actionBtn, strokeCol, 0.5, 1)

		local btnPadding = Instance.new("UIPadding")
		btnPadding.PaddingLeft = UDim.new(0, 14)
		btnPadding.PaddingRight = UDim.new(0, 14)
		btnPadding.Parent = actionBtn

		actionBtn.MouseEnter:Connect(function()
			tween(actionBtn, { BackgroundTransparency = 0.15 }, 0.1):Play()
		end)
		actionBtn.MouseLeave:Connect(function()
			tween(actionBtn, { BackgroundTransparency = 0 }, 0.1):Play()
		end)

		actionBtn.Activated:Connect(function()
			tween(actionBtn, { BackgroundTransparency = 0.3 }, 0.05):Play()
			task.wait(0.05)
			tween(actionBtn, { BackgroundTransparency = 0 }, 0.05):Play()

			if btnSpec.callback then
				task.spawn(btnSpec.callback, handle)
			end

			onButtonClickedSignal:Fire(btnSpec.text, idx, handle)

			if btnSpec.autoClose ~= false then
				closePopup()
			end
		end)
	end

	local function getTargetDialogScale()
		local camera = utils.Workspace.CurrentCamera
		if not camera then return 1 end
		local vp = camera.ViewportSize
		if vp.X <= 0 or vp.Y <= 0 then return 1 end
		local maxW = vp.X * 0.85
		local maxH = vp.Y * 0.85
		local sX = maxW / 380
		local sY = maxH / 220
		return math.clamp(math.min(1, sX, sY), 0.5, 1)
	end

	-- Entrance Animation
	tween(overlay, { BackgroundTransparency = 0.55 }, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
	tween(dialogScale, { Scale = getTargetDialogScale() }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()

	return handle
end

return popup
