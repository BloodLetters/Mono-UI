local Util = require("./Util")
local Cache = require("./Cache")
local Notification = require("./Notification")

local UI = {}

function UI.build(self)
	local parentGui = Util.getGuiParent()
	if not parentGui then
		warn("Guard Key System: Failed to locate ScreenGui parent.")
		return
	end

	local windowWidth = 440
	local windowHeight = 190

	local logoName = tostring(self._options.Logo):lower()
	local hasLogo = logoName ~= "" and logoName ~= "none"
	local iconAsset = "rbxassetid://16898613509"
	local rectOffset = Vector2.new(918, 857) -- default lock
	local rectSize = Vector2.new(48, 48)

	if logoName == "key" then
		rectOffset = Vector2.new(869, 404)
	elseif logoName == "shield-check" or logoName == "shield" then
		iconAsset = "rbxassetid://16898613777"
		rectOffset = Vector2.new(820, 257)
	elseif logoName == "shield-x" then
		iconAsset = "rbxassetid://16898613777"
		rectOffset = Vector2.new(514, 820)
	elseif logoName == "shield-alert" then
		iconAsset = "rbxassetid://16898613777"
		rectOffset = Vector2.new(49, 771)
	end

	local screenGui = Util.make("ScreenGui", {
		Name = "GuardKeySystem",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 1001,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = parentGui,
	})
	self._screenGui = screenGui

	local mainFrame = Util.make("Frame", {
		Name = "MainFrame",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(windowWidth, windowHeight),
		BackgroundColor3 = Color3.fromRGB(16, 16, 18),
		BorderSizePixel = 0,
		Active = true,
		Parent = screenGui,
	})
	self._mainFrame = mainFrame
	Util.addCorner(mainFrame, 10)
	Util.addStroke(mainFrame, Color3.fromRGB(60, 60, 68), 0.3, 1)

	local topBar = Util.make("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundTransparency = 1,
		Parent = mainFrame,
	})
	Util.connectDrag(topBar, mainFrame)

	if hasLogo then
		Util.make("ImageLabel", {
			Name = "Logo",
			Position = UDim2.fromOffset(14, 10),
			Size = UDim2.fromOffset(28, 28),
			BackgroundTransparency = 1,
			Image = iconAsset,
			ImageRectOffset = rectOffset,
			ImageRectSize = rectSize,
			ImageColor3 = Color3.fromRGB(242, 242, 242),
			Parent = topBar,
		})
	end

	local cleanFont = Font.fromEnum(Enum.Font.Montserrat)
	local cleanFontBold = Font.fromEnum(Enum.Font.MontserratBold)

	local titleLabel = Util.make("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(hasLogo and 50 or 15, 12),
		Size = UDim2.new(1, hasLogo and -95 or -60, 0, 16),
		Text = self._options.Title,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 14,
		FontFace = cleanFontBold,
		BackgroundTransparency = 1,
		Parent = topBar,
	})

	local subtitleLabel = Util.make("TextLabel", {
		Name = "Subtitle",
		Position = UDim2.fromOffset(hasLogo and 50 or 15, 28),
		Size = UDim2.new(1, hasLogo and -95 or -60, 0, 12),
		Text = self._options.Subtitle,
		TextColor3 = Color3.fromRGB(140, 140, 145),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 11,
		FontFace = cleanFont,
		BackgroundTransparency = 1,
		Parent = topBar,
	})

	local closeBtn = Util.make("TextButton", {
		Name = "Close",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(26, 26),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "×",
		TextColor3 = Color3.fromRGB(150, 150, 155),
		TextSize = 20,
		FontFace = cleanFont,
		AutoButtonColor = false,
		Parent = topBar,
	})
	Util.addCorner(closeBtn, 6)

	local TweenService = game:GetService("TweenService")
	closeBtn.MouseEnter:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.2), {
			BackgroundTransparency = 0.9,
			BackgroundColor3 = Color3.fromRGB(255, 75, 75),
			TextColor3 = Color3.fromRGB(255, 100, 100)
		}):Play()
	end)
	closeBtn.MouseLeave:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.2), {
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(150, 150, 155)
		}):Play()
	end)
	closeBtn.MouseButton1Click:Connect(function()
		self:Destroy()
	end)

	local colDivider = Util.make("Frame", {
		Name = "ColDivider",
		Position = UDim2.fromOffset(220, 60),
		Size = UDim2.fromOffset(1, 50),
		BackgroundColor3 = Color3.fromRGB(40, 40, 46),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Parent = mainFrame,
	})

	local leftCol = Util.make("Frame", {
		Name = "LeftColumn",
		Position = UDim2.fromOffset(15, 55),
		Size = UDim2.fromOffset(190, 60),
		BackgroundTransparency = 1,
		Parent = mainFrame,
	})

	Util.make("TextLabel", {
		Name = "KeyLabel",
		Size = UDim2.new(1, 0, 0, 14),
		Text = "Key",
		TextColor3 = Color3.fromRGB(140, 140, 145),
		TextSize = 11,
		FontFace = cleanFontBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Parent = leftCol,
	})

	local inputContainer = Util.make("Frame", {
		Name = "InputContainer",
		Position = UDim2.fromOffset(0, 18),
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = Color3.fromRGB(20, 20, 24),
		BorderSizePixel = 0,
		Parent = leftCol,
	})
	Util.addCorner(inputContainer, 6)
	local inputStroke = Util.addStroke(inputContainer, Color3.fromRGB(45, 45, 52), 0.5, 1)

	local keyTextBox = Util.make("TextBox", {
		Name = "KeyTextBox",
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -16, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = "Password",
		PlaceholderColor3 = Color3.fromRGB(80, 80, 85),
		TextColor3 = Color3.fromRGB(235, 235, 240),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 12,
		FontFace = cleanFont,
		ClearTextOnFocus = false,
		Parent = inputContainer,
	})

	keyTextBox.Focused:Connect(function()
		TweenService:Create(inputStroke, TweenInfo.new(0.2), { Color = self._options.AccentColor }):Play()
	end)
	keyTextBox.FocusLost:Connect(function()
		TweenService:Create(inputStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(45, 45, 52) }):Play()
	end)

	local rightCol = Util.make("Frame", {
		Name = "RightColumn",
		Position = UDim2.fromOffset(235, 55),
		Size = UDim2.fromOffset(190, 60),
		BackgroundTransparency = 1,
		Parent = mainFrame,
	})

	Util.make("TextLabel", {
		Name = "NoteLabel",
		Size = UDim2.new(1, 0, 0, 14),
		Text = "Note",
		TextColor3 = Color3.fromRGB(140, 140, 145),
		TextSize = 11,
		FontFace = cleanFontBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Parent = rightCol,
	})

	local discord = self._options.DiscordUrl ~= nil and tostring(self._options.DiscordUrl) ~= "" and tostring(self._options.DiscordUrl) or "discord.gg/epichub"
	local defaultNote = "Join our Discord server to get the key! " .. discord
	local noteTextString = self._options.NoteText ~= nil and tostring(self._options.NoteText) ~= "" and tostring(self._options.NoteText) or defaultNote

	local noteBtn = Util.make("TextButton", {
		Name = "NoteButton",
		Position = UDim2.fromOffset(0, 18),
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = noteTextString,
		TextColor3 = Color3.fromRGB(140, 140, 145),
		TextSize = 11,
		FontFace = cleanFont,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		AutoButtonColor = false,
		Parent = rightCol,
	})

	noteBtn.MouseEnter:Connect(function()
		TweenService:Create(noteBtn, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
	end)
	noteBtn.MouseLeave:Connect(function()
		TweenService:Create(noteBtn, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(140, 140, 145) }):Play()
	end)

	local statusLabel
	noteBtn.MouseButton1Click:Connect(function()
		local linkToCopy = self._options.DiscordUrl ~= "" and self._options.DiscordUrl or discord
		local copied = Util.copyToClipboard(linkToCopy)
		if copied then
			statusLabel.Text = "copied discord invite to clipboard!"
			statusLabel.TextColor3 = self._options.AccentColor
			Notification.new({
				Title = "Clipboard Success",
				Content = "Discord invite link copied to clipboard!",
				Type = "Success",
				AccentColor = self._options.AccentColor
			})
		else
			statusLabel.Text = "failed to copy! link: " .. tostring(linkToCopy):sub(1, 24) .. "..."
			statusLabel.TextColor3 = Color3.fromRGB(220, 160, 80)
			Notification.new({
				Title = "Clipboard Error",
				Content = "Failed to copy Discord link! Please check console.",
				Type = "Error",
				AccentColor = self._options.AccentColor
			})
		end
		task.delay(3, function()
			if statusLabel.Text == "copied discord invite to clipboard!" or statusLabel.Text:match("^failed to copy!") then
				statusLabel.Text = "awaiting verification"
				statusLabel.TextColor3 = Color3.fromRGB(110, 110, 115)
			end
		end)
	end)

	statusLabel = Util.make("TextLabel", {
		Name = "StatusLabel",
		Position = UDim2.fromOffset(20, 115),
		Size = UDim2.new(1, -40, 0, 14),
		Text = "awaiting verification",
		TextColor3 = Color3.fromRGB(110, 110, 115),
		TextSize = 11,
		FontFace = cleanFont,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = mainFrame,
	})

	local buttonsContainer = Util.make("Frame", {
		Name = "ButtonsContainer",
		Position = UDim2.fromOffset(20, 135),
		Size = UDim2.new(1, -40, 0, 36),
		BackgroundTransparency = 1,
		Parent = mainFrame,
	})

	local loginBtn = Util.make("TextButton", {
		Name = "LoginButton",
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(190, 34),
		BackgroundColor3 = Color3.fromRGB(22, 22, 26),
		BorderSizePixel = 0,
		Text = "Login",
		TextColor3 = Color3.fromRGB(180, 180, 185),
		TextSize = 12,
		FontFace = cleanFont,
		AutoButtonColor = false,
		Parent = buttonsContainer,
	})
	Util.addCorner(loginBtn, 6)
	local loginStroke = Util.addStroke(loginBtn, Color3.fromRGB(45, 45, 52), 0.3, 1)

	loginBtn.MouseEnter:Connect(function()
		TweenService:Create(loginBtn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(28, 28, 34), TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
		TweenService:Create(loginStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(70, 70, 78) }):Play()
	end)
	loginBtn.MouseLeave:Connect(function()
		TweenService:Create(loginBtn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(22, 22, 26), TextColor3 = Color3.fromRGB(180, 180, 185) }):Play()
		TweenService:Create(loginStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(45, 45, 52) }):Play()
	end)

	local isVerifying = false
	loginBtn.MouseButton1Click:Connect(function()
		if isVerifying then return end
		isVerifying = true

		task.spawn(function()
			statusLabel.Text = "checking key..."
			statusLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
			task.wait(0.4)

			local entered = keyTextBox.Text:match("^%s*(.-)%s*$")
			local isValid = self:_validate(entered)

			if isValid then
				print("Guard: Key is valid!")
				statusLabel.Text = "verification successful!"
				statusLabel.TextColor3 = Color3.fromRGB(80, 220, 80)
				Cache.saveCachedKey(self._options.ConfigName, entered)

				Notification.new({
					Title = "Access Granted",
					Content = "Key verification successful. Loading...",
					Type = "Success",
					AccentColor = self._options.AccentColor
				})

				print("Guard: OnSuccess type is:", type(self._options.OnSuccess))
				if self._options.OnSuccess then
					task.spawn(function()
						print("Guard: Spawning OnSuccess...")
						local ok, err = pcall(self._options.OnSuccess)
						if not ok then
							warn("Guard: OnSuccess crashed:", tostring(err))
						end
					end)
				end

				TweenService:Create(mainFrame, TweenInfo.new(0.3), { BackgroundColor3 = Color3.fromRGB(12, 32, 16) }):Play()
				task.wait(0.5)

				self:Destroy()
			else
				statusLabel.Text = "invalid key! please try again."
				statusLabel.TextColor3 = Color3.fromRGB(220, 80, 80)

				Notification.new({
					Title = "Access Denied",
					Content = "The key you entered is invalid. Please try again.",
					Type = "Error",
					AccentColor = self._options.AccentColor
				})

				local originalPos = mainFrame.Position
				task.spawn(function()
					for i = 1, 6 do
						local offset = (i % 2 == 0) and 4 or -4
						mainFrame.Position = originalPos + UDim2.fromOffset(offset, 0)
						task.wait(0.04)
					end
					mainFrame.Position = originalPos
				end)

				isVerifying = false
			end
		end)
	end)

	local getKeyBtn = Util.make("TextButton", {
		Name = "GetKeyButton",
		Position = UDim2.fromOffset(210, 0),
		Size = UDim2.fromOffset(190, 34),
		BackgroundColor3 = Color3.fromRGB(22, 22, 26),
		BorderSizePixel = 0,
		Text = "Get Key",
		TextColor3 = Color3.fromRGB(180, 180, 185),
		TextSize = 12,
		FontFace = cleanFont,
		AutoButtonColor = false,
		Parent = buttonsContainer,
	})
	Util.addCorner(getKeyBtn, 6)
	local getKeyStroke = Util.addStroke(getKeyBtn, Color3.fromRGB(45, 45, 52), 0.3, 1)

	getKeyBtn.MouseEnter:Connect(function()
		TweenService:Create(getKeyBtn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(28, 28, 34), TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
		TweenService:Create(getKeyStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(70, 70, 78) }):Play()
	end)
	getKeyBtn.MouseLeave:Connect(function()
		TweenService:Create(getKeyBtn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(22, 22, 26), TextColor3 = Color3.fromRGB(180, 180, 185) }):Play()
		TweenService:Create(getKeyStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(45, 45, 52) }):Play()
	end)

	getKeyBtn.MouseButton1Click:Connect(function()
		local link = self._options.GetKeyUrl ~= "" and self._options.GetKeyUrl or "https://example.com/get-key"
		local copied = Util.copyToClipboard(link)
		if copied then
			statusLabel.Text = "copied get-key URL to clipboard!"
			statusLabel.TextColor3 = self._options.AccentColor
			Notification.new({
				Title = "Clipboard Success",
				Content = "Key URL copied to clipboard!",
				Type = "Success",
				AccentColor = self._options.AccentColor
			})
		else
			statusLabel.Text = "failed to copy! link: " .. tostring(link):sub(1, 24) .. "..."
			statusLabel.TextColor3 = Color3.fromRGB(220, 160, 80)
			Notification.new({
				Title = "Clipboard Error",
				Content = "Failed to copy key URL!",
				Type = "Error",
				AccentColor = self._options.AccentColor
			})
		end
		task.delay(3, function()
			if statusLabel.Text == "copied get-key URL to clipboard!" or statusLabel.Text:match("^failed to copy!") then
				statusLabel.Text = "awaiting verification"
				statusLabel.TextColor3 = Color3.fromRGB(110, 110, 115)
			end
		end)
	end)

	mainFrame.Size = UDim2.fromOffset(windowWidth, 0)
	mainFrame.ClipsDescendants = true
	TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(windowWidth, windowHeight)
	}):Play()
	task.delay(0.5, function()
		mainFrame.ClipsDescendants = false
	end)
end

return UI
