-- =====================================================================================
-- BLU | Better Level-Up! - battlepets.lua
-- =====================================================================================
-- Author: Your Name
-- Description: Tracks battle pet levels, handles level-up events, and responds with sounds and notifications.
-- =====================================================================================

-- ============================
-- Localization Table
-- ============================
local BLU_L = BLU_L or {
    ["PET_LEVEL_UP"] = "Your pet '%s' has reached level %d!"
}

-- ============================
-- Initialize BLU Table
-- ============================
local BLU = BLU or {}
BLU.previousPetLevels = BLU.previousPetLevels or {} -- Temporary table to store pet levels
BLU.settings = BLU.settings or { debugMode = false } -- Ensure settings are initialized
BLU.petData = BLU.petData or {} -- Initialize the petData table

-- ============================
-- Constants
-- ============================
local MAX_PET_LEVEL = 25 -- Maximum battle pet level
local defaultSounds = { [2] = "Interface\\AddOns\\BetterLevelUp\\Sounds\\LevelUp.ogg" } -- Example sound path

-- ============================
-- Utility Functions
-- ============================
-- Utility function to check if the spellID corresponds to a pet battle item
local function IsPetBattleItem(spellID)
    local petBattleItems = {
        [171525] = true,  -- Flawless Battle-Training Stone
        [122457] = true,  -- Ultimate Battle-Training Stone
        [141694] = true,  -- Pet Treat
        [86143]  = true,  -- Battle Pet Bandage
    }
    return petBattleItems[spellID] or false
end

-- ============================
-- Level-Up Handling Functions
-- ============================

-- Function: HandlePetLevelUp
-- Purpose: Processes a pet level-up event.
function BLU:HandlePetLevelUp(petID)
    petID = tostring(petID)
    local name, _, currentLevel = C_PetJournal.GetPetInfoByPetID(petID)

    if not currentLevel then
        if BLU.settings.debugMode then
            print("|cFFFF0000[BLU Error]|r Invalid pet level data for PetID: " .. petID)
        end
        return
    end

    local previousLevel = self.previousPetLevels[petID] or 0

    -- Check if the pet's level increased
    if currentLevel > previousLevel then
        self:TriggerLevelUpSound(name, currentLevel)
        self.previousPetLevels[petID] = currentLevel -- Update the stored level
    end
end

-- Trigger the sound for pet level-up using the HandleEvent method from utils.lua
function BLU:TriggerLevelUpSound(petName, currentLevel)
    -- Print the pet level-up message
    if BLU_L["PET_LEVEL_UP"] then
        print("|cFF00FF00[BLU]|r " .. BLU_L["PET_LEVEL_UP"]:format(petName, currentLevel))
    else
        print("|cFF00FF00[BLU]|r Pet '%s' has reached level %d!"):format(petName, currentLevel)
    end

    -- Use HandleEvent to trigger the sound (using utils.lua's event queue)
    if defaultSounds[2] then
        self:HandleEvent("PET_LEVEL_UP", "BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds[2])
    else
        if BLU.settings.debugMode then
            print("|cFFFF0000[BLU Error]|r Default sound is missing.")
        end
    end
end

-- ============================
-- Pet Data Management
-- ============================

-- Update and store pet levels from the Pet Journal (runs on login)
function BLU:UpdatePetData()
    -- Ensure petData table exists
    BLU.petData = BLU.petData or {}

    -- Check if the Pet Journal is unlocked
    if not C_PetJournal.IsJournalUnlocked() then
        self:PrintDebugMessage("Pet journal is not unlocked.")
        return
    end

    -- Fetch total number of pets
    local numPets = C_PetJournal.GetNumPets()
    self:PrintDebugMessage(string.format("Total pets found: %d", numPets))

    if not numPets or numPets == 0 then
        self:PrintDebugMessage("No pets found in the journal.")
        return
    end

    -- Clear current pet data before updating
    wipe(BLU.petData)

    -- Loop through all pets
    for i = 1, numPets do
        -- Get pet info by index (the second return value is the petID)
        local _, petID = C_PetJournal.GetPetInfoByIndex(i)

        -- Fetch detailed info for the pet using its petID
        if petID then
            local speciesID, customName, level, xp, maxXp, displayID, isFavorite, isRevoked, speciesName, icon, petType, creatureID, canBattle = C_PetJournal.GetPetInfoByPetID(petID)

            -- Debugging output to verify retrieved pet info
            self:PrintDebugMessage(string.format(
                "Retrieved Pet Info - petID: %s, customName: %s, Level: %d, canBattle: %s", 
                tostring(petID), tostring(customName), level or -1, tostring(canBattle)
            ))

            -- Store valid pet data if it's a valid battle pet with a proper level
            if canBattle and level and type(level) == "number" and level >= 1 and level <= 25 then
                BLU.petData[petID] = level
                self:PrintDebugMessage(string.format("Stored Pet ID: %s, Level: %d", tostring(petID), level))
            else
                self:PrintDebugMessage(string.format("Invalid or non-battle pet data for Pet ID: %s, Level: %d", petID or "N/A", level or -1))
            end
        else
            self:PrintDebugMessage(string.format("Invalid pet entry for index: %d", i))
        end
    end
end

-- ============================
-- Event Handler
-- ============================

-- Main event handler function
function BLU:HandleEvents(event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local _, _, spellID = ...
        -- If the spell cast is a pet battle item, check levels
        if IsPetBattleItem(spellID) then
            if BLU.settings.debugMode then
                print("|cFF00FF00[BLU Debug]|r Pet Battle Item used, checking pet levels.")
            end
            -- Check for pet level-ups when a pet battle item is used
            self:CheckPetJournalForLevelUps()
        end
    elseif event == "PLAYER_LOGIN" then
        -- Store pet data when the player logs in
        self:UpdatePetData()
    end
end

-- Function to check pet levels for possible level-ups after a pet item is used
function BLU:CheckPetJournalForLevelUps()
    local numPets = C_PetJournal.GetNumPets()
    for i = 1, numPets do
        local petID, _, isOwned, _, currentLevel = C_PetJournal.GetPetInfoByIndex(i)
        if petID and isOwned and currentLevel and currentLevel > (self.previousPetLevels[tostring(petID)] or 0) then
            -- If a pet's level increased, trigger the level-up sound
            self:HandlePetLevelUp(petID)
        end
    end
end

-- ============================
-- Event Registration
-- ============================

-- Create an event frame to listen for addon events
local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    BLU:HandleEvents(event, ...)
end)

-- Register events
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
