-- ByteUI - A Modern UI Library for Lua
-- Version: 1.1.0
-- Author: ByteRide Team
-- Key System inspired by Rayfield Interface Suite

local ByteUI = {}
ByteUI.__index = ByteUI

-- Core Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")

-- Detect device type
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled
local IS_TABLET = false
local IS_DESKTOP = not IS_MOBILE

-- Detect screen size for responsive design
local function getScreenInfo()
    local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
    local isPortrait = viewportSize.Y > viewportSize.X
    
    -- Determine device type based on screen size (rough estimates)
    if IS_MOBILE then
        local minDimension = math.min(viewportSize.X, viewportSize.Y)
        IS_TABLET = minDimension > 600 -- Tablets typically have larger screens
    end
    
    return {
        Width = viewportSize.X,
        Height = viewportSize.Y,
        IsPortrait = isPortrait,
        IsLandscape = not isPortrait,
        IsTablet = IS_TABLET,
        IsPhone = IS_MOBILE and not IS_TABLET,
        IsDesktop = IS_DESKTOP,
        Scale = math.clamp(math.min(viewportSize.X / 1920, viewportSize.Y / 1080), 0.5, 1.5)
    }
end

-- Mobile-safe input handling
local function createTouchButton(name, parent, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.BackgroundTransparency = 0.8
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.BorderSizePixel = 0
    button.Size = UDim2.new(0, 60, 0, 60)
    button.Position = UDim2.new(1, -70, 1, -70)
    button.ZIndex = 1000
    button.Visible = IS_MOBILE
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0) -- Make it circular
    corner.Parent = button
    
    -- Add touch feedback
    local function onTouchBegan()
        button.BackgroundTransparency = 0.7
    end
    
    local function onTouchEnded()
        button.BackgroundTransparency = 0.8
        if callback then
            callback()
        end
    end
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            onTouchBegan()
        end
    end)
    
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            onTouchEnded()
        end
    end)
    
    -- Prevent touch event propagation
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            input:GetPropertyChangedSignal("UserInputState"):Wait()
            if input.UserInputState == Enum.UserInputState.End then
                onTouchEnded()
            end
        end
    end)
    
    return button
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = button
    
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Text = "≡" -- Menu icon
    icon.TextSize = 30
    icon.TextColor3 = Color3.new(1, 1, 1)
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.Parent = button
    
    -- Touch handling
    local isTouching = false
    local touchStartPos = nil
    local touchStartTime = 0
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            isTouching = true
            touchStartPos = input.Position
            touchStartTime = tick()
            
            -- Visual feedback
            button.BackgroundTransparency = 0.7
            icon.TextTransparency = 0.2
        end
    end)
    
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and isTouching then
            isTouching = false
            button.BackgroundTransparency = 0.8
            icon.TextTransparency = 0
            
            -- Check if it was a tap (not a swipe)
            local touchEndPos = input.Position
            local distance = (touchEndPos - touchStartPos).Magnitude
            local duration = tick() - touchStartTime
            
            if distance < 10 and duration < 0.5 then
                -- It's a tap
                if callback then
                    callback()
                end
            end
        end
    end)
    
    return button
end

-- Constants
local KEY_SYSTEM_FOLDER = "ByteUI_Keys"
local KEY_FILE_EXTENSION = ".key"

-- Default Theme with Blue to White gradient
ByteUI.DefaultTheme = {
    PrimaryColor = Color3.fromRGB(0, 120, 255),      -- Deep Blue
    SecondaryColor = Color3.fromRGB(0, 150, 255),   -- Medium Blue
    BackgroundColor = Color3.fromRGB(25, 25, 35),   -- Dark background
    TextColor = Color3.fromRGB(255, 255, 255),      -- White text
    AccentColor = Color3.fromRGB(0, 200, 255),      -- Bright Cyan
    ErrorColor = Color3.fromRGB(255, 80, 80),       -- Soft Red
    SuccessColor = Color3.fromRGB(0, 200, 150),     -- Teal
    WarningColor = Color3.fromRGB(255, 180, 0),     -- Amber
    CornerRadius = UDim.new(0, 8),                  -- Slightly more rounded corners
    Padding = UDim.new(0, 12),                      -- Slightly more padding
    Font = Enum.Font.Gotham,                        -- Modern font
    TextSize = 14,
    
    -- Animation settings
    AnimationDuration = 0.3,                        -- Default animation duration
    AnimationStyle = Enum.EasingStyle.Quad,         -- Default animation style
    AnimationDirection = Enum.EasingDirection.Out   -- Default animation direction
}

-- Current Theme (can be customized)
ByteUI.Theme = table.clone(ByteUI.DefaultTheme)

-- Animation Module
ByteUI.Animations = {}
ByteUI.Animations.__index = ByteUI.Animations

-- Notification System
ByteUI.Notifications = {}
ByteUI.ActiveNotifications = {}

-- Tab System
ByteUI.TabSystem = {}
ByteUI.TabSystem.__index = ByteUI.TabSystem

-- Toggle Switch Component
ByteUI.Toggle = {}
ByteUI.Toggle.__index = ByteUI.Toggle

-- Slider Component
ByteUI.Slider = {}
ByteUI.Slider.__index = ByteUI.Slider

-- Dropdown Component
ByteUI.Dropdown = {}
ByteUI.Dropdown.__index = ByteUI.Dropdown

-- Keybind Component
ByteUI.Keybind = {}
ByteUI.Keybind.__index = ByteUI.Keybind

-- Color Picker Component
ByteUI.ColorPicker = {}
ByteUI.ColorPicker.__index = ByteUI.ColorPicker

-- Animation presets
ByteUI.Animations.Presets = {
    FadeIn = {
        Property = "BackgroundTransparency",
        From = 1,
        To = 0
    },
    FadeOut = {
        Property = "BackgroundTransparency",
        From = 0,
        To = 1
    },
    SlideUp = {
        Property = "Position",
        From = UDim2.new(0.5, 0, 1, 0),
        To = UDim2.new(0.5, 0, 0.5, 0)
    },
    SlideDown = {
        Property = "Position",
        From = UDim2.new(0.5, 0, 0, -50),
        To = UDim2.new(0.5, 0, 0, 0)
    },
    PopIn = {
        Property = "Size",
        From = UDim2.new(0, 0, 0, 0),
        To = UDim2.new(1, 0, 1, 0)
    },
    PopOut = {
        Property = "Size",
        From = UDim2.new(1, 0, 1, 0),
        To = UDim2.new(0, 0, 0, 0)
    }
}

-- Create a new animation
function ByteUI.Animations.new(instance, preset, options)
    options = options or {}
    local self = setmetatable({}, ByteUI.Animations)
    
    self.Instance = instance
    self.Preset = preset
    self.Duration = options.Duration or ByteUI.Theme.AnimationDuration
    self.EasingStyle = options.EasingStyle or ByteUI.Theme.AnimationStyle
    self.EasingDirection = options.EasingDirection or ByteUI.Theme.AnimationDirection
    self.Completed = Instance.new("BindableEvent")
    
    return self
end

