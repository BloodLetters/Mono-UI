local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = workspace

local Util = require("./Util")

local Esp = {}
Esp.__index = Esp

--- @param options table – shared config (read by UpdateEsp each frame)
function Esp.new(options)
	local self = setmetatable({}, Esp)

	self._options = options
	self._players = {}

	self._highlightsFolder = Workspace:FindFirstChild("VanityEspHighlights")
	if not self._highlightsFolder then
		self._highlightsFolder = Instance.new("Folder")
		self._highlightsFolder.Name = "VanityEspHighlights"
		self._highlightsFolder.Parent = Workspace
	end

	self._connections = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			self:_createEsp(player)
		end
	end

	-- Track joins / leaves / respawns
	self._connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
		if player ~= LocalPlayer then
			self:_createEsp(player)
			-- Handle respawn: ensure ESP exists
			self._connections[player] = player.CharacterAdded:Connect(function()
				if player ~= LocalPlayer then
					self:_createEsp(player)
				end
			end)
		end
	end)

	self._connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
		self:_removeEsp(player)
		if self._connections[player] then
			self._connections[player]:Disconnect()
			self._connections[player] = nil
		end
	end)

	-- CharacterAdded for existing players
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			self._connections[player] = player.CharacterAdded:Connect(function()
				if player ~= LocalPlayer then
					self:_createEsp(player)
				end
			end)
		end
	end

	-- Bind to RenderStepped
	local camera = Workspace.CurrentCamera
	self._renderConnection = RunService.RenderStepped:Connect(function()
		self:_updateEsp(camera)
	end)

	return self
end

function Esp:_createEsp(player)
	if self._players[player] then
		return
	end

	local box = Drawing.new("Square")
	box.Visible = false
	box.Color = self._options.BoxColor or Color3.fromRGB(160, 160, 160)
	box.Thickness = 1.5
	box.Filled = false

	local boxOutline = Drawing.new("Square")
	boxOutline.Visible = false
	boxOutline.Color = self._options.BoxOutlineColor or Color3.fromRGB(60, 60, 60)
	boxOutline.Thickness = 2.5
	boxOutline.Filled = false

	local healthBarOutline = Drawing.new("Line")
	healthBarOutline.Visible = false
	healthBarOutline.Color = Color3.fromRGB(0, 0, 0)
	healthBarOutline.Thickness = 2.5

	local healthBar = Drawing.new("Line")
	healthBar.Visible = false
	healthBar.Color = Color3.fromRGB(0, 255, 0)
	healthBar.Thickness = 1.5

	local nameText = Drawing.new("Text")
	nameText.Visible = false
	nameText.Color = self._options.NameColor or Color3.fromRGB(255, 255, 255)
	nameText.Size = self._options.NameSize or 13
	nameText.Center = true
	nameText.Outline = true

	local highlight = Instance.new("Highlight")
	highlight.FillColor = self._options.HighlightColor or Color3.fromRGB(0, 162, 255)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.6
	highlight.OutlineTransparency = 0.1
	highlight.Enabled = false
	highlight.Parent = self._highlightsFolder

	self._players[player] = {
		Box = box,
		BoxOutline = boxOutline,
		HealthBarOutline = healthBarOutline,
		HealthBar = healthBar,
		NameText = nameText,
		Highlight = highlight,
	}
end

function Esp:_removeEsp(player)
	local data = self._players[player]
	if not data then
		return
	end
	data.Box:Remove()
	data.BoxOutline:Remove()
	data.HealthBarOutline:Remove()
	data.HealthBar:Remove()
	data.NameText:Remove()
	if data.Highlight then
		pcall(function()
			data.Highlight:Destroy()
		end)
	end
	self._players[player] = nil
end

function Esp:_hideAll(data)
	data.Box.Visible = false
	data.BoxOutline.Visible = false
	data.HealthBar.Visible = false
	data.HealthBarOutline.Visible = false
	data.NameText.Visible = false
	data.Highlight.Enabled = false
end

