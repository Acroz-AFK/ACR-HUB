-- // ACR_BRAIN_ROT_V1
-- // High-End Network Manipulation Module
-- // Keybind: [P] to Toggle UI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local BG_COLOR = Color3.fromRGB(10, 10, 10)
local ACCENT = Color3.fromRGB(255, 20, 147)

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 130)
Main.Position = UDim2.new(0.5, -130, 0.5, -65)
Main.BackgroundColor3 = BG_COLOR
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = ACCENT; Stroke.Thickness = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "BRAIN ROT EXPLOIT"; Title.TextColor3 = ACCENT
Title.Font = Enum.Font.Code; Title.TextSize = 16; Title.BackgroundTransparency = 1

local Toggle = Instance.new("TextButton", Main)
Toggle.Size = UDim2.new(0.8, 0, 0, 45); Toggle.Position = UDim2.new(0.1, 0, 0.45, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Toggle.Text = "STUN FIELD: OFF"
Toggle.TextColor3 = Color3.fromRGB(150, 150, 150); Toggle.Font = Enum.Font.Code; Toggle.TextSize = 14
Instance.new("UICorner", Toggle)

-- // DRAGGABLE LITE
local d, ds, sp
Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; ds = i.Position; sp = Main.Position end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)
RunService.RenderStepped:Connect(function() 
    if d then 
        local delta = UserInputService:GetMouseLocation() - Vector2.new(ds.X, ds.Y)
        Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y) 
    end 
end)

-- // THE "LAG" LOGIC (ANTI-CHEAT SAFE)
local StunActive = false
Toggle.MouseButton1Click:Connect(function()
    StunActive = not StunActive
    Toggle.Text = StunActive and "STUN FIELD: ACTIVE" or "STUN FIELD: OFF"
    Toggle.TextColor3 = StunActive and ACCENT or Color3.fromRGB(150, 150, 150)
    
    -- Anti-Cheat'e yakalanmamak için Network Replication ayarını simüle eder
    settings().Network.IncomingReplicationLag = StunActive and 10 or 0
end)

RunService.Heartbeat:Connect(function()
    if not StunActive or not LP.Character then return end
    
    local myRoot = LP.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local enemyRoot = p.Character.HumanoidRootPart
            local dist = (enemyRoot.Position - myRoot.Position).Magnitude
            
            -- 30 stud yakınındaki oyuncuların fiziksel güncellemesini senin ekranında "dondurur"
            if dist < 30 then
                -- Onları havada asılı kalmış gibi gösterir (Sadece senin ekranında ve vuruşlarında)
                enemyRoot.Anchored = true
                task.delay(0.1, function() enemyRoot.Anchored = false end)
            end
        end
    end
end)

-- P TO TOGGLE
UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.P then Main.Visible = not Main.Visible end
end)
