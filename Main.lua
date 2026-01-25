-- ACR HUB V39 - MODERN CUSTOMIZABLE TEAM CHECK & TARGET FIX
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Character, Root, Humanoid

-- RENK TEMASI
local Theme = {
    Primary = Color3.fromRGB(220, 20, 60),    -- Kırmızı (Ana renk)
    Secondary = Color3.fromRGB(30, 144, 255), -- Mavi (İkincil renk)
    Dark = Color3.fromRGB(10, 10, 15),        -- Koyu arkaplan
    Darker = Color3.fromRGB(5, 5, 10),        -- Daha koyu
    Light = Color3.fromRGB(240, 240, 245),    -- Açık metin
    Gray = Color3.fromRGB(40, 40, 50),        -- Gri alanlar
    Success = Color3.fromRGB(0, 200, 0),      -- Yeşil (başarı)
    Warning = Color3.fromRGB(255, 165, 0)     -- Turuncu (uyarı)
}

-- AUTO REFRESH CHARACTER
local function UpdateCharacterVars(char)
    Character = char or Player.Character
    if Character then
        Root = Character:WaitForChild("HumanoidRootPart", 5)
        Humanoid = Character:WaitForChild("Humanoid", 5)
        
        Humanoid.HealthChanged:Connect(function()
            local s_god = false
            for _, m in pairs(_G.CurrentConfig.Player) do if m.Tag == "GodMode" and m.State then s_god = true end end
            if s_god then Humanoid.Health = 100 end
        end)
    end
end
Player.CharacterAdded:Connect(UpdateCharacterVars)
UpdateCharacterVars(Player.Character)

-- GLOBAL DEĞİŞKENLER
_G.BoostPower = _G.BoostPower or 45
_G.TeamCheckActive = true
_G.ClickTPDistance = 100
_G.AimbotFOV = 100
_G.ESPColorMode = "Team" -- "Team", "Health", "Distance"

