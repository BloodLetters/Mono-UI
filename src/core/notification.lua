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

local activeCards = {}
local CARD_HEIGHT = 68
local CARD_GAP = 10
local MAX_VISIBLE = 5

local function getNotificationGui()
	if screenGui and screenGui.Parent then
		return screenGui, listHolder
	end

	screenGui = make("ScreenGui", {
		Name = "MonoNotification",
		ResetOnSpawn = false,
		DisplayOrder = 99999,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = utils.getGuiParent(),
	})

	listHolder = make("Frame", {
		Name = "ListHolder",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -20, 1, -96),
		Size = UDim2.new(0, 290, 1, -120),
		BackgroundTransparency = 1,
		Parent = screenGui,
	})

	return screenGui, listHolder
end

local function repositionCards()
	local totalCards = #activeCards
	for i, entry in ipairs(activeCards) do
		local fromBottom = totalCards - i 
		local targetY = -(fromBottom * (CARD_HEIGHT + CARD_GAP))
		local age = fromBottom / math.max(totalCards - 1, 1)
		local targetTransparency = 0.05 + (age * 0.35)
		local targetScale = 1 - (age * 0.04)

		tween(entry.card, {
			Position = UDim2.new(0, 0, 1, targetY),
			BackgroundTransparency = targetTransparency,
			Size = UDim2.new(targetScale, 0, 0, CARD_HEIGHT),
		}, 0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out):Play()

		entry.card.Visible = fromBottom < MAX_VISIBLE
	end
end

local function removeCard(entry)
	for i, e in ipairs(activeCards) do
		if e == entry then
			table.remove(activeCards, i)
			break
		end
	end
	repositionCards()
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
		Position = UDim2.new(1, 300, 1, 0),
		Size = UDim2.new(1, 0, 0, CARD_HEIGHT),
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
	applyFont(contentLabel, 13, Color3.fromRGB(160, 160, 170), Enum.TextXAlignment.Left)

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

	local entry = { card = card }
	table.insert(activeCards, entry)
	repositionCards()

	local fromBottom = 0
	local targetY = -(fromBottom * (CARD_HEIGHT + CARD_GAP))
	card.Position = UDim2.new(1, 300, 1, targetY)
	local enterTween = tween(card, {
		Position = UDim2.new(0, 0, 1, targetY),
	}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	enterTween:Play()

	task.spawn(function()
		enterTween.Completed:Wait()

		local progressTween = tween(progressBar, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)
		progressTween:Play()
		progressTween.Completed:Wait()

		local currentY = card.Position.Y.Offset
		local exitTween = tween(card, {
			Position = UDim2.new(1, 300, 1, currentY),
			BackgroundTransparency = 1,
		}, 0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		exitTween:Play()
		exitTween.Completed:Wait()

		card:Destroy()
		removeCard(entry)
	end)
end

return notification
