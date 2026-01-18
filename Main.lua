-- ACR HUB V21 - ULTIMATE EDITION (INF JUMP INCLUDED)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- MODÜLLER VE DURUMLARI
local Modules = {
    {Text = "Combat Baritone", State = false, Key = Enum.KeyCode.H, Tag = "Baritone"},
    {Text = "Fake Lag (Ghost)", State = false, Key = Enum.KeyCode.X, Tag = "FakeLag"},
    {Text = "Infinity Jump", State = false, Key = Enum.KeyCode.M, Tag = "InfJump"},
    {Text = "Movement Bypass", State = false, Key = Enum.KeyCode.Z, Tag = "Bypass"},
    {Text = "Player ESP", State = false, Key = Enum.KeyCode.C, Tag = "ESP"},
    {Text = "Anti-Knockback", State = false, Key = Enum.KeyCode.V, Tag = "AntiKB"},
    {Text = "X-Ray 50%", State = false, Key = Enum.KeyCode.B, Tag = "EmptyXRay"},
    {Text = "No-Clip", State = false, Key = Enum.KeyCode.N, Tag = "NoClip"},
    {Text = "Auto Clicker", State = false, Key = Enum.KeyCode.K, Tag = "AutoClicker"}
}

local BoostPower = 33
local TargetRange = 15
local BorderColor = Color3.fromRGB(200, 0, 0)
local OffColor = Color3.fromRGB(0, 255, 255)

-- GUI ROOT
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ACR_V21_Final"
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Size = UDim2.new(0, 300, 0, 540)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.Active, MainFrame.Draggable = true, true
local UIStroke = Instance.new("UIStroke", MainFrame); UIStroke.Color = BorderColor; UIStroke.Thickness = 3
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local ResizeBtn = Instance.new("TextButton", MainFrame)
ResizeBtn.Size = UDim2.new(0, 20, 0, 20); ResizeBtn.Position = UDim2.new(1, -20, 1, -20)
ResizeBtn.Text = "↘"; ResizeBtn.BackgroundTransparency = 1; ResizeBtn.TextColor3 = Color3.fromRGB(255,255,255)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45); Title.Text = "ACR HUB V21 - ULTIMATE"; Title.TextColor3 = BorderColor
Title.Font = Enum.Font.Code; Title.TextSize = 18; Title.BackgroundTransparency = 1

local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Size = UDim2.new(1, -20, 1, -150); Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1; Container.ScrollBarThickness = 2
local UIList = Instance.new("UIListLayout", Container); UIList.Padding = UDim.new(0, 5)

-- YARDIMCI FONKSİYONLAR
local function GetClosestTarget()
    local closest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (p.Character.HumanoidRootPart.Position - Root.Position).Magnitude
            if d < dist then closest = p.Character; dist = d end
        end
    end
    return closest
end

-- MODÜL OLUŞTURUCU
for _, mod in pairs(Modules) do
    local ModFrame = Instance.new("Frame", Container)
    ModFrame.Size = UDim2.new(1, 0, 0, 35); ModFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", ModFrame)

    local ToggleBtn = Instance.new("TextButton", ModFrame)
    ToggleBtn.Size = UDim2.new(0.7, 0, 1, 0); ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Text = mod.Text; ToggleBtn.TextColor3 = OffColor; ToggleBtn.Font = Enum.Font.Code; ToggleBtn.TextSize = 12

    local BindBtn = Instance.new("TextButton", ModFrame)
    BindBtn.Size = UDim2.new(0.3, 0, 1, 0); BindBtn.Position = UDim2.new(0.7, 0, 0, 0)
    BindBtn.BackgroundTransparency = 1; BindBtn.Text = "[" .. mod.Key.Name .. "]"; BindBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    BindBtn.Font = Enum.Font.Code; BindBtn.TextSize = 10

    local function Toggle()
        mod.State = not mod.State
        ToggleBtn.TextColor3 = mod.State and Color3.fromRGB(0, 255, 120) or OffColor
        if mod.Tag == "EmptyXRay" then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("base") or v.Name:lower():find("empty")) then
                    v.Transparency = mod.State and 0.5 or 0
                end
            end
        end
    end

    ToggleBtn.MouseButton1Click:Connect(Toggle)
    mod.ToggleFunc = Toggle

    BindBtn.MouseButton1Click:Connect(function()
        BindBtn.Text = "[...]"
        local con; con = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                mod.Key = input.KeyCode; BindBtn.Text = "[" .. input.KeyCode.Name .. "]"; con:Disconnect()
            end
        end)
    end)
