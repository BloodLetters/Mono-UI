local window = require("./core/window")
local notification = require("./core/notification")
local watermark = require("./core/watermark")
local utils = require("./core/utils")
local controlHUD = require("./core/controlHUD")
local popup = require("./core/popup")
local Timer = require("../Packages/Timer")

local activeWindows = {}

local getgenv = getgenv
if not getgenv then
	getgenv = function()
		return _G
	end
end

local function getActiveWindow()
	return activeWindows[#activeWindows]
end

local function setMinimizedHelper(val)
	local activeWindow = getActiveWindow()
	if activeWindow and activeWindow.SetMinimized then
		activeWindow:SetMinimized(val)
	end
end

local function setVisibleHelper(val)
	local activeWindow = getActiveWindow()
	if activeWindow and activeWindow.SetVisible then
		activeWindow:SetVisible(val)
	end
end

local MonoUI = {
	Notify = notification.notify,
	SetWatermark = watermark.set,
	SetThemeColor = utils.setThemeColor,
	CreateControlHUD = controlHUD.create,
	CreateTimer = Timer.new,
	Popup = popup.create,
	CreatePopup = popup.create,
	module = {},
}

function MonoUI.SetMinimized(...)
	local args = {...}
	local minVal
	if args[1] == MonoUI then
		minVal = args[2] == nil or args[2] == true
	else
		minVal = args[1] == nil or args[1] == true
	end
	setMinimizedHelper(minVal)
end

function MonoUI.setMinimized(...)
	MonoUI.SetMinimized(...)
end

function MonoUI.Minimize()
	setMinimizedHelper(true)
end

function MonoUI.Restore()
	setMinimizedHelper(false)
end

function MonoUI.SetVisible(...)
	local args = {...}
	local visVal
	if args[1] == MonoUI then
		visVal = args[2] == nil or args[2] == true
	else
		visVal = args[1] == nil or args[1] == true
	end
	setVisibleHelper(visVal)
end

function MonoUI.setVisible(...)
	MonoUI.SetVisible(...)
end

local monouiEnv = setmetatable({}, {
	__index = function(self, key)
		local libVal = MonoUI[key]
		if libVal ~= nil then
			return libVal
		end
		
		local activeWindow = getActiveWindow()
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
			elseif key == "minimized" then
				return activeWindow:IsMinimized()
			elseif key == "window" then
				return activeWindow
			elseif key == "close" then
				return function()
					activeWindow:Destroy()
				end
			elseif key == "minimize" then
				return function()
					activeWindow:Minimize()
				end
			elseif key == "restore" then
				return function()
					activeWindow:Restore()
				end
			elseif key == "setMinimized" or key == "SetMinimized" then
				return function(_, val)
					if type(_) == "boolean" then
						activeWindow:SetMinimized(_)
					else
						activeWindow:SetMinimized(val == nil or val == true)
					end
				end
			elseif key == "setVisible" or key == "SetVisible" then
				return function(_, val)
					if type(_) == "boolean" then
						activeWindow:SetVisible(_)
					else
						activeWindow:SetVisible(val == nil or val == true)
					end
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
		local activeWindow = getActiveWindow()
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
			elseif key == "minimized" then
				activeWindow:SetMinimized(value)
				return
			end
		end
		rawset(self, key, value)
	end
})

local originalCreateWindow = window.CreateWindow
local function CreateWindow(options)
	local windowObject = originalCreateWindow(options)
	table.insert(activeWindows, windowObject)
	getgenv().monoui = monouiEnv
	
	windowObject:AddCleanup(function()
		for i, win in ipairs(activeWindows) do
			if win == windowObject then
				table.remove(activeWindows, i)
				break
			end
		end
		if #activeWindows == 0 then
			getgenv().monoui = nil
		end
	end)
	
	if MonoUI.module and MonoUI.module.profile then
		local profile = require("./module/profile")
		profile(windowObject)
	end
	return windowObject
end

MonoUI.CreateWindow = CreateWindow

return MonoUI


