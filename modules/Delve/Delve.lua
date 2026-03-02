--=====================================================================================
-- BLU Delve Companion Module
-- Handles Delve Companion level up sounds (TWW feature)
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local DelveCompanion = {}

local DELVE_SYSTEM_SCAN_THROTTLE_SECONDS = 0.25
local DELVE_EVENT_ID_CHAT = "delve_chat_system"
local DELVE_EVENT_ID_FACTION = "delve_faction_standing_changed"

local function IsRetailClient()
    local _, _, _, interfaceVersion = GetBuildInfo()
    return interfaceVersion and interfaceVersion >= 100000
end

-- Module initialization
function DelveCompanion:Init()
    self.cachedCompanionFactionID = nil
    self.lastCompanionLevel = nil
    self.lastPlayedCompanionLevel = nil
    self.lastSystemScanAt = nil

    if not IsRetailClient() then
        BLU:PrintDebug("DelveCompanion skipped (non-retail client)")
        return
    end

    BLU:RegisterEvent("CHAT_MSG_SYSTEM", function(...) self:OnSystemMessage(...) end, DELVE_EVENT_ID_CHAT)
    BLU:RegisterEvent("FACTION_STANDING_CHANGED", function(...) self:OnFactionStandingChanged(...) end, DELVE_EVENT_ID_FACTION)

    self:UpdateCompanionLevelCache()
    BLU:PrintDebug("DelveCompanion module initialized")
end

-- Cleanup function
function DelveCompanion:Cleanup()
    BLU:UnregisterEvent("CHAT_MSG_SYSTEM", DELVE_EVENT_ID_CHAT)
    BLU:UnregisterEvent("FACTION_STANDING_CHANGED", DELVE_EVENT_ID_FACTION)
    BLU:PrintDebug("DelveCompanion module cleaned up")
end

function DelveCompanion:IsEnabled()
    return BLU.db and BLU.db.profile and BLU.db.profile.enableDelveCompanion ~= false
end

function DelveCompanion:GetCompanionFactionID()
    if not C_DelvesUI then
        return nil
    end

    if C_DelvesUI.GetFactionForCompanion then
        local factionID = C_DelvesUI.GetFactionForCompanion()
        if factionID and factionID > 0 then
            return factionID
        end
    end

    if C_DelvesUI.GetDelvesFactionForSeason then
        local factionID = C_DelvesUI.GetDelvesFactionForSeason()
        if factionID and factionID > 0 then
            return factionID
        end
    end

    return nil
end

function DelveCompanion:GetCompanionLevel()
    local factionID = self.cachedCompanionFactionID or self:GetCompanionFactionID()
    if not factionID then
        return nil, nil
    end
    self.cachedCompanionFactionID = factionID

    if C_GossipInfo and C_GossipInfo.GetFriendshipReputationRanks then
        local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)
        if rankInfo and rankInfo.currentLevel then
            return rankInfo.currentLevel, factionID
        end
    end

    if C_MajorFactions and C_MajorFactions.GetMajorFactionData then
        local factionData = C_MajorFactions.GetMajorFactionData(factionID)
        if factionData and factionData.renownLevel then
            return factionData.renownLevel, factionID
        end
    end

    return nil, factionID
end

function DelveCompanion:UpdateCompanionLevelCache()
    local level, factionID = self:GetCompanionLevel()
    if factionID then
        self.cachedCompanionFactionID = factionID
    end
    if level then
        self.lastCompanionLevel = level
    end
end

function DelveCompanion:TriggerLevelUp(level)
    if level and self.lastPlayedCompanionLevel and level <= self.lastPlayedCompanionLevel then
        return
    end

    if level then
        self.lastCompanionLevel = level
        self.lastPlayedCompanionLevel = level
    end

    self:PlayDelveSound()

    if BLU.debugMode then
        if level then
            BLU:Print(string.format("Delve Companion reached level %d!", level))
        else
            BLU:Print("Delve Companion leveled up!")
        end
    end
end

function DelveCompanion:CheckForLevelIncrease(expectedFactionID)
    if not self:IsEnabled() then
        return
    end

    local currentLevel, factionID = self:GetCompanionLevel()
    if not factionID or not currentLevel then
        return
    end

    if expectedFactionID and expectedFactionID ~= factionID then
        return
    end

    if self.lastCompanionLevel and currentLevel > self.lastCompanionLevel then
        self:TriggerLevelUp(currentLevel)
    else
        self.lastCompanionLevel = currentLevel
    end
end

-- System message handler (taint-safe: does not inspect message payload)
function DelveCompanion:OnSystemMessage()
    if not self:IsEnabled() then
        return
    end

    local now = GetTime and GetTime() or 0
    if self.lastSystemScanAt and (now - self.lastSystemScanAt) < DELVE_SYSTEM_SCAN_THROTTLE_SECONDS then
        return
    end

    self.lastSystemScanAt = now
    self:CheckForLevelIncrease(nil)
end

function DelveCompanion:OnFactionStandingChanged(event, factionID)
    self:CheckForLevelIncrease(factionID)
end

-- Play Delve Companion sound
function DelveCompanion:PlayDelveSound()
    if BLU.PlayCategorySound then
        BLU:PlayCategorySound("delvecompanion")
        return
    end

    local soundName = BLU.db and BLU.db.profile and BLU.db.profile.delveCompanionSound
    local delveVolume = BLU.db and BLU.db.profile and BLU.db.profile.delveCompanionVolume or 1
    local masterVolume = BLU.db and BLU.db.profile and BLU.db.profile.masterVolume or 1
    BLU:PlaySound(soundName, delveVolume * masterVolume)
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["delve"] = DelveCompanion
BLU.Modules["DelveCompanion"] = DelveCompanion

-- Export module
return DelveCompanion
