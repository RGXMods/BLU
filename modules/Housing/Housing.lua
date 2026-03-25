--=====================================================================================
-- BLU Housing Module
-- Handles housing-related progression and collection sounds
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local Housing = {}

local HOUSING_EVENT_ID_FAVOR = "housing_level_favor_updated"
local HOUSING_EVENT_ID_LEVEL = "housing_level_changed"
local HOUSING_EVENT_ID_REWARDS = "housing_level_rewards"
local HOUSING_EVENT_ID_CHEST = "housing_decor_added_to_chest"
local HOUSING_EVENT_ID_ACQUIRED = "housing_item_acquired"
local HOUSING_EVENT_ID_INFO_RECEIVED = "housing_current_house_info_received"
local HOUSING_EVENT_ID_INFO_UPDATED = "housing_current_house_info_updated"

local DECOR_ITEM_TYPE = 3
local DECOR_DEDUPE_SECONDS = 0.50

Housing.houseFavorByGUID = {}
Housing.houseLevelByGUID = {}
Housing.lastDecorCollectAt = 0

local function IsDecorItemType(itemType)
    if itemType == DECOR_ITEM_TYPE then
        return true
    end

    if type(itemType) == "string" then
        return string.lower(itemType) == "decor"
    end

    return false
end

local function IsHousingEnabled()
    if not (BLU.db and BLU.db.profile) then
        return false
    end

    if BLU.db.profile.enabled == false then
        return false
    end

    if BLU.db.profile.enableHousing == false then
        return false
    end

    if BLU.db.profile.modules and BLU.db.profile.modules.housing == false then
        return false
    end

    return true
end

function Housing:Init()
    BLU:RegisterEvent("HOUSE_LEVEL_FAVOR_UPDATED", function(...) self:OnHouseFavorUpdated(...) end, HOUSING_EVENT_ID_FAVOR)
    BLU:RegisterEvent("HOUSE_LEVEL_CHANGED", function(...) self:OnHouseLevelChanged(...) end, HOUSING_EVENT_ID_LEVEL)
    BLU:RegisterEvent("RECEIVED_HOUSE_LEVEL_REWARDS", function(...) self:OnHouseRewardsReceived(...) end, HOUSING_EVENT_ID_REWARDS)
    BLU:RegisterEvent("HOUSE_DECOR_ADDED_TO_CHEST", function(...) self:OnDecorAddedToChest(...) end, HOUSING_EVENT_ID_CHEST)
    BLU:RegisterEvent("NEW_HOUSING_ITEM_ACQUIRED", function(...) self:OnNewHousingItemAcquired(...) end, HOUSING_EVENT_ID_ACQUIRED)
    BLU:RegisterEvent("CURRENT_HOUSE_INFO_RECIEVED", function(...) self:OnCurrentHouseInfo(...) end, HOUSING_EVENT_ID_INFO_RECEIVED)
    BLU:RegisterEvent("CURRENT_HOUSE_INFO_UPDATED", function(...) self:OnCurrentHouseInfo(...) end, HOUSING_EVENT_ID_INFO_UPDATED)

    BLU:PrintDebug("[Housing] Housing module initialized")
end

function Housing:Cleanup()
    BLU:UnregisterEvent("HOUSE_LEVEL_FAVOR_UPDATED", HOUSING_EVENT_ID_FAVOR)
    BLU:UnregisterEvent("HOUSE_LEVEL_CHANGED", HOUSING_EVENT_ID_LEVEL)
    BLU:UnregisterEvent("RECEIVED_HOUSE_LEVEL_REWARDS", HOUSING_EVENT_ID_REWARDS)
    BLU:UnregisterEvent("HOUSE_DECOR_ADDED_TO_CHEST", HOUSING_EVENT_ID_CHEST)
    BLU:UnregisterEvent("NEW_HOUSING_ITEM_ACQUIRED", HOUSING_EVENT_ID_ACQUIRED)
    BLU:UnregisterEvent("CURRENT_HOUSE_INFO_RECIEVED", HOUSING_EVENT_ID_INFO_RECEIVED)
    BLU:UnregisterEvent("CURRENT_HOUSE_INFO_UPDATED", HOUSING_EVENT_ID_INFO_UPDATED)

    BLU:PrintDebug("[Housing] Housing module cleaned up")
end

function Housing:OnCurrentHouseInfo(event, houseInfo)
    if type(houseInfo) ~= "table" then
        return
    end

    local houseGUID = houseInfo.houseGUID or "current"
    local houseFavor = tonumber(houseInfo.houseFavor or houseInfo.levelFavor)
    local houseLevel = tonumber(houseInfo.houseLevel or houseInfo.level)

    if houseFavor then
        self.houseFavorByGUID[houseGUID] = houseFavor
    end

    if houseLevel then
        self.houseLevelByGUID[houseGUID] = houseLevel
    end
end

function Housing:OnHouseFavorUpdated(event, houseLevelFavor)
    if not IsHousingEnabled() or type(houseLevelFavor) ~= "table" then
        return
    end

    local houseGUID = houseLevelFavor.houseGUID or "current"
    local newFavor = tonumber(houseLevelFavor.houseFavor) or 0
    local lastFavor = self.houseFavorByGUID[houseGUID]
    self.houseFavorByGUID[houseGUID] = newFavor

    if lastFavor ~= nil and newFavor > lastFavor then
        BLU:PlayCategorySound("housingxpgained")
    end
end

function Housing:OnHouseLevelChanged(event, newHouseLevelInfo)
    if not IsHousingEnabled() or type(newHouseLevelInfo) ~= "table" then
        return
    end

    local houseGUID = newHouseLevelInfo.houseGUID or "current"
    local newLevel = tonumber(newHouseLevelInfo.level) or 0
    local lastLevel = self.houseLevelByGUID[houseGUID]
    self.houseLevelByGUID[houseGUID] = newLevel

    if lastLevel ~= nil and newLevel > lastLevel then
        BLU:PlayCategorySound("housingleveledup")
    end
end

function Housing:OnHouseRewardsReceived(event, level, rewards)
    if not IsHousingEnabled() then
        return
    end

    BLU:PlayCategorySound("housingrewardsreceived")
end

function Housing:MarkDecorCollected()
    self.lastDecorCollectAt = GetTime and GetTime() or 0
    BLU:PlayCategorySound("housingdecorcollected")
end

function Housing:OnDecorAddedToChest(event, decorGUID, decorID)
    if not IsHousingEnabled() then
        return
    end

    self:MarkDecorCollected()
end

function Housing:OnNewHousingItemAcquired(event, itemType, itemName, icon)
    if not IsHousingEnabled() then
        return
    end

    if not IsDecorItemType(itemType) then
        return
    end

    local now = GetTime and GetTime() or 0
    if self.lastDecorCollectAt and (now - self.lastDecorCollectAt) < DECOR_DEDUPE_SECONDS then
        return
    end

    self:MarkDecorCollected()
end

BLU.Modules = BLU.Modules or {}
BLU.Modules["housing"] = Housing

return Housing
