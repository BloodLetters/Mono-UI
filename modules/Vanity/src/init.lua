local Esp = require("./Esp")

local Vanity = {}
Vanity.__index = Vanity

local DEFAULT_OPTIONS = {
	-- Toggles
	BoxEnabled = false,
	NameEnabled = false,
	HealthEnabled = false,
	HighlightEnabled = false,
	MaxDistance = 1000,
	VisibilityColor = false,

	-- Visual customization
	BoxColor = Color3.fromRGB(160, 160, 160),
	BoxOutlineColor = Color3.fromRGB(60, 60, 60),
	NameColor = Color3.fromRGB(255, 255, 255),
	NameSize = 13,
	HighlightColor = Color3.fromRGB(0, 162, 255),
	VisibleColor = Color3.fromRGB(255, 230, 0),

	-- Custom player model support
	RootPart = "HumanoidRootPart",       -- part name or function(char) => BasePart
	HeadPart = "Head",                   -- part name or function(char) => BasePart
	HealthClass = "Humanoid",            -- class name for health object
	BoxTopOffset = Vector3.new(0, 3, 0),    -- offset from root for top of box
	BoxBottomOffset = Vector3.new(0, -3.5, 0), -- offset from root for bottom of box
	IsValid = nil,                       -- function(char) => bool (overrides default alive check)
}

--- Create a new Vanity ESP instance
--- @param options table? – optional overrides (see DEFAULT_OPTIONS)
--- @return table – Vanity instance with :UpdateOptions(), :Destroy()
function Vanity.new(options)
	local self = setmetatable({}, Vanity)
	options = options or {}

	-- Merge user options over defaults
	self._options = {}
	for k, v in pairs(DEFAULT_OPTIONS) do
		self._options[k] = (options[k] ~= nil) and options[k] or v
	end

	-- Spin up the ESP manager (starts RenderStepped loop automatically)
	self._esp = Esp.new(self._options)

	return self
end

--- Update live options without recreating the ESP system
--- @param newOptions table – partial options table
function Vanity:UpdateOptions(newOptions)
	for k, v in pairs(newOptions) do
		self._options[k] = v
	end
	self._esp:UpdateOptions(self._options)
end

--- Destroy all ESP elements, disconnect events, and stop rendering
function Vanity:Destroy()
	if self._esp then
		self._esp:Destroy()
		self._esp = nil
	end
end

return Vanity
