local utils = require("../core/utils")
local make = utils.make
local applyFont = utils.applyFont

return function(page, args)
	args = args or {}
	local sectionText = args.text
	
	local isVBar = page.Name == "VBar"
	local sectionHeight = isVBar and 26 or 30
	local textSize = isVBar and 14 or 18
	local textPos = isVBar and UDim2.fromOffset(2, 2) or UDim2.fromOffset(4, 4)

	local sectionRow = make("Frame", {
		Name = sectionText or "Section",
		Size = UDim2.new(1, 0, 0, sectionHeight),
		BackgroundTransparency = 1,
		Parent = page,
	})
	
	local sectionLabel = make("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = textPos,
		Size = UDim2.new(1, - 4, 0, 16),
		Text = string.upper(tostring(sectionText or "Section")),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = sectionRow,
	})
	applyFont(sectionLabel, textSize, Color3.fromRGB(235, 235, 242), Enum.TextXAlignment.Left)
	
	local sectionLine = make("Frame", {
		Name = "Divider",
		BackgroundColor3 = Color3.fromRGB(218, 218, 224),
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 2, 1, - 2),
		Size = UDim2.new(1, - 4, 0, 1),
		Parent = sectionRow,
	})
	
	return sectionRow
end