-- Play the animation
function ByteUI.Animations:Play()
    if not self.Preset or not self.Instance then return end
    
    local preset = ByteUI.Animations.Presets[self.Preset]
    if not preset then return end
    
    -- Set initial state
    self.Instance[preset.Property] = preset.From
    
    -- Create and play the tween
    local tweenInfo = TweenInfo.new(
        self.Duration,
        self.EasingStyle,
        self.EasingDirection
    )
    
    local tween = TweenService:Create(self.Instance, tweenInfo, {
        [preset.Property] = preset.To
    })
    
    tween.Completed:Connect(function()
        self.Completed:Fire()
    end)
    
    tween:Play()
    return tween
end

-- Chain multiple animations
function ByteUI.Animations.Chain(animations, onComplete)
    local function playNext(index)
        if index > #animations then
            if onComplete then onComplete() end
            return
        end
        
        local anim = animations[index]
        if not anim.Instance then
            playNext(index + 1)
            return
        end
        
        local connection
        connection = anim.Completed.Event:Connect(function()
            connection:Disconnect()
            playNext(index + 1)
        end)
        
        anim:Play()
    end
    
    playNext(1)
end

-- Create a gradient with the theme colors
--[[
    Creates a notification
    @param options table - Configuration for the notification
        - Title: string - Notification title
        - Content: string - Notification content
        - Duration: number - How long to display (default: 5)
        - Icon: string - Optional icon (emoji or image ID)
        - Callback: function - Function to call when clicked
]]
function ByteUI:Notify(options)
    options = options or {}
    local duration = options.Duration or 5
    
    -- Create notification container
    local notification = Instance.new("Frame")
    notification.Name = "Notification_" .. HttpService:GenerateGUID()
    notification.BackgroundColor3 = self.Theme.BackgroundColor
    notification.BackgroundTransparency = 0.2
    notification.BorderSizePixel = 0
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, 10, 1, -90 * (#self.ActiveNotifications + 1) - 10)
    notification.AnchorPoint = Vector2.new(1, 1)
    notification.ZIndex = 100
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = self.Theme.CornerRadius
    corner.Parent = notification
    
    -- Add gradient background
    local gradient = self:CreateGradient(notification, {
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.8),
            NumberSequenceKeypoint.new(1, 0.9)
        })
    })
    
    -- Add title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Font = self.Theme.Font
    title.TextColor3 = self.Theme.TextColor
    title.TextSize = self.Theme.TextSize + 2
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = options.Title or "Notification"
    title.Position = UDim2.new(0, 45, 0, 10)
    title.Size = UDim2.new(1, -55, 0, 20)
    title.BackgroundTransparency = 1
    title.Parent = notification
    
    -- Add content
    local content = Instance.new("TextLabel")
    content.Name = "Content"
    content.Font = self.Theme.Font
    content.TextColor3 = self.Theme.TextColor
    content.TextTransparency = 0.3
    content.TextSize = self.Theme.TextSize - 2
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.TextWrapped = true
    content.Text = options.Content or ""
    content.Position = UDim2.new(0, 45, 0, 35)
    content.Size = UDim2.new(1, -55, 1, -45)
    content.BackgroundTransparency = 1
    content.Parent = notification
    
    -- Add icon
    if options.Icon then
        local icon = Instance.new("TextLabel")
        icon.Name = "Icon"
        icon.Font = Enum.Font.GothamBold
        icon.Text = options.Icon:match("^%d+$") and "" or options.Icon
        icon.TextSize = 20
        icon.TextColor3 = self.Theme.AccentColor
        icon.Size = UDim2.new(0, 30, 0, 30)
        icon.Position = UDim2.new(0, 10, 0, 10)
        icon.BackgroundTransparency = 1
        icon.Parent = notification
        
        if options.Icon:match("^%d+$") then
            -- It's an image ID
            local image = Instance.new("ImageLabel")
            image.Name = "Image"
            image.Image = "rbxassetid://" .. options.Icon
            image.Size = UDim2.new(1, 0, 1, 0)
            image.BackgroundTransparency = 1
            image.Parent = icon
        end
    end
    
    -- Add close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Text = "✕"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.TextColor3 = self.Theme.TextColor
    closeButton.TextTransparency = 0.5
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.BackgroundTransparency = 1
    closeButton.Parent = notification
    
    -- Add to screen
    notification.Parent = CoreGui
    table.insert(self.ActiveNotifications, notification)
    
    -- Update positions
    for i, notif in ipairs(self.ActiveNotifications) do
        self:CreateTween(notif, "Position", 
            UDim2.new(1, 10, 1, -90 * i - 10), 0.3, Enum.EasingStyle.Quad)
    end
    
    -- Auto-remove after duration
    local removeConnection
    local function remove()
        if removeConnection then removeConnection:Disconnect() end
        
        -- Fade out
        local tween = self:CreateTween(notification, "Position", 
            UDim2.new(1.5, 0, 1, notification.Position.Y.Offset), 0.3, Enum.EasingStyle.Quad)
        
        tween.Completed:Connect(function()
            -- Remove from active notifications
            for i, notif in ipairs(self.ActiveNotifications) do
                if notif == notification then
                    table.remove(self.ActiveNotifications, i)
                    break
                end
            end
            
            -- Update remaining notifications
            for i, notif in ipairs(self.ActiveNotifications) do
                self:CreateTween(notif, "Position", 
                    UDim2.new(1, 10, 1, -90 * i - 10), 0.3, Enum.EasingStyle.Quad)
            end
            
            notification:Destroy()
        end)
    end
    
    removeConnection = game:GetService("RunService").Heartbeat:Connect(function(delta)
        duration = duration - delta
        if duration <= 0 then
            remove()
        end
    end)
    
    -- Click to dismiss
    local function onClick()
        if options.Callback then
            options.Callback()
        end
        remove()
    end
    
    notification.MouseButton1Click:Connect(onClick)
    closeButton.MouseButton1Click:Connect(remove)
    
    return {
        Remove = remove
    }
end

