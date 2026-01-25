-- LocalScript (StarterPlayerScripts içine koy)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- TEK TUŞLA TÜM KORKU SALDIRISI
local isTrolling = false

-- Korkunç sesler (en iyileri)
local horrorSounds = {
    "rbxassetid://9119658371",  -- Ürpertici fısıltı
    "rbxassetid://9125325392",  -- Yüksek çığlık
    "rbxassetid://138080206",   -- Şeytani gülüş
    "rbxassetid://6448115801",  -- Kapı gıcırtısı
    "rbxassetid://6165903264",  -- Ani çığlık
    "rbxassetid://6196826573",  -- Korku müziği
    "rbxassetid://6452080903",  -- Karanlık sesler
    "rbxassetid://376011982"    -- Jump scare sesi
}

-- Korkunç görüntüler (ani görünecekler)
local scaryImages = {
    "rbxassetid://1312944139",   -- Hayalet yüz
    "rbxassetid://6197274482",   -- Kırmızı gözler
    "rbxassetid://10501563070",  -- Çarpık yüz
    "rbxassetid://10494031723",  -- Kanlı el
    "rbxassetid://10501565287",  -- Deforme yüz
    "rbxassetid://1312944167",   -- Korkunç yüz
    "rbxassetid://6197274297",   -- Gölge yaratık
    "rbxassetid://10501564550"   -- Şeytani gülümseme
}

