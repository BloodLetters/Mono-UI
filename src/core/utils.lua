local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local monoFont = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

-- Import the local Lucide icon resolver module
local getIcon = require("./lucide")

local utils = {}

utils.Players = Players
utils.UserInputService = UserInputService
utils.TweenService = TweenService
utils.Workspace = Workspace
utils.player = player
utils.playerGui = playerGui
utils.monoFont = monoFont

function utils.getIconAsset(icon)
	if not icon or tostring(icon) == "" then
		return nil
	end
	icon = tostring(icon):lower()
	if icon:match("^rbxassetid://") or icon:match("^http://") or icon:match("^https://") or icon:match("^assetgame://") then
		return icon
	end
	if tonumber(icon) then
		return "rbxassetid://" .. icon
	end
	return nil
end

function utils.createIcon(icon, parent, size, position, color)
	if not icon or tostring(icon) == "" then
		return nil
	end

	-- Try loading using local getIcon function (returns spritesheet mapping)
	local ok, asset = pcall(getIcon, icon)
	if ok and asset and asset.id then
		local imageLabel = utils.make("ImageLabel", {
			Name = "Icon",
			Size = size or UDim2.fromScale(1, 1),
			Position = position or UDim2.fromScale(0, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://" .. asset.id,
			ImageRectOffset = asset.imageRectOffset,
			ImageRectSize = asset.imageRectSize,
			ImageColor3 = color or Color3.fromRGB(242, 242, 242),
			Parent = parent,
		})
		return imageLabel
	end

	-- Fallback to direct asset strings or numeric IDs
	local iconAsset = utils.getIconAsset(icon)
	if iconAsset then
		local imageLabel = utils.make("ImageLabel", {
			Name = "Icon",
			Size = size or UDim2.fromScale(1, 1),
			Position = position or UDim2.fromScale(0, 0),
			BackgroundTransparency = 1,
			Image = iconAsset,
			ImageColor3 = color or Color3.fromRGB(242, 242, 242),
			Parent = parent,
		})
		return imageLabel
	else
		-- It's a text/emoji icon
		local textLabel = utils.make("TextLabel", {
			Name = "Icon",
			Size = size or UDim2.fromScale(1, 1),
			Position = position or UDim2.fromScale(0, 0),
			BackgroundTransparency = 1,
			Text = tostring(icon),
			Parent = parent,
		})
		utils.applyFont(textLabel, 16, color or Color3.fromRGB(242, 242, 242), Enum.TextXAlignment.Center)
		return textLabel
	end
end

function utils.getGuiParent()
	if typeof(gethui) == "function" then
		local ok, result = pcall(gethui)
		if ok and result then
			return result
		end
	end
	return playerGui
end

function utils.tween(instance, properties, duration)
	local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	return TweenService:Create(instance, info, properties)
end

function utils.make(className, properties)
	local instance = Instance.new(className)
	for property, value in pairs(properties or {}) do
		instance[property] = value
	end
	return instance
end

function utils.addCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
	return corner
end

function utils.addStroke(instance, color, transparency, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Transparency = transparency
	stroke.Thickness = thickness
	stroke.Parent = instance
	return stroke
end

function utils.applyFont(instance, size, color, alignment)
	instance.FontFace = monoFont
	instance.TextSize = size
	instance.TextColor3 = color
	if alignment then
		instance.TextXAlignment = alignment
	end
end

function utils.setVisible(group, visible)
	for _, child in ipairs(group:GetChildren()) do
		if child:IsA("GuiObject") then
			child.Visible = visible
		end
	end
end

function utils.connectDrag(handle, target)
	local dragging = false
	local dragStart
	local startPosition
	handle.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
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

function utils.getResponsiveWindowSize()
	local camera = Workspace.CurrentCamera
	if not camera then
		return UDim2.fromOffset(560, 360)
	end
	local viewport = camera.ViewportSize
	local width = math.clamp(math.floor(viewport.X * 0.46), 520, 780)
	local height = math.clamp(math.floor(viewport.Y * 0.48), 340, 560)
	return UDim2.fromOffset(width, height)
end

-- CENTRALIZED THEME REGISTRY
utils.theme = {
	AccentColor = Color3.fromRGB(0, 162, 255),
	BackgroundColor = Color3.fromRGB(16, 16, 18),
	CardColor = Color3.fromRGB(24, 24, 28),
	BorderColor = Color3.fromRGB(60, 60, 68),
	TextColor = Color3.fromRGB(235, 235, 240),
	MutedTextColor = Color3.fromRGB(150, 150, 160),
}

local themeRegistry = {}
local themeSignals = {}

function utils.onThemeChanged(callback)
	table.insert(themeSignals, callback)
end

function utils.registerTheme(instance, property, themeKey)
	table.insert(themeRegistry, { instance = instance, property = property, key = themeKey })
	instance[property] = utils.theme[themeKey]
end

function utils.setThemeColor(themeKey, color)
	if utils.theme[themeKey] then
		utils.theme[themeKey] = color
		for i = #themeRegistry, 1, -1 do
			local item = themeRegistry[i]
			if item.instance and item.instance.Parent then
				pcall(function()
					item.instance[item.property] = color
				end)
			else
				table.remove(themeRegistry, i)
			end
		end
		for _, cb in ipairs(themeSignals) do
			task.spawn(cb, themeKey, color)
		end
	end
end

return utils
