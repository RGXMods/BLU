--=====================================================================================
-- BLU Delve Companion Module
-- Handles Delve Companion level up sounds (TWW feature)
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local RGX = assert(_G.RGXFramework, "BLU requires RGX-Framework")
local DelveCompanion = {}

local DELVE_EVENT_ID_FACTION = "delve_faction_standing_changed"
local DELVE_EVENT_ID_RENOWN = "delve_renown_changed"
local DELVE_EVENT_ID_LIVES = "delve_lives_update"
local DELVE_LIVES_RECHECK_DELAY_SECONDS = 0.10

-- Spell ID for the "Lives Remaining" delve aura (added patch 11.0.0 TWW)
local DELVE_LIVES_SPELL_ID = 458103

local RESTRICTED = "restricted"

-- Retail 12.x can hand back secret aura data (GetPlayerAuraBySpellID is
-- SecretWhenUnitAuraRestricted). Comparing a secret number throws, so every
-- read goes through the framework access predicates first.
local function CanAccessValue(value)
    local api = RGX.API
    if api and type(api.CanAccessValue) == "function" then
        return api.CanAccessValue(value)
    end
    return true
end

local function CanAccessTable(tbl)
    local api = RGX.API
    if api and type(api.CanAccessTable) == "function" then
        return api.CanAccessTable(tbl)
    end
    return type(tbl) == "table"
end

local function ReadCount(value)
    if type(value) == "nil" then return nil end
    if not CanAccessValue(value) then return RESTRICTED end
    if type(value) == "number" then return value end
    return nil
end

local function GetAuraStackCount(aura)
    if type(aura) ~= "table" then
        return nil
    end
    if not CanAccessTable(aura) then
        return RESTRICTED
    end

    for _, field in ipairs({ "applications", "stackCount", "charges" }) do
        local count = ReadCount(aura[field])
        if count ~= nil then
            return count
        end
    end

    local points = aura.points
    if type(points) == "table" then
        if not CanAccessTable(points) then
            return RESTRICTED
        end
        for _, value in ipairs(points) do
            local count = ReadCount(value)
            if count ~= nil then
                return count
            end
        end
    end

    return 0
end

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
    self.pendingLivesRefresh = false

    if not IsRetailClient() then
        BLU:PrintDebug(BLU:Loc("DEBUG_DELVE_SKIPPED_NON_RETAIL"))
        return
    end

    BLU:RegisterEvent("FACTION_STANDING_CHANGED", function(...) self:OnFactionStandingChanged(...) end, DELVE_EVENT_ID_FACTION)
    BLU:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", function(...) self:OnMajorFactionRenownLevelChanged(...) end, DELVE_EVENT_ID_RENOWN)
    RGX:RegisterUnitEvent("UNIT_AURA", "player", function()
        self:OnUnitAura()
    end, DELVE_EVENT_ID_LIVES, self)

    self:UpdateCompanionLevelCache()
    self:UpdateLivesCache()
    BLU:PrintDebug(BLU:Loc("MODULE_LOADED", "DelveCompanion"))
end

-- Cleanup function
function DelveCompanion:Cleanup()
    BLU:UnregisterEvent("FACTION_STANDING_CHANGED", DELVE_EVENT_ID_FACTION)
    BLU:UnregisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", DELVE_EVENT_ID_RENOWN)
    RGX:UnregisterUnitEvent("UNIT_AURA", DELVE_EVENT_ID_LIVES)
    BLU:PrintDebug(BLU:Loc("MODULE_CLEANED_UP", "DelveCompanion"))
end

function DelveCompanion:IsEnabled()
    if not (BLU.db) then
        return false
    end

    if BLU.db.enabled == false then
        return false
    end

    if BLU.db.enableDelveCompanion == false then
        return false
    end

    if BLU.db.modules and BLU.db.modules.delvecompanion == false then
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

    if BLU.db and BLU.db.debugMode then
        if level then
            BLU:Print(BLU:Loc("DEBUG_DELVE_COMPANION_LEVEL", level))
        else
            BLU:Print(BLU:Loc("DEBUG_DELVE_COMPANION_LEVEL_GENERIC"))
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
-- Returns the lives count, nil when the aura is absent, or nil, "restricted"
-- when the client is withholding the aura data.
function DelveCompanion:GetDelveLivesRemaining()
    local api = RGX.API
    local getter = api and api.GetPlayerAuraBySpellID
    if type(getter) ~= "function" then
        getter = C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID
    end
    if type(getter) ~= "function" then return nil end

    local ok, aura = pcall(getter, DELVE_LIVES_SPELL_ID)
    if not ok then return nil, RESTRICTED end
    if type(aura) == "nil" then return nil end

    local count = GetAuraStackCount(aura)
    if count == RESTRICTED then return nil, RESTRICTED end
    return count
end

function DelveCompanion:UpdateLivesCache()
    local current, status = self:GetDelveLivesRemaining()
    if status == RESTRICTED then return end
    self.cachedLivesRemaining = current
end

-- UNIT_AURA handler — tracks the "Lives Remaining" aura stack count
-- Tracks the "Lives Remaining" aura stack count.
function DelveCompanion:RefreshLivesState()
    local current, status = self:GetDelveLivesRemaining()
    local previous = self.cachedLivesRemaining

    if status == RESTRICTED then
        -- Data withheld this tick: keep the last known count and compare later.
        return
    end

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
                if BLU.db and BLU.db.debugMode then
                    BLU:Print(BLU:Loc("DEBUG_DELVE_LIFE_LOST", previous, current))
                end
            end
        elseif current > previous then
            -- Life gained (+1 life mechanic)
            if (now - self.lastLifeGainedTime) >= 1.0 then
                self.lastLifeGainedTime = now
                BLU:PlayCategorySound("delvelifegained")
                if BLU.db and BLU.db.debugMode then
                    BLU:Print(BLU:Loc("DEBUG_DELVE_LIFE_GAINED", previous, current))
                end
            end
        end
    end

    self.cachedLivesRemaining = current
end

function DelveCompanion:QueueLivesRefresh(delaySeconds)
    if self.pendingLivesRefresh then
        return
    end

    self.pendingLivesRefresh = true
    _G.RGXFramework:After(delaySeconds or DELVE_LIVES_RECHECK_DELAY_SECONDS, function()
        self.pendingLivesRefresh = false
        if self:IsEnabled() then
            self:RefreshLivesState()
        else
            self:UpdateLivesCache()
        end
    end)
end

function DelveCompanion:OnUnitAura()
    if not self:IsEnabled() then return end

    self:RefreshLivesState()
    self:QueueLivesRefresh(DELVE_LIVES_RECHECK_DELAY_SECONDS)
end

-- Play Delve Companion sound
function DelveCompanion:PlayDelveSound()
    if BLU.PlayCategorySound then
        BLU:PlayCategorySound("delvecompanion")
        return
    end

    local soundName = BLU.db and BLU.db.delveCompanionSound
    local delveVolume = BLU.db and BLU.db.delveCompanionVolume or 1
    local masterVolume = BLU.db and BLU.db.masterVolume or 1
    BLU:PlaySound(soundName, delveVolume * masterVolume)
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["delve"] = DelveCompanion
BLU.Modules["DelveCompanion"] = DelveCompanion

-- Export module
return DelveCompanion
