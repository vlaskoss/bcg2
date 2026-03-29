local BadgeService = game:GetService("BadgeService")
local PlayersService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local serverFolder = ServerStorage.Server
local sharedFolder = ReplicatedStorage.Shared

local dataUpdateBindable = serverFolder.BindableEvents.DataUpdateBindable
local dataInitBindable = serverFolder.BindableEvents.DataInitBindable

local badgeConfig = require(serverFolder.Modules.BadgeConfig)
local gammaNum = require(sharedFolder.Modules.GammaNum)

local badgesByStat = {}
for badgeId, criteria in pairs(badgeConfig) do
    if criteria.Type == "Currency" then
        if not badgesByStat[criteria.RelatedStat] then
            badgesByStat[criteria.RelatedStat] = {}
        end
        table.insert(badgesByStat[criteria.RelatedStat], { id = badgeId, criteria = criteria })
    end
end

local earnedBadges = {}
local pendingBadges = {}

local function loadPlayerBadges(player)
    local userId = player.UserId
    earnedBadges[userId] = {}
    pendingBadges[userId] = {}

    for badgeId in pairs(badgeConfig) do
        local success, alreadyOwned = pcall(BadgeService.UserHasBadgeAsync, BadgeService, userId, badgeId)
        if success and alreadyOwned then
            earnedBadges[userId][badgeId] = true
        end
    end
end

local function awardBadge(player, badgeId, badgeName)
    local userId = player.UserId
    earnedBadges[userId] = earnedBadges[userId] or {}
    pendingBadges[userId] = pendingBadges[userId] or {}

    if earnedBadges[userId][badgeId] or pendingBadges[userId][badgeId] then return end
    pendingBadges[userId][badgeId] = true

    local success = pcall(BadgeService.AwardBadgeAsync, BadgeService, userId, badgeId)
    if success then
        print(`[BadgeHandler]: Awarded badge {badgeName} to {player.Name}`)
        earnedBadges[userId][badgeId] = true
    else
        warn(`[BadgeHandler]: Failed to award badge {badgeName} for {player.Name}`)
    end

    pendingBadges[userId][badgeId] = nil
end

local function checkBadges(player, data, updatedCurrency)
    if not player or not player.Parent then return end

    local relevantBadges = badgesByStat[updatedCurrency]
    if not relevantBadges then return end

    local owned = earnedBadges[player.UserId]
    local value = data[updatedCurrency]
    if value == nil then return end

    for _, badge in ipairs(relevantBadges) do
        if owned and owned[badge.id] then continue end
        local qualifies = if badge.criteria.Exact
            then gammaNum.eq(value, badge.criteria.Required)
            else gammaNum.gte(value, badge.criteria.Required)
        if qualifies then
            awardBadge(player, badge.id, badge.criteria.Name)
        end
    end
end

PlayersService.PlayerRemoving:Connect(function(player)
    earnedBadges[player.UserId] = nil
    pendingBadges[player.UserId] = nil
end)

dataUpdateBindable.Event:Connect(function(player, data, updatedCurrency)
    if not player or not data or not updatedCurrency then
        warn("[BadgeHandler]: dataUpdateBindable missing required args")
        return
    end
    checkBadges(player, data, updatedCurrency)
end)

dataInitBindable.Event:Connect(loadPlayerBadges)