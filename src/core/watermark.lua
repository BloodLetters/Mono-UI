local utils = require("./utils")
local make = utils.make
local addCorner = utils.addCorner
local addStroke = utils.addStroke
local applyFont = utils.applyFont
local tween = utils.tween

local watermark = {}
local screenGui = nil
local card = nil
local textLabel = nil
local isUpdating = false
local currentOptions = {}

local function getWatermarkGui()
	if screenGui and screenGui.Parent then
		return screenGui, card, textLabel
	end
	
	screenGui = make("ScreenGui", {
		Name = "MonoWatermark",
		ResetOnSpawn = false,
		DisplayOrder = 99998,
		Parent = utils.getGuiParent(),
	})
	
	card = make("Frame", {
		Name = "WatermarkCard",
		AnchorPoint = currentOptions.anchorPoint or Vector2.new(1, 0),
		Position = currentOptions.position or UDim2.new(1, -24, 0, 24),
		Size = UDim2.fromOffset(240, 28),
		BackgroundColor3 = Color3.fromRGB(20, 20, 24),
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Parent = screenGui,
	})
	addCorner(card, 6)
	local stroke = addStroke(card, Color3.fromRGB(60, 60, 68), 0.6, 1)
	utils.registerTheme(stroke, "Color", "AccentColor")
	
	textLabel = make("TextLabel", {
		Name = "Label",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "mono ui | loading stats...",
		Parent = card,
	})
	applyFont(textLabel, 13, Color3.fromRGB(235, 235, 240), Enum.TextXAlignment.Center)
	textLabel.Font = Enum.Font.RobotoMono
	
	return screenGui, card, textLabel
end

function watermark.set(options)
	options = options or {}
	currentOptions = options
	local visible = options.visible ~= false
	local customText = options.text or "mono ui"

	if not visible then
		if screenGui then
			screenGui:Destroy()
			screenGui = nil
			card = nil
			textLabel = nil
		end
		isUpdating = false
		return
	end

	local _, watermarkCard, label = getWatermarkGui()
	
	if not isUpdating then
		isUpdating = true
		task.spawn(function()
			local RunService = game:GetService("RunService")
			local Stats = game:GetService("Stats")
			
			local lastUpdate = os.clock()
			local fpsCount = 0
			local currentFps = 60
			
			local fpsConnection
			fpsConnection = RunService.RenderStepped:Connect(function()
				fpsCount = fpsCount + 1
				local now = os.clock()
				if now - lastUpdate >= 1 then
					currentFps = fpsCount
					fpsCount = 0
					lastUpdate = now
				end
			end)
			
			while isUpdating and label and label.Parent do
				local ping = 0
				local network = Stats:FindFirstChild("Network")
				local serverPing = network and network:FindFirstChild("ServerPing")
				if serverPing then
					ping = math.floor(serverPing:GetValue() + 0.5)
				end
				
				local timeStr = os.date("%H:%M:%S")
				local statsText = string.format("%s | %d FPS | %dms | %s", customText, currentFps, ping, timeStr)
				
				local textWidth = label.TextBounds.X
				if textWidth > 0 then
					watermarkCard.Size = UDim2.fromOffset(textWidth + 24, 28)
				end
				
				label.Text = statsText
				task.wait(0.5)
			end
			
			if fpsConnection then
				fpsConnection:Disconnect()
			end
		end)
	end
end

return watermark
