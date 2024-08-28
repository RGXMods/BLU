--=====================================================================================
-- BLU | Better Level Up!
--=====================================================================================

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
    HandleEvent(self, "QUEST_TURN_IN", "QuestSoundSelect", "QuestVolume", defaultSounds[8])
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

    -- Retrieve the name of the completed activity and display it in chat
    local activityName = C_PerksActivities.GetActivityInfo(activityID)
    if activityName then
        print(BLU_PREFIX .. L["PERKS_ACTIVITY_COMPLETED_MSG"]:format(activityName))
    else
        print(BLU_PREFIX .. L["PERKS_ACTIVITY_ERROR"])
    end
end

--=====================================================================================
-- Reputation Event Handler
--=====================================================================================
function BLU:ReputationChatFrameHook()
    -- Ensure this hook is only added once
    if BLU.chatFrameHooked then 
        self:PrintDebugMessage("CHAT_FRAME_ALREADY_HOOKED")
        return 
    end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", function(_, _, msg)
        BLU:PrintDebugMessage("INCOMING_CHAT_MESSAGE: " .. msg)

        local rankFound = false
        local ranks = {
            { rank = "Exalted", pattern = "You are now Exalted with" },
            { rank = "Revered", pattern = "You are now Revered with" },
            { rank = "Honored", pattern = "You are now Honored with" },
            { rank = "Friendly", pattern = "You are now Friendly with" },
            { rank = "Neutral", pattern = "You are now Neutral with" },
            { rank = "Unfriendly", pattern = "You are now Unfriendly with" },
            { rank = "Hostile", pattern = "You are now Hostile with" },
            { rank = "Hated", pattern = "You are now Hated with" }
        }

        -- Check for reputation rank changes
        for _, v in ipairs(ranks) do
            if string.match(msg, v.pattern) then
                BLU:DebugMessage("|cff00ff00Rank found: " .. v.rank .. "|r")
                BLU:ReputationRankIncrease(v.rank)
                rankFound = true
                break
            end
        end

        -- Check for general reputation gains
        if not rankFound then
            local faction, amount = string.match(msg, "Reputation with (.+) increased by (%d+)")
            if faction and amount then
                BLU:DebugMessage("|cff00ff00Reputation gained with " .. faction .. ": " .. amount .. "|r")
                -- You could add more logic here if you want to do something on every reputation gain
            else
                BLU:PrintDebugMessage("NO_RANK_OR_REP_GAIN_FOUND")
            end
        end

        return false
    end)

    BLU.chatFrameHooked = true
    self:PrintDebugMessage("CHAT_FRAME_HOOK_SUCCESS")
end


--=====================================================================================
-- Handle Reputation Rank Increase
--=====================================================================================
function BLU:ReputationRankIncrease(rank)
    self:PrintDebugMessage("REPUTATION_RANK_INCREASE_FUNCTION_CALLED")

    if BLU.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end

    self:PrintDebugMessage("REPUTATION_RANK_INCREASE: " .. rank)
    local sound = self:SelectSound(self.db.profile.RepSoundSelect)
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND")
        return
    end
    local volumeLevel = self.db.profile.RepVolume
    self:PlaySelectedSound(sound, volumeLevel, defaultSounds[6])
end

--=====================================================================================
-- Delve Level-Up Event Handler
--=====================================================================================
function BLU:DelveLevelUpChatFrameHook()
    -- Ensure this hook is only added once
    if BLU.delveChatFrameHooked then
        self:PrintDebugMessage("CHAT_FRAME_ALREADY_HOOKED")
        return
    end

    ChatFrame_AddMessageEventFilter("UPDATE_FACTION", function(_, _, msg)
        BLU:PrintDebugMessage("INCOMING_CHAT_MESSAGE: " .. msg)

        -- Match any level between 1 and 999
        local level = string.match(msg, "Brann Bronzebeard has reached Level (%d+)%p?")
        if level and tonumber(level) >= 1 and tonumber(level) <= 999 then
            BLU:DebugMessage("|cff00ff00Delve Level found: " .. level .. "|r")
            BLU:HandleDelveLevelUp(level)
        else
            BLU:PrintDebugMessage("NO_DELVESOUND_FOUND")
        end

        return false
    end)

    BLU.delveChatFrameHooked = true
    self:PrintDebugMessage("CHAT_FRAME_HOOK_SUCCESS")
end

--=====================================================================================
-- Handle Delve Level-Up Detection
--=====================================================================================
function BLU:HandleDelveLevelUp(level)
    self:PrintDebugMessage("DELVESOUND_FUNCTION_CALLED")

    if BLU.functionsHalted then
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return
    end

    self:PrintDebugMessage("DELVESOUND_LEVEL_UP: " .. level)
    local sound = self:SelectSound(self.db.profile.DelveLevelUpSoundSelect)
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND")
        return
    end
    local volumeLevel = self.db.profile.DelveLevelUpVolume
    self:PlaySelectedSound(sound, volumeLevel, defaultSounds[3])
end


--=====================================================================================
-- Test Sound Functions
--=====================================================================================
local function TestSound(self, soundID, volumeKey, defaultSound, debugMessage)
    self:PrintDebugMessage(L[debugMessage])
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
