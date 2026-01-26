-- ACR HUB V39 - DARK MODERN VERSION WITH ANTI-STUN (FIXED)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Character, Root, Humanoid

-- KOYU RENK TEMASI
local Theme = {
    Primary = Color3.fromRGB(220, 20, 60),    -- Kırmızı
    Secondary = Color3.fromRGB(30, 144, 255), -- Mavi
    Dark = Color3.fromRGB(15, 15, 20),        -- Koyu arkaplan
    Darker = Color3.fromRGB(10, 10, 15),      -- Daha koyu
    Light = Color3.fromRGB(200, 200, 205),    -- Açık metin
    Gray = Color3.fromRGB(30, 30, 40),        -- Gri alanlar
    Success = Color3.fromRGB(0, 180, 0),      -- Yeşil
    Warning = Color3.fromRGB(230, 140, 0)     -- Turuncu
}

-- AUTO REFRESH CHARACTER (DÜZELTİLMİŞ)
local function UpdateCharacterVars(char)
    Character = char or Player.Character
    if Character then
        Root = Character:WaitForChild("HumanoidRootPart", 5)
        Humanoid = Character:FindFirstChild("Humanoid") -- WaitFirstChild yerine FindFirstChild
    end
end

Player.CharacterAdded:Connect(UpdateCharacterVars)
if Player.Character then 
    UpdateCharacterVars(Player.Character) 
end

-- GLOBAL DEĞİŞKENLER
_G.BoostPower = _G.BoostPower or 45
_G.TeamCheckActive = true
_G.ClickTPDistance = 100
_G.AimbotFOV = 100
_G.ESPColorMode = "Team"

-- YENİ: ANTI-STUN DEĞİŞKENLERİ
local LastStunCheck = 0
local AntiStunEnabled = false
local OriginalWalkSpeed = 16
local OriginalJumpPower = 50

-- MODÜL KONFİGÜRASYONU (ANTI-STUN EKLENDİ)
_G.CurrentConfig = {
    Combat = {
        {Text = "🔫 Combat Lock", State = false, Key = Enum.KeyCode.G, Tag = "Aimbot", HasSettings = true, Icon = "🎯"},
        {Text = "💥 Super Knockback", State = false, Key = Enum.KeyCode.Y, Tag = "SuperKB", Icon = "⚡"},
        {Text = "🧱 Wall Hit", State = false, Key = Enum.KeyCode.L, Tag = "WallHit", Icon = "🔨"},
        {Text = "🖱️ Auto Clicker", State = false, Key = Enum.KeyCode.K, Tag = "AutoClicker", Icon = "⚡", HasSettings = true},
        {Text = "🎯 Silent Aim", State = false, Key = Enum.KeyCode.P, Tag = "SilentAim", Icon = "🎯"}
    },
    Movement = {
        {Text = "🚀 Speed Bypass", State = false, Key = Enum.KeyCode.Z, Tag = "Bypass", HasSettings = true, Icon = "⚡"},
        {Text = "🔄 Inf Jump", State = false, Key = Enum.KeyCode.M, Tag = "InfJump", Icon = "⬆️"},
        {Text = "👻 No-Clip", State = false, Key = Enum.KeyCode.N, Tag = "NoClip", Icon = "👻"},
        {Text = "📍 Click TP", State = false, Key = Enum.KeyCode.I, Tag = "ClickTP", HasSettings = true, Icon = "📍"},
        {Text = "🕊️ Fly", State = false, Key = Enum.KeyCode.F, Tag = "Fly", Icon = "🕊️"},
        -- YENİ: ANTI-STUN MODÜLÜ
        {Text = "🛡️ Anti-Stun", State = false, Key = Enum.KeyCode.V, Tag = "AntiStun", Icon = "⚡"}
    },
    Player = {
        {Text = "👑 God Mode", State = false, Key = Enum.KeyCode.T, Tag = "GodMode", Icon = "👑"},
        {Text = "🌀 Anti-Aim", State = false, Key = Enum.KeyCode.X, Tag = "AntiAim", Icon = "🌀"},
        {Text = "🛡️ Anti-KB", State = false, Key = Enum.KeyCode.C, Tag = "AntiKB", Icon = "🛡️"},
        {Text = "👁️ X-Ray", State = false, Key = Enum.KeyCode.B, Tag = "XRay", Icon = "👁️"},
        {Text = "💨 No Slow", State = false, Key = Enum.KeyCode.H, Tag = "NoSlow", Icon = "💨"}
    },
    Visuals = {
        {Text = "👁️ Player ESP", State = false, Key = Enum.KeyCode.U, Tag = "ESP", HasSettings = true, Icon = "👁️"},
        {Text = "📐 Tracers", State = false, Key = Enum.KeyCode.J, Tag = "Tracers", Icon = "📐"},
        {Text = "✨ Hand Glow", State = false, Key = Enum.KeyCode.Y, Tag = "HandGlow", Icon = "✨"},
        {Text = "⚡ Blink", State = false, Key = Enum.KeyCode.Q, Tag = "Blink", HasSettings = true, Icon = "⚡"},
        {Text = "🌈 Rainbow GUI", State = false, Key = Enum.KeyCode.R, Tag = "RainbowGUI", Icon = "🌈"}
    }
}

