--=====================================================================================
-- BLU Delve Companion Module
-- Handles Delve Companion level up sounds (TWW feature)
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local DelveCompanion = {}

local DELVE_EVENT_ID_FACTION = "delve_faction_standing_changed"
local DELVE_EVENT_ID_RENOWN = "delve_renown_changed"
local DELVE_EVENT_ID_LIVES = "delve_lives_update"

-- Spell ID for the "Lives Remaining" delve aura (added patch 11.0.0 TWW)
local DELVE_LIVES_SPELL_ID = 458103

local function IsRetailClient()
    local _, _, _, interfaceVersion = GetBuildInfo()
    return interfaceVersion and interfaceVersion >= 100000
end

-- Module initialization
function DelveCompanion:Init()
    self.cachedCompanionFactionID = nil
    self.lastCompanionLevel = nil
    self.lastPlayedCompanionLevel = nil
    self.cachedLivesRemaining = nil
    self.lastLifeLostTime = 0
    self.lastLifeGainedTime = 0

    if not IsRetailClient() then
        BLU:PrintDebug("DelveCompanion skipped (non-retail client)")
        return
    end

    BLU:RegisterEvent("FACTION_STANDING_CHANGED", function(...) self:OnFactionStandingChanged(...) end, DELVE_EVENT_ID_FACTION)
    BLU:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", function(...) self:OnMajorFactionRenownLevelChanged(...) end, DELVE_EVENT_ID_RENOWN)
    BLU:RegisterEvent("UNIT_AURA", function(...) self:OnUnitAura(...) end, DELVE_EVENT_ID_LIVES)

    self:UpdateCompanionLevelCache()
    self:UpdateLivesCache()
    BLU:PrintDebug("DelveCompanion module initialized")
end

-- Cleanup function
function DelveCompanion:Cleanup()
    BLU:UnregisterEvent("FACTION_STANDING_CHANGED", DELVE_EVENT_ID_FACTION)
    BLU:UnregisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", DELVE_EVENT_ID_RENOWN)
    BLU:UnregisterEvent("UNIT_AURA", DELVE_EVENT_ID_LIVES)
    BLU:PrintDebug("DelveCompanion module cleaned up")
end

function DelveCompanion:IsEnabled()
    if not (BLU.db and BLU.db.profile) then
        return false
    end

    if BLU.db.profile.enabled == false then
        return false
    end

    if BLU.db.profile.enableDelveCompanion == false then
        return false
    end

    if BLU.db.profile.modules and BLU.db.profile.modules.delvecompanion == false then
        return false
    end

    return true
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

function DelveCompanion:OnFactionStandingChanged(event, factionID)
    self:CheckForLevelIncrease(factionID)
end

function DelveCompanion:OnMajorFactionRenownLevelChanged(event, factionID, newLevel, oldLevel)
    if not self:IsEnabled() then
        return
    end

    local companionFactionID = self.cachedCompanionFactionID or self:GetCompanionFactionID()
    if not companionFactionID or factionID ~= companionFactionID then
        return
    end

    if newLevel and oldLevel and newLevel > oldLevel then
        self:TriggerLevelUp(newLevel)
        return
    end

    self:CheckForLevelIncrease(factionID)
end

-- Get remaining lives from the "Lives Remaining" delve aura (spell 458103, added TWW patch 11.0.0)
function DelveCompanion:GetDelveLivesRemaining()
    if not C_UnitAuras or not C_UnitAuras.GetPlayerAuraBySpellID then return nil end
    local aura = C_UnitAuras.GetPlayerAuraBySpellID(DELVE_LIVES_SPELL_ID)
    if aura then
        return aura.applications or 0
    end
    return nil
end

function DelveCompanion:UpdateLivesCache()
    self.cachedLivesRemaining = self:GetDelveLivesRemaining()
end

-- UNIT_AURA handler — tracks the "Lives Remaining" aura stack count
function DelveCompanion:OnUnitAura(event, unitToken)
    if unitToken ~= "player" then return end
    if not self:IsEnabled() then return end

    local current = self:GetDelveLivesRemaining()
    local previous = self.cachedLivesRemaining

    if current == nil then
        -- Aura gone (left delve or no aura active)
        self.cachedLivesRemaining = nil
        return
    end

    if previous ~= nil then
        local now = GetTime()
        if current < previous then
            -- Life lost (died in delve, Brann used a revive)
            if (now - self.lastLifeLostTime) >= 1.0 then
                self.lastLifeLostTime = now
                BLU:PlayCategorySound("delvelifelost")
                if BLU.debugMode then
                    BLU:Print(string.format("Delve life lost! %d → %d remaining", previous, current))
                end
            end
        elseif current > previous then
            -- Life gained (+1 life mechanic)
            if (now - self.lastLifeGainedTime) >= 1.0 then
                self.lastLifeGainedTime = now
                BLU:PlayCategorySound("delvelifegained")
                if BLU.debugMode then
                    BLU:Print(string.format("Delve life gained! %d → %d remaining", previous, current))
                end
            end
        end
    end

    self.cachedLivesRemaining = current
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
