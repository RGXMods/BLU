-- =====================================================================================
-- BLU | Better Level Up! - core.lua
-- =====================================================================================
BLU_L = BLU_L or {}
-- =====================================================================================
-- Event Handlers for Various Game Events
-- =====================================================================================

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

-- =====================================================================================
-- Test Sound Trigger Functions
-- =====================================================================================

local testSoundMappings = {
    TestAchievementSound = { "AchievementSoundSelect", "AchievementVolume", defaultSounds[1], BLU_L["TEST_ACHIEVEMENT_SOUND"] },
    TestBattlePetLevelSound = { "BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds[2], BLU_L["TEST_BATTLE_PET_LEVEL_SOUND"] },
    TestDelveLevelUpSound = { "DelveLevelUpSoundSelect", "DelveLevelUpVolume", defaultSounds[3], BLU_L["TEST_DELVE_LEVEL_UP_SOUND"] },
    TestHonorSound = { "HonorSoundSelect", "HonorVolume", defaultSounds[5], BLU_L["TEST_HONOR_SOUND"] },
    TestLevelSound = { "LevelSoundSelect", "LevelVolume", defaultSounds[4], BLU_L["TEST_LEVEL_SOUND"] },
    TestPostSound = { "PostSoundSelect", "PostVolume", defaultSounds[9], BLU_L["TEST_POST_SOUND"] },
    TestQuestAcceptSound = { "QuestAcceptSoundSelect", "QuestAcceptVolume", defaultSounds[7], BLU_L["TEST_QUEST_ACCEPT_SOUND"] },
    TestQuestSound = { "QuestSoundSelect", "QuestVolume", defaultSounds[8], BLU_L["TEST_QUEST_SOUND"] },
    TestRenownSound = { "RenownSoundSelect", "RenownVolume", defaultSounds[6], BLU_L["TEST_RENOWN_SOUND"] },
    TestRepSound = { "RepSoundSelect", "RepVolume", defaultSounds[6], BLU_L["TEST_REP_SOUND"] }
}

for name, params in pairs(testSoundMappings) do
    BLU[name] = function(self)
        self:TestSound(unpack(params))
    end
end

-- =====================================================================================
-- Reputation Event Handler with Hardcoded Rank Matching
-- =====================================================================================

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

function BLU:ReputationRankIncrease(rank, msg)
    if self.functionsHalted then return end
    local factionName = string.match(msg, "with (.+)")
    self:PrintDebugMessage("Reputation rank increase for " .. rank .. " with " .. factionName)

    local sound = self:SelectSound(self.db.profile.RepSoundSelect)
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND for ID: " .. self.db.profile.RepSoundSelect)
        return
    end
    self:PlaySelectedSound(sound, self.db.profile.RepVolume, defaultSounds[6])
end

-- =====================================================================================
-- Delve Level-Up Event Handler
-- =====================================================================================

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

