local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Util = {}

--- Check if a character model is alive
--- @param character Model
--- @param healthClass string? – class name for health check (default "Humanoid")
function Util.IsAlive(character, healthClass)
	if not character then
		return false
	end
	healthClass = healthClass or "Humanoid"
	local healthObj = character:FindFirstChildOfClass(healthClass)
	return healthObj ~= nil and healthObj.Health > 0
end

--- Resolve a part name or function lookup to a part instance
--- @param character Model
--- @param lookup string|function – part name or function(character) => BasePart
--- @return BasePart?
function Util.FindPart(character, lookup)
	if not character then
		return nil
	end
	if type(lookup) == "function" then
		return lookup(character)
	end
	return character:FindFirstChild(lookup)
end

--- Raycast visibility check: true if nothing obscures the target part from the camera
--- @param camera Camera
--- @param targetPart BasePart
--- @param localCharacter Model
function Util.IsVisible(camera, targetPart, localCharacter)
	local origin = camera.CFrame.Position
	local destination = targetPart.Position
	local direction = destination - origin

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { localCharacter, targetPart.Parent }
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true

	local result = workspace:Raycast(origin, direction, raycastParams)
	return result == nil
end

--- Get all alive enemy players
function Util.GetPlayers()
	local list = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and Util.IsAlive(player.Character) then
			table.insert(list, player)
		end
	end
	return list
end

return Util
