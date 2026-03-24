--=====================================================================================
-- BLU Renown Rank Module
-- Handles Renown reputation rank up sounds
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local RenownRank = {}

local RENOWN_EVENT_ID_MAJOR = "renown_major_faction_level_changed"
local RENOWN_EVENT_ID_COVENANT = "renown_covenant_level_changed"
local RENOWN_SOUND_COOLDOWN_SECONDS = 0.30

-- Module variables
RenownRank.renownLevels = {}
RenownRank.lastSoundAt = 0

-- Module initialization
function RenownRank:Init()
    -- Renown events
    BLU:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", function(...) self:OnRenownLevelChanged(...) end, RENOWN_EVENT_ID_MAJOR)
    BLU:RegisterEvent("COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED", function(...) self:OnCovenantRenownChanged(...) end, RENOWN_EVENT_ID_COVENANT)
    
    -- Initialize renown tracking
    self:ScanRenownLevels()
    
    BLU:PrintDebug("RenownRank module initialized")
end

-- Cleanup function
function RenownRank:Cleanup()
    BLU:UnregisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", RENOWN_EVENT_ID_MAJOR)
    BLU:UnregisterEvent("COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED", RENOWN_EVENT_ID_COVENANT)
    
    BLU:PrintDebug("RenownRank module cleaned up")
end

-- Scan current renown levels
function RenownRank:ScanRenownLevels()
    -- Check major factions (Dragonflight+)
    if C_MajorFactions then
        local factionIDs = C_MajorFactions.GetMajorFactionIDs and C_MajorFactions.GetMajorFactionIDs()
        if type(factionIDs) == "table" then
            for _, factionID in ipairs(factionIDs) do
                local data = C_MajorFactions.GetMajorFactionData and C_MajorFactions.GetMajorFactionData(factionID)
                if data then
                    self.renownLevels[factionID] = data.renownLevel or 0
                end
            end
        end
    end
    
    -- Check covenant renown (Shadowlands)
    if C_CovenantSanctumUI and C_Covenants and C_Covenants.GetActiveCovenantID then
        local covenantID = C_Covenants.GetActiveCovenantID()
        if covenantID then
            local level = C_CovenantSanctumUI.GetRenownLevel and C_CovenantSanctumUI.GetRenownLevel() or 0
            self.renownLevels["covenant_" .. covenantID] = level or 0
        end
    end
end

-- Major faction renown level changed
function RenownRank:OnRenownLevelChanged(event, factionID, newLevel, oldLevel)
    if not BLU.db or not BLU.db.profile then return end
    if not BLU.db.profile.enabled then return end
    if not BLU.db.profile.enableRenownRank then return end
    if BLU.db.profile.modules and BLU.db.profile.modules.renownrank == false then return end
    
    if newLevel > oldLevel then
        self:PlayRenownSound()
        
        if BLU.debugMode then
            local data = C_MajorFactions.GetMajorFactionData(factionID)
            local factionName = data and data.name or "Unknown Faction"
            BLU:Print(string.format("Renown increased with %s: %d -> %d", factionName, oldLevel, newLevel))
        end
    end
    
    self.renownLevels[factionID] = newLevel
end

-- Covenant renown changed
function RenownRank:OnCovenantRenownChanged(event, newLevel, oldLevel)
    if not BLU.db or not BLU.db.profile then return end
    if not BLU.db.profile.enabled then return end
    if not BLU.db.profile.enableRenownRank then return end
    if BLU.db.profile.modules and BLU.db.profile.modules.renownrank == false then return end
    
    if newLevel and oldLevel and newLevel > oldLevel then
        self:PlayRenownSound()
        
        if BLU.debugMode then
            BLU:Print(string.format("Covenant Renown increased: %d -> %d", oldLevel, newLevel))
        end
    end
end

-- Play renown sound
function RenownRank:PlayRenownSound()
    local now = GetTime and GetTime() or 0
    if self.lastSoundAt and (now - self.lastSoundAt) < RENOWN_SOUND_COOLDOWN_SECONDS then
        return
    end
    self.lastSoundAt = now
    BLU:PlayCategorySound("renownrank")
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["renown"] = RenownRank

-- Export module
return RenownRank