function Esp:_updateEsp(camera)
	local opts = self._options
	local camPos = camera.CFrame.Position

	-- Customizable part lookups (default = standard R6/R15)
	local headLookup = opts.HeadPart or "Head"
	local rootLookup = opts.RootPart or "HumanoidRootPart"
	local healthClass = opts.HealthClass or "Humanoid"
	local isValid = opts.IsValid -- optional custom validity function

	for player, data in pairs(self._players) do
		local character = player.Character
		local rootPart = Util.FindPart(character, rootLookup)
		local headPart = Util.FindPart(character, headLookup)
		local healthObj = character and character:FindFirstChildOfClass(healthClass)

		-- Validity check: default or custom
		local alive
		if isValid then
			alive = isValid(character)
		else
			alive = (rootPart and healthObj and healthObj.Health > 0)
		end

		if not alive then
			self:_hideAll(data)
			continue
		end

		local dist = (rootPart.Position - camPos).Magnitude
		local maxDist = opts.MaxDistance or 1000
		if dist > maxDist then
			self:_hideAll(data)
			continue
		end

		-- Highlight (Cham)
		if opts.HighlightEnabled then
			data.Highlight.Adornee = character
			if opts.VisibilityColor then
				local visible = Util.IsVisible(camera, rootPart, LocalPlayer.Character)
				data.Highlight.FillColor = visible
						and (opts.HighlightColor or Color3.fromRGB(0, 162, 255))
					or (opts.VisibleColor or Color3.fromRGB(255, 230, 0))
			else
				data.Highlight.FillColor = opts.HighlightColor or Color3.fromRGB(0, 162, 255)
			end
			data.Highlight.Enabled = true
		else
			data.Highlight.Enabled = false
			data.Highlight.Adornee = nil
		end

		-- Customizable box offsets (relative to root part)
		local topOffset = opts.BoxTopOffset or Vector3.new(0, 3, 0)
		local botOffset = opts.BoxBottomOffset or Vector3.new(0, -3.5, 0)

		local topPos, topOn = camera:WorldToViewportPoint((rootPart.CFrame * CFrame.new(topOffset)).Position)
		local botPos, botOn = camera:WorldToViewportPoint((rootPart.CFrame * CFrame.new(botOffset)).Position)

		if not (topOn or botOn) then
			data.Box.Visible = false
			data.BoxOutline.Visible = false
			data.HealthBar.Visible = false
			data.HealthBarOutline.Visible = false
			data.NameText.Visible = false
			continue
		end

		local h = math.abs(topPos.Y - botPos.Y)
		local w = h / 2
		local x = topPos.X - w / 2
		local y = topPos.Y

		-- Box ESP
		local showBox = opts.BoxEnabled
		data.Box.Visible = showBox
		data.BoxOutline.Visible = showBox
		if showBox then
			data.Box.Size = Vector2.new(w, h)
			data.Box.Position = Vector2.new(x, y)
			data.Box.Color = opts.BoxColor or Color3.fromRGB(160, 160, 160)
			data.BoxOutline.Size = Vector2.new(w, h)
			data.BoxOutline.Position = Vector2.new(x, y)
			data.BoxOutline.Color = opts.BoxOutlineColor or Color3.fromRGB(60, 60, 60)
		end

		-- Name ESP
		local showName = opts.NameEnabled
		data.NameText.Visible = showName
		if showName then
			data.NameText.Text = string.format("%s [%d]", player.Name, math.floor(dist))
			data.NameText.Position = Vector2.new(topPos.X, y - 18)
			data.NameText.Color = opts.NameColor or Color3.fromRGB(255, 255, 255)
			data.NameText.Size = opts.NameSize or 13
		end

		-- Health Bar ESP
		local showHealth = opts.HealthEnabled
		data.HealthBar.Visible = showHealth
		data.HealthBarOutline.Visible = showHealth
		if showHealth then
			local hpFrac = math.clamp(healthObj.Health / healthObj.MaxHealth, 0, 1)
			local barX = x - 6
			data.HealthBarOutline.From = Vector2.new(barX, y + h)
			data.HealthBarOutline.To = Vector2.new(barX, y)
			data.HealthBar.From = Vector2.new(barX, y + h)
			data.HealthBar.To = Vector2.new(barX, y + h - (h * hpFrac))
			data.HealthBar.Color = Color3.new(1 - hpFrac, hpFrac, 0)
		end
	end
end

function Esp:UpdateOptions(options)
	self._options = options
end

--- Full cleanup: disconnect events, remove all drawings & highlights
function Esp:Destroy()
	if self._renderConnection then
		self._renderConnection:Disconnect()
		self._renderConnection = nil
	end
	
    -- Disconnect player events
	for _, conn in pairs(self._connections) do
		if typeof(conn) == "RBXScriptConnection" then
			conn:Disconnect()
		end
	end
	self._connections = {}
	
    -- Remove ESP for all tracked players
	for player, _ in pairs(self._players) do
		self:_removeEsp(player)
	end

	-- Clean up highlights folder
	if self._highlightsFolder then
		pcall(function()
			self._highlightsFolder:Destroy()
		end)
		self._highlightsFolder = nil
	end
end

return Esp
