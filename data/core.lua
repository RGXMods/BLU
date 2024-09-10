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

function BLU:HandlePetBattleLevelChanged()
    self:PrintDebugMessage("PET_BATTLE_LEVEL_CHANGED_TRIGGERED")
    self:HandleEvent("PET_BATTLE_LEVEL_CHANGED", "BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds[2])
end

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
            self:TriggerDelveLevelUpSound(level)
        else
            self:PrintDebugMessage("NO_LEVEL_FOUND")
        end
    end
end

--=====================================================================================
-- Trigger Sound on Delve Level-Up
--=====================================================================================
function BLU:TriggerDelveLevelUpSound(level)
    if self.functionsHalted then
        self:PrintDebugMessage("Functions halted. Event not processed.")
        return
    end

    self:PrintDebugMessage("Delve Level-Up sound triggered for Level " .. level)
    local sound = self:SelectSound(self.db.profile.DelveLevelUpSoundSelect)
    if not sound then
        self:PrintDebugMessage("Sound not found for sound ID: " .. self.db.profile.DelveLevelUpSoundSelect)
        return
    end
    local volumeLevel = self.db.profile.DelveLevelUpVolume
    self:PlaySelectedSound(sound, volumeLevel, defaultSounds[3])
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
