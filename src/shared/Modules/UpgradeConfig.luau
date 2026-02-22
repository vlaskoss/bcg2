local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gammaNum = require(ReplicatedStorage.Shared.Modules.GammaNum)

return {
    ["Level"] = {
        Type = "Infinite",
        Priority = 1,
        StatType = "Level",
        RelatedStat = "Level",
        CostFormula = "LevelCost",
        DisplayName = function(current)
            return "Level " .. tostring(current)
        end,
        Description = "Increases the power of your clicks!",
        IsPermanent = false
    }, 
    ["AutoClicker"] = {
        Type = "Tiered",
        MaxTier = 15,
        Priority = 2,
        StatType = "Upgrade",
        RelatedStat = "AutoClicker",
        Tiers = {
            [1] = {DisplayName = "Autoclicker", Description = "Automatically clicks for you at a sluggish rate (2 cps)"}, -- 50
            [2] = {Description = "Upgrade the speed of your sluggish autoclicker! (4 cps)"}, -- 500
            [3] = {Description = "Upgrade your autoclicker's speed! (6 cps) "}, -- 5000
            [4] = {Description = "Upgrade your autoclicker's speed! (8 cps)"},
            [5] = {Description = "This is getting fast! 10 CPS autoclicking!!"}, -- 500k
            [6] = {Description = "Upgrade your autoclicker's speed! (12 cps)"}, -- 5m
            [7] = {Description = "Upgrade your autoclicker's speed! (14 cps)"},
            [8] = {Description = "Upgrade your autoclicker's speed! (16 cps)"},
            [9] = {Description = "Upgrade your autoclicker's speed! (18 cps)"},
            [10] = {Description = "20CPS? HOLYYY THATS FAST"},
            [11] = {Description = "Upgrade your autoclicker to 25 cps!"},
            [12] = {Description = "Upgrade your autoclicker to 30 cps!"},
            [13] = {Description = "Upgrade your autoclicker to 35 cps!"},
            [14] = {Description = "Upgrade your autoclicker to 40 cps!"},
            [15] = {Description = "THE FINAL SPEED.. 50CPS! OR IS IT??"}
        },
        CostFormula = "AutoClickerCost",
        DisplayName = function(current)
            return "Autoclicker " .. tostring(current)
        end, 
        IsPermanent = true
    },
    ["TimePlayed"] = {
        Type = "Single",
        Priority = 3,
        StatType = "Upgrade",
        RelatedStat = "TimePlayed",
        Cost = gammaNum.fromNumber(500),
        DisplayName = "The Long Game",
        Description = "Multiplies your clicks based on your playtime",
        IsPermanent = true
    },
    ["ReduceLevelCost"] = {
        Type = "Tiered",
        MaxTier = 50,
        Priority = 4,
        StatType = "Upgrade",
        RelatedStat = "ReduceLevelCost",
        CostFormula = "ReduceLevelCost",
        DisplayName = "Deflation",
        Description = "Reduces level cost by 0.01x (additive) per upgrade",
        IsPermanent = true
    },
    ["DoubleClicks"] = {
        Type = "Single",
        Priority = 5,
        StatType = "Upgrade",
        RelatedStat = "DoubleClicks",
        Cost = gammaNum.fromNumber(100),
        DisplayName = "2x Clicks",
        Description = "A small multiplier",
        IsPermanent = false
    },
    ["TripleClicks"] = {
        Type = "Single",
        Priority = 6,
        StatType = "Upgrade",
        RelatedStat = "TripleClicks",
        Cost = gammaNum.fromNumber(10000),
        DisplayName = "3x Clicks",
        Description = "A healthy multiplier",
        IsPermanent = false
    },
    ["QuadrupleClicks"] = {
        Type = "Single",
        Priority = 7,
        StatType = "Upgrade",
        RelatedStat = "QuadrupleClicks",
        Cost = gammaNum.fromNumber(100000),
        DisplayName = "4x Clicks",
        Description = "A big multiplier",
        IsPermanent = false
    },
    ["QuintupleClicks"] = {
        Type = "Single",
        Priority = 8,
        StatType = "Upgrade",
        RelatedStat = "QuintupleClicks",
        Cost = gammaNum.fromNumber(1000000),
        DisplayName = "5x Clicks",
        Description = "A huge multiplier",
        IsPermanent = false
    },
}