local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gammaNum = require(ReplicatedStorage.Shared.Modules.GammaNum)

return {
    Clicks = gammaNum.fromNumber(10),
    Level = 1,
    Rebirths = 0,
    Upgrades = {
        -- numbers
        AutoClicker = 0,
        ClickMultiplier = 0,
        TimePlayed = 0,
        ReduceLevelCost = 0,
        BaseBoost = 0,
        Recursion = 0,
        Exponents = 0,
        Base2 = 0,

        -- booleans
        RemoveClickDebounce = false,
        LevelMultibuy = false,
        
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