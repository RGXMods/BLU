-- =====================================================================================
-- BLU | Better Level Up! - battlepets.lua
-- =====================================================================================

BLU_L = BLU_L or {}
BLU = BLU or {}

-- Initialize pet tracking
BLU.previousPetLevels = {}  -- Stores the initial pet levels on login
local lastSoundTime = {}
local SOUND_COOLDOWN = 2

BLU.petData = {} -- This will now be used to store the *current* pet levels during checks

-- Register events
function BLU:RegisterPetEvents()
    self:RegisterEvent("PLAYER_LOGIN", "OnPlayerLogin")
    self:RegisterEvent("PET_JOURNAL_LIST_UPDATE", "HandlePetJournalUpdate")
    self:RegisterEvent("PET_BATTLE_LEVEL_CHANGED", "HandlePetLevelUp") 
    self:RegisterEvent("UNIT_PET_EXPERIENCE", "HandlePetLevelUp")
    self:RegisterEvent("BAG_UPDATE_DELAYED", "HandlePetLevelUp") 
end

-- PLAYER_LOGIN event handler
function BLU:OnPlayerLogin()
    if self:GetGameVersion() == "retail" then
        -- Clear any search filters
        C_PetJournal.ClearSearchFilter()
        self:UpdatePetData() -- Initialize pet data on login, store in BLU.previousPetLevels
        self:PrintDebugMessage("Player login detected, pet data initialized.")
        self:PrintStoredData()
    end
end

-- Handle Pet Journal Updates
function BLU:HandlePetJournalUpdate()
    -- Delay to stabilize the Pet Journal data (optional, might not be needed)
    C_Timer.After(0.2, function()
        self:CheckPetJournalForLevelUps()
    end)
end

-- Pet Level-Up Event Handlers 
function BLU:HandlePetLevelUp(event, ...)
    self:PrintDebugMessage(string.format("Handling event: %s", event))

    if event == "BAG_UPDATE_DELAYED" then
        local lastUsedItemID = self.db.profile.lastUsedItemID

        if lastUsedItemID and self:IsPetLevelUpItem(lastUsedItemID) then
            self.db.profile.lastUsedItemID = nil
            -- Force Pet Journal update
            C_PetJournal.ClearSearchFilter()
        end
    end

    -- Delay to ensure pet journal is updated
    C_Timer.After(0.2, function()
        self:CheckPetJournalForLevelUps(event == "BAG_UPDATE_DELAYED")
    end)
end

-- Check for level-ups and process them
function BLU:CheckPetJournalForLevelUps(isItemTriggered)
    isItemTriggered = isItemTriggered or false

    self:UpdatePetData() -- Update BLU.petData with current pet levels

    for petID, currentLevel in pairs(BLU.petData) do
        local previousLevel = BLU.previousPetLevels[petID] or 0 
        if currentLevel > previousLevel then
            self:ProcessPetLevelUp(petID, currentLevel, false, isItemTriggered)
        else
            self:PrintDebugMessage(string.format("No level-up detected for Pet ID: %s, Previous Level: %d, Current Level: %d", petID, previousLevel, currentLevel))
        end
    end

    -- Output stored information after processing level-ups
    self:PrintStoredData()
end

-- Update pet data in the journal (store only levels)
function BLU:UpdatePetData()
    if not C_PetJournal.IsJournalUnlocked() then
        self:PrintDebugMessage("Pet journal is not unlocked.")
        return
    end

    local numPets = C_PetJournal.GetNumPets()
    self:PrintDebugMessage(string.format("Total pets found: %d", numPets))

    if not numPets or numPets == 0 then
        self:PrintDebugMessage("No pets found in the journal.")
        return
    end

    -- Clear current pet data before updating
    wipe(BLU.petData)

    for i = 1, numPets do
        -- Get the pet's unique ID from the second argument
        local _, petID = C_PetJournal.GetPetInfoByIndex(i)

        -- Fetch detailed info for the pet by its petID
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

-- Process Each Pet's Level-Up 
function BLU:ProcessPetLevelUp(petID, currentLevel, suppressSound, isItemTriggered)
    if not petID or not currentLevel then return end

    local storedLevel = BLU.previousPetLevels[petID] 

    if currentLevel > storedLevel then 
        local currentTime = GetTime()
        self:PrintDebugMessage(string.format("Processing level-up for Pet ID: %s, New Level: %d", tostring(petID), currentLevel))

        if (lastSoundTime[petID] or 0) + SOUND_COOLDOWN <= currentTime then
            if not suppressSound then 
                self:HandleEvent("PET_LEVEL_UP", "BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds[2])
            end
            lastSoundTime[petID] = currentTime
        end

        -- Update the stored level after a successful level-up
        BLU.previousPetLevels[petID] = currentLevel 
    elseif not storedLevel then -- Store the initial level if it's not already stored
        BLU.previousPetLevels[petID] = currentLevel
    end
end

-- Helper function to check if an item is a pet level-up item
function BLU:IsPetLevelUpItem(itemID)
    local petLevelUpItems = {
        122457, 116429, 98587, 128417, 171003, 171004, 171005, 171006, 171007, 
        171008, 171009, 171010, 171011, 171012
    }
    return tContains(petLevelUpItems, itemID)
end
