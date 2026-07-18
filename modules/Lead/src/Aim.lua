local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = workspace

local Util = require("./Util")

local Aim = {}
Aim.__index = Aim

--- @param options table
function Aim.new(options)
	local self = setmetatable({}, Aim)
	self._options = options
	self._active = false
	self._target = nil -- sticky target
	self._connections = {}

	return self
end

--- Start the aimbot loop (binds to RenderStepped)
function Aim:Start()
	if self._active then return end
	self._active = true

	self._connections.render = RunService.RenderStepped:Connect(function(dt)
		self:_step(dt)
	end)
end

--- Stop the aimbot loop
function Aim:Stop()
	self._active = false
	self._target = nil
	if self._connections.render then
		self._connections.render:Disconnect()
		self._connections.render = nil
	end
end

--- Update options dynamically
function Aim:UpdateOptions(opts)
	for k, v in pairs(opts) do
		self._options[k] = v
	end
end

function Aim:_step(dt)
	local opts = self._options
	if not opts.AimEnabled then
		self._target = nil
		return
	end

	local camera = Workspace.CurrentCamera
	if not camera then return end

	-- Determine activation key
	local aimKey = opts.AimKey
	if aimKey == "always" then
		-- always active (e.g., silent aim)
	elseif typeof(aimKey) == "function" then
		-- Custom activation check
		if not aimKey() then
			self._target = nil
			return
		end
	else
		-- Default: Enum.UserInputType or Enum.KeyCode
		local inputType = typeof(aimKey) == "EnumItem" and aimKey
		if inputType then
			local pressed = false
			if inputType.EnumType == Enum.UserInputType then
				pressed = UserInputService:IsMouseButtonPressed(inputType)
			else
				pressed = UserInputService:IsKeyDown(inputType)
			end
			if not pressed then
				self._target = nil
				return
			end
		end
	end

	-- Sticky target: keep locked if still valid
	local sticky = opts.StickyTarget
	if sticky and self._target then
		local player = self._target.player
		local part = self._target.part
		local character = player and player.Character
		if character then
			local targetLookup = opts.TargetPart or "Head"
			local currentPart = Util.FindPart(character, targetLookup)
			local healthClass = opts.HealthClass or "Humanoid"
			local isValid = opts.IsTargetValid
			local alive = isValid and isValid(player, character)
				or Util.IsAlive(character, healthClass)

			if alive and currentPart then
				local dist = (part.Position - camera.CFrame.Position).Magnitude
				local maxDist = opts.MaxDistance or math.huge
				if dist <= maxDist then
					-- Sticky still valid — but check wall
					if not opts.WallCheck or Util.IsVisible(camera, currentPart, LocalPlayer.Character, opts.WallCheckIgnoreList) then
						self._target.part = currentPart
						self:_aimAt(currentPart, dt)
						return
					end
				end
			end
		end
		self._target = nil
	end

	-- Find new target
	local targetLookup = opts.TargetPart or "Head"
	local healthClass = opts.HealthClass or "Humanoid"
	local fovRadius = opts.FovRadius or 150
	local wallCheck = opts.WallCheck
	local wallIgnore = opts.WallCheckIgnoreList
	local isTargetValid = opts.IsTargetValid
	local maxDist = opts.MaxDistance or math.huge

	local closestPlayer, closestPart = Util.GetClosestPlayerToCrosshair(camera, {
		TargetPart = targetLookup,
		HealthClass = healthClass,
		FovRadius = fovRadius,
		FovMethod = opts.FovMethod,
		WallCheck = wallCheck,
		WallCheckIgnoreList = wallIgnore,
		IsTargetValid = isTargetValid,
		MaxDistance = maxDist,
	})

	if closestPart then
		self._target = { player = closestPlayer, part = closestPart }
		self:_aimAt(closestPart, dt)
	end
end

--- Apply the aim to a part
function Aim:_aimAt(targetPart, dt)
	local opts = self._options
	local camera = Workspace.CurrentCamera
	if not camera then return end

	-- Prediction
	local predictedPos = Util.PredictPosition(
		targetPart.Parent,
		targetPart,
		LocalPlayer.Character,
		opts.PredictionFn
	)

	-- Custom target offset (e.g. aim slightly above head for bullet drop)
	local targetOffset = opts.TargetOffset
	if targetOffset then
		if type(targetOffset) == "function" then
			predictedPos = predictedPos + targetOffset(dt, predictedPos, targetPart)
		elseif typeof(targetOffset) == "Vector3" then
			predictedPos = predictedPos + targetOffset
		end
	end

	-- Smoothness (higher = slower snap)
	local smoothness = opts.Smoothness or 1
	local aimCFrame

	if opts.SilentAim then
		-- Silent aim: don't move camera, hook mouse position
		self._silentAimPos = predictedPos
		if opts.SilentAimHook then
			opts.SilentAimHook(predictedPos)
		end
		return
	end

	if smoothness <= 1 then
		aimCFrame = CFrame.lookAt(camera.CFrame.Position, predictedPos)
	else
		local currentDir = camera.CFrame.LookVector
		local targetDir = (predictedPos - camera.CFrame.Position).Unit
		local lerpedDir = currentDir:Lerp(targetDir, 1 / smoothness)
		aimCFrame = CFrame.lookAt(camera.CFrame.Position, camera.CFrame.Position + lerpedDir)
	end

	-- Apply aim method
	local aimMethod = opts.AimMethod
	if aimMethod == "Camera" or not aimMethod then
		camera.CFrame = aimCFrame
	elseif aimMethod == "Mouse" then
		-- Move mouse to corresponding screen position
		local screenPos, onscreen = camera:WorldToViewportPoint(predictedPos)
		if onscreen then
			mousemoverel(screenPos.X - camera.ViewportSize.X / 2, screenPos.Y - camera.ViewportSize.Y / 2)
		end
	elseif type(aimMethod) == "function" then
		-- Custom aim method
		aimMethod(camera, predictedPos, aimCFrame)
	end
end

--- Get silent aim position (for triggerbot integration)
function Aim:GetSilentAimPosition()
	return self._silentAimPos
end

function Aim:Destroy()
	self:Stop()
	self._target = nil
	self._silentAimPos = nil
end

return Aim
