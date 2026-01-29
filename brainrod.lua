-- ACR-HUB BRANIROT - ULTIMATE EDITION
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = Workspace.CurrentCamera

-- BRAINROT ÖZEL ÖZELLİKLER
local BrainrotFeatures = {
    AutoFarm = false,
    AutoCollect = false,
    AutoSell = false,
    AutoRebirth = false,
    SpeedHack = false,
    JumpHack = false,
    NoClipFarm = false,
    AntiAfk = false,
    AutoEquipBest = false,
    AutoUpgrade = false,
    DupeItems = false
}

-- AYARLAR
local States = { 
    Bypass = false, 
    ESP = false, 
    AntiKB = false, 
    AutoClicker = false, 
    InfJump = false, 
    NoClip = false, 
    EmptyXRay = false, 
    FreeCam = false,
    Fly = false,
    Speed = false,
    NoclipESP = false,
    FullBright = false
}

-- BRAINROT OYUNU İÇİN ÖZEL DEĞİŞKENLER
local BrainrotGame = {
    IsBrainrot = false,
    AreaESP = false,
    ItemESP = false,
    MobESP = false,
    AutoClickRadius = 50,
    FarmSpeed = 1,
    SelectedArea = "Spawn"
}

local BoostPower = 33
local FlySpeed = 50
local FlyKeys = {W = false, A = false, S = false, D = false, Q = false, E = false}
local FlyToggle = Enum.KeyCode.F

local BorderColor = Color3.fromRGB(0, 255, 255)
local AccentColor = Color3.fromRGB(255, 0, 255)
local OnColor = Color3.fromRGB(0, 255, 120)
local OffColor = Color3.fromRGB(150, 150, 150)

-- FREE CAM VARIABLES (DÜZELTİLMİŞ)
local FreeCamEnabled = false
local FreeCamSpeed = 2
local FreeCamSensitivity = 0.5
local FreeCamCFrame = CFrame.new()
local FreeCamInput = {
    W = false,
    A = false,
    S = false,
    D = false,
    Q = false,
    E = false
}

-- FLY VARIABLES
local BodyVelocity = nil
local BodyGyro = nil

-- GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ACR_BRANIROT"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end) then
    -- Success
else
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

-- BRAINROT OYUNU KONTROLÜ
local function CheckBrainrotGame()
    local success, gameInfo = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    end)
    
    if success and gameInfo then
        local gameName = gameInfo.Name:lower()
        local brainrotKeywords = {"brainrot", "brain", "rot", "clicker", "simulator", "tycoon", "farm", "pet"}
        
        for _, keyword in ipairs(brainrotKeywords) do
            if string.find(gameName, keyword) then
                BrainrotGame.IsBrainrot = true
                return true
            end
        end
    end
    
    -- Bazı popüler brainrot oyunları için manuel kontrol
    local placeId = game.PlaceId
    local knownBrainrotGames = {
        [155615604] = true, -- Prison Life
        [142823291] = true, -- Murder Mystery 2
        [286090429] = true, -- Arsenal
        [292439477] = true, -- Phantom Forces
        [606849621] = true, -- Jailbreak
    }
    
    if knownBrainrotGames[placeId] then
        BrainrotGame.IsBrainrot = true
        return true
    end
    
    return false
end

CheckBrainrotGame()

-- SLIDER SETUP FONKSİYONU (BAŞA TAŞINDI)
local function SetupSlider(sliderData, minValue, maxValue, currentValue, callback)
    if not sliderData then return end
    
    local function UpdateSlider(value)
        value = math.clamp(value, minValue, maxValue)
        local percent = (value - minValue) / (maxValue - minValue)
        if sliderData.Fill then
            sliderData.Fill.Size = UDim2.new(percent, 0, 1, 0)
        end
        if sliderData.Button then
            sliderData.Button.Position = UDim2.new(percent, -8, 0.5, -8)
        end
        if sliderData.ValueLabel then
            sliderData.ValueLabel.Text = tostring(math.floor(value))
        end
        if callback then
            callback(value)
        end
    end
    
    -- Initialize
    UpdateSlider(currentValue)
    
    -- Dragging
    local dragging = false
    
    if sliderData.Button then
        sliderData.Button.MouseButton1Down:Connect(function()
            dragging = true
        end)
    end
    
    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end
    
    UserInputService.InputEnded:Connect(onInputEnded)
    
    local function onInputChanged(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            if sliderData.Background then
                local mousePos = UserInputService:GetMouseLocation()
                local relativeX = mousePos.X - sliderData.Background.AbsolutePosition.X
                local percent = math.clamp(relativeX / sliderData.Background.AbsoluteSize.X, 0, 1)
                UpdateSlider(minValue + percent * (maxValue - minValue))
            end
        end
    end
    
    UserInputService.InputChanged:Connect(onInputChanged)
    
    -- Click to set value
    if sliderData.Frame then
        local ClickButton = Instance.new("TextButton")
        ClickButton.Name = "ClickButton"
        ClickButton.Size = UDim2.new(1, 0, 1, 0)
        ClickButton.Position = UDim2.new(0, 0, 0, 0)
        ClickButton.BackgroundTransparency = 1
        ClickButton.Text = ""
        ClickButton.Parent = sliderData.Frame
        
        ClickButton.MouseButton1Down:Connect(function(x, y)
            if sliderData.Background then
                local relativeX = x - sliderData.Background.AbsolutePosition.X
                local percent = math.clamp(relativeX / sliderData.Background.AbsoluteSize.X, 0, 1)
                UpdateSlider(minValue + percent * (maxValue - minValue))
            end
        end)
    end
end

-- MAIN CONTAINER (BRAINROT TEMASI)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Size = UDim2.new(0, 350, 0, 600)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -300)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- NEON GLOW EFFECT
local UIGlow = Instance.new("UIGradient")
UIGlow.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))
})
UIGlow.Rotation = 90
UIGlow.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = BorderColor
UIStroke.Thickness = 3
UIStroke.Transparency = 0.3
UIStroke.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainFrame

-- HEADER WITH ANIMATED TEXT
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 70)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.7, 0)
Title.Text = "ACR-HUB BRANIROT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SciFi
Title.TextSize = 28
Title.BackgroundTransparency = 1
Title.TextStrokeTransparency = 0
Title.TextStrokeColor3 = BorderColor
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0.3, 0)
Subtitle.Position = UDim2.new(0, 0, 0.7, 0)
Subtitle.Text = BrainrotGame.IsBrainrot and "🧠 BRAINROT MODE 🧠" or "⚡ ULTIMATE CHEAT MENU ⚡"
Subtitle.TextColor3 = AccentColor
Subtitle.Font = Enum.Font.Code
Subtitle.TextSize = 14
Subtitle.BackgroundTransparency = 1
Subtitle.Parent = Header

-- STATUS BAR
local StatusBar = Instance.new("Frame")
StatusBar.Name = "StatusBar"
StatusBar.Size = UDim2.new(1, -20, 0, 4)
StatusBar.Position = UDim2.new(0, 10, 0, 70)
StatusBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
StatusBar.Parent = MainFrame

local StatusFill = Instance.new("Frame")
StatusFill.Name = "StatusFill"
StatusFill.Size = UDim2.new(0.7, 0, 1, 0)
StatusFill.BackgroundColor3 = BorderColor
StatusFill.Parent = StatusBar

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(1, 0)
StatusCorner.Parent = StatusBar

-- MODULES CONTAINER
local Container = Instance.new("ScrollingFrame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -20, 1, -200)
Container.Position = UDim2.new(0, 10, 0, 85)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.ScrollBarThickness = 4
Container.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = Container

-- CONTAINER SIZE UPDATER
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end)

