--=====================================================================================
-- BLU Reputation Module
-- Handles reputation gain sounds
--=====================================================================================

local addonName, addonTable = ...
local Reputation = {}

-- Reputation rank names
local REPUTATION_RANKS = {
    [1] = "Hated",
    [2] = "Hostile", 
    [3] = "Unfriendly",
    [4] = "Neutral",
    [5] = "Friendly",
    [6] = "Honored",
    [7] = "Revered",
    [8] = "Exalted"
}

-- Module initialization
function Reputation:Init()
    -- Hook into chat messages for reputation gains
    ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", function(...) return self:OnReputationMessage(...) end)
    
    -- Track reputation changes
    BLU:RegisterEvent("UPDATE_FACTION", function(...) self:OnUpdateFaction(...) end)
    
    -- Initialize reputation tracking
    self.reputationData = {}
    self:ScanReputation()
    
    BLU:PrintDebug("Reputation module initialized")
end

-- Cleanup function
function Reputation:Cleanup()
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", self.OnReputationMessage)
    BLU:UnregisterEvent("UPDATE_FACTION")
    BLU:PrintDebug("Reputation module cleaned up")
end

-- Scan current reputation standings
function Reputation:ScanReputation()
    for i = 1, GetNumFactions() do
        local name, _, standingId, _, _, value = GetFactionInfo(i)
        if name then
            self.reputationData[name] = {
                standing = standingId,
                value = value
            }
        end
    end
end

-- Handle reputation chat messages
function Reputation:OnReputationMessage(chatFrame, event, msg)
    if not BLU.db.profile.enableReputation then return false end
    
    -- Check for rank up messages
    if msg:find("You are now") and (msg:find("Friendly") or msg:find("Honored") or 
       msg:find("Revered") or msg:find("Exalted")) then
        self:PlayReputationSound()
    end
    
    return false
end

-- Handle faction updates
function Reputation:OnUpdateFaction(event)
    if not BLU.db.profile.enableReputation then return end
    
    C_Timer.After(0.1, function()
        self:CheckReputationChanges()
    end)
end

-- Check for reputation standing changes
function Reputation:CheckReputationChanges()
    local playSound = false
    
    for i = 1, GetNumFactions() do
        local name, _, standingId, _, _, value = GetFactionInfo(i)
        if name and self.reputationData[name] then
            local oldData = self.reputationData[name]
            
            -- Check if standing increased
            if standingId > oldData.standing then
                playSound = true
                
                if BLU.debugMode then
                    BLU:Print(string.format("Reputation increased with %s: %s -> %s", 
                        name, 
                        REPUTATION_RANKS[oldData.standing] or "Unknown",
                        REPUTATION_RANKS[standingId] or "Unknown"))
                end
            end
            
            -- Update stored data
            self.reputationData[name] = {
                standing = standingId,
                value = value
            }
        end
    end
    
    if playSound then
        self:PlayReputationSound()
    end
end

-- Play reputation sound
function Reputation:PlayReputationSound()
    local soundName = BLU.db.profile.reputationSound
    local volume = BLU.db.profile.reputationVolume * BLU.db.profile.masterVolume
    
    BLU:PlaySound(soundName, volume)
end

-- Export module
return Reputation