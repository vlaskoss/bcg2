--[[
    UpgradeConfig.luau
    ─────────────────────────────────────────────────────────────────────────────
    Defines every purchasable upgrade in the game.

    SHARED FIELDS (all upgrades)
    ─────────────────────────────
    Type         "Infinite" | "Finite" | "Single" | "Tiered"
                   Infinite → no cap, keeps going
                   Finite   → capped at MaxLevel
                   Single   → one-time purchase (tier 0 or 1)
                   Tiered   → fixed list of tiers defined in Tiers table

    StatType     "Level" | "Upgrade"
                   Level   → uses RetrieveAmount / AddCurrency
                   Upgrade → uses GetUpgrade / SetUpgrade

    RelatedStat  (string) data key this upgrade reads/writes

    Priority     (number) UI sort order, lower = higher up

    DisplayName  (string | function(currentTier) → string)

    Description  (string) shown in UI; Tiered upgrades can override per tier

    IsPermanent  (bool) whether the upgrade survives rebirths

    CostFormula  (string | nil) name of formula module in UpgradeFormulas folder
    Cost         (GammaNum | nil) flat cost fallback if no CostFormula

    MaxLevel     (number | nil) cap for Finite type
    MaxTier      (number | nil) cap for Tiered type

    Tiers        ({[n] = {DisplayName?, Description?, Cost?}} | nil)
                   Tiered upgrades define per-tier display overrides here.

    RequiredUpgrade  (string | nil)
                   If set, the player must own at least tier 1 of this upgrade
                   (or the tier specified by RequiredUpgradeTier) before this
                   upgrade appears/is purchasable.
                   Example: RequiredUpgrade = "TimePlayed"

    RequiredUpgradeTier  (number | nil)
                   Works together with RequiredUpgrade. When set, the referenced
                   upgrade must be at THIS tier or higher (instead of the default
                   of >= 1). Ignored if RequiredUpgrade is not also set.
                   Example: RequiredUpgrade = "AutoClicker", RequiredUpgradeTier = 5
                            → hidden until the player owns AutoClicker tier 5+

    RequiredLevel    (number | nil)
                   Player's Level stat must be >= this value to unlock.

    OnUpgrade    (function(player, newTier) | nil)
                   Optional server-side callback fired after a successful purchase.
--]]

local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gammaNum = require(ReplicatedStorage.Shared.Modules.GammaNum)
local gameUtils = require(ReplicatedStorage.Shared.Modules.GameUtils)

