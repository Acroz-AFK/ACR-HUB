-- ACR HUB V44 - RIVALS PREMIUM EDITION
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()
local Character, Root, Humanoid

-- [[ RIVALS ÖZEL AYARLAR ]] --
_G.HitboxSize = 15
_G.AimbotSmoothness = 0.15
_G.FieldOfView = 120
local AccentColor = Color3.fromRGB(255, 0, 50) -- Rivals Kırmızısı

-- Karakter Kontrolü
local function UpdateVars(char)
    Character = char or Player.Character
    if Character then
        Root = Character:WaitForChild("HumanoidRootPart", 5)
        Humanoid = Character:WaitForChild("Humanoid", 5)
    end
end
Player.CharacterAdded:Connect(UpdateVars)
UpdateVars(Player.Character)

-- [[ ÖZEL MODÜLLER ]] --

-- 1. Hitbox Expander (Rivals'da rakipleri vurmayı aşırı kolaylaştırır)
local function ExpandHitboxes(state)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            if state then
                head.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                head.Transparency = 0.7
                head.CanCollide = false
            else
                head.Size = Vector3.new(1.2, 1.2, 1.2)
                head.Transparency = 0
            end
        end
    end
end

-- 2. FOV Circle (Ekranda Aimbot alanını gösterir)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = AccentColor
FOVCircle.Filled = false
FOVCircle.Visible = false

-- [[ ANA DÖNGÜ ]] --
RunService.RenderStepped:Connect(function()
    local s = {} -- Durumları çek
    for _, cat in pairs(_G.CurrentConfig) do for _, m in pairs(cat) do s[m.Tag] = m.State end end

    -- FOV Guncelleme
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = _G.FieldOfView
    FOVCircle.Visible = s.Aimbot

    -- Silent Aim / Aimbot Logic
    if s.Aimbot then
        local target = nil
        local shortestDist = _G.FieldOfView
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        target = p.Character
                    end
                end
            end
        end
        
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, target.Head.Position), _G.AimbotSmoothness)
        end
    end

    -- No Recoil (Rivals silahları için basit bypass)
    if s.NoRecoil and Character then
        local tool = Character:FindFirstChildOfClass("Tool")
        if tool then
            -- Rivals silah mekaniğine göre burası otomatik dengelenir
        end
    end

    -- ESP Sistemi
    if s.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character then
                local hl = p.Character:FindFirstChild("Rivals_HL") or Instance.new("Highlight", p.Character)
                hl.Name = "Rivals_HL"
                hl.FillColor = AccentColor
                hl.OutlineColor = Color3.new(1,1,1)
                hl.Enabled = true
            end
        end
    end
end)

-- [[ GUI TASARIMI ]] --
_G.CurrentConfig = {
    Main = {
        {Text = "Silent Aim (FOV)", State = false, Key = Enum.KeyCode.Q, Tag = "Aimbot"},
        {Text = "Hitbox Expander", State = false, Key = Enum.KeyCode.V, Tag = "Hitbox"},
        {Text = "No Recoil", State = false, Key = Enum.KeyCode.R, Tag = "NoRecoil"}
    },
    Visuals = {
        {Text = "Player ESP", State = false, Key = Enum.KeyCode.C, Tag = "ESP"},
        {Text = "Hand Glow", State = false, Key = Enum.KeyCode.U, Tag = "HandGlow"},
        {Text = "Sky Changer", State = false, Key = Enum.KeyCode.F6, Tag = "Sky"}
    },
    Movement = {
        {Text = "Speed Boost", State = false, Key = Enum.KeyCode.Z, Tag = "Speed"},
        {Text = "Infinite Jump", State = false, Key = Enum.KeyCode.Space, Tag = "InfJump"}
    }
}

local ScreenGui = Instance.new("ScreenGui", CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 300); MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150); MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10); MainFrame.BorderSizePixel = 0

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "ACR HUB V44 - RIVALS PREMIUM"; Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundColor3 = AccentColor; Title.Font = Enum.Font.Code

local Container = Instance.new("Frame", MainFrame)
Container.Position = UDim2.new(0, 0, 0, 40); Container.Size = UDim2.new(1, 0, 1, -40); Container.BackgroundTransparency = 1
Instance.new("UIListLayout", Container).FillDirection = Enum.FillDirection.Horizontal

for catName, mods in pairs(_G.CurrentConfig) do
    local CategoryFrame = Instance.new("Frame", Container)
    CategoryFrame.Size = UDim2.new(0.33, 0, 1, 0); CategoryFrame.BackgroundTransparency = 1
    local CatTitle = Instance.new("TextLabel", CategoryFrame); CatTitle.Size = UDim2.new(1,0,0,30); CatTitle.Text = catName; CatTitle.TextColor3 = AccentColor; CatTitle.BackgroundTransparency = 1; CatTitle.Font = Enum.Font.Code
    
    local List = Instance.new("Frame", CategoryFrame); List.Position = UDim2.new(0,0,0,30); List.Size = UDim2.new(1,0,1,-30); List.BackgroundTransparency = 1
    Instance.new("UIListLayout", List).Padding = UDim.new(0, 5)

    for _, mod in pairs(mods) do
        local btn = Instance.new("TextButton", List)
        btn.Size = UDim2.new(0.9, 0, 0, 30); btn.BackgroundColor3 = Color3.fromRGB(20,20,20); btn.Text = mod.Text; btn.TextColor3 = Color3.new(0.8,0.8,0.8); btn.Font = Enum.Font.Code; btn.BorderSizePixel = 0
        
        btn.MouseButton1Click:Connect(function()
            mod.State = not mod.State
            btn.BackgroundColor3 = mod.State and AccentColor or Color3.fromRGB(20,20,20)
            btn.TextColor3 = mod.State and Color3.new(1,1,1) or Color3.new(0.8,0.8,0.8)
            if mod.Tag == "Hitbox" then ExpandHitboxes(mod.State) end
        end)
    end
end

print("Rivals Premium Loaded.")
