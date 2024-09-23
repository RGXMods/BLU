--=====================================================================================
-- BLU | Better Level Up! - petTracking.lua
--=====================================================================================
local BLU = BLU or {}  -- Ensure BLU is referencing the correct addon object as a table
BLU.previousPetLevels = {}  -- Stores the initial pet levels on login
BLU.currentPetLevels = {}   -- Temporary table to store current pet levels
BLU.dataInitialized = false -- Prevents level-up detection during initial load

-- Cooldown to prevent sound spamming
BLU.soundCooldowns = {} -- Table to store cooldown timers per pet

-- =====================================================================================
-- Helper Functions (Utility)
-- =====================================================================================
BLU.L = BLU.L or {}
local L = BLU.L

-- Function to check for cooldowns on sound triggers
function BLU:CanPlaySound(petID)
    local cooldown = self.soundCooldowns[petID]
    if cooldown and cooldown > GetTime() then
        return false
    end
    -- Set a cooldown of 2 seconds (adjust as needed)
    self.soundCooldowns[petID] = GetTime() + 2
    return true
end

-- =====================================================================================
-- Pet Level-Up Handling (Core Functionality)
-- =====================================================================================

function BLU:HandlePetLevelUp(petID, currentLevel)
    -- Ensure valid level data
    if not petID or not currentLevel then
        self:PrintDebugMessage("Invalid petID or currentLevel. PetID: " .. tostring(petID) .. ", Level: " .. tostring(currentLevel))
        return
    end

    -- Avoid triggering level-ups during the initial load
    if not self.dataInitialized then
        self:PrintDebugMessage("Skipping level-up detection during initial data load")
        return
    end

    self:PrintDebugMessage("PET_LEVEL_UP_TRIGGERED for PetID: " .. tostring(petID) .. " Level: " .. tostring(currentLevel))
    
    -- Ensure we only play sound after checking cooldown
    if self:CanPlaySound(petID) then
        -- Use the correct keys for battle pet sound and volume
        self:HandleEvent("PET_LEVEL_UP", "BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds[2])
    end
end

-- Update pet data
function BLU:UpdatePetData()
    if not C_PetJournal.IsJournalUnlocked() then
        return
    end

    local numPets = C_PetJournal.GetNumPets()
    if not numPets or numPets == 0 then
        return
    end

    -- Populate currentPetLevels
    wipe(self.currentPetLevels)

    for i = 1, numPets do
        local petID, speciesID, isOwned, customName, level, favorite, isRevoked, speciesName, icon, petType = C_PetJournal.GetPetInfoByIndex(i)

        if petID then
            local health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(petID)
            local _, _, _, _, _, _, _, _, _, _, _, _, _, _, canBattle = C_PetJournal.GetPetInfoByPetID(petID)

            if canBattle and level and type(level) == "number" and level >= 1 and level <= 25 then
                self.currentPetLevels[petID] = {
                    customName = customName,
                    speciesName = speciesName,
                    level = level,
                    canBattle = canBattle,
                    icon = icon,
                    maxHealth = maxHealth,
                    power = power,
                    speed = speed
                }

                -- Debug print
                self:PrintDebugMessage("Tracking pet:", speciesName, "ID:", petID, "Level:", level)
            end
        end
    end

    -- Mark data as initialized after the first load
    if not self.dataInitialized then
        self.dataInitialized = true
        -- Initialize previousPetLevels with currentPetLevels
        wipe(self.previousPetLevels)
        for petID, petInfo in pairs(self.currentPetLevels) do
            self.previousPetLevels[petID] = petInfo
        end
        self:PrintDebugMessage("Pet data initialized.")
    end
end

-- Check for level-ups and process them
function BLU:CheckPetJournalForLevelUps()
    if not self.dataInitialized then
        self:PrintDebugMessage("Skipping level-up detection during initial data load.")
        return
    end

    self:PrintDebugMessage("Checking for pet level-ups...")

    for petID, petInfo in pairs(self.currentPetLevels) do
        local previousLevel = self.previousPetLevels[petID] and self.previousPetLevels[petID].level or 0

        if petInfo.level > previousLevel then
            self:HandlePetLevelUp(petID, petInfo.level)
        end
    end

    -- Update previousPetLevels to match currentPetLevels
    wipe(self.previousPetLevels)
    for petID, petInfo in pairs(self.currentPetLevels) do
        self.previousPetLevels[petID] = petInfo
    end
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
eventFrame:RegisterEvent("PET_BATTLE_OPENING_START")
eventFrame:RegisterEvent("PET_BATTLE_CLOSE")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:RegisterEvent("PET_BATTLE_LEVEL_CHANGED")
eventFrame:RegisterEvent("UNIT_PET_EXPERIENCE")
eventFrame:RegisterEvent("BAG_UPDATE_DELAYED")

-- PLAYER_LOGIN event handler
function BLU:PLAYER_LOGIN()
    if self:GetGameVersion() == "retail" then
        -- Clear any search filters
        C_PetJournal.ClearSearchFilter()
        self:UpdatePetData() -- Initialize pet data on login

        -- Output to chat
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Tracked Pet Levels Initialized on Login.|r")
    end
end

-- Handle updates to the Pet Journal
function BLU:PET_JOURNAL_LIST_UPDATE()
    self:UpdatePetData()
    self:CheckPetJournalForLevelUps()
end

-- Handle Pet Battle events
function BLU:PET_BATTLE_OPENING_START()
    C_Timer.After(0.2, function()
        BLU:UpdatePetData()
        BLU:CheckPetJournalForLevelUps()
    end)
end

function BLU:PET_BATTLE_CLOSE()
    C_Timer.After(0.2, function()
        BLU:UpdatePetData()
        BLU:CheckPetJournalForLevelUps()
    end)
end

-- Handle Combat Log events for potential pet level-ups
function BLU:COMBAT_LOG_EVENT_UNFILTERED()
    local _, eventType = CombatLogGetCurrentEventInfo()
    if eventType == "UNIT_DIED" or eventType == "UNIT_DESTROYED" then
        -- Delay to ensure pet data is updated
        C_Timer.After(0.1, function()
            BLU:UpdatePetData()
            BLU:CheckPetJournalForLevelUps()
        end)
    end
end

-- Handle pet level-up related events
function BLU:PET_BATTLE_LEVEL_CHANGED(petID, newLevel)
    if petID and newLevel then
        BLU:HandlePetLevelUp(petID, newLevel)
    else
        -- Fallback: Check all pets if parameters are missing
        BLU:UpdatePetData()
        BLU:CheckPetJournalForLevelUps()
    end
end

function BLU:UNIT_PET_EXPERIENCE(unitID, currentXP, maxXP)
    if unitID then
        -- Determine which pet corresponds to the unitID
        -- Assuming unitID "player" corresponds to the player's main pet
        local petID = C_PetJournal.GetPetIDForPetSlot(1) -- Adjust the slot index as needed
        if petID then
            local _, _, currentLevel = C_PetJournal.GetPetInfoByPetID(petID)
            if currentLevel then
                BLU:HandlePetLevelUp(petID, currentLevel)
            else
                -- If currentLevel is not available, fallback to checking all pets
                BLU:UpdatePetData()
                BLU:CheckPetJournalForLevelUps()
            end
        else
            -- If petID can't be determined, fallback to checking all pets
            BLU:UpdatePetData()
            BLU:CheckPetJournalForLevelUps()
        end
    else
        BLU:CheckPetJournalForLevelUps()
    end
end

function BLU:BAG_UPDATE_DELAYED()
    -- BAG_UPDATE_DELAYED doesn't provide pet-specific information
    -- It's best to iterate through all pets to detect any level changes
    BLU:UpdatePetData()
    BLU:CheckPetJournalForLevelUps()
end
