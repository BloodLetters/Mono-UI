local window = require("./core/window")
local notification = require("./core/notification")
local watermark = require("./core/watermark")
local utils = require("./core/utils")
local controlHUD = require("./core/controlHUD")
local Timer = require("../Packages/Timer")

local MonoUI = {
	Notify = notification.notify,
	SetWatermark = watermark.set,
	SetThemeColor = utils.setThemeColor,
	CreateControlHUD = controlHUD.create,
	CreateTimer = Timer.new,
	module = {},
}

local originalCreateWindow = window.CreateWindow
local function CreateWindow(options)
	local windowObject = originalCreateWindow(options)
	if MonoUI.module and MonoUI.module.profile then
		local profile = require("./module/profile")
		profile(windowObject)
	end
	return windowObject
end

MonoUI.CreateWindow = CreateWindow

return MonoUI


