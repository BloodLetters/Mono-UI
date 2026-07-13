local utils = require("../core/utils")
local Players = utils.Players
local make = utils.make
local addCorner = utils.addCorner
local addStroke = utils.addStroke
local applyFont = utils.applyFont

local function AddUserProfile(windowObject, options)
	options = options or {}
	local player = Players.LocalPlayer
	local displayName = options.CustomName
	local username = options.CustomUsername
	local userId = player and player.UserId or 0
	
	if not displayName then
		if player then
			displayName = player.DisplayName or player.Name
		else
			displayName = "Guest"
		end
	end
	
	if not username then
		if player then
			username = "@" .. player.Name
		else
			username = "@guest"
		end
	end

	local frame = windowObject.Frame
	local content = frame:FindFirstChild("Content")
	if not content then return end
	local layoutRoot = content:FindFirstChild("LayoutRoot")
	if not layoutRoot then return end
	local tabBar = layoutRoot:FindFirstChild("TabBar")
	if not tabBar then return end

	-- Allow dividers to extend outside layoutRoot boundaries
	layoutRoot.ClipsDescendants = false

	-- Reparent the main SidebarDivider to layoutRoot so it spans the full window height and doesn't scroll/clip
	local sidebarDivider = layoutRoot:FindFirstChild("SidebarDivider") or tabBar:FindFirstChild("SidebarDivider")
	if sidebarDivider then
		sidebarDivider.Parent = layoutRoot
		sidebarDivider.Position = UDim2.new(0, 118, 0, 0)
		sidebarDivider.Size = UDim2.new(0, 1, 1, 0)
		sidebarDivider.ZIndex = 4
	end

	local profileHeight = options.Height or 48
	tabBar.Size = UDim2.new(0, 120, 1, -profileHeight)

	local profileFrame = make("Frame", {
		Name = "UserProfile",
		Size = UDim2.new(0, 120, 0, profileHeight),
		Position = UDim2.new(0, 0, 1, -profileHeight),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = layoutRoot,
	})

	-- Horizontal separator at the top of the profile footer
	local topDivider = make("Frame", {
		Name = "TopDivider",
		Size = UDim2.new(1, 2, 0, 1),
		Position = UDim2.new(0, -4, 0, 0),
		BackgroundColor3 = Color3.fromRGB(45, 45, 52),
		BorderSizePixel = 0,
		Parent = profileFrame,
	})

	local avatarSize = 30
	local avatarImage = options.CustomAvatar or ("rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=150&h=150")

	local avatarFrame = make("ImageLabel", {
		Name = "Avatar",
		Size = UDim2.fromOffset(avatarSize, avatarSize),
		Position = UDim2.new(0, 4, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Image = avatarImage,
		Parent = profileFrame,
	})
	addCorner(avatarFrame, avatarSize / 2)
	addStroke(avatarFrame, Color3.fromRGB(52, 52, 60), 0.5, 1)

	local infoFrame = make("Frame", {
		Name = "Info",
		Size = UDim2.fromOffset(74, avatarSize),
		Position = UDim2.new(0, 40, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Parent = profileFrame,
	})
	
	local listLayout = make("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 0),
		Parent = infoFrame,
	})

	local nameLabel = make("TextLabel", {
		Name = "DisplayName",
		Size = UDim2.new(1, 0, 0, 15),
		BackgroundTransparency = 1,
		Text = displayName,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = infoFrame,
	})
	applyFont(nameLabel, 12, utils.theme.TextColor or Color3.fromRGB(235, 235, 240), Enum.TextXAlignment.Left)

	local usernameLabel = make("TextLabel", {
		Name = "Username",
		Size = UDim2.new(1, 0, 0, 11),
		BackgroundTransparency = 1,
		Text = username,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = infoFrame,
	})
	applyFont(usernameLabel, 9, utils.theme.MutedTextColor or Color3.fromRGB(140, 140, 150), Enum.TextXAlignment.Left)

	return profileFrame
end

return AddUserProfile
