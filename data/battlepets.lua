
local addonName, BLU = ...
BLU.previousPetLevels = {}
BLU.currentPetLevels = {}
BLU.dataInitialized = false
BLU_L = BLU_L or {}

-- Cooldown to prevent sound spamming
BLU.soundCooldowns = {}

-- =====================================================================================
-- Helper Functions (Utility)
-- =====================================================================================

-- Function to check for cooldowns on sound triggers
function BLU:CanPlaySound(petID)
    if self.functionsHalted then
        return false
    end

    local cooldown = self.soundCooldowns[petID]
    if cooldown and cooldown > GetTime() then
        return false
    end

    -- Set a cooldown of 2 seconds (adjust as needed)
    self.soundCooldowns[petID] = GetTime() + 2
    return true
end

-- Function to handle pet level-up detection
function BLU:HandlePetLevelUp(petID, speciesID, currentLevel)
    if not petID or not currentLevel then
        self:PrintDebugMessage("[BLU] Invalid petID or currentLevel. PetID: " .. tostring(petID) .. ", Level: " .. tostring(currentLevel))
        return
    end

    if not self.initialLoadComplete then
        self:PrintDebugMessage("[BLU] Skipping level-up detection during initial data load")
        return
    end

    local previousLevel = self.previousPetLevels[speciesID] and self.previousPetLevels[speciesID].level or 0

    if currentLevel > previousLevel then
        self:PrintDebugMessage("[BLU] PET_LEVEL_UP_TRIGGERED for PetID: " .. tostring(petID) .. " | Species: " .. tostring(speciesID) .. " | Level: " .. tostring(currentLevel))

        if self:CanPlaySound(petID) then
            self:HandleEvent("PET_LEVEL_UP", "BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds[2])
            self.previousPetLevels[speciesID] = { level = currentLevel }
        else
            self:PrintDebugMessage("[BLU] Cooldown active or functions halted for PetID: " .. tostring(petID) .. ". No sound played.")
        end
    else
        self:PrintDebugMessage("[BLU] No level-up detected for PetID: " .. tostring(petID) .. " | Species: " .. tostring(speciesID) .. " | Level: " .. tostring(currentLevel))
    end
end

-- Update pet data and track current levels
function BLU:UpdatePetData()
    if not C_PetJournal.IsJournalUnlocked() then
        self:PrintDebugMessage("[BLU] Pet Journal is not unlocked, skipping pet data update.")
        return
    end

    local numPets = C_PetJournal.GetNumPets()
    if not numPets or numPets == 0 then
        self:PrintDebugMessage("[BLU] No pets found, skipping pet data update.")
        return
    end

    C_PetJournal.ClearSearchFilter()
    wipe(self.currentPetLevels)
    self:PrintDebugMessage("[BLU] Updating pet data for " .. tostring(numPets) .. " pets.")

    for i = 1, numPets do
        local petID, speciesID, isOwned, customName, level, favorite, isRevoked, speciesName, icon, petType = C_PetJournal.GetPetInfoByIndex(i)

        if petID then
            local _, _, _, _, _, _, _, _, _, _, _, _, _, _, canBattle = C_PetJournal.GetPetInfoByPetID(petID)

            if canBattle and level and type(level) == "number" and level >= 1 and level <= 25 then
                self.currentPetLevels[petID] = {
                    speciesID = speciesID,
                    customName = customName,
                    speciesName = speciesName,
                    level = level
                }

                if not self.previousPetLevels[speciesID] then
                    self.previousPetLevels[speciesID] = { level = level }
                end
            end
        end
    end

    if not self.dataInitialized then
        self.dataInitialized = true
        self:PrintDebugMessage("[BLU] Pet data initialized and previous pet levels stored.")
    end
end

-- Check for level-ups and process them
function BLU:CheckPetJournalForLevelUps()
    if not self.initialLoadComplete then
        self:PrintDebugMessage("[BLU] Skipping level-up check as initial load is incomplete.")
        return
    end

    for petID, petInfo in pairs(self.currentPetLevels) do
        if petInfo.level and petInfo.level > 0 then
            self:HandlePetLevelUp(petID, petInfo.speciesID, petInfo.level)
        end
    end

    self:PrintDebugMessage("[BLU] Pet levels checked and compared with previous levels.")
end

-- =====================================================================================
-- Event Handlers
-- =====================================================================================

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if BLU[event] then
        BLU[event](BLU, ...)
    end
end)

-- Register events
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
eventFrame:RegisterEvent("PET_BATTLE_LEVEL_CHANGED")
eventFrame:RegisterEvent("UNIT_PET_EXPERIENCE")
eventFrame:RegisterEvent("BAG_UPDATE_DELAYED")

-- PLAYER_LOGIN event handler
function BLU:PLAYER_LOGIN()
    if self:GetGameVersion() == "retail" then
        self:UpdatePetData()
        self.initialLoadComplete = true

        self:HaltOperations()
        C_Timer.After(15, function()
            self:ResumeOperations()
            self:PrintDebugMessage("[BLU] Pet level-up sounds are now enabled.")
        end)

        self:PrintDebugMessage("|cff00ff00Tracked Pet Levels Initialized on Login. Sounds halted for 15 seconds.|r")
    end
end

-- Handle updates to the Pet Journal
function BLU:PET_JOURNAL_LIST_UPDATE()
    self:UpdatePetData()
    self:CheckPetJournalForLevelUps()
end

-- Handle pet level-up events
function BLU:PET_BATTLE_LEVEL_CHANGED(petID, newLevel)
    BLU:HandlePetLevelUp(petID, speciesID, newLevel)
end

-- Handle experience changes
function BLU:UNIT_PET_EXPERIENCE(unitID, currentXP, maxXP)
    BLU:UpdatePetData()
    BLU:CheckPetJournalForLevelUps()
end

-- Handle bag updates related to pet items
function BLU:BAG_UPDATE_DELAYED()
    BLU:UpdatePetData()
    BLU:CheckPetJournalForLevelUps()
end
