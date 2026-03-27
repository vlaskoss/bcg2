local upgrades = {
    "AutoClicker",
    "Base2",
    "BaseBoost",
    "ClickMultiplier",
    "ExponentRecursion",
    "Exponents",
    "LevelMultibuy",
    "PyramidScheme",
    "Recursion",
    "ReduceLevelCost",
    "RemoveClickDebounce",
    "TimePlayed",
}

return function (registry)
    registry:RegisterType("upgrades", registry.Cmdr.Util.MakeEnumType("upgrades", upgrades))
end