--=====================================================================================
-- BLU Renown Rank Module
-- Handles Renown reputation rank up sounds
--=====================================================================================

local addonName, BLU = ...
local RenownRank = {}

-- Module variables
RenownRank.renownLevels = {}

-- Module initialization
function RenownRank:Init()
    -- Renown events
    BLU:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", function(...) self:OnRenownLevelChanged(...) end)
    BLU:RegisterEvent("COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED", function(...) self:OnCovenantRenownChanged(...) end)
    
    -- Chat message filter for renown messages
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(...) return self:OnSystemMessage(...) end)
    
    -- Initialize renown tracking
    self:ScanRenownLevels()
    
    BLU:PrintDebug("RenownRank module initialized")
end

-- Cleanup function
function RenownRank:Cleanup()
    BLU:UnregisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
    BLU:UnregisterEvent("COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED")
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self.OnSystemMessage)
    
    BLU:PrintDebug("RenownRank module cleaned up")
end

-- Scan current renown levels
function RenownRank:ScanRenownLevels()
    -- Check major factions (Dragonflight+)
    if C_MajorFactions then
        for _, factionID in ipairs(C_MajorFactions.GetMajorFactionIDs()) do
            local data = C_MajorFactions.GetMajorFactionData(factionID)
            if data then
                self.renownLevels[factionID] = data.renownLevel or 0
            end
        end
    end
    
    -- Check covenant renown (Shadowlands)
    if C_CovenantSanctumUI then
        local covenantID = C_Covenants.GetActiveCovenantID()
        if covenantID then
            local level = C_CovenantSanctumUI.GetRenownLevel()
            self.renownLevels["covenant_" .. covenantID] = level or 0
        end
    end
end

-- Major faction renown level changed
function RenownRank:OnRenownLevelChanged(event, factionID, newLevel, oldLevel)
    if not BLU.db.profile.enableRenownRank then return end
    
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
    if not BLU.db.profile.enableRenownRank then return end
    
    if newLevel and oldLevel and newLevel > oldLevel then
        self:PlayRenownSound()
        
        if BLU.debugMode then
            BLU:Print(string.format("Covenant Renown increased: %d -> %d", oldLevel, newLevel))
        end
    end
end

-- System message handler
function RenownRank:OnSystemMessage(chatFrame, event, msg)
    if not BLU.db.profile.enableRenownRank then return false end
    
    -- Check for renown messages
    local patterns = {
        "You are now Renown",
        "Renown %d+ earned",
        "gained Renown level",
        "Renown increased to"
    }
    
    for _, pattern in ipairs(patterns) do
        if msg:find(pattern) then
            self:PlayRenownSound()
            
            if BLU.debugMode then
                BLU:Print("Renown rank increased!")
            end
            
            break
        end
    end
    
    return false
end

-- Play renown sound
function RenownRank:PlayRenownSound()
    local soundName = BLU.db.profile.renownRankSound
    local volume = BLU.db.profile.renownRankVolume * BLU.db.profile.masterVolume
    
    BLU:PlaySound(soundName, volume)
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["RenownRank"] = RenownRank

-- Export module
return RenownRank