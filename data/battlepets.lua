-- =====================================================================================
-- BLU | Better Level-Up! - battlepets.lua
-- =====================================================================================

-- ============================
-- Localization Table
-- ============================
-- Ensure BLU_L is available
local BLU_L = BLU_L or {}

-- ============================
-- Initialize BLU Table
-- ============================
local BLU = BLU or {}
BLU.previousPetLevels = BLU.previousPetLevels or {} -- Table to store pet levels
BLU.settings = BLU.settings or { debugMode = true } -- Enable debug mode
BLU.isInitialized = BLU.isInitialized or false -- Flag to prevent initial load triggering level-ups

-- ============================
-- Constants
-- ============================
local MAX_PET_LEVEL = 25 -- Maximum battle pet level

-- ============================
-- Utility Functions
-- ============================
-- Function: IsPetBattleItem
-- Purpose: Checks if the provided spellID corresponds to a pet battle item.
local function IsPetBattleItem(spellID)
    local petBattleItems = {
        -- Battle Pet Bandage
        [125439] = true,  -- Battle Pet Bandage (Item ID: 86143)
        -- Pet Treats
        [142409] = true,  -- Pet Treat (Item ID: 98112)
        [142410] = true,  -- Lesser Pet Treat (Item ID: 98114)
        [168791] = true,  -- Magical Pet Biscuit (Item ID: 113631)
        -- Battle-Training Stones
        [126988] = true,  -- Humanoid Battle-Training Stone (Item ID: 92741)
        [126989] = true,  -- Dragonkin Battle-Training Stone (Item ID: 92742)
        [126990] = true,  -- Flying Battle-Training Stone (Item ID: 92743)
        [126991] = true,  -- Undead Battle-Training Stone (Item ID: 92744)
        [126992] = true,  -- Critter Battle-Training Stone (Item ID: 92745)
        [126993] = true,  -- Magic Battle-Training Stone (Item ID: 92746)
        [126994] = true,  -- Elemental Battle-Training Stone (Item ID: 92747)
        [126995] = true,  -- Beast Battle-Training Stone (Item ID: 92748)
        [126996] = true,  -- Aquatic Battle-Training Stone (Item ID: 92749)
        [126997] = true,  -- Mechanical Battle-Training Stone (Item ID: 92750)
        [127755] = true,  -- Ultimate Battle-Training Stone (Item ID: 122457)
        -- Leveling Stones
        [177161] = true,  -- Flawless Battle-Training Stone (Item ID: 116429)
        [177162] = true,  -- Flawless Battle-Training Stone (Item ID: 116374)
        [177163] = true,  -- Flawless Battle-Training Stone (Item ID: 116415)
        [177164] = true,  -- Flawless Battle-Training Stone (Item ID: 116416)
        [177165] = true,  -- Flawless Battle-Training Stone (Item ID: 116417)
        [177166] = true,  -- Flawless Battle-Training Stone (Item ID: 116418)
        [177167] = true,  -- Flawless Battle-Training Stone (Item ID: 116419)
        [177168] = true,  -- Flawless Battle-Training Stone (Item ID: 116420)
        [177169] = true,  -- Flawless Battle-Training Stone (Item ID: 116421)
        [177170] = true,  -- Flawless Battle-Training Stone (Item ID: 116422)
        -- Family-Specific Training Stones
        [173266] = true,  -- Humanoid Battle-Training Stone (Item ID: 165846)
        [173267] = true,  -- Dragonkin Battle-Training Stone (Item ID: 165847)
        [173268] = true,  -- Flying Battle-Training Stone (Item ID: 165848)
        [173269] = true,  -- Undead Battle-Training Stone (Item ID: 165849)
        [173270] = true,  -- Critter Battle-Training Stone (Item ID: 165850)
        [173271] = true,  -- Magic Battle-Training Stone (Item ID: 165851)
        [173272] = true,  -- Elemental Battle-Training Stone (Item ID: 165852)
        [173273] = true,  -- Beast Battle-Training Stone (Item ID: 165853)
        [173274] = true,  -- Aquatic Battle-Training Stone (Item ID: 165854)
        [173275] = true,  -- Mechanical Battle-Training Stone (Item ID: 165855)
        -- Other Consumables
        [366246] = true,  -- Purewater Pet Fish (Item ID: 187811)
        [340027] = true,  -- Pouch of Razor Sharp Teeth (Item ID: 180089)
        -- Add more spellIDs for pet battle items as needed
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
    -- Fetch pet info by petID
    local speciesID, _, level, _, _, _, _, petName = C_PetJournal.GetPetInfoByPetID(petID)
    if not level then
        self:PrintDebugMessage("INVALID_PET_LEVEL", petID)
        return
    end

    -- Get the pet's name and level
    local displayName = petName or BLU_L["UNKNOWN_PET"]

    -- Add debug message
    self:PrintDebugMessage("PET_LEVEL_UP_TRIGGERED", displayName, level)

    self:TriggerLevelUpSound(displayName, level)

    -- Update the stored level and species ID
    self.previousPetLevels[petID] = {
        level = level,
        speciesID = speciesID,
    }
end

-- Function: TriggerLevelUpSound
-- Purpose: Plays the level-up sound and displays a message.
function BLU:TriggerLevelUpSound(petName, currentLevel)
    
    -- Use HandleEvent to trigger the sound (assuming it's defined elsewhere)
    if self.HandleEvent then
        self:HandleEvent("PET_LEVEL_UP", "BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds[2])
    end
end

-- ============================
-- Pet Data Management
-- ============================
-- Function: UpdatePetData
-- Purpose: Updates and stores pet levels from the Pet Journal.
function BLU:UpdatePetData()
    -- Fetch total number of pets (collected and uncollected)
    local numPets = C_PetJournal.GetNumPets()
    if not numPets or numPets == 0 then
        self:PrintDebugMessage("NO_PETS_FOUND")
        return
    end

    -- Create a table to store current pet levels
    local currentPetLevels = {}

    -- Loop through all pets
    for i = 1, numPets do
        -- Fetch pet info by index
        local petID, speciesID, isOwned, _, level = C_PetJournal.GetPetInfoByIndex(i)
        if petID and isOwned then
            if level and level >= 1 and level <= MAX_PET_LEVEL then
                currentPetLevels[petID] = {
                    level = level,
                    speciesID = speciesID,
                }
            end
        end
    end

    if self.isInitialized then
        -- Compare current levels to previous levels to detect level-ups
        for petID, petData in pairs(currentPetLevels) do
            local previousData = self.previousPetLevels[petID]
            local previousLevel = previousData and previousData.level or 0
            if petData.level > previousLevel then
                -- Pet has leveled up
                self:HandlePetLevelUp(petID)
            end
        end
    else
        -- Initial data load, do not trigger level-up notifications
        self.isInitialized = true
        self:PrintDebugMessage("INIT_LOAD_COMPLETE")
    end

    -- Update previousPetLevels with current levels
    self.previousPetLevels = currentPetLevels
end

-- Function: CheckPetJournalForLevelUps
-- Purpose: Checks for pet level-ups after certain events.
function BLU:CheckPetJournalForLevelUps()
    self:UpdatePetData()
end

-- ============================
-- Event Handler
-- ============================
-- Main event handler function
function BLU:HandleEvents(event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unitTarget, castGUID, spellID = ...
        -- Ensure the spell cast is by the player
        if unitTarget == "player" and IsPetBattleItem(spellID) then
            -- Check for pet level-ups when a pet battle item is used
            self:CheckPetJournalForLevelUps()
        end
    elseif event == "PLAYER_LOGIN" then
        -- Store pet data when the player logs in
        self:UpdatePetData()
    elseif event == "PET_BATTLE_LEVEL_CHANGED" or event == "UNIT_PET_EXPERIENCE" then
        -- Update pet data and check for level-ups
        self:UpdatePetData()
    elseif event == "PET_JOURNAL_LIST_UPDATE" then
        -- Secondary check for level-ups
        self:CheckPetJournalForLevelUps()
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
eventFrame:RegisterEvent("PET_BATTLE_LEVEL_CHANGED")
eventFrame:RegisterEvent("UNIT_PET_EXPERIENCE")
eventFrame:RegisterEvent("PET_JOURNAL_LIST_UPDATE")