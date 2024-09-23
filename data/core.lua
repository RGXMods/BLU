--=====================================================================================
-- BLU | Better Level Up! - core.lua (Fixing Misfires)
--=====================================================================================

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
    self:PrintDebugMessage("PERKS_ACTIVITY_COMPLETED_TRIGGERED")
    self:HandleEvent("PERKS_ACTIVITY_COMPLETED", "PostSoundSelect", "PostVolume", defaultSounds[9])
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

--=====================================================================================
-- Reputation Event Handler with Hardcoded Rank Matching
--=====================================================================================

function BLU:ReputationRankIncrease(rank, msg)
    if self.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end

    -- Extract the faction name from the message
    local factionName = string.match(msg, "with (.+)")

    self:PrintDebugMessage("Reputation rank increase triggered for rank: " .. rank .. " with faction: " .. factionName)

    -- Use HandleEvent to manage sound and volume handling
    self:HandleEvent("REPUTATION_RANK_INCREASE", "RepSoundSelect", "RepVolume", defaultSounds[6])
end

function BLU:ReputationChatFrameHook()
    if self.chatFrameHooked then return end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, msg)
        self:PrintDebugMessage("INCOMING_CHAT_MESSAGE: " .. msg)
        local rankPatterns = {
            { "Exalted", "You are now Exalted with" },
            { "Revered", "You are now Revered with" },
            { "Honored", "You are now Honored with" },
            { "Friendly", "You are now Friendly with" },
            { "Neutral", "You are now Neutral with" },
            { "Unfriendly", "You are now Unfriendly with" },
            { "Hostile", "You are now Hostile with" },
            { "Hated", "You are now Hated with" }
        }

        for _, rank in pairs(rankPatterns) do
            if string.match(msg, rank[2]) then
                self:PrintDebugMessage("Rank found: " .. rank[1])
                self:ReputationRankIncrease(rank[1], msg)
                return false
            end
        end

        self:PrintDebugMessage("NO_RANK_FOUND")
        return false
    end)

    self.chatFrameHooked = true
end


--=====================================================================================
-- Delve Level-Up Event Handler
--=====================================================================================

function BLU:OnDelveCompanionLevelUp(event, ...)
    self:PrintDebugMessage(BLU_L["DELVE_LEVEL_UP_AWAITING_CONFIRMATION"])

    if event == "CHAT_MSG_SYSTEM" then
        local msg = ...
        self:PrintDebugMessage(BLU_L["INCOMING_CHAT_MESSAGE"] .. msg)

        local levelUpMatch = string.match(msg, "Brann Bronzebeard has reached Level (%d+)")
        if levelUpMatch then
            local level = tonumber(levelUpMatch)
            self:PrintDebugMessage(BLU_L["BRANN_LEVEL_UP_DETECTED"] .. level)
            self:HandleEvent("DELVE_LEVEL_UP", "DelveLevelUpSoundSelect", "DelveLevelUpVolume", defaultSounds[3])
        else
            self:PrintDebugMessage(BLU_L["NO_LEVEL_FOUND"])
        end
    end
end