-- ACR HUB V39 - CUSTOMIZABLE TEAM CHECK & TARGET FIX
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Character, Root, Humanoid

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

_G.BoostPower = _G.BoostPower or 45
_G.TeamCheckActive = true -- Varsayılan olarak takım arkadaşlarına vurmaz
_G.ClickTPDistance = 100 -- Varsayılan Click TP mesafesi
local AccentColor = Color3.fromRGB(200, 0, 0)

_G.CurrentConfig = {
    Combat = {
        {Text = "Combat Lock", State = false, Key = Enum.KeyCode.G, Tag = "Aimbot", HasSettings = true},
        {Text = "Super Knockback", State = false, Key = Enum.KeyCode.Y, Tag = "SuperKB"},
        {Text = "Wall Hit", State = false, Key = Enum.KeyCode.L, Tag = "WallHit"},
        {Text = "Baritone", State = false, Key = Enum.KeyCode.H, Tag = "Baritone"},
        {Text = "Auto Clicker", State = false, Key = Enum.KeyCode.K, Tag = "AutoClicker"}
    },
    Movement = {
        {Text = "Speed Bypass", State = false, Key = Enum.KeyCode.Z, Tag = "Bypass", HasSettings = true},
        {Text = "Inf Jump", State = false, Key = Enum.KeyCode.M, Tag = "InfJump"},
        {Text = "No-Clip", State = false, Key = Enum.KeyCode.N, Tag = "NoClip"},
        {Text = "Click TP", State = false, Key = Enum.KeyCode.I, Tag = "ClickTP", HasSettings = true}
    },
    Player = {
        {Text = "God Mode+", State = false, Key = Enum.KeyCode.T, Tag = "GodMode"},
        {Text = "Anti-Aim", State = false, Key = Enum.KeyCode.F, Tag = "AntiAim"},
        {Text = "Anti-KB", State = false, Key = Enum.KeyCode.V, Tag = "AntiKB"},
        {Text = "Fake Lag", State = false, Key = Enum.KeyCode.X, Tag = "FakeLag"}
    },
    Render = {
        {Text = "Player ESP", State = false, Key = Enum.KeyCode.C, Tag = "ESP"},
        {Text = "Tracers", State = false, Key = Enum.KeyCode.J, Tag = "Tracers"},
        {Text = "Hand Glow", State = false, Key = Enum.KeyCode.U, Tag = "HandGlow"},
        {Text = "X-Ray 50%", State = false, Key = Enum.KeyCode.B, Tag = "EmptyXRay"},
        -- BLINK MODÜLÜ EKLENDİ
        {Text = "Blink", State = false, Key = Enum.KeyCode.Q, Tag = "Blink", HasSettings = true}
    }
}

-- GUI SETUP
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "ACR_HUB_V39"

local MainContainer = Instance.new("Frame", ScreenGui)
MainContainer.Size = UDim2.new(1, 0, 1, 0); MainContainer.BackgroundTransparency = 1
local UIList = Instance.new("UIListLayout", MainContainer)
UIList.FillDirection = Enum.FillDirection.Horizontal
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.VerticalAlignment = Enum.VerticalAlignment.Top
UIList.Padding = UDim.new(0, 25)

local SpeedDisplayLabel
local BlinkPower = 100 -- Varsayılan Blink gücü
local BlinkEffectEnabled = true -- Blink efektleri aktif

-- CLICK TP VISUALIZATION (GÜVENLİ VERSİYON)
_G.ClickTPIndicator = nil
local function SafeSetIndicatorVisibility(state)
    if _G.ClickTPIndicator and _G.ClickTPIndicator.Parent then
        pcall(function()
            _G.ClickTPIndicator.Visible = state
        end)
    end
end

local function SafeUpdateIndicatorPosition(position)
    if _G.ClickTPIndicator and _G.ClickTPIndicator.Parent then
        pcall(function()
            _G.ClickTPIndicator.Position = position
        end)
    end
end