-- MODÜL OLUŞTURUCU
local function CreateModule(text, stateKey, hasSlider, isBrainrot)
    local ModuleFrame = Instance.new("Frame")
    ModuleFrame.Name = text .. "Module"
    ModuleFrame.Size = UDim2.new(1, 0, 0, hasSlider and 70 or 45)
    ModuleFrame.BackgroundColor3 = isBrainrot and Color3.fromRGB(20, 0, 20) or Color3.fromRGB(10, 10, 10)
    ModuleFrame.BackgroundTransparency = 0.3
    ModuleFrame.Parent = Container
    
    local ModuleCorner = Instance.new("UICorner")
    ModuleCorner.CornerRadius = UDim.new(0, 10)
    ModuleCorner.Parent = ModuleFrame
    
    local ModuleStroke = Instance.new("UIStroke")
    ModuleStroke.Color = isBrainrot and AccentColor or BorderColor
    ModuleStroke.Thickness = 2
    ModuleStroke.Parent = ModuleFrame
    
    -- Module Header
    local ModuleHeader = Instance.new("Frame")
    ModuleHeader.Size = UDim2.new(1, 0, 0, 25)
    ModuleHeader.BackgroundTransparency = 1
    ModuleHeader.Parent = ModuleFrame
    
    local ModuleIcon = Instance.new("TextLabel")
    ModuleIcon.Size = UDim2.new(0, 25, 0, 25)
    ModuleIcon.Text = isBrainrot and "🧠" or "⚡"
    ModuleIcon.TextColor3 = isBrainrot and AccentColor or BorderColor
    ModuleIcon.Font = Enum.Font.SciFi
    ModuleIcon.TextSize = 18
    ModuleIcon.BackgroundTransparency = 1
    ModuleIcon.Parent = ModuleHeader
    
    -- Toggle Button
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleBtn"
    ToggleBtn.Size = UDim2.new(1, -40, 0, 25)
    ToggleBtn.Position = UDim2.new(0, 30, 0, 0)
    ToggleBtn.BackgroundColor3 = isBrainrot and Color3.fromRGB(30, 0, 30) or Color3.fromRGB(20, 20, 20)
    ToggleBtn.Text = text .. (States[stateKey] and " [ON]" or " [OFF]")
    ToggleBtn.TextColor3 = States[stateKey] and OnColor or OffColor
    ToggleBtn.Font = Enum.Font.Code
    ToggleBtn.TextSize = 14
    ToggleBtn.Parent = ModuleHeader
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleBtn
    
    -- Toggle Indicator
    local Indicator = Instance.new("Frame")
    Indicator.Name = "Indicator"
    Indicator.Size = UDim2.new(0, 10, 0, 10)
    Indicator.Position = UDim2.new(1, -15, 0.5, -5)
    Indicator.BackgroundColor3 = States[stateKey] and OnColor or Color3.fromRGB(80, 80, 80)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = ToggleBtn
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = Indicator
    
    -- Slider for speed/power adjustment
    local SliderData = nil
    
    if hasSlider then
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = "SliderFrame"
        SliderFrame.Size = UDim2.new(1, -20, 0, 25)
        SliderFrame.Position = UDim2.new(0, 10, 0, 35)
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Parent = ModuleFrame
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0, 50, 1, 0)
        ValueLabel.Position = UDim2.new(1, -50, 0, 0)
        ValueLabel.Text = "50"
        ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ValueLabel.Font = Enum.Font.Code
        ValueLabel.TextSize = 12
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Parent = SliderFrame
        
        local SliderBackground = Instance.new("Frame")
        SliderBackground.Name = "SliderBackground"
        SliderBackground.Size = UDim2.new(1, -60, 0, 6)
        SliderBackground.Position = UDim2.new(0, 0, 0.5, -3)
        SliderBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        SliderBackground.BorderSizePixel = 0
        SliderBackground.Parent = SliderFrame
        
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(1, 0)
        SliderCorner.Parent = SliderBackground
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Name = "SliderFill"
        SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
        SliderFill.BackgroundColor3 = isBrainrot and AccentColor or BorderColor
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderBackground
        
        local SliderFillCorner = Instance.new("UICorner")
        SliderFillCorner.CornerRadius = UDim.new(1, 0)
        SliderFillCorner.Parent = SliderFill
        
        local SliderButton = Instance.new("TextButton")
        SliderButton.Name = "SliderButton"
        SliderButton.Size = UDim2.new(0, 16, 0, 16)
        SliderButton.Position = UDim2.new(0.5, -8, 0.5, -8)
        SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderButton.Text = ""
        SliderButton.ZIndex = 2
        SliderButton.Parent = SliderFrame
        
        local SliderButtonCorner = Instance.new("UICorner")
        SliderButtonCorner.CornerRadius = UDim.new(1, 0)
        SliderButtonCorner.Parent = SliderButton
        
        SliderData = {
            Frame = SliderFrame,
            Background = SliderBackground,
            Fill = SliderFill,
            Button = SliderButton,
            ValueLabel = ValueLabel
        }
    end
    
    -- Toggle functionality
    ToggleBtn.MouseButton1Click:Connect(function()
        if stateKey == "Bypass" then
            States.Bypass = not States.Bypass
        elseif stateKey == "ESP" then
            States.ESP = not States.ESP
            if not States.ESP then
                ClearESP()
            end
        elseif stateKey == "AntiKB" then
            States.AntiKB = not States.AntiKB
        elseif stateKey == "AutoClicker" then
            States.AutoClicker = not States.AutoClicker
        elseif stateKey == "InfJump" then
            States.InfJump = not States.InfJump
        elseif stateKey == "NoClip" then
            States.NoClip = not States.NoClip
        elseif stateKey == "EmptyXRay" then
            States.EmptyXRay = not States.EmptyXRay
            UpdateXRay()
        elseif stateKey == "FreeCam" then
            States.FreeCam = not States.FreeCam
            if States.FreeCam then
                EnableFreeCam()
            else
                DisableFreeCam()
            end
        elseif stateKey == "Fly" then
            States.Fly = not States.Fly
            if States.Fly then
                EnableFly()
            else
                DisableFly()
            end
        elseif stateKey == "FullBright" then
            States.FullBright = not States.FullBright
            if States.FullBright then
                EnableFullBright()
            else
                DisableFullBright()
            end
        end
        
        ToggleBtn.Text = text .. (States[stateKey] and " [ON]" or " [OFF]")
        ToggleBtn.TextColor3 = States[stateKey] and OnColor or OffColor
        Indicator.BackgroundColor3 = States[stateKey] and OnColor or Color3.fromRGB(80, 80, 80)
    end)
    
    return ModuleFrame, SliderData, ToggleBtn
