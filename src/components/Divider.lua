local utils = require("../core/utils")
local make = utils.make

return function(page, args)
	args = args or {}
	local height = args.height or 12
	local hasLine = args.line == true
	
	local dividerFrame = make("Frame", {
		Name = "Divider",
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = page,
	})
	
	local line = nil
	if hasLine then
		line = make("Frame", {
			Name = "Line",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, -8, 0, 1),
			BackgroundColor3 = Color3.fromRGB(45, 45, 52),
			BorderSizePixel = 0,
			Parent = dividerFrame,
		})
	end
	
	local obj = {}
	
	function obj:SetHeight(newHeight)
		dividerFrame.Size = UDim2.new(1, 0, 0, newHeight)
	end
	
	function obj:Destroy()
		dividerFrame:Destroy()
	end
	
	return obj
end
