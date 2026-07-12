local utils = require("../core/utils")
local Workspace = utils.Workspace
local UserInputService = utils.UserInputService
local monoFont = utils.monoFont
local make = utils.make
local addCorner = utils.addCorner
local addStroke = utils.addStroke
local applyFont = utils.applyFont

return function(page, screenGui, args)
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

	local pickerRow = make("Frame", {
		Name = (pickerText or "Color") .. "Row",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(24, 24, 28),
		BorderSizePixel = 0,
		Parent = page,
	})
	addCorner(pickerRow, 10)
	addStroke(pickerRow, Color3.fromRGB(60, 60, 68), 0.65, 1)

	local isVBar = page.Name == "VBar"
	local boxWidth = isVBar and 76 or 100
	local labelWidthOffset = isVBar and -110 or -140

	local label = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, labelWidthOffset, 1, 0),
		Text = tostring(pickerText or "Color"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = pickerRow,
	})
	applyFont(label, 14, Color3.fromRGB(232, 232, 236), Enum.TextXAlignment.Left)

	local colorBox = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(boxWidth, 28),
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

		popupBody = make("Frame", {
			Name = "Body",
			Size = UDim2.new(1, -20, 1, -20),
			Position = UDim2.fromOffset(10, 10),
			BackgroundTransparency = 1,
			ZIndex = 10001,
			Parent = pickerPopup,
		})

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

			btn.Activated:Connect(function()
				applyPopupColor(pr, pg, pb)
			end)
		end

		-- Init
		popupR, popupG, popupB = colorToRGB255(currentColor)
		refreshPopupSliders()
	end

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

	colorBox.Activated:Connect(function()
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
