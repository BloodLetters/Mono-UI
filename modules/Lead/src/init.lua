local Aim = require("./Aim")
local Trigger = require("./Trigger")
local Util = require("./Util")

local Lead = {}
Lead.__index = Lead

local DEFAULT_OPTIONS = {

	-- ═══════════════════════════════════════════
	-- AIMBOT
	-- ═══════════════════════════════════════════

	AimEnabled = false,

	--- Activation key:
	---   Enum.UserInputType.MouseButton2  →  right-click hold (default)
	---   Enum.KeyCode.LeftShift           →  key hold
	---   "always"                         →  always on (silent aim mode)
	---   function() => bool               →  custom condition check
	AimKey = Enum.UserInputType.MouseButton2,

	--- Aim method:
	---   "Camera"     →  move camera CFrame (default, works everywhere)
	---   "Mouse"      →  move mouse (requires mouse.move / mousemoverel)
	---   function(camera, predictedPos, aimCFrame) →  fully custom
	AimMethod = "Camera",

	--- Target body part:
	---   "Head" / "HumanoidRootPart" / etc.
	---   function(character) => BasePart  →  custom lookup (for NPCs / custom models)
	TargetPart = "Head",

	--- Health class (for custom health systems):
	---   "Humanoid"   →  default humanoid
	---   "MonsterHealth" / "BossHealth" / etc.
	HealthClass = "Humanoid",

	--- Custom validity check:
	---   nil  →  defaults to `Util.IsAlive(character, HealthClass)`
	---   function(player, character) => bool
	IsTargetValid = nil,

	--- Circular FOV radius in screen pixels
	FovRadius = 150,

	--- Custom FOV method:
	---   nil  →  circular distance from crosshair
	---   function(camPos, partPos, screenCenter, screenPos, fovRadius) => bool
	FovMethod = nil,

	--- Smoothness: 1 = instant snap, higher = slower interpolation
	Smoothness = 1,

	--- Sticky target: keep locked on same target even if another player is closer
	StickyTarget = false,

	--- Wall check: skip targets behind walls
	WallCheck = false,

	--- Extra instances to ignore during wall check raycast
	WallCheckIgnoreList = nil, -- { instance, instance, ... }

	--- Maximum target distance (studs), nil = unlimited
	MaxDistance = nil,

	--- Prediction function:
	---   nil  →  default velocity-based prediction
	---   function(character, targetPart, localCharacter) => Vector3
	PredictionFn = nil,

	--- Aim offset from predicted position:
	---   nil         →  no offset
	---   Vector3     →  static offset (e.g. Vector3.new(0, 0.5, 0) for bullet drop compensation)
	---   function(dt, predictedPos, targetPart) => Vector3
	TargetOffset = nil,

	--- Silent aim: redirects bullets without moving camera
	SilentAim = false,

	--- Silent aim hook: called with predicted world position every frame
	---   function(worldPosition)
	---     -- Set your weapon to fire at this position instead
	---   end
	SilentAimHook = nil,

	-- ═══════════════════════════════════════════
	-- TRIGGER BOT
	-- ═══════════════════════════════════════════

	TriggerEnabled = false,

	--- Trigger activation:
	---   nil / "always"  →  fires automatically when target in crosshair
	---   Enum.UserInputType.MouseButton1  →  only fire while LMB held
	---   Enum.KeyCode.E →  only fire while key held
	---   function() => bool  →  custom condition
	TriggerKey = nil,

	--- Target part for trigger bot (defaults to same as TargetPart if nil)
	TriggerTargetPart = nil,

	--- FOV radius for trigger (smaller = more precise, requires crosshair on target)
	TriggerFovRadius = 50,

	--- Max distance for trigger bot
	TriggerMaxDistance = 1000,

	--- Wall check for trigger
	TriggerWallCheck = false,

	--- Delay between shots in milliseconds
	Delay = 50,

	--- Custom fire function:
	---   nil →  default mouse1click()
	---   function() →  custom (e.g. fire remote, virtual input)
	Fire = nil,

	--- Called BEFORE firing, return false to cancel
	---   function(player, character, targetPart) => bool
	BeforeFire = nil,

	--- Called AFTER firing
	---   function(player, character, targetPart)
	AfterFire = nil,
}

--- Create a new Lead combat instance
--- @param options table?
--- @return table – Lead instance with :Start(), :Stop(), :UpdateOptions(), :Destroy()
function Lead.new(options)
	local self = setmetatable({}, Lead)
	options = options or {}

	-- Merge options
	self._options = {}
	for k, v in pairs(DEFAULT_OPTIONS) do
		self._options[k] = (options[k] ~= nil) and options[k] or v
	end

	-- Init sub-modules
	self._aim = Aim.new(self._options)
	self._trigger = Trigger.new(self._options, self._aim)

	return self
end

--- Start all active modules (auto-starts Aim + Trigger if enabled in options)
function Lead:Start()
	self._aim:Start()
	self._trigger:Start()
end

--- Stop all modules
function Lead:Stop()
	self._aim:Stop()
	self._trigger:Stop()
end

--- Get the silent aim position (for external use by weapon scripts)
function Lead:GetSilentAimPosition()
	return self._aim:GetSilentAimPosition()
end

--- Update options at runtime
--- @param newOptions table
function Lead:UpdateOptions(newOptions)
	for k, v in pairs(newOptions) do
		self._options[k] = v
	end
	self._aim:UpdateOptions(self._options)
	self._trigger:UpdateOptions(self._options)
end

--- Full cleanup
function Lead:Destroy()
	self._aim:Destroy()
	self._trigger:Destroy()
	self._aim = nil
	self._trigger = nil
end

return Lead