-- YENİ MODÜLLER İLE GÜNCELLENMİŞ CONFIG
_G.CurrentConfig = {
    Combat = {
        {Text = "🔫 Combat Lock", State = false, Key = Enum.KeyCode.G, Tag = "Aimbot", HasSettings = true, Icon = "🎯"},
        {Text = "💥 Super Knockback", State = false, Key = Enum.KeyCode.Y, Tag = "SuperKB", Icon = "⚡"},
        {Text = "🧱 Wall Hit", State = false, Key = Enum.KeyCode.L, Tag = "WallHit", Icon = "🔨"},
        {Text = "🎵 Baritone", State = false, Key = Enum.KeyCode.H, Tag = "Baritone", Icon = "🎼"},
        {Text = "🖱️ Auto Clicker", State = false, Key = Enum.KeyCode.K, Tag = "AutoClicker", Icon = "⚡", HasSettings = true},
        {Text = "🎯 Silent Aim", State = false, Key = Enum.KeyCode.P, Tag = "SilentAim", Icon = "🎯"},
        {Text = "🔫 Trigger Bot", State = false, Key = Enum.KeyCode.O, Tag = "TriggerBot", Icon = "🎯"}
    },
    Movement = {
        {Text = "🚀 Speed Bypass", State = false, Key = Enum.KeyCode.Z, Tag = "Bypass", HasSettings = true, Icon = "⚡"},
        {Text = "🔄 Inf Jump", State = false, Key = Enum.KeyCode.M, Tag = "InfJump", Icon = "⬆️"},
        {Text = "👻 No-Clip", State = false, Key = Enum.KeyCode.N, Tag = "NoClip", Icon = "👻"},
        {Text = "📍 Click TP", State = false, Key = Enum.KeyCode.I, Tag = "ClickTP", HasSettings = true, Icon = "📍"},
        {Text = "🛡️ Fly", State = false, Key = Enum.KeyCode.J, Tag = "Fly", Icon = "🕊️"},
        {Text = "🎯 AirStuck", State = false, Key = Enum.KeyCode.U, Tag = "AirStuck", Icon = "✈️"},
        {Text = "📐 Spiderman", State = false, Key = Enum.KeyCode.RightAlt, Tag = "Spiderman", Icon = "🕷️"}
    },
    Player = {
        {Text = "👑 God Mode+", State = false, Key = Enum.KeyCode.T, Tag = "GodMode", Icon = "👑"},
        {Text = "🌀 Anti-Aim", State = false, Key = Enum.KeyCode.F, Tag = "AntiAim", Icon = "🌀"},
        {Text = "🛡️ Anti-KB", State = false, Key = Enum.KeyCode.V, Tag = "AntiKB", Icon = "🛡️"},
        {Text = "📡 Fake Lag", State = false, Key = Enum.KeyCode.X, Tag = "FakeLag", HasSettings = true, Icon = "📡"},
        {Text = "🔒 Anti-Grab", State = false, Key = Enum.KeyCode.B, Tag = "AntiGrab", Icon = "🔒"},
        {Text = "👁️ X-Ray", State = false, Key = Enum.KeyCode.C, Tag = "XRay", Icon = "👁️"},
        {Text = "💨 No Slow", State = false, Key = Enum.KeyCode.LeftAlt, Tag = "NoSlow", Icon = "💨"}
    },
    Visuals = {
        {Text = "👁️ Player ESP", State = false, Key = Enum.KeyCode.C, Tag = "ESP", HasSettings = true, Icon = "👁️"},
        {Text = "📐 Tracers", State = false, Key = Enum.KeyCode.J, Tag = "Tracers", Icon = "📐"},
        {Text = "✨ Hand Glow", State = false, Key = Enum.KeyCode.U, Tag = "HandGlow", Icon = "✨"},
        {Text = "🎨 Chams", State = false, Key = Enum.KeyCode.B, Tag = "Chams", Icon = "🎨"},
        {Text = "⚡ Blink", State = false, Key = Enum.KeyCode.Q, Tag = "Blink", HasSettings = true, Icon = "⚡"},
        {Text = "🌈 Rainbow GUI", State = false, Key = Enum.KeyCode.R, Tag = "RainbowGUI", Icon = "🌈"},
        {Text = "🎭 Fullbright", State = false, Key = Enum.KeyCode.F, Tag = "Fullbright", Icon = "💡"}
    },
    Utility = {
        {Text = "📋 Server Info", State = false, Key = Enum.KeyCode.Insert, Tag = "ServerInfo", Icon = "📊"},
        {Text = "🎮 Anti-AFK", State = false, Key = Enum.KeyCode.End, Tag = "AntiAFK", Icon = "⏰"},
        {Text = "📸 Screenshot", State = false, Key = Enum.KeyCode.Print, Tag = "Screenshot", Icon = "📷"},
        {Text = "🔍 Zoom", State = false, Key = Enum.KeyCode.Z, Tag = "Zoom", Icon = "🔍"},
        {Text = "💾 Save Config", State = false, Key = Enum.KeyCode.F5, Tag = "SaveConfig", Icon = "💾"},
        {Text = "📂 Load Config", State = false, Key = Enum.KeyCode.F6, Tag = "LoadConfig", Icon = "📂"}
    }
}

-- MODERN GUI SETUP
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "ACR_HUB_V39_MODERN"
ScreenGui.ResetOnSpawn = false

-- ANA CONTAINER
local MainContainer = Instance.new("Frame", ScreenGui)
MainContainer.Size = UDim2.new(0, 900, 0, 500)
MainContainer.Position = UDim2.new(0.5, -450, 0.5, -250)
MainContainer.BackgroundColor3 = Theme.Dark
MainContainer.BorderSizePixel = 0
MainContainer.ClipsDescendants = true

-- KÖŞE YUVARLAKLIĞI
local UICorner = Instance.new("UICorner", MainContainer)
UICorner.CornerRadius = UDim.new(0, 12)

-- GÖLGE EFEKTİ
local DropShadow = Instance.new("ImageLabel", MainContainer)
DropShadow.Name = "DropShadow"
DropShadow.BackgroundTransparency = 1
DropShadow.Position = UDim2.new(0, -15, 0, -15)
DropShadow.Size = UDim2.new(1, 30, 1, 30)
DropShadow.Image = "rbxassetid://6015897843"
DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
DropShadow.ImageTransparency = 0.5
DropShadow.ScaleType = Enum.ScaleType.Slice
DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
DropShadow.ZIndex = -1

