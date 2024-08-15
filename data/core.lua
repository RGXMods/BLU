--=====================================================================================
-- Event Handlers
--=====================================================================================

function BLU:HandlePlayerLevelUp()
    if functionsHalted then
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return
    end
    self:PrintDebugMessage("PLAYER_LEVEL_UP")
    local sound = SelectSound(self.db.profile["LevelSoundSelect"])
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND")
        return
    end
    local volumeLevel = self.db.profile["LevelVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[4])
end

function BLU:HandleQuestAccepted()
    if functionsHalted then
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return
    end
    self:PrintDebugMessage("QUEST_ACCEPTED")
    local sound = SelectSound(self.db.profile["QuestAcceptSoundSelect"])
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND")
        return
    end
    local volumeLevel = self.db.profile["QuestAcceptVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[7])
end

function BLU:HandleQuestTurnedIn()
    if functionsHalted then
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return
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

function BLU:HandlePerksActivityCompleted()
    if functionsHalted then
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return
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

function BLU:HandlePetBattleLevelChanged()
    if functionsHalted then
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return
    end
    self:PrintDebugMessage("PET_BATTLE_LEVEL_CHANGED")
    local sound = SelectSound(self.db.profile["BattlePetLevelSoundSelect"])
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND")
        return
    end
    local volumeLevel = self.db.profile["BattlePetLevelVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[2])
end

function BLU:HandleHonorLevelUpdate()
    if functionsHalted then
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return
    end
    self:PrintDebugMessage("HONOR_LEVEL_UPDATE")
    local sound = SelectSound(self.db.profile["HonorSoundSelect"])
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND")
        return
    end
    local volumeLevel = self.db.profile["HonorVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[3])
end

function BLU:HandleAchievementEarned()
    if functionsHalted then
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

function BLU:ReputationRankIncrease(rank)
    if functionsHalted then
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

function BLU:ReputationChatFrameHook()
    if not chatFrameHooked then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", function(_, _, msg)
            BLU:PrintDebugMessage("REPUTATION_CHAT_FRAME_HOOKED")

            local rankFound = false
            if string.match(msg, "You are now Exalted with") then
                BLU:PrintDebugMessage("RANK_FOUND_EXALTED")
                BLU:ReputationRankIncrease("Exalted")
                rankFound = true
            elseif string.match(msg, "You are now Revered with") then
                BLU:PrintDebugMessage("RANK_FOUND_REVERED")
                BLU:ReputationRankIncrease("Revered")
                rankFound = true
            elseif string.match(msg, "You are now Honored with") then
                BLU:PrintDebugMessage("RANK_FOUND_HONORED")
                BLU:ReputationRankIncrease("Honored")
                rankFound = true
            elseif string.match(msg, "You are now Friendly with") then
                BLU:PrintDebugMessage("RANK_FOUND_FRIENDLY")
                BLU:ReputationRankIncrease("Friendly")
                rankFound = true
            elseif string.match(msg, "You are now Neutral with") then
                BLU:PrintDebugMessage("RANK_FOUND_NEUTRAL")
                BLU:ReputationRankIncrease("Neutral")
                rankFound = true
            elseif string.match(msg, "You are now Unfriendly with") then
                BLU:PrintDebugMessage("RANK_FOUND_UNFRIENDLY")
                BLU:ReputationRankIncrease("Unfriendly")
                rankFound = true
            elseif string.match(msg, "You are now Hostile with") then
                BLU:PrintDebugMessage("RANK_FOUND_HOSTILE")
                BLU:ReputationRankIncrease("Hostile")
                rankFound = true
            elseif string.match(msg, "You are now Hated with") then
                BLU:PrintDebugMessage("RANK_FOUND_HATED")
                BLU:ReputationRankIncrease("Hated")
                rankFound = true
            end

            if not rankFound then
                BLU:PrintDebugMessage("NO_RANK_FOUND")
            end

            return false
        end)
        chatFrameHooked = true
    end
end

--=====================================================================================
-- Slash Command
--=====================================================================================
function BLU:SlashCommand(input)
    if input == "debug" then
        self:ToggleDebugMode()
    elseif input == "enable" then
        self:Enable()
        print(BLU_PREFIX .. self:PrintDebugMessage("ADDON_ENABLED"))
    elseif input == "disable" then
        self:Disable()
        print(BLU_PREFIX .. self:PrintDebugMessage("ADDON_DISABLED"))
    else
        Settings.OpenToCategory(self.optionsFrame.name)
        if debugMode then
            self:PrintDebugMessage("OPTIONS_PANEL_OPENED")
        end
    end
end

-- Register the Slash Command
SLASH_BLUDEBUG1 = "/blu"
SlashCmdList["BLUDEBUG"] = function(msg)
    BLU:SlashCommand(msg)
end
