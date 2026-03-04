--[[
    MultiplierConfig.luau
    ─────────────────────────────────────────────────────────────────────────────
    Each entry defines one multiplier source.

    SHARED FIELDS
    ─────────────
    Category    "Base" | "Final"
                  Base   → sources are ADDED together, then used as the click value
                  Final  → sources are MULTIPLIED onto the base total at the end

    Type        "Flat" | "PerStat" | "PerUpgrade" | "Gamepass" | "Rebirth"
                (see per-type docs below)

    ─────────────────────────────────────────────────────────────────────────────
    TYPE: "Flat"
      A constant bonus, always active.
      Fields:
        Value (number)  – amount to contribute

    TYPE: "PerStat"
      Scales linearly with a player stat (Level, currency, etc.)
      Contribution = stat * ValuePerUnit
      Fields:
        Stat         (string)  – data key to read
        ValuePerUnit (number)  – multiplier per 1 unit of stat

    TYPE: "PerUpgrade"
      Reads an upgrade tier and maps it to a value via a fixed steps table OR
      a linear formula: Value = BaseValue + (tier * ValuePerTier)
      Using a steps table is recommended for "growable" upgrades like 1x/2x/3x
      so the value is always exactly what you list, not compounded.
      Fields:
        Upgrade      (string)             – upgrade key in data
        Steps        ({number}|nil)       – indexed by tier; Steps[tier] is the value
        BaseValue    (number|nil)         – fallback linear base  (if no Steps)
        ValuePerTier (number|nil)         – fallback linear slope (if no Steps)

    TYPE: "Gamepass"
      Active only when the player owns the gamepass.
      Fields:
        GamepassId (number)  – Roblox gamepass ID
        Value      (number)  – flat value to contribute while active

    TYPE: "Rebirth"
      Scales as: Value = MultiplierPerRebirth ^ rebirths
      Rebirths=0 → 1x (safe identity).
      Because this is exponential it belongs in "Final" nearly always.
      Fields:
        MultiplierPerRebirth (number)  – base of the exponent (e.g. 2 → 2^rebirths)
--]]

return {

    ---------------------------------------------------------------------------
    -- BASE sources  (added together to form the base click value)
    ---------------------------------------------------------------------------

    ["LevelBonus"] = {
        Type         = "PerStat",
        Category     = "Base",
        Stat         = "Level",
        ValuePerUnit = 1,  -- level 1 = 1, level 2 = 2, level 3 = 3
    },

    ["BaseBoost"] = {
        Type         = "PerUpgrade",
        Category     = "Base",
        Upgrade      = "BaseBoost",
        ValuePerTier =  10
    },

    ---------------------------------------------------------------------------
    -- FINAL multipliers  (multiplied together and applied to the base total)
    ---------------------------------------------------------------------------
    ["FlatRateMultiplier"] = {
        Type = "PerUpgrade",
        Category = "Final",
        Upgrade = "FlatRate",
        Steps = {
            [1] = 1.5
        }
    },
    
    ["ClickMultiplier"] = {
        Type     = "PerUpgrade",
        Category = "Final",
        Upgrade  = "ClickMultiplier",  
        Steps    = { 
            [1] = 2,   
            [2] = 3, 
            [3] = 4,
            [4] = 5,
            [5] = 6,
            [6] = 7,
            [7] = 8,
            [8] = 9,
            [9] = 10,
        },
    
    },

    ["TimePlayedMultiplier"] = {
    Type            = "TimePlayed",
    Category        = "Final",
    Stat            = "TotalTime",
    RequiredUpgrade = "TimePlayed", 
    },

    ["RebirthMultiplier"] = {
        Type                 = "Rebirth",
        Category             = "Final",
        MultiplierPerRebirth = 2,   -- 2^rebirths
    },

    ["RecursionMultiplier"] = {
        Type = "Recursion",
        Category = "Final",
        Upgrade = "Recursion"
    },

    ["ExponentsMultiplier"] = {
        Type = "Exponents",
        Category = "Exponent",
        Upgrade = "Exponents"
    },

    }
