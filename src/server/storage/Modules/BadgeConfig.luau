local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gammaNum = require(ReplicatedStorage.Shared.Modules.GammaNum)

return {
    [1395790761766017] = {
        Name = "join the game",
        Type = "Currency",
        RelatedStat = "Clicks",
        Required = gammaNum.fromNumber(1)
    },
    [237626552005175] = {
        Name = "experience hell",
        Type = "Currency",
        RelatedStat = "Clicks",
        Required = gammaNum.fromNumber(67),
        Exact = true
    },
    [1463325682098749] = {
        Name = "100 clicks",
        Type = "Currency",
        RelatedStat = "Clicks",
        Required = gammaNum.fromNumber(100)
    },
    [4038736842497206] = {
        Name = "1,000 clicks",
        Type = "Currency",
        RelatedStat = "Clicks",
        Required = gammaNum.fromNumber(1000)
    },
    [2528389491983139] = {
        Name = "1 million clicks",
        Type = "Currency",
        RelatedStat = "Clicks",
        Required = gammaNum.fromNumber(1000000)
    },
    [2986165415498419] = {
        Name = "1 billion clicks",
        Type = "Currency",
        RelatedStat = "Clicks",
        Required = gammaNum.fromNumber(1000000000)
    },
    [3801242592251386] = {
        Name = "1 rebirth",
        Type = "Currency",
        RelatedStat = "Rebirths",
        Required = 1
    },
    [1946702413100920] = {
        Name = "10 rebirths",
        Type = "Currency",
        RelatedStat = "Rebirths",
        Required = 10
    },    
}