--[[
    Creates a tab system
    @param parent Instance - Parent instance
    @param tabs table - Array of tab names
    @param options table - Configuration options
]]
function ByteUI:CreateTabSystem(parent, tabs, options)
    options = options or {}
    
    local tabSystem = setmetatable({
        Tabs = {},
        CurrentTab = nil,
        Container = nil
    }, self.TabSystem)
    
    -- Create main container
    tabSystem.Container = Instance.new("Frame")
    tabSystem.Container.Name = "TabSystem"
    tabSystem.Container.BackgroundTransparency = 1
    tabSystem.Container.Size = UDim2.new(1, 0, 1, 0)
    tabSystem.Container.Parent = parent
    
    -- Create tab buttons container
    local tabButtons = Instance.new("Frame")
    tabButtons.Name = "TabButtons"
    tabButtons.BackgroundTransparency = 1
    tabButtons.Size = UDim2.new(1, 0, 0, 40)
    tabButtons.Position = UDim2.new(0, 0, 0, 0)
    tabButtons.Parent = tabSystem.Container
    
    -- Create tab content container
    local tabContent = Instance.new("Frame")
    tabContent.Name = "TabContent"
    tabContent.BackgroundTransparency = 1
    tabContent.Size = UDim2.new(1, 0, 1, -45)
    tabContent.Position = UDim2.new(0, 0, 0, 45)
    tabContent.ClipsDescents = true
    tabContent.Parent = tabSystem.Container
    
    -- Create tab buttons
    local buttonWidth = 1 / #tabs
    for i, tabName in ipairs(tabs) do
        local button = Instance.new("TextButton")
        button.Name = tabName .. "Tab"
        button.Text = tabName
        button.Font = self.Theme.Font
        button.TextSize = self.Theme.TextSize
        button.TextColor3 = self.Theme.TextColor
        button.TextTransparency = 0.5
        button.BackgroundTransparency = 1
        button.Size = UDim2.new(buttonWidth, 0, 1, 0)
        button.Position = UDim2.new(buttonWidth * (i-1), 0, 0, 0)
        button.Parent = tabButtons
        
        -- Add hover effect
        button.MouseEnter:Connect(function()
            if tabSystem.CurrentTab ~= tabName then
                self:CreateTween(button, "TextTransparency", 0.2, 0.2)
            end
        end)
        
        button.MouseLeave:Connect(function()
            if tabSystem.CurrentTab ~= tabName then
                self:CreateTween(button, "TextTransparency", 0.5, 0.2)
            end
        end)
        
        -- Add click handler
        button.MouseButton1Click:Connect(function()
            tabSystem:SwitchToTab(tabName)
        end)
        
        -- Create tab content
        local content = Instance.new("Frame")
        content.Name = tabName
        content.BackgroundTransparency = 1
        content.Size = UDim2.new(1, 0, 1, 0)
        content.Visible = false
        content.Parent = tabContent
        
        tabSystem.Tabs[tabName] = {
            Button = button,
            Content = content
        }
    end
    
    -- Set first tab as active
    if #tabs > 0 then
        tabSystem:SwitchToTab(tabs[1])
    end
    
    return tabSystem
end

-- Switch to a specific tab
function ByteUI.TabSystem:SwitchToTab(tabName)
    if self.Tabs[tabName] == nil then return end
    
    -- Hide current tab
    if self.CurrentTab then
        self.Tabs[self.CurrentTab].Content.Visible = false
        self:CreateTween(self.Tabs[self.CurrentTab].Button, "TextTransparency", 0.5, 0.2)
    end
    
    -- Show new tab
    self.CurrentTab = tabName
    self.Tabs[tabName].Content.Visible = true
    self:CreateTween(self.Tabs[tabName].Button, "TextTransparency", 0, 0.2)
    
    -- Highlight the active tab button
    for name, tab in pairs(self.Tabs) do
        if name == tabName then
            self:CreateTween(tab.Button, "TextColor3", self.Theme.AccentColor, 0.2)
        else
            self:CreateTween(tab.Button, "TextColor3", self.Theme.TextColor, 0.2)
        end
    end
end

