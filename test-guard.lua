--[================================================================[
    Standalone Test Script for Guard Key System (Obsidian Slate Theme)
    Execution Ready - Fully Offline Bundled
--================================================================]
local isPremium = false
local HttpService = game:GetService('HttpService')
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local LocalPlayer = Players.LocalPlayer

-- User verification wrapper
local function getHWID()
    return game:GetService('RbxAnalyticsService'):GetClientId()
end

local function encodeUsername(username)
    return HttpService:UrlEncode(username)
end

local function checkUser()
    local player = Players.LocalPlayer
    local username = player.Name
    local hwid = getHWID()
    
    local encodedUsername = encodeUsername(username)
    local userApiUrl = 'https://ashlabs-token-six.vercel.app/api/user/' .. encodedUsername

    local success, userResponse = pcall(function()
        return game:HttpGet(userApiUrl)
    end)
    
    if not success then
        player:Kick('Connection Error. report this to discord support')
        return
    end
    
    local userdata = HttpService:JSONDecode(userResponse)
    
    if userdata.remaining_time and userdata.remaining_time <= 0 then
        local verifyUrl = 'https://ashlabs-premium.vercel.app/verify?hwid=' .. hwid
        
        local verifySuccess, verifyResponse = pcall(function()
            return game:HttpGet(verifyUrl)
        end)
        
        if not verifySuccess then
            player:Kick('Verification Error. report this to discord support')
            return
        end
        
        local verifyData = HttpService:JSONDecode(verifyResponse)
        
        if verifyData.status == 'ok' then
            isPremium = true
        elseif verifyData.status == 'error' then
            player:Kick('Dont Bypass')
            return
        elseif verifyData.status ~= 'ok' then
            player:Kick('Verification Failed. report this to discord support')
            return
        end
    end
    
    print('[AshLabs] User verified successfully')
end

-- checkUser() -- Commented for debugging as specified in global rules

-- Bundled Guard Module
local Guard = (function()
local __DARKLUA_BUNDLE_MODULES = {
    cache = {}::any,
}

do
    do
        local function __modImpl()
            local Cache = {}

            function Cache.getCacheFilename(configName)
                return 'guard_key_' .. tostring(configName) .. '.txt'
            end
            function Cache.loadCachedKey(configName)
                local filename = Cache.getCacheFilename(configName)

                if isfile and isfile(filename) then
                    local ok, key = pcall(readfile, filename)

                    if ok and key then
                        key = key:match('^%s*(.-)%s*$')

                        return key
                    end
                end

                return nil
            end
            function Cache.saveCachedKey(configName, key)
                local filename = Cache.getCacheFilename(configName)

                if writefile then
                    pcall(writefile, filename, key)
                end
            end

            return Cache
        end

        function __DARKLUA_BUNDLE_MODULES.a(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.a

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.a = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Util = {}

            function Util.getGuiParent()
                if typeof(gethui) == 'function' then
                    local ok, result = pcall(gethui)

                    if ok and result then
                        return result
                    end
                end

                local players = game:GetService('Players')
                local localPlayer = players.LocalPlayer

                if localPlayer then
                    local pGui = localPlayer:FindFirstChildOfClass('PlayerGui')

                    if pGui then
                        return pGui
                    end
                end

                local ok, coreGui = pcall(game.GetService, game, 'CoreGui')

                if ok and coreGui then
                    return coreGui
                end

                return nil
            end
            function Util.make(className, properties)
                local instance = Instance.new(className)

                for property, value in pairs(properties or {})do
                    instance[property] = value
                end

                return instance
            end
            function Util.addCorner(instance, radius)
                local corner = Instance.new('UICorner')

                corner.CornerRadius = UDim.new(0, radius)
                corner.Parent = instance

                return corner
            end
            function Util.addStroke(instance, color, transparency, thickness)
                local stroke = Instance.new('UIStroke')

                stroke.Color = color
                stroke.Transparency = transparency or 0
                stroke.Thickness = thickness or 1
                stroke.Parent = instance

                return stroke
            end
            function Util.connectDrag(handle, target)
                local dragging = false
                local dragStart
                local startPosition
                local UserInputService = game:GetService('UserInputService')

                handle.InputBegan:Connect(function(input, processed)
                    if processed then
                        return
                    end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragStart = input.Position
                        startPosition = target.Position
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if not dragging then
                        return
                    end
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        local delta = input.Position - dragStart

                        target.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
            end
            function Util.copyToClipboard(text)
                if typeof(setclipboard) == 'function' then
                    pcall(setclipboard, text)

                    return true
                elseif typeof(toClipboard) == 'function' then
                    pcall(toClipboard, text)

                    return true
                end

                return false
            end

            return Util
        end

        function __DARKLUA_BUNDLE_MODULES.b(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.b

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.b = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Util = __DARKLUA_BUNDLE_MODULES.b()
            local TweenService = game:GetService('TweenService')
            local Notification = {}
            local activeNotifications = {}

            local function updatePositions()
                local yOffset = -20

                for i = #activeNotifications, 1, -1 do
                    local notif = activeNotifications[i]
                    local frame = notif.Frame

                    if frame then
                        local targetPos = UDim2.new(1, -20, 1, yOffset)

                        TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = targetPos}):Play()

                        yOffset = yOffset - (frame.AbsoluteSize.Y + 10)
                    end
                end
            end

            function Notification.new(options)
                options = options or {}

                local title = options.Title or 'Notification'
                local content = options.Content or ''
                local duration = options.Duration or 4
                local notifType = options.Type or 'Info'
                local accentColor = options.AccentColor or Color3.fromRGB(240, 240, 245)
                local parentGui = Util.getGuiParent()

                if not parentGui then
                    return
                end

                local notifGui = parentGui:FindFirstChild('GuardNotificationGui')

                if not notifGui then
                    notifGui = Util.make('ScreenGui', {
                        Name = 'GuardNotificationGui',
                        ResetOnSpawn = false,
                        IgnoreGuiInset = true,
                        DisplayOrder = 1002,
                        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                        Parent = parentGui,
                    })
                end

                local frameWidth = 280
                local frameHeight = 66
                local frame = Util.make('Frame', {
                    Name = 'NotificationFrame',
                    AnchorPoint = Vector2.new(1, 1),
                    Position = UDim2.new(1, frameWidth + 20, 1, -20),
                    Size = UDim2.fromOffset(frameWidth, frameHeight),
                    BackgroundColor3 = Color3.fromRGB(20, 26, 38),
                    BorderSizePixel = 0,
                    Parent = notifGui,
                })

                Util.addCorner(frame, 8)
                Util.addStroke(frame, Color3.fromRGB(38, 48, 66), 0.3, 1)

                local typeColor = Color3.fromRGB(56, 189, 248)
                local iconAsset = 'rbxassetid://16898613509'
                local iconRectOffset = Vector2.new(820, 257)

                if notifType == 'Success' then
                    typeColor = Color3.fromRGB(74, 222, 128)
                    iconAsset = 'rbxassetid://16898613777'
                    iconRectOffset = Vector2.new(820, 257)
                elseif notifType == 'Error' then
                    typeColor = Color3.fromRGB(248, 113, 113)
                    iconAsset = 'rbxassetid://16898613777'
                    iconRectOffset = Vector2.new(514, 820)
                elseif notifType == 'Info' then
                    typeColor = Color3.fromRGB(56, 189, 248)
                end

                local accentBar = Util.make('Frame', {
                    Name = 'AccentBar',
                    Size = UDim2.new(0, 4, 1, 0),
                    BackgroundColor3 = typeColor,
                    BorderSizePixel = 0,
                    Parent = frame,
                })

                Util.addCorner(accentBar, 8)

                local icon = Util.make('ImageLabel', {
                    Name = 'Icon',
                    Position = UDim2.fromOffset(14, 20),
                    Size = UDim2.fromOffset(24, 24),
                    BackgroundTransparency = 1,
                    Image = iconAsset,
                    ImageRectOffset = iconRectOffset,
                    ImageRectSize = Vector2.new(48, 48),
                    ImageColor3 = typeColor,
                    Parent = frame,
                })
                local cleanFont = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                local cleanFontBold = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
                local titleLabel = Util.make('TextLabel', {
                    Name = 'Title',
                    Position = UDim2.fromOffset(48, 12),
                    Size = UDim2.new(1, -60, 0, 16),
                    Text = title,
                    TextColor3 = Color3.fromRGB(245, 245, 245),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 13,
                    FontFace = cleanFontBold,
                    BackgroundTransparency = 1,
                    Parent = frame,
                })
                local contentLabel = Util.make('TextLabel', {
                    Name = 'Content',
                    Position = UDim2.fromOffset(48, 30),
                    Size = UDim2.new(1, -60, 0, 24),
                    Text = content,
                    TextColor3 = Color3.fromRGB(160, 160, 160),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    TextSize = 11,
                    FontFace = cleanFont,
                    TextWrapped = true,
                    BackgroundTransparency = 1,
                    Parent = frame,
                })
                local progressBarBg = Util.make('Frame', {
                    Name = 'ProgressBarBg',
                    Position = UDim2.new(0, 0, 1, -2),
                    Size = UDim2.new(1, 0, 0, 2),
                    BackgroundColor3 = Color3.fromRGB(30, 30, 35),
                    BorderSizePixel = 0,
                    Parent = frame,
                })
                local progressBar = Util.make('Frame', {
                    Name = 'ProgressBar',
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = typeColor,
                    BorderSizePixel = 0,
                    Parent = progressBarBg,
                })
                local notifObj = {
                    Frame = frame,
                    Destroy = function()
                        for idx, val in ipairs(activeNotifications)do
                            if val.Frame == frame then
                                table.remove(activeNotifications, idx)

                                break
                            end
                        end

                        updatePositions()

                        local slideOut = TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
                            Position = UDim2.new(1, frameWidth + 20, 1, frame.Position.Y.Offset),
                        })

                        slideOut:Play()
                        slideOut.Completed:Connect(function()
                            frame:Destroy()
                        end)
                    end,
                }

                table.insert(activeNotifications, notifObj)
                updatePositions()
                TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                    Size = UDim2.new(0, 0, 1, 0),
                }):Play()
                task.delay(duration, function()
                    if frame and frame.Parent then
                        notifObj.Destroy()
                    end
                end)

                return notifObj
            end

            return Notification
        end

        function __DARKLUA_BUNDLE_MODULES.c(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.c

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.c = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Util = __DARKLUA_BUNDLE_MODULES.b()
            local Cache = __DARKLUA_BUNDLE_MODULES.a()
            local Notification = __DARKLUA_BUNDLE_MODULES.c()
            local UI = {}

            function UI.build(self)
                local parentGui = Util.getGuiParent()

                if not parentGui then
                    warn('Guard Key System: Failed to locate ScreenGui parent.')

                    return
                end

                local windowWidth = 440
                local windowHeight = 205
                local logoName = tostring(self._options.Logo):lower()
                local hasLogo = logoName ~= '' and logoName ~= 'none'
                local iconAsset = 'rbxassetid://16898613509'
                local rectOffset = Vector2.new(918, 857)
                local rectSize = Vector2.new(48, 48)

                if logoName == 'key' then
                    rectOffset = Vector2.new(869, 404)
                elseif logoName == 'shield-check' or logoName == 'shield' then
                    iconAsset = 'rbxassetid://16898613777'
                    rectOffset = Vector2.new(820, 257)
                elseif logoName == 'shield-x' then
                    iconAsset = 'rbxassetid://16898613777'
                    rectOffset = Vector2.new(514, 820)
                elseif logoName == 'shield-alert' then
                    iconAsset = 'rbxassetid://16898613777'
                    rectOffset = Vector2.new(49, 771)
                end

                local screenGui = Util.make('ScreenGui', {
                    Name = 'GuardKeySystem',
                    ResetOnSpawn = false,
                    IgnoreGuiInset = true,
                    DisplayOrder = 1001,
                    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                    Parent = parentGui,
                })

                self._screenGui = screenGui

                local bgBase = Color3.fromRGB(15, 18, 25)
                local bgGradientStart = Color3.fromRGB(22, 28, 40)
                local bgGradientEnd = Color3.fromRGB(10, 13, 19)
                local innerPanelBg = Color3.fromRGB(22, 27, 38)
                local cardContainerBg = Color3.fromRGB(26, 33, 46)
                local pillBg = Color3.fromRGB(18, 22, 32)
                local borderGray = Color3.fromRGB(38, 48, 66)
                local statusCyan = Color3.fromRGB(56, 189, 248)
                local textPrimary = Color3.fromRGB(255, 255, 255)
                local textSecondary = Color3.fromRGB(148, 163, 184)
                local iconSoftWhite = Color3.fromRGB(226, 232, 240)
                local darkButtonText = Color3.fromRGB(15, 23, 42)
                local mainFrame = Util.make('Frame', {
                    Name = 'MainFrame',
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.45),
                    Size = UDim2.fromOffset(windowWidth, windowHeight),
                    BackgroundColor3 = bgBase,
                    BorderSizePixel = 0,
                    Active = true,
                    Parent = screenGui,
                })

                self._mainFrame = mainFrame

                Util.addCorner(mainFrame, 12)
                Util.addStroke(mainFrame, borderGray, 0.25, 1)
                Util.make('UIGradient', {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, bgGradientStart),
                        ColorSequenceKeypoint.new(1, bgGradientEnd),
                    }),
                    Rotation = 135,
                    Parent = mainFrame,
                })

                local topLight = Util.make('Frame', {
                    Name = 'TopEdgeLight',
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 2),
                    BackgroundColor3 = statusCyan,
                    BackgroundTransparency = 0.4,
                    BorderSizePixel = 0,
                    Parent = mainFrame,
                })

                Util.addCorner(topLight, 12)

                local topBar = Util.make('Frame', {
                    Name = 'TopBar',
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = mainFrame,
                })

                Util.connectDrag(topBar, mainFrame)
                Util.make('Frame', {
                    Name = 'HeaderDivider',
                    Position = UDim2.new(0, 0, 1, -1),
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = borderGray,
                    BackgroundTransparency = 0.3,
                    BorderSizePixel = 0,
                    Parent = topBar,
                })

                if hasLogo then
                    local logoContainer = Util.make('Frame', {
                        Name = 'LogoBadge',
                        Position = UDim2.fromOffset(14, 9),
                        Size = UDim2.fromOffset(32, 32),
                        BackgroundColor3 = cardContainerBg,
                        BorderSizePixel = 0,
                        Parent = topBar,
                    })

                    Util.addCorner(logoContainer, 8)
                    Util.addStroke(logoContainer, borderGray, 0.3, 1)
                    Util.make('ImageLabel', {
                        Name = 'LogoIcon',
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromOffset(20, 20),
                        BackgroundTransparency = 1,
                        Image = iconAsset,
                        ImageRectOffset = rectOffset,
                        ImageRectSize = rectSize,
                        ImageColor3 = iconSoftWhite,
                        Parent = logoContainer,
                    })
                end

                local cleanFont = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                local cleanFontBold = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)

                Util.make('TextLabel', {
                    Name = 'Title',
                    Position = UDim2.fromOffset(hasLogo and 54 or 15, 10),
                    Size = UDim2.new(1, hasLogo and -95 or -60, 0, 16),
                    Text = self._options.Title,
                    TextColor3 = textPrimary,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 14,
                    FontFace = cleanFontBold,
                    BackgroundTransparency = 1,
                    Parent = topBar,
                })
                Util.make('TextLabel', {
                    Name = 'Subtitle',
                    Position = UDim2.fromOffset(hasLogo and 54 or 15, 27),
                    Size = UDim2.new(1, hasLogo and -95 or -60, 0, 12),
                    Text = self._options.Subtitle,
                    TextColor3 = textSecondary,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 11,
                    FontFace = cleanFont,
                    BackgroundTransparency = 1,
                    Parent = topBar,
                })

                local closeBtn = Util.make('ImageButton', {
                    Name = 'Close',
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(26, 26),
                    BackgroundColor3 = cardContainerBg,
                    BorderSizePixel = 0,
                    Image = 'rbxassetid://16898613869',
                    ImageRectOffset = Vector2.new(869, 906),
                    ImageRectSize = Vector2.new(48, 48),
                    ImageColor3 = iconSoftWhite,
                    AutoButtonColor = false,
                    Parent = topBar,
                })

                Util.addCorner(closeBtn, 6)
                Util.addStroke(closeBtn, borderGray, 0.3, 1)

                local TweenService = game:GetService('TweenService')

                closeBtn.MouseEnter:Connect(function()
                    TweenService:Create(closeBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(38, 48, 66),
                        ImageColor3 = textPrimary,
                    }):Play()
                end)
                closeBtn.MouseLeave:Connect(function()
                    TweenService:Create(closeBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = cardContainerBg,
                        ImageColor3 = iconSoftWhite,
                    }):Play()
                end)
                closeBtn.MouseButton1Click:Connect(function()
                    self:Destroy()
                end)
                Util.make('Frame', {
                    Name = 'ColDivider',
                    Position = UDim2.fromOffset(220, 62),
                    Size = UDim2.fromOffset(1, 52),
                    BackgroundColor3 = borderGray,
                    BackgroundTransparency = 0.3,
                    BorderSizePixel = 0,
                    Parent = mainFrame,
                })

                local leftCol = Util.make('Frame', {
                    Name = 'LeftColumn',
                    Position = UDim2.fromOffset(15, 58),
                    Size = UDim2.fromOffset(190, 60),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Parent = mainFrame,
                })

                Util.make('TextLabel', {
                    Name = 'KeyLabel',
                    Size = UDim2.new(1, 0, 0, 14),
                    Text = 'KEY PASSWORD',
                    TextColor3 = textSecondary,
                    TextSize = 10,
                    FontFace = cleanFontBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Parent = leftCol,
                })

                local inputContainer = Util.make('Frame', {
                    Name = 'InputContainer',
                    Position = UDim2.fromOffset(0, 18),
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundColor3 = innerPanelBg,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Parent = leftCol,
                })

                Util.addCorner(inputContainer, 8)

                local inputStroke = Util.addStroke(inputContainer, borderGray, 0.3, 1)
                local inputKeyIcon = Util.make('ImageLabel', {
                    Name = 'InputIcon',
                    Position = UDim2.fromOffset(9, 9),
                    Size = UDim2.fromOffset(16, 16),
                    BackgroundTransparency = 1,
                    Image = 'rbxassetid://16898613509',
                    ImageRectOffset = Vector2.new(869, 404),
                    ImageRectSize = Vector2.new(48, 48),
                    ImageColor3 = iconSoftWhite,
                    Parent = inputContainer,
                })
                local keyTextBox = Util.make('TextBox', {
                    Name = 'KeyTextBox',
                    Position = UDim2.fromOffset(30, 0),
                    Size = UDim2.new(1, -38, 1, 0),
                    BackgroundTransparency = 1,
                    Text = '',
                    PlaceholderText = 'Enter key here...',
                    PlaceholderColor3 = textSecondary,
                    TextColor3 = textPrimary,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 12,
                    FontFace = cleanFont,
                    ClearTextOnFocus = false,
                    ClipsDescendants = true,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = inputContainer,
                })

                keyTextBox.Focused:Connect(function()
                    TweenService:Create(inputStroke, TweenInfo.new(0.2), {
                        Color = textPrimary,
                        Transparency = 0.1,
                    }):Play()
                end)
                keyTextBox.FocusLost:Connect(function()
                    TweenService:Create(inputStroke, TweenInfo.new(0.2), {
                        Color = borderGray,
                        Transparency = 0.3,
                    }):Play()
                end)

                local rightCol = Util.make('Frame', {
                    Name = 'RightColumn',
                    Position = UDim2.fromOffset(235, 58),
                    Size = UDim2.fromOffset(190, 60),
                    BackgroundTransparency = 1,
                    Parent = mainFrame,
                })

                Util.make('TextLabel', {
                    Name = 'NoteLabel',
                    Size = UDim2.new(1, 0, 0, 14),
                    Text = 'INFORMATION',
                    TextColor3 = textSecondary,
                    TextSize = 10,
                    FontFace = cleanFontBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Parent = rightCol,
                })

                local discord = self._options.DiscordUrl ~= nil and tostring(self._options.DiscordUrl) ~= '' and tostring(self._options.DiscordUrl) or 'discord.gg/epichub'
                local defaultNote = 'Join our Discord server to get the key! ' .. discord
                local noteTextString = self._options.NoteText ~= nil and tostring(self._options.NoteText) ~= '' and tostring(self._options.NoteText) or defaultNote
                local noteCard = Util.make('Frame', {
                    Name = 'NoteCard',
                    Position = UDim2.fromOffset(0, 18),
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundColor3 = innerPanelBg,
                    BorderSizePixel = 0,
                    Parent = rightCol,
                })

                Util.addCorner(noteCard, 8)
                Util.addStroke(noteCard, borderGray, 0.3, 1)

                local noteBtn = Util.make('TextButton', {
                    Name = 'NoteButton',
                    Position = UDim2.fromOffset(6, 4),
                    Size = UDim2.new(1, -12, 1, -8),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Text = noteTextString,
                    TextColor3 = textSecondary,
                    TextSize = 10,
                    FontFace = cleanFont,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    AutoButtonColor = false,
                    Parent = noteCard,
                })

                noteBtn.MouseEnter:Connect(function()
                    TweenService:Create(noteBtn, TweenInfo.new(0.2), {TextColor3 = textPrimary}):Play()
                end)
                noteBtn.MouseLeave:Connect(function()
                    TweenService:Create(noteBtn, TweenInfo.new(0.2), {TextColor3 = textSecondary}):Play()
                end)

                local statusPill = Util.make('Frame', {
                    Name = 'StatusPill',
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.new(0.5, 0, 0, 120),
                    Size = UDim2.fromOffset(240, 20),
                    BackgroundColor3 = pillBg,
                    BorderSizePixel = 0,
                    Parent = mainFrame,
                })

                Util.addCorner(statusPill, 10)
                Util.addStroke(statusPill, borderGray, 0.3, 1)

                local statusDot = Util.make('Frame', {
                    Name = 'StatusDot',
                    Position = UDim2.fromOffset(8, 7),
                    Size = UDim2.fromOffset(6, 6),
                    BackgroundColor3 = statusCyan,
                    BorderSizePixel = 0,
                    Parent = statusPill,
                })

                Util.addCorner(statusDot, 6)

                local statusLabel = Util.make('TextLabel', {
                    Name = 'StatusLabel',
                    Position = UDim2.fromOffset(20, 0),
                    Size = UDim2.new(1, -28, 1, 0),
                    Text = 'awaiting verification',
                    TextColor3 = iconSoftWhite,
                    TextSize = 10,
                    FontFace = cleanFont,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = statusPill,
                })

                task.spawn(function()
                    while statusPill and statusPill.Parent do
                        TweenService:Create(statusDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.5}):Play()
                        task.wait(0.8)
                        TweenService:Create(statusDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play()
                        task.wait(0.8)
                    end
                end)
                noteBtn.MouseButton1Click:Connect(function()
                    local linkToCopy = self._options.DiscordUrl ~= '' and self._options.DiscordUrl or discord
                    local copied = Util.copyToClipboard(linkToCopy)

                    if copied then
                        statusLabel.Text = 'copied discord invite link!'

                        Notification.new({
                            Title = 'Clipboard Success',
                            Content = 'Discord invite link copied to clipboard!',
                            Type = 'Success',
                            AccentColor = textPrimary,
                        })
                    else
                        statusLabel.Text = 'failed to copy link!'

                        Notification.new({
                            Title = 'Clipboard Error',
                            Content = 'Failed to copy Discord link! Check console.',
                            Type = 'Error',
                            AccentColor = textPrimary,
                        })
                    end

                    task.delay(3, function()
                        if statusLabel.Text == 'copied discord invite link!' or statusLabel.Text == 'failed to copy link!' then
                            statusLabel.Text = 'awaiting verification'
                        end
                    end)
                end)

                local buttonsContainer = Util.make('Frame', {
                    Name = 'ButtonsContainer',
                    Position = UDim2.fromOffset(15, 150),
                    Size = UDim2.new(1, -30, 0, 38),
                    BackgroundTransparency = 1,
                    Parent = mainFrame,
                })
                local loginBtn = Util.make('TextButton', {
                    Name = 'LoginButton',
                    Position = UDim2.fromOffset(0, 0),
                    Size = UDim2.fromOffset(198, 36),
                    BackgroundColor3 = textPrimary,
                    BorderSizePixel = 0,
                    Text = '',
                    AutoButtonColor = false,
                    Parent = buttonsContainer,
                })

                Util.addCorner(loginBtn, 8)

                local loginStroke = Util.addStroke(loginBtn, textPrimary, 0.1, 1)
                local loginContent = Util.make('Frame', {
                    Name = 'Content',
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Parent = loginBtn,
                })

                Util.make('ImageLabel', {
                    Name = 'Icon',
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 42, 0.5, 0),
                    Size = UDim2.fromOffset(16, 16),
                    BackgroundTransparency = 1,
                    Image = 'rbxassetid://16898613777',
                    ImageRectOffset = Vector2.new(820, 257),
                    ImageRectSize = Vector2.new(48, 48),
                    ImageColor3 = darkButtonText,
                    Parent = loginContent,
                })
                Util.make('TextLabel', {
                    Name = 'Label',
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 66, 0.5, 0),
                    Size = UDim2.new(1, -70, 1, 0),
                    Text = 'Verify Key',
                    TextColor3 = darkButtonText,
                    TextSize = 12,
                    FontFace = cleanFontBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Parent = loginContent,
                })
                loginBtn.MouseEnter:Connect(function()
                    TweenService:Create(loginBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    }):Play()
                end)
                loginBtn.MouseLeave:Connect(function()
                    TweenService:Create(loginBtn, TweenInfo.new(0.2), {BackgroundColor3 = textPrimary}):Play()
                end)

                local getKeyBtn = Util.make('TextButton', {
                    Name = 'GetKeyButton',
                    Position = UDim2.fromOffset(212, 0),
                    Size = UDim2.fromOffset(198, 36),
                    BackgroundColor3 = innerPanelBg,
                    BorderSizePixel = 0,
                    Text = '',
                    AutoButtonColor = false,
                    Parent = buttonsContainer,
                })

                Util.addCorner(getKeyBtn, 8)

                local getKeyStroke = Util.addStroke(getKeyBtn, borderGray, 0.35, 1)
                local getKeyContent = Util.make('Frame', {
                    Name = 'Content',
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Parent = getKeyBtn,
                })
                local getKeyIcon = Util.make('ImageLabel', {
                    Name = 'Icon',
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 48, 0.5, 0),
                    Size = UDim2.fromOffset(16, 16),
                    BackgroundTransparency = 1,
                    Image = 'rbxassetid://16898613509',
                    ImageRectOffset = Vector2.new(869, 404),
                    ImageRectSize = Vector2.new(48, 48),
                    ImageColor3 = iconSoftWhite,
                    Parent = getKeyContent,
                })
                local getKeyLabel = Util.make('TextLabel', {
                    Name = 'Label',
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 72, 0.5, 0),
                    Size = UDim2.new(1, -76, 1, 0),
                    Text = 'Get Key',
                    TextColor3 = textPrimary,
                    TextSize = 12,
                    FontFace = cleanFontBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Parent = getKeyContent,
                })

                getKeyBtn.MouseEnter:Connect(function()
                    TweenService:Create(getKeyBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(34, 42, 58),
                    }):Play()
                    TweenService:Create(getKeyStroke, TweenInfo.new(0.2), {
                        Color = Color3.fromRGB(80, 100, 130),
                    }):Play()
                end)
                getKeyBtn.MouseLeave:Connect(function()
                    TweenService:Create(getKeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = innerPanelBg}):Play()
                    TweenService:Create(getKeyStroke, TweenInfo.new(0.2), {Color = borderGray}):Play()
                end)

                local isVerifying = false

                loginBtn.MouseButton1Click:Connect(function()
                    if isVerifying then
                        return
                    end

                    isVerifying = true

                    task.spawn(function()
                        statusLabel.Text = 'verifying key...'

                        task.wait(0.4)

                        local entered = keyTextBox.Text:match('^%s*(.-)%s*$')
                        local isValid = self:_validate(entered)

                        if isValid then
                            print('Guard: Key is valid!')

                            statusLabel.Text = 'verification successful!'

                            Cache.saveCachedKey(self._options.ConfigName, entered)
                            Notification.new({
                                Title = 'Access Granted',
                                Content = 'Key verification successful. Loading...',
                                Type = 'Success',
                                AccentColor = textPrimary,
                            })

                            if self._options.OnSuccess then
                                task.spawn(function()
                                    local ok, err = pcall(self._options.OnSuccess)

                                    if not ok then
                                        warn('Guard: OnSuccess crashed:', tostring(err))
                                    end
                                end)
                            end

                            task.wait(0.5)
                            self:Destroy()
                        else
                            statusLabel.Text = 'invalid key! please try again.'

                            Notification.new({
                                Title = 'Access Denied',
                                Content = 'The key you entered is invalid. Please try again.',
                                Type = 'Error',
                                AccentColor = textPrimary,
                            })

                            local originalPos = mainFrame.Position

                            task.spawn(function()
                                for i = 1, 6 do
                                    local offset = (i % 2 == 0) and 4 or -4

                                    mainFrame.Position = originalPos + UDim2.fromOffset(offset, 0)

                                    task.wait(0.04)
                                end

                                mainFrame.Position = originalPos
                            end)

                            isVerifying = false
                        end
                    end)
                end)
                getKeyBtn.MouseButton1Click:Connect(function()
                    local link = self._options.GetKeyUrl ~= '' and self._options.GetKeyUrl or 'https://example.com/get-key'
                    local copied = Util.copyToClipboard(link)

                    if copied then
                        statusLabel.Text = 'copied get-key URL to clipboard!'

                        Notification.new({
                            Title = 'Clipboard Success',
                            Content = 'Key URL copied to clipboard!',
                            Type = 'Success',
                            AccentColor = textPrimary,
                        })
                    else
                        statusLabel.Text = 'failed to copy key URL!'

                        Notification.new({
                            Title = 'Clipboard Error',
                            Content = 'Failed to copy key URL!',
                            Type = 'Error',
                            AccentColor = textPrimary,
                        })
                    end

                    task.delay(3, function()
                        if statusLabel.Text == 'copied get-key URL to clipboard!' or statusLabel.Text == 'failed to copy key URL!' then
                            statusLabel.Text = 'awaiting verification'
                        end
                    end)
                end)

                mainFrame.Size = UDim2.fromOffset(windowWidth, 0)
                mainFrame.ClipsDescendants = true

                TweenService:Create(mainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                    Size = UDim2.fromOffset(windowWidth, windowHeight),
                }):Play()
                task.delay(0.45, function()
                    mainFrame.ClipsDescendants = false
                end)
            end
            function UI.destroy(self)
                if self._screenGui then
                    self._screenGui:Destroy()

                    self._screenGui = nil
                end
            end

            return UI
        end

        function __DARKLUA_BUNDLE_MODULES.d(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.d

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.d = v
            end

            return v.c
        end
    end
end

local Cache = __DARKLUA_BUNDLE_MODULES.a()
local UI = __DARKLUA_BUNDLE_MODULES.d()
local Guard = {}

Guard.__index = Guard

local DEFAULT_OPTIONS = {
    Title = 'Guard Key System',
    Subtitle = 'Key System',
    Logo = 'none',
    GetKeyUrl = '',
    DiscordUrl = '',
    NoteText = '',
    Key = '',
    ConfigName = 'guard_default',
    AccentColor = Color3.fromRGB(240, 240, 240),
    OnSuccess = nil,
}

function Guard.new(options)
    local self = setmetatable({}, Guard)

    options = options or {}
    self._options = {}

    for k, v in pairs(DEFAULT_OPTIONS)do
        self._options[k] = v
    end
    for k, v in pairs(options)do
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

    if type(expected) == 'function' then
        local ok, result = pcall(expected, inputKey)

        return ok and result == true
    elseif type(expected) == 'table' then
        for _, k in ipairs(expected)do
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

end)()

print('[Guard Test] Launching Guard Key System in Obsidian Slate Theme...')
local guardInstance = Guard.new({
    Title = 'Guard Key System',
    Subtitle = 'Sleek Obsidian Slate Glass Verification',
    Logo = 'shield-check',
    Key = '1234',
    GetKeyUrl = 'https://example.com/get-key',
    DiscordUrl = 'https://discord.gg/monoui',
    NoteText = 'Gunakan key: 1234 untuk meverifikasi.',
    ConfigName = 'guard_obsidian_test',
    AccentColor = Color3.fromRGB(56, 189, 248),
    OnSuccess = function()
        print('[Guard Test] Key Verified Successfully! Access Granted.')
    end
})
