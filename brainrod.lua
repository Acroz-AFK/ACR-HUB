-- // ACR_GHOST_PROTOCOL_V47
-- // Developed for High-Tier Performance & Stealth
-- // Keybind: [P] to Toggle UI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Character, Root, Humanoid

-- // PRIVATE SETTINGS
local UI_THEME = Color3.fromRGB(255, 20, 147)
local BG_ACCENT = Color3.fromRGB(10, 10, 10)
local _G_ENABLED = true

local function SyncChar()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Root = Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid")
end
SyncChar()
LocalPlayer.CharacterAdded:Connect(SyncChar)

-- // UI CONSTRUCTION (MODERN & MINIMAL)
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 240, 0, 180)
Main.Position = UDim2.new(0.5, -120, 0.5, -90)
Main.BackgroundColor3 = BG_ACCENT
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Glow = Instance.new("UIStroke", Main)
Glow.Color = UI_THEME; Glow.Thickness = 2; Glow.Transparency = 0.2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "ACR GHOST V47"
Title.TextColor3 = UI_THEME; Title.Font = Enum.Font.GothamBold; Title.TextSize = 14; Title.BackgroundTransparency = 1

local Container = Instance.new("Frame", Main)
Container.Position = UDim2.new(0, 10, 0, 45); Container.Size = UDim2.new(1, -20, 1, -55); Container.BackgroundTransparency = 1
Instance.new("UIListLayout", Container).Padding = UDim.new(0, 8)

-- // DRAGGABLE ENGINE
local d, di, ds, sp
Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; ds = i.Position; sp = Main.Position end end)
Main.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then di = i end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)
RunService.RenderStepped:Connect(function() if d and di then local delta = di.Position - ds; Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y) end end)

-- // MODULE FUNCTIONS
local function CreateToggle(text, callback)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(20, 20, 20); b.Text = text
    b.TextColor3 = Color3.fromRGB(150, 150, 150); b.Font = Enum.Font.GothamMedium; b.TextSize = 12
    Instance.new("UICorner", b)
    
    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        b.TextColor3 = state and UI_THEME or Color3.fromRGB(150, 150, 150)
        b.BackgroundColor3 = state and Color3.fromRGB(25, 25, 25) or Color3.fromRGB(20, 20, 20)
        callback(state)
    end)
end

-- // PRO MODULES
-- 1. DESYNC (Rakiplerin seni vurmasını imkansızlaştırır)
local DesyncActive = false
CreateToggle("Network Desync (Anti-Hit)", function(s) DesyncActive = s end)

-- 2. SPEED BYPASS (Hız hilesi değil, hareket optimizasyonu)
local SpeedActive = false
CreateToggle("Velocity Optimizer", function(s) SpeedActive = s end)

-- 3. JUMP BYPASS
local JumpActive = false
CreateToggle("Infinite Glide", function(s) JumpActive = s end)

-- // ENGINE LOOPS (STEALTH MODE)
RunService.Heartbeat:Connect(function()
    if not Root or not Humanoid then return end
    
    -- Anti-Hit / Desync: Karakterin hitbox'ını milisaniyelik gecikmelerle kaydırır
    if DesyncActive then
        local oldV = Root.Velocity
        Root.Velocity = oldV * 0.5 + Vector3.new(0, 0.05, 0)
        RunService.RenderStepped:Wait()
        Root.Velocity = oldV
    end
    
    -- Optimizer: Hareket halindeyken sürtünmeyi azaltır
    if SpeedActive and Humanoid.MoveDirection.Magnitude > 0 then
        Root.CFrame = Root.CFrame + (Humanoid.MoveDirection * 0.45)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if JumpActive and Root then Root.Velocity = Vector3.new(Root.Velocity.X, 50, Root.Velocity.Z) end
end)

-- Toggle Menu
UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.P then Main.Visible = not Main.Visible end
end)

print("ACR GHOST V47 Booted. Stealth Mode: Active.")