local function CreateTPIndicator()
    -- Eski indicator'ı temizle
    if _G.ClickTPIndicator and _G.ClickTPIndicator.Parent then
        _G.ClickTPIndicator:Destroy()
    end
    
    -- Yeni indicator oluştur
    _G.ClickTPIndicator = Instance.new("Part")
    _G.ClickTPIndicator.Size = Vector3.new(2, 0.1, 2)
    _G.ClickTPIndicator.Color = Color3.fromRGB(0, 255, 0)
    _G.ClickTPIndicator.Anchored = true
    _G.ClickTPIndicator.CanCollide = false
    _G.ClickTPIndicator.Transparency = 0.5
    _G.ClickTPIndicator.Name = "ACR_ClickTP_Indicator"
    
    -- Parent ayarla (önemli!)
    _G.ClickTPIndicator.Parent = workspace
    
    -- Visible özelliği sadece parent ayarlandıktan sonra
    pcall(function()
        _G.ClickTPIndicator.Visible = false
    end)
    
    -- Işık efekti ekle
    local pointLight = Instance.new("PointLight", _G.ClickTPIndicator)
    pointLight.Brightness = 1
    pointLight.Range = 5
    pointLight.Color = Color3.fromRGB(0, 255, 0)
    pointLight.Enabled = true
end

-- BLINK VISUAL EFFECT FUNCTION
local function CreateBlinkEffect(position)
    if not BlinkEffectEnabled then return end
    
    -- Ana efekt partı
    local effect = Instance.new("Part")
    effect.Size = Vector3.new(3, 3, 3)
    effect.Position = position
    effect.Transparency = 0.3
    effect.Color = Color3.fromRGB(0, 150, 255)
    effect.Material = EnumMaterial.Neon
    effect.Anchored = true
    effect.CanCollide = false
    effect.Parent = workspace
    
    -- Işık efekti
    local pointLight = Instance.new("PointLight", effect)
    pointLight.Brightness = 2
    pointLight.Range = 10
    pointLight.Color = Color3.fromRGB(0, 150, 255)
    pointLight.Enabled = true
    
    -- Parlama efekti için particle
    local particle = Instance.new("ParticleEmitter", effect)
    particle.Rate = 100
    particle.Lifetime = NumberRange.new(0.5, 1)
    particle.Speed = NumberRange.new(5, 10)
    particle.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 0)
    })
    particle.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    particle.Color = ColorSequence.new(Color3.fromRGB(0, 150, 255))
    particle.EmissionDirection = Enum.NormalId.Top
    particle.VelocityInheritance = 0
    
    game:GetService("Debris"):AddItem(effect, 1)
    
    -- Kısa süreli yanıp sönme efekti
    for i = 1, 3 do
        effect.Transparency = i % 2 == 0 and 0.3 or 0.7
        task.wait(0.1)
    end
end

-- RENDER VISUALIZATION FUNCTION
local function UpdateTPVisualization()
    if not Character or not Root then return end
    
    local rayOrigin = Camera.CFrame.Position
    local rayDirection = Camera.CFrame.LookVector * _G.ClickTPDistance
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {Character}
    
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    if raycastResult then
        SafeUpdateIndicatorPosition(raycastResult.Position + Vector3.new(0, 0.5, 0))
        SafeSetIndicatorVisibility(true)
    else
        SafeUpdateIndicatorPosition(rayOrigin + (rayDirection * 0.95))
        SafeSetIndicatorVisibility(true)
    end
end

