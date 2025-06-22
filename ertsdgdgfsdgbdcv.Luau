-- NexusUI Library - Advanced Roblox UI Framework
-- Version: 2.0.0
-- Features: Smooth animations, multiple themes, responsive design, advanced components

local NexusUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Configuration
local Config = {
    AnimationSpeed = 0.3,
    SpringDamping = 0.8,
    SpringFrequency = 4,
    BlurIntensity = 25,
    DropShadowSize = 8,
    RippleSize = 100,
    NotificationDuration = 4
}

-- Themes
local Themes = {
    Dark = {
        Background = Color3.fromRGB(18, 18, 18),
        Surface = Color3.fromRGB(28, 28, 30),
        SurfaceVariant = Color3.fromRGB(35, 35, 37),
        Primary = Color3.fromRGB(0, 162, 255),
        PrimaryVariant = Color3.fromRGB(0, 122, 204),
        Secondary = Color3.fromRGB(142, 69, 173),
        Success = Color3.fromRGB(52, 199, 89),
        Warning = Color3.fromRGB(255, 159, 10),
        Error = Color3.fromRGB(255, 69, 58),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(174, 174, 178),
        TextDisabled = Color3.fromRGB(99, 99, 102),
        Border = Color3.fromRGB(48, 48, 50),
        Accent = Color3.fromRGB(94, 92, 230)
    },
    Light = {
        Background = Color3.fromRGB(248, 249, 250),
        Surface = Color3.fromRGB(255, 255, 255),
        SurfaceVariant = Color3.fromRGB(242, 242, 247),
        Primary = Color3.fromRGB(0, 122, 255),
        PrimaryVariant = Color3.fromRGB(0, 92, 191),
        Secondary = Color3.fromRGB(175, 82, 222),
        Success = Color3.fromRGB(52, 199, 89),
        Warning = Color3.fromRGB(255, 149, 0),
        Error = Color3.fromRGB(255, 59, 48),
        TextPrimary = Color3.fromRGB(0, 0, 0),
        TextSecondary = Color3.fromRGB(99, 99, 102),
        TextDisabled = Color3.fromRGB(174, 174, 178),
        Border = Color3.fromRGB(209, 209, 214),
        Accent = Color3.fromRGB(88, 86, 214)
    },
    Neon = {
        Background = Color3.fromRGB(10, 10, 15),
        Surface = Color3.fromRGB(15, 15, 25),
        SurfaceVariant = Color3.fromRGB(25, 25, 35),
        Primary = Color3.fromRGB(57, 255, 20),
        PrimaryVariant = Color3.fromRGB(45, 200, 15),
        Secondary = Color3.fromRGB(255, 20, 147),
        Success = Color3.fromRGB(0, 255, 127),
        Warning = Color3.fromRGB(255, 215, 0),
        Error = Color3.fromRGB(255, 20, 60),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 255),
        TextDisabled = Color3.fromRGB(100, 100, 150),
        Border = Color3.fromRGB(57, 255, 20),
        Accent = Color3.fromRGB(138, 43, 226)
    }
}

local CurrentTheme = Themes.Dark

-- Utility Functions
local function CreateTweenInfo(duration, style, direction, repeatCount, reverses, delayTime)
    return TweenInfo.new(
        duration or Config.AnimationSpeed,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out,
        repeatCount or 0,
        reverses or false,
        delayTime or 0
    )
end

local function CreateSpringTween(obj, properties, duration)
    local tween = TweenService:Create(obj, CreateTweenInfo(duration, Enum.EasingStyle.Back), properties)
    tween:Play()
    return tween
end

local function CreateRippleEffect(parent, position)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, position.X, 0, position.Y)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = CurrentTheme.Primary
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, Config.RippleSize)
    corner.Parent = ripple
    
    local expandTween = TweenService:Create(ripple, CreateTweenInfo(0.4), {
        Size = UDim2.new(0, Config.RippleSize, 0, Config.RippleSize),
        BackgroundTransparency = 1
    })
    
    expandTween:Play()
    expandTween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

local function CreateDropShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "DropShadow"
    shadow.Size = UDim2.new(1, Config.DropShadowSize * 2, 1, Config.DropShadowSize * 2)
    shadow.Position = UDim2.new(0, -Config.DropShadowSize, 0, -Config.DropShadowSize)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = parent
    shadow.ZIndex = parent.ZIndex - 1
    return shadow
end

local function AddHoverEffect(element, hoverColor, normalColor)
    local isHovering = false
    
    element.MouseEnter:Connect(function()
        isHovering = true
        CreateSpringTween(element, {BackgroundColor3 = hoverColor}, 0.2)
    end)
    
    element.MouseLeave:Connect(function()
        isHovering = false
        CreateSpringTween(element, {BackgroundColor3 = normalColor}, 0.2)
    end)
end

-- Mobile Support Detection
function NexusUI:IsMobile()
    if not UserInputService then return false end
    return UserInputService.TouchEnabled and (game:GetService("UserInputService").KeyboardEnabled == false)
end

-- Adjust UI for mobile
function NexusUI:AdjustForMobile(element, scaleFactor)
    scaleFactor = scaleFactor or 1.2
    if self:IsMobile() then
        local size = element.Size
        if size.X.Scale > 0 then
            element.Size = UDim2.new(size.X.Scale * scaleFactor, size.X.Offset, size.Y.Scale * scaleFactor, size.Y.Offset)
        else
            element.Size = UDim2.new(size.X.Scale, size.X.Offset * scaleFactor, size.Y.Scale, size.Y.Offset * scaleFactor)
        end
    end
end

-- Key System for access control
local KeySystem = {}
KeySystem.__index = KeySystem

function KeySystem.new(config)
    local self = setmetatable({}, KeySystem)
    self.Key = config.key or ""
    self.FileName = config.fileName or "byteui_key"
    self.Title = config.title or "ByteUI Key System"
    self.Subtitle = config.subtitle or "Enter your access key"
    self.Note = config.note or ""
    self.Validated = false
    return self
