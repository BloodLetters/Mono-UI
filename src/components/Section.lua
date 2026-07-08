local utils = require("../core/utils")
local make = utils.make
local applyFont = utils.applyFont

return function(page, args)
	args = args or {}
	local sectionText = args.text
	
	local sectionRow = make("Frame", {
		Name = sectionText or "Section",
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Parent = page,
	})
	
	local sectionLabel = make("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(4, 4),
		Size = UDim2.new(1, - 8, 0, 20),
		Text = string.upper(tostring(sectionText or "Section")),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = sectionRow,
	})
	applyFont(sectionLabel, 20, Color3.fromRGB(255, 255, 255), Enum.TextXAlignment.Left)
	
	local sectionLine = make("Frame", {
		Name = "Divider",
		BackgroundColor3 = Color3.fromRGB(218, 218, 224),
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 4, 1, - 2),
		Size = UDim2.new(1, - 8, 0, 1),
		Parent = sectionRow,
	})
	
	return sectionRow
end