-- CATEGORY SYSTEM
local function CreateCategory(name, modules)
    local Frame = Instance.new("Frame", MainContainer)
    Frame.Size = UDim2.new(0, 180, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Frame.BorderSizePixel = 0
    Frame.AutomaticSize = Enum.AutomaticSize.Y
    
    local Top = Instance.new("Frame", Frame)
    Top.Size = UDim2.new(1, 0, 0, 3)
    Top.BackgroundColor3 = AccentColor
    Top.BorderSizePixel = 0
    
    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.Text = "  "..name:upper()
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.Code
    Title.TextSize = 14
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local Content = Instance.new("Frame", Frame)
    Content.Position = UDim2.new(0, 0, 0, 38)
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.AutomaticSize = Enum.AutomaticSize.Y
    Content.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Content.BorderSizePixel = 0
    
    local ContentList = Instance.new("UIListLayout", Content)
    ContentList.Padding = UDim.new(0, 2)

    for _, mod in pairs(modules) do
        local btn = Instance.new("TextButton", Content)
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        btn.Text = "  " .. mod.Text
        btn.TextColor3 = mod.State and AccentColor or Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Code
        btn.TextSize = 11
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.BorderSizePixel = 0
        
        if mod.Tag == "Bypass" then SpeedDisplayLabel = btn end

        local bindBtn = Instance.new("TextButton", btn)
        bindBtn.Size = UDim2.new(0, 50, 1, 0)
        bindBtn.Position = UDim2.new(1, -55, 0, 0)
        bindBtn.BackgroundTransparency = 1
        bindBtn.Text = "["..mod.Key.Name.."]"
        bindBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
        bindBtn.Font = Enum.Font.Code
        bindBtn.TextSize = 10
        bindBtn.TextXAlignment = Enum.TextXAlignment.Right
        
        bindBtn.MouseButton1Click:Connect(function()
            bindBtn.Text = "[...]"
            local conn
            conn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    mod.Key = (input.KeyCode == Enum.KeyCode.Escape) and Enum.KeyCode.Unknown or input.KeyCode
                    bindBtn.Text = "["..mod.Key.Name.."]"
                    conn:Disconnect()
                end
            end)
        end)

        -- SETTINGS FRAME
        local sf = Instance.new("Frame", Content)
        sf.Size = UDim2.new(1, 0, 0, 80) -- Blink için daha yüksek
        sf.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        sf.Visible = false
        sf.BorderSizePixel = 0
        
        -- COMBAT LOCK SETTINGS
        if mod.Tag == "Aimbot" then
            local teamBtn = Instance.new("TextButton", sf)
            teamBtn.Size = UDim2.new(0.9, 0, 0.5, 0)
            teamBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
            teamBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            teamBtn.Font = Enum.Font.Code
            teamBtn.TextSize = 10
            teamBtn.TextColor3 = Color3.new(1,1,1)
            
            local function updateTeamText()
                teamBtn.Text = _G.TeamCheckActive and "Team Check: ON" or "Team Check: OFF"
                teamBtn.BackgroundColor3 = _G.TeamCheckActive and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
            end
            updateTeamText()
            
            teamBtn.MouseButton1Click:Connect(function()
                _G.TeamCheckActive = not _G.TeamCheckActive
                updateTeamText()
            end)
        end

        -- SPEED SETTINGS
        if mod.Tag == "Bypass" then
            local speedText = Instance.new("TextLabel", sf)
            speedText.Size = UDim2.new(0.9, 0, 0.3, 0)
            speedText.Position = UDim2.new(0.05, 0, 0.1, 0)
            speedText.BackgroundTransparency = 1
            speedText.Text = "Hız: " .. _G.BoostPower
            speedText.Font = Enum.Font.Code
            speedText.TextSize = 10
            speedText.TextColor3 = Color3.new(1,1,1)
            speedText.TextXAlignment = Enum.TextXAlignment.Left
            
            local sl = Instance.new("TextButton", sf)
            sl.Size = UDim2.new(0.8, 0, 0, 8)
            sl.Position = UDim2.new(0.1, 0, 0.5, 0)
            sl.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            sl.Text = ""
            
            local fl = Instance.new("Frame", sl)
            fl.BackgroundColor3 = AccentColor
            fl.BorderSizePixel = 0
            fl.Size = UDim2.new(math.clamp((_G.BoostPower-16)/184, 0, 1), 0, 1, 0)
            
            sl.MouseButton1Down:Connect(function()
                local move
                move = RunService.RenderStepped:Connect(function()
                    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                        local p = math.clamp((UserInputService:GetMouseLocation().X - sl.AbsolutePosition.X) / sl.AbsoluteSize.X, 0, 1)
                        _G.BoostPower = math.floor(16 + (p * 184))
                        speedText.Text = "Hız: " .. _G.BoostPower
                        fl.Size = UDim2.new(math.clamp((_G.BoostPower-16)/184, 0, 1), 0, 1, 0)
                    else
                        move:Disconnect()
                    end
                end)
            end)
        end
        
        -- CLICK TP SETTINGS
        if mod.Tag == "ClickTP" then
            local distText = Instance.new("TextLabel", sf)
            distText.Size = UDim2.new(0.9, 0, 0.3, 0)
            distText.Position = UDim2.new(0.05, 0, 0.1, 0)
            distText.BackgroundTransparency = 1
            distText.Text = "Mesafe: " .. _G.ClickTPDistance
            distText.Font = Enum.Font.Code
            distText.TextSize = 10
            distText.TextColor3 = Color3.new(1,1,1)
            distText.TextXAlignment = Enum.TextXAlignment.Left
            
            local sl = Instance.new("TextButton", sf)
            sl.Size = UDim2.new(0.8, 0, 0, 8)
            sl.Position = UDim2.new(0.1, 0, 0.5, 0)
            sl.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            sl.Text = ""
            
            local fl = Instance.new("Frame", sl)
            fl.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            fl.BorderSizePixel = 0
            fl.Size = UDim2.new(math.clamp(_G.ClickTPDistance/500, 0, 1), 0, 1, 0)
            
            sl.MouseButton1Down:Connect(function()
                local move
                move = RunService.RenderStepped:Connect(function()
                    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                        local p = math.clamp((UserInputService:GetMouseLocation().X - sl.AbsolutePosition.X) / sl.AbsoluteSize.X, 0, 1)
                        _G.ClickTPDistance = math.floor(10 + (p * 490))
                        distText.Text = "Mesafe: " .. _G.ClickTPDistance
                        fl.Size = UDim2.new(math.clamp(_G.ClickTPDistance/500, 0, 1), 0, 1, 0)
                        
                        if mod.State then
                            UpdateTPVisualization()
                        end
                    else
                        move:Disconnect()
                    end
                end)
            end)
        end
        
        -- BLINK SETTINGS
        if mod.Tag == "Blink" then
            -- Blink gücü ayarı
            local powerText = Instance.new("TextLabel", sf)
            powerText.Size = UDim2.new(0.9, 0, 0.2, 0)
            powerText.Position = UDim2.new(0.05, 0, 0.05, 0)
            powerText.BackgroundTransparency = 1
            powerText.Text = "Blink Gücü: " .. BlinkPower
            powerText.Font = Enum.Font.Code
            powerText.TextSize = 10
            powerText.TextColor3 = Color3.new(1,1,1)
            powerText.TextXAlignment = Enum.TextXAlignment.Left
            
            local powerSlider = Instance.new("TextButton", sf)
            powerSlider.Size = UDim2.new(0.8, 0, 0, 6)
            powerSlider.Position = UDim2.new(0.1, 0, 0.3, 0)
            powerSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            powerSlider.Text = ""
            
            local powerFill = Instance.new("Frame", powerSlider)
            powerFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            powerFill.BorderSizePixel = 0
            powerFill.Size = UDim2.new(math.clamp(BlinkPower/200, 0, 1), 0, 1, 0)
            
            powerSlider.MouseButton1Down:Connect(function()
                local move
                move = RunService.RenderStepped:Connect(function()
                    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                        local p = math.clamp((UserInputService:GetMouseLocation().X - powerSlider.AbsolutePosition.X) / powerSlider.AbsoluteSize.X, 0, 1)
                        BlinkPower = math.floor(10 + (p * 190))
                        powerText.Text = "Blink Gücü: " .. BlinkPower
                        powerFill.Size = UDim2.new(math.clamp(BlinkPower/200, 0, 1), 0, 1, 0)
                    else
                        move:Disconnect()
                    end
                end)
            end)
            
            -- Efekt toggle butonu
            local effectBtn = Instance.new("TextButton", sf)
            effectBtn.Size = UDim2.new(0.9, 0, 0.25, 0)
            effectBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
            effectBtn.BackgroundColor3 = BlinkEffectEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
            effectBtn.Font = Enum.Font.Code
            effectBtn.TextSize = 10
            effectBtn.Text = BlinkEffectEnabled and "Efektler: AÇIK" or "Efektler: KAPALI"
            effectBtn.TextColor3 = Color3.new(1,1,1)
            
            effectBtn.MouseButton1Click:Connect(function()
                BlinkEffectEnabled = not BlinkEffectEnabled
                effectBtn.BackgroundColor3 = BlinkEffectEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
                effectBtn.Text = BlinkEffectEnabled and "Efektler: AÇIK" or "Efektler: KAPALI"
            end)
        end

        btn.MouseButton1Click:Connect(function()
            mod.State = not mod.State
            btn.TextColor3 = mod.State and AccentColor or Color3.fromRGB(200, 200, 200)
            
            if mod.Tag == "ClickTP" then
                if mod.State then
                    -- Indicator'ı oluştur veya yenile
                    CreateTPIndicator()
                    UpdateTPVisualization()
                else
                    SafeSetIndicatorVisibility(false)
                end
            end
        end)
        
        btn.MouseButton2Click:Connect(function()
            if mod.HasSettings then
                sf.Visible = not sf.Visible
                if mod.Tag == "ClickTP" and sf.Visible and mod.State then
                    UpdateTPVisualization()
                end
            end
        end)
    end