-- HEADER
local Header = Instance.new("Frame", MainContainer)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Theme.Darker
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔮 ACR HUB V39 | MODERN EDITION"
Title.TextColor3 = Theme.Light
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left

local Version = Instance.new("TextLabel", Header)
Version.Size = UDim2.new(0, 100, 0, 20)
Version.Position = UDim2.new(1, -120, 0, 15)
Version.BackgroundTransparency = 1
Version.Text = "v39.0.1"
Version.TextColor3 = Theme.Secondary
Version.Font = Enum.Font.GothamMedium
Version.TextSize = 14

-- STATUS BAR
local StatusBar = Instance.new("Frame", Header)
StatusBar.Size = UDim2.new(0, 200, 0, 4)
StatusBar.Position = UDim2.new(0, 20, 1, -8)
StatusBar.BackgroundColor3 = Theme.Gray
StatusBar.BorderSizePixel = 0

local StatusFill = Instance.new("Frame", StatusBar)
StatusFill.Size = UDim2.new(0.75, 0, 1, 0)
StatusFill.BackgroundColor3 = Theme.Primary
StatusFill.BorderSizePixel = 0

-- İÇERİK ALANI
local Content = Instance.new("Frame", MainContainer)
Content.Size = UDim2.new(1, -20, 1, -70)
Content.Position = UDim2.new(0, 10, 0, 60)
Content.BackgroundTransparency = 1

-- TAB SİSTEMİ
local Tabs = {"Combat", "Movement", "Player", "Visuals", "Utility"}
local TabButtons = {}
local TabFrames = {}

local TabContainer = Instance.new("Frame", Content)
TabContainer.Size = UDim2.new(0, 150, 1, 0)
TabContainer.BackgroundTransparency = 1

local ModulesContainer = Instance.new("Frame", Content)
ModulesContainer.Size = UDim2.new(1, -160, 1, 0)
ModulesContainer.Position = UDim2.new(0, 160, 0, 0)
ModulesContainer.BackgroundTransparency = 1

-- TAB BUTONLARI
for i, tabName in ipairs(Tabs) do
    local TabButton = Instance.new("TextButton", TabContainer)
    TabButton.Size = UDim2.new(1, 0, 0, 40)
    TabButton.Position = UDim2.new(0, 0, 0, (i-1)*45)
    TabButton.BackgroundColor3 = Theme.Darker
    TabButton.Text = "  " .. tabName
    TabButton.TextColor3 = Theme.Light
    TabButton.Font = Enum.Font.GothamMedium
    TabButton.TextSize = 14
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.BorderSizePixel = 0
    
    local TabCorner = Instance.new("UICorner", TabButton)
    TabCorner.CornerRadius = UDim.new(0, 8)
    
    local TabIcon = Instance.new("TextLabel", TabButton)
    TabIcon.Size = UDim2.new(0, 20, 1, 0)
    TabIcon.Position = UDim2.new(1, -25, 0, 0)
    TabIcon.BackgroundTransparency = 1
    TabIcon.Text = i == 1 and "⚔️" or i == 2 and "🏃" or i == 3 and "👤" or i == 4 and "👁️" or "🛠️"
    TabIcon.TextColor3 = Theme.Secondary
    TabIcon.Font = Enum.Font.GothamBold
    TabIcon.TextSize = 16
    
    TabButtons[tabName] = TabButton
    
    -- MODÜL FRAME'İ
    local TabFrame = Instance.new("ScrollingFrame", ModulesContainer)
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.ScrollBarThickness = 4
    TabFrame.ScrollBarImageColor3 = Theme.Primary
    TabFrame.Visible = i == 1
    TabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local ModuleList = Instance.new("UIListLayout", TabFrame)
    ModuleList.Padding = UDim.new(0, 10)
    
    TabFrames[tabName] = TabFrame
    
    TabButton.MouseButton1Click:Connect(function()
        for _, frame in pairs(TabFrames) do
            frame.Visible = false
        end
        TabFrame.Visible = true
        
        for _, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = Theme.Darker
            btn.TextColor3 = Theme.Light
        end
        TabButton.BackgroundColor3 = Theme.Primary
        TabButton.TextColor3 = Color3.new(1, 1, 1)
    end)
    
    if i == 1 then
        TabButton.BackgroundColor3 = Theme.Primary
        TabButton.TextColor3 = Color3.new(1, 1, 1)
    end