-- ANTI-STUN FONKSİYONLARI
local function IsCharacterStunned()
    if not Character or not Humanoid then return false end
    
    -- Humanoid state kontrolü
    local state = Humanoid:GetState()
    local stunnedStates = {
        Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.Ragdoll,
        Enum.HumanoidStateType.GettingUp,
        Enum.HumanoidStateType.Flying,
        Enum.HumanoidStateType.Freefall,
        Enum.HumanoidStateType.Landed
    }
    
    for _, stunnedState in ipairs(stunnedStates) do
        if state == stunnedState then
            return true
        end
    end
    
    -- Velocity kontrolü (anormal hızda hareket)
    if Root then
        local velocity = Root.Velocity.Magnitude
        if velocity > 100 and Humanoid.MoveDirection.Magnitude < 0.1 then
            return true
        end
    end
    
    -- Sit ve Lay animasyonları kontrolü
    if Humanoid.Sit or Humanoid.PlatformStand then
        return true
    end
    
    return false
end

local function ApplyAntiStun()
    if not Character or not Humanoid or not Root then return end
    
    -- Humanoid state'leri bypass et
    Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    
    -- Collision'ı kaldır
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Velocity = Vector3.new(0, 0, 0)
            part.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
    
    -- Force field ekle
    if not Character:FindFirstChild("AntiStunForceField") then
        local forceField = Instance.new("ForceField")
        forceField.Name = "AntiStunForceField"
        forceField.Visible = false
        forceField.Parent = Character
    end
    
    -- Velocity'yi sıfırla
    Root.Velocity = Vector3.new(0, 0, 0)
    Root.RotVelocity = Vector3.new(0, 0, 0)
    
    -- WalkSpeed ve JumpPower'ı koru
    Humanoid.WalkSpeed = OriginalWalkSpeed
    Humanoid.JumpPower = OriginalJumpPower
end

local function RemoveAntiStun()
    if not Character then return end
    
    -- Force field'ı kaldır
    local forceField = Character:FindFirstChild("AntiStunForceField")
    if forceField then
        forceField:Destroy()
    end
    
    -- Collision'ı geri getir
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
    
    if Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
end

-- MODERN GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ACR_HUB_DARK"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- ANA CONTAINER
local MainContainer = Instance.new("Frame", ScreenGui)
MainContainer.Size = UDim2.new(0, 850, 0, 480)
MainContainer.Position = UDim2.new(0.5, -425, 0.5, -240)
MainContainer.BackgroundColor3 = Theme.Dark
MainContainer.BorderSizePixel = 0
MainContainer.ClipsDescendants = true

