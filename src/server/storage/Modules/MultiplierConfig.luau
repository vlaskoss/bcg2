return {
    ["Rebirths"] = {
        Type = "Rebirth",
        MultiplierPerLevel = 2,
        Category = "Final",
    },
    ["Level"] = {
        Type = "Level",
        MultiplierPerLevel = 1, 
        Category = "Base"
    },
    ["DoubleClicks"] = {
        Type = "Upgrade",
        RelatedStat = "DoubleClicks",
        Multiplier = 2,
        Category = "Final"
    },
    ["TripleClicks"] = {
        Type = "Upgrade",
        RelatedStat = "TripleClicks",
        Multiplier = 3,
        Category = "Final"
    },
    ["QuadrupleClicks"] = {
        Type = "Upgrade",
        RelatedStat = "QuadrupleClicks",
        Multiplier = 4,
        Category = "Final"
    },
    ["QuintupleClicks"] = {
        Type = "Upgrade",
        RelatedStat = "QuintupleClicks",
        Multiplier = 5,
        Category = "Final"
    },
    ["TimePlayed"] = {
        Type = "Statistic",
        RequiredStat = "TimePlayed",
        RelatedStat = "TotalTime",
        MultiplierFormula = "TimePlayedFormula",
        Category = "Final"
    }
}