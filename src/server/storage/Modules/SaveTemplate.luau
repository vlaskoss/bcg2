local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gammaNum = require(ReplicatedStorage.Shared.Modules.GammaNum)

return {
    Clicks = gammaNum.fromNumber(10),
    Level = 1,
    Rebirths = 0,
    Upgrades = {
        AutoClicker = 0,
        ClickUpgrades = 0,
        ClickMultiplier = 0,
        TimePlayed = 0,
        ReduceLevelCost = 0,
        BaseBoost = 0,
        RemoveDebounce = false,
    },
    Settings = {
        BGMusic = true,
        SFX = true,
        VFX = true,
    },
    Statistics = {
        TotalTime = 0,
        TotalClicks = 0,
    }
} 