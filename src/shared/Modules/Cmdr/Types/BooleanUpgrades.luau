local booleanUpgrades = {
    "RemoveClickDebounce",
    "LevelMultibuy",
    "PyramidScheme",
    "ExponentRecursion",

}
return function (registry)
    registry:RegisterType("booleanUpgrades", registry.Cmdr.Util.MakeEnumType("booleanUpgrades", booleanUpgrades))
end