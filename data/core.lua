--=====================================================================================
-- BLU | Better Level Up! - core.lua
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
            { rank = "Exalted", pattern = L["RANK_EXALTED"] },
            { rank = "Revered", pattern = L["RANK_REVERED"] },
            { rank = "Honored", pattern = L["RANK_HONORED"] },
            { rank = "Friendly", pattern = L["RANK_FRIENDLY"] },
            { rank = "Neutral", pattern = L["RANK_NEUTRAL"] },
            { rank = "Unfriendly", pattern = L["RANK_UNFRIENDLY"] },
            { rank = "Hostile", pattern = L["RANK_HOSTILE"] },
            { rank = "Hated", pattern = L["RANK_HATED"] }
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
-- Test Sound Functions with Detailed Debug Output
--=====================================================================================
local function TestSound(self, soundID, volumeKey, defaultSound, debugMessage, functionName)
    -- Output to chat the function name being used
    self:PrintDebugMessage("Function used: " .. functionName)

    -- Print the debug message for the test being triggered
    self:PrintDebugMessage(L[debugMessage])

    -- Select the sound based on sound ID
    local sound = self:SelectSound(self.db.profile[soundID])
    if not sound then
        self:PrintDebugMessage(L["ERROR_SOUND_NOT_FOUND"] .. " Default sound will be used.")
    end

    -- Play the selected sound
    local volumeLevel = self.db.profile[volumeKey]
    self:PlaySelectedSound(sound, volumeLevel, defaultSound)
end

--=====================================================================================
-- Test Sound Trigger Functions
--=====================================================================================
function BLU:TestAchievementSound()
    self:PrintDebugMessage("TEST_ACHIEVEMENT_SOUND")
    TestSound(self, "AchievementSoundSelect", "AchievementVolume", defaultSounds[1], "TEST_ACHIEVEMENT_SOUND", "TestAchievementSound")
end

function BLU:TestBattlePetLevelSound()
    self:PrintDebugMessage("TEST_BATTLE_PET_LEVEL_SOUND")
    TestSound(self, "BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds[2], "TEST_BATTLE_PET_LEVEL_SOUND", "TestBattlePetLevelSound")
end

function BLU:TestDelveLevelUpSound()
    self:PrintDebugMessage("TEST_DELVE_LEVEL_UP_SOUND")
    TestSound(self, "DelveLevelUpSoundSelect", "DelveLevelUpVolume", defaultSounds[3], "TEST_DELVESOUND", "TestDelveLevelUpSound")
end

function BLU:TestHonorSound()
    self:PrintDebugMessage("TEST_HONOR_SOUND")
    TestSound(self, "HonorSoundSelect", "HonorVolume", defaultSounds[5], "TEST_HONOR_SOUND", "TestHonorSound")
end

function BLU:TestLevelSound()
    self:PrintDebugMessage("TEST_LEVEL_SOUND")
    TestSound(self, "LevelSoundSelect", "LevelVolume", defaultSounds[4], "TEST_LEVEL_SOUND", "TestLevelSound")
end

function BLU:TestPostSound()
    self:PrintDebugMessage("TEST_POST_SOUND")
    TestSound(self, "PostSoundSelect", "PostVolume", defaultSounds[9], "TEST_POST_SOUND", "TestPostSound")
end

function BLU:TestQuestAcceptSound()
    self:PrintDebugMessage("TEST_QUEST_ACCEPT_SOUND")
    TestSound(self, "QuestAcceptSoundSelect", "QuestAcceptVolume", defaultSounds[7], "TEST_QUEST_ACCEPT_SOUND", "TestQuestAcceptSound")
end

function BLU:TestQuestSound()
    self:PrintDebugMessage("TEST_QUEST_SOUND")
    TestSound(self, "QuestSoundSelect", "QuestVolume", defaultSounds[8], "TEST_QUEST_SOUND", "TestQuestSound")
end

function BLU:TestRenownSound()
    self:PrintDebugMessage("TEST_RENOWN_SOUND")
    TestSound(self, "RenownSoundSelect", "RenownVolume", defaultSounds[6], "TEST_RENOWN_SOUND", "TestRenownSound")
end

function BLU:TestRepSound()
    self:PrintDebugMessage("TEST_REP_SOUND")
    TestSound(self, "RepSoundSelect", "RepVolume", defaultSounds[6], "TEST_REP_SOUND", "TestRepSound")
end