-- TÜM KORKU SALDIRISINI BAŞLAT
local function startFullHorrorAttack()
    if isTrolling then return end
    isTrolling = true
    
    print("🚨 TROLLEME SALDIRISI BAŞLATILDI! 🚨")
    
    -- 1. EKRANI KAPAT (Siyah ekran)
    local blackScreen = Instance.new("Frame")
    blackScreen.Name = "BlackScreen"
    blackScreen.Size = UDim2.new(1, 0, 1, 0)
    blackScreen.Position = UDim2.new(0, 0, 0, 0)
    blackScreen.BackgroundColor3 = Color3.new(0, 0, 0)
    blackScreen.BackgroundTransparency = 0
    blackScreen.ZIndex = 1000
    blackScreen.Parent = playerGui
    
    -- 2. TÜM SESLERİ AYNI ANDA ÇAL
    for _, soundId in ipairs(horrorSounds) do
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = math.random(5, 10) / 10
        sound.Pitch = math.random(8, 15) / 10
        sound.Parent = workspace
        
        -- Rastgele gecikmeyle çal (kaos efekti)
        delay(math.random(0, 2) / 10, function()
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 10)
        end)
    end
    
    -- 3. YÜKSEK SESLİ JUMP SCARE SESİ
    local jumpscareSound = Instance.new("Sound")
    jumpscareSound.SoundId = "rbxassetid://376011982"  -- Jump scare
    jumpscareSound.Volume = 1.5
    jumpscareSound.Parent = workspace
    jumpscareSound:Play()
    game:GetService("Debris"):AddItem(jumpscareSound, 5)
    
    -- 4. ANİ EKRAN TİTREMESİ (ŞİDDETLİ)
    local camera = workspace.CurrentCamera
    local originalCFrame = camera.CFrame
    
    spawn(function()
        local intensity = 2  -- Çok şiddetli
        for i = 1, 50 do  -- 2 saniye boyunca
            local shakeX = math.random(-intensity * 100, intensity * 100) / 50
            local shakeY = math.random(-intensity * 100, intensity * 100) / 50
            local shakeZ = math.random(-intensity * 50, intensity * 50) / 50
            
            camera.CFrame = originalCFrame * CFrame.new(shakeX, shakeY, shakeZ)
            
            -- Döndürme efekti
            local rotX = math.random(-intensity * 10, intensity * 10) / 100
            local rotY = math.random(-intensity * 10, intensity * 10) / 100
            
            camera.CFrame = camera.CFrame * CFrame.Angles(rotX, rotY, 0)
            RunService.RenderStepped:Wait()
        end
        camera.CFrame = originalCFrame
    end)
    
    -- 5. KORKUNÇ GÖRÜNTÜLERİ EKRANA YAY
    wait(0.3)  -- Biraz bekle sonra görüntüler gelsin
    
    -- Fullscreen jump scare görüntüsü
    local jumpscareImage = Instance.new("ImageLabel")
    jumpscareImage.Name = "JumpScare"
    jumpscareImage.Size = UDim2.new(1, 0, 1, 0)
    jumpscareImage.Position = UDim2.new(0, 0, 0, 0)
    jumpscareImage.BackgroundColor3 = Color3.new(0, 0, 0)
    jumpscareImage.BackgroundTransparency = 1
    jumpscareImage.Image = scaryImages[math.random(1, #scaryImages)]
    jumpscareImage.ImageTransparency = 1
    jumpscareImage.ZIndex = 1001
    jumpscareImage.Parent = blackScreen
    
    -- Aniden belirsin
    local tween = TweenService:Create(
        jumpscareImage,
        TweenInfo.new(0.1, Enum.EasingStyle.Linear),
        {ImageTransparency = 0}
    )
    tween:Play()
    
    -- Fareyi takip eden hayaletler
    for i = 1, 15 do
        spawn(function()
            local ghost = Instance.new("ImageLabel")
            ghost.Name = "Ghost_" .. i
            ghost.Size = UDim2.new(0, math.random(100, 200), 0, math.random(100, 200))
            ghost.BackgroundTransparency = 1
            ghost.Image = scaryImages[math.random(1, #scaryImages)]
            ghost.ImageTransparency = math.random(3, 7) / 10
            ghost.ImageColor3 = Color3.fromRGB(255, math.random(50, 100), math.random(50, 100))
            ghost.ZIndex = 999
            ghost.Parent = blackScreen
            
            -- Fareyi takip et
            spawn(function()
                while ghost and ghost.Parent do
                    local mousePos = UserInputService:GetMouseLocation()
                    ghost.Position = UDim2.new(
                        0, mousePos.X + math.random(-200, 200),
                        0, mousePos.Y + math.random(-200, 200)
                    )
                    RunService.RenderStepped:Wait()
                end
            end)
            
            -- Titreme efekti
            spawn(function()
                while ghost and ghost.Parent do
                    local offsetX = math.random(-10, 10)
                    local offsetY = math.random(-10, 10)
                    ghost.Position = ghost.Position + UDim2.new(0, offsetX, 0, offsetY)
                    wait(0.05)
                end
            end)
            
            -- 5 saniye sonra kaybol
            delay(5, function()
                if ghost then
                    local fadeTween = TweenService:Create(
                        ghost,
                        TweenInfo.new(1, Enum.EasingStyle.Linear),
                        {ImageTransparency = 1}
                    )
                    fadeTween:Play()
                    fadeTween.Completed:Wait()
                    ghost:Destroy()
                end
            end)
        end)
        
        wait(math.random(1, 3) / 10)  -- Kademeli olarak çık
    end
    
    -- 6. EKRAN RENKLERİNİ BOZ (ÇOK KÖTÜ)
    local colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Name = "HorrorColor"
    colorCorrection.Brightness = -0.3
    colorCorrection.Contrast = 0.8
    colorCorrection.Saturation = -1
    colorCorrection.TintColor = Color3.fromRGB(255, 0, 0)
    colorCorrection.Parent = Lighting
    
    -- Renk değişim efekti
    spawn(function()
        for i = 1, 20 do
            colorCorrection.TintColor = Color3.fromRGB(
                math.random(150, 255),
                math.random(0, 50),
                math.random(0, 50)
            )
            wait(0.2)
        end
    end)
    
    -- 7. BULANIKLIK VE PARLAMA
    local blur = Instance.new("BlurEffect")
    blur.Name = "HorrorBlur"
    blur.Size = 15
    blur.Parent = Lighting
    
    local bloom = Instance.new("BloomEffect")
    bloom.Name = "HorrorBloom"
    bloom.Intensity = 1.5
    bloom.Size = 48
    bloom.Threshold = 0.2
    bloom.Parent = Lighting
    
    -- 8. KAN EFEKTLERİ (Ekranda akan kan)
    spawn(function()
        for i = 1, 8 do
            local blood = Instance.new("Frame")
            blood.Name = "Blood_" .. i
            blood.Size = UDim2.new(0, math.random(20, 50), 0, math.random(100, 300))
            blood.Position = UDim2.new(0, math.random(0, 1000), 0, -100)
            blood.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            blood.BackgroundTransparency = 0.5
            blood.BorderSizePixel = 0
            blood.ZIndex = 998
            blood.Parent = blackScreen
            
            -- Aşağı doğru ak
            local targetY = math.random(500, 800)
            local tween = TweenService:Create(
                blood,
                TweenInfo.new(math.random(3, 6), Enum.EasingStyle.Linear),
                {Position = UDim2.new(0, blood.Position.X.Offset, 0, targetY)}
            )
            tween:Play()
            
            -- Yavaşça kaybol
            delay(2, function()
                if blood then
                    local fadeTween = TweenService:Create(
                        blood,
                        TweenInfo.new(2, Enum.EasingStyle.Linear),
                        {BackgroundTransparency = 1}
                    )
                    fadeTween:Play()
                    fadeTween.Completed:Wait()
                    blood:Destroy()
                end
            end)
            
            wait(math.random(5, 15) / 10)
        end
    end)
    
    -- 9. YAZILAR (Korkutucu mesajlar)
    local scaryMessages = {
        "SENİ BULDUK",
        "ARKANA BAK",
        "BURADAYIM",
        "KAÇAMAZSIN",
        "GELİYORUM",
        "ÖLÜYORSUN",
        "SONUN GELDİ",
        "BENİ GÖRDÜN",
        "KAÇ!",
        "HAYATIN SONU"
    }
    
    spawn(function()
        for i = 1, 6 do
            local message = Instance.new("TextLabel")
            message.Name = "ScaryText"
            message.Size = UDim2.new(0, 300, 0, 60)
            message.Position = UDim2.new(
                0, math.random(100, 600),
                0, math.random(100, 400)
            )
            message.BackgroundTransparency = 1
            message.Text = scaryMessages[math.random(1, #scaryMessages)]
            message.TextColor3 = Color3.fromRGB(255, 0, 0)
            message.TextSize = math.random(24, 36)
            message.Font = Enum.Font.SourceSansBold
            message.TextTransparency = 1
            message.ZIndex = 1002
            message.Parent = blackScreen
            
            -- Yanıp sönme efekti
            spawn(function()
                for j = 1, 5 do
                    local tween1 = TweenService:Create(
                        message,
                        TweenInfo.new(0.3, Enum.EasingStyle.Linear),
                        {TextTransparency = 0}
                    )
                    tween1:Play()
                    tween1.Completed:Wait()
                    
                    wait(0.2)
                    
                    local tween2 = TweenService:Create(
                        message,
                        TweenInfo.new(0.3, Enum.EasingStyle.Linear),
                        {TextTransparency = 1}
                    )
                    tween2:Play()
                    tween2.Completed:Wait()
                    
                    wait(0.2)
                end
                message:Destroy()
            end)
            
            wait(math.random(5, 15) / 10)
        end
    end)
    
    -- 10. MOUSE'U KİLİTLE (Kaçamaz!)
    UserInputService.MouseIconEnabled = false
    
    -- 5 SANİYE SONRA HER ŞEYİ TEMİZLE
    delay(5, function()
        -- Ekranı yavaşça temizle
        if blackScreen then
            local fadeTween = TweenService:Create(
                blackScreen,
                TweenInfo.new(2, Enum.EasingStyle.Linear),
                {BackgroundTransparency = 1}
            )
            fadeTween:Play()
            
            -- Tüm çocukları temizle
            for _, child in ipairs(blackScreen:GetChildren()) do
                if child:IsA("ImageLabel") or child:IsA("TextLabel") or child:IsA("Frame") then
                    local childTween = TweenService:Create(
                        child,
                        TweenInfo.new(1, Enum.EasingStyle.Linear),
                        {BackgroundTransparency = 1, ImageTransparency = 1, TextTransparency = 1}
                    )
                    childTween:Play()
                end
            end
            
            fadeTween.Completed:Wait()
            blackScreen:Destroy()
        end
        
        -- Lighting efektlerini temizle
        if colorCorrection then colorCorrection:Destroy() end
        if blur then blur:Destroy() end
        if bloom then bloom:Destroy() end
        
        -- Mouse'u geri getir
        UserInputService.MouseIconEnabled = true
        
        -- Kamerayı sıfırla
        if camera then
            camera.CFrame = originalCFrame
        end
        
        isTrolling = false
        print("Trolleme saldırısı bitti!")
    end)
end

-- 11. OYUN İÇİ TETİKLEYİCİLER (Ekstra trolleme)
local function setupTriggers()
    -- F tuşuna basınca (ani trolleme)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
            startFullHorrorAttack()
        end
    end)
    
    -- B tuşuna basınca (daha hafif versiyon)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.B then
            spawn(function()
                -- Sadece ses ve küçük görüntü
                local sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://376011982"
                sound.Volume = 1
                sound.Parent = workspace
                sound:Play()
                
                local image = Instance.new("ImageLabel")
                image.Size = UDim2.new(0, 200, 0, 200)
                image.Position = UDim2.new(0.5, -100, 0.5, -100)
                image.Image = scaryImages[math.random(1, #scaryImages)]
                image.BackgroundTransparency = 1
                image.ZIndex = 1000
                image.Parent = playerGui
                
                wait(0.3)
                image:Destroy()
                game:GetService("Debris"):AddItem(sound, 3)
            end)
        end
    end)
    
    -- Rastgele zamanlarda otomatik trolleme (isteğe bağlı)
    spawn(function()
        while true do
            wait(math.random(60, 180))  -- 1-3 dakika arası
            if math.random(1, 100) <= 20 then  -- %20 şans
                startFullHorrorAttack()
            end
        end
    end)
end

-- BAŞLAT
setupTriggers()

print("🎃 TROLLEME SCRIPTİ HAZIR! 🎃")
print("Kontroller:")
print("- F tuşu: TÜM KORKU SALDIRISI (Full troll)")
print("- B tuşu: Hafif korkutma (Mini trol)")
print("")
print("⚠️  DİKKAT: Arkadaşını korkutmak için F tuşuna bas!")
print("⚠️  UYARI: Epilepsi hastaları için tehlikeli olabilir!")

-- GUI'de göster (opsiyonel)
local function createControlGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TrollControls"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 120)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.3
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Text = "🎮 TROLL KONTROLLERİ"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 50, 50)
    title.TextSize = 18
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local fKey = Instance.new("TextLabel")
    fKey.Text = "F Tuşu: FULL KORKU SALDIRISI"
    fKey.Size = UDim2.new(1, 0, 0, 25)
    fKey.Position = UDim2.new(0, 0, 0, 35)
    fKey.BackgroundTransparency = 1
    fKey.TextColor3 = Color3.fromRGB(255, 150, 150)
    fKey.TextSize = 14
    fKey.Parent = frame
    
    local bKey = Instance.new("TextLabel")
    bKey.Text = "B Tuşu: Mini Korkutma"
    bKey.Size = UDim2.new(1, 0, 0, 25)
    bKey.Position = UDim2.new(0, 0, 0, 60)
    bKey.BackgroundTransparency = 1
    bKey.TextColor3 = Color3.fromRGB(200, 200, 255)
    bKey.TextSize = 14
    bKey.Parent = frame
    
    local warning = Instance.new("TextLabel")
    warning.Text = "⚠️ Arkadaşını trolle!"
    warning.Size = UDim2.new(1, 0, 0, 25)
    warning.Position = UDim2.new(0, 0, 0, 85)
    warning.BackgroundTransparency = 1
    warning.TextColor3 = Color3.fromRGB(255, 255, 0)
    warning.TextSize = 12
    warning.Parent = frame
end

-- GUI'yi oluştur
createControlGUI()
