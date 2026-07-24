local Util = require("./Util")
local TweenService = game:GetService("TweenService")

local Notification = {}
local activeNotifications = {}

local function updatePositions()
	local yOffset = -20 -- start 20px from bottom
	for i = #activeNotifications, 1, -1 do
		local notif = activeNotifications[i]
		local frame = notif.Frame
		if frame then
			local targetPos = UDim2.new(1, -20, 1, yOffset)
			TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = targetPos
			}):Play()
			yOffset = yOffset - (frame.AbsoluteSize.Y + 10)
		end
	end
end

function Notification.new(options)
	options = options or {}
	local title = options.Title or "Notification"
	local content = options.Content or ""
	local duration = options.Duration or 4
	local notifType = options.Type or "Info" -- "Info", "Success", "Error"
	local accentColor = options.AccentColor or Color3.fromRGB(0, 162, 255)

	local parentGui = Util.getGuiParent()
	if not parentGui then return end

	-- Find or create Notification ScreenGui
	local notifGui = parentGui:FindFirstChild("GuardNotificationGui")
	if not notifGui then
		notifGui = Util.make("ScreenGui", {
			Name = "GuardNotificationGui",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 1002,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			Parent = parentGui
		})
	end

	local frameWidth = 280
	local frameHeight = 66

	-- Container Frame
	local frame = Util.make("Frame", {
		Name = "NotificationFrame",
		AnchorPoint = Vector2.new(1, 1),
		-- Start off-screen to the right
		Position = UDim2.new(1, frameWidth + 20, 1, -20),
		Size = UDim2.fromOffset(frameWidth, frameHeight),
		BackgroundColor3 = Color3.fromRGB(20, 20, 24),
		BorderSizePixel = 0,
		Parent = notifGui
	})

	Util.addCorner(frame, 8)
	Util.addStroke(frame, Color3.fromRGB(45, 45, 52), 0.3, 1)

	-- Icon & Left border accent color
	local typeColor = Color3.fromRGB(140, 140, 145) -- Info default
	local iconAsset = "rbxassetid://16898613509"
	local iconRectOffset = Vector2.new(820, 257) -- shield / check info

	if notifType == "Success" then
		typeColor = Color3.fromRGB(80, 220, 80)
		iconAsset = "rbxassetid://16898613777"
		iconRectOffset = Vector2.new(820, 257) -- check
	elseif notifType == "Error" then
		typeColor = Color3.fromRGB(220, 80, 80)
		iconAsset = "rbxassetid://16898613777"
		iconRectOffset = Vector2.new(514, 820) -- cross
	elseif notifType == "Info" then
		typeColor = accentColor
	end

	-- Left vertical line indicator
	local accentBar = Util.make("Frame", {
		Name = "AccentBar",
		Size = UDim2.new(0, 4, 1, 0),
		BackgroundColor3 = typeColor,
		BorderSizePixel = 0,
		Parent = frame
	})
	Util.addCorner(accentBar, 8) -- corners on the left edge

	-- Icon
	local icon = Util.make("ImageLabel", {
		Name = "Icon",
		Position = UDim2.fromOffset(14, 20),
		Size = UDim2.fromOffset(24, 24),
		BackgroundTransparency = 1,
		Image = iconAsset,
		ImageRectOffset = iconRectOffset,
		ImageRectSize = Vector2.new(48, 48),
		ImageColor3 = typeColor,
		Parent = frame
	})

	local cleanFont = Font.fromEnum(Enum.Font.Montserrat)
	local cleanFontBold = Font.fromEnum(Enum.Font.MontserratBold)

	-- Title Label
	local titleLabel = Util.make("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(48, 12),
		Size = UDim2.new(1, -60, 0, 16),
		Text = title,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 13,
		FontFace = cleanFontBold,
		BackgroundTransparency = 1,
		Parent = frame
	})

	-- Content Label
	local contentLabel = Util.make("TextLabel", {
		Name = "Content",
		Position = UDim2.fromOffset(48, 30),
		Size = UDim2.new(1, -60, 0, 24),
		Text = content,
		TextColor3 = Color3.fromRGB(140, 140, 145),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextSize = 11,
		FontFace = cleanFont,
		TextWrapped = true,
		BackgroundTransparency = 1,
		Parent = frame
	})

	-- Progress Bar (at the bottom)
	local progressBarBg = Util.make("Frame", {
		Name = "ProgressBarBg",
		Position = UDim2.new(0, 0, 1, -2),
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = Color3.fromRGB(30, 30, 35),
		BorderSizePixel = 0,
		Parent = frame
	})

	local progressBar = Util.make("Frame", {
		Name = "ProgressBar",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = typeColor,
		BorderSizePixel = 0,
		Parent = progressBarBg
	})

	local notifObj = {
		Frame = frame,
		Destroy = function()
			-- Remove from active list
			for idx, val in ipairs(activeNotifications) do
				if val.Frame == frame then
					table.remove(activeNotifications, idx)
					break
				end
			end
			updatePositions()

			-- Slide out to the right
			local slideOut = TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
				Position = UDim2.new(1, frameWidth + 20, 1, frame.Position.Y.Offset)
			})
			slideOut:Play()
			slideOut.Completed:Connect(function()
				frame:Destroy()
			end)
		end
	}

	table.insert(activeNotifications, notifObj)
	updatePositions()

	-- Animate Progress Bar
	TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, 0, 1, 0)
	}):Play()

	-- Auto Destroy
	task.delay(duration, function()
		if frame and frame.Parent then
			notifObj.Destroy()
		end
	end)

	return notifObj
end

return Notification
