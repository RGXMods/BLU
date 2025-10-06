--=====================================================================================
-- BLU | Better Level-Up! - core.lua
--=====================================================================================
BLU_L = BLU_L or {}
---BLU:HandleEvent(eventName, soundSelectKey, volumeKey, defaultSound, debugMessage)

function BLU:HandlePlayerLevelUp()
    self:HandleEvent("PLAYER_LEVEL_UP", "LevelSoundSelect", "LevelVolume", defaultSounds[4], "PLAYER_LEVEL_UP_TRIGGERED")
end

function BLU:HandleQuestAccepted()
    self:HandleEvent("QUEST_ACCEPTED", "QuestAcceptSoundSelect", "QuestAcceptVolume", defaultSounds[7], "QUEST_ACCEPTED_TRIGGERED")
    
end

function BLU:HandleQuestTurnedIn()
    self:HandleEvent("QUEST_TURNED_IN", "QuestSoundSelect", "QuestVolume", defaultSounds[8], "QUEST_TURNED_IN_TRIGGERED")
end

function BLU:HandleAchievementEarned()
    self:HandleEvent("ACHIEVEMENT_EARNED", "AchievementSoundSelect", "AchievementVolume", defaultSounds[1], "ACHIEVEMENT_EARNED_TRIGGERED")
end

function BLU:HandleHonorLevelUpdate()
    self:HandleEvent("HONOR_LEVEL_UPDATE", "HonorSoundSelect", "HonorVolume", defaultSounds[5], "HONOR_LEVEL_UPDATE_TRIGGERED")
end

function BLU:HandleRenownLevelChanged()
    self:HandleEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", "RenownSoundSelect", "RenownVolume", defaultSounds[6], "MAJOR_FACTION_RENOWN_LEVEL_CHANGED_TRIGGERED")
end

function BLU:HandlePerksActivityCompleted()
    self:HandleEvent("PERKS_ACTIVITY_COMPLETED", "PostSoundSelect", "PostVolume", defaultSounds[9], "PERKS_ACTIVITY_COMPLETED_TRIGGERED")
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
        elseif string.match(msg, "Your standing with") then -- start of new shit
            self:PrintDebugMessage("|cff00ff00Rank found: Acquaintance|r")
            self:ReputationRankIncrease("Acquaintance", msg)
            rankFound = true
        elseif string.match(msg, "Your standing with") then
            self:PrintDebugMessage("|cff00ff00Rank found: Crony|r")
            self:ReputationRankIncrease("Crony", msg)
            rankFound = true
        elseif string.match(msg, "Your standing with") then
            self:PrintDebugMessage("|cff00ff00Rank found: Accomplice|r")
            self:ReputationRankIncrease("Accomplice", msg)
            rankFound = true
        elseif string.match(msg, "Your standing with") then
            self:PrintDebugMessage("|cff00ff00Rank found: Collaborator|r")
            self:ReputationRankIncrease("Collaborator", msg)
            rankFound = true
        elseif string.match(msg, "Your standing with") then
            self:PrintDebugMessage("|cff00ff00Rank found: Accessory|r")
            self:ReputationRankIncrease("Accessory", msg)
            rankFound = true
        elseif string.match(msg, "Your standing with") then
            self:PrintDebugMessage("|cff00ff00Rank found: Abettor|r")
            self:ReputationRankIncrease("Abettor", msg)
            rankFound = true
        elseif string.match(msg, "Your standing with") then
            self:PrintDebugMessage("|cff00ff00Rank found: Conspirator|r")
            self:ReputationRankIncrease("Conspirator", msg)
            rankFound = true
        elseif string.match(msg, "Your standing with") then
            self:PrintDebugMessage("|cff00ff00Rank found: Mastermind|r")
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

    -- Extract the faction name from the message
    local factionName = string.match(msg, "with (.+)")
    
    -- Use HandleEvent for consistency
    self:HandleEvent("REPUTATION_RANK_INCREASE", "RepSoundSelect", "RepVolume", defaultSounds[6], "REPUTATION_RANK_INCREASE_TRIGGERED")
end

