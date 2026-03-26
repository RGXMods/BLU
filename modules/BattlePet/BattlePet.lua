--=====================================================================================
-- BLU Battle Pet Module
-- Handles battle pet level up sounds
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local BattlePet = {}

local PET_EVENT_ID_LEVEL = "battlepet_level_changed"
local PET_EVENT_ID_CHANGED = "battlepet_pet_changed"
local PET_EVENT_ID_CAPTURED = "battlepet_captured"

-- Module variables
BattlePet.lastPetLevel = {}
BattlePet.levelUpCooldown = {}
BattlePet.pendingLevelScan = false

-- Module initialization
function BattlePet:Init()
    -- Battle pet events
    BLU:RegisterEvent("PET_BATTLE_LEVEL_CHANGED", function(...) self:OnPetLevelChanged(...) end, PET_EVENT_ID_LEVEL)
    BLU:RegisterEvent("PET_BATTLE_PET_CHANGED", function(...) self:OnPetChanged(...) end, PET_EVENT_ID_CHANGED)
    BLU:RegisterEvent("PET_BATTLE_CAPTURED", function(...) self:OnPetCaptured(...) end, PET_EVENT_ID_CAPTURED)
    
    -- Initialize pet levels
    self:ScanPetLevels()
    
    BLU:PrintDebug(BLU:Loc("MODULE_LOADED", "BattlePet"))
end

-- Cleanup function
function BattlePet:Cleanup()
    BLU:UnregisterEvent("PET_BATTLE_LEVEL_CHANGED", PET_EVENT_ID_LEVEL)
    BLU:UnregisterEvent("PET_BATTLE_PET_CHANGED", PET_EVENT_ID_CHANGED)
    BLU:UnregisterEvent("PET_BATTLE_CAPTURED", PET_EVENT_ID_CAPTURED)
    self.pendingLevelScan = false
    BLU:PrintDebug(BLU:Loc("MODULE_CLEANED_UP", "BattlePet"))
end

-- Scan current pet levels
function BattlePet:ScanPetLevels()
    if not C_PetJournal or not C_PetJournal.GetNumPets or not C_PetJournal.GetPetInfoByIndex or not C_PetJournal.GetPetInfoByPetID then
        return
    end

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
function BattlePet:OnPetLevelChanged(event, owner, petSlot, newLevel, oldLevel)
    if not BLU.db or not BLU.db.profile then return end
    if not BLU.db.profile.enabled then return end
    if not BLU.db.profile.enableBattlePet then return end
    if BLU.db.profile.modules and BLU.db.profile.modules.battlepet == false then return end
    
    -- Only play for player's pets
    if owner ~= Enum.BattlePetOwner.Ally then return end
    
    -- Check cooldown
    local now = GetTime()
    if self.levelUpCooldown[petSlot] and (now - self.levelUpCooldown[petSlot]) < 1 then
        return
    end
    
    self.levelUpCooldown[petSlot] = now
    
    BLU:PlayCategorySound("battlepet")
    
    if BLU.db.profile.debugMode then
        BLU:Print(BLU:Loc("DEBUG_BATTLE_PET_LEVEL_SLOT", petSlot, oldLevel, newLevel))
    end
end

-- Pet changed handler
function BattlePet:OnPetChanged(event)
    if not BLU.db or not BLU.db.profile then return end
    if not BLU.db.profile.enabled then return end
    if not BLU.db.profile.enableBattlePet then return end
    if BLU.db.profile.modules and BLU.db.profile.modules.battlepet == false then return end
    self:SchedulePetLevelScan(0.2)
end

function BattlePet:OnPetCaptured(event, owner, petIndex)
    if not BLU.db or not BLU.db.profile then return end
    if not BLU.db.profile.enabled then return end
    if not BLU.db.profile.enableBattlePet then return end
    if BLU.db.profile.modules and BLU.db.profile.modules.battlepet == false then return end
    if owner ~= Enum.BattlePetOwner.Ally then return end

    BLU:PlayCategorySound("petcapture")

    if BLU.db.profile.debugMode then
        BLU:Print(BLU:Loc("DEBUG_BATTLE_PET_CAPTURED", tostring(petIndex)))
    end
end

-- Check for pet level changes
function BattlePet:CheckPetLevels()
    if not BLU.db or not BLU.db.profile then
        return
    end

    if BLU.db.profile.enabled == false or BLU.db.profile.enableBattlePet == false then
        return
    end

    if BLU.db.profile.modules and BLU.db.profile.modules.battlepet == false then
        return
    end

    if not C_PetJournal or not C_PetJournal.GetNumPets or not C_PetJournal.GetPetInfoByIndex or not C_PetJournal.GetPetInfoByPetID then
        return
    end

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
                    
                    if BLU.db.profile.debugMode then
                        BLU:Print(BLU:Loc("DEBUG_BATTLE_PET_LEVEL_NAME", name or BLU:Loc("UNKNOWN"), level))
                    end
                    
                    self.lastPetLevel[petID] = level
                end
            end
        end
    end
end

function BattlePet:SchedulePetLevelScan(delay)
    if self.pendingLevelScan then
        return
    end

    self.pendingLevelScan = true
    C_Timer.After(delay or 0.1, function()
        self.pendingLevelScan = false
        self:CheckPetLevels()
    end)
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["battlepet"] = BattlePet

-- Export module
return BattlePet