function ByteUI:CreateGradient(parent, options)
    options = options or {}
    local gradient = Instance.new("UIGradient")
    
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.Theme.PrimaryColor),
        ColorSequenceKeypoint.new(0.5, self.Theme.AccentColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    
    if options.Rotation then
        gradient.Rotation = options.Rotation
    end
    
    if options.Transparency then
        gradient.Transparency = options.Transparency
    end
    
    if parent then
        gradient.Parent = parent
    end
    
    return gradient
end

--[[
    Makes a UI element smoothly draggable with momentum and bounds checking
    @param dragPoint GuiObject - The element that will be used to drag (e.g., title bar)
    @param mainFrame GuiObject - The element that will be moved (e.g., window)
    @param options table - Optional configuration
        - bounds: UDim2 - Maximum distance from screen edges {X = {Min, Max}, Y = {Min, Max}}
        - momentum: boolean - Whether to enable momentum effect (default: true)
        - smoothness: number - How smooth the movement is (0-1, higher = smoother)
        - onDragStart: function() - Callback when dragging starts
        - onDragEnd: function() - Callback when dragging ends
]]
function ByteUI:MakeDraggable(dragPoint, mainFrame, options)
    options = options or {}
    local bounds = options.bounds or {
        X = {Min = 0, Max = 1},
        Y = {Min = 0, Max = 1}
    }
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local velocity = Vector2.new(0, 0)
    local lastPos = nil
    local lastTime = 0
    local smoothness = options.smoothness or 0.8
    local useMomentum = options.momentum ~= false
    local connection
    
    -- Function to clamp position within bounds
    local function clampPosition(position)
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local absPos = UDim2.new(
            math.clamp(position.X.Scale, bounds.X.Min, bounds.X.Max),
            position.X.Offset,
            math.clamp(position.Y.Scale, bounds.Y.Min, bounds.Y.Max),
            position.Y.Offset
        )
        
        -- Convert to pixel position for bounds checking
        local pixelX = absPos.X.Offset + (absPos.X.Scale * viewportSize.X)
        local pixelY = absPos.Y.Offset + (absPos.Y.Scale * viewportSize.Y)
        
        -- Keep window fully on screen
        local windowSize = mainFrame.AbsoluteSize
        if pixelX < 0 then
            absPos = UDim2.new(0, 0, absPos.Y.Scale, absPos.Y.Offset)
        elseif pixelX + windowSize.X > viewportSize.X then
            absPos = UDim2.new(1, -windowSize.X, absPos.Y.Scale, absPos.Y.Offset)
        end
        
        if pixelY < 0 then
            absPos = UDim2.new(absPos.X.Scale, absPos.X.Offset, 0, 0)
        elseif pixelY + windowSize.Y > viewportSize.Y then
            absPos = UDim2.new(absPos.X.Scale, absPos.X.Offset, 1, -windowSize.Y)
        end
        
        return absPos
    end
    
    -- Update position with smooth movement
    local function updatePosition(newPos)
        if not mainFrame or not mainFrame.Parent then return end
        
        -- Apply smooth movement
        local currentPos = mainFrame.Position
        local smoothPos = UDim2.new(
            currentPos.X.Scale + (newPos.X.Scale - currentPos.X.Scale) * (1 - smoothness),
            currentPos.X.Offset + (newPos.X.Offset - currentPos.X.Offset) * (1 - smoothness),
            currentPos.Y.Scale + (newPos.Y.Scale - currentPos.Y.Scale) * (1 - smoothness),
            currentPos.Y.Offset + (newPos.Y.Offset - currentPos.Y.Offset) * (1 - smoothness)
        )
        
        mainFrame.Position = clampPosition(smoothPos)
    end
    
    -- Handle mouse movement with momentum
    local function onRenderStep(deltaTime)
        if not dragging and useMomentum and velocity.Magnitude > 0.1 then
            -- Apply friction
            velocity = velocity * (0.9 ^ (deltaTime * 60)) -- 60 FPS normalized
            
            -- Update position based on velocity
            local currentPos = mainFrame.Position
            local newPos = UDim2.new(
                currentPos.X.Scale,
                currentPos.X.Offset + velocity.X,
                currentPos.Y.Scale,
                currentPos.Y.Offset + velocity.Y
            )
            
            updatePosition(newPos)
        end
    end
    
    -- Connect render step for smooth updates
    connection = RunService.RenderStepped:Connect(onRenderStep)
    
    -- Handle drag start
    local function onDragStart(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            velocity = Vector2.new(0, 0)
            lastPos = input.Position
            lastTime = tick()
            
            if options.onDragStart then
                options.onDragStart()
            end
            
            -- Connect to input changed for smooth dragging
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    
                    if options.onDragEnd then
                        options.onDragEnd()
                    end
                    
                    connection:Disconnect()
                end
            end)
            
            return true
        end
        return false
    end
    
    -- Handle drag movement
    local function onDragMove(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            
            -- Calculate velocity for momentum
            local currentTime = tick()
            local deltaTime = currentTime - lastTime
            if deltaTime > 0 then
                velocity = (input.Position - lastPos) / deltaTime
            end
            lastPos = input.Position
            lastTime = currentTime
            
            updatePosition(newPos)
        end
    end
    
    -- Connect events
    dragPoint.InputBegan:Connect(onDragStart)
    dragPoint.InputChanged:Connect(onDragMove)
    
    -- Cleanup function
    local function cleanup()
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
    
    -- Return cleanup function
    return {
        Destroy = cleanup,
        SetBounds = function(newBounds)
            bounds = newBounds or {X = {Min = 0, Max = 1}, Y = {Min = 0, Max = 1}}
            mainFrame.Position = clampPosition(mainFrame.Position)
        end,
        SetMomentum = function(enabled)
            useMomentum = enabled ~= false
        end,
        SetSmoothness = function(value)
            smoothness = math.clamp(value or 0.8, 0, 1)
        end
    }
end

-- Key System Module
ByteUI.KeySystem = {}
ByteUI.KeySystem.__index = ByteUI.KeySystem

--[[
    Creates a new KeySystem instance
    @param config table - Configuration for the key system
        - key: string - The valid key
        - fileName: string - File to store the key
        - title: string - Title for the key UI
        - subtitle: string - Subtitle for the key UI
        - note: string - Instructions for the user
]]
function ByteUI.KeySystem.new(config)
    local self = setmetatable({}, ByteUI.KeySystem)
    
    self.key = config.key
    self.fileName = config.fileName or "default"
    self.title = config.title or "Key System"
    self.subtitle = config.subtitle or "Enter your key"
    self.note = config.note or "Please enter your key to continue"
    self.validated = false
    
    -- Create key system folder if it doesn't exist
    if not isfolder(KEY_SYSTEM_FOLDER) then
        makefolder(KEY_SYSTEM_FOLDER)
    end
    
    return self
end

-- Validates the stored key if it exists
function ByteUI.KeySystem:hasValidKey()
    local keyFile = KEY_SYSTEM_FOLDER.."/"..self.fileName..KEY_FILE_EXTENSION
    if isfile(keyFile) then
        local storedKey = readfile(keyFile)
        if storedKey == self.key then
            self.validated = true
            return true
        end
    end
    return false
end

-- Saves the key if it's valid
function ByteUI.KeySystem:saveKey()
    local keyFile = KEY_SYSTEM_FOLDER.."/"..self.fileName..KEY_FILE_EXTENSION
    writefile(keyFile, self.key)
    self.validated = true
end

-- Shows the key entry UI
function ByteUI.KeySystem:showKeyUI()
    local uiParent = gethui and gethui() or CoreGui
    
    -- Create main container
    local keyUI = Instance.new("ScreenGui")
    keyUI.Name = "ByteUI_KeySystem"
    keyUI.ResetOnSpawn = false
    
    -- Create main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 450, 0, 250)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -125)
    mainFrame.BackgroundColor3 = ByteUI.Theme.BackgroundColor
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = keyUI
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = ByteUI.Theme.CornerRadius
    corner.Parent = mainFrame
    
    -- Add shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = -1
    shadow.Parent = mainFrame
    
    -- Add title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -40, 0, 30)
    title.Position = UDim2.new(0, 20, 0, 20)
    title.BackgroundTransparency = 1
    title.Font = ByteUI.Theme.Font
    title.Text = self.title
    title.TextColor3 = ByteUI.Theme.TextColor
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainFrame
    
    -- Add subtitle
    local subtitle = title:Clone()
    subtitle.Name = "Subtitle"
    subtitle.Position = UDim2.new(0, 20, 0, 50)
    subtitle.Text = self.subtitle
    subtitle.TextSize = 14
    subtitle.TextTransparency = 0.3
    subtitle.Parent = mainFrame
    
    -- Add input box
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "InputFrame"
    inputFrame.Size = UDim2.new(1, -40, 0, 40)
    inputFrame.Position = UDim2.new(0, 20, 0, 90)
    inputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = mainFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = inputFrame
    
    local inputBox = Instance.new("TextBox")
    inputBox.Name = "InputBox"
    inputBox.Size = UDim2.new(1, -20, 1, 0)
    inputBox.Position = UDim2.new(0, 10, 0, 0)
    inputBox.BackgroundTransparency = 1
    inputBox.Font = ByteUI.Theme.Font
    inputBox.PlaceholderText = "Enter your key here..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    inputBox.Text = ""
    inputBox.TextColor3 = ByteUI.Theme.TextColor
    inputBox.TextSize = 14
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.Parent = inputFrame
    
    -- Add note
    local note = Instance.new("TextLabel")
    note.Name = "Note"
    note.Size = UDim2.new(1, -40, 0, 0)
    note.Position = UDim2.new(0, 20, 0, 150)
    note.BackgroundTransparency = 1
    note.Font = ByteUI.Theme.Font
    note.Text = self.note
    note.TextColor3 = Color3.fromRGB(150, 150, 150)
    note.TextSize = 12
    note.TextWrapped = true
    note.TextXAlignment = Enum.TextXAlignment.Left
    note.TextYAlignment = Enum.TextYAlignment.Top
    note.AutomaticSize = Enum.AutomaticSize.Y
    note.Parent = mainFrame
    
    -- Add submit button
    local submitButton = Instance.new("TextButton")
    submitButton.Name = "SubmitButton"
    submitButton.Size = UDim2.new(0, 100, 0, 35)
    submitButton.Position = UDim2.new(1, -120, 1, -15)
    submitButton.BackgroundColor3 = ByteUI.Theme.PrimaryColor
    submitButton.BorderSizePixel = 0
    submitButton.Font = ByteUI.Theme.Font
    submitButton.Text = "Submit"
    submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitButton.TextSize = 14
    submitButton.Parent = mainFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = submitButton
    
    -- Add close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 100, 0, 35)
    closeButton.Position = UDim2.new(0, 20, 1, -15)
    closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    closeButton.BorderSizePixel = 0
    closeButton.Font = ByteUI.Theme.Font
    closeButton.Text = "Close"
    closeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeButton.TextSize = 14
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    -- Animation
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(mainFrame, tweenInfo, {
        Size = UDim2.new(0, 450, 0, 250),
        Position = UDim2.new(0.5, -225, 0.5, -125)
    }):Play()
    
    -- Show UI
    keyUI.Parent = uiParent
    
    -- Handle submit
    local function onSubmit()
        local enteredKey = inputBox.Text
        if enteredKey == self.key then
            self:saveKey()
            
            -- Animate out and destroy
            TweenService:Create(mainFrame, tweenInfo, {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
            
            wait(0.3)
            keyUI:Destroy()
            return true
        else
            -- Shake animation for wrong key
            local shakeInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 3, true)
            TweenService:Create(mainFrame, shakeInfo, {
                Position = UDim2.new(0.5, 10, 0.5, -125)
            }):Play()
            
            inputBox.Text = ""
            inputBox.PlaceholderText = "Invalid key, try again..."
            inputBox.PlaceholderColor3 = ByteUI.Theme.ErrorColor
            return false
        end
    end
    
    -- Connect events
    submitButton.MouseButton1Click:Connect(function()
        onSubmit()
    end)
    
    inputBox.Focused:Connect(function()
        inputBox.PlaceholderText = "Enter your key here..."
        inputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    end)
    
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            onSubmit()
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        keyUI:Destroy()
    end)
    
    -- Make draggable with mobile support
    if IS_MOBILE then
        -- Enhanced touch dragging for mobile
        local dragStart = nil
        local startPos = nil
        local isDragging = false
        
        local function updatePosition(input)
            if not isDragging then return end
            
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
            
            -- Keep window within screen bounds
            local viewportSize = workspace.CurrentCamera.ViewportSize
            local windowSize = mainFrame.AbsoluteSize
            
            newPos = UDim2.new(
                newPos.X.Scale,
                math.clamp(newPos.X.Offset, 0, viewportSize.X - windowSize.X),
                newPos.Y.Scale,
                math.clamp(newPos.Y.Offset, 0, viewportSize.Y - windowSize.Y)
            )
            
            mainFrame.Position = newPos
        end
        
        local function onTouchBegan(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragStart = input.Position
                startPos = mainFrame.Position
                isDragging = true
                
                -- Bring to front
                local gui = mainFrame:FindFirstAncestorWhichIsA("GuiObject")
                if gui then
                    gui.ZIndex = 100
                end
                
                -- Visual feedback
                mainFrame.BackgroundTransparency = 0.9
            end
        end
        
        local function onTouchEnded()
            isDragging = false
            mainFrame.BackgroundTransparency = 0.8
        end
        
        -- Connect events
        mainFrame.InputBegan:Connect(onTouchBegan)
        mainFrame.InputEnded:Connect(onTouchEnded)
        mainFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                updatePosition(input)
            end
        end)
        
        -- Handle touch outside
        UserInputService.TouchEnded:Connect(function(input, gameProcessed)
            if not gameProcessed and isDragging then
                onTouchEnded()
            end
        end)
    else
        -- Desktop dragging
        local dragging = false
        local dragStart = nil
        local startPos = nil
        
        mainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end
    
    -- Return a promise-like object
    local connection
    local promise = {}
    
    function promise:Wait()
        local completed = false
        local result = false
        
        connection = keyUI.Destroying:Connect(function()
            if not completed then
                completed = true
                result = self.validated
            end
        end)
        
        while not completed do
            wait()
        end
        
        return result
    end
    
    function promise:Destroy()
        if connection then
            connection:Disconnect()
        end
        keyUI:Destroy()
    end
    
    setmetatable(promise, {
        __index = function(_, k)
            if k == "Validated" then
                return self.validated
            end
        end
    })
    
    return promise
