--=====================================================================================
-- BLU | Better Level Up! - core.lua
--=====================================================================================

--=====================================================================================
-- Event Handlers
--=====================================================================================
function BLU:HandlePlayerLevelUp()
    self:PrintDebugMessage("PLAYER_LEVEL_UP_TRIGGERED")
    self:HandleEvent("PLAYER_LEVEL_UP", "LevelSoundSelect", "LevelVolume", defaultSounds[4])
end

function BLU:HandleQuestAccepted()
    self:PrintDebugMessage("QUEST_ACCEPTED_TRIGGERED")
    self:HandleEvent("QUEST_ACCEPTED", "QuestAcceptSoundSelect", "QuestAcceptVolume", defaultSounds[7])
end

function BLU:HandleQuestTurnedIn()
    self:PrintDebugMessage("QUEST_TURNED_IN_TRIGGERED")
    self:HandleEvent("QUEST_TURNED_IN", "QuestSoundSelect", "QuestVolume", defaultSounds[8])
end

function BLU:HandleAchievementEarned()
    self:PrintDebugMessage("ACHIEVEMENT_EARNED_TRIGGERED")
    self:HandleEvent("ACHIEVEMENT_EARNED", "AchievementSoundSelect", "AchievementVolume", defaultSounds[1])
end

function BLU:HandleHonorLevelUpdate()
    self:PrintDebugMessage("HONOR_LEVEL_UPDATE_TRIGGERED")
    self:HandleEvent("HONOR_LEVEL_UPDATE", "HonorSoundSelect", "HonorVolume", defaultSounds[5])
end

function BLU:HandleRenownLevelChanged()
    self:PrintDebugMessage("MAJOR_FACTION_RENOWN_LEVEL_CHANGED_TRIGGERED")
    self:HandleEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", "RenownSoundSelect", "RenownVolume", defaultSounds[6])
end

--=====================================================================================
-- BLU | Better Level Up! - core.lua
--=====================================================================================

--=====================================================================================
-- Unified Pet Level-Up Handler
--=====================================================================================
local previousPetLevels = {}
local isPetJournalInitialized = false  -- Flag to track initial population
local lastPetLevelSoundTime = 0  -- Time of last pet level-up sound trigger
local PET_LEVEL_SOUND_COOLDOWN = 3  -- Cooldown period in seconds to prevent spamming

function BLU:HandlePetLevelUp(event, ...)
    if self.functionsHalted then
        self:PrintDebugMessage("HANDLE_PET_LEVEL_UP - Halt timer active, not processing.")
        return
    end

    local eventName = L[event] or "UnknownEvent"
    self:PrintDebugMessage(eventName .. " triggered")

    -- Check for pet level-up triggers from battles or experience gains
    if event == "PET_BATTLE_LEVEL_CHANGED" or event == "UNIT_PET_EXPERIENCE" then
        local petID = ...
        if petID then
            self:ProcessPetLevelUp(petID)
        else
            self:PrintDebugMessage("PetID missing, not processing event.")
        end
    -- Ensure `BAG_UPDATE_DELAYED` triggers sound when using pet level-up items
    elseif event == "PET_JOURNAL_LIST_UPDATE" or event == "BAG_UPDATE_DELAYED" then
        self:CheckPetJournalForLevelUps(true)  -- Pass 'true' to handle item-triggered level-ups
    end
end

-- Check for any level-ups after journal update or bag change
function BLU:CheckPetJournalForLevelUps(isItemTriggered)
    for i = 1, C_PetJournal.GetNumPets(false) do
        local petID = C_PetJournal.GetPetInfoByIndex(i)
        if petID then
            -- Handle pet level-ups triggered by items differently
            self:ProcessPetLevelUp(petID, not isPetJournalInitialized, isItemTriggered)
        end
    end

    if not isPetJournalInitialized then
        self:PrintDebugMessage("Pet journal initialized. Suppressing sounds for initial population.")
        isPetJournalInitialized = true
    end
end

-- Processes the pet level-up logic, handling both sound and debug messages
function BLU:ProcessPetLevelUp(petID, suppressSound, isItemTriggered)
    if self.functionsHalted then
        self:PrintDebugMessage("ProcessPetLevelUp - Halt timer active, not processing.")
        return
    end

    if not petID then
        self:PrintDebugMessage(L["ERROR_PET_ID_NIL"])
        return
    end

    -- Retrieve pet info using petGUID
    local _, customName, level = C_PetJournal.GetPetInfoByPetID(petID)

    if level and (not previousPetLevels[petID] or level > previousPetLevels[petID]) then
        self:PrintDebugMessage(L["HANDLE_PET_LEVEL_UP"]:format(customName or "Unnamed", level))

        -- Suppress sound if this is the journal's initial population, but not for item-triggered level-ups
        if not suppressSound or isItemTriggered then
            local currentTime = GetTime()
            if currentTime - lastPetLevelSoundTime >= PET_LEVEL_SOUND_COOLDOWN then
                self:HandleEvent("PET_LEVEL_UP", "BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds[2])
                lastPetLevelSoundTime = currentTime
            else
                self:PrintDebugMessage("ProcessPetLevelUp - Sound throttled.")
            end
        end

        -- Track the pet's latest level
        previousPetLevels[petID] = level
    else
        self:PrintDebugMessage("No level increase detected for pet with GUID: " .. petID)
    end
end



--=====================================================================================
-- Perks Activity Completed
--=====================================================================================
function BLU:HandlePerksActivityCompleted()
    self:PrintDebugMessage("PERKS_ACTIVITY_COMPLETED_TRIGGERED")
    self:HandleEvent("PERKS_ACTIVITY_COMPLETED", "PostSoundSelect", "PostVolume", defaultSounds[9])
end

--=====================================================================================
-- Reputation Event Handler with Hardcoded Rank Matching
--=====================================================================================
function BLU:ReputationChatFrameHook()
    -- Ensure this hook is only added once
    if BLU.chatFrameHooked then return end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, msg)
        self:PrintDebugMessage("INCOMING_CHAT_MESSAGE: " .. msg)

        local rankFound = false
        if string.match(msg, "You are now Exalted with") then
            self:PrintDebugMessage("|cff00ff00Rank found: Exalted|r")
            self:ReputationRankIncrease("Exalted", msg)
            rankFound = true
        elseif string.match(msg, "You are now Revered with") then
            self:PrintDebugMessage("|cff00ff00Rank found: Revered|r")
            self:ReputationRankIncrease("Revered", msg)
            rankFound = true
        elseif string.match(msg, "You are now Honored with") then
            self:PrintDebugMessage("|cff00ff00Rank found: Honored|r")
            self:ReputationRankIncrease("Honored", msg)
            rankFound = true
        elseif string.match(msg, "You are now Friendly with") then
            self:PrintDebugMessage("|cff00ff00Rank found: Friendly|r")
            self:ReputationRankIncrease("Friendly", msg)
            rankFound = true
        elseif string.match(msg, "You are now Neutral with") then
            self:PrintDebugMessage("|cff00ff00Rank found: Neutral|r")
            self:ReputationRankIncrease("Neutral", msg)
            rankFound = true
        elseif string.match(msg, "You are now Unfriendly with") then
            self:PrintDebugMessage("|cff00ff00Rank found: Unfriendly|r")
            self:ReputationRankIncrease("Unfriendly", msg)
            rankFound = true
        elseif string.match(msg, "You are now Hostile with") then
            self:PrintDebugMessage("|cff00ff00Rank found: Hostile|r")
            self:ReputationRankIncrease("Hostile", msg)
            rankFound = true
        elseif string.match(msg, "You are now Hated with") then
            self:PrintDebugMessage("|cff00ff00Rank found: Hated|r")
            self:ReputationRankIncrease("Hated", msg)
            rankFound = true
        end

        if not rankFound then
            self:PrintDebugMessage("NO_RANK_FOUND")
        end

        return false -- Ensure that the message is not blocked from being displayed
    end)

    BLU.chatFrameHooked = true
end

function BLU:ReputationRankIncrease(rank, msg)
    if self.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end

    -- Extract the faction name from the message
    local factionName = string.match(msg, "with (.+)")

    self:PrintDebugMessage("Reputation rank increase triggered for rank: " .. rank .. " with faction: " .. factionName)
    local sound = self:SelectSound(self.db.profile.RepSoundSelect)
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND: " .. self.db.profile.RepSoundSelect)
        return
    end
    local volumeLevel = self.db.profile.RepVolume
    self:PlaySelectedSound(sound, volumeLevel, defaultSounds[6])
end

--=====================================================================================
-- Delve Level-Up Event Handler
--=====================================================================================
function BLU:OnDelveCompanionLevelUp(event, ...)
    -- Print debug message for the triggering event
    self:PrintDebugMessage(event .. " event fired, awaiting CHAT_MSG_SYSTEM for confirmation.")

    -- Only proceed with the CHAT_MSG_SYSTEM event to finalize the check
    if event == "CHAT_MSG_SYSTEM" then
        local msg = ...
        self:PrintDebugMessage("INCOMING_CHAT_MESSAGE: " .. msg)

        -- Check if Brann's level-up message is found in the chat
        local levelUpMatch = string.match(msg, "Brann Bronzebeard has reached Level (%d+)")
        if levelUpMatch then
            local level = tonumber(levelUpMatch)
            self:PrintDebugMessage("|cff00ff00Brann Level-Up detected: Level " .. level .. "|r")

            -- Trigger event handling using the standard method
            self:HandleEvent("DELVE_LEVEL_UP", "DelveLevelUpSoundSelect", "DelveLevelUpVolume", defaultSounds[3])

        else
            self:PrintDebugMessage("NO_LEVEL_FOUND")
        end
    end
end

--=====================================================================================
-- Test Sound Trigger Functions
--=====================================================================================
function BLU:TestAchievementSound()
    self:TestSound("AchievementSoundSelect", "AchievementVolume", defaultSounds[1], "TEST_ACHIEVEMENT_SOUND")
end

function BLU:TestBattlePetLevelSound()
    self:TestSound("BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds[2], "TEST_BATTLE_PET_LEVEL_SOUND")
end

function BLU:TestDelveLevelUpSound()
    self:TestSound("DelveLevelUpSoundSelect", "DelveLevelUpVolume", defaultSounds[3], "TEST_DELVE_LEVEL_UP_SOUND")
end

function BLU:TestHonorSound()
    self:TestSound("HonorSoundSelect", "HonorVolume", defaultSounds[5], "TEST_HONOR_SOUND")
end

function BLU:TestLevelSound()
    self:TestSound("LevelSoundSelect", "LevelVolume", defaultSounds[4], "TEST_LEVEL_SOUND")
end

function BLU:TestPostSound()
    self:TestSound("PostSoundSelect", "PostVolume", defaultSounds[9], "TEST_POST_SOUND")
end

function BLU:TestQuestAcceptSound()
    self:TestSound("QuestAcceptSoundSelect", "QuestAcceptVolume", defaultSounds[7], "TEST_QUEST_ACCEPT_SOUND")
end

function BLU:TestQuestSound()
    self:TestSound("QuestSoundSelect", "QuestVolume", defaultSounds[8], "TEST_QUEST_SOUND")
end

function BLU:TestRenownSound()
    self:TestSound("RenownSoundSelect", "RenownVolume", defaultSounds[6], "TEST_RENOWN_SOUND")
end

function BLU:TestRepSound()
    self:TestSound("RepSoundSelect", "RepVolume", defaultSounds[6], "TEST_REP_SOUND")
end