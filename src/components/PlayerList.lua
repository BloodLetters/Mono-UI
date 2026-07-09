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
	local espStates = {}
	local espHighlights = {}
	local characterConns = {}

	local function teleportTo(targetPlayer)
		local localPlayer = Players.LocalPlayer
		if not localPlayer then return end
		local targetChar = targetPlayer.Character
		local localChar = localPlayer.Character
		if targetChar and localChar then
			local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
			local localRoot = localChar:FindFirstChild("HumanoidRootPart")
			if targetRoot and localRoot then
				localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -3)
			end
		end
	end

	local function toggleESP(player, state)
		espStates[player] = state
		if state then
			local function applyHighlight(char)
				if not char then return end
				local existing = char:FindFirstChild("MonoESP")
				if existing then existing:Destroy() end

				local hl = Instance.new("Highlight")
				hl.Name = "MonoESP"
				hl.FillColor = utils.theme.AccentColor
				hl.FillTransparency = 0.5
				hl.OutlineColor = Color3.fromRGB(255, 255, 255)
				hl.OutlineTransparency = 0
				hl.Adornee = char
				hl.Parent = char
				espHighlights[player] = hl
			end

			local char = player.Character
			if char then
				applyHighlight(char)
			end

			if characterConns[player] then characterConns[player]:Disconnect() end
			characterConns[player] = player.CharacterAdded:Connect(function(newChar)
				task.wait(0.5)
				applyHighlight(newChar)
			end)
		else
			local hl = espHighlights[player]
			if hl then pcall(function() hl:Destroy() end) end
			espHighlights[player] = nil

			if characterConns[player] then
				characterConns[player]:Disconnect()
				characterConns[player] = nil
			end
		end
	end

	local function addPlayerRow(player)
		if playerRows[player] then return end
		if player == Players.LocalPlayer then return end

		local playerRow = make("Frame", {
			Name = player.Name,
			Size = UDim2.new(1, 0, 0, 44),
			BackgroundColor3 = Color3.fromRGB(22, 22, 26),
			BorderSizePixel = 0,
			Parent = scroll,
		})
		addCorner(playerRow, 6)
		addStroke(playerRow, Color3.fromRGB(40, 40, 48), 0.5, 1)

		local nameLabel = make("TextLabel", {
			Position = UDim2.fromOffset(8, 0),
			Size = UDim2.new(1, -120, 1, 0),
			BackgroundTransparency = 1,
			Text = player.DisplayName or player.Name,
			Parent = playerRow,
		})
		applyFont(nameLabel, 14, Color3.fromRGB(220, 220, 225), Enum.TextXAlignment.Left)

		local tpBtn = make("TextButton", {
			Name = "TP",
			Position = UDim2.new(1, -106, 0.5, -18),
			Size = UDim2.fromOffset(50, 36),
			BackgroundColor3 = Color3.fromRGB(30, 30, 36),
			BorderSizePixel = 0,
			Text = "TP",
			Parent = playerRow,
		})
		addCorner(tpBtn, 4)
		addStroke(tpBtn, Color3.fromRGB(50, 50, 58), 0.5, 1)
		applyFont(tpBtn, 14, Color3.fromRGB(220, 220, 225), Enum.TextXAlignment.Center)

		tpBtn.MouseButton1Click:Connect(function()
			teleportTo(player)
		end)

		local espBtn = make("TextButton", {
			Name = "ESP",
			Position = UDim2.new(1, -50, 0.5, -18),
			Size = UDim2.fromOffset(44, 36),
			BackgroundColor3 = Color3.fromRGB(30, 30, 36),
			BorderSizePixel = 0,
			Text = "ESP",
			Parent = playerRow,
		})
		addCorner(espBtn, 4)
		local espStroke = addStroke(espBtn, Color3.fromRGB(50, 50, 58), 0.5, 1)
		applyFont(espBtn, 14, Color3.fromRGB(220, 220, 225), Enum.TextXAlignment.Center)

		espBtn.MouseButton1Click:Connect(function()
			local isEspActive = not (espStates[player] == true)
			toggleESP(player, isEspActive)
			local targetBgColor = isEspActive and utils.theme.AccentColor or Color3.fromRGB(30, 30, 36)
			local targetStrokeColor = isEspActive and utils.theme.AccentColor or Color3.fromRGB(50, 50, 58)
			
			tween(espBtn, { BackgroundColor3 = targetBgColor }, 0.12):Play()
			tween(espStroke, { Color = targetStrokeColor }, 0.12):Play()
		end)

		playerRows[player] = playerRow
	end

	local function removePlayerRow(player)
		local rowFrame = playerRows[player]
		if rowFrame then
			rowFrame:Destroy()
			playerRows[player] = nil
		end
		toggleESP(player, false)
	end

	for _, p in ipairs(Players:GetPlayers()) do
		addPlayerRow(p)
	end

	local addedConn = Players.PlayerAdded:Connect(addPlayerRow)
	local removingConn = Players.PlayerRemoving:Connect(removePlayerRow)

	local themeConn
	themeConn = utils.onThemeChanged(function(key, color)
		if key == "AccentColor" then
			for player, hl in pairs(espHighlights) do
				hl.FillColor = color
			end
		end
	end)

	return {
		Destroy = function()
			addedConn:Disconnect()
			removingConn:Disconnect()
			themeConn:Disconnect()
			for p in pairs(playerRows) do
				removePlayerRow(p)
			end
			container:Destroy()
		end
	}
end