end

-- SPEED SLIDER (ESKİ USUL)
local SpeedLabel = Instance.new("TextLabel", MainFrame)
SpeedLabel.Position = UDim2.new(0.05, 0, 0.82, 0); SpeedLabel.Size = UDim2.new(0.9, 0, 0, 20)
SpeedLabel.Text = "Velocity: " .. BoostPower; SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200); SpeedLabel.BackgroundTransparency = 1
local SliderBack = Instance.new("Frame", MainFrame); SliderBack.Position = UDim2.new(0.05, 0, 0.88, 0); SliderBack.Size = UDim2.new(0.9, 0, 0, 10); SliderBack.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
local SliderMain = Instance.new("TextButton", SliderBack); SliderMain.Size = UDim2.new((BoostPower-16)/134, 0, 1, 0); SliderMain.BackgroundColor3 = BorderColor; SliderMain.Text = ""

SliderMain.MouseButton1Down:Connect(function()
    local moveCon; moveCon = RunService.RenderStepped:Connect(function()
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local p = math.clamp((UserInputService:GetMouseLocation().X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
            SliderMain.Size = UDim2.new(p, 0, 1, 0); BoostPower = math.floor(16 + (p * 134)); SpeedLabel.Text = "Velocity: " .. BoostPower
        else moveCon:Disconnect() end
    end)
end)

-- ANA DÖNGÜ
RunService.Heartbeat:Connect(function()
    local states = {}
    for _, m in pairs(Modules) do states[m.Tag] = m.State end

    if states.Baritone then
        local target = GetClosestTarget()
        if target then
            Humanoid:MoveTo(target.HumanoidRootPart.Position)
            if (target.HumanoidRootPart.Position - Root.Position).Magnitude < TargetRange then
                local tool = Character:FindFirstChildOfClass("Tool")
                if tool then 
                    if states.FakeLag then Root.Anchored = false end
                    tool:Activate() 
                end
            end
        end
    end

    if states.FakeLag and not (states.Baritone and GetClosestTarget() and (GetClosestTarget().HumanoidRootPart.Position - Root.Position).Magnitude < 6) then
        Root.Anchored = true; task.wait(0.06); Root.Anchored = false
    end

    if states.Bypass and Humanoid.MoveDirection.Magnitude > 0 then
        Root.Velocity = Vector3.new(Humanoid.MoveDirection.X * BoostPower, Root.Velocity.Y, Humanoid.MoveDirection.Z * BoostPower)
    end
    if states.AntiKB then Root.Velocity = Vector3.new(0, Root.Velocity.Y, 0) end
    if states.NoClip then for _, v in pairs(Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    if states.AutoClicker and not states.Baritone then 
        local t = Character:FindFirstChildOfClass("Tool") if t then t:Activate() end 
    end
    if states.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character then
                local hl = p.Character:FindFirstChild("ACR_HL") or Instance.new("Highlight", p.Character)
                hl.Enabled = true; hl.FillColor = Color3.fromRGB(255, 0, 0)
            end
        end
    end
end)

-- INFINITY JUMP & TUŞLARI DİNLE
UserInputService.JumpRequest:Connect(function()
    for _, m in pairs(Modules) do if m.Tag == "InfJump" and m.State then Root.Velocity = Vector3.new(Root.Velocity.X, 50, Root.Velocity.Z) end end
end)

UserInputService.InputBegan:Connect(function(input, g)
    if g then return end
    for _, mod in pairs(Modules) do if input.KeyCode == mod.Key then mod.ToggleFunc() end end
    if input.KeyCode == Enum.KeyCode.P then MainFrame.Visible = not MainFrame.Visible end
end)

-- RESIZE
local resizing = false
ResizeBtn.MouseButton1Down:Connect(function() resizing = true end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end end)
RunService.RenderStepped:Connect(function()
    if resizing then
        local m = UserInputService:GetMouseLocation()
        MainFrame.Size = UDim2.new(0, math.max(200, m.X - MainFrame.AbsolutePosition.X), 0, math.max(250, m.Y - MainFrame.AbsolutePosition.Y))
    end
end)

Player.CharacterAdded:Connect(function(nc) Character, Root, Humanoid = nc, nc:WaitForChild("HumanoidRootPart"), nc:WaitForChild("Humanoid") end)
print("ACR HUB V21 LOADED! INF JUMP ADDED.")
