local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local sharedFolder = ReplicatedStorage.Shared
local modulesFolder, remotesFolder, bindablesFolder, soundsFolder = sharedFolder.Modules, sharedFolder.Remotes, sharedFolder.Bindables, sharedFolder.Sounds

local dataInitEvent = bindablesFolder.DataInitEvent
local dataUpdateEvent = remotesFolder.DataUpdateEvent
local sfxEvent = bindablesFolder.SFXEvent
local stopSfxEvent = bindablesFolder.StopSFXEvent

local bgSoundOrigin = soundsFolder.Background.BG
local loadingSoundOrigin = soundsFolder.Interactive.LoadingSound

local bgMusicEnabled
local sfxEnabled

local bgSound

local activeSounds = {}

dataInitEvent.Event:Connect(function(data)

    bgMusicEnabled = data.Settings.BGMusic
    sfxEnabled = data.Settings.SFX

    Instance.new("Folder", script.Parent).Name = "SFX"
    if sfxEnabled then
        local loadingSound = loadingSoundOrigin:Clone()
        loadingSound.Parent = script.Parent.SFX
        loadingSound.Volume = 7.5
        loadingSound:Play()       
    end
    task.wait(3)
    bgSound = bgSoundOrigin:Clone()
    bgSound.Parent = script.Parent.SFX
    bgSound.Volume = 0
    bgSound.Looped = true

    local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(bgSound, tweenInfo, {Volume = 0.25})

    if bgMusicEnabled then
        bgSound:Play()
        tween:Play()
    end
end)

sfxEvent.Event:Connect(function(sfxSound, volume, looped, soundTag)
    if sfxSound then
        if not sfxEnabled then return end
        local soundClone = sfxSound:Clone()
        soundClone.Volume = volume or 0.5
        soundClone.Looped = looped or false
        soundClone.Parent = script.Parent.SFX

        if soundTag then
            if activeSounds[soundTag] then
                activeSounds[soundTag]:Destroy()
            end
            activeSounds[soundTag] = soundClone
        end
        
        soundClone:Play()
        soundClone.Ended:Connect(function()
            if soundTag and activeSounds[soundTag] == soundClone then
                activeSounds[soundTag] = nil
            end
            soundClone:Destroy()
        end)
    end
end)

stopSfxEvent.Event:Connect(function(soundTag)
    if activeSounds[soundTag] then
        activeSounds[soundTag]:Destroy()
        activeSounds[soundTag] = nil
    end
end)

dataUpdateEvent.OnClientEvent:Connect(function(data, updatedCurrency)
    if updatedCurrency == "BGMusic" or "SFX" then
        sfxEnabled = data.Settings.SFX
        bgMusicEnabled = data.Settings.BGMusic
        if updatedCurrency == "BGMusic" then
            if bgMusicEnabled == true then
                local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
                local tween = TweenService:Create(bgSound, tweenInfo, {Volume = 0.25})
                bgSound:Play()
                tween:Play()
            elseif bgMusicEnabled == false then
                local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
                local tween = TweenService:Create(bgSound, tweenInfo, {Volume = 0})
                tween:Play()
                tween.Completed:Connect(function()
                    bgSound:Stop()
                end) 
            end
        end
        if updatedCurrency == "SFX" then
            for _, sound in pairs(activeSounds) do
                activeSounds[sound] = nil
                script.Parent.SFX:ClearAllChildren()
            end
        end
    end
end)