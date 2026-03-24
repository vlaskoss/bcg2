local upgrades = {
    "AutoClicker",
    "ClickMultiplier",
    "TimePlayed",
    "ReduceLevelCost",
    "BaseBoost",
    "Recursion",
    "Exponents",
    "Base2",
    
}
return function (registry)
    registry:RegisterType("upgrades", registry.Cmdr.Util.MakeEnumType("upgrades", upgrades))
end