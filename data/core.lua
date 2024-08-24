-- core.lua
--=====================================================================================
-- Sound Selection Functions
--=====================================================================================
function BLU:RandomSoundID()
    self:PrintDebugMessage("SELECTING_RANDOM_SOUND_ID")

    local validSoundIDs = {}

    -- Collect all custom sound IDs
    for soundID, soundList in pairs(sounds) do
        for _, _ in pairs(soundList) do
            table.insert(validSoundIDs, {table = sounds, id = soundID})
        end
    end
    self:PrintDebugMessage("QUEST_TURNED_IN")
    local sound = SelectSound(self.db.profile["QuestSoundSelect"])
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND")
        return
    end
    local volumeLevel = self.db.profile["QuestVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[8])
end

function BLU:HandleRenownLevelChanged()
    if functionsHalted then
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return
    end
    self:PrintDebugMessage("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
    local sound = SelectSound(self.db.profile["RenownSoundSelect"])
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND")
        return
    end
    local volumeLevel = self.db.profile["RenownVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[5])
end

function BLU:SelectSound(soundID)
    self:PrintDebugMessage("SELECTING_SOUND", tostring(soundID))

    -- If the sound ID is not provided or is set to random (2), return a random sound ID
    if not soundID or soundID == 2 then
        local randomSoundID = self:RandomSoundID()
        if randomSoundID then
            self:PrintDebugMessage("USING_RANDOM_SOUND_ID", randomSoundID.id)
            return randomSoundID
        end
    end
    self:PrintDebugMessage("PERKS_ACTIVITY_COMPLETED")
    local sound = SelectSound(self.db.profile["PostSoundSelect"])
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND")
        return
    end
    local volumeLevel = self.db.profile["PostVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[9])
end

function BLU:PlaySelectedSound(sound, volumeLevel, defaultTable)
    self:PrintDebugMessage("PLAYING_SOUND", sound.id, volumeLevel)

    -- Do not play the sound if the volume level is set to 0
    if volumeLevel == 0 then
        self:PrintDebugMessage("VOLUME_LEVEL_ZERO")
        return
    end

    -- Determine the sound file to play based on the sound ID and volume level
    local soundFile
    if sound and sound.table and sound.id then
        soundFile = sound.table[sound.id][volumeLevel]
    elseif defaultTable then
        soundFile = defaultTable[volumeLevel]
    end

    self:PrintDebugMessage("SOUND_FILE_TO_PLAY", tostring(soundFile))

    -- Play the sound file using the "MASTER" sound channel
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    else
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND", sound.id)
    end
    local volumeLevel = self.db.profile["BattlePetLevelVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[2])
end

--=====================================================================================
-- Event Handlers
--=====================================================================================
function BLU:HandlePlayerLevelUp()
    if self.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return
    end
    self:PrintDebugMessage("ACHIEVEMENT_EARNED")
    local sound = SelectSound(self.db.profile["AchievementSoundSelect"])
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND")
        return
    end
    local volumeLevel = self.db.profile["AchievementVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[1])
end

function BLU:HandleQuestAccepted()
    if self.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return
    end
    self:PrintDebugMessage("REPUTATION_RANK_INCREASE", rank)
    local sound = SelectSound(self.db.profile.RepSoundSelect)
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND")
        return
    end
    local volumeLevel = self.db.profile.RepVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[6])
end

function BLU:HandleQuestTurnedIn()
    if self.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
end

function BLU:HandleAchievementEarned()
    if self.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("ACHIEVEMENT_EARNED")
    local sound = self:SelectSound(self.db.profile["AchievementSoundSelect"])
    self:PlaySelectedSound(sound, self.db.profile["AchievementVolume"], defaultSounds[1])
end

function BLU:HandleHonorLevelUpdate()
    if self.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("HONOR_LEVEL_UPDATE")
    local sound = self:SelectSound(self.db.profile["HonorSoundSelect"])
    self:PlaySelectedSound(sound, self.db.profile["HonorVolume"], defaultSounds[5])
end

function BLU:HandleRenownLevelChanged()
    if self.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
    local sound = self:SelectSound(self.db.profile["RenownSoundSelect"])
    self:PlaySelectedSound(sound, self.db.profile["RenownVolume"], defaultSounds[6])
end

function BLU:HandlePetBattleLevelChanged()
    if self.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("PET_BATTLE_LEVEL_CHANGED")
    local sound = self:SelectSound(self.db.profile["BattlePetLevelSoundSelect"])
    self:PlaySelectedSound(sound, self.db.profile["BattlePetLevelVolume"], defaultSounds[2])
end

function BLU:HandlePerksActivityCompleted()
    if self.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("PERKS_ACTIVITY_COMPLETED")
    local sound = self:SelectSound(self.db.profile["PostSoundSelect"])
    self:PlaySelectedSound(sound, self.db.profile["PostVolume"], defaultSounds[9])
end

--=====================================================================================
-- ChatFrame Hooks
--=====================================================================================
function BLU:ReputationChatFrameHook()
    -- Ensure this hook is only added once
    if self.chatFrameHooked then return end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", function(_, _, msg)
        self:DebugMessage("|cffffff00Incoming chat message:|r " .. msg)
        local rankFound = false
        if string.match(msg, "You are now Exalted with") or string.match(msg, "Your Warband is now Exalted with") then
            self:DebugMessage("|cff00ff00Rank found: Exalted|r")
            self:ReputationRankIncrease("Exalted")
            rankFound = true
        elseif string.match(msg, "You are now Revered with") or string.match(msg, "Your Warband is now Revered with") then
            self:DebugMessage("|cff00ff00Rank found: Revered|r")
            self:ReputationRankIncrease("Revered")
            rankFound = true
        elseif string.match(msg, "You are now Honored with") or string.match(msg, "Your Warband is now Honored with") then
            self:DebugMessage("|cff00ff00Rank found: Honored|r")
            self:ReputationRankIncrease("Honored")
            rankFound = true
        elseif string.match(msg, "You are now Friendly with") or string.match(msg, "Your Warband is now Friendly with") then
            self:DebugMessage("|cff00ff00Rank found: Friendly|r")
            self:ReputationRankIncrease("Friendly")
            rankFound = true
        elseif string.match(msg, "You are now Neutral with") or string.match(msg, "Your Warband is now Neutral with") then
            self:DebugMessage("|cff00ff00Rank found: Neutral|r")
            self:ReputationRankIncrease("Neutral")
            rankFound = true
        elseif string.match(msg, "You are now Unfriendly with") or string.match(msg, "Your Warband is now Unfriendly with") then
            self:DebugMessage("|cff00ff00Rank found: Unfriendly|r")
            self:ReputationRankIncrease("Unfriendly")
            rankFound = true
        elseif string.match(msg, "You are now Hostile with") or string.match(msg, "Your Warband is now Hostile with") then
            self:DebugMessage("|cff00ff00Rank found: Hostile|r")
            self:ReputationRankIncrease("Hostile")
            rankFound = true
        elseif string.match(msg, "You are now Hated with") or string.match(msg, "Your Warband is now Hated with") then
            self:DebugMessage("|cff00ff00Rank found: Hated|r")
            self:ReputationRankIncrease("Hated")
            rankFound = true
        end

        if not rankFound then
            self:PrintDebugMessage("NO_RANK_FOUND")
        end

        return false
    end)

    self.chatFrameHooked = true
end

function BLU:ReputationRankIncrease(rank)
    if self.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("REPUTATION_RANK_INCREASE", rank)
    local sound = self:SelectSound(self.db.profile.RepSoundSelect)
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND")
        return
    end
    local volumeLevel = self.db.profile.RepVolume
    self:PlaySelectedSound(sound, volumeLevel, defaultSounds[6])
end

--=====================================================================================
-- Test Sound Functions
--=====================================================================================
function BLU:TestAchievementSound()
    self:PrintDebugMessage("TEST_ACHIEVEMENT_SOUND")
    local sound = self:SelectSound(self.db.profile.AchievementSoundSelect)
    self:PlaySelectedSound(sound, self.db.profile.AchievementVolume, defaultSounds[1])
end

function BLU:TestBattlePetLevelSound()
    self:PrintDebugMessage("TEST_BATTLE_PET_LEVEL_SOUND")
    local sound = self:SelectSound(self.db.profile.BattlePetLevelSoundSelect)
    self:PlaySelectedSound(sound, self.db.profile.BattlePetLevelVolume, defaultSounds[2])
end

function BLU:TestDelveLevelUpSound()
    self:PrintDebugMessage("TEST_DELVESOUND")
    local sound = self:SelectSound(self.db.profile.DelveLevelUpSoundSelect)
    self:PlaySelectedSound(sound, self.db.profile.DelveLevelUpVolume, defaultSounds[3])
end

function BLU:TestHonorSound()
    self:PrintDebugMessage("TEST_HONOR_SOUND")
    local sound = self:SelectSound(self.db.profile.HonorSoundSelect)
    self:PlaySelectedSound(sound, self.db.profile.HonorVolume, defaultSounds[5])
end

function BLU:TestLevelSound()
    self:PrintDebugMessage("TEST_LEVEL_SOUND")
    local sound = self:SelectSound(self.db.profile.LevelSoundSelect)
    self:PlaySelectedSound(sound, self.db.profile.LevelVolume, defaultSounds[4])
end

function BLU:TestPostSound()
    self:PrintDebugMessage("TEST_POST_SOUND")
    local sound = self:SelectSound(self.db.profile.PostSoundSelect)
    self:PlaySelectedSound(sound, self.db.profile.PostVolume, defaultSounds[9])
end

function BLU:TestQuestAcceptSound()
    self:PrintDebugMessage("TEST_QUEST_ACCEPT_SOUND")
    local sound = self:SelectSound(self.db.profile.QuestAcceptSoundSelect)
    self:PlaySelectedSound(sound, self.db.profile.QuestAcceptVolume, defaultSounds[7])
end

function BLU:TestQuestSound()
    self:PrintDebugMessage("TEST_QUEST_SOUND")
    local sound = self:SelectSound(self.db.profile.QuestSoundSelect)
    self:PlaySelectedSound(sound, self.db.profile.QuestVolume, defaultSounds[8])
end

function BLU:TestRenownSound()
    self:PrintDebugMessage("TEST_RENOWN_SOUND")
    local sound = self:SelectSound(self.db.profile.RenownSoundSelect)
    self:PlaySelectedSound(sound, self.db.profile.RenownVolume, defaultSounds[6])
end

function BLU:TestRepSound()
    self:PrintDebugMessage("TEST_REP_SOUND")
    local sound = self:SelectSound(self.db.profile.RepSoundSelect)
    self:PlaySelectedSound(sound, self.db.profile.RepVolume, defaultSounds[6])
end

--=====================================================================================
-- Utility Functions
--=====================================================================================
function BLU:MuteSounds()
    -- Placeholder for muting sound logic if needed
end

function BLU:DisplayWelcomeMessage()
    -- Display the welcome message in the chat window
    print(BLU_PREFIX .. L["WELCOME_MESSAGE"])
    self:PrintDebugMessage("WELCOME_MESSAGE_DISPLAYED")
end