end

-- Validates a key and shows UI if needed
function ByteUI.KeySystem:validate()
    if self:hasValidKey() then
        return true
    end
    
    return self:showKeyUI()
end

-- Utility Functions
function ByteUI:LerpColor(color1, color2, alpha)
    local r = color1.R + (color2.R - color1.R) * alpha
    local g = color1.G + (color2.G - color1.G) * alpha
    local b = color1.B + (color2.B - color1.B) * alpha
    return Color3.new(r, g, b)
end

function ByteUI:CreateTween(object, property, goal, duration, easingStyle, easingDirection)
    if not TweenService then return end
    local tweenInfo = TweenInfo.new(duration or 0.3, easingStyle or Enum.EasingStyle.Sine, easingDirection or Enum.EasingDirection.InOut)
    local tween = TweenService:Create(object, tweenInfo, {[property] = goal})
    tween:Play()
    return tween
end

--[[
    Example Usage:
    
    -- Key System Example
    local keySystem = ByteUI.KeySystem.new({
        key = "YOUR_SECURE_KEY",
        fileName = "my_script",
        title = "My Script Authentication",
        subtitle = "Enter your key to continue",
        note = "Please contact the developer if you don't have a key"
    })
    
    if not keySystem:validate() then
        return -- Exit if key validation fails
    end
    
    -- Draggable Window Example
    local window = ByteUI.Window.new(screenGui, {
        Size = UDim2.new(0, 400, 0, 300),
        Position = UDim2.new(0.5, -200, 0.5, -150),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    })
    
    -- Make window draggable from title bar
    local titleBar = window:FindFirstChild("TitleBar")
    if titleBar then
        ByteUI:MakeDraggable(titleBar, window, {
            smoothness = 0.85,  -- Smoother movement (0-1)
            momentum = true,     -- Enable momentum effect
            bounds = {           -- Keep window within screen bounds
                X = {Min = 0, Max = 1},
                Y = {Min = 0, Max = 1}
            },
            onDragStart = function()
                print("Dragging started")
            end,
            onDragEnd = function()
                print("Dragging ended")
            end
        })
    end
]]

-- Base Component Class
local Component = {}
Component.__index = Component

function Component.new(className, parent, props)
    local self = setmetatable({}, Component)
    self.ClassName = className
    self.Instance = Instance.new(className)
    self.Instance.Parent = parent
    self.Children = {}
    self.EventHandlers = {}
    
    -- Apply properties
    if props then
        self:ApplyProps(props)
    end
    
    return self
end

function Component:ApplyProps(props)
    for prop, value in pairs(props) do
        if prop ~= "Children" and prop ~= "Events" then
            self:SetProperty(prop, value)
        end
    end
    
    -- Handle children
    if props.Children then
        for _, child in ipairs(props.Children) do
            child.Parent = self.Instance
        end
    end
    
    -- Handle events
    if props.Events then
        for event, handler in pairs(props.Events) do
            self:ConnectEvent(event, handler)
        end
    end
end

function Component:SetProperty(property, value)
    pcall(function()
        self.Instance[property] = value
    end)
end

function Component:ConnectEvent(eventName, handler)
    local event = self.Instance[eventName]
    if event then
        self.EventHandlers[eventName] = event:Connect(handler)
    end
end

function Component:AddChild(child)
    table.insert(self.Children, child)
    child.Parent = self.Instance
end

function Component:Destroy()
    for _, handler in pairs(self.EventHandlers) do
        handler:Disconnect()
    end
    for _, child in ipairs(self.Children) do
        child:Destroy()
    end
    self.Instance:Destroy()
end

-- Window Component
ByteUI.Window = setmetatable({}, {__index = Component})
ByteUI.Window.__index = ByteUI.Window

-- Add animation methods to the base component
function Component:Animate(animationType, options)
    options = options or {}
    local anim = ByteUI.Animations.new(self.Instance, animationType, {
        Duration = options.Duration,
        EasingStyle = options.EasingStyle,
        EasingDirection = options.EasingDirection
    })
    
    -- Apply initial state if specified
    if options.Instant then
        local preset = ByteUI.Animations.Presets[animationType]
        if preset then
            self.Instance[preset.Property] = preset.From
        end
    end
    
    return anim
end

