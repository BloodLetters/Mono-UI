local Util = {}

function Util.getGuiParent()
	if typeof(gethui) == "function" then
		local ok, result = pcall(gethui)
		if ok and result then
			return result
		end
	end
	local players = game:GetService("Players")
	local localPlayer = players.LocalPlayer
	if localPlayer then
		local pGui = localPlayer:FindFirstChildOfClass("PlayerGui")
		if pGui then
			return pGui
		end
	end
	-- Fallback
	local ok, coreGui = pcall(game.GetService, game, "CoreGui")
	if ok and coreGui then
		return coreGui
	end
	return nil
end

function Util.make(className, properties)
	local instance = Instance.new(className)
	for property, value in pairs(properties or {}) do
		instance[property] = value
	end
	return instance
end

function Util.addCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
	return corner
end

function Util.addStroke(instance, color, transparency, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Transparency = transparency or 0
	stroke.Thickness = thickness or 1
	stroke.Parent = instance
	return stroke
end

function Util.connectDrag(handle, target)
	local dragging = false
	local dragStart
	local startPosition

	local UserInputService = game:GetService("UserInputService")

	handle.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = target.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(
				startPosition.X.Scale, startPosition.X.Offset + delta.X,
				startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

function Util.copyToClipboard(text)
	if typeof(setclipboard) == "function" then
		pcall(setclipboard, text)
		return true
	elseif typeof(toClipboard) == "function" then
		pcall(toClipboard, text)
		return true
	end
	return false
end

return Util