end

-- BRAINROT ÖZEL MODÜLÜ
local function CreateBrainrotModule(text, featureKey, hasSlider)
    local ModuleFrame = Instance.new("Frame")
    ModuleFrame.Name = text .. "Module"
    ModuleFrame.Size = UDim2.new(1, 0, 0, hasSlider and 70 or 45)
    ModuleFrame.BackgroundColor3 = Color3.fromRGB(20, 0, 20)
    ModuleFrame.BackgroundTransparency = 0.3
    ModuleFrame.Parent = Container
    
    local ModuleCorner = Instance.new("UICorner")
    ModuleCorner.CornerRadius = UDim.new(0, 10)
    ModuleCorner.Parent = ModuleFrame
    
    local ModuleStroke = Instance.new("UIStroke")
    ModuleStroke.Color = AccentColor
    ModuleStroke.Thickness = 2
    ModuleStroke.Parent = ModuleFrame
    
    -- Module Header
    local ModuleHeader = Instance.new("Frame")
    ModuleHeader.Size = UDim2.new(1, 0, 0, 25)
    ModuleHeader.BackgroundTransparency = 1
    ModuleHeader.Parent = ModuleFrame
    
    local ModuleIcon = Instance.new("TextLabel")
    ModuleIcon.Size = UDim2.new(0, 25, 0, 25)
    ModuleIcon.Text = "🧠"
    ModuleIcon.TextColor3 = AccentColor
    ModuleIcon.Font = Enum.Font.SciFi
    ModuleIcon.TextSize = 18
    ModuleIcon.BackgroundTransparency = 1
    ModuleIcon.Parent = ModuleHeader
    
    -- Toggle Button
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleBtn"
    ToggleBtn.Size = UDim2.new(1, -40, 0, 25)
    ToggleBtn.Position = UDim2.new(0, 30, 0, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 0, 30)
    ToggleBtn.Text = text .. (BrainrotFeatures[featureKey] and " [ON]" or " [OFF]")
    ToggleBtn.TextColor3 = BrainrotFeatures[featureKey] and OnColor or OffColor
    ToggleBtn.Font = Enum.Font.Code
    ToggleBtn.TextSize = 14
    ToggleBtn.Parent = ModuleHeader
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleBtn
    
    -- Toggle Indicator
    local Indicator = Instance.new("Frame")
    Indicator.Name = "Indicator"
    Indicator.Size = UDim2.new(0, 10, 0, 10)
    Indicator.Position = UDim2.new(1, -15, 0.5, -5)
    Indicator.BackgroundColor3 = BrainrotFeatures[featureKey] and OnColor or Color3.fromRGB(80, 80, 80)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = ToggleBtn
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = Indicator
    
    local SliderData = nil
    
    if hasSlider then
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = "SliderFrame"
        SliderFrame.Size = UDim2.new(1, -20, 0, 25)
        SliderFrame.Position = UDim2.new(0, 10, 0, 35)
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Parent = ModuleFrame
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0, 50, 1, 0)
        ValueLabel.Position = UDim2.new(1, -50, 0, 0)
        ValueLabel.Text = "50"
        ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ValueLabel.Font = Enum.Font.Code
        ValueLabel.TextSize = 12
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Parent = SliderFrame
        
        local SliderBackground = Instance.new("Frame")
        SliderBackground.Name = "SliderBackground"
        SliderBackground.Size = UDim2.new(1, -60, 0, 6)
        SliderBackground.Position = UDim2.new(0, 0, 0.5, -3)
        SliderBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        SliderBackground.BorderSizePixel = 0
        SliderBackground.Parent = SliderFrame
        
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(1, 0)
        SliderCorner.Parent = SliderBackground
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Name = "SliderFill"
        SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
        SliderFill.BackgroundColor3 = AccentColor
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderBackground
        
        local SliderFillCorner = Instance.new("UICorner")
        SliderFillCorner.CornerRadius = UDim.new(1, 0)
        SliderFillCorner.Parent = SliderFill
        
        local SliderButton = Instance.new("TextButton")
        SliderButton.Name = "SliderButton"
        SliderButton.Size = UDim2.new(0, 16, 0, 16)
        SliderButton.Position = UDim2.new(0.5, -8, 0.5, -8)
        SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderButton.Text = ""
        SliderButton.ZIndex = 2
        SliderButton.Parent = SliderFrame
        
        local SliderButtonCorner = Instance.new("UICorner")
        SliderButtonCorner.CornerRadius = UDim.new(1, 0)
        SliderButtonCorner.Parent = SliderButton
        
        SliderData = {
            Frame = SliderFrame,
            Background = SliderBackground,
            Fill = SliderFill,
            Button = SliderButton,
            ValueLabel = ValueLabel
        }
    end
    
    -- Toggle functionality
    ToggleBtn.MouseButton1Click:Connect(function()
        BrainrotFeatures[featureKey] = not BrainrotFeatures[featureKey]
        ToggleBtn.Text = text .. (BrainrotFeatures[featureKey] and " [ON]" or " [OFF]")
        ToggleBtn.TextColor3 = BrainrotFeatures[featureKey] and OnColor or OffColor
        Indicator.BackgroundColor3 = BrainrotFeatures[featureKey] and OnColor or Color3.fromRGB(80, 80, 80)
    end)
    
    return ModuleFrame, SliderData, ToggleBtn
