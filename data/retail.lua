--=====================================================================================
-- BLU | Better Level Up! - retail.lua
--=====================================================================================

--=====================================================================================
-- Sound Selection Functions
--=====================================================================================
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

    -- Otherwise, return the specified sound ID
    self:PrintDebugMessage("USING_SPECIFIED_SOUND_ID", soundID)
    return {table = sounds, id = soundID}
end

function BLU:PlaySelectedSound(sound, volumeLevel, defaultTable)
    self:PrintDebugMessage("PLAYING_SOUND", sound.id, volumeLevel)

    -- Do not play the sound if the volume level is set to 0
    if volumeLevel == 0 then
        self:PrintDebugMessage("VOLUME_LEVEL_ZERO")
        return
    end

    -- Determine the sound file to play based on the sound ID and volume level
    local soundFile = sound.id == 1 and defaultTable[volumeLevel] or sound.table[sound.id][volumeLevel]

    self:PrintDebugMessage("SOUND_FILE_TO_PLAY", tostring(soundFile))

    -- Play the sound file using the "MASTER" sound channel
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    else
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND", sound.id)
    end
end

--=====================================================================================
-- Event Registration
--=====================================================================================
function BLU:OnEnable()
    self:PrintDebugMessage("ENABLING_ADDON")
    self:RegisterSharedEvents()
    self:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", "HandleRenownLevelChanged")
    self:RegisterEvent("PERKS_ACTIVITY_COMPLETED", "HandlePerksActivityCompleted")
    self:RegisterEvent("PET_BATTLE_LEVEL_CHANGED", "HandlePetBattleLevelChanged")
    self:RegisterEvent("ACHIEVEMENT_EARNED", "HandleAchievementEarned")
    self:RegisterEvent("HONOR_LEVEL_UPDATE", "HandleHonorLevelUpdate")
    self:RegisterEvent("UPDATE_FACTION", "HandleUpdateFaction")
end

--=====================================================================================
-- Event Handlers for Retail-specific Events
--=====================================================================================
function BLU:HandleUpdateFaction()
    self:DelveLevelUpChatFrameHook()
end

function BLU:HandleRenownLevelChanged()
    if self.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
    local sound = self:SelectSound(self.db.profile["RenownSoundSelect"])
    self:PlaySelectedSound(sound, self.db.profile["RenownVolume"], defaultSounds[5])
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

function BLU:HandlePetBattleLevelChanged()
    if self.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("PET_BATTLE_LEVEL_CHANGED")
    local sound = self:SelectSound(self.db.profile["BattlePetLevelSoundSelect"])
    self:PlaySelectedSound(sound, self.db.profile["BattlePetLevelVolume"], defaultSounds[2])
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
    self:PlaySelectedSound(sound, self.db.profile["HonorVolume"], defaultSounds[3])
end

--=====================================================================================
-- ChatFrame Hooks for Delve Level-Up Detection
--=====================================================================================
function BLU:DelveLevelUpChatFrameHook()
    if self.delveChatFrameHooked then return end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, msg)
        self:PrintDebugMessage("Incoming chat message: " .. msg)
        local level = string.match(msg, "Brann Bronzebeard has reached Level (%d+)%p?")
        if level then
            self:PrintDebugMessage("Brann Bronzebeard has reached Level " .. level)
            self:DelveLevelUpDetected(level)
        else
            self:PrintDebugMessage("No Delve Level found in chat message.")
        end
        return false
    end)

    self.delveChatFrameHooked = true
end

--=====================================================================================
-- Handle Delve Level-Up Detection
--=====================================================================================
function BLU:DelveLevelUpDetected(level)
    if self.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("DELVE_LEVEL_UP_DETECTED", level)
    local sound = self:SelectSound(self.db.profile.DelveLevelUpSoundSelect)
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND")
        return
    end
    self:PlaySelectedSound(sound, self.db.profile.DelveLevelUpVolume, defaultSounds[6])
end

--=====================================================================================
-- Retail-specific Mute Sounds Function
--=====================================================================================
function BLU:MuteSounds()
    for _, soundID in ipairs(muteSoundIDs) do
        self:PrintDebugMessage("MUTE_SOUND", soundID)
        MuteSoundFile(soundID)
    end
end