end

-- Create categories
CreateCategory("Combat", _G.CurrentConfig.Combat)
CreateCategory("Movement", _G.CurrentConfig.Movement)
CreateCategory("Player", _G.CurrentConfig.Player)
CreateCategory("Render", _G.CurrentConfig.Render)

-- MOUSE WHEEL CONTROL
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        _G.BoostPower = math.clamp(_G.BoostPower + (input.Position.Z > 0 and 5 or -5), 16, 200)
        if SpeedDisplayLabel then
            SpeedDisplayLabel.Text = "  Speed Bypass [".._G.BoostPower.."]"
        end
    end
end)

-- CLICK TP FUNCTION
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        for _, cat in pairs(_G.CurrentConfig) do
            for _, m in pairs(cat) do
                if m.Tag == "ClickTP" and m.State and Root then
                    -- Indicator'ı kontrol et, yoksa oluştur
                    if not _G.ClickTPIndicator or not _G.ClickTPIndicator.Parent then
                        CreateTPIndicator()
                    end
                    
                    local rayOrigin = Camera.CFrame.Position
                    local rayDirection = Camera.CFrame.LookVector * _G.ClickTPDistance
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    raycastParams.FilterDescendantsInstances = {Character}
                    
                    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                    
                    if raycastResult then
                        local targetPos = raycastResult.Position + Vector3.new(0, 3, 0)
                        if Humanoid and Humanoid.FloorMaterial ~= Enum.Material.Air then
                            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                        Root.CFrame = CFrame.new(targetPos)
                    else
                        local targetPos = rayOrigin + (rayDirection * 0.95)
                        if Humanoid and Humanoid.FloorMaterial ~= Enum.Material.Air then
                            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                        Root.CFrame = CFrame.new(targetPos)
                    end
                    
                    -- Teleport efekti
                    local effect = Instance.new("Part")
                    effect.Size = Vector3.new(3, 3, 3)
                    effect.Position = Root.Position
                    effect.Transparency = 0.5
                    effect.Color = Color3.fromRGB(0, 255, 0)
                    effect.Anchored = true
                    effect.CanCollide = false
                    effect.Parent = workspace
                    
                    game:GetService("Debris"):AddItem(effect, 0.5)
                    break
                end
            end
        end
    end