-- Mobile-optimized window creation
function ByteUI.Window.new(parent, props)
    local screenInfo = getScreenInfo()
    
    -- Default mobile-friendly size
    local defaultSize = IS_MOBILE and 
        UDim2.new(0.9, 0, 0.8, 0) or 
        UDim2.new(0, 400, 0, 300)
    
    -- Merge with provided props
    props = props or {}
    props.Size = props.Size or defaultSize
    
    -- Adjust for mobile
    if IS_MOBILE then
        -- Ensure window isn't too large for mobile screens
        local maxWidth = screenInfo.Width * 0.95
        local maxHeight = screenInfo.Height * 0.9
        
        if props.Size.X.Scale == 0 and props.Size.X.Offset > maxWidth then
            props.Size = UDim2.new(0, maxWidth, props.Size.Y.Scale, props.Size.Y.Offset)
        end
        
        if props.Size.Y.Scale == 0 and props.Size.Y.Offset > maxHeight then
            props.Size = UDim2.new(props.Size.X.Scale, props.Size.X.Offset, 0, maxHeight)
        end
        
        -- Add mobile-specific padding
        props.Padding = props.Padding or UDim.new(0, 10)
    end
    local self = setmetatable(Component.new("Frame", parent, props), ByteUI.Window)
    
    -- Default properties
    self:SetProperty("BackgroundColor3", ByteUI.Theme.BackgroundColor)
    self:SetProperty("BorderSizePixel", 0)
    self:SetProperty("Size", UDim2.new(0, 400, 0, 300))
    self:SetProperty("Position", UDim2.new(0.5, -200, 0.5, -150))
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = ByteUI.Theme.CornerRadius
    corner.Parent = self.Instance
    
    -- Add gradient background
    local gradient = ByteUI:CreateGradient(self.Instance, {
        Rotation = 90
    })
    
    -- Add drop shadow with animation
    local shadow = Instance.new("ImageLabel")
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 100, 200)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.ZIndex = -1
    shadow.Parent = self.Instance
    
    -- Add hover effect
    local hoverTween = TweenService:Create(shadow, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        ImageColor3 = Color3.fromRGB(0, 150, 255)
    })
    
    self:ConnectEvent("MouseEnter", function()
        hoverTween:Play()
    end)
    
    self:ConnectEvent("MouseLeave", function()
        TweenService:Create(shadow, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            ImageColor3 = Color3.fromRGB(0, 100, 200)
        }):Play()
    end)
    
    -- Add title bar
    self.TitleBar = Component.new("Frame", self.Instance, {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = ByteUI:LerpColor(ByteUI.Theme.BackgroundColor, Color3.fromRGB(0, 0, 0), 0.1),
        BorderSizePixel = 0
    })
    
    local titleBarCorner = Instance.new("UICorner")
    titleBarCorner.CornerRadius = UDim.new(0, ByteUI.Theme.CornerRadius.Offset)
    titleBarCorner.Parent = self.TitleBar.Instance
    
    self.TitleLabel = Component.new("TextLabel", self.TitleBar.Instance, {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = ByteUI.Theme.TextColor,
        TextSize = ByteUI.Theme.TextSize,
        Font = ByteUI.Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = props and props.Title or "Window"
    })
    
    -- Add close button
    self.CloseButton = ByteUI.Button.new(self.TitleBar.Instance, {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0.5, -10),
        Text = "×",
        Style = "Danger",
        Events = {
            MouseButton1Click = function()
                self:Close()
            end
        }
    })
    
    -- Content area
    self.Content = Component.new("Frame", self.Instance, {
        Size = UDim2.new(1, -20, 1, -40),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundTransparency = 1
    })
    
    -- Make draggable and store the draggable controller
    self.draggable = self:MakeDraggable()
    
    -- Add a method to update window bounds if needed
    function self:UpdateBounds(minX, maxX, minY, maxY)
        if self.draggable and self.draggable.SetBounds then
            self.draggable.SetBounds({
                X = {Min = minX or 0, Max = maxX or 1},
                Y = {Min = minY or 0, Max = maxY or 1}
            })
        end
    end
    
    -- Add a method to enable/disable momentum
    function self:SetMomentum(enabled)
        if self.draggable and self.draggable.SetMomentum then
            self.draggable.SetMomentum(enabled)
        end
    end
    
    -- Add a method to set smoothness
    function self:SetSmoothness(value)
        if self.draggable and self.draggable.SetSmoothness then
            self.draggable.SetSmoothness(value)
        end
    end
    
    return self
end

function ByteUI.Window:MakeDraggable()
    -- Use the enhanced MakeDraggable function with smoothness and momentum
    local dragHandle = self.TitleBar.Instance
    local window = self.Instance
    
    -- Store the draggable controller to allow customization later
    self.draggable = ByteUI:MakeDraggable(dragHandle, window, {
        smoothness = 0.85,  -- Smooth movement (0-1, higher is smoother)
        momentum = true,    -- Enable momentum effect
        bounds = {          -- Keep window within screen bounds
            X = {Min = 0, Max = 1},
            Y = {Min = 0, Max = 1}
        },
        onDragStart = function()
            -- Optional: Add visual feedback when dragging starts
            ByteUI:CreateTween(window, "BackgroundTransparency", 0.05, 0.1)
        end,
        onDragEnd = function()
            -- Optional: Reset visual feedback when dragging ends
            ByteUI:CreateTween(window, "BackgroundTransparency", 0, 0.2)
        end
    })
    
    -- Add cursor feedback when hovering over the title bar
    dragHandle.MouseEnter:Connect(function()
        game:GetService("UserInputService").MouseIcon = "rbxasset://SystemCursors/SizeAll"
    end)
    
    dragHandle.MouseLeave:Connect(function()
        game:GetService("UserInputService").MouseIcon = ""
    end)
    
    return self.draggable  -- Return the draggable controller for further customization
end

function ByteUI.Window:Close(animate)
    if animate ~= false then
        -- Animate window closing
        local fadeOut = self:Animate("FadeOut", { Duration = 0.2 })
        local shrink = self:Animate("PopOut", { Duration = 0.25 })
        
        fadeOut.Completed:Connect(function()
            self:Destroy()
        end)
        
        fadeOut:Play()
        shrink:Play()
    else
        self:Destroy()
    end
end

-- Show window with animation
function ByteUI.Window:Show(animate)
    if animate ~= false then
        self.Instance.Visible = true
        self.Instance.BackgroundTransparency = 1
        self.Instance.Size = UDim2.new(0, 0, 0, 0)
        
        local fadeIn = self:Animate("FadeIn", { Duration = 0.2 })
        local grow = self:Animate("PopIn", { Duration = 0.25 })
        
        fadeIn:Play()
        grow:Play()
    else
        self.Instance.Visible = true
    end
end

-- Hide window with animation
function ByteUI.Window:Hide(animate)
    if animate ~= false then
        local fadeOut = self:Animate("FadeOut", { Duration = 0.2 })
        
        fadeOut.Completed:Connect(function()
            self.Instance.Visible = false
        end)
        
        fadeOut:Play()
    else
        self.Instance.Visible = false
    end
end

-- Button Component
ByteUI.Button = setmetatable({}, {__index = Component})
ByteUI.Button.__index = ByteUI.Button

