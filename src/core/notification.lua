local utils = require("./utils")
local make = utils.make
local addCorner = utils.addCorner
local addStroke = utils.addStroke
local applyFont = utils.applyFont
local tween = utils.tween
local getIcon = require("./lucide")

local notification = {}
local screenGui = nil
local listHolder = nil

local function getNotificationGui()
	if screenGui and screenGui.Parent then
		return screenGui, listHolder
	end
	
	screenGui = make("ScreenGui", {
		Name = "MonoNotification",
		ResetOnSpawn = false,
		DisplayOrder = 99999,
		Parent = utils.getGuiParent(),
	})
	
	listHolder = make("Frame", {
		Name = "ListHolder",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -24, 1, -24),
		Size = UDim2.new(0, 280, 1, -48),
		BackgroundTransparency = 1,
		Parent = screenGui,
	})
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	listLayout.Padding = UDim.new(0, 10)
	listLayout.Parent = listHolder
	
	return screenGui, listHolder
end

function notification.notify(args)
	args = args or {}
	local titleText = args.title or "Notification"
	local contentText = args.content or ""
	local duration = args.duration or 4
	local iconText = args.icon or "info"

	local _, holder = getNotificationGui()

	local card = make("Frame", {
		Name = "Card",
		Size = UDim2.new(1, 0, 0, 68),
		BackgroundColor3 = Color3.fromRGB(20, 20, 24),
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = holder,
	})
	addCorner(card, 8)
	local stroke = addStroke(card, Color3.fromRGB(60, 60, 68), 0.6, 1)
	utils.registerTheme(stroke, "Color", "AccentColor")

	local iconContainer = make("Frame", {
		Name = "IconContainer",
		Position = UDim2.fromOffset(12, 14),
		Size = UDim2.fromOffset(24, 24),
		BackgroundTransparency = 1,
		Parent = card,
	})
	utils.createIcon(iconText, iconContainer, UDim2.fromOffset(20, 20), UDim2.fromOffset(2, 2), Color3.fromRGB(235, 235, 240))

	local textFrame = make("Frame", {
		Name = "TextFrame",
		Position = UDim2.fromOffset(46, 10),
		Size = UDim2.new(1, -56, 1, -20),
		BackgroundTransparency = 1,
		Parent = card,
	})

	local titleLabel = make("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Text = tostring(titleText),
		Parent = textFrame,
	})
	applyFont(titleLabel, 13, Color3.fromRGB(240, 240, 245), Enum.TextXAlignment.Left)
	titleLabel.Font = Enum.Font.RobotoMono

	local contentLabel = make("TextLabel", {
		Name = "Content",
		Position = UDim2.fromOffset(0, 18),
		Size = UDim2.new(1, 0, 1, -18),
		BackgroundTransparency = 1,
		Text = tostring(contentText),
		TextWrapped = true,
		Parent = textFrame,
	})
	applyFont(contentLabel, 11, Color3.fromRGB(160, 160, 170), Enum.TextXAlignment.Left)

	-- Progress Bar (at the bottom)
	local progressBarBg = make("Frame", {
		Name = "ProgressBarBg",
		Position = UDim2.new(0, 0, 1, -3),
		Size = UDim2.new(1, 0, 0, 3),
		BackgroundColor3 = Color3.fromRGB(36, 36, 42),
		BorderSizePixel = 0,
		Parent = card,
	})
	local progressBar = make("Frame", {
		Name = "ProgressBar",
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		Parent = progressBarBg,
	})
	utils.registerTheme(progressBar, "BackgroundColor3", "AccentColor")

	card.Position = UDim2.new(1, 300, 0, 0)
	local enterTween = tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	enterTween:Play()
	enterTween.Completed:Wait()

	local progressTween = tween(progressBar, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)
	progressTween:Play()
	progressTween.Completed:Wait()

	local exitTween = tween(card, { Position = UDim2.new(1, 300, 0, 0) }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	exitTween:Play()
	exitTween.Completed:Wait()

	card:Destroy()
end

return notification