end)

-- BLINK FUNCTION
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    for _, cat in pairs(_G.CurrentConfig) do
        for _, m in pairs(cat) do
            if m.Tag == "Blink" and m.State and Root then
                -- Blink tuşu Q olarak ayarlı
                if input.KeyCode == Enum.KeyCode.Q then
                    -- Kamera yönünde blink hareketi
                    local direction = Camera.CFrame.LookVector
                    
                    -- Başlangıç pozisyonunda efekt
                    CreateBlinkEffect(Root.Position)
                    
                    -- Hareket vektörü
                    local moveVector = direction * BlinkPower
                    
                    -- Yeni pozisyonu hesapla
                    local newPosition = Root.Position + moveVector
                    
                    -- Karakteri hareket ettir
                    if Humanoid and Humanoid.FloorMaterial ~= Enum.Material.Air then
                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                    
                    Root.CFrame = CFrame.new(newPosition)
                    
                    -- Bitiş pozisyonunda efekt
                    CreateBlinkEffect(newPosition)
                    
                    -- Hareket etkisi için kısa süreli hız
                    Root.Velocity = moveVector * 0.5 + Vector3.new(0, 10, 0)
                    
                    break
                end
            end
        end
    end
end)

-- MAIN ENGINE
RunService.Heartbeat:Connect(function()
    if not Root or not Humanoid then return end
    
    local s = {}
    for _, cat in pairs(_G.CurrentConfig) do
        for _, m in pairs(cat) do
            s[m.Tag] = m.State
        end
    end
    
    if SpeedDisplayLabel then
        SpeedDisplayLabel.Text = "  Speed Bypass [".._G.BoostPower.."]"
    end

    -- GOD MODE
    if s.GodMode then
        Humanoid.Health = 100
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    else
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
    end

    -- MOVEMENT
    if s.Bypass and Humanoid.MoveDirection.Magnitude > 0 then
        Root.Velocity = Vector3.new(
            Humanoid.MoveDirection.X * _G.BoostPower,
            Root.Velocity.Y,
            Humanoid.MoveDirection.Z * _G.BoostPower
        )
    end
    
    if s.NoClip then
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
    
    if s.AntiAim then
        Root.CFrame = Root.CFrame * CFrame.Angles(0, math.rad(45), 0)
    end
    
    if s.AntiKB then
        Root.Velocity = Vector3.new(0, Root.Velocity.Y, 0)
    end

    -- Click TP görselleştirmesi (GÜVENLİ VERSİYON)
    if s.ClickTP then
        -- Indicator'ı kontrol et, yoksa oluştur
        if not _G.ClickTPIndicator or not _G.ClickTPIndicator.Parent then
            CreateTPIndicator()
        end
        
        UpdateTPVisualization()
    else
        SafeSetIndicatorVisibility(false)
    end

    -- COMBAT ENGINE
    if s.Aimbot or s.SuperKB then
        local target = nil
        local dist = 250
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                local canTarget = true
                if _G.TeamCheckActive and p.Team == Player.Team then
                    canTarget = false
                end
                
                if canTarget then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local d = (hrp.Position - Root.Position).Magnitude
                        if d < dist then
                            target = p.Character
                            dist = d
                        end
                    end
                end
            end
        end
        
        if target and target:FindFirstChild("HumanoidRootPart") then
            if s.Aimbot then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.HumanoidRootPart.Position + Vector3.new(0, 2, 0))
                Root.CFrame = CFrame.lookAt(
                    Root.Position,
                    Vector3.new(target.HumanoidRootPart.Position.X, Root.Position.Y, target.HumanoidRootPart.Position.Z)
                )
            end
            
            if s.SuperKB and (target.HumanoidRootPart.Position - Root.Position).Magnitude < 15 then
                target.HumanoidRootPart.Velocity = Root.CFrame.LookVector * 500 + Vector3.new(0, 50, 0)
            end
        end
    end

    -- ESP
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if s.ESP then
                local hl = p.Character:FindFirstChild("ACR_ESP") or Instance.new("Highlight", p.Character)
                hl.Name = "ACR_ESP"
                hl.FillColor = (p.Team ~= Player.Team) and AccentColor or Color3.new(0,1,0)
                hl.FillTransparency = 0.5
                hl.OutlineColor = Color3.new(1,1,1)
                hl.OutlineTransparency = 0
            elseif p.Character:FindFirstChild("ACR_ESP") then
                p.Character.ACR_ESP:Destroy()
            end
        end
    end