function ByteUI.Button.new(parent, props)
    local self = setmetatable(Component.new("TextButton", parent, props), ByteUI.Button)
    
    -- Default properties
    self:SetProperty("BackgroundColor3", ByteUI.Theme.PrimaryColor)
    self:SetProperty("BorderSizePixel", 0)
    self:SetProperty("Size", UDim2.new(0, 100, 0, 30))
    self:SetProperty("TextColor3", ByteUI.Theme.TextColor)
    self:SetProperty("TextSize", ByteUI.Theme.TextSize)
    self:SetProperty("Font", ByteUI.Theme.Font)
    self:SetProperty("AutoButtonColor", false)
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = ByteUI.Theme.CornerRadius
    corner.Parent = self.Instance
    
    -- Apply style
    if props and props.Style then
        self:ApplyStyle(props.Style)
    end
    
    -- Hover effect
    self:ConnectEvent("MouseEnter", function()
        ByteUI:CreateTween(self.Instance, "BackgroundColor3", ByteUI:LerpColor(self.Instance.BackgroundColor3, Color3.fromRGB(255, 255, 255), 0.1), 0.2)
    end)
    
    self:ConnectEvent("MouseLeave", function()
        ByteUI:CreateTween(self.Instance, "BackgroundColor3", self.OriginalColor or ByteUI.Theme.PrimaryColor, 0.2)
    end)
    
    self:ConnectEvent("MouseButton1Down", function()
        ByteUI:CreateTween(self.Instance, "BackgroundColor3", ByteUI:LerpColor(self.Instance.BackgroundColor3, Color3.fromRGB(0, 0, 0), 0.2), 0.1)
    end)
    
    self:ConnectEvent("MouseButton1Up", function()
        ByteUI:CreateTween(self.Instance, "BackgroundColor3", ByteUI:LerpColor(self.Instance.BackgroundColor3, Color3.fromRGB(255, 255, 255), 0.1), 0.1)
    end)
    
    return self
end

function ByteUI.Button:ApplyStyle(style)
    if style == "Secondary" then
        self:SetProperty("BackgroundColor3", ByteUI.Theme.SecondaryColor)
    elseif style == "Danger" then
        self:SetProperty("BackgroundColor3", ByteUI.Theme.ErrorColor)
    elseif style == "Accent" then
        self:SetProperty("BackgroundColor3", ByteUI.Theme.AccentColor)
    end
    self.OriginalColor = self.Instance.BackgroundColor3
end

-- TextInput Component
ByteUI.TextInput = setmetatable({}, {__index = Component})
ByteUI.TextInput.__index = ByteUI.TextInput

function ByteUI.TextInput.new(parent, props)
    local self = setmetatable(Component.new("TextBox", parent, props), ByteUI.TextInput)
    
    -- Default properties
    self:SetProperty("BackgroundColor3", ByteUI:LerpColor(ByteUI.Theme.BackgroundColor, Color3.fromRGB(255, 255, 255), 0.1))
    self:SetProperty("BorderSizePixel", 0)
    self:SetProperty("Size", UDim2.new(0, 200, 0, 30))
    self:SetProperty("TextColor3", ByteUI.Theme.TextColor)
    self:SetProperty("TextSize", ByteUI.Theme.TextSize)
    self:SetProperty("Font", ByteUI.Theme.Font)
    self:SetProperty("ClearTextOnFocus", false)
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = ByteUI.Theme.CornerRadius
    corner.Parent = self.Instance
    
    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = ByteUI.Theme.Padding
    padding.PaddingRight = ByteUI.Theme.Padding
    padding.Parent = self.Instance
    
    -- Focus effects
    self:ConnectEvent("Focused", function()
        ByteUI:CreateTween(self.Instance, "BackgroundColor3", ByteUI:LerpColor(self.Instance.BackgroundColor3, Color3.fromRGB(255, 255, 255), 0.05), 0.2)
    end)
    
    self:ConnectEvent("FocusLost", function()
        ByteUI:CreateTween(self.Instance, "BackgroundColor3", ByteUI:LerpColor(ByteUI.Theme.BackgroundColor, Color3.fromRGB(255, 255, 255), 0.1), 0.2)
    end)
    
    return self
end

-- Label Component
ByteUI.Label = setmetatable({}, {__index = Component})
ByteUI.Label.__index = ByteUI.Label

function ByteUI.Label.new(parent, props)
    local self = setmetatable(Component.new("TextLabel", parent, props), ByteUI.Label)
    
    -- Default properties
    self:SetProperty("BackgroundTransparency", 1)
    self:SetProperty("TextColor3", ByteUI.Theme.TextColor)
    self:SetProperty("TextSize", ByteUI.Theme.TextSize)
    self:SetProperty("Font", ByteUI.Theme.Font)
    self:SetProperty("Size", UDim2.new(0, 200, 0, 20))
    
    return self
end

-- Container Component
ByteUI.Container = setmetatable({}, {__index = Component})
ByteUI.Container.__index = ByteUI.Container

function ByteUI.Container.new(parent, props)
    local self = setmetatable(Component.new("Frame", parent, props), ByteUI.Container)
    
    -- Default properties
    self:SetProperty("BackgroundTransparency", 1)
    self:SetProperty("Size", UDim2.new(1, 0, 1, 0))
    
    return self
end

-- ScrollContainer Component
ByteUI.ScrollContainer = setmetatable({}, {__index = Component})
ByteUI.ScrollContainer.__index = ByteUI.ScrollContainer

function ByteUI.ScrollContainer.new(parent, props)
    local self = setmetatable(Component.new("ScrollingFrame", parent, props), ByteUI.ScrollContainer)
    
    -- Default properties
    self:SetProperty("BackgroundTransparency", 1)
    self:SetProperty("Size", UDim2.new(1, 0, 1, 0))
    self:SetProperty("ScrollBarThickness", 4)
    self:SetProperty("ScrollBarImageColor3", ByteUI.Theme.SecondaryColor)
    
    return self
end

-- Theme customization
function ByteUI:SetTheme(newTheme)
    for key, value in pairs(newTheme) do
        if self.Theme[key] ~= nil then
            self.Theme[key] = value
        end
    end
end

function ByteUI:ResetTheme()
    self.Theme = table.clone(self.DefaultTheme)
end

--[[
    Creates a toggle switch
    @param parent Instance - Parent instance
    @param options table - Configuration options
        - Default: boolean - Initial state (default: false)
        - Callback: function - Function to call when toggled
        - Text: string - Optional label text
]]
function ByteUI:CreateToggle(parent, options)
    options = options or {}
    local toggle = setmetatable({
        Value = options.Default or false,
        Callback = options.Callback or function() end
    }, self.Toggle)
    
    -- Create container
    local container = Instance.new("Frame")
    container.Name = "Toggle"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 30)
    container.Parent = parent
    
    -- Add label if provided
    if options.Text then
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Text = options.Text
        label.Font = self.Theme.Font
        label.TextSize = self.Theme.TextSize
        label.TextColor3 = self.Theme.TextColor
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Parent = container
    end
    
    -- Create toggle background
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.BackgroundColor3 = self.Theme.SecondaryColor
    background.BorderSizePixel = 0
    background.Size = UDim2.new(0, 40, 0, 20)
    background.Position = UDim2.new(1, -40, 0.5, -10)
    background.AnchorPoint = Vector2.new(1, 0.5)
    background.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = background
    
    -- Create toggle button
    local button = Instance.new("Frame")
    button.Name = "Button"
    button.BackgroundColor3 = self.Theme.TextColor
    button.BorderSizePixel = 0
    button.Size = UDim2.new(0, 16, 0, 16)
    button.Position = options.Default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    button.AnchorPoint = Vector2.new(0, 0.5)
    button.Parent = background
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.5, 0)
    buttonCorner.Parent = button
    
    -- Click handler
    local function toggleState()
        toggle.Value = not toggle.Value
        
        -- Animate button
        self:CreateTween(button, "Position", 
            toggle.Value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), 
            0.2, 
            Enum.EasingStyle.Quad
        )
        
        -- Animate background color
        self:CreateTween(background, "BackgroundColor3", 
            toggle.Value and self.Theme.AccentColor or self.Theme.SecondaryColor,
            0.2,
            Enum.EasingStyle.Quad
        )
        
        -- Call callback
        toggle.Callback(toggle.Value)
    end
    
    -- Connect events
    background.MouseButton1Click:Connect(toggleState)
    button.MouseButton1Click:Connect(toggleState)
    
    -- Set initial state
    if options.Default then
        background.BackgroundColor3 = self.Theme.AccentColor
    end
    
    -- Add methods
    function toggle:SetValue(value)
        if value ~= self.Value then
            toggleState()
        end
    end
    
    function toggle:GetValue()
        return self.Value
    end
    
    return toggle