-- KÖŞE YUVARLAKLIĞI
local UICorner = Instance.new("UICorner", MainContainer)
UICorner.CornerRadius = UDim.new(0, 10)

-- GÖLGE
local DropShadow = Instance.new("ImageLabel", MainContainer)
DropShadow.BackgroundTransparency = 1
DropShadow.Position = UDim2.new(0, -10, 0, -10)
DropShadow.Size = UDim2.new(1, 20, 1, 20)
DropShadow.Image = "rbxassetid://6015897843"
DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
DropShadow.ImageTransparency = 0.6
DropShadow.ScaleType = Enum.ScaleType.Slice
DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
DropShadow.ZIndex = -1

-- HEADER
local Header = Instance.new("Frame", MainContainer)
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Theme.Darker
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 10, 0, 0)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔮 ACR HUB V39 | ANTI-STUN"
Title.TextColor3 = Theme.Light
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

local Status = Instance.new("TextLabel", Header)
Status.Size = UDim2.new(0, 120, 0, 20)
Status.Position = UDim2.new(1, -140, 0, 12)
Status.BackgroundTransparency = 1
Status.Text = "🟢 ONLINE"
Status.TextColor3 = Theme.Success
Status.Font = Enum.Font.GothamMedium
Status.TextSize = 12

-- TAB CONTAINER
local TabContainer = Instance.new("Frame", MainContainer)
TabContainer.Size = UDim2.new(0, 150, 1, -50)
TabContainer.Position = UDim2.new(0, 0, 0, 45)
TabContainer.BackgroundTransparency = 1

-- MODULES CONTAINER
local ModulesContainer = Instance.new("Frame", MainContainer)
ModulesContainer.Size = UDim2.new(1, -155, 1, -50)
ModulesContainer.Position = UDim2.new(0, 155, 0, 45)
ModulesContainer.BackgroundTransparency = 1

-- TAB SİSTEMİ
local Tabs = {"Combat", "Movement", "Player", "Visuals"}
local TabButtons = {}
local TabFrames = {}

for i, tabName in ipairs(Tabs) do
    -- TAB BUTON
    local TabButton = Instance.new("TextButton", TabContainer)
    TabButton.Size = UDim2.new(0.9, 0, 0, 40)
    TabButton.Position = UDim2.new(0.05, 0, 0, (i-1)*45)
    TabButton.BackgroundColor3 = i == 1 and Theme.Primary or Theme.Gray
    TabButton.Text = ""
    TabButton.BorderSizePixel = 0
    
    local TabCorner = Instance.new("UICorner", TabButton)
    TabCorner.CornerRadius = UDim.new(0, 8)
    
    local TabLabel = Instance.new("TextLabel", TabButton)
    TabLabel.Size = UDim2.new(1, -40, 1, 0)
    TabLabel.Position = UDim2.new(0, 10, 0, 0)
    TabLabel.BackgroundTransparency = 1
    TabLabel.Text = tabName
    TabLabel.TextColor3 = i == 1 and Color3.new(1,1,1) or Theme.Light
    TabLabel.Font = Enum.Font.GothamMedium
    TabLabel.TextSize = 13
    TabLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local TabIcon = Instance.new("TextLabel", TabButton)
    TabIcon.Size = UDim2.new(0, 30, 1, 0)
    TabIcon.Position = UDim2.new(1, -35, 0, 0)
    TabIcon.BackgroundTransparency = 1
    TabIcon.Text = i == 1 and "⚔️" or i == 2 and "🏃" or i == 3 and "👤" or "👁️"
    TabIcon.TextColor3 = i == 1 and Color3.new(1,1,1) or Theme.Secondary
    TabIcon.Font = Enum.Font.GothamBold
    TabIcon.TextSize = 16
    
    -- SCROLLING FRAME
    local TabFrame = Instance.new("ScrollingFrame", ModulesContainer)
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.ScrollBarThickness = 4
    TabFrame.ScrollBarImageColor3 = Theme.Primary
    TabFrame.Visible = i == 1
    TabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    
    local ModuleGrid = Instance.new("UIGridLayout", TabFrame)
    ModuleGrid.CellSize = UDim2.new(0, 200, 0, 90)
    ModuleGrid.CellPadding = UDim2.new(0, 10, 0, 10)
    ModuleGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left
    ModuleGrid.VerticalAlignment = Enum.VerticalAlignment.Top
    ModuleGrid.SortOrder = Enum.SortOrder.LayoutOrder
    
    TabButtons[tabName] = TabButton
    TabFrames[tabName] = TabFrame
    
    TabButton.MouseButton1Click:Connect(function()
        for _, frame in pairs(TabFrames) do
            frame.Visible = false
        end
        TabFrame.Visible = true
        
        for _, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = Theme.Gray
            if btn:FindFirstChildOfClass("TextLabel") then
                btn:FindFirstChildOfClass("TextLabel").TextColor3 = Theme.Light
            end
            if btn:FindFirstChildWhichIsA("TextLabel", true) then
                local icon = btn:FindFirstChildWhichIsA("TextLabel", true)
                if icon then icon.TextColor3 = Theme.Secondary end
            end
        end
        
        TabButton.BackgroundColor3 = Theme.Primary
        if TabLabel then TabLabel.TextColor3 = Color3.new(1,1,1) end
        if TabIcon then TabIcon.TextColor3 = Color3.new(1,1,1) end
    end)