end

-- X-RAY UPDATE FONKSİYONU
local function UpdateXRay()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:lower():find("base") or v.Name:lower():find("empty") or v.Name:lower():find("wall")) then
            v.Transparency = States.EmptyXRay and 0.5 or 0
        end
    end
end

-- ESP CLEAR FONKSİYONU
local function ClearESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("ACR_ESP") then
            player.Character.ACR_ESP:Destroy()
        end
    end
end

-- TÜM MODÜLLERİ OLUŞTUR
local Modules = {}
local Sliders = {}

-- GENEL MODÜLLER
local SpeedModule, SpeedSliderData, SpeedToggle = CreateModule("Hız Hilesi", "Bypass", true, false)
if SpeedSliderData then
    Sliders["Speed"] = {
        data = SpeedSliderData,
        callback = function(value)
            BoostPower = value
            if SpeedToggle then
                SpeedToggle.Text = "Hız Hilesi: " .. value .. (States.Bypass and " [ON]" or " [OFF]")
            end
        end
    }
end

CreateModule("Uçuş Modu (F)", "Fly", false, false)
CreateModule("Player ESP", "ESP", false, false)
CreateModule("Anti-Knockback", "AntiKB", false, false)
CreateModule("Boş Alan X-Ray", "EmptyXRay", false, false)
CreateModule("No-Clip", "NoClip", false, false)
CreateModule("Sonsuz Zıplama", "InfJump", false, false)
CreateModule("Auto-Clicker", "AutoClicker", false, false)
CreateModule("FullBright", "FullBright", false, false)

-- FREE CAM MODÜLÜ
local FreeCamModule, FreeCamSliderData, FreeCamToggle = CreateModule("Serbest Kamera", "FreeCam", true, false)
if FreeCamSliderData then
    Sliders["FreeCam"] = {
        data = FreeCamSliderData,
        callback = function(value)
            FreeCamSpeed = value
            if FreeCamToggle then
                FreeCamToggle.Text = "Serbest Kamera: " .. string.format("%.1f", value) .. (States.FreeCam and " [ON]" or " [OFF]")
            end
        end
    }
end

-- BRAINROT ÖZEL MODÜLLER
if BrainrotGame.IsBrainrot then
    local AutoFarmModule, AutoFarmSlider, AutoFarmToggle = CreateBrainrotModule("Auto Farm", "AutoFarm", true)
    if AutoFarmSlider then
        Sliders["AutoFarm"] = {
            data = AutoFarmSlider,
            callback = function(value)
                BrainrotGame.FarmSpeed = value
                if AutoFarmToggle then
                    AutoFarmToggle.Text = "Auto Farm: " .. value .. "x" .. (BrainrotFeatures.AutoFarm and " [ON]" or " [OFF]")
                end
            end
        }
    end
    
    CreateBrainrotModule("Auto Toplama", "AutoCollect", false)
    CreateBrainrotModule("Auto Satış", "AutoSell", false)
    CreateBrainrotModule("Auto Rebirth", "AutoRebirth", false)
    CreateBrainrotModule("Jump Hack", "JumpHack", false)
    CreateBrainrotModule("NoClip Farm", "NoClipFarm", false)
    CreateBrainrotModule("Anti-AFK", "AntiAfk", false)
    CreateBrainrotModule("En İyiyi Otomatik Kuşan", "AutoEquipBest", false)
    CreateBrainrotModule("Otomatik Yükselt", "AutoUpgrade", false)
    CreateBrainrotModule("Eşya Çoğaltma", "DupeItems", false)
end