end

-- Mobile-specific utility functions
function ByteUI:IsMobile()
    return IS_MOBILE
end

function ByteUI:IsTablet()
    return IS_TABLET
end

function ByteUI:GetScreenInfo()
    return getScreenInfo()
end

-- Adjust UI scale for mobile
function ByteUI:AdjustForMobile(guiObject)
    if not IS_MOBILE then return end
    
    -- Increase touch target sizes
    if guiObject:IsA("TextButton") or guiObject:IsA("ImageButton") then
        local minSize = 44 -- Minimum touch target size recommended by Apple/Google
        
        if guiObject.Size.X.Offset > 0 and guiObject.Size.X.Offset < minSize then
            guiObject.Size = UDim2.new(guiObject.Size.X.Scale, minSize, 
                                     guiObject.Size.Y.Scale, guiObject.Size.Y.Offset)
        end
        
        if guiObject.Size.Y.Offset > 0 and guiObject.Size.Y.Offset < minSize then
            guiObject.Size = UDim2.new(guiObject.Size.X.Scale, guiObject.Size.X.Offset,
                                     guiObject.Size.Y.Scale, minSize)
        end
    end
    
    -- Increase text size for better readability
    if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") or guiObject:IsA("TextBox") then
        if guiObject.TextSize < 16 then
            guiObject.TextSize = 16
        end
        
        -- Add some padding
        if not guiObject:FindFirstChild("UIPadding") then
            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 8)
            padding.PaddingRight = UDim.new(0, 8)
            padding.PaddingTop = UDim.new(0, 4)
            padding.PaddingBottom = UDim.new(0, 4)
            padding.Parent = guiObject
        end
    end
    
    -- Make sliders easier to use
    if guiObject:IsA("Frame") and guiObject.Name == "Slider" then
        local track = guiObject:FindFirstChild("Track")
        local thumb = track and track:FindFirstChild("Thumb")
        
        if track and thumb then
            track.Size = UDim2.new(1, 0, 0, 8) -- Thicker track
            thumb.Size = UDim2.new(0, 24, 0, 24) -- Larger thumb
        end
    end
end

-- Virtual joystick for mobile controls
function ByteUI:CreateVirtualJoystick(parent)
    if not IS_MOBILE then return end
    
    local container = Instance.new("Frame")
    container.Name = "VirtualJoystick"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(0.4, 0, 0.4, 0)
    container.Position = UDim2.new(0.1, 0, 0.6, 0)
    container.Visible = false
    container.Parent = parent
    
    local outer = Instance.new("Frame")
    outer.Name = "Outer"
    outer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    outer.BackgroundTransparency = 0.8
    outer.Size = UDim2.new(0, 100, 0, 100)
    outer.Position = UDim2.new(0.5, -50, 0.5, -50)
    outer.BorderSizePixel = 0
    outer.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = outer
    
    local inner = Instance.new("Frame")
    inner.Name = "Inner"
    inner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    inner.BackgroundTransparency = 0.5
    inner.Size = UDim2.new(0, 50, 0, 50)
    inner.Position = UDim2.new(0.5, -25, 0.5, -25)
    inner.BorderSizePixel = 0
    inner.Parent = outer
    
    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(0.5, 0)
    innerCorner.Parent = inner
    
    local isActive = false
    local startPos = nil
    local connection = nil
    
    -- Input handling
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            isActive = true
            startPos = input.Position
            container.Position = UDim2.new(0, startPos.X - container.AbsoluteSize.X/2, 
                                          0, startPos.Y - container.AbsoluteSize.Y/2)
            container.Visible = true
            
            -- Disable other touches while active
            connection = UserInputService.TouchEnded:Connect(function()
                isActive = false
                container.Visible = false
                if connection then
                    connection:Disconnect()
                    connection = nil
                end
            end)
        end
    end
    
    UserInputService.TouchStarted:Connect(onInputBegan)
    
    -- Movement handling
    UserInputService.TouchMoved:Connect(function(input)
        if isActive and startPos then
            local delta = input.Position - startPos
            local magnitude = delta.Magnitude
            local maxMagnitude = outer.AbsoluteSize.X / 2
            
            if magnitude > maxMagnitude then
                delta = delta.Unit * maxMagnitude
            end
            
            inner.Position = UDim2.new(0.5, delta.X - 25, 0.5, delta.Y - 25)
            
            -- Normalize direction
            local direction = delta / math.max(1, magnitude)
            
            -- Fire movement event
            self.JoystickMoved:Fire({
                Direction = Vector2.new(direction.X, direction.Y),
                Magnitude = math.min(1, magnitude / maxMagnitude)
            })
        end
    end)
    
    -- Cleanup
    container.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if connection then
                connection:Disconnect()
            end
        end
    end)
    
    return container
end

-- Initialize mobile-specific features
if IS_MOBILE then
    -- Create event for joystick movement
    ByteUI.JoystickMoved = Instance.new("BindableEvent")
    
    -- Add mobile UI scale factor
    ByteUI.MOBILE_SCALE = math.clamp(getScreenInfo().Scale, 0.8, 1.5)
    
    -- Disable keyboard on mobile
    if UserInputService.TouchEnabled then
        ContextActionService:UnbindCoreAction("MobileBackButton")
        ContextActionService:BindCoreAction("MobileBackButton", function()
            -- Handle back button press
        end, false, Enum.KeyCode.ButtonB)
    end
    
    -- Add viewport size listener for orientation changes
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        local screenInfo = getScreenInfo()
        ByteUI.MOBILE_SCALE = math.clamp(screenInfo.Scale, 0.8, 1.5)
        
        -- Fire event for orientation change
        ByteUI.ScreenOrientationChanged:Fire({
            IsPortrait = screenInfo.IsPortrait,
            IsLandscape = screenInfo.IsLandscape,
            Width = screenInfo.Width,
            Height = screenInfo.Height
        })
    end)
    
    -- Create orientation change event
    ByteUI.ScreenOrientationChanged = Instance.new("BindableEvent")
end

return ByteUI
