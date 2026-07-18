local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = workspace

local Util = {}

--- Resolve a part name or function lookup to a part instance
--- @param character Model
--- @param lookup string|function – part name or function(character) => BasePart
--- @return BasePart?
function Util.FindPart(character, lookup)
	if not character then return nil end
	if type(lookup) == "function" then
		return lookup(character)
	end
	return character:FindFirstChild(lookup)
end

--- Check if a character is alive (custom health class support)
--- @param character Model
--- @param healthClass string? – class name (default "Humanoid")
function Util.IsAlive(character, healthClass)
	if not character then return false end
	local h = character:FindFirstChildOfClass(healthClass or "Humanoid")
	return h ~= nil and h.Health > 0
end

--- Raycast visibility check
--- @param camera Camera
--- @param targetPart BasePart
--- @param localCharacter Model
--- @param ignoreList table? – extra instances to ignore
function Util.IsVisible(camera, targetPart, localCharacter, ignoreList)
	local origin = camera.CFrame.Position
	local dest = targetPart.Position
	local dir = dest - origin

	local params = RaycastParams.new()
	local filter = { localCharacter, targetPart.Parent }
	if ignoreList then
		for _, v in ipairs(ignoreList) do
			table.insert(filter, v)
		end
	end
	params.FilterDescendantsInstances = filter
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true

	local result = Workspace:Raycast(origin, dir, params)
	return result == nil
end

--- Get all players (excluding self), optionally filtered by a custom validator
--- @param isValidFn function? – function(player, character) => bool
function Util.GetPlayers(isValidFn)
	local list = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			if not isValidFn or isValidFn(player, player.Character) then
				table.insert(list, player)
			end
		end
	end
	return list
end

--- Find the closest valid player to the crosshair (FOV-based)
--- @param camera Camera
--- @param opts table – options: FovRadius, FovMethod, TargetPart, HealthClass, IsTargetValid, WallCheck, WallCheckIgnoreList, MaxDistance
--- @return Player?, BasePart?, number? (player, targetPart, distance)
function Util.GetClosestPlayerToCrosshair(camera, opts)
	local screenCenter = camera.ViewportSize / 2
	local closest = nil
	local closestPart = nil
	local closestDist = nil

	local targetLookup = opts.TargetPart or "Head"
	local healthClass = opts.HealthClass or "Humanoid"
	local isTargetValid = opts.IsTargetValid
	local maxDist = opts.MaxDistance or math.huge
	local wallCheck = opts.WallCheck
	local wallIgnore = opts.WallCheckIgnoreList
	local fovRadius = opts.FovRadius or 150
	local fovMethod = opts.FovMethod

	local localCharacter = LocalPlayer.Character
	local camPos = camera.CFrame.Position

	for _, player in ipairs(Util.GetPlayers()) do
		local character = player.Character
		if not character then continue end

		-- Custom validity
		if isTargetValid and not isTargetValid(player, character) then
			continue
		elseif not isTargetValid and not Util.IsAlive(character, healthClass) then
			continue
		end

		local targetPart = Util.FindPart(character, targetLookup)
		if not targetPart then continue end

		local dist = (targetPart.Position - camPos).Magnitude
		if dist > maxDist then continue end

		-- Wall check
		if wallCheck and not Util.IsVisible(camera, targetPart, localCharacter, wallIgnore) then
			continue
		end

		-- FOV check
		local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
		local fovPassed = false
		if fovMethod then
			fovPassed = fovMethod(camPos, targetPart.Position, screenCenter, screenPos, fovRadius)
		else
			-- Default circular FOV
			local dx = screenPos.X - screenCenter.X
			local dy = screenPos.Y - screenCenter.Y
			fovPassed = math.sqrt(dx * dx + dy * dy) <= fovRadius
		end

		if not fovPassed or not onScreen then continue end

		-- Closest to crosshair
		local crosshairDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
		if not closestDist or crosshairDist < closestDist then
			closest = player
			closestPart = targetPart
			closestDist = crosshairDist
		end
	end

	return closest, closestPart, closestDist
end

--- Predict target position for moving targets (default linear prediction)
--- @param character Model
--- @param targetPart BasePart
--- @param localCharacter Model?
--- @param predictionFn function? – custom prediction: function(character, targetPart) => Vector3
function Util.PredictPosition(character, targetPart, localCharacter, predictionFn)
	if predictionFn then
		return predictionFn(character, targetPart, localCharacter)
	end
	-- Default: simple velocity-based prediction
	local rootPart = Util.FindPart(character, "HumanoidRootPart")
	if rootPart and rootPart.Velocity then
		local ping = (LocalPlayer:GetNetworkPing() or 0.1) / 1.5
		return targetPart.Position + rootPart.Velocity * ping
	end
	return targetPart.Position
end

return Util