-- SLIDER'LARI SETUP ET
for name, sliderInfo in pairs(Sliders) do
    if name == "Speed" then
        SetupSlider(sliderInfo.data, 16, 160, BoostPower, sliderInfo.callback)
    elseif name == "FreeCam" then
        SetupSlider(sliderInfo.data, 0.1, 10, FreeCamSpeed, sliderInfo.callback)
    elseif name == "AutoFarm" then
        SetupSlider(sliderInfo.data, 1, 10, BrainrotGame.FarmSpeed, sliderInfo.callback)
    end
end

-- FOOTER
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, -20, 0, 50)
Footer.Position = UDim2.new(0, 10, 1, -60)
Footer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Footer.BackgroundTransparency = 0.5
Footer.Parent = MainFrame

local FooterCorner = Instance.new("UICorner")
FooterCorner.CornerRadius = UDim.new(0, 10)
FooterCorner.Parent = Footer

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -10, 0.5, 0)
StatusLabel.Position = UDim2.new(0, 5, 0, 0)
StatusLabel.Text = "Status: Aktif | INSERT tuşu ile gizle/göster"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 12
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = Footer

local KeybindsLabel = Instance.new("TextLabel")
KeybindsLabel.Size = UDim2.new(1, -10, 0.5, 0)
KeybindsLabel.Position = UDim2.new(0, 5, 0.5, 0)
KeybindsLabel.Text = "F: Uçuş | C: NoClip | P: FreeCam Mouse"
KeybindsLabel.TextColor3 = AccentColor
KeybindsLabel.Font = Enum.Font.Code
KeybindsLabel.TextSize = 11
KeybindsLabel.BackgroundTransparency = 1
KeybindsLabel.Parent = Footer

-- FREE CAM FUNCTIONS (DÜZELTİLMİŞ)
function EnableFreeCam()
    FreeCamEnabled = true
    FreeCamCFrame = Camera.CFrame
    
    -- Hide character
    if Character then
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 1
            end
        end
    end
    
    -- Disable character movement
    if Humanoid then
        Humanoid.WalkSpeed = 0
    end
    
    Camera.CameraType = Enum.CameraType.Scriptable
    print("Serbest Kamera Aktif - WSAD ile hareket, Fare ile bak")
end

function DisableFreeCam()
    FreeCamEnabled = false
    
    -- Show character
    if Character then
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 0
            end
        end
    end
    
    -- Enable character movement
    if Humanoid then
        Humanoid.WalkSpeed = 16
    end
    
    -- Reset camera
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = Humanoid
    end
    
    print("Serbest Kamera Deaktif")
end

-- FLY FUNCTIONS
function EnableFly()
    if not BodyVelocity then
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(0, 0, 0)
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.Parent = Root
    end
    
    if not BodyGyro then
        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.MaxTorque = Vector3.new(0, 0, 0)
        BodyGyro.P = 1000
        BodyGyro.D = 50
        BodyGyro.Parent = Root
    end
    
    BodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
    BodyGyro.MaxTorque = Vector3.new(10000, 10000, 10000)
    
    print("Uçuş Modu Aktif - WSAD + Q/E")
end

function DisableFly()
    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
    
    if BodyGyro then
        BodyGyro:Destroy()
        BodyGyro = nil
    end
    
    print("Uçuş Modu Deaktif")
end

-- FULLBRIGHT FUNCTIONS
function EnableFullBright()
    Lighting.Brightness = 2
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    
    print("FullBright Aktif")
end

function DisableFullBright()
    Lighting.Brightness = 1
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    Lighting.FogEnd = 1000
    Lighting.GlobalShadows = true
    
    print("FullBright Deaktif")
end

