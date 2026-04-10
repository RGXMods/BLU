--=====================================================================================
-- BLU Reputation Module
-- Handles reputation gain sounds
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local Reputation = {}

local REPUTATION_EVENT_ID_UPDATE = "reputation_update"
local REPUTATION_EVENT_ID_LOGIN = "reputation_login"
local REPUTATION_SCAN_DELAY_SECONDS = 0.10

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
    self.reputationData = {}
    self.pendingScan = false

    BLU:RegisterEvent("UPDATE_FACTION", function(...) self:OnUpdateFaction(...) end, REPUTATION_EVENT_ID_UPDATE)
    BLU:RegisterEvent("PLAYER_ENTERING_WORLD", function(...) self:OnPlayerEnteringWorld(...) end, REPUTATION_EVENT_ID_LOGIN)

    self:ScanReputation()
    BLU:PrintDebug(BLU:Loc("MODULE_LOADED", "Reputation"))
end

-- Cleanup function
function Reputation:Cleanup()
    BLU:UnregisterEvent("UPDATE_FACTION", REPUTATION_EVENT_ID_UPDATE)
    BLU:UnregisterEvent("PLAYER_ENTERING_WORLD", REPUTATION_EVENT_ID_LOGIN)
    self.pendingScan = false
    BLU:PrintDebug(BLU:Loc("MODULE_CLEANED_UP", "Reputation"))
end

-- Scan current reputation standings
function Reputation:ScanReputation()
    if not C_Reputation or not C_Reputation.GetNumFactions or not C_Reputation.GetFactionDataByIndex then
        return
    end

    local numFactions = C_Reputation.GetNumFactions()
    for i = 1, numFactions do
        local factionData = C_Reputation.GetFactionDataByIndex(i)
        if factionData and factionData.name and factionData.reaction then
            self.reputationData[factionData.name] = {
                standing = factionData.reaction,
                value = factionData.currentStanding
            }
        end
    end
end

-- Handle faction updates
function Reputation:OnUpdateFaction(event)
    if not BLU.db or not BLU.db.enabled then return end
    if BLU.db.enableReputation == false then return end
    if BLU.db.modules and BLU.db.modules.reputation == false then return end

    if self.pendingScan then
        return
    end

    self.pendingScan = true
    C_Timer.After(REPUTATION_SCAN_DELAY_SECONDS, function()
        self.pendingScan = false
        self:CheckReputationChanges()
    end)
end

function Reputation:OnPlayerEnteringWorld()
    self:ScanReputation()
end

-- Check for reputation standing changes
function Reputation:CheckReputationChanges()
    if not C_Reputation or not C_Reputation.GetNumFactions or not C_Reputation.GetFactionDataByIndex then
        return
    end

    local playSound = false
    local numFactions = C_Reputation.GetNumFactions()
    
    for i = 1, numFactions do
        local factionData = C_Reputation.GetFactionDataByIndex(i)
        if factionData and factionData.name and factionData.reaction then
            local oldData = self.reputationData[factionData.name]

            if oldData and factionData.reaction > oldData.standing then
                playSound = true
                
                if BLU.db and BLU.db.debugMode then
                    BLU:Print(BLU:Loc("DEBUG_REPUTATION_INCREASED",
                        factionData.name,
                        REPUTATION_RANKS[oldData.standing] or BLU:Loc("UNKNOWN"),
                        REPUTATION_RANKS[factionData.reaction] or BLU:Loc("UNKNOWN")))
                end
            end
            
            self.reputationData[factionData.name] = {
                standing = factionData.reaction,
                value = factionData.currentStanding
            }
        end
    end
    
    if playSound then
        self:PlayReputationSound()
    end
end

-- Play reputation sound
function Reputation:PlayReputationSound()
    BLU:PlayCategorySound("reputation")
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["reputation"] = Reputation

-- Export module
return Reputation