end

function KeySystem:validate()
    -- In a real implementation, this would check against a saved key or server
    -- For now, we'll just show the UI if no key is set
    if self.Key == "" then
        return true
    end
    
    -- Create UI for key input
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ByteUI_KeySystem"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local window = NexusUI:CreateWindow({
        Title = self.Title,
        Size = UDim2.new(0, 400, 0, 300),
        Position = UDim2.new(0.5, -200, 0.5, -150)
    })
    
    local container = window.Content
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = self.Subtitle
    titleLabel.TextColor3 = CurrentTheme.TextPrimary
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = container
    
    local noteLabel = Instance.new("TextLabel")
    noteLabel.Name = "Note"
    noteLabel.Size = UDim2.new(1, -20, 0, 40)
    noteLabel.Position = UDim2.new(0, 10, 0, 50)
    noteLabel.BackgroundTransparency = 1
    noteLabel.Text = self.Note
    noteLabel.TextColor3 = CurrentTheme.TextSecondary
    noteLabel.TextSize = 14
    noteLabel.Font = Enum.Font.SourceSans
    noteLabel.TextXAlignment = Enum.TextXAlignment.Left
    noteLabel.TextYAlignment = Enum.TextYAlignment.Top
    noteLabel.TextWrapped = true
    noteLabel.Parent = container
    
    local keyInput = Instance.new("TextBox")
    keyInput.Name = "KeyInput"
    keyInput.Size = UDim2.new(1, -20, 0, 40)
    keyInput.Position = UDim2.new(0, 10, 0, 100)
    keyInput.BackgroundColor3 = CurrentTheme.Surface
    keyInput.BorderSizePixel = 0
    keyInput.Text = ""
    keyInput.PlaceholderText = "Enter key..."
    keyInput.ClearTextOnFocus = false
    keyInput.TextColor3 = CurrentTheme.TextPrimary
    keyInput.TextSize = 14
    keyInput.Font = Enum.Font.SourceSans
    keyInput.Parent = container
    
    local submitButton = Instance.new("TextButton")
    submitButton.Name = "SubmitButton"
    submitButton.Size = UDim2.new(0, 150, 0, 35)
    submitButton.Position = UDim2.new(0.5, -75, 0, 150)
    submitButton.BackgroundColor3 = CurrentTheme.Primary
    submitButton.BorderSizePixel = 0
    submitButton.Text = "Submit"
    submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitButton.TextSize = 14
    submitButton.Font = Enum.Font.SourceSansSemibold
    submitButton.Parent = container
    
    local isHovering = false
    
    submitButton.MouseEnter:Connect(function()
        isHovering = true
        CreateSpringTween(submitButton, {BackgroundColor3 = CurrentTheme.PrimaryVariant}, 0.2)
    end)
    
    submitButton.MouseLeave:Connect(function()
        isHovering = false
        CreateSpringTween(submitButton, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
    end)
    
    submitButton.MouseButton1Click:Connect(function()
        local enteredKey = keyInput.Text
        if enteredKey == self.Key then
            self.Validated = true
            screenGui:Destroy()
            NexusUI:CreateNotification({
                Title = "Success!",
                Description = "Key validated successfully",
                Duration = 3,
                Type = "success"
            })
        else
            NexusUI:CreateNotification({
                Title = "Error",
                Description = "Invalid key. Please try again.",
                Duration = 3,
                Type = "error"
            })
        end
    end)
    
    return false -- Return false initially until validated
end

-- Add to NexusUI
NexusUI.KeySystem = KeySystem

-- Enhanced Animations
function NexusUI:CreateRippleEffect(parent, position)
    if not TweenService then return end
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, position.X, 0, position.Y)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = CurrentTheme.Primary
    ripple.BackgroundTransparency = 0.7
    ripple.BorderSizePixel = 0
    ripple.Parent = parent
    ripple.ZIndex = parent.ZIndex + 1
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    local sizeTween = TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 100, 0, 100),
        BackgroundTransparency = 1
    })
    sizeTween:Play()
    sizeTween.Completed:Connect(function()
        ripple:Destroy()
    end)
    return ripple
end

function NexusUI:CreateHoverEffect(element, normalColor, hoverColor)
    if not TweenService then return end
    local isHovering = false
    
    element.MouseEnter:Connect(function()
        isHovering = true
        self:CreateTween(element, "BackgroundColor3", hoverColor, 0.2)
    end)
    
    element.MouseLeave:Connect(function()
        isHovering = false
        self:CreateTween(element, "BackgroundColor3", normalColor, 0.2)
    end)
end

-- Add fade in/out animations
function NexusUI:FadeIn(element, duration)
    if not TweenService then return end
    duration = duration or 0.5
    element.BackgroundTransparency = 1
    local tween = TweenService:Create(element, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {BackgroundTransparency = 0})
    tween:Play()
    return tween
end

