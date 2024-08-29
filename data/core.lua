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

function BLU:HandlePerksActivityCompleted(_, activityID)
    self:PrintDebugMessage("PERKS_ACTIVITY_COMPLETED_TRIGGERED")
    self:HandleEvent("PERKS_ACTIVITY_COMPLETED", "PostSoundSelect", "PostVolume", defaultSounds[9])

    -- Retrieve the activity info table
    local activityInfo = C_PerksActivities.GetActivityInfo(activityID)

    -- Check if the activity info and name are valid
    if activityInfo and activityInfo.activityName then
        self:PrintDebugMessage(L["PERKS_ACTIVITY_COMPLETED_MSG"]:format(activityID))
        print(BLU_PREFIX .. L["PERKS_ACTIVITY_COMPLETED_MSG"]:format(activityInfo.activityName))
    else
        self:PrintDebugMessage(L["PERKS_ACTIVITY_ERROR"]:format(activityID))
    end
end

--=====================================================================================
-- Reputation Event Handler
--=====================================================================================
function BLU:ReputationChatFrameHook()
    if BLU.chatFrameHooked then 
        self:PrintDebugMessage(L["CHAT_FRAME_ALREADY_HOOKED"])
        return 
    end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", function(_, _, msg)
        BLU:PrintDebugMessage(L["INCOMING_CHAT_MESSAGE"]:format(msg))

        local ranks = {
            { rank = "Exalted", pattern = L["RANK_EXALTED"] },
            { rank = "Revered", pattern = L["RANK_REVERED"] },
            { rank = "Honored", pattern = L["RANK_HONORED"] },
            { rank = "Friendly", pattern = L["RANK_FRIENDLY"] },
            { rank = "Neutral", pattern = L["RANK_NEUTRAL"] },
            { rank = "Unfriendly", pattern = L["RANK_UNFRIENDLY"] },
            { rank = "Hostile", pattern = L["RANK_HOSTILE"] },
            { rank = "Hated", pattern = L["RANK_HATED"] }
        }

        local rankFound = false
        for _, v in ipairs(ranks) do
            if string.match(msg, v.pattern) then
                BLU:PrintDebugMessage(L["RANK_FOUND"]:format(v.rank))
                BLU:ReputationRankIncrease(v.rank)
                rankFound = true
                break
            end
        end

        if not rankFound then
            local faction, amount = string.match(msg, "Reputation with (.+) increased by (%d+)")
            if faction and amount then
                BLU:PrintDebugMessage(L["REPUTATION_GAINED_TRIGGERED"]:format(faction, amount))
            else
                BLU:PrintDebugMessage(L["NO_RANK_OR_REP_GAIN_FOUND"])
            end
        end

        return false
    end)

    BLU.chatFrameHooked = true
    self:PrintDebugMessage(L["CHAT_FRAME_HOOK_SUCCESS"])
end

--=====================================================================================
-- Handle Reputation Rank Increase
--=====================================================================================
function BLU:ReputationRankIncrease(rank)
    if BLU.functionsHalted then 
        self:PrintDebugMessage(L["FUNCTIONS_HALTED"])
        return 
    end

    self:PrintDebugMessage(L["REPUTATION_RANK_INCREASE"]:format(rank))
    local sound = self:SelectSound(self.db.profile.RepSoundSelect)
    if not sound then
        self:PrintDebugMessage(L["ERROR_SOUND_NOT_FOUND"])
        return
    end
    local volumeLevel = self.db.profile.RepVolume
    self:PlaySelectedSound(sound, volumeLevel, defaultSounds[6])
end

--=====================================================================================
-- Delve Level-Up Event Handler
--=====================================================================================
function BLU:DelveLevelUpChatFrameHook()
    if BLU.delveChatFrameHooked then
        self:PrintDebugMessage(L["CHAT_FRAME_ALREADY_HOOKED"])
        return
    end

    ChatFrame_AddMessageEventFilter("UPDATE_FACTION", function(_, _, msg)
        BLU:PrintDebugMessage(L["INCOMING_CHAT_MESSAGE"]:format(msg))

        local level = string.match(msg, "Brann Bronzebeard has reached Level (%d+)%p?")
        if level and tonumber(level) >= 1 and tonumber(level) <= 999 then
            BLU:PrintDebugMessage(L["DELVE_LEVEL_FOUND"]:format(level))
            BLU:HandleDelveLevelUp(level)
        else
            BLU:PrintDebugMessage(L["NO_DELVESOUND_FOUND"])
        end

        return false
    end)

    BLU.delveChatFrameHooked = true
    self:PrintDebugMessage(L["CHAT_FRAME_HOOK_SUCCESS"])
end

--=====================================================================================
-- Handle Delve Level-Up Detection
--=====================================================================================
function BLU:HandleDelveLevelUp(level)
    if BLU.functionsHalted then
        self:PrintDebugMessage(L["FUNCTIONS_HALTED"])
        return
    end

    self:PrintDebugMessage(L["DELVESOUND_LEVEL_UP"]:format(level))
    local sound = self:SelectSound(self.db.profile.DelveLevelUpSoundSelect)
    if not sound then
        self:PrintDebugMessage(L["ERROR_SOUND_NOT_FOUND"])
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
