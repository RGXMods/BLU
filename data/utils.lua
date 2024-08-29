--=====================================================================================
-- BLU | Better Level Up! - utils.lua
--=====================================================================================

--=====================================================================================
-- Utility Functions
--=====================================================================================

function BLU:HandleEvent(eventName, soundSelectKey, volumeKey, defaultSound)
    -- Log the event name being handled
    self:PrintDebugMessage("EVENT_TRIGGERED", eventName)

    -- Select and play the appropriate sound
    local sound = self:SelectSound(self.db.profile[soundSelectKey])
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND", soundSelectKey)
        return
    end
    local volumeLevel = self.db.profile[volumeKey]

    -- Check that the volume level is within the valid range
    if volumeLevel < 0 or volumeLevel > 3 then
        self:PrintDebugMessage("INVALID_VOLUME_LEVEL", volumeLevel)
        return
    end

    -- Play the selected sound
    self:PlaySelectedSound(sound, volumeLevel, defaultSound)
end

function BLU:ToggleDebugMode()
    self.debugMode = not self.debugMode
    self.db.profile.debugMode = self.debugMode
    local statusMessage = self.debugMode and L["DEBUG_MODE_ENABLED"] or L["DEBUG_MODE_DISABLED"]
    print(BLU_PREFIX .. statusMessage)
    self:PrintDebugMessage("DEBUG_MODE_TOGGLED", tostring(self.debugMode))
end

function BLU:DebugMessage(message)
    if self.debugMode then
        print(BLU_PREFIX .. DEBUG_PREFIX .. message)
    end
end

function BLU:PrintDebugMessage(key, ...)
    if self.debugMode and L[key] then
        self:DebugMessage(L[key]:format(...))
    end
end

function BLU:DisplayWelcomeMessage()
    print(BLU_PREFIX .. L["WELCOME_MESSAGE"])
    self:PrintDebugMessage("WELCOME_MESSAGE_DISPLAYED")
end

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

    -- Collect all default sound IDs
    for soundID, soundList in pairs(defaultSounds) do
        for _, _ in pairs(soundList) do
            table.insert(validSoundIDs, {table = defaultSounds, id = soundID})
        end
    end

    -- Return nil if no valid sound IDs are found
    if #validSoundIDs == 0 then
        self:PrintDebugMessage("NO_VALID_SOUND_IDS")
        return nil
    end

    -- Select a random sound ID from the list
    local randomIndex = math.random(1, #validSoundIDs)
    local selectedSoundID = validSoundIDs[randomIndex]

    self:PrintDebugMessage("RANDOM_SOUND_ID_SELECTED", selectedSoundID.id)

    return selectedSoundID
end

--=====================================================================================
-- Function to select a sound based on the provided sound ID
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

--=====================================================================================
-- Test Sound Functions with Detailed Debug Output
--=====================================================================================
function BLU:TestSound(soundID, volumeKey, defaultSound, debugMessage)
    self:PrintDebugMessage(debugMessage)

    local sound = self:SelectSound(self.db.profile[soundID])
    if not sound then
        self:PrintDebugMessage(L["ERROR_SOUND_NOT_FOUND"] .. " " .. L["DEFAULT_SOUND_USED"])
    end

    local volumeLevel = self.db.profile[volumeKey]
    self:PlaySelectedSound(sound, volumeLevel, defaultSound)
end

--=====================================================================================
-- Function to play the selected sound with the specified volume level
function BLU:PlaySelectedSound(sound, volumeLevel, defaultTable)
    self:PrintDebugMessage("PLAYING_SOUND", sound.id, volumeLevel)

    -- Do not play the sound if the volume level is set to 0
    if volumeLevel == 0 then
        self:PrintDebugMessage("VOLUME_LEVEL_ZERO")
        return
    end

    -- Determine the sound file to play based on the sound ID and volume level
    local soundFile = sound.id == 1 and defaultTable[volumeLevel] or sound.table[sound.id][volumeLevel]

    -- Log the sound file being played
    self:PrintDebugMessage("SOUND_FILE_TO_PLAY", tostring(soundFile))

    -- Play the sound file using the "MASTER" sound channel
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    else
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND", sound.id)
    end
end