function NexusUI:FadeOut(element, duration)
    if not TweenService then return end
    duration = duration or 0.5
    local tween = TweenService:Create(element, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    tween:Play()
    return tween
end

-- Enhanced Notification with animations
function NexusUI:CreateNotification(config)
    config = config or {}
    config.Title = config.Title or "Notification"
    config.Description = config.Description or ""
    config.Duration = config.Duration or 3
    config.Type = config.Type or "info" -- info, success, warning, error
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NexusNotification"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 80)
    frame.Position = UDim2.new(1, 320, 0, 20)
    frame.BackgroundColor3 = CurrentTheme.Surface
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local border = Instance.new("UIStroke")
    border.Thickness = 1
    border.Transparency = 0.3
    border.Color = CurrentTheme.Secondary
    border.Parent = frame
    
    -- Set color based on type
    local typeColors = {
        info = CurrentTheme.Primary,
        success = Color3.fromRGB(52, 199, 89),
        warning = Color3.fromRGB(255, 159, 10),
        error = CurrentTheme.Error
    }
    border.Color = typeColors[config.Type] or CurrentTheme.Primary
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 20)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = config.Title
    title.TextColor3 = CurrentTheme.TextPrimary
    title.TextSize = 16
    title.Font = Enum.Font.SourceSansBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    local content = Instance.new("TextLabel")
    content.Size = UDim2.new(1, -20, 0, 40)
    content.Position = UDim2.new(0, 10, 0, 30)
    content.BackgroundTransparency = 1
    content.Text = config.Description
    content.TextColor3 = CurrentTheme.TextSecondary
    content.TextSize = 14
    content.Font = Enum.Font.SourceSans
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.TextWrapped = true
    content.Parent = frame
    
    -- Animate in
    self:CreateTween(frame, "Position", UDim2.new(1, -320, 0, 20), 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    
    -- Auto close
    spawn(function()
        wait(config.Duration)
        local tween = self:CreateTween(frame, "Position", UDim2.new(1, 320, 0, 20), 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
        tween.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)
    
    return frame
end

-- Main Library Functions
function NexusUI:CreateWindow(config)
    local window = {}
    
    -- Validate config
    config = config or {}
    config.Title = config.Title or "NexusUI Window"
    config.Size = config.Size or UDim2.new(0, 580, 0, 460)
    config.Theme = config.Theme or "Dark"
    config.CloseCallback = config.CloseCallback or function() end
    config.MinimizeCallback = config.MinimizeCallback or function() end
    config.Draggable = config.Draggable ~= false
    config.Resizable = config.Resizable or false
    
    -- Set theme
    CurrentTheme = Themes[config.Theme] or Themes.Dark
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NexusUI_" .. config.Title
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    
    -- Parent to appropriate service
    if gethui then
        screenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = CoreGui
    else
        screenGui.Parent = CoreGui
    end
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = config.Size
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = CurrentTheme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- Add corner radius
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    -- Add drop shadow
    CreateDropShadow(mainFrame)
    
    -- Add border
    local border = Instance.new("UIStroke")
    border.Color = CurrentTheme.Border
    border.Thickness = 1
    border.Transparency = 0.5
    border.Parent = mainFrame
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = CurrentTheme.Surface
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleBarCorner = Instance.new("UICorner")
    titleBarCorner.CornerRadius = UDim.new(0, 12)
    titleBarCorner.Parent = titleBar
    
    -- Title bar bottom border
    local titleBorder = Instance.new("Frame")
    titleBorder.Name = "Border"
    titleBorder.Size = UDim2.new(1, 0, 0, 1)
    titleBorder.Position = UDim2.new(0, 0, 1, -1)
    titleBorder.BackgroundColor3 = CurrentTheme.Border
    titleBorder.BorderSizePixel = 0
    titleBorder.Parent = titleBar
    
    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -120, 1, 0)
    titleText.Position = UDim2.new(0, 20, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = config.Title
    titleText.TextColor3 = CurrentTheme.TextPrimary
    titleText.TextSize = 16
    titleText.Font = Enum.Font.SourceSansBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Control buttons container
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "Controls"
    controlsFrame.Size = UDim2.new(0, 90, 1, 0)
    controlsFrame.Position = UDim2.new(1, -90, 0, 0)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = titleBar
    
    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    controlsLayout.Padding = UDim.new(0, 5)
    controlsLayout.Parent = controlsFrame
    
    -- Minimize button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeButton"
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.BackgroundColor3 = CurrentTheme.SurfaceVariant
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = CurrentTheme.TextPrimary
    minimizeBtn.TextSize = 14
    minimizeBtn.Font = Enum.Font.SourceSansBold
    minimizeBtn.Parent = controlsFrame
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = minimizeBtn
    
    AddHoverEffect(minimizeBtn, CurrentTheme.Warning, CurrentTheme.SurfaceVariant)
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.BackgroundColor3 = CurrentTheme.SurfaceVariant
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = CurrentTheme.TextPrimary
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = controlsFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    
    AddHoverEffect(closeBtn, CurrentTheme.Error, CurrentTheme.SurfaceVariant)
    
    -- Content frame
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -40, 1, -70)
    contentFrame.Position = UDim2.new(0, 20, 0, 60)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 4
    contentFrame.ScrollBarImageColor3 = CurrentTheme.Primary
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.Parent = mainFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = contentFrame
    
    -- Auto-resize canvas
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Dragging functionality
    if config.Draggable then
        local dragging = false
        local dragStart = nil
        local startPos = nil
        
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
            end
        end)
        
        titleBar.InputChanged:Connect(function(input)
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
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end
    
    -- Button events
    closeBtn.MouseButton1Click:Connect(function()
        CreateRippleEffect(closeBtn, Vector2.new(15, 15))
        CreateSpringTween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        wait(0.3)
        screenGui:Destroy()
        config.CloseCallback()
    end)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        CreateRippleEffect(minimizeBtn, Vector2.new(15, 15))
        local isMinimized = mainFrame.Size.Y.Offset == 50
        
        if isMinimized then
            CreateSpringTween(mainFrame, {Size = config.Size}, 0.3)
        else
            CreateSpringTween(mainFrame, {Size = UDim2.new(config.Size.X.Scale, config.Size.X.Offset, 0, 50)}, 0.3)
        end
        
        config.MinimizeCallback(not isMinimized)
    end)
    
    -- Window methods
    window.Frame = mainFrame
    window.Content = contentFrame
    
    function window:CreateTab(name)
        local tab = {}
        
        -- Tab button (if tabs are needed, extend this section)
        local tabContent = Instance.new("Frame")
        tabContent.Name = name .. "Tab"
        tabContent.Size = UDim2.new(1, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Parent = contentFrame
        
        local tabLayout = Instance.new("UIListLayout")
        tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabLayout.Padding = UDim.new(0, 8)
        tabLayout.Parent = tabContent
        
        -- Auto-resize tab
        tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.Size = UDim2.new(1, 0, 0, tabLayout.AbsoluteContentSize.Y)
        end)
        
        tab.Frame = tabContent
        
        -- Tab methods
        function tab:CreateSection(name)
            local section = {}
            
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = name .. "Section"
            sectionFrame.Size = UDim2.new(1, 0, 0, 0)
            sectionFrame.BackgroundColor3 = CurrentTheme.Surface
            sectionFrame.BorderSizePixel = 0
            sectionFrame.Parent = tabContent
            
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 8)
            sectionCorner.Parent = sectionFrame
            
            local sectionBorder = Instance.new("UIStroke")
            sectionBorder.Color = CurrentTheme.Border
            sectionBorder.Thickness = 1
            sectionBorder.Transparency = 0.7
            sectionBorder.Parent = sectionFrame
            
            -- Section header
            local sectionHeader = Instance.new("TextLabel")
            sectionHeader.Name = "Header"
            sectionHeader.Size = UDim2.new(1, -20, 0, 35)
            sectionHeader.Position = UDim2.new(0, 10, 0, 5)
            sectionHeader.BackgroundTransparency = 1
            sectionHeader.Text = name
            sectionHeader.TextColor3 = CurrentTheme.TextPrimary
            sectionHeader.TextSize = 14
            sectionHeader.Font = Enum.Font.SourceSansSemibold
            sectionHeader.TextXAlignment = Enum.TextXAlignment.Left
            sectionHeader.Parent = sectionFrame
            
            -- Section content
            local sectionContent = Instance.new("Frame")
            sectionContent.Name = "Content"
            sectionContent.Size = UDim2.new(1, -20, 0, 0)
            sectionContent.Position = UDim2.new(0, 10, 0, 40)
            sectionContent.BackgroundTransparency = 1
            sectionContent.Parent = sectionFrame
            
            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Padding = UDim.new(0, 6)
            sectionLayout.Parent = sectionContent
            
            -- Auto-resize section
            sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectionContent.Size = UDim2.new(1, -20, 0, sectionLayout.AbsoluteContentSize.Y)
                sectionFrame.Size = UDim2.new(1, 0, 0, sectionLayout.AbsoluteContentSize.Y + 50)
            end)
            
            section.Frame = sectionFrame
            section.Content = sectionContent
            
            -- Section element creation methods
            function section:CreateButton(config)
                config = config or {}
                config.Text = config.Text or "Button"
                config.Callback = config.Callback or function() end
                
                local button = Instance.new("TextButton")
                button.Name = config.Text .. "Button"
                button.Size = UDim2.new(1, 0, 0, 36)
                button.BackgroundColor3 = CurrentTheme.Primary
                button.BorderSizePixel = 0
                button.Text = config.Text
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 14
                button.Font = Enum.Font.SourceSansSemibold
                button.Parent = sectionContent
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 6)
                buttonCorner.Parent = button
                
                AddHoverEffect(button, CurrentTheme.PrimaryVariant, CurrentTheme.Primary)
                
                button.MouseButton1Click:Connect(function()
                    CreateRippleEffect(button, Vector2.new(button.AbsoluteSize.X/2, button.AbsoluteSize.Y/2))
                    config.Callback()
                end)
                
                return button
            end
            
            function section:CreateToggle(config)
                config = config or {}
                config.Text = config.Text or "Toggle"
                config.Default = config.Default or false
                config.Callback = config.Callback or function() end
                
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Name = config.Text .. "Toggle"
                toggleFrame.Size = UDim2.new(1, 0, 0, 36)
                toggleFrame.BackgroundColor3 = CurrentTheme.SurfaceVariant
                toggleFrame.BorderSizePixel = 0
                toggleFrame.Parent = sectionContent
                
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(0, 6)
                toggleCorner.Parent = toggleFrame
                
                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Name = "Label"
                toggleLabel.Size = UDim2.new(1, -50, 1, 0)
                toggleLabel.Position = UDim2.new(0, 12, 0, 0)
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Text = config.Text
                toggleLabel.TextColor3 = CurrentTheme.TextPrimary
                toggleLabel.TextSize = 14
                toggleLabel.Font = Enum.Font.SourceSans
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                toggleLabel.Parent = toggleFrame
                
                local toggleButton = Instance.new("TextButton")
                toggleButton.Name = "Button"
                toggleButton.Size = UDim2.new(0, 32, 0, 18)
                toggleButton.Position = UDim2.new(1, -40, 0.5, -9)
                toggleButton.BackgroundColor3 = config.Default and CurrentTheme.Primary or CurrentTheme.Border
                toggleButton.BorderSizePixel = 0
                toggleButton.Text = ""
                toggleButton.Parent = toggleFrame
                
                local toggleButtonCorner = Instance.new("UICorner")
                toggleButtonCorner.CornerRadius = UDim.new(0, 9)
                toggleButtonCorner.Parent = toggleButton
                
                local toggleIndicator = Instance.new("Frame")
                toggleIndicator.Name = "Indicator"
                toggleIndicator.Size = UDim2.new(0, 14, 0, 14)
                toggleIndicator.Position = config.Default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleIndicator.BorderSizePixel = 0
                toggleIndicator.Parent = toggleButton
                
                local indicatorCorner = Instance.new("UICorner")
                indicatorCorner.CornerRadius = UDim.new(0, 7)
                indicatorCorner.Parent = toggleIndicator
                
                local isToggled = config.Default
                
                toggleButton.MouseButton1Click:Connect(function()
                    isToggled = not isToggled
                    
                    CreateSpringTween(toggleButton, {
                        BackgroundColor3 = isToggled and CurrentTheme.Primary or CurrentTheme.Border
                    }, 0.2)
                    
                    CreateSpringTween(toggleIndicator, {
                        Position = isToggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                    }, 0.2)
                    
                    config.Callback(isToggled)
                end)
                
                return toggleFrame
            end
            
            function section:CreateSlider(config)
                config = config or {}
                config.Text = config.Text or "Slider"
                config.Min = config.Min or 0
                config.Max = config.Max or 100
                config.Default = config.Default or 50
                config.Callback = config.Callback or function() end
                
                local sliderFrame = Instance.new("Frame")
                sliderFrame.Name = config.Text .. "Slider"
                sliderFrame.Size = UDim2.new(1, 0, 0, 50)
                sliderFrame.BackgroundColor3 = CurrentTheme.SurfaceVariant
                sliderFrame.BorderSizePixel = 0
                sliderFrame.Parent = sectionContent
                
                local sliderCorner = Instance.new("UICorner")
                sliderCorner.CornerRadius = UDim.new(0, 6)
                sliderCorner.Parent = sliderFrame
                
                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Name = "Label"
                sliderLabel.Size = UDim2.new(1, -20, 0, 20)
                sliderLabel.Position = UDim2.new(0, 10, 0, 5)
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.Text = config.Text
                sliderLabel.TextColor3 = CurrentTheme.TextPrimary
                sliderLabel.TextSize = 14
                sliderLabel.Font = Enum.Font.SourceSans
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                sliderLabel.Parent = sliderFrame
                
                local valueLabel = Instance.new("TextLabel")
                valueLabel.Name = "Value"
                valueLabel.Size = UDim2.new(0, 50, 0, 20)
                valueLabel.Position = UDim2.new(1, -60, 0, 5)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = tostring(config.Default)
                valueLabel.TextColor3 = CurrentTheme.TextSecondary
                valueLabel.TextSize = 14
                valueLabel.Font = Enum.Font.SourceSansBold
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Parent = sliderFrame
                
                local sliderTrack = Instance.new("Frame")
                sliderTrack.Name = "Track"
                sliderTrack.Size = UDim2.new(1, -20, 0, 4)
                sliderTrack.Position = UDim2.new(0, 10, 1, -15)
                sliderTrack.BackgroundColor3 = CurrentTheme.Border
                sliderTrack.BorderSizePixel = 0
                sliderTrack.Parent = sliderFrame
                
                local trackCorner = Instance.new("UICorner")
                trackCorner.CornerRadius = UDim.new(0, 2)
                trackCorner.Parent = sliderTrack
                
                local sliderFill = Instance.new("Frame")
                sliderFill.Name = "Fill"
                sliderFill.Size = UDim2.new((config.Default - config.Min) / (config.Max - config.Min), 0, 1, 0)
                sliderFill.Position = UDim2.new(0, 0, 0, 0)
                sliderFill.BackgroundColor3 = CurrentTheme.Primary
                sliderFill.BorderSizePixel = 0
                sliderFill.Parent = sliderTrack
                
                local fillCorner = Instance.new("UICorner")
                fillCorner.CornerRadius = UDim.new(0, 2)
                fillCorner.Parent = sliderFill
                
                local sliderHandle = Instance.new("Frame")
                sliderHandle.Name = "Handle"
                sliderHandle.Size = UDim2.new(0, 16, 0, 16)
                sliderHandle.Position = UDim2.new((config.Default - config.Min) / (config.Max - config.Min), -8, 0.5, -8)
                sliderHandle.BackgroundColor3 = CurrentTheme.Primary
                sliderHandle.BorderSizePixel = 0
                sliderHandle.Parent = sliderTrack
                
                local handleCorner = Instance.new("UICorner")
                handleCorner.CornerRadius = UDim.new(0, 8)
                handleCorner.Parent = sliderHandle
                
                local currentValue = config.Default
                local dragging = false
                
                local function updateSlider(value)
                    value = math.clamp(value, config.Min, config.Max)
                    currentValue = value
                    valueLabel.Text = tostring(math.floor(value))
                    
                    local percentage = (value - config.Min) / (config.Max - config.Min)
                    CreateSpringTween(sliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.1)
                    CreateSpringTween(sliderHandle, {Position = UDim2.new(percentage, -8, 0.5, -8)}, 0.1)
                    
                    config.Callback(value)
                end
                
                sliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        local relativeX = input.Position.X - sliderTrack.AbsolutePosition.X
                        local percentage = math.clamp(relativeX / sliderTrack.AbsoluteSize.X, 0, 1)
                        local value = config.Min + (config.Max - config.Min) * percentage
                        updateSlider(value)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local relativeX = input.Position.X - sliderTrack.AbsolutePosition.X
                        local percentage = math.clamp(relativeX / sliderTrack.AbsoluteSize.X, 0, 1)
                        local value = config.Min + (config.Max - config.Min) * percentage
                        updateSlider(value)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                return sliderFrame
            end
            
            function section:CreateDropdown(config)
                config = config or {}
                config.Text = config.Text or "Dropdown"
                config.Options = config.Options or {"Option 1", "Option 2", "Option 3"}
                config.Default = config.Default or config.Options[1]
                config.Callback = config.Callback or function() end
                
                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Name = config.Text .. "Dropdown"
                dropdownFrame.Size = UDim2.new(1, 0, 0, 36)
                dropdownFrame.BackgroundColor3 = CurrentTheme.SurfaceVariant
                dropdownFrame.BorderSizePixel = 0
                dropdownFrame.Parent = sectionContent
                
                local dropdownCorner = Instance.new("UICorner")
                dropdownCorner.CornerRadius = UDim.new(0, 6)
                dropdownCorner.Parent = dropdownFrame
                
                local dropdownLabel = Instance.new("TextLabel")
                dropdownLabel.Name = "Label"
                dropdownLabel.Size = UDim2.new(0.4, 0, 1, 0)
                dropdownLabel.Position = UDim2.new(0, 12, 0, 0)
                dropdownLabel.BackgroundTransparency = 1
                dropdownLabel.Text = config.Text
                dropdownLabel.TextColor3 = CurrentTheme.TextPrimary
                dropdownLabel.TextSize = 14
                dropdownLabel.Font = Enum.Font.SourceSans
                dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                dropdownLabel.Parent = dropdownFrame
                
                local dropdownButton = Instance.new("TextButton")
                dropdownButton.Name = "Button"
                dropdownButton.Size = UDim2.new(0.55, -12, 0, 28)
                dropdownButton.Position = UDim2.new(0.45, 0, 0, 4)
                dropdownButton.BackgroundColor3 = CurrentTheme.Surface
                dropdownButton.BorderSizePixel = 0
                dropdownButton.Text = config.Default .. " ▼"
                dropdownButton.TextColor3 = CurrentTheme.TextPrimary
                dropdownButton.TextSize = 13
                dropdownButton.Font = Enum.Font.SourceSans
                dropdownButton.Parent = dropdownFrame
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 4)
                buttonCorner.Parent = dropdownButton
                
                local buttonBorder = Instance.new("UIStroke")
                buttonBorder.Color = CurrentTheme.Border
                buttonBorder.Thickness = 1
                buttonBorder.Transparency = 0.5
                buttonBorder.Parent = dropdownButton
                
                local optionsFrame = Instance.new("Frame")
                optionsFrame.Name = "Options"
                optionsFrame.Size = UDim2.new(0.55, -12, 0, #config.Options * 32)
                optionsFrame.Position = UDim2.new(0.45, 0, 1, 4)
                optionsFrame.BackgroundColor3 = CurrentTheme.Surface
                optionsFrame.BorderSizePixel = 0
                optionsFrame.Visible = false
                optionsFrame.ZIndex = 10
                optionsFrame.Parent = dropdownFrame
                
                local optionsCorner = Instance.new("UICorner")
                optionsCorner.CornerRadius = UDim.new(0, 6)
                optionsCorner.Parent = optionsFrame
                
                local optionsBorder = Instance.new("UIStroke")
                optionsBorder.Color = CurrentTheme.Border
                optionsBorder.Thickness = 1
                optionsBorder.Transparency = 0.3
                optionsBorder.Parent = optionsFrame
                
                CreateDropShadow(optionsFrame)
                
                local optionsLayout = Instance.new("UIListLayout")
                optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                optionsLayout.Parent = optionsFrame
                
                local currentSelection = config.Default
                local isOpen = false
                
                for i, option in ipairs(config.Options) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = "Option" .. i
                    optionButton.Size = UDim2.new(1, 0, 0, 32)
                    optionButton.BackgroundColor3 = CurrentTheme.Surface
                    optionButton.BorderSizePixel = 0
                    optionButton.Text = option
                    optionButton.TextColor3 = CurrentTheme.TextPrimary
                    optionButton.TextSize = 13
                    optionButton.Font = Enum.Font.SourceSans
                    optionButton.Parent = optionsFrame
                    
                    AddHoverEffect(optionButton, CurrentTheme.SurfaceVariant, CurrentTheme.Surface)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        currentSelection = option
                        dropdownButton.Text = option .. " ▼"
                        optionsFrame.Visible = false
                        isOpen = false
                        CreateSpringTween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 36)}, 0.2)
                        config.Callback(option)
                    end)
                end
                
                dropdownButton.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    optionsFrame.Visible = isOpen
                    
                    if isOpen then
                        CreateSpringTween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 36 + #config.Options * 32 + 8)}, 0.2)
                        dropdownButton.Text = currentSelection .. " ▲"
                    else
                        CreateSpringTween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 36)}, 0.2)
                        dropdownButton.Text = currentSelection .. " ▼"
                    end
                end)
                
                return dropdownFrame
            end
            
            function section:CreateTextbox(config)
                config = config or {}
                config.Text = config.Text or "Textbox"
                config.Placeholder = config.Placeholder or "Enter text..."
                config.Default = config.Default or ""
                config.Callback = config.Callback or function() end
                
                local textboxFrame = Instance.new("Frame")
                textboxFrame.Name = config.Text .. "Textbox"
                textboxFrame.Size = UDim2.new(1, 0, 0, 50)
                textboxFrame.BackgroundColor3 = CurrentTheme.SurfaceVariant
                textboxFrame.BorderSizePixel = 0
                textboxFrame.Parent = sectionContent
                
                local textboxCorner = Instance.new("UICorner")
                textboxCorner.CornerRadius = UDim.new(0, 6)
                textboxCorner.Parent = textboxFrame
                
                local textboxLabel = Instance.new("TextLabel")
                textboxLabel.Name = "Label"
                textboxLabel.Size = UDim2.new(1, -20, 0, 20)
                textboxLabel.Position = UDim2.new(0, 10, 0, 5)
                textboxLabel.BackgroundTransparency = 1
                textboxLabel.Text = config.Text
                textboxLabel.TextColor3 = CurrentTheme.TextPrimary
                textboxLabel.TextSize = 14
                textboxLabel.Font = Enum.Font.SourceSans
                textboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                textboxLabel.Parent = textboxFrame
                
                local textboxInput = Instance.new("TextBox")
                textboxInput.Name = "Input"
                textboxInput.Size = UDim2.new(1, -20, 0, 22)
                textboxInput.Position = UDim2.new(0, 10, 1, -27)
                textboxInput.BackgroundColor3 = CurrentTheme.Surface
                textboxInput.BorderSizePixel = 0
                textboxInput.Text = config.Default
                textboxInput.PlaceholderText = config.Placeholder
                textboxInput.TextColor3 = CurrentTheme.TextPrimary
                textboxInput.PlaceholderColor3 = CurrentTheme.TextDisabled
                textboxInput.TextSize = 13
                textboxInput.Font = Enum.Font.SourceSans
                textboxInput.ClearButtonOnFocus = false
                textboxInput.Parent = textboxFrame
                
                local inputCorner = Instance.new("UICorner")
                inputCorner.CornerRadius = UDim.new(0, 4)
                inputCorner.Parent = textboxInput
                
                local inputBorder = Instance.new("UIStroke")
                inputBorder.Color = CurrentTheme.Border
                inputBorder.Thickness = 1
                inputBorder.Transparency = 0.5
                inputBorder.Parent = textboxInput
                
                textboxInput.Focused:Connect(function()
                    CreateSpringTween(inputBorder, {Color = CurrentTheme.Primary, Transparency = 0}, 0.2)
                end)
                
                textboxInput.FocusLost:Connect(function()
                    CreateSpringTween(inputBorder, {Color = CurrentTheme.Border, Transparency = 0.5}, 0.2)
                    config.Callback(textboxInput.Text)
                end)
                
                return textboxFrame
            end
            
            function section:CreateLabel(config)
                config = config or {}
                config.Text = config.Text or "Label"
                
                local label = Instance.new("TextLabel")
                label.Name = config.Text .. "Label"
                label.Size = UDim2.new(1, 0, 0, 25)
                label.BackgroundTransparency = 1
                label.Text = config.Text
                label.TextColor3 = CurrentTheme.TextSecondary
                label.TextSize = 14
                label.Font = Enum.Font.SourceSans
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.TextWrapped = true
                label.Parent = sectionContent
                
                return label
            end
            
            return section
        end
        
        return tab
    end
    
    function window:Destroy()
        screenGui:Destroy()
    end
    
    function window:SetVisible(visible)
        screenGui.Enabled = visible
    end
    
    function window:SetTheme(themeName)
        if Themes[themeName] then
            CurrentTheme = Themes[themeName]
            -- Update existing elements with new theme
            -- This would require storing references to all elements
        end
    end
    
    -- Show window with animation
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    CreateSpringTween(mainFrame, {Size = config.Size}, 0.4)
    
    return window
