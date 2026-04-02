--[[
    MultiplierConfig.luau
    ──────────────────────────────────────────────────────────────────
    Each entry defines one multiplier source used by ClickCalculationManager.

    CATEGORIES
    ──────────
    "Base"      → values are SUMMED into baseTotal
    "Final"     → values are MULTIPLIED into finalTotal
    "Exponent"  → values are SUMMED into exponentTotal
    
    Formula:  clickValue = (baseTotal × finalTotal) ^ exponentTotal

    TYPES
    ──────
    Flat          Always-on constant bonus.
                    Value (number)

    PerStat       Scales with a player stat: stat × ValuePerUnit
                    Stat (string), ValuePerUnit (number)

    PerUpgrade    Maps an upgrade tier to a value.
                  Use Steps for exact values per tier, or BaseValue + ValuePerTier
                  for a simple linear formula.
                    Upgrade (string)
                    Steps        ({[tier] = value})   -- recommended
                    BaseValue    (number)              -- linear fallback
                    ValuePerTier (number)              -- linear fallback

    Gamepass      Active only when the player owns the gamepass.
                    GamepassId (number), Value (number)

    Rebirth       Exponential: MultiplierPerRebirth ^ rebirths
                  Rebirths = 0 → 1× (safe identity). Best used as "Final".
                    MultiplierPerRebirth (number)
--]]

return {

    ---------------------------------------------------------------------------
    -- BASES
    ---------------------------------------------------------------------------

    ["Level"] = {
        Type         = "PerStat",
        Category     = "Base",
        Stat         = "Level",
        ValuePerUnit = 1,       -- +1 per level
    },

    ["BaseBoost"] = {
        Type         = "PerUpgrade",
        Category     = "Base",
        Upgrade      = "BaseBoost",
        ValuePerTier = 5,
    },

    ["Base2"] = {
        Type     = "Base2",
        Category = "Base",
    },

    ---------------------------------------------------------------------------
    -- FINALS
    ---------------------------------------------------------------------------

    ["ClickMultiplier"] = {
        Type     = "PerUpgrade",
        Category = "Final",
        Upgrade  = "ClickMultiplier",
        Steps    = {
            [1] = 2,  [2] = 3,  [3] = 4,
            [4] = 5,  [5] = 6,  [6] = 7,
            [7] = 8,  [8] = 9,  [9] = 10,
        },
    },

    ["TimePlayed"] = {
        Type     = "TimePlayed",
        Category = "Final",
    },

    ["Rebirths"] = {
        Type     = "Rebirth",
        Category = "Final",
    },

    ["Recursion"] = {
        Type     = "Recursion",
        Category = "Final",
    },

    ["ServerAge"] = {
        Type     = "ServerAge",
        Category = "Final",
    },

    ---------------------------------------------------------------------------
    -- EXPONENTS
    ---------------------------------------------------------------------------

    ["Exponents"] = {
        Type     = "Exponents",
        Category = "Exponent",
    },

    ["PyramidScheme"] = {
        Type     = "PyramidScheme",
        Category = "Exponent",
    },

    ["ExponentRecursion"] = {
        Type     = "ExponentRecursion",
        Category = "Exponent",
    },
}
