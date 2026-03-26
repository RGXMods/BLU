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
local HOUSING_EVENT_ID_ACQUIRED = "housing_item_acquired"
local HOUSING_EVENT_ID_INFO_RECEIVED = "housing_current_house_info_received"
local HOUSING_EVENT_ID_INFO_UPDATED = "housing_current_house_info_updated"

-- Enum.HousingItemToastType 3 = Decor
local DECOR_ITEM_TYPE = 3
local DECOR_DEDUPE_SECONDS = 0.50

Housing.houseFavorByGUID = {}
Housing.houseLevelByGUID = {}
Housing.lastDecorCollectAt = 0
-- Simple level tracker for HOUSE_LEVEL_CHANGED (HouseLevelInfo has no houseGUID field)
Housing.lastKnownHouseLevel = nil

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
    BLU:RegisterEvent("NEW_HOUSING_ITEM_ACQUIRED", function(...) self:OnNewHousingItemAcquired(...) end, HOUSING_EVENT_ID_ACQUIRED)
    BLU:RegisterEvent("CURRENT_HOUSE_INFO_RECIEVED", function(...) self:OnCurrentHouseInfo(...) end, HOUSING_EVENT_ID_INFO_RECEIVED)
    BLU:RegisterEvent("CURRENT_HOUSE_INFO_UPDATED", function(...) self:OnCurrentHouseInfo(...) end, HOUSING_EVENT_ID_INFO_UPDATED)

    BLU:PrintDebug(BLU:Loc("MODULE_LOADED", "Housing"))
end

function Housing:Cleanup()
    BLU:UnregisterEvent("HOUSE_LEVEL_FAVOR_UPDATED", HOUSING_EVENT_ID_FAVOR)
    BLU:UnregisterEvent("HOUSE_LEVEL_CHANGED", HOUSING_EVENT_ID_LEVEL)
    BLU:UnregisterEvent("RECEIVED_HOUSE_LEVEL_REWARDS", HOUSING_EVENT_ID_REWARDS)
    BLU:UnregisterEvent("NEW_HOUSING_ITEM_ACQUIRED", HOUSING_EVENT_ID_ACQUIRED)
    BLU:UnregisterEvent("CURRENT_HOUSE_INFO_RECIEVED", HOUSING_EVENT_ID_INFO_RECEIVED)
    BLU:UnregisterEvent("CURRENT_HOUSE_INFO_UPDATED", HOUSING_EVENT_ID_INFO_UPDATED)

    BLU:PrintDebug(BLU:Loc("MODULE_CLEANED_UP", "Housing"))
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
        -- HOUSE_LEVEL_CHANGED struct has no houseGUID, so seed the simple tracker too
        self.lastKnownHouseLevel = houseLevel
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
        if BLU.db and BLU.db.profile and BLU.db.profile.debugMode then
            BLU:Print(BLU:Loc("DEBUG_HOUSING_FAVOR_GAINED", lastFavor, newFavor))
        end
    end
end

function Housing:OnHouseLevelChanged(event, newHouseLevelInfo)
    if not IsHousingEnabled() or type(newHouseLevelInfo) ~= "table" then
        return
    end

    -- HouseLevelInfo struct has no houseGUID field; use simple level tracker
    local newLevel = tonumber(newHouseLevelInfo.level) or 0
    local lastLevel = self.lastKnownHouseLevel
    self.lastKnownHouseLevel = newLevel

    if lastLevel ~= nil and newLevel > lastLevel then
        BLU:PlayCategorySound("housingleveledup")
        if BLU.db and BLU.db.profile and BLU.db.profile.debugMode then
            BLU:Print(BLU:Loc("DEBUG_HOUSING_LEVEL_UP", lastLevel, newLevel))
        end
    end
end

function Housing:OnHouseRewardsReceived(event, level, rewards)
    if not IsHousingEnabled() then
        return
    end

    BLU:PlayCategorySound("housingrewardsreceived")
    if BLU.db and BLU.db.profile and BLU.db.profile.debugMode then
        BLU:Print(BLU:Loc("DEBUG_HOUSING_REWARDS_RECEIVED", tonumber(level) or 0))
    end
end

function Housing:MarkDecorCollected()
    self.lastDecorCollectAt = GetTime and GetTime() or 0
    BLU:PlayCategorySound("housingdecorcollected")
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
    if BLU.db and BLU.db.profile and BLU.db.profile.debugMode then
        BLU:Print(BLU:Loc("DEBUG_HOUSING_DECOR_COLLECTED", tostring(itemName or BLU:Loc("UNKNOWN"))))
    end
end

BLU.Modules = BLU.Modules or {}
BLU.Modules["housing"] = Housing

return Housing
