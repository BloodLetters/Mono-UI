local utils = require("../core/utils")
local make = utils.make
local addCorner = utils.addCorner
local addStroke = utils.addStroke
local applyFont = utils.applyFont
local tween = utils.tween

local function normalizeDirectory(value)
	local raw = tostring(value or "MonoUIConfigs"):gsub("\\", "/")
	local parts = {}
	for part in raw:gmatch("[^/]+") do
		part = part:gsub("[%c<>:\"|%?%*]", "_")
		part = part:gsub("^%s+", ""):gsub("%s+$", "")
		if part ~= "" and part ~= "." and part ~= ".." then
			table.insert(parts, part)
		end
	end
	return #parts > 0 and table.concat(parts, "/") or "MonoUIConfigs"
end

local function normalizeConfigName(value)
	local name = tostring(value or "")
	if name:lower():sub(-5) == ".json" then
		name = name:sub(1, -6)
	end
	name = name:gsub("[%c<>:\"/\\|%?%*]", "_")
	name = name:gsub("^%s+", ""):gsub("%s+$", "")
	name = name:gsub("^%.*", ""):gsub("%.*$", "")
	return name
end

local function ensureDirectory(directory)
	local function folderExists(path)
		if type(isfolder) ~= "function" then
			return nil
		end
		local success, result = pcall(isfolder, path)
		return success and result == true
	end

	if folderExists(directory) == true then
		return true
	end
	if type(makefolder) ~= "function" then
		return false, "makefolder is unavailable"
	end

	local current = ""
	for part in directory:gmatch("[^/]+") do
		current = current == "" and part or (current .. "/" .. part)
		local exists = folderExists(current)
		if not exists then
			local success, err = pcall(makefolder, current)
			if not success and folderExists(current) == false then
				return false, err
			end
		end
	end
	return true
end

local function createActionButton(parent, text, width, color)
	local button = make("TextButton", {
		Name = text,
		Size = UDim2.fromOffset(width, 30),
		BackgroundColor3 = color or Color3.fromRGB(42, 42, 48),
		BorderSizePixel = 0,
		Text = text,
		AutoButtonColor = false,
		Parent = parent,
	})
	applyFont(button, 12, Color3.fromRGB(240, 240, 244), Enum.TextXAlignment.Center)
	addCorner(button, 7)
	button.MouseEnter:Connect(function()
		tween(button, { BackgroundTransparency = 0.15 }, 0.12):Play()
	end)
	button.MouseLeave:Connect(function()
		tween(button, { BackgroundTransparency = 0 }, 0.12):Play()
	end)
	return button
end

