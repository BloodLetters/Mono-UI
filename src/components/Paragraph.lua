local utils = require("../core/utils")
local make = utils.make
local monoFont = utils.monoFont

return function(page, args)
	args = args or {}
	local paragraphText = args.text or "This is a paragraph."
	local fontSize = args.size or 16
	local textColor = args.color or Color3.fromRGB(180, 180, 190)
	local alignment = args.align or Enum.TextXAlignment.Left

	local paragraphFrame = make("Frame", {
		Name = "Paragraph",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = page,
	})

	local paragraphPadding = Instance.new("UIPadding")
	paragraphPadding.PaddingLeft = UDim.new(0, 4)
	paragraphPadding.PaddingRight = UDim.new(0, 4)
	paragraphPadding.PaddingTop = UDim.new(0, 4)
	paragraphPadding.PaddingBottom = UDim.new(0, 4)
	paragraphPadding.Parent = paragraphFrame

	local paragraphLabel = make("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = tostring(paragraphText),
		TextSize = fontSize,
		TextColor3 = textColor,
		TextXAlignment = alignment,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		RichText = true,
		Parent = paragraphFrame,
	})
	
	if args.font then
		paragraphLabel.FontFace = args.font
	else
		paragraphLabel.FontFace = monoFont
	end

	local obj = {}
	
	function obj:SetText(newText)
		paragraphLabel.Text = tostring(newText)
	end
	
	function obj:SetColor(newColor)
		paragraphLabel.TextColor3 = newColor
	end

	function obj:Destroy()
		paragraphFrame:Destroy()
	end

	return obj
end
