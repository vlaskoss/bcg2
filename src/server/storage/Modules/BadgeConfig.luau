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
        Name = "1000 clicks",
        Type = "Currency",
        RelatedStat = "Clicks",
        Required = gammaNum.fromNumber(1000)
    }
}