return function(windowObject, args)
	if type(args) == "string" then
		args = { directory = args }
	else
		args = args or {}
	end

	local directory = normalizeDirectory(args.directory or args.Directory)
	local tab = windowObject:CreateTab({
		text = args.text or args.title or "Configs",
		icon = args.icon or "folder-cog",
	})
	tab:CreateSection({ text = args.section or "Configuration Manager" })

	local nameInput = tab:CreateInput({
		text = args.inputText or "Config Name",
		placeholder = args.placeholder or "enter a config name...",
		default = args.default or "",
	})

	local toolbar = make("Frame", {
		Name = "ConfigActions",
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Color3.fromRGB(24, 24, 28),
		BorderSizePixel = 0,
		Parent = tab.Page,
	})
	addCorner(toolbar, 10)
	addStroke(toolbar, Color3.fromRGB(60, 60, 68), 0.65, 1)

	local saveButton = createActionButton(toolbar, "Save Config", 112, Color3.fromRGB(42, 42, 48))
	saveButton.AnchorPoint = Vector2.new(0, 0.5)
	saveButton.Position = UDim2.new(0, 8, 0.5, 0)

	local refreshButton = createActionButton(toolbar, "Refresh", 84, Color3.fromRGB(42, 42, 48))
	refreshButton.AnchorPoint = Vector2.new(1, 0.5)
	refreshButton.Position = UDim2.new(1, -8, 0.5, 0)

	local statusLabel = make("TextLabel", {
		Name = "Status",
		Position = UDim2.fromOffset(128, 0),
		Size = UDim2.new(1, -228, 1, 0),
		BackgroundTransparency = 1,
		Text = directory,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = toolbar,
	})
	applyFont(statusLabel, 11, Color3.fromRGB(145, 145, 155), Enum.TextXAlignment.Left)

	local listFrame = make("Frame", {
		Name = "ConfigList",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = tab.Page,
	})
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 6)
	listLayout.Parent = listFrame

	local manager = {
		Directory = directory,
		Tab = tab,
		Input = nameInput,
	}

	local function notify(title, content, icon)
		windowObject.Notify({
			title = title,
			content = content,
			icon = icon or "info",
			duration = 3,
		})
	end

	local function runCallback(callback, name)
		if type(callback) == "function" then
			task.spawn(callback, name, directory)
		end
	end

	local function getNames()
		if type(listfiles) ~= "function" then
			return {}, "listfiles is unavailable"
		end

		local ok, files = pcall(listfiles, directory)
		if not ok then
			return {}, files
		end

		local names = {}
		local seen = {}
		for _, file in ipairs(files or {}) do
			local normalized = tostring(file):gsub("\\", "/")
			local base = normalized:match("([^/]+)$") or normalized
			if base:lower():sub(-5) == ".json" then
				local name = base:sub(1, -6)
				if name ~= "" and not seen[name] then
					seen[name] = true
					table.insert(names, name)
				end
			end
		end
		table.sort(names, function(a, b)
			return a:lower() < b:lower()
		end)
		return names
	end

	local function clearRows()
		for _, child in ipairs(listFrame:GetChildren()) do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
	end

	local refresh

	function manager:Save(name)
		local requestedName = name or nameInput:Get()
		local cleanName = normalizeConfigName(requestedName)
		if cleanName == "" then
			notify("Config Name Required", "Enter a name before saving the config.", "triangle-alert")
			return false, "config name is empty"
		end

		local dirOk, dirErr = ensureDirectory(directory)
		if not dirOk then
			notify("Save Failed", tostring(dirErr), "circle-x")
			return false, dirErr
		end

		nameInput:Set(cleanName, false)
		if windowObject and windowObject.Components then
			for flag, comp in pairs(windowObject.Components) do
				if comp and type(comp.Get) == "function" then
					pcall(function()
						windowObject.Flags[flag] = comp:Get()
					end)
				end
			end
		end
		local success, err = windowObject:SaveConfig(directory .. "/" .. cleanName)
		if success then
			notify("Config Saved", cleanName .. ".json was saved.", "save")
			runCallback(args.onSaved, cleanName)
			refresh()
		else
			notify("Save Failed", tostring(err or "writefile is unavailable"), "circle-x")
		end
		return success, err
	end

	function manager:Load(name)
		local cleanName = normalizeConfigName(name or nameInput:Get())
		if cleanName == "" then
			notify("Select a Config", "Choose or enter a config name to load.", "triangle-alert")
			return false
		end

		local success = windowObject:LoadConfig(directory .. "/" .. cleanName, true)
		if success then
			nameInput:Set(cleanName, false)
			notify("Config Loaded", cleanName .. ".json was loaded.", "folder-open")
			runCallback(args.onLoaded, cleanName)
		else
			notify("Load Failed", cleanName .. ".json could not be loaded.", "circle-x")
		end
		return success
	end

	function manager:Delete(name)
		local cleanName = normalizeConfigName(name or nameInput:Get())
		if cleanName == "" then
			notify("Select a Config", "Choose or enter a config name to delete.", "triangle-alert")
			return false
		end
		if type(delfile) ~= "function" then
			notify("Delete Failed", "delfile is unavailable in this executor.", "circle-x")
			return false, "delfile is unavailable"
		end

		local path = directory .. "/" .. cleanName .. ".json"
		if type(isfile) == "function" then
			local checked, exists = pcall(isfile, path)
			if checked and not exists then
				notify("Delete Failed", cleanName .. ".json does not exist.", "circle-x")
				return false, "config does not exist"
			end
		end

		local success, err = pcall(delfile, path)
		if success then
			notify("Config Deleted", cleanName .. ".json was deleted.", "trash-2")
			runCallback(args.onDeleted, cleanName)
			if normalizeConfigName(nameInput:Get()) == cleanName then
				nameInput:Set("", false)
			end
			refresh()
		else
			notify("Delete Failed", tostring(err), "circle-x")
		end
		return success, err
	end

	function manager:Copy(name)
		local cleanName = normalizeConfigName(name or nameInput:Get())
		if cleanName == "" then
			notify("Select a Config", "Choose or enter a config name to copy.", "triangle-alert")
			return false
		end
		if type(setclipboard) ~= "function" then
			notify("Copy Failed", "setclipboard is unavailable in this executor.", "circle-x")
			return false, "setclipboard is unavailable"
		end
		local path = directory .. "/" .. cleanName .. ".json"
		if type(isfile) == "function" then
			local checked, exists = pcall(isfile, path)
			if checked and not exists then
				notify("Copy Failed", cleanName .. ".json does not exist.", "circle-x")
				return false, "config does not exist"
			end
		end
		if type(readfile) ~= "function" then
			notify("Copy Failed", "readfile is unavailable in this executor.", "circle-x")
			return false, "readfile is unavailable"
		end
		local success, content = pcall(readfile, path)
		if success then
			local cbSuccess, cbErr = pcall(setclipboard, content)
			if cbSuccess then
				notify("Config Copied", "Copied to clipboard.", "clipboard-copy")
			else
				notify("Copy Failed", tostring(cbErr), "circle-x")
			end
			return true
		else
			notify("Copy Failed", tostring(content), "circle-x")
			return false, content
		end
	end

	refresh = function()
		clearRows()
		local names, listErr = getNames()
		statusLabel.Text = listErr and tostring(listErr) or (tostring(#names) .. " config(s) in " .. directory)

		if #names == 0 then
			local emptyLabel = make("TextLabel", {
				Name = "Empty",
				Size = UDim2.new(1, 0, 0, 38),
				BackgroundColor3 = Color3.fromRGB(22, 22, 26),
				BackgroundTransparency = 0.25,
				BorderSizePixel = 0,
				Text = listErr and "Config list is unavailable" or "No saved configs yet",
				Parent = listFrame,
			})
			addCorner(emptyLabel, 9)
			applyFont(emptyLabel, 12, Color3.fromRGB(135, 135, 145), Enum.TextXAlignment.Center)
			return names, listErr
		end

		for index, name in ipairs(names) do
			local row = make("Frame", {
				Name = name,
				LayoutOrder = index,
				Size = UDim2.new(1, 0, 0, 42),
				BackgroundColor3 = Color3.fromRGB(24, 24, 28),
				BorderSizePixel = 0,
				Parent = listFrame,
			})
			addCorner(row, 9)
			addStroke(row, Color3.fromRGB(56, 56, 64), 0.7, 1)

			local selectButton = make("TextButton", {
				Name = "Select",
				Position = UDim2.fromOffset(12, 0),
				Size = UDim2.new(1, -210, 1, 0),
				BackgroundTransparency = 1,
				Text = name,
				TextTruncate = Enum.TextTruncate.AtEnd,
				AutoButtonColor = false,
				Parent = row,
			})
			applyFont(selectButton, 13, Color3.fromRGB(232, 232, 236), Enum.TextXAlignment.Left)
			selectButton.Activated:Connect(function()
				nameInput:Set(name, false)
			end)

			local copyButton = createActionButton(row, "Copy", 56, Color3.fromRGB(42, 42, 48))
			copyButton.AnchorPoint = Vector2.new(1, 0.5)
			copyButton.Position = UDim2.new(1, -136, 0.5, 0)
			copyButton.Activated:Connect(function()
				manager:Copy(name)
			end)

			local loadButton = createActionButton(row, "Load", 56, Color3.fromRGB(42, 42, 48))
			loadButton.AnchorPoint = Vector2.new(1, 0.5)
			loadButton.Position = UDim2.new(1, -72, 0.5, 0)
			loadButton.Activated:Connect(function()
				manager:Load(name)
			end)

			local deleteButton = createActionButton(row, "Delete", 56, Color3.fromRGB(42, 42, 48))
			deleteButton.AnchorPoint = Vector2.new(1, 0.5)
			deleteButton.Position = UDim2.new(1, -8, 0.5, 0)
			deleteButton.Activated:Connect(function()
				manager:Delete(name)
			end)
		end
		return names
	end

	function manager:Refresh()
		return refresh()
	end

	saveButton.Activated:Connect(function()
		manager:Save()
	end)
	refreshButton.Activated:Connect(function()
		refresh()
	end)

	ensureDirectory(directory)
	refresh()
	return manager
end