end

-- MODÜL KARTLARI OLUŞTURMA
local SpeedDisplayLabel

local function CreateModuleCard(parent, module)
    local Card = Instance.new("Frame", parent)
    Card.Size = UDim2.new(0, 200, 0, 80)
    Card.BackgroundColor3 = Theme.Darker
    Card.BorderSizePixel = 0
    
    local CardCorner = Instance.new("UICorner", Card)
    CardCorner.CornerRadius = UDim.new(0, 10)
    
    local TopBar = Instance.new("Frame", Card)
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.BackgroundColor3 = Theme.Gray
    TopBar.BorderSizePixel = 0
    
    local TopCorner = Instance.new("UICorner", TopBar)
    TopCorner.CornerRadius = UDim.new(0, 10, 0, 0)
    
    local Icon = Instance.new("TextLabel", TopBar)
    Icon.Size = UDim2.new(0, 30, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = module.Icon or "⚙️"
    Icon.TextColor3 = Theme.Secondary
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 16
    
    local Title = Instance.new("TextLabel", TopBar)
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 35, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = module.Text
    Title.TextColor3 = Theme.Light
    Title.Font = Enum.Font.GothamMedium
    Title.TextSize = 12
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleButton = Instance.new("TextButton", Card)
    ToggleButton.Size = UDim2.new(0, 60, 0, 25)
    ToggleButton.Position = UDim2.new(0, 15, 1, -35)
    ToggleButton.BackgroundColor3 = module.State and Theme.Success or Color3.fromRGB(100, 0, 0)
    ToggleButton.Text = module.State and "ON" or "OFF"
    ToggleButton.TextColor3 = Color3.new(1, 1, 1)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextSize = 12
    ToggleButton.BorderSizePixel = 0
    
    local ToggleCorner = Instance.new("UICorner", ToggleButton)
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    
    local KeybindButton = Instance.new("TextButton", Card)
    KeybindButton.Size = UDim2.new(0, 80, 0, 25)
    KeybindButton.Position = UDim2.new(1, -95, 1, -35)
    KeybindButton.BackgroundColor3 = Theme.Gray
    KeybindButton.Text = "["..module.Key.Name.."]"
    KeybindButton.TextColor3 = Theme.Light
    KeybindButton.Font = Enum.Font.GothamMedium
    KeybindButton.TextSize = 11
    KeybindButton.BorderSizePixel = 0
    
    local KeybindCorner = Instance.new("UICorner", KeybindButton)
    KeybindCorner.CornerRadius = UDim.new(0, 6)
    
    -- TOGGLE FUNCTIONALITY
    ToggleButton.MouseButton1Click:Connect(function()
        module.State = not module.State
        ToggleButton.BackgroundColor3 = module.State and Theme.Success or Color3.fromRGB(100, 0, 0)
        ToggleButton.Text = module.State and "ON" or "OFF"
        
        -- Özel efekt
        local ripple = Instance.new("Frame", ToggleButton)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.BackgroundColor3 = module.State and Theme.Success or Color3.fromRGB(200, 0, 0)
        ripple.BackgroundTransparency = 0.5
        ripple.BorderSizePixel = 0
        
        local rippleCorner = Instance.new("UICorner", ripple)
        rippleCorner.CornerRadius = UDim.new(1, 0)
        
        TweenService:Create(ripple, TweenInfo.new(0.3), {
            Size = UDim2.new(2, 0, 2, 0),
            Position = UDim2.new(-0.5, 0, -0.5, 0),
            BackgroundTransparency = 1
        }):Play()
        
        game:GetService("Debris"):AddItem(ripple, 0.3)
    end)
    
    -- KEYBIND FUNCTIONALITY
    KeybindButton.MouseButton1Click:Connect(function()
        KeybindButton.Text = "[...]"
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                module.Key = (input.KeyCode == Enum.KeyCode.Escape) and module.Key or input.KeyCode
                KeybindButton.Text = "["..module.Key.Name.."]"
                conn:Disconnect()
            end
        end)
    end)
    
    -- SETTINGS BUTTON
    if module.HasSettings then
        local SettingsButton = Instance.new("TextButton", Card)
        SettingsButton.Size = UDim2.new(0, 30, 0, 30)
        SettingsButton.Position = UDim2.new(1, -35, 0, 5)
        SettingsButton.BackgroundColor3 = Theme.Gray
        SettingsButton.Text = "⚙️"
        SettingsButton.TextColor3 = Theme.Light
        SettingsButton.Font = Enum.Font.GothamBold
        SettingsButton.TextSize = 14
        SettingsButton.BorderSizePixel = 0
        
        local SettingsCorner = Instance.new("UICorner", SettingsButton)
        SettingsCorner.CornerRadius = UDim.new(1, 0)
        
        -- SETTINGS PANEL
        local SettingsPanel = Instance.new("Frame", ScreenGui)
        SettingsPanel.Size = UDim2.new(0, 300, 0, 200)
        SettingsPanel.Position = UDim2.new(0.5, -150, 0.5, -100)
        SettingsPanel.BackgroundColor3 = Theme.Dark
        SettingsPanel.BorderSizePixel = 0
        SettingsPanel.Visible = false
        SettingsPanel.ZIndex = 100
        
        local PanelCorner = Instance.new("UICorner", SettingsPanel)
        PanelCorner.CornerRadius = UDim.new(0, 12)
        
        local PanelShadow = Instance.new("ImageLabel", SettingsPanel)
        PanelShadow.Name = "PanelShadow"
        PanelShadow.BackgroundTransparency = 1
        PanelShadow.Position = UDim2.new(0, -15, 0, -15)
        PanelShadow.Size = UDim2.new(1, 30, 1, 30)
        PanelShadow.Image = "rbxassetid://6015897843"
        PanelShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        PanelShadow.ImageTransparency = 0.5
        PanelShadow.ScaleType = Enum.ScaleType.Slice
        PanelShadow.SliceCenter = Rect.new(49, 49, 450, 450)
        PanelShadow.ZIndex = 99
        
        SettingsButton.MouseButton1Click:Connect(function()
            SettingsPanel.Visible = not SettingsPanel.Visible
            UpdateSettingsPanel(SettingsPanel, module)
        end)
    end
    
    return Card