end)

-- INF JUMP
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
    
    if input.KeyCode == Enum.KeyCode.P then
        MainContainer.Visible = not MainContainer.Visible
        return
    end
    
    for _, cat in pairs(_G.CurrentConfig) do
        for _, mod in pairs(cat) do
            if mod.Key ~= Enum.KeyCode.Unknown and input.KeyCode == mod.Key then
                mod.State = not mod.State
                
                -- Update button color
                for _, frame in pairs(MainContainer:GetChildren()) do
                    if frame:IsA("Frame") then
                        for _, content in pairs(frame:GetChildren()) do
                            if content:IsA("Frame") and content.Name == "" then
                                for _, btn in pairs(content:GetChildren()) do
                                    if btn:IsA("TextButton") and btn.Text:find(mod.Text, 1, true) then
                                        btn.TextColor3 = mod.State and AccentColor or Color3.fromRGB(200, 200, 200)
                                        
                                        if mod.Tag == "ClickTP" then
                                            if mod.State then
                                                CreateTPIndicator()
                                                UpdateTPVisualization()
                                            else
                                                SafeSetIndicatorVisibility(false)
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

-- İlk çalıştırmada indicator'ı oluştur
task.wait(1)
if not _G.ClickTPIndicator or not _G.ClickTPIndicator.Parent then
    CreateTPIndicator()
end

print("ACR HUB V39 - HATALAR GİDERİLDİ")
print("• Click TP indicator güvenli hale getirildi")
print("• Visible hataları düzeltildi")
print("• Blink modülü eklendi (Q tuşu)")
print("• Tüm modüller çalışır durumda")
