local Cache = require("./Cache")
local UI = require("./UI")

local Guard = {}
Guard.__index = Guard

local DEFAULT_OPTIONS = {
	Title = "Guard Key System",
	Subtitle = "Key System",
	Logo = "none",
	GetKeyUrl = "",
	DiscordUrl = "",
	NoteText = "",
	Key = "",
	ConfigName = "guard_default",
	AccentColor = Color3.fromRGB(0, 162, 255),
	OnSuccess = nil,
}

function Guard.new(options)
	local self = setmetatable({}, Guard)
	options = options or {}
	self._options = {}
	for k, v in pairs(DEFAULT_OPTIONS) do
		self._options[k] = v
	end
	for k, v in pairs(options) do
		self._options[k] = v
	end

	local cachedKey = Cache.loadCachedKey(self._options.ConfigName)
	if cachedKey then
		if self:_validate(cachedKey) then
			task.spawn(function()
				if self._options.OnSuccess then
					self._options.OnSuccess()
				end
			end)
			return self
		end
	end

	self:_buildUI()
	return self
end

function Guard:_validate(inputKey)
	local expected = self._options.Key
	if type(expected) == "function" then
		local ok, result = pcall(expected, inputKey)
		return ok and result == true
	elseif type(expected) == "table" then
		for _, k in ipairs(expected) do
			if tostring(k) == inputKey then
				return true
			end
		end
		return false
	else
		return tostring(expected) == inputKey
	end
end

function Guard:_buildUI()
	UI.build(self)
end

function Guard:Show()
	if self._screenGui then
		self._screenGui.Enabled = true
	end
end

function Guard:Hide()
	if self._screenGui then
		self._screenGui.Enabled = false
	end
end

function Guard:Destroy()
	if self._screenGui then
		self._screenGui:Destroy()
		self._screenGui = nil
	end
end

return Guard