end

-- AYAR PANELİ GÜNCELLEME
local function UpdateSettingsPanel(panel, module)
    for _, child in pairs(panel:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    local Title = Instance.new("TextLabel", panel)
    Title.Size = UDim2.new(1, -20, 0, 40)
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = module.Text .. " Settings"
    Title.TextColor3 = Theme.Light
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    
    -- MODÜL AYARLARI
    if module.Tag == "Aimbot" then
        local teamBtn = Instance.new("TextButton", panel)
        teamBtn.Size = UDim2.new(0.9, 0, 0, 30)
        teamBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
        teamBtn.BackgroundColor3 = _G.TeamCheckActive and Theme.Success or Color3.fromRGB(100, 0, 0)
        teamBtn.Font = Enum.Font.GothamMedium
        teamBtn.TextSize = 12
        teamBtn.TextColor3 = Color3.new(1,1,1)
        teamBtn.Text = _G.TeamCheckActive and "Team Check: ON" or "Team Check: OFF"
        
        teamBtn.MouseButton1Click:Connect(function()
            _G.TeamCheckActive = not _G.TeamCheckActive
            teamBtn.BackgroundColor3 = _G.TeamCheckActive and Theme.Success or Color3.fromRGB(100, 0, 0)
            teamBtn.Text = _G.TeamCheckActive and "Team Check: ON" or "Team Check: OFF"
        end)
        
        -- FOV Ayarı
        local fovText = Instance.new("TextLabel", panel)
        fovText.Size = UDim2.new(0.9, 0, 0, 20)
        fovText.Position = UDim2.new(0.05, 0, 0.5, 0)
        fovText.BackgroundTransparency = 1
        fovText.Text = "FOV: " .. _G.AimbotFOV
        fovText.TextColor3 = Theme.Light
        fovText.Font = Enum.Font.GothamMedium
        fovText.TextSize = 12
        
        local fovSlider = Instance.new("Frame", panel)
        fovSlider.Size = UDim2.new(0.8, 0, 0, 6)
        fovSlider.Position = UDim2.new(0.1, 0, 0.7, 0)
        fovSlider.BackgroundColor3 = Theme.Gray
        
        local fovFill = Instance.new("Frame", fovSlider)
        fovFill.Size = UDim2.new(_G.AimbotFOV/360, 0, 1, 0)
        fovFill.BackgroundColor3 = Theme.Primary
        fovFill.BorderSizePixel = 0
        
        local sliderBtn = Instance.new("TextButton", fovSlider)
        sliderBtn.Size = UDim2.new(1, 0, 2, 0)
        sliderBtn.Position = UDim2.new(0, 0, -0.5, 0)
        sliderBtn.BackgroundTransparency = 1
        sliderBtn.Text = ""
        
        sliderBtn.MouseButton1Down:Connect(function()
            local move
            move = RunService.RenderStepped:Connect(function()
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    local p = math.clamp((UserInputService:GetMouseLocation().X - fovSlider.AbsolutePosition.X) / fovSlider.AbsoluteSize.X, 0, 1)
                    _G.AimbotFOV = math.floor(30 + (p * 330))
                    fovText.Text = "FOV: " .. _G.AimbotFOV
                    fovFill.Size = UDim2.new(_G.AimbotFOV/360, 0, 1, 0)
                else
                    move:Disconnect()
                end
            end)
        end)
    end
    
    -- Diğer modül ayarları buraya eklenebilir...
end

-- TÜM MODÜLLERİ OLUŞTUR
for categoryName, modules in pairs(_G.CurrentConfig) do
    local tabFrame = TabFrames[categoryName]
    if tabFrame then
        for _, module in pairs(modules) do
            CreateModuleCard(tabFrame, module)
        end
    end
end

-- KAPATMA BUTONU
local CloseButton = Instance.new("TextButton", MainContainer)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 20
CloseButton.BorderSizePixel = 0

local CloseCorner = Instance.new("UICorner", CloseButton)
CloseCorner.CornerRadius = UDim.new(1, 0)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- SÜRÜKLEME FONKSİYONU
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainContainer.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- TOGGLE GUI KOMUTU
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainContainer.Visible = not MainContainer.Visible
    end
end)

