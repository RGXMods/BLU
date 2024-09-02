--=====================================================================================
-- BLU | Better Level Up! - utils.lua
--=====================================================================================
--=====================================================================================
-- Get and Set Functions
--=====================================================================================
function BLU:GetValue(info)
    self:PrintDebugMessage("GETTING_VALUE", info[#info])
    return self.db.profile[info[#info]]
end

function BLU:SetValue(info, value)
    self:PrintDebugMessage("SETTING_VALUE", info[#info], tostring(value))
    self.db.profile[info[#info]] = value
end
--=====================================================================================
-- Event Handling Functions
--=====================================================================================

function BLU:HandleEvent(eventName, soundSelectKey, volumeKey, defaultSound)
    self:PrintDebugMessage(eventName .. " triggered")

    local sound = self:SelectSound(self.db.profile[soundSelectKey])
    if not sound then
        self:PrintDebugMessage("Sound not found for sound ID: " .. tostring(soundSelectKey))
        return
    end

    local volumeLevel = self.db.profile[volumeKey]
    if volumeLevel < 0 or volumeLevel > 3 then
        self:PrintDebugMessage("Invalid volume level: " .. tostring(volumeLevel))
        return
    end

    self:PlaySelectedSound(sound, volumeLevel, defaultSound)
end

function BLU:HandlePlayerEnteringWorld()
    self:PrintDebugMessage("PLAYER_ENTER_WORLD_FUNCTION_USED", "HandlePlayerEnteringWorld")
    self:HaltOperations()
end

function BLU:HaltOperations()
    self:PrintDebugMessage("HALT_OPERATIONS_FUNCTION_USED", "HaltOperations")

    -- Ensure functions are halted
    if not self.functionsHalted then
        self.functionsHalted = true
        self:PrintDebugMessage("FUNCTIONS_HALTED")
    end

    -- Cancel the existing timer if it's running
    if self.haltTimer then
        self.haltTimer:Cancel()
        self.haltTimer = nil
        self:PrintDebugMessage("COUNTDOWN_TIMER_RESET")
    end

    -- Initialize countdown variables
    local countdownTime = 15

    -- Debug message to confirm that the countdown timer has started
    self:PrintDebugMessage("HALT_TIMER_STARTED", countdownTime)

    -- Start the countdown timer
    self.haltTimer = C_Timer.NewTicker(1, function()
        countdownTime = countdownTime - 1

        -- Debug message for each countdown tick
        self:PrintDebugMessage("COUNTDOWN_TICK", countdownTime)

        if countdownTime <= 0 then
            -- Call the resume function when countdown finishes
            self:ResumeOperations()
        end
    end, countdownTime)
end

function BLU:ResumeOperations()
    self:PrintDebugMessage("RESUME_OPERATIONS_FUNCTION_USED", "ResumeOperations")

    -- Lift the function halt
    if self.functionsHalted then
        self.functionsHalted = false
        self:PrintDebugMessage("FUNCTIONS_RESUMED")
    end

    -- Mark the countdown as not running
    self.countdownRunning = false

    -- Stop the timer after it finishes
    if self.haltTimer then
        self.haltTimer:Cancel()
        self.haltTimer = nil
    end
end

--=====================================================================================
-- Slash Command Registration
--=====================================================================================

function BLU:HandleSlashCommands(input)
    input = input:trim():lower()  -- Convert input to lowercase

    if input == "" then
        Settings.OpenToCategory(self.optionsFrame.name)
        if self.debugMode then
            self:PrintDebugMessage("OPTIONS_PANEL_OPENED")
        end
    elseif input == "debug" then
        self:ToggleDebugMode()
    elseif input == "welcome" then
        self:ToggleWelcomeMessage()
    elseif input == "help" then
        self:PrintDebugMessage("HELP_COMMAND_RECOGNIZED")
        self:DisplayBLUHelp()
    else
        self:PrintDebugMessage("UNKNOWN_SLASH_COMMAND", input)
        print(BLU_PREFIX .. L["UNKNOWN_SLASH_COMMAND"])
    end
end

function BLU:DisplayBLUHelp()
    print(BLU_PREFIX .. L["HELP_COMMAND"])
    print(BLU_PREFIX .. L["HELP_DEBUG"])
    print(BLU_PREFIX .. L["HELP_WELCOME"])
    print(BLU_PREFIX .. L["HELP_PANEL"])
end

--=====================================================================================
-- Utility Functions
--=====================================================================================

function BLU:ToggleDebugMode()
    self.debugMode = not self.debugMode
    self.db.profile.debugMode = self.debugMode

    local statusMessage = self.debugMode and L["DEBUG_MODE_ENABLED"] or L["DEBUG_MODE_DISABLED"]
    print(BLU_PREFIX .. statusMessage)
    self:PrintDebugMessage("DEBUG_MODE_TOGGLED", tostring(self.debugMode))
end

function BLU:ToggleWelcomeMessage()
    self.showWelcomeMessage = not self.showWelcomeMessage
    self.db.profile.showWelcomeMessage = self.showWelcomeMessage

    local status = self.showWelcomeMessage and BLU_PREFIX .. L["WELCOME_MSG_ENABLED"] or BLU_PREFIX .. L["WELCOME_MSG_DISABLED"]
    print(status)
    self:PrintDebugMessage("SHOW_WELCOME_MESSAGE_TOGGLED", tostring(self.showWelcomeMessage))
    self:PrintDebugMessage("CURRENT_DB_SETTING", tostring(self.db.profile.showWelcomeMessage))
end

--=====================================================================================
-- Debug Messaging Functions
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

--=====================================================================================
-- Sound Selection Functions
--=====================================================================================

function BLU:RandomSoundID()
    self:PrintDebugMessage("SELECTING_RANDOM_SOUND_ID")

    local validSoundIDs = {}

    for soundID, soundList in pairs(sounds) do
        for _, _ in pairs(soundList) do
            table.insert(validSoundIDs, {table = sounds, id = soundID})
        end
    end

    for soundID, soundList in pairs(defaultSounds) do
        for _, _ in pairs(soundList) do
            table.insert(validSoundIDs, {table = defaultSounds, id = soundID})
        end
    end

    if #validSoundIDs == 0 then
        self:PrintDebugMessage("NO_VALID_SOUND_IDS")
        return nil
    end

    local randomIndex = math.random(1, #validSoundIDs)
    local selectedSoundID = validSoundIDs[randomIndex]

    self:PrintDebugMessage("RANDOM_SOUND_ID_SELECTED", selectedSoundID.id)

    return selectedSoundID
end

function BLU:SelectSound(soundID)
    self:PrintDebugMessage("SELECTING_SOUND", tostring(soundID))

    if not soundID or soundID == 2 then
        local randomSoundID = self:RandomSoundID()
        if randomSoundID then
            self:PrintDebugMessage("USING_RANDOM_SOUND_ID", randomSoundID.id)
            return randomSoundID
        end
    end

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

function BLU:PlaySelectedSound(sound, volumeLevel, defaultTable)
    self:PrintDebugMessage("PLAYING_SOUND", sound.id, volumeLevel)

    if volumeLevel == 0 then
        self:PrintDebugMessage("VOLUME_LEVEL_ZERO")
        return
    end

    local soundFile = sound.id == 1 and defaultTable[volumeLevel] or sound.table[sound.id][volumeLevel]

    self:PrintDebugMessage("SOUND_FILE_TO_PLAY", tostring(soundFile))

    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    else
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND", sound.id)
    end
end
