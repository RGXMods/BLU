-- utils.lua

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

--=====================================================================================
-- Function to play the selected sound with the specified volume level
--=====================================================================================
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
end

--=====================================================================================
-- Utility Functions
--=====================================================================================
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
    -- Display the welcome message in the chat window
    print(BLU_PREFIX .. L["WELCOME_MESSAGE"])
    self:PrintDebugMessage("WELCOME_MESSAGE_DISPLAYED")
end

--=====================================================================================
-- Slash Command
--=====================================================================================
function BLU:SlashCommand(input)
    self:PrintDebugMessage("PROCESSING_SLASH_COMMAND", input)

    if input == "debug" then
        self.debugMode = not self.debugMode
        self.db.profile.debugMode = self.debugMode
        self:PrintDebugMessage("DEBUG_MODE_TOGGLED", tostring(self.debugMode))
        local status = self.debugMode and "DEBUG_MODE_ENABLED" or "DEBUG_MODE_DISABLED"
        self:PrintDebugMessage(status)
    elseif input == "welcome" then
        self.showWelcomeMessage = not self.showWelcomeMessage
        self.db.profile.showWelcomeMessage = self.showWelcomeMessage
        self:PrintDebugMessage("SHOW_WELCOME_MESSAGE_TOGGLED", tostring(self.showWelcomeMessage))
        local status = self.showWelcomeMessage and "|cff00ff00enabled|r" or "|cffff0000disabled|r"
        print(BLU_PREFIX .. "Welcome message " .. status)
    elseif input == "enable" then
        self:Enable()
        self:PrintDebugMessage("ENABLING_ADDON")
        print(BLU_PREFIX .. L["ADDON_ENABLED"])
    elseif input == "disable" then
        self:Disable()
        print(BLU_PREFIX .. L["ADDON_DISABLED"])
    elseif input == "help" then
        print(L["SLASH_COMMAND_HELP"])
    else
        -- Log unknown command
        self:PrintDebugMessage("UNKNOWN_SLASH_COMMAND", input)
        Settings.OpenToCategory(self.optionsFrame.name)
        if self.debugMode then
            self:PrintDebugMessage("OPTIONS_PANEL_OPENED")
        end
    end
end