end

-- MODÜL KARTI OLUŞTURMA FONKSİYONU
local function CreateModuleCard(parent, module)
    local Card = Instance.new("Frame", parent)
    Card.Size = UDim2.new(0, 200, 0, 90)
    Card.BackgroundColor3 = Theme.Darker
    Card.BorderSizePixel = 0
    
    local CardCorner = Instance.new("UICorner", Card)
    CardCorner.CornerRadius = UDim.new(0, 8)
    
    -- TOP BAR
    local TopBar = Instance.new("Frame", Card)
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.BackgroundColor3 = Theme.Gray
    TopBar.BorderSizePixel = 0
    
    local TopCorner = Instance.new("UICorner", TopBar)
    TopCorner.CornerRadius = UDim.new(0, 8, 0, 0)
    
    -- MODÜL İCON
    local Icon = Instance.new("TextLabel", TopBar)
    Icon.Size = UDim2.new(0, 30, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = module.Icon or "⚙️"
    Icon.TextColor3 = Theme.Secondary
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 16
    
    -- MODÜL ADI
    local ModuleName = Instance.new("TextLabel", TopBar)
    ModuleName.Size = UDim2.new(1, -35, 1, 0)
    ModuleName.Position = UDim2.new(0, 35, 0, 0)
    ModuleName.BackgroundTransparency = 1
    ModuleName.Text = module.Text
    ModuleName.TextColor3 = Theme.Light
    ModuleName.Font = Enum.Font.GothamMedium
    ModuleName.TextSize = 12
    ModuleName.TextXAlignment = Enum.TextXAlignment.Left
    
    -- TOGGLE BUTON
    local ToggleButton = Instance.new("TextButton", Card)
    ToggleButton.Size = UDim2.new(0, 70, 0, 28)
    ToggleButton.Position = UDim2.new(0, 10, 1, -40)
    ToggleButton.BackgroundColor3 = module.State and Theme.Success or Color3.fromRGB(80, 0, 0)
    ToggleButton.Text = module.State and "ENABLED" or "DISABLED"
    ToggleButton.TextColor3 = Color3.new(1, 1, 1)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextSize = 11
    ToggleButton.BorderSizePixel = 0
    
    local ToggleCorner = Instance.new("UICorner", ToggleButton)
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    
    -- KEYBIND BUTON
    local KeybindButton = Instance.new("TextButton", Card)
    KeybindButton.Size = UDim2.new(0, 70, 0, 28)
    KeybindButton.Position = UDim2.new(1, -80, 1, -40)
    KeybindButton.BackgroundColor3 = Theme.Gray
    KeybindButton.Text = "["..module.Key.Name.."]"
    KeybindButton.TextColor3 = Theme.Light
    KeybindButton.Font = Enum.Font.GothamMedium
    KeybindButton.TextSize = 11
    KeybindButton.BorderSizePixel = 0
    
    local KeybindCorner = Instance.new("UICorner", KeybindButton)
    KeybindCorner.CornerRadius = UDim.new(0, 6)
    
    -- SETTINGS BUTON
    local SettingsButton
    if module.HasSettings then
        SettingsButton = Instance.new("TextButton", Card)
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
    end
    
    -- TOGGLE FUNCTION
    ToggleButton.MouseButton1Click:Connect(function()
        module.State = not module.State
        ToggleButton.BackgroundColor3 = module.State and Theme.Success or Color3.fromRGB(80, 0, 0)
        ToggleButton.Text = module.State and "ENABLED" or "DISABLED"
        
        -- ANTI-STUN MODÜLÜ İÇİN ÖZEL KOD
        if module.Tag == "AntiStun" then
            AntiStunEnabled = module.State
            if not AntiStunEnabled then
                RemoveAntiStun()
            end
        end
    end)
    
    -- KEYBIND FUNCTION
    KeybindButton.MouseButton1Click:Connect(function()
        KeybindButton.Text = "[...]"
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Escape then
                    KeybindButton.Text = "["..module.Key.Name.."]"
                else
                    module.Key = input.KeyCode
                    KeybindButton.Text = "["..module.Key.Name.."]"
                end
                conn:Disconnect()
            end
        end)
    end)
    
    -- AYAR PANELİ
    if module.HasSettings and SettingsButton then
        local SettingsPanel = Instance.new("Frame")
        SettingsPanel.Size = UDim2.new(0, 300, 0, 200)
        SettingsPanel.Position = UDim2.new(0.5, -150, 0.5, -100)
        SettingsPanel.BackgroundColor3 = Theme.Darker
        SettingsPanel.BorderSizePixel = 0
        SettingsPanel.Visible = false
        SettingsPanel.ZIndex = 100
        SettingsPanel.Parent = ScreenGui
        
        local PanelCorner = Instance.new("UICorner", SettingsPanel)
        PanelCorner.CornerRadius = UDim.new(0, 10)
        
        local PanelShadow = Instance.new("ImageLabel", SettingsPanel)
        PanelShadow.BackgroundTransparency = 1
        PanelShadow.Position = UDim2.new(0, -10, 0, -10)
        PanelShadow.Size = UDim2.new(1, 20, 1, 20)
        PanelShadow.Image = "rbxassetid://6015897843"
        PanelShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        PanelShadow.ImageTransparency = 0.7
        PanelShadow.ScaleType = Enum.ScaleType.Slice
        PanelShadow.SliceCenter = Rect.new(49, 49, 450, 450)
        PanelShadow.ZIndex = 99
        
        -- PANEL BAŞLIĞI
        local PanelTitle = Instance.new("TextLabel", SettingsPanel)
        PanelTitle.Size = UDim2.new(1, 0, 0, 40)
        PanelTitle.BackgroundColor3 = Theme.Gray
        PanelTitle.Text = module.Text .. " Settings"
        PanelTitle.TextColor3 = Color3.new(1, 1, 1)
        PanelTitle.Font = Enum.Font.GothamBold
        PanelTitle.TextSize = 16
        PanelTitle.BorderSizePixel = 0
        
        local TitleCorner = Instance.new("UICorner", PanelTitle)
        TitleCorner.CornerRadius = UDim.new(0, 10, 0, 0)
        
        -- KAPATMA BUTONU
        local CloseButton = Instance.new("TextButton", PanelTitle)
        CloseButton.Size = UDim2.new(0, 30, 0, 30)
        CloseButton.Position = UDim2.new(1, -35, 0, 5)
        CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        CloseButton.Text = "×"
        CloseButton.TextColor3 = Color3.new(1, 1, 1)
        CloseButton.Font = Enum.Font.GothamBold
        CloseButton.TextSize = 20
        CloseButton.BorderSizePixel = 0
        
        local CloseCorner = Instance.new("UICorner", CloseButton)
        CloseCorner.CornerRadius = UDim.new(1, 0)
        
        CloseButton.MouseButton1Click:Connect(function()
            SettingsPanel.Visible = false
        end)
        
        -- İÇERİK ALANI
        local Content = Instance.new("Frame", SettingsPanel)
        Content.Size = UDim2.new(1, -20, 1, -60)
        Content.Position = UDim2.new(0, 10, 0, 50)
        Content.BackgroundTransparency = 1
        
        local ContentList = Instance.new("UIListLayout", Content)
        ContentList.Padding = UDim.new(0, 10)
        
        SettingsButton.MouseButton1Click:Connect(function()
            -- İçeriği temizle
            for _, child in pairs(Content:GetChildren()) do
                if not child:IsA("UIListLayout") then
                    child:Destroy()
                end
            end
            
            -- AYARLARI YÜKLE
            if module.Tag == "Aimbot" then
                -- Team Check
                local teamCheck = Instance.new("TextButton", Content)
                teamCheck.Size = UDim2.new(1, 0, 0, 35)
                teamCheck.BackgroundColor3 = _G.TeamCheckActive and Theme.Success or Color3.fromRGB(80, 0, 0)
                teamCheck.Text = _G.TeamCheckActive and "Team Check: ON" or "Team Check: OFF"
                teamCheck.TextColor3 = Color3.new(1,1,1)
                teamCheck.Font = Enum.Font.GothamMedium
                teamCheck.TextSize = 12
                teamCheck.BorderSizePixel = 0
                
                local teamCorner = Instance.new("UICorner", teamCheck)
                teamCorner.CornerRadius = UDim.new(0, 6)
                
                teamCheck.MouseButton1Click:Connect(function()
                    _G.TeamCheckActive = not _G.TeamCheckActive
                    teamCheck.BackgroundColor3 = _G.TeamCheckActive and Theme.Success or Color3.fromRGB(80, 0, 0)
                    teamCheck.Text = _G.TeamCheckActive and "Team Check: ON" or "Team Check: OFF"
                end)
                
                -- FOV Slider
                local fovLabel = Instance.new("TextLabel", Content)
                fovLabel.Size = UDim2.new(1, 0, 0, 20)
                fovLabel.BackgroundTransparency = 1
                fovLabel.Text = "FOV: " .. _G.AimbotFOV
                fovLabel.TextColor3 = Theme.Light
                fovLabel.Font = Enum.Font.GothamMedium
                fovLabel.TextSize = 12
                fovLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local fovSlider = Instance.new("Frame", Content)
                fovSlider.Size = UDim2.new(1, 0, 0, 6)
                fovSlider.BackgroundColor3 = Theme.Gray
                fovSlider.BorderSizePixel = 0
                
                local fovCorner = Instance.new("UICorner", fovSlider)
                fovCorner.CornerRadius = UDim.new(1, 0)
                
                local fovFill = Instance.new("Frame", fovSlider)
                fovFill.Size = UDim2.new(_G.AimbotFOV/360, 0, 1, 0)
                fovFill.BackgroundColor3 = Theme.Primary
                fovFill.BorderSizePixel = 0
                
                local fovFillCorner = Instance.new("UICorner", fovFill)
                fovFillCorner.CornerRadius = UDim.new(1, 0)
                
                local sliderBtn = Instance.new("TextButton", fovSlider)
                sliderBtn.Size = UDim2.new(1, 0, 2, 0)
                sliderBtn.Position = UDim2.new(0, 0, -0.5, 0)
                sliderBtn.BackgroundTransparency = 1
                sliderBtn.Text = ""
                
                sliderBtn.MouseButton1Down:Connect(function()
                    local move
                    move = RunService.RenderStepped:Connect(function()
                        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                            local mouseX = UserInputService:GetMouseLocation().X
                            local sliderX = fovSlider.AbsolutePosition.X
                            local sliderWidth = fovSlider.AbsoluteSize.X
                            local p = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
                            _G.AimbotFOV = math.floor(30 + (p * 330))
                            fovLabel.Text = "FOV: " .. _G.AimbotFOV
                            fovFill.Size = UDim2.new(_G.AimbotFOV/360, 0, 1, 0)
                        else
                            move:Disconnect()
                        end
                    end)
                end)
                
            elseif module.Tag == "Bypass" then
                -- Speed Slider
                local speedLabel = Instance.new("TextLabel", Content)
                speedLabel.Size = UDim2.new(1, 0, 0, 20)
                speedLabel.BackgroundTransparency = 1
                speedLabel.Text = "Speed Power: " .. _G.BoostPower
                speedLabel.TextColor3 = Theme.Light
                speedLabel.Font = Enum.Font.GothamMedium
                speedLabel.TextSize = 12
                speedLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local speedSlider = Instance.new("Frame", Content)
                speedSlider.Size = UDim2.new(1, 0, 0, 6)
                speedSlider.BackgroundColor3 = Theme.Gray
                speedSlider.BorderSizePixel = 0
                
                local speedCorner = Instance.new("UICorner", speedSlider)
                speedCorner.CornerRadius = UDim.new(1, 0)
                
                local speedFill = Instance.new("Frame", speedSlider)
                speedFill.Size = UDim2.new(_G.BoostPower/200, 0, 1, 0)
                speedFill.BackgroundColor3 = Theme.Secondary
                speedFill.BorderSizePixel = 0
                
                local speedFillCorner = Instance.new("UICorner", speedFill)
                speedFillCorner.CornerRadius = UDim.new(1, 0)
                
                local sliderBtn = Instance.new("TextButton", speedSlider)
                sliderBtn.Size = UDim2.new(1, 0, 2, 0)
                sliderBtn.Position = UDim2.new(0, 0, -0.5, 0)
                sliderBtn.BackgroundTransparency = 1
                sliderBtn.Text = ""
                
                sliderBtn.MouseButton1Down:Connect(function()
                    local move
                    move = RunService.RenderStepped:Connect(function()
                        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                            local mouseX = UserInputService:GetMouseLocation().X
                            local sliderX = speedSlider.AbsolutePosition.X
                            local sliderWidth = speedSlider.AbsoluteSize.X
                            local p = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
                            _G.BoostPower = math.floor(16 + (p * 184))
                            speedLabel.Text = "Speed Power: " .. _G.BoostPower
                            speedFill.Size = UDim2.new(_G.BoostPower/200, 0, 1, 0)
                        else
                            move:Disconnect()
                        end
                    end)
                end)
                
            elseif module.Tag == "ESP" then
                -- ESP Color Mode
                local modeLabel = Instance.new("TextLabel", Content)
                modeLabel.Size = UDim2.new(1, 0, 0, 20)
                modeLabel.BackgroundTransparency = 1
                modeLabel.Text = "Color Mode: " .. _G.ESPColorMode
                modeLabel.TextColor3 = Theme.Light
                modeLabel.Font = Enum.Font.GothamMedium
                modeLabel.TextSize = 12
                modeLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local modeButton = Instance.new("TextButton", Content)
                modeButton.Size = UDim2.new(1, 0, 0, 35)
                modeButton.BackgroundColor3 = Theme.Primary
                modeButton.Text = "Change Mode"
                modeButton.TextColor3 = Color3.new(1,1,1)
                modeButton.Font = Enum.Font.GothamMedium
                modeButton.TextSize = 12
                modeButton.BorderSizePixel = 0
                
                local modeCorner = Instance.new("UICorner", modeButton)
                modeCorner.CornerRadius = UDim.new(0, 6)
                
                modeButton.MouseButton1Click:Connect(function()
                    local modes = {"Team", "Health", "Distance"}
                    local currentIndex = table.find(modes, _G.ESPColorMode) or 1
                    local nextIndex = currentIndex % #modes + 1
                    _G.ESPColorMode = modes[nextIndex]
                    modeLabel.Text = "Color Mode: " .. _G.ESPColorMode
                end)
            end
            
            SettingsPanel.Visible = true
        end)
    end
    
    return Card
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

-- GUI TOGGLE BUTONU
local ToggleButton = Instance.new("TextButton", MainContainer)
ToggleButton.Size = UDim2.new(0, 30, 0, 30)
ToggleButton.Position = UDim2.new(1, -35, 0, 10)
ToggleButton.BackgroundColor3 = Theme.Primary
ToggleButton.Text = "×"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 20
ToggleButton.BorderSizePixel = 0

local ToggleCorner = Instance.new("UICorner", ToggleButton)
ToggleCorner.CornerRadius = UDim.new(1, 0)

ToggleButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- SÜRÜKLEME SİSTEMİ
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

-- GUI AÇ/KAPA TUŞU
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainContainer.Visible = not MainContainer.Visible
    end
end)

-- BAŞLANGIÇTA ORJİNAL DEĞERLERİ KAYDET
task.spawn(function()
    repeat
        task.wait(0.1)
    until Humanoid
    
    if Humanoid then
        OriginalWalkSpeed = Humanoid.WalkSpeed
        OriginalJumpPower = Humanoid.JumpPower
    end
end)

-- ANA OYUN LOOP'U (ANTI-STUN İLE BİRLİKTE)
RunService.Heartbeat:Connect(function(delta)
    if not Character or not Humanoid or not Root then return end
    
    -- Modül durumlarını kontrol et
    local states = {}
    for _, cat in pairs(_G.CurrentConfig) do
        for _, m in pairs(cat) do
            states[m.Tag] = m.State
        end
    end
    
    -- ANTI-STUN SİSTEMİ
    if states.AntiStun then
        AntiStunEnabled = true
        if IsCharacterStunned() then
            ApplyAntiStun()
        end
    else
        AntiStunEnabled = false
        RemoveAntiStun()
    end
    
    -- GOD MODE
    if states.GodMode then
        Humanoid.Health = Humanoid.MaxHealth
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
    
    -- NO SLOW
    if states.NoSlow then
        Humanoid.WalkSpeed = OriginalWalkSpeed
        Humanoid.JumpPower = OriginalJumpPower
    end
    
    -- FLY
    if states.Fly then
        local direction = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end
        
        if direction.Magnitude > 0 then
            direction = direction.Unit * 100
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
    
    -- X-RAY
    if states.XRay then
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 0.5 then
                part.LocalTransparencyModifier = 0.5
            end
        end
    else
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 0
            end
        end
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
                
                -- GUI'de güncelle
                for _, tabFrame in pairs(TabFrames) do
                    for _, card in pairs(tabFrame:GetChildren()) do
                        if card:IsA("Frame") then
                            for _, child in pairs(card:GetChildren()) do
                                if child:IsA("TextButton") and (child.Text == "ENABLED" or child.Text == "DISABLED") then
                                    if card:FindFirstChildOfClass("TextLabel") and 
                                       card:FindFirstChildOfClass("TextLabel").Text:find(mod.Text, 1, true) then
                                        child.BackgroundColor3 = mod.State and Theme.Success or Color3.fromRGB(80, 0, 0)
                                        child.Text = mod.State and "ENABLED" or "DISABLED"
                                        
                                        -- ANTI-STUN için özel işlem
                                        if mod.Tag == "AntiStun" then
                                            AntiStunEnabled = mod.State
                                            if not AntiStunEnabled then
                                                RemoveAntiStun()
                                            end
                                        end
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

print("🎮 ACR HUB V39 - ANTI-STUN EDITION YÜKLENDİ!")
print("• WaitFirstChild hatası düzeltildi")
print("• Anti-Stun modülü aktif")
print("• GUI tuşu: RightShift")
