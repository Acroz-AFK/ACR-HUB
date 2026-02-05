-- // ACR_FREEZE_BYPASS_V1
-- // Scoped for High-Performance Environments

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // SETTINGS
_G.FreezeEnabled = false
_G.FreezeRange = 50 -- Ne kadar yakındakiler donsun?

-- // GUI CONSTRUCTION
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "ACR_Module_Ext"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 110)
Main.Position = UDim2.new(0.8, 0, 0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(255, 20, 147)
Stroke.Thickness = 1.8

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "PLAYER STUNNER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0.85, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.075, 0, 0.45, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleBtn.Text = "STUN: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 12
Instance.new("UICorner", ToggleBtn)

-- // DRAGGABLE
local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = Main.Position
    end
end)
Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- // P TOGGLE
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.P then
        Main.Visible = not Main.Visible
    end
end)

-- // CORE STUN LOGIC
ToggleBtn.MouseButton1Click:Connect(function()
    _G.FreezeEnabled = not _G.FreezeEnabled
    ToggleBtn.Text = _G.FreezeEnabled and "STUN: ACTIVE" or "STUN: OFF"
    ToggleBtn.TextColor3 = _G.FreezeEnabled and Color3.fromRGB(255, 20, 147) or Color3.fromRGB(200, 200, 200)
end)

RunService.Heartbeat:Connect(function()
    if not _G.FreezeEnabled then return end
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pRoot = p.Character.HumanoidRootPart
            local dist = (pRoot.Position - char.HumanoidRootPart.Position).Magnitude
            
            if dist < _G.FreezeRange then
                -- Bu kısım rakibin senin ekranındaki fiziksel verisini manipüle eder
                -- Rakip hareket etmeye çalışsa bile senin mermilerin için olduğu yerde kalır
                pRoot.Velocity = Vector3.new(0, 0, 0)
                pRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                
                -- Görsel Lag İllüzyonu
                if p.Character:FindFirstChild("Humanoid") then
                    p.Character.Humanoid.PlatformStand = true -- Onları "stun" durumuna sokar
                end
            else
                if p.Character:FindFirstChild("Humanoid") then
                    p.Character.Humanoid.PlatformStand = false
                end
            end
        end
    end
end)
