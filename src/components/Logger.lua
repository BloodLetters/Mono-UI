local utils = require("../core/utils")
local make = utils.make
local addCorner = utils.addCorner
local addStroke = utils.addStroke
local applyFont = utils.applyFont
local tween = utils.tween

return function(page, args)
	args = args or {}
	local titleText = args.text or "Console Logs"
	local height = args.height or 180

	local container = make("Frame", {
		Name = "LoggerContainer",
		Size = UDim2.new(1, 0, 0, height + 40),
		BackgroundColor3 = Color3.fromRGB(24, 24, 28),
		BorderSizePixel = 0,
		Parent = page,
	})
	addCorner(container, 10)
	addStroke(container, Color3.fromRGB(60, 60, 68), 0.65, 1)

	local titleLabel = make("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 8),
		Size = UDim2.new(1, -28, 0, 20),
		Text = tostring(titleText),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container,
	})
	applyFont(titleLabel, 14, Color3.fromRGB(255, 255, 255), Enum.TextXAlignment.Left)

	local scroll = make("ScrollingFrame", {
		Name = "LogScroll",
		Position = UDim2.fromOffset(10, 32),
		Size = UDim2.new(1, -20, 0, height),
		BackgroundColor3 = Color3.fromRGB(16, 16, 18),
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = container,
	})
	addCorner(scroll, 6)
	addStroke(scroll, Color3.fromRGB(40, 40, 48), 0.6, 1)

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = scroll

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 0)
	listLayout.Parent = scroll

	local logCount = 0

	local function log(level, text)
		logCount = logCount + 1
		level = tostring(level or "INFO"):upper()
		text = tostring(text or "")

		local timeStr = os.date("%H:%M:%S")
		local logRow = make("Frame", {
			Name = string.format("Log_%05d", logCount),
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			LayoutOrder = logCount,
			Parent = scroll,
		})

		local colorMap = {
			INFO = Color3.fromRGB(200, 200, 210),
			SUCCESS = Color3.fromRGB(50, 220, 100),
			WARNING = Color3.fromRGB(240, 180, 50),
			ERROR = Color3.fromRGB(250, 70, 70)
		}
		local levelColor = colorMap[level] or Color3.fromRGB(200, 200, 210)

		local fullText = string.format("[%s] [%s] %s", timeStr, level, text)
		
		local label = make("TextLabel", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Text = fullText,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			Parent = logRow,
		})
		applyFont(label, 14, levelColor, Enum.TextXAlignment.Left)
		label.Font = Enum.Font.RobotoMono
		label.RichText = true
		label.TextSize = 14
		
		-- Let AutomaticSize handle the height of logRow
		logRow.AutomaticSize = Enum.AutomaticSize.Y

		-- Force scroll to bottom
		task.defer(function()
			scroll.CanvasPosition = Vector2.new(0, scroll.AbsoluteCanvasSize.Y)
		end)
	end

	return {
		Log = function(_, level, text)
			log(level, text)
		end,
		Clear = function()
			for _, child in ipairs(scroll:GetChildren()) do
				if child:IsA("Frame") then
					child:Destroy()
				end
			end
		end
	}
end
