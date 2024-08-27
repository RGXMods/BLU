--=====================================================================================
-- BLU | Better Level Up!
--=====================================================================================

-- Variables to track triggered reputation events with cooldowns
local triggeredReputationRanks = {}

-- Cooldown period in seconds to prevent multiple triggers in quick succession
local reputationCooldown = 2

--=====================================================================================
-- Event Handlers
--=====================================================================================
function BLU:HandlePlayerLevelUp()
    HandleEvent(self, "PLAYER_LEVEL_UP", "LevelSoundSelect", "LevelVolume", defaultSounds[4])
end

function BLU:HandleQuestAccepted()
    HandleEvent(self, "QUEST_ACCEPTED", "QuestAcceptSoundSelect", "QuestAcceptVolume", defaultSounds[7])
end

function BLU:HandleQuestTurnedIn()
    HandleEvent(self, "QUEST_TURNED_IN", "QuestSoundSelect", "QuestVolume", defaultSounds[8])
end

function BLU:HandleAchievementEarned()
    HandleEvent(self, "ACHIEVEMENT_EARNED", "AchievementSoundSelect", "AchievementVolume", defaultSounds[1])
end

function BLU:HandleHonorLevelUpdate()
    HandleEvent(self, "HONOR_LEVEL_UPDATE", "HonorSoundSelect", "HonorVolume", defaultSounds[5])
end

function BLU:HandleRenownLevelChanged()
    HandleEvent(self, "MAJOR_FACTION_RENOWN_LEVEL_CHANGED", "RenownSoundSelect", "RenownVolume", defaultSounds[6])
end

function BLU:HandlePetBattleLevelChanged()
    HandleEvent(self, "PET_BATTLE_LEVEL_CHANGED", "BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds[2])
end

function BLU:HandlePerksActivityCompleted(_, activityID)
    HandleEvent(self, "PERKS_ACTIVITY_COMPLETED", "PostSoundSelect", "PostVolume", defaultSounds[9])

    -- Retrieve the name of the completed activity and display in chat
    local activityName = C_PerksActivities.GetActivityInfo(activityID)
    if activityName then
        self:Print(L["PERKS_ACTIVITY_COMPLETED_MESSAGE"]:format(activityName))
    else
        self:Print(L["PERKS_ACTIVITY_COMPLETED_ERROR"])
    end
end

--=====================================================================================
-- Reputation ChatFrame Hook
--=====================================================================================
function BLU:ReputationChatFrameHook()
    if self.chatFrameHooked then return end

    local rankPatterns = {
        Exalted = L["RANK_EXALTED"],
        Revered = L["RANK_REVERED"],
        Honored = L["RANK_HONORED"],
        Friendly = L["RANK_FRIENDLY"],
        Neutral = L["RANK_NEUTRAL"],
        Unfriendly = L["RANK_UNFRIENDLY"],
        Hostile = L["RANK_HOSTILE"],
        Hated = L["RANK_HATED"]
    }

    ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", function(_, _, msg)
        self:PrintDebugMessage(L["INCOMING_CHAT_MESSAGE"]:format(msg))
        local currentTime = GetTime()

        for rank, pattern in pairs(rankPatterns) do
            if string.match(msg, pattern) then
                local lastTriggered = triggeredReputationRanks[rank]
                
                if not lastTriggered or (currentTime - lastTriggered >= reputationCooldown) then
                    self:PrintDebugMessage(L["RANK_FOUND"]:format(rank))
                    self:ReputationRankIncrease(rank)
                    triggeredReputationRanks[rank] = currentTime
                else
                    self:PrintDebugMessage(L["COOLDOWN_ACTIVE"]:format(rank))
                end
                
                return false
            end
        end
        
        self:PrintDebugMessage(L["NO_RANK_FOUND"])
        return false
    end)

    self.chatFrameHooked = true
end

function BLU:ReputationRankIncrease(rank)
    HandleEvent(self, "REPUTATION_RANK_INCREASE", "RepSoundSelect", "RepVolume", defaultSounds[6])
end

--=====================================================================================
-- Delve Level-Up Detection
--=====================================================================================
function BLU:DelveLevelUpChatFrameHook()
    if self.delveChatFrameHooked then return end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, msg)
        self:PrintDebugMessage(L["INCOMING_CHAT_MESSAGE"]:format(msg))
        local level = string.match(msg, L["DELVESYSTEM_MESSAGE_PATTERN"])
        if level then
            self:PrintDebugMessage(L["BRANN_LEVEL_FOUND"]:format(level))
            self:DelveLevelUpDetected(level)
        else
            self:PrintDebugMessage(L["NO_BRANN_LEVEL_FOUND"])
        end
        return false
    end)

    self.delveChatFrameHooked = true
end

function BLU:DelveLevelUpDetected(level)
    HandleEvent(self, "DELVE_LEVEL_UP_DETECTED", "DelveLevelUpSoundSelect", "DelveLevelUpVolume", defaultSounds[6])
end

--=====================================================================================
-- Test Sound Functions
--=====================================================================================
local function TestSound(self, soundID, volumeKey, defaultSound, debugMessage)
    self:PrintDebugMessage(debugMessage)
    local sound = self:SelectSound(self.db.profile[soundID])
    if not sound then
        self:PrintDebugMessage(L["ERROR_SOUND_NOT_FOUND"])
        return
    end
    self:PlaySelectedSound(sound, self.db.profile[volumeKey], defaultSound)
end

function BLU:TestAchievementSound()
    TestSound(self, "AchievementSoundSelect", "AchievementVolume", defaultSounds[1], "TEST_ACHIEVEMENT_SOUND")
end

function BLU:TestBattlePetLevelSound()
    TestSound(self, "BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds[2], "TEST_BATTLE_PET_LEVEL_SOUND")
end

function BLU:TestDelveLevelUpSound()
    TestSound(self, "DelveLevelUpSoundSelect", "DelveLevelUpVolume", defaultSounds[3], "TEST_DELVESOUND")
end

function BLU:TestHonorSound()
    TestSound(self, "HonorSoundSelect", "HonorVolume", defaultSounds[5], "TEST_HONOR_SOUND")
end

function BLU:TestLevelSound()
    TestSound(self, "LevelSoundSelect", "LevelVolume", defaultSounds[4], "TEST_LEVEL_SOUND")
end

function BLU:TestPostSound()
    TestSound(self, "PostSoundSelect", "PostVolume", defaultSounds[9], "TEST_POST_SOUND")
end

function BLU:TestQuestAcceptSound()
    TestSound(self, "QuestAcceptSoundSelect", "QuestAcceptVolume", defaultSounds[7], "TEST_QUEST_ACCEPT_SOUND")
end

function BLU:TestQuestSound()
    TestSound(self, "QuestSoundSelect", "QuestVolume", defaultSounds[8], "TEST_QUEST_SOUND")
end

function BLU:TestRenownSound()
    TestSound(self, "RenownSoundSelect", "RenownVolume", defaultSounds[6], "TEST_RENOWN_SOUND")
end

function BLU:TestRepSound()
    TestSound(self, "RepSoundSelect", "RepVolume", defaultSounds[6], "TEST_REP_SOUND")
end
