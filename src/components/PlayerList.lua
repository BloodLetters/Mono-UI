local utils = require("../core/utils")
local make = utils.make
local addCorner = utils.addCorner
local addStroke = utils.addStroke
local applyFont = utils.applyFont
local tween = utils.tween
local Players = utils.Players

return function(page, args)
	args = args or {}
	local titleText = args.text or "Player List"
	local height = args.height or 200

	local container = make("Frame", {
		Name = "PlayerListContainer",
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
		Parent = container,
	})
	applyFont(titleLabel, 13, Color3.fromRGB(200, 200, 210), Enum.TextXAlignment.Left)

	local scroll = make("ScrollingFrame", {
		Name = "PlayerScroll",
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

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.Name
	listLayout.Padding = UDim.new(0, 4)
	listLayout.Parent = scroll

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = scroll

	local playerRows = {}
	local playerRowButtons = {}
	local activeToggleButtons = {}

	local function addPlayerRow(player)
		if playerRows[player] then return end
		if player == Players.LocalPlayer then return end

		local customButtons = args.buttons or {}
		if #customButtons > 2 then
			customButtons = {}
		end

		local playerRow = make("Frame", {
			Name = player.Name,
			Size = UDim2.new(1, 0, 0, 44),
			BackgroundColor3 = Color3.fromRGB(22, 22, 26),
			BorderSizePixel = 0,
			Parent = scroll,
		})
		addCorner(playerRow, 6)
		addStroke(playerRow, Color3.fromRGB(40, 40, 48), 0.5, 1)

		local numButtons = #customButtons
		local buttonsContainerWidth = numButtons > 0 and (numButtons * 60 - 6) or 0
		local nameLabelWidthOffset = -10 - buttonsContainerWidth - (numButtons > 0 and 8 or 0)

		local nameLabel = make("TextLabel", {
			Position = UDim2.fromOffset(8, 0),
			Size = UDim2.new(1, nameLabelWidthOffset, 1, 0),
			BackgroundTransparency = 1,
			Text = player.DisplayName or player.Name,
			Parent = playerRow,
		})
		applyFont(nameLabel, 14, Color3.fromRGB(220, 220, 225), Enum.TextXAlignment.Left)

		if numButtons > 0 then
			local buttonsContainer = make("Frame", {
				Name = "ButtonsContainer",
				Position = UDim2.new(1, -10 - buttonsContainerWidth, 0.5, -15),
				Size = UDim2.fromOffset(buttonsContainerWidth, 30),
				BackgroundTransparency = 1,
				Parent = playerRow,
			})

			local buttonsLayout = Instance.new("UIListLayout")
			buttonsLayout.FillDirection = Enum.FillDirection.Horizontal
			buttonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
			buttonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			buttonsLayout.Padding = UDim.new(0, 6)
			buttonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
			buttonsLayout.Parent = buttonsContainer

			local rowButtons = {}
			playerRowButtons[player] = rowButtons

			for i, btnConfig in ipairs(customButtons) do
				local btn = make("TextButton", {
					Name = btnConfig.text or "Btn",
					Size = UDim2.fromOffset(54, 30),
					BackgroundColor3 = Color3.fromRGB(30, 30, 36),
					BorderSizePixel = 0,
					Text = btnConfig.text or "",
					LayoutOrder = i,
					Parent = buttonsContainer,
				})
				addCorner(btn, 4)
				local btnStroke = addStroke(btn, Color3.fromRGB(50, 50, 58), 0.5, 1)
				applyFont(btn, 13, Color3.fromRGB(220, 220, 225), Enum.TextXAlignment.Center)

				table.insert(rowButtons, btn)

				if btnConfig.type == "toggle" then
					local state = btnConfig.default == true
					local function updateColors(animate)
						local targetBg, targetStroke
						if state then
							targetBg = utils.theme.AccentColor
							targetStroke = utils.theme.AccentColor
							activeToggleButtons[btn] = btnStroke
						else
							targetBg = Color3.fromRGB(30, 30, 36)
							targetStroke = Color3.fromRGB(50, 50, 58)
							activeToggleButtons[btn] = nil
						end

						if animate then
							tween(btn, { BackgroundColor3 = targetBg }, 0.12):Play()
							tween(btnStroke, { Color = targetStroke }, 0.12):Play()
						else
							btn.BackgroundColor3 = targetBg
							btnStroke.Color = targetStroke
						end
					end

					updateColors(false)

					btn.Activated:Connect(function()
						state = not state
						updateColors(true)
						if btnConfig.callback then
							task.spawn(btnConfig.callback, player, state)
						end
					end)
				else
					btn.Activated:Connect(function()
						if btnConfig.callback then
							task.spawn(btnConfig.callback, player)
						end
					end)
				end
			end
		end

		playerRows[player] = playerRow
	end

	local function removePlayerRow(player)
		local rowFrame = playerRows[player]
		if rowFrame then
			rowFrame:Destroy()
			playerRows[player] = nil
		end
		
		local rowButtons = playerRowButtons[player]
		if rowButtons then
			for _, btn in ipairs(rowButtons) do
				activeToggleButtons[btn] = nil
			end
			playerRowButtons[player] = nil
		end
	end

	for _, p in ipairs(Players:GetPlayers()) do
		addPlayerRow(p)
	end

	local addedConn = Players.PlayerAdded:Connect(addPlayerRow)
	local removingConn = Players.PlayerRemoving:Connect(removePlayerRow)

	local themeConn
	themeConn = utils.onThemeChanged(function(key, color)
		if key == "AccentColor" then
			for btn, stroke in pairs(activeToggleButtons) do
				btn.BackgroundColor3 = color
				stroke.Color = color
			end
		end
	end)

	return {
		Destroy = function()
			addedConn:Disconnect()
			removingConn:Disconnect()
			if themeConn and themeConn.Disconnect then
				themeConn:Disconnect()
			end
			for p in pairs(playerRows) do
				removePlayerRow(p)
			end
			container:Destroy()
		end
	}
end
