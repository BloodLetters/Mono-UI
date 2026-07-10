local utils = require("../core/utils")
local UserInputService = utils.UserInputService
local make = utils.make
local addCorner = utils.addCorner
local addStroke = utils.addStroke
local applyFont = utils.applyFont

return function(page, args)
	args = args or {}
	local sliderText = args.text or "Slider"
	local min = args.min or 0
	local max = args.max or 100
	local defaultValue = args.default or min
	local callback = args.callback
	
	local sliderRow = make("Frame", {
		Name = sliderText .. "Row",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(24, 24, 28),
		BorderSizePixel = 0,
		Parent = page,
	})
	addCorner(sliderRow, 10)
	addStroke(sliderRow, Color3.fromRGB(60, 60, 68), 0.65, 1)
	
	local label = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, - 140, 1, 0),
		Text = tostring(sliderText),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = sliderRow,
	})
	applyFont(label, 14, Color3.fromRGB(232, 232, 236), Enum.TextXAlignment.Left)
	
	local valueLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, - 12, 0.5, 0),
		Size = UDim2.fromOffset(40, 18),
		Text = tostring(defaultValue),
		TextColor3 = Color3.fromRGB(155, 155, 165),
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = sliderRow,
	})
	applyFont(valueLabel, 13, Color3.fromRGB(155, 155, 165), Enum.TextXAlignment.Right)
	
	local trackHolder = make("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, - 64, 0.5, 0),
		Size = UDim2.fromOffset(80, 10),
		BackgroundColor3 = Color3.fromRGB(22, 22, 26),
		BorderSizePixel = 0,
		Parent = sliderRow,
	})
	addCorner(trackHolder, 5)
	
	local fill = make("Frame", {
		Size = UDim2.fromOffset(0, 10),
		BorderSizePixel = 0,
		Parent = trackHolder,
	})
	addCorner(fill, 5)
	utils.registerTheme(fill, "BackgroundColor3", "AccentColor")
	
	local thumb = make("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(0, 5),
		Size = UDim2.fromOffset(22, 22),
		BackgroundColor3 = Color3.fromRGB(235, 235, 240),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Parent = trackHolder,
	})
	addCorner(thumb, 11)
	
	local currentValue = defaultValue
	local dragging = false
	
	local function clamp(v)
		return math.max(min, math.min(max, v))
	end
	
	local function setValue(value)
		value = clamp(value)
		currentValue = value
		local ratio = (value - min) / (max - min)
		local trackWidth = trackHolder.AbsoluteSize.X
		local thumbPos = ratio * trackWidth
		fill.Size = UDim2.fromOffset(math.max(0, thumbPos), 10)
		thumb.Position = UDim2.fromOffset(math.max(11, math.min(trackWidth - 11, thumbPos)), 5)
		valueLabel.Text = tostring(math.floor(value * 10) / 10)
		if callback then
			callback(value)
		end
	end
	
	local function getValueFromMouse(inputPos)
		local trackPos = trackHolder.AbsolutePosition
		local trackWidth = trackHolder.AbsoluteSize.X
		local relativeX = inputPos.X - trackPos.X
		local ratio = math.clamp(relativeX / trackWidth, 0, 1)
		return min + ratio * (max - min)
	end
	
	thumb.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			setValue(getValueFromMouse(input.Position))
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	
	trackHolder.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			setValue(getValueFromMouse(input.Position))
		end
	end)
	
	task.wait()
	setValue(clamp(defaultValue))
	
	return {
		Set = function(_, value)
			setValue(clamp(value))
		end,
		Get = function()
			return currentValue
		end,
	}
end
