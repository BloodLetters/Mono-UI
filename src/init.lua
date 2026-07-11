local window = require("./core/window")
local notification = require("./core/notification")
local watermark = require("./core/watermark")
local utils = require("./core/utils")
local controlHUD = require("./core/controlHUD")
local Timer = require("../Packages/Timer")

return {
	CreateWindow = window.CreateWindow,
	Notify = notification.notify,
	SetWatermark = watermark.set,
	SetThemeColor = utils.setThemeColor,
	CreateControlHUD = controlHUD.create,
	CreateTimer = Timer.new,
}