-- RAINBOW GUI EFFECT
local rainbowConnections = {}
local function ToggleRainbowGUI(state)
    if state then
        local hue = 0
        local conn = RunService.RenderStepped:Connect(function()
            hue = (hue + 0.01) % 1
            local color = Color3.fromHSV(hue, 0.8, 1)
            
            -- Header rengini değiştir
            Header.BackgroundColor3 = color
            
            -- Aktif tab rengini değiştir
            for _, btn in pairs(TabButtons) do
                if btn.BackgroundColor3 == Theme.Primary then
                    btn.BackgroundColor3 = color
                end
            end
            
            -- Toggle butonlarını güncelle
            for _, module in pairs(_G.CurrentConfig.Visuals) do
                if module.Tag == "RainbowGUI" and module.State then
                    Theme.Primary = color
                    Theme.Secondary = Color3.fromHSV((hue + 0.5) % 1, 0.8, 1)
                end
            end
        end)
        table.insert(rainbowConnections, conn)
    else
        for _, conn in pairs(rainbowConnections) do
            conn:Disconnect()
        end
        rainbowConnections = {}
        Header.BackgroundColor3 = Theme.Darker
    end
end

-- GAME LOOP
RunService.Heartbeat:Connect(function()
    if not Root or not Humanoid then return end
    
    -- Modül durumlarını kontrol et
    local states = {}
    for _, cat in pairs(_G.CurrentConfig) do
        for _, m in pairs(cat) do
            states[m.Tag] = m.State
        end
    end
    
    -- Rainbow GUI kontrolü
    if states.RainbowGUI ~= nil then
        ToggleRainbowGUI(states.RainbowGUI)
    end
    
    -- GOD MODE
    if states.GodMode then
        Humanoid.Health = 100
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    else
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
    end

    -- HIZ BYPASS
    if states.Bypass and Humanoid.MoveDirection.Magnitude > 0 then
        Root.Velocity = Vector3.new(
            Humanoid.MoveDirection.X * _G.BoostPower,
            Root.Velocity.Y,
            Humanoid.MoveDirection.Z * _G.BoostPower
        )
    end
    
    -- NO-CLIP
    if states.NoClip then
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
    
    -- ANTI-AIM
    if states.AntiAim then
        Root.CFrame = Root.CFrame * CFrame.Angles(0, math.rad(45), 0)
    end
    
    -- ANTI-KB
    if states.AntiKB then
        Root.Velocity = Vector3.new(0, Root.Velocity.Y, 0)
    end
    
    -- FLY (Yeni özellik)
    if states.Fly then
        local direction = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end
        
        if direction.Magnitude > 0 then
            direction = direction.Unit * 50
            Root.Velocity = Vector3.new(direction.X, 0, direction.Z)
            Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        end
    end
    
    -- ESP
    if states.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hl = p.Character:FindFirstChild("ACR_ESP") or Instance.new("Highlight", p.Character)
                hl.Name = "ACR_ESP"
                
                -- ESP renk moduna göre renk belirle
                if _G.ESPColorMode == "Team" then
                    hl.FillColor = (p.Team ~= Player.Team) and Theme.Primary or Theme.Success
                elseif _G.ESPColorMode == "Health" then
                    local health = p.Character.Humanoid.Health / p.Character.Humanoid.MaxHealth
                    hl.FillColor = Color3.new(1 - health, health, 0)
                else -- Distance
                    local dist = (p.Character.HumanoidRootPart.Position - Root.Position).Magnitude
                    local intensity = math.clamp(1 - (dist / 500), 0, 1)
                    hl.FillColor = Color3.new(1, intensity, 0)
                end
                
                hl.FillTransparency = 0.3
                hl.OutlineColor = Color3.new(1, 1, 1)
                hl.OutlineTransparency = 0
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("ACR_ESP") then
                p.Character.ACR_ESP:Destroy()
            end
        end
    end
    
    -- FULLBRIGHT
    if states.Fullbright then
        game.Lighting.Brightness = 2
        game.Lighting.ClockTime = 14
        game.Lighting.FogEnd = 100000
    else
        game.Lighting.Brightness = 1
    end
end)

-- INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    for _, m in pairs(_G.CurrentConfig.Movement) do
        if m.Tag == "InfJump" and m.State and Root then
            Root.Velocity = Vector3.new(Root.Velocity.X, 50, Root.Velocity.Z)
            break
        end
    end
end)

-- KEY BINDINGS
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    for _, cat in pairs(_G.CurrentConfig) do
        for _, mod in pairs(cat) do
            if mod.Key ~= Enum.KeyCode.Unknown and input.KeyCode == mod.Key then
                mod.State = not mod.State
                
                -- GUI'de güncelleme
                for _, tabFrame in pairs(TabFrames) do
                    for _, card in pairs(tabFrame:GetChildren()) do
                        if card:IsA("Frame") then
                            for _, child in pairs(card:GetChildren()) do
                                if child:IsA("TextButton") and child.Text:find("ON") or child.Text:find("OFF") then
                                    if card:FindFirstChildOfClass("TextLabel") and 
                                       card:FindFirstChildOfClass("TextLabel").Text:find(mod.Text, 1, true) then
                                        child.BackgroundColor3 = mod.State and Theme.Success or Color3.fromRGB(100, 0, 0)
                                        child.Text = mod.State and "ON" or "OFF"
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                break
            end
        end
    end
end)

print("🎮 ACR HUB V39 - MODERN EDITION YÜKLENDİ!")
print("• Modern kırmızı-mavi tema")
print("• " .. #Tabs .. " kategori, " .. 
      (#_G.CurrentConfig.Combat + #_G.CurrentConfig.Movement + 
       #_G.CurrentConfig.Player + #_G.CurrentConfig.Visuals + 
       #_G.CurrentConfig.Utility) .. " modül")
print("• GUI'yi açmak/kapatmak için: RightShift")
print("• Discord: ACR Development")
