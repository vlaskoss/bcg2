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
                   before this upgrade appears/is purchasable.
                   Example: RequiredUpgrade = "TimePlayed"

    RequiredLevel    (number | nil)
                   Player's Level stat must be >= this value to unlock.

    OnUpgrade    (function(player, newTier) | nil)
                   Optional server-side callback fired after a successful purchase.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gammaNum = require(ReplicatedStorage.Shared.Modules.GammaNum)

return {
    ["Level"] = {
        Type        = "Infinite",
        Priority    = 1,
        StatType    = "Level",
        RelatedStat = "Level",
        CostFormula = "LevelCost",
        DisplayName = function(current)
            return "Level " .. tostring(current)
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
        Type        = "Single",
        Priority    = 3,
        StatType    = "Upgrade",
        RelatedStat = "TimePlayed",
        Cost        = gammaNum.fromNumber(500),
        DisplayName = "The Long Game",
        Description = "Multiplies your clicks based on your total playtime.",
        IsPermanent = true,
        RequiredLevel = 5,
        -- no RequiredUpgrade → always visible
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
        RequiredLevel = 5,
    },

    ["ClickMultiplier"] = {
        Type        = "Tiered",
        MaxTier     = 4,
        Priority    = 5,
        StatType    = "Upgrade",
        RelatedStat = "ClickMultiplier",
        CostFormula = "ClickMultiplierCost",
        IsPermanent = false,
        Tiers = {
            [1] = { DisplayName = "2x Clicks", Description = "A small multiplier." },
            [2] = { DisplayName = "3x Clicks", Description = "A healthy multiplier." },
            [3] = { DisplayName = "4x Clicks", Description = "A big multiplier." },
            [4] = { DisplayName = "5x Clicks", Description = "A huge multiplier." },
        },
        RequiredLevel = 2,
    },

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