-- INPUT HANDLING
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Free Cam Inputs
    if FreeCamEnabled then
        if input.KeyCode == Enum.KeyCode.W then
            FreeCamInput.W = true
        elseif input.KeyCode == Enum.KeyCode.A then
            FreeCamInput.A = true
        elseif input.KeyCode == Enum.KeyCode.S then
            FreeCamInput.S = true
        elseif input.KeyCode == Enum.KeyCode.D then
            FreeCamInput.D = true
        elseif input.KeyCode == Enum.KeyCode.Q then
            FreeCamInput.Q = true
        elseif input.KeyCode == Enum.KeyCode.E then
            FreeCamInput.E = true
        end
    end
    
    -- Fly Inputs
    if States.Fly then
        if input.KeyCode == Enum.KeyCode.W then
            FlyKeys.W = true
        elseif input.KeyCode == Enum.KeyCode.A then
            FlyKeys.A = true
        elseif input.KeyCode == Enum.KeyCode.S then
            FlyKeys.S = true
        elseif input.KeyCode == Enum.KeyCode.D then
            FlyKeys.D = true
        elseif input.KeyCode == Enum.KeyCode.Q then
            FlyKeys.Q = true
        elseif input.KeyCode == Enum.KeyCode.E then
            FlyKeys.E = true
        end
    end
    
    -- Toggle Fly
    if input.KeyCode == FlyToggle then
        States.Fly = not States.Fly
        if States.Fly then
            EnableFly()
        else
            DisableFly()
        end
        
        -- Update UI
        for _, child in pairs(Container:GetChildren()) do
            if child.Name == "Uçuş Modu (F)Module" then
                local toggleBtn = child:FindFirstChild("ToggleBtn")
                if toggleBtn then
                    toggleBtn.Text = "Uçuş Modu (F)" .. (States.Fly and " [ON]" or " [OFF]")
                    toggleBtn.TextColor3 = States.Fly and OnColor or OffColor
                    
                    local indicator = toggleBtn:FindFirstChild("Indicator")
                    if indicator then
                        indicator.BackgroundColor3 = States.Fly and OnColor or Color3.fromRGB(80, 80, 80)
                    end
                end
            end
        end
    end
    
    -- Toggle GUI
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
    
    -- Toggle NoClip
    if input.KeyCode == Enum.KeyCode.C then
        States.NoClip = not States.NoClip
        
        -- Update UI
        for _, child in pairs(Container:GetChildren()) do
            if child.Name == "No-ClipModule" then
                local toggleBtn = child:FindFirstChild("ToggleBtn")
                if toggleBtn then
                    toggleBtn.Text = "No-Clip" .. (States.NoClip and " [ON]" or " [OFF]")
                    toggleBtn.TextColor3 = States.NoClip and OnColor or OffColor
                    
                    local indicator = toggleBtn:FindFirstChild("Indicator")
                    if indicator then
                        indicator.BackgroundColor3 = States.NoClip and OnColor or Color3.fromRGB(80, 80, 80)
                    end
                end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Free Cam Inputs
    if FreeCamEnabled then
        if input.KeyCode == Enum.KeyCode.W then
            FreeCamInput.W = false
        elseif input.KeyCode == Enum.KeyCode.A then
            FreeCamInput.A = false
        elseif input.KeyCode == Enum.KeyCode.S then
            FreeCamInput.S = false
        elseif input.KeyCode == Enum.KeyCode.D then
            FreeCamInput.D = false
        elseif input.KeyCode == Enum.KeyCode.Q then
            FreeCamInput.Q = false
        elseif input.KeyCode == Enum.KeyCode.E then
            FreeCamInput.E = false
        end
    end
    
    -- Fly Inputs
    if States.Fly then
        if input.KeyCode == Enum.KeyCode.W then
            FlyKeys.W = false
        elseif input.KeyCode == Enum.KeyCode.A then
            FlyKeys.A = false
        elseif input.KeyCode == Enum.KeyCode.S then
            FlyKeys.S = false
        elseif input.KeyCode == Enum.KeyCode.D then
            FlyKeys.D = false
        elseif input.KeyCode == Enum.KeyCode.Q then
            FlyKeys.Q = false
        elseif input.KeyCode == Enum.KeyCode.E then
            FlyKeys.E = false
        end
    end
end)

-- FREE CAM MOUSE LOOK (DÜZELTİLMİŞ)
local mouseLocked = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.P and FreeCamEnabled then
        mouseLocked = not mouseLocked
        UserInputService.MouseBehavior = mouseLocked and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
    end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if gameProcessed or not FreeCamEnabled or not mouseLocked then return end
    
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Delta
        FreeCamCFrame = FreeCamCFrame * CFrame.fromEulerAnglesYXZ(
            -delta.Y * 0.002 * FreeCamSensitivity,
            -delta.X * 0.002 * FreeCamSensitivity,
            0
        )
    end
end)

