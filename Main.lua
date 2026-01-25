-- LocalScript, oyuncunun PlayerScripts veya bir GUI nesnesine eklenmeli
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Korkunç görüntüler için resim URL'leri (Roblox ImageLabel'da kullanılabilir)
local scaryImages = {
    "rbxassetid://1312944139",  -- Korkunç yüz 1
    "rbxassetid://1312944167",  -- Korkunç yüz 2
    "rbxassetid://1312944195",  -- Korkunç yüz 3
    "rbxassetid://6197274482",  -- Korkunç gözler
    "rbxassetid://6197274297"   -- Korkunç yaratık
}

-- Ana GUI'yi oluştur
local function createMainGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HorrorEffects"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    return screenGui
end

-- Fullscreen görüntü için ImageLabel oluştur
local function createScaryImage(parent)
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Name = "ScaryImage"
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.Position = UDim2.new(0, 0, 0, 0)
    imageLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    imageLabel.BackgroundTransparency = 1
    imageLabel.ImageTransparency = 1  -- Başlangıçta görünmez
    imageLabel.ScaleType = Enum.ScaleType.Fit
    imageLabel.Parent = parent
    
    return imageLabel
end

-- Titreme efekti
local function applyScreenShake(camera, intensity, duration)
    local startTime = tick()
    local originalCFrame = camera.CFrame
    
    while tick() - startTime < duration do
        local elapsed = tick() - startTime
        local currentIntensity = intensity * (1 - (elapsed / duration))
        
        -- Rastgele titreme
        local shakeOffset = Vector3.new(
            math.random(-currentIntensity, currentIntensity),
            math.random(-currentIntensity, currentIntensity),
            math.random(-currentIntensity, currentIntensity)
        )
        
        camera.CFrame = originalCFrame + shakeOffset
        RunService.RenderStepped:Wait()
    end
    
    camera.CFrame = originalCFrame
end

-- Renkleri tersine çevirme efekti
local function applyInvertedColors()
    local lighting = game:GetService("Lighting")
    
    -- ColorCorrectionEffect oluştur veya var olanı bul
    local colorCorrection = lighting:FindFirstChild("HorrorColorCorrection")
    if not colorCorrection then
        colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Name = "HorrorColorCorrection"
        colorCorrection.Parent = lighting
    end
    
    -- Renkleri tersine çevir
    colorCorrection.TintColor = Color3.new(0, 0, 0)  -- Siyah tint
    colorCorrection.Brightness = -0.1
    colorCorrection.Contrast = 0.5
    colorCorrection.Saturation = -0.8
    
    -- Tersine çevirme efekti
    local tweenInfo = TweenInfo.new(
        2,  -- Süre
        Enum.EasingStyle.Quad,  -- Easing stili
        Enum.EasingDirection.InOut,  -- Easing yönü
        -1,  -- Tekrar sayısı (sonsuz)
        true  -- Tersine oynat
    )
    
    local tween = TweenService:Create(
        colorCorrection,
        tweenInfo,
        {TintColor = Color3.new(1, 1, 1), Brightness = 0.2, Contrast = 0.8}
    )
    
    tween:Play()
    return colorCorrection, tween
end

-- Korkunç ses efekti
local function playScarySound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9125325392"  -- Korkunç ses efekti
    sound.Volume = 0.7
    sound.Parent = workspace
    
    sound:Play()
    
    -- Ses bittikten sonra sil
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

-- Ana korku efekti fonksiyonu
local function triggerHorrorEffect()
    print("Korku efekti başlatılıyor...")
    
    -- GUI'yi oluştur
    local screenGui = playerGui:FindFirstChild("HorrorEffects")
    if not screenGui then
        screenGui = createMainGUI()
    end
    
    -- Korkunç resim için ImageLabel oluştur
    local scaryImage = screenGui:FindFirstChild("ScaryImage")
    if not scaryImage then
        scaryImage = createScaryImage(screenGui)
    end
    
    -- Rastgele korkunç resim seç
    local randomImage = scaryImages[math.random(1, #scaryImages)]
    scaryImage.Image = randomImage
    
    -- Kamera referansı al
    local camera = workspace.CurrentCamera
    
    -- Titreme efekti başlat (coroutine içinde)
    local shakeCoroutine = coroutine.create(function()
        applyScreenShake(camera, 0.5, 3)
    end)
    coroutine.resume(shakeCoroutine)
    
    -- Renk tersine çevirme efekti
    local colorCorrection, colorTween = applyInvertedColors()
    
    -- Korkunç ses çal
    playScarySound()
    
    -- Resmi görünür yap
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local appearTween = TweenService:Create(scaryImage, tweenInfo, {ImageTransparency = 0})
    appearTween:Play()
    
    -- 3 saniye bekleyip resmi yavaşça kaybet
    wait(3)
    
    local disappearTween = TweenService:Create(scaryImage, tweenInfo, {ImageTransparency = 1})
    disappearTween:Play()
    
    -- Efektleri temizle
    disappearTween.Completed:Connect(function()
        -- Renk efekti tweener'ı durdur
        if colorTween then
            colorTween:Cancel()
        end
        
        -- ColorCorrection efekti kaldır
        if colorCorrection then
            colorCorrection:Destroy()
        end
        
        -- Resmi kaldır
        scaryImage:Destroy()
    end)
end

-- TEST İÇİN: Bir tuşa basıldığında efekti tetikle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.H then
        triggerHorrorEffect()
    end
end)

-- Oyun içinde otomatik tetikleme örneği (isteğe bağlı)
-- Bu kısım oyununuzun mantığına göre değiştirilebilir
local function setupAutomaticTriggers()
    -- Örnek: Oyun içinde belirli bir yere gidince tetikle
    workspace.DescendantAdded:Connect(function(descendant)
        if descendant.Name == "TriggerHorror" then
            triggerHorrorEffect()
            wait(1)
            descendant:Destroy()
        end
    end)
    
    -- Örnek: Can düşükse rastgele tetikleme
    local function onHealthChanged(health)
        if health < 20 then
            -- %30 şansla korku efekti tetikle
            if math.random(1, 100) <= 30 then
                triggerHorrorEffect()
            end
        end
    end
    
    -- Oyuncunun karakterini bekle
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.HealthChanged:Connect(onHealthChanged)
    
    -- Karakter değişirse yeniden bağla
    player.CharacterAdded:Connect(function(newCharacter)
        local newHumanoid = newCharacter:WaitForChild("Humanoid")
        newHumanoid.HealthChanged:Connect(onHealthChanged)
    end)
end

-- Otomatik tetikleyicileri başlat
setupAutomaticTriggers()

print("scripti yüklendi! H tuşuna basarak test edebilirsiniz.")
