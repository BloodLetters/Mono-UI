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

local activeWindow = nil

local getgenv = getgenv
if not getgenv then
	getgenv = function()
		return _G
	end
end

local monouiEnv = setmetatable({}, {
	__index = function(self, key)
		local libVal = MonoUI[key]
		if libVal ~= nil then
			return libVal
		end
		
		if activeWindow then
			if key == "title" then
				return activeWindow.TitleLabel and activeWindow.TitleLabel.Text or activeWindow.Title
			elseif key == "subtitle" then
				return activeWindow.SubtitleLabel and activeWindow.SubtitleLabel.Text or activeWindow.Subtitle
			elseif key == "flags" then
				return activeWindow.Flags
			elseif key == "components" then
				return activeWindow.Components
			elseif key == "activeTab" then
				return activeWindow.ActiveTab and activeWindow.ActiveTab.Button.Name or nil
			elseif key == "visible" then
				return activeWindow.Frame.Visible
			elseif key == "window" then
				return activeWindow
			elseif key == "close" then
				return function()
					activeWindow:Destroy()
				end
			end
			
			local winVal = activeWindow[key]
			if winVal ~= nil then
				return winVal
			end
			
			local pascalKey = key:sub(1,1):upper() .. key:sub(2)
			local winPascalVal = activeWindow[pascalKey]
			if winPascalVal ~= nil then
				return winPascalVal
			end
		end
		return nil
	end,
	__newindex = function(self, key, value)
		if activeWindow then
			if key == "title" then
				if activeWindow.TitleLabel then
					activeWindow.TitleLabel.Text = tostring(value)
				end
				activeWindow.Title = value
				return
			elseif key == "subtitle" then
				if activeWindow.SubtitleLabel then
					activeWindow.SubtitleLabel.Text = tostring(value)
				end
				activeWindow.Subtitle = value
				return
			elseif key == "visible" then
				activeWindow:SetVisible(value)
				return
			end
		end
		rawset(self, key, value)
	end
})

getgenv().monoui = monouiEnv

local originalCreateWindow = window.CreateWindow
local function CreateWindow(options)
	local windowObject = originalCreateWindow(options)
	activeWindow = windowObject
	
	local originalDestroy = windowObject.Destroy
	windowObject.Destroy = function(self)
		if activeWindow == windowObject then
			activeWindow = nil
		end
		originalDestroy(self)
	end
	
	if MonoUI.module and MonoUI.module.profile then
		local profile = require("./module/profile")
		profile(windowObject)
	end
	return windowObject
end

MonoUI.CreateWindow = CreateWindow

return MonoUI