-- ANA DÖNGÜ
RunService.Heartbeat:Connect(function(deltaTime)
    -- Movement Bypass
    if States.Bypass and Humanoid.MoveDirection.Magnitude > 0 then
        Root.Velocity = Vector3.new(Humanoid.MoveDirection.X * BoostPower, Root.Velocity.Y, Humanoid.MoveDirection.Z * BoostPower)
    end
    
    -- Free Camera Movement (DÜZELTİLMİŞ)
    if FreeCamEnabled then
        local moveVector = Vector3.new(0, 0, 0)
        
        if FreeCamInput.W then
            moveVector = moveVector + FreeCamCFrame.LookVector
        end
        if FreeCamInput.S then
            moveVector = moveVector - FreeCamCFrame.LookVector
        end
        if FreeCamInput.D then
            moveVector = moveVector + FreeCamCFrame.RightVector
        end
        if FreeCamInput.A then
            moveVector = moveVector - FreeCamCFrame.RightVector
        end
        if FreeCamInput.Q then
            moveVector = moveVector - Vector3.new(0, 1, 0)
        end
        if FreeCamInput.E then
            moveVector = moveVector + Vector3.new(0, 1, 0)
        end
        
        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit * FreeCamSpeed * 10
        end
        
        FreeCamCFrame = FreeCamCFrame + moveVector * deltaTime
        Camera.CFrame = FreeCamCFrame
    end
    
    -- Fly Movement
    if States.Fly and BodyVelocity and BodyGyro then
        BodyGyro.CFrame = Camera.CFrame
        
        local velocity = Vector3.new(0, 0, 0)
        
        if FlyKeys.W then
            velocity = velocity + (Camera.CFrame.LookVector * FlySpeed)
        end
        if FlyKeys.S then
            velocity = velocity - (Camera.CFrame.LookVector * FlySpeed)
        end
        if FlyKeys.D then
            velocity = velocity + (Camera.CFrame.RightVector * FlySpeed)
        end
        if FlyKeys.A then
            velocity = velocity - (Camera.CFrame.RightVector * FlySpeed)
        end
        if FlyKeys.Q then
            velocity = velocity + Vector3.new(0, FlySpeed, 0)
        end
        if FlyKeys.E then
            velocity = velocity - Vector3.new(0, FlySpeed, 0)
        end
        
        BodyVelocity.Velocity = velocity
    end
    
    -- Anti-Knockback
    if States.AntiKB then
        Root.Velocity = Vector3.new(0, Root.Velocity.Y, 0)
    end
    
    -- ESP
    if States.ESP then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player and player.Character then
                local highlight = player.Character:FindFirstChild("ACR_ESP") or Instance.new("Highlight")
                highlight.Name = "ACR_ESP"
                highlight.Enabled = true
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 100, 100)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Parent = player.Character
            end
        end
    end
    
    -- No-Clip
    if States.NoClip then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Auto-Clicker
    if States.AutoClicker then
        local tool = Character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
    end
    
    -- BRAINROT OTOMATİK FARM
    if BrainrotGame.IsBrainrot and BrainrotFeatures.AutoFarm then
        BrainrotAutoFarm()
    end
end)

-- INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if States.InfJump then
        Root.Velocity = Vector3.new(Root.Velocity.X, 50, Root.Velocity.Z)
    end
end)

-- BRAINROT AUTO FARM FUNCTION
function BrainrotAutoFarm()
    if not Character then return end
    
    -- Find nearest collectible/item
    local nearestPart = nil
    local nearestDistance = BrainrotGame.AutoClickRadius
    
    for _, item in pairs(Workspace:GetChildren()) do
        if item:IsA("BasePart") and (item.Name:lower():find("coin") or item.Name:lower():find("money") or 
           item.Name:lower():find("cash") or item.Name:lower():find("gem") or item.Name:lower():find("orb")) then
            local distance = (Root.Position - item.Position).Magnitude
            if distance < nearestDistance then
                nearestPart = item
                nearestDistance = distance
            end
        end
    end
    
    -- Move towards item
    if nearestPart then
        local direction = (nearestPart.Position - Root.Position).Unit
        Root.Velocity = direction * (BoostPower * BrainrotGame.FarmSpeed)
        
        -- Auto click if close enough
        if nearestDistance < 10 then
            local tool = Character:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
        end
    end
end

-- CHARACTER TRACKING
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Root = newChar:WaitForChild("HumanoidRootPart")
    Humanoid = newChar:WaitForChild("Humanoid")
    
    -- Reset states
    if States.Fly then
        DisableFly()
        States.Fly = false
    end
    
    if States.FreeCam then
        DisableFreeCam()
        States.FreeCam = false
    end
end)

-- INITIALIZE
print("╔══════════════════════════════════════════════╗")
print("║        ACR-HUB BRANIROT ULTIMATE EDITION     ║")
print("╚══════════════════════════════════════════════╝")
print("✓ Başarıyla Yüklendi!")
print("✓ INSERT tuşu ile menüyü aç/kapat")
print("✓ F tuşu ile uçuş modunu aç/kapat")
print("✓ C tuşu ile NoClip modunu aç/kapat")
print("✓ P tuşu ile FreeCam mouse kontrolü")
print("")
if BrainrotGame.IsBrainrot then
    print("🧠 BRAINROT MODU AKTİF!")
    print("✓ Auto Farm sistemi hazır")
    print("✓ 11 özel brainrot özelliği")
else
    print("⚡ GENEL MOD AKTİF")
    print("✓ 12 farklı hack modülü")
end
print("═══════════════════════════════════════════════")
