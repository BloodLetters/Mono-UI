local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = workspace

local Util = require("./Util")

local Trigger = {}
Trigger.__index = Trigger

--- @param options table
--- @param aimModule table? – optional reference to Aim for silent aim integration
function Trigger.new(options, aimModule)
	local self = setmetatable({}, Trigger)
	self._options = options
	self._aimModule = aimModule
	self._active = false
	self._connections = {}
	self._lastShot = 0
	return self
end

--- Start the trigger bot loop
function Trigger:Start()
	if self._active then return end
	self._active = true

	self._connections.render = RunService.RenderStepped:Connect(function(dt)
		self:_step(dt)
	end)
end

--- Stop the trigger bot loop
function Trigger:Stop()
	self._active = false
	if self._connections.render then
		self._connections.render:Disconnect()
		self._connections.render = nil
	end
end

function Trigger:UpdateOptions(opts)
	for k, v in pairs(opts) do
		self._options[k] = v
	end
end

function Trigger:_step(dt)
	local opts = self._options
	if not opts.TriggerEnabled then return end

	local camera = Workspace.CurrentCamera
	if not camera then return end

	-- Check activation key
	local triggerKey = opts.TriggerKey
	if triggerKey and triggerKey ~= "always" then
		if typeof(triggerKey) == "function" then
			if not triggerKey() then return end
		elseif typeof(triggerKey) == "EnumItem" then
			local pressed = false
			if triggerKey.EnumType == Enum.UserInputType then
				pressed = UserInputService:IsMouseButtonPressed(triggerKey)
			else
				pressed = UserInputService:IsKeyDown(triggerKey)
			end
			if not pressed then return end
		end
	end

	-- Delay / firerate control
	local delayMs = opts.Delay or 50
	local now = tick() * 1000
	if now - self._lastShot < delayMs then return end

	-- Determine target part
	local targetLookup = opts.TriggerTargetPart or "Head"
	local healthClass = opts.HealthClass or "Humanoid"
	local isTargetValid = opts.IsTargetValid
	local wallCheck = opts.TriggerWallCheck
	local wallIgnore = opts.WallCheckIgnoreList
	local maxDist = opts.TriggerMaxDistance or 1000
	local fovRadius = opts.TriggerFovRadius or 50

	local localCharacter = LocalPlayer.Character
	if not localCharacter then return end

	local camPos = camera.CFrame.Position

	for _, player in ipairs(Util.GetPlayers()) do
		local character = player.Character
		if not character then continue end

		-- Validity
		if isTargetValid then
			if not isTargetValid(player, character) then continue end
		elseif not Util.IsAlive(character, healthClass) then
			continue
		end

		local targetPart = Util.FindPart(character, targetLookup)
		if not targetPart then continue end

		-- Distance
		local dist = (targetPart.Position - camPos).Magnitude
		if dist > maxDist then continue end

		-- FOV check (is part near crosshair?)
		local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
		if not onScreen then continue end

		local screenCenter = camera.ViewportSize / 2
		local dx = screenPos.X - screenCenter.X
		local dy = screenPos.Y - screenCenter.Y
		if math.sqrt(dx * dx + dy * dy) > fovRadius then continue end

		-- Wall check
		if wallCheck and not Util.IsVisible(camera, targetPart, localCharacter, wallIgnore) then
			continue
		end

		-- Custom pre-fire callback
		if opts.BeforeFire then
			local shouldFire = opts.BeforeFire(player, character, targetPart)
			if not shouldFire then continue end
		end

		-- Fire!
		local fireFn = opts.Fire
		if fireFn then
			fireFn()
		else
			-- Default: simulate mouse click
			mouse1click()
		end

		self._lastShot = tick() * 1000

		-- Post-fire callback
		if opts.AfterFire then
			opts.AfterFire(player, character, targetPart)
		end

		-- One shot per frame
		break
	end
end

function Trigger:Destroy()
	self:Stop()
end

return Trigger