end

-- Notification System
function NexusUI:CreateNotification(config)
    config = config or {}
    config.Title = config.Title or "Notification"
    config.Description = config.Description or ""
    config.Type = config.Type or "Info" -- Info, Success, Warning, Error
    config.Duration = config.Duration or Config.NotificationDuration
    
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "NexusNotification"
    notificationGui.ResetOnSpawn = false
    notificationGui.IgnoreGuiInset = true
    
    if gethui then
        notificationGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(notificationGui)
        notificationGui.Parent = CoreGui
    else
        notificationGui.Parent = CoreGui
    end
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 350, 0, 80)
    notification.Position = UDim2.new(1, 20, 0, 50)
    notification.BackgroundColor3 = CurrentTheme.Surface
    notification.BorderSizePixel = 0
    notification.Parent = notificationGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 10)
    notifCorner.Parent = notification
    
    CreateDropShadow(notification)
    
    local notifBorder = Instance.new("UIStroke")
    notifBorder.Thickness = 1
    notifBorder.Transparency = 0.3
    notifBorder.Parent = notification
    
    -- Set color based on type
    local typeColors = {
        Info = CurrentTheme.Primary,
        Success = CurrentTheme.Success,
        Warning = CurrentTheme.Warning,
        Error = CurrentTheme.Error
    }
    notifBorder.Color = typeColors[config.Type] or CurrentTheme.Primary
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 15, 0, 12)
    icon.BackgroundTransparency = 1
    icon.TextColor3 = typeColors[config.Type] or CurrentTheme.Primary
    icon.TextSize = 20
    icon.Font = Enum.Font.SourceSansBold
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.Parent = notification
    
    local typeIcons = {
        Info = "ℹ",
        Success = "✓",
        Warning = "⚠",
        Error = "✗"
    }
    icon.Text = typeIcons[config.Type] or "ℹ"
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -90, 0, 20)
    title.Position = UDim2.new(0, 45, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = config.Title
    title.TextColor3 = CurrentTheme.TextPrimary
    title.TextSize = 15
    title.Font = Enum.Font.SourceSansBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.Parent = notification
    
    -- Description
    if config.Description ~= "" then
        local description = Instance.new("TextLabel")
        description.Name = "Description"
        description.Size = UDim2.new(1, -90, 0, 35)
        description.Position = UDim2.new(0, 45, 0, 30)
        description.BackgroundTransparency = 1
        description.Text = config.Description
        description.TextColor3 = CurrentTheme.TextSecondary
        description.TextSize = 13
        description.Font = Enum.Font.SourceSans
        description.TextXAlignment = Enum.TextXAlignment.Left
        description.TextYAlignment = Enum.TextYAlignment.Top
        description.TextWrapped = true
        description.Parent = notification
    end
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -30, 0, 10)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "×"
    closeBtn.TextColor3 = CurrentTheme.TextSecondary
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = notification
    
    -- Animate in
    CreateSpringTween(notification, {Position = UDim2.new(1, -370, 0, 50)}, 0.4)
    
    -- Auto close
    local closeNotification = function()
        CreateSpringTween(notification, {Position = UDim2.new(1, 20, 0, 50)}, 0.3)
        wait(0.3)
        notificationGui:Destroy()
    end
    
    closeBtn.MouseButton1Click:Connect(closeNotification)
    
    if config.Duration > 0 then
        spawn(function()
            wait(config.Duration)
            closeNotification()
        end)
    end
    
    return notificationGui
