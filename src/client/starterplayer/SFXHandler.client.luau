local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local sharedFolder = ReplicatedStorage.Shared
local modulesFolder, remotesFolder, bindablesFolder, soundsFolder = sharedFolder.Modules, sharedFolder.Remotes, sharedFolder.Bindables, sharedFolder.Sounds

local dataInitEvent = remotesFolder.DataInitEvent
local sfxEvent = bindablesFolder.SFXEvent
local stopSfxEvent = bindablesFolder.StopSFXEvent

local bgSoundOrigin = soundsFolder.Background.BG
local loadingSoundOrigin = soundsFolder.Interactive.LoadingSound

local activeSounds = {}

dataInitEvent.OnClientEvent:Connect(function()
    Instance.new("Folder", script.Parent).Name = "SFX"
    local loadingSound = loadingSoundOrigin:Clone()
    loadingSound.Parent = script.Parent.SFX
    loadingSound.Volume = 5
    loadingSound:Play()
    task.wait(3)
    local bgSound = bgSoundOrigin:Clone()
    bgSound.Parent = script.Parent.SFX
    bgSound.Volume = 0
    bgSound.Looped = true
    bgSound:Play()

    local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(bgSound, tweenInfo, {Volume = 0.25})
    tween:Play()
end)

sfxEvent.Event:Connect(function(sfxSound, volume, looped, soundTag)
    if sfxSound then
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