return {
    ["Level"] = {
        Type        = "Infinite",
        Priority    = 1,
        StatType    = "Level",
        RelatedStat = "Level",
        CostFormula = "LevelCost",
        DisplayName = function(current)
            return "Level " .. tostring(gameUtils:FormatSeparators(current))
        end,
        Description = "Increases the power of your clicks!",
        IsPermanent = false,
    },
    ["AutoClicker"] = {
        Type        = "Tiered",
        MaxTier     = 15,
        Priority    = 2,
        StatType    = "Upgrade",
        RelatedStat = "AutoClicker",
        CostFormula = "AutoClickerCost",
        DisplayName = function(current)
            return "Autoclicker " .. tostring(current)
        end,
        Tiers = {
            [1]  = { DisplayName = "Autoclicker",  Description = "Automatically clicks for you at a sluggish rate (2 cps)" },
            [2]  = { Description = "Upgrade the speed of your sluggish autoclicker! (4 cps)" },
            [3]  = { Description = "Upgrade your autoclicker's speed! (6 cps)" },
            [4]  = { Description = "Upgrade your autoclicker's speed! (8 cps)" },
            [5]  = { Description = "This is getting fast! 10 CPS autoclicking!!" },
            [6]  = { Description = "Upgrade your autoclicker's speed! (12 cps)" },
            [7]  = { Description = "Upgrade your autoclicker's speed! (14 cps)" },
            [8]  = { Description = "Upgrade your autoclicker's speed! (16 cps)" },
            [9]  = { Description = "Upgrade your autoclicker's speed! (18 cps)" },
            [10] = { Description = "20 CPS? HOLY THAT'S FAST" },
            [11] = { Description = "Upgrade your autoclicker to 25 cps!" },
            [12] = { Description = "Upgrade your autoclicker to 30 cps!" },
            [13] = { Description = "Upgrade your autoclicker to 35 cps!" },
            [14] = { Description = "Upgrade your autoclicker to 40 cps!" },
            [15] = { Description = "THE FINAL SPEED.. 50 CPS! OR IS IT??" },
        },
        IsPermanent = true,
        RequiredLevel = 2,
    },
    ["TimePlayed"] = {
        Type        = "Tiered",
        Priority    = 3,
        StatType    = "Upgrade",
        MaxTier = 50,
        RelatedStat = "TimePlayed",
        CostFormula = "TimePlayedCost",
        DisplayName = "The Long Game",
        Tiers = {
            [1] = {Description = "Multiplies your clicks based on your total playtime."}
        },
        Description = "Upgrades the TimePlayed formula",
        IsPermanent = true,
        RequiredUpgrade = "ClickMultiplier",
        RequiredUpgradeTier = 9,
    },
    ["ReduceLevelCost"] = {
        Type        = "Tiered",
        MaxTier     = 50,
        Priority    = 4,
        StatType    = "Upgrade",
        RelatedStat = "ReduceLevelCost",
        CostFormula = "ReduceLevelCost",
        DisplayName = "Deflation",
        Description = "Reduces level cost by 0.01x (additive) per tier.",
        IsPermanent = true,
        RequiredLevel = 25,
    },

    ["ClickMultiplier"] = {
        Type        = "Tiered",
        MaxTier     = 9,
        Priority    = 5,
        StatType    = "Upgrade",
        RelatedStat = "ClickMultiplier",
        CostFormula = "ClickMultiplierCost",
        DisplayName = function(current)
            return (current + 1) .. "x Clicks"
        end,
        Description = "+1x clicks per upgrade!",
        IsPermanent = false,
        Tiers = {
            [1] = { Description = "A small 2x clicks multiplier." },
        },
        RequiredLevel = 5,
    },

    ["BaseBoost"] = {
        Type        = "Finite",
        MaxLevel     = 5,
        Priority    = 6,
        StatType    = "Upgrade",
        RelatedStat = "BaseBoost",
        CostFormula = "BaseBoostCost",
        DisplayName = "Back to Basics",
        Description = "+5 base clicks per tier.",
        IsPermanent = false,
        RequiredLevel = 15,
    },

    ["Recursion"] = {
        Type = "Tiered",
        MaxTier = 5,
        Priority = 7,
        StatType = "Upgrade",
        RelatedStat = "Recursion",
        CostFormula = "RecursionCost",
        DisplayName = "Recursion",
        Description = "Improves the Recursion formula by +0.25x",
        Tiers = {
            [1] = {Description = "Multiplies clicks by the number of clicks you currently have."}
        },
        IsPermanent = false,
        RequiredLevel = 125
    },
    
    ["Exponents"] = {
        Type = "Tiered",
        MaxTier = 5,
        Priority = 8,
        StatType = "Upgrade",
        RelatedStat = "Exponents",
        CostFormula = "ExponentsCost",
        DisplayName = "Exponents!",
        Description = "+ ^.05 exponent per upgrade",
        Tiers = {
            [1] = {Description = "An exponent of ^1.05 after all other multipliers!"}
        },
        IsPermanent = true,
        RequiredLevel = 100
    },

    ["Base2"] = {
        Type = "Infinite",
        Priority = 10,
        StatType = "Upgrade",
        RelatedStat = "Base2",
        CostFormula = "Base2Cost",
        DisplayName = function(current)
            if current >= 1 then
                return `Base 2 ({gameUtils:FormatSeparators(current)})`
            else
                return "Base 2"
            end
        end,
        Description = "Cost increases 2x per upgrade, but so do clicks!",
        IsPermanent = false,
        RequiredLevel = 50
    },

    ["RemoveClickDebounce"] = {
        Type = "Single",
        Priority = 11,
        StatType = "Upgrade",
        RelatedStat = "RemoveClickDebounce",
        Cost = gammaNum.fromNumber(50000),
        DisplayName = "Freedom",
        Description = "Removes the click debounce for manual clicks!",
        IsPermanent = true,
        RequiredLevel = 75
    },

    ["LevelMultibuy"] = {
        Type = "Single",
        Priority = 11,
        StatType = "Upgrade",
        RelatedStat = "LevelMultibuy",
        Cost = gammaNum.fromNumber(25000),
        DisplayName = "Freedom",
        Description = "Removes the click debounce for manual clicks!",
        IsPermanent = true,
        RequiredLevel = 75
    }
    --[[
        EXAMPLE: upgrade locked behind another upgrade

        ["DoubleClickMultiplier"] = {
            Type             = "Single",
            Priority         = 6,
            StatType         = "Upgrade",
            RelatedStat      = "DoubleClickMultiplier",
            Cost             = gammaNum.fromNumber(10000),
            DisplayName      = "Double Down",
            Description      = "Doubles your click multiplier.",
            IsPermanent      = false,
            RequiredUpgrade  = "ClickMultiplier",   -- hidden until ClickMultiplier tier >= 1
            -- RequiredLevel = 10,                  -- also optionally gate by level
        },
    --]]
}
