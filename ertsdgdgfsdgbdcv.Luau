--!strict
-- ByteRise UI Library
-- A modern, animated UI library for Roblox with mobile support and key system

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Debounce utility
local function debounce(func, wait)
    local lastCalled = 0
    return function(...)
        local now = tick()
        if now - lastCalled >= wait then
            lastCalled = now
            return func(...)
        end
    end
end

-- Animation presets
local ANIMATION_PRESETS = {
    ButtonHover = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    ButtonClick = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    WindowOpen = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    WindowClose = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    FadeIn = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    FadeOut = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    Bounce = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false, 0.3)
}

-- Constants
local THEME = {
    Primary = Color3.fromRGB(0, 120, 215), -- Blue
    Secondary = Color3.fromRGB(64, 156, 255),
    Background = Color3.fromRGB(30, 30, 35),
    Surface = Color3.fromRGB(40, 40, 45),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 190),
    Success = Color3.fromRGB(76, 209, 55),
    Warning = Color3.fromRGB(255, 193, 7),
    Error = Color3.fromRGB(255, 71, 87),
    
    -- Default animation
    TweenInfo = ANIMATION_PRESETS.FadeIn,
    
    -- Mobile Detection
    TouchEnabled = UserInputService.TouchEnabled,
    
    -- Screen Gui
    ScreenGui = {
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    },
    
    -- Components
    Window = {
        Size = UDim2.new(0, 500, 0, 350),
        MinSize = UDim2.new(0, 300, 0, 200),
        TitleHeight = 40,
        AccentThickness = 3,
        CornerRadius = UDim.new(0, 6)
    },
    
    Button = {
        Size = UDim2.new(1, -20, 0, 36),
        CornerRadius = UDim.new(0, 4)
    },
    
    Toggle = {
        Size = UDim2.new(0, 40, 0, 20),
        ToggleSize = UDim2.new(0, 16, 0, 16),
        Padding = 2
    },
    
    Slider = {
        Height = 24,
        HandleSize = 16,
        BarHeight = 4,
        CornerRadius = Dim.new(1, 0)
    },
    
    Dropdown = {
        MaxVisibleItems = 5,
        ItemHeight = 28
    },
    
    Input = {
        Height = 36,
        CornerRadius = UDim.new(0, 4)
    }
}

-- Utility Functions
local function create(class, props)
    local instance = Instance.new(class)
    for prop, value in pairs(props or {}) do
        if prop ~= "Parent" and prop ~= "Children" then
            instance[prop] = value
        end
    end
    
    if props and props.Children then
        for _, child in ipairs(props.Children) do
            child.Parent = instance
        end
    end
    
    if props and props.Parent then
        instance.Parent = props.Parent
    end
    
    return instance
end

local function tween(instance, properties, info)
    local tween = TweenService:Create(instance, info or THEME.TweenInfo, properties)
    tween:Play()
    return tween
end

local function createRipple(button, position, color)
    local absoluteSize = button.AbsoluteSize
    local size = math.max(absoluteSize.X, absoluteSize.Y)
    
    local ripple = create("Frame", {
        Name = "Ripple",
        BackgroundColor3 = color or THEME.Primary,
        BackgroundTransparency = 0.8,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, position.X, 0, position.Y),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 10
    })
    
    local corner = create("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, ripple)
    
    local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    tween(ripple, {
        Size = UDim2.new(0, size * 2, 0, size * 2),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1
    }, tweenInfo)
    
    game:GetService("Debris"):AddItem(ripple, 0.6)
    return ripple
end

-- Main Library
local ByteRise = {}
ByteRise.__index = ByteRise

function ByteRise.new(options)
    options = options or {}
    
    local self = setmetatable({}, ByteRise)
    
    -- Create main ScreenGui
    self.gui = create("ScreenGui", {
        Name = "ByteRise",
        ResetOnSpawn = THEME.ScreenGui.ResetOnSpawn,
        IgnoreGuiInset = THEME.ScreenGui.IgnoreGuiInset,
        ZIndexBehavior = THEME.ScreenGui.ZIndexBehavior
    })
    
    -- Key system
    if options.Key then
        self.key = options.Key
        self.activated = false
        self:setupKeySystem()
    else
        self.activated = true
        self.gui.Parent = PlayerGui
    end
    
    -- Mobile support
    if THEME.TouchEnabled then
        self:setupMobileSupport()
    end
    
    -- Store windows
    self.windows = {}
    
    return self
end

function ByteRise:setupKeySystem()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode[self.key] then
            self:toggle()
        end
    end)
end

function ByteRise:setupMobileSupport()
    -- Add mobile controls here
    -- This would include things like touch controls, swipe gestures, etc.
end

function ByteRise:toggle()
    self.activated = not self.activated
    
    if self.activated then
        self.gui.Parent = PlayerGui
        -- Animate in
    else
        -- Animate out
        task.delay(0.3, function()
            if not self.activated then
                self.gui.Parent = nil
            end
        end)
    end
end

function ByteRise:CreateWindow(options)
    options = options or {}
    
    local window = {
        title = options.Title or "ByteRise",
        size = options.Size or THEME.Window.Size,
        position = options.Position or UDim2.new(0.5, 0, 0.5, 0),
        minSize = options.MinSize or THEME.Window.MinSize,
        accentColor = options.AccentColor or THEME.Primary,
        callback = options.Callback or function() end
    }
    
    -- Create window UI
    local container = create("Frame", {
        Name = "Window",
        Size = window.size,
        Position = window.position,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = THEME.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    
    local corner = create("UICorner", {
        CornerRadius = THEME.Window.CornerRadius
    }, container)
    
    local titleBar = create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, THEME.Window.TitleHeight),
        BackgroundColor3 = THEME.Surface,
        BorderSizePixel = 0,
        ZIndex = 2
    }, container)
    
    local titleText = create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = window.title,
        TextColor3 = THEME.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        ZIndex = 2
    }, titleBar)
    
    local accentBar = create("Frame", {
        Name = "AccentBar",
        Size = UDim2.new(1, 0, 0, THEME.Window.AccentThickness),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = window.accentColor,
        BorderSizePixel = 0,
        ZIndex = 2
    }, titleBar)
    
    local content = create("ScrollingFrame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -THEME.Window.TitleHeight - THEME.Window.AccentThickness),
        Position = UDim2.new(0, 0, 0, THEME.Window.TitleHeight + THEME.Window.AccentThickness),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = THEME.Surface,
        ScrollBarImageTransparency = 0.5,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png",
        TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png",
        MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    }, container)
    
    local listLayout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    }, content)
    
    local padding = create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
    }, content)
    
    -- Enhanced window dragging with momentum and boundaries
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local velocity = Vector2.new(0, 0)
    local lastDragTime = 0
    local lastDragPos = Vector2.new(0, 0)
    local connection
    
    -- Keep window within screen bounds
    local function ensureInBounds()
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local windowSize = container.AbsoluteSize
        local position = container.AbsolutePosition
        
        local newX = math.clamp(position.X, 0, viewportSize.X - windowSize.X)
        local newY = math.clamp(position.Y, 0, viewportSize.Y - windowSize.Y)
        
        if newX ~= position.X or newY ~= position.Y then
            container.Position = UDim2.new(
                0,
                newX,
                0,
                newY
            )
            velocity = Vector2.new(0, 0) -- Stop momentum when hitting bounds
        end
    end
    
    -- Update window position with momentum
    local function updateWithMomentum(dt)
        if not dragging and velocity.Magnitude > 0.1 then
            -- Apply friction
            velocity = velocity * (1 - dt * 8)
            
            -- Update position
            local currentPos = container.AbsolutePosition
            local newPos = currentPos + velocity * dt * 60
            
            container.Position = UDim2.new(
                0,
                newPos.X,
                0,
                newPos.Y
            )
            
            ensureInBounds()
        end
    end
    
    -- Connect to render step for smooth dragging
    if not connection then
        connection = RunService.RenderStepped:Connect(function(dt)
            if dragging then
                local currentTime = tick()
                local deltaTime = currentTime - lastDragTime
                
                if deltaTime > 0 then
                    local currentPos = container.AbsolutePosition
                    local deltaPos = currentPos - lastDragPos
                    
                    -- Calculate velocity (pixels per second)
                    if deltaTime > 0 then
                        velocity = deltaPos / deltaTime
                    end
                    
                    lastDragPos = currentPos
                    lastDragTime = currentTime
                end
                
                ensureInBounds()
            end
            
            -- Update momentum
            updateWithMomentum(dt)
        end)
    end
    
    -- Start dragging
    local function startDragging(input)
        dragging = true
        dragStart = input.Position
        startPos = container.Position
        lastDragTime = tick()
        lastDragPos = container.AbsolutePosition
        velocity = Vector2.new(0, 0)
        
        -- Highlight title bar
        tween(titleBar, {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}, ANIMATION_PRESETS.ButtonHover)
    end
    
    -- Stop dragging
    local function stopDragging()
        dragging = false
        
        -- Restore title bar color
        tween(titleBar, {BackgroundColor3 = THEME.Surface}, ANIMATION_PRESETS.ButtonHover)
    end
    
    -- Handle input
    titleBar.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            startDragging(input)
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    stopDragging()
                end
            end)
        end
    end)
    
    -- Handle drag
    UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                        input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            container.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            
            -- Update velocity for momentum
            local currentTime = tick()
            local deltaTime = currentTime - lastDragTime
            
            if deltaTime > 0 then
                local currentPos = container.AbsolutePosition
                local deltaPos = currentPos - lastDragPos
                
                if deltaTime > 0 then
                    velocity = deltaPos / deltaTime
                end
                
                lastDragPos = currentPos
                lastDragTime = currentTime
            end
        end
    end)
    
    -- Add window to table
    table.insert(self.windows, container)
    
    -- Add to screen with animation
    if self.activated then
        -- Set initial state for animation
        container.Position = UDim2.new(0.5, 0, 0.4, 0)
        container.AnchorPoint = Vector2.new(0.5, 0.5)
        container.Size = UDim2.new(0, 0, 0, 0)
        container.Visible = true
        container.Parent = self.gui
        
        -- Animate window open
        tween(container, {
            Size = window.size,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5)
        }, ANIMATION_PRESETS.WindowOpen)
    end
    
    -- Public methods
    local windowMethods = {}
    
    function windowMethods:SetTitle(title)
        titleText.Text = title
    end
    
    function windowMethods:SetAccentColor(color)
        accentBar.BackgroundColor3 = color
    end
    
    function windowMethods:Destroy()
        -- Animate close before destroying
        local closeTween = tween(container, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.6, 0),
            AnchorPoint = Vector2.new(0.5, 0.5)
        }, ANIMATION_PRESETS.WindowClose)
        
        closeTween.Completed:Connect(function()
            -- Clean up
            if connection then
                connection:Disconnect()
                connection = nil
            end
            
            container:Destroy()
            for i, win in ipairs(self.windows) do
                if win == container then
                    table.remove(self.windows, i)
                    break
                end
            end
        end)
    end
    
    -- Add component creation methods
    function windowMethods:CreateButton(options)
        options = options or {}
        
        local button = create("TextButton", {
            Name = "Button",
            Size = THEME.Button.Size,
            BackgroundColor3 = THEME.Surface,
            BorderSizePixel = 0,
            Text = options.Text or "Button",
            TextColor3 = THEME.Text,
            TextSize = 14,
            Font = Enum.Font.GothamSemibold,
            AutoButtonColor = false,
            LayoutOrder = options.LayoutOrder or 1
        })
        
        local corner = create("UICorner", {
            CornerRadius = THEME.Button.CornerRadius
        }, button)
        
        -- Enhanced hover effect with scale
        local originalSize = button.Size
        local hoverSize = UDim2.new(
            originalSize.X.Scale,
            originalSize.X.Offset * 0.98,
            originalSize.Y.Scale,
            originalSize.Y.Offset * 0.98
        )
        
        local originalColor = button.BackgroundColor3
        local hoverColor = Color3.new(
            math.min(originalColor.R * 1.3, 1),
            math.min(originalColor.G * 1.3, 1),
            math.min(originalColor.B * 1.3, 1)
        )
        
        -- Store original text color
        local originalTextColor = button.TextColor3
        
        -- Hover animation
        button.MouseEnter:Connect(function()
            tween(button, {
                BackgroundColor3 = hoverColor,
                Size = hoverSize,
                TextColor3 = THEME.Text
            }, ANIMATION_PRESETS.ButtonHover)
        end)
        
        -- Leave animation
        button.MouseLeave:Connect(function()
            tween(button, {
                BackgroundColor3 = originalColor,
                Size = originalSize,
                TextColor3 = originalTextColor
            }, ANIMATION_PRESETS.ButtonHover)
        end)
        
        -- Enhanced click effect with ripple
        button.MouseButton1Down:Connect(function(x, y)
            -- Create ripple effect
            local mouse = UserInputService:GetMouseLocation()
            local buttonPos = button.AbsolutePosition
            local pos = Vector2.new(
                mouse.X - buttonPos.X,
                mouse.Y - buttonPos.Y
            )
            
            local ripple = createRipple(button, pos, Color3.new(1, 1, 1))
            ripple.Parent = button
            
            -- Click animation
            tween(button, {
                Size = UDim2.new(
                    originalSize.X.Scale * 0.96,
                    originalSize.X.Offset * 0.96,
                    originalSize.Y.Scale * 0.9,
                    originalSize.Y.Offset * 0.9
                ),
                BackgroundTransparency = 0.2
            }, ANIMATION_PRESETS.ButtonClick)
        end)
        
        button.MouseButton1Up:Connect(function()
            -- Bounce back animation
            local bounceTween = tween(button, {
                Size = UDim2.new(
                    originalSize.X.Scale * 1.05,
                    originalSize.X.Offset * 1.05,
                    originalSize.Y.Scale * 1.1,
                    originalSize.Y.Offset * 1.1
                ),
                BackgroundTransparency = 0
            }, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
            
            bounceTween.Completed:Connect(function()
                tween(button, {
                    Size = originalSize,
                    BackgroundTransparency = 0
                }, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false, 0.1))
            end)
            
            -- Execute callback with debounce
            if options.Callback then
                debounce(function()
                    task.spawn(options.Callback)
                end, 0.5)()
            end
        end)
        
        -- Add keyboard focus effect
        button.SelectionGained:Connect(function()
            tween(button, {
                BackgroundColor3 = hoverColor,
                Size = hoverSize
            }, ANIMATION_PRESETS.ButtonHover)
        end)
        
        button.SelectionLost:Connect(function()
            tween(button, {
                BackgroundColor3 = originalColor,
                Size = originalSize
            }, ANIMATION_PRESETS.ButtonHover)
        end)
        
        -- Add to content
        button.Parent = content
        
        -- Public methods
        local buttonMethods = {}
        
        function buttonMethods:Destroy()
            button:Destroy()
        end
        
        function buttonMethods:SetText(text)
            button.Text = text
        end
        
        return buttonMethods
    end
    
    -- Add more component creation methods here (Toggle, Slider, Dropdown, etc.)
    
    return windowMethods
end

-- Initialize the library
return ByteRise
