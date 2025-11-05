--=====================================================================================
-- BLU Battle Pet Module
-- Handles battle pet level up sounds
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local battlepet = {}

-- Module variables
battlepet.lastPetLevel = {}
battlepet.levelUpCooldown = {}

-- Module initialization
function battlepet:Init()
    -- Battle pet events
    BLU:RegisterEvent("PET_BATTLE_LEVEL_CHANGED", function(...) self:OnPetLevelChanged(...) end)
    BLU:RegisterEvent("PET_BATTLE_PET_CHANGED", function(...) self:OnPetChanged(...) end)
    BLU:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN", function(...) self:OnCombatXPGain(...) end)
    
    -- Initialize pet levels
    self:ScanPetLevels()
    
    BLU:PrintDebug("BattlePet module initialized")
end

-- Cleanup function
function battlepet:Cleanup()
    BLU:UnregisterEvent("PET_BATTLE_LEVEL_CHANGED")
    BLU:UnregisterEvent("PET_BATTLE_PET_CHANGED")
    BLU:UnregisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
    BLU:PrintDebug("BattlePet module cleaned up")
end

-- Scan current pet levels
function battlepet:ScanPetLevels()
    local numPets = C_PetJournal.GetNumPets()
    
    for i = 1, numPets do
        local petID, speciesID, owned = C_PetJournal.GetPetInfoByIndex(i)
        if petID and owned then
            local _, _, level = C_PetJournal.GetPetInfoByPetID(petID)
            if level then
                self.lastPetLevel[petID] = level
            end
        end
    end
end

-- Pet level changed handler
function battlepet:OnPetLevelChanged(event, owner, petSlot, newLevel, oldLevel)
    if not BLU.db.profile.enableBattlePet then return end
    
    -- Only play for player's pets
    if owner ~= Enum.BattlePetOwner.Ally then return end
    
    -- Check cooldown
    local now = GetTime()
    if self.levelUpCooldown[petSlot] and (now - self.levelUpCooldown[petSlot]) < 1 then
        return
    end
    
    self.levelUpCooldown[petSlot] = now
    
    BLU:PlayCategorySound("battlepet")
    
    if BLU.debugMode then
        BLU:Print(string.format("Battle pet leveled up! Slot %d: %d -> %d", petSlot, oldLevel, newLevel))
    end
end

-- Pet changed handler
function battlepet:OnPetChanged(event)
    -- Update pet levels after battle
    C_Timer.After(0.5, function()
        self:CheckPetLevels()
    end)
end

-- Combat XP gain handler (for pets outside of battles)
function battlepet:OnCombatXPGain(event, msg)
    if not BLU.db or not BLU.db.profile or not BLU.db.profile.enableBattlePet then return end
    
    -- Check if message is about battle pet XP
    if msg:find("gains %d+ experience") and msg:find("Battle Pet") then
        -- Check for level ups after XP gain
        C_Timer.After(0.1, function()
            self:CheckPetLevels()
        end)
    end
end

-- Check for pet level changes
function battlepet:CheckPetLevels()
    local numPets = C_PetJournal.GetNumPets()
    
    for i = 1, numPets do
        local petID, speciesID, owned = C_PetJournal.GetPetInfoByIndex(i)
        if petID and owned then
            local _, _, level, _, _, _, _, name = C_PetJournal.GetPetInfoByPetID(petID)
            if level then
                local lastLevel = self.lastPetLevel[petID] or 0
                
                if level > lastLevel then
                    -- Pet leveled up!
                    BLU:PlayCategorySound("battlepet")
                    
                    if BLU.debugMode then
                        BLU:Print(string.format("Battle pet '%s' leveled up to %d!", name or "Unknown", level))
                    end
                    
                    self.lastPetLevel[petID] = level
                end
            end
        end
    end
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["battlepet"] = battlepet