end

-- Dialog System
function NexusUI:CreateDialog(config)
    config = config or {}
    config.Title = config.Title or "Dialog"
    config.Description = config.Description or "Are you sure?"
    config.Buttons = config.Buttons or {
        {Text = "Cancel", Callback = function() end},
        {Text = "Confirm", Callback = function() end, Primary = true}
    }
    
    local dialogGui = Instance.new("ScreenGui")
    dialogGui.Name = "NexusDialog"
    dialogGui.ResetOnSpawn = false
    dialogGui.IgnoreGuiInset = true
    
    if gethui then
        dialogGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(dialogGui)
        dialogGui.Parent = CoreGui
    else
        dialogGui.Parent = CoreGui
    end
    
    -- Backdrop
    local backdrop = Instance.new("Frame")
    backdrop.Name = "Backdrop"
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.Position = UDim2.new(0, 0, 0, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.5
    backdrop.BorderSizePixel = 0
    backdrop.Parent = dialogGui
    
    -- Dialog
    local dialog = Instance.new("Frame")
    dialog.Name = "Dialog"
    dialog.Size = UDim2.new(0, 400, 0, 200)
    dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
    dialog.AnchorPoint = Vector2.new(0.5, 0.5)
    dialog.BackgroundColor3 = CurrentTheme.Surface
    dialog.BorderSizePixel = 0
    dialog.Parent = dialogGui
    
    local dialogCorner = Instance.new("UICorner")
    dialogCorner.CornerRadius = UDim.new(0, 12)
    dialogCorner.Parent = dialog
    
    CreateDropShadow(dialog)
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -40, 0, 40)
    titleLabel.Position = UDim2.new(0, 20, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = config.Title
    titleLabel.TextColor3 = CurrentTheme.TextPrimary
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = dialog
    
    -- Description
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(1, -40, 0, 80)
    descLabel.Position = UDim2.new(0, 20, 0, 60)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = config.Description
    descLabel.TextColor3 = CurrentTheme.TextSecondary
    descLabel.TextSize = 14
    descLabel.Font = Enum.Font.SourceSans
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.TextWrapped = true
    descLabel.Parent = dialog
    
    -- Buttons
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "Buttons"
    buttonsFrame.Size = UDim2.new(1, -40, 0, 40)
    buttonsFrame.Position = UDim2.new(0, 20, 1, -60)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = dialog
    
    local buttonsLayout = Instance.new("UIListLayout")
    buttonsLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    buttonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    buttonsLayout.Padding = UDim.new(0, 10)
    buttonsLayout.Parent = buttonsFrame
    
    for i, buttonConfig in ipairs(config.Buttons) do
        local button = Instance.new("TextButton")
        button.Name = "Button" .. i
        button.Size = UDim2.new(0, 100, 1, 0)
        button.BackgroundColor3 = buttonConfig.Primary and CurrentTheme.Primary or CurrentTheme.SurfaceVariant
        button.BorderSizePixel = 0
        button.Text = buttonConfig.Text
        button.TextColor3 = buttonConfig.Primary and Color3.fromRGB(255, 255, 255) or CurrentTheme.TextPrimary
        button.TextSize = 14
        button.Font = Enum.Font.SourceSansSemibold
        button.Parent = buttonsFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button
        
        AddHoverEffect(button, 
            buttonConfig.Primary and CurrentTheme.PrimaryVariant or CurrentTheme.Border,
            buttonConfig.Primary and CurrentTheme.Primary or CurrentTheme.SurfaceVariant
        )
        
        button.MouseButton1Click:Connect(function()
            CreateRippleEffect(button, Vector2.new(50, 20))
            buttonConfig.Callback()
            dialogGui:Destroy()
        end)
    end
    
    -- Animate in
    dialog.Size = UDim2.new(0, 0, 0, 0)
    backdrop.BackgroundTransparency = 1
    
    CreateSpringTween(dialog, {Size = UDim2.new(0, 400, 0, 200)}, 0.4)
    CreateSpringTween(backdrop, {BackgroundTransparency = 0.5}, 0.3)
    
    return dialogGui
end

-- Loading System
function NexusUI:CreateLoader(config)
    config = config or {}
    config.Text = config.Text or "Loading..."
    
    local loaderGui = Instance.new("ScreenGui")
    loaderGui.Name = "NexusLoader"
    loaderGui.ResetOnSpawn = false
    loaderGui.IgnoreGuiInset = true
    
    if gethui then
        loaderGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(loaderGui)
        loaderGui.Parent = CoreGui
    else
        loaderGui.Parent = CoreGui
    end
    
    -- Backdrop
    local backdrop = Instance.new("Frame")
    backdrop.Name = "Backdrop"
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.Position = UDim2.new(0, 0, 0, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.7
    backdrop.BorderSizePixel = 0
    backdrop.Parent = loaderGui
    
    -- Loader
    local loader = Instance.new("Frame")
    loader.Name = "Loader"
    loader.Size = UDim2.new(0, 200, 0, 100)
    loader.Position = UDim2.new(0.5, 0, 0.5, 0)
    loader.AnchorPoint = Vector2.new(0.5, 0.5)
    loader.BackgroundColor3 = CurrentTheme.Surface
    loader.BorderSizePixel = 0
    loader.Parent = loaderGui
    
    local loaderCorner = Instance.new("UICorner")
    loaderCorner.CornerRadius = UDim.new(0, 12)
    loaderCorner.Parent = loader
    
    -- Spinner
    local spinner = Instance.new("Frame")
    spinner.Name = "Spinner"
    spinner.Size = UDim2.new(0, 30, 0, 30)
    spinner.Position = UDim2.new(0.5, 0, 0.5, -15)
    spinner.AnchorPoint = Vector2.new(0.5, 0.5)
    spinner.BackgroundTransparency = 1
    spinner.Parent = loader
    
    local spinnerImage = Instance.new("ImageLabel")
    spinnerImage.Size = UDim2.new(1, 0, 1, 0)
    spinnerImage.BackgroundTransparency = 1
    spinnerImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    spinnerImage.ImageColor3 = CurrentTheme.Primary
    spinnerImage.Parent = spinner
    
    -- Text
    local text = Instance.new("TextLabel")
    text.Name = "Text"
    text.Size = UDim2.new(1, -20, 0, 20)
    text.Position = UDim2.new(0, 10, 1, -35)
    text.BackgroundTransparency = 1
    text.Text = config.Text
    text.TextColor3 = CurrentTheme.TextPrimary
    text.TextSize = 14
    text.Font = Enum.Font.SourceSans
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.Parent = loader
    
    -- Animate spinner
    local spinTween = TweenService:Create(spinnerImage, 
        TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
        {Rotation = 360}
    )
    spinTween:Play()
    
    return {
        Gui = loaderGui,
        UpdateText = function(newText)
            text.Text = newText
        end,
        Destroy = function()
            spinTween:Cancel()
            loaderGui:Destroy()
        end
    }
end

return NexusUI
