--=====================================================================================
-- BLU | Better Level Up! - utils.lua
--=====================================================================================

BLU_L = BLU_L or {}

--=====================================================================================
-- Get and Set Functions
--=====================================================================================

function BLU:GetValue(info)
    return self.db.profile[info[#info]]
end

function BLU:SetValue(info, value)
    self.db.profile[info[#info]] = value
end

--=====================================================================================
-- Event Handling Functions
--=====================================================================================

function BLU:HandleEvent(eventName, soundSelectKey, volumeKey, defaultSound)
    -- Ensure localization for eventName exists
    if not BLU_L["EVENT_TRIGGERED"] then
        self:PrintDebugMessage("Missing localization for EVENT_TRIGGERED")
        return
    end

    -- Print event name
    self:PrintDebugMessage(string.format(BLU_L["EVENT_TRIGGERED"], eventName))

    -- Ensure soundSelectKey exists in the database
    if not self.db.profile[soundSelectKey] then
        self:PrintDebugMessage(string.format(BLU_L["SOUND_SELECT_KEY_NOT_FOUND"], soundSelectKey))
        return
    end

    -- Select sound
    local sound = self:SelectSound(self.db.profile[soundSelectKey])
    if not sound then
        self:PrintDebugMessage(string.format(BLU_L["SOUND_NOT_FOUND_FOR_ID"], soundSelectKey))
        return
    end

    -- Validate volume level
    local volumeLevel = self.db.profile[volumeKey]
    if not volumeLevel or volumeLevel < 0 or volumeLevel > 3 then
        self:PrintDebugMessage(string.format(BLU_L["INVALID_VOLUME_LEVEL"], tostring(volumeLevel)))
        return
    end

    -- Play the sound
    self:PlaySelectedSound(sound, volumeLevel, defaultSound)
end

--=====================================================================================
-- Halt and Resume Operations
--=====================================================================================

function BLU:HaltOperations()
    self:PrintDebugMessage(BLU_L["HALT_OPERATIONS_FUNCTION_USED"], "HaltOperations")

    if not self.functionsHalted then
        self.functionsHalted = true
        self:PrintDebugMessage(BLU_L["FUNCTIONS_HALTED"])
    end

    if self.haltTimer then
        self.haltTimer:Cancel()
        self.haltTimer = nil
        self:PrintDebugMessage(BLU_L["COUNTDOWN_TIMER_RESET"])
    end

    local countdownTime = 10
    self:PrintDebugMessage(string.format(BLU_L["HALT_TIMER_STARTED"], countdownTime))

    self.haltTimer = C_Timer.NewTicker(1, function()
        countdownTime = countdownTime - 1
        self:PrintDebugMessage(string.format(BLU_L["COUNTDOWN_TICK"], countdownTime))

        if countdownTime <= 0 then
            self:ResumeOperations()
        end
    end, countdownTime)
end

function BLU:ResumeOperations()
    self:PrintDebugMessage(BLU_L["RESUME_OPERATIONS_FUNCTION_USED"], "ResumeOperations")

    if self.functionsHalted then
        self.functionsHalted = false
        self:PrintDebugMessage(BLU_L["FUNCTIONS_RESUMED"])
    end

    if self.haltTimer then
        self.haltTimer:Cancel()
        self.haltTimer = nil
    end
end

--=====================================================================================
-- Slash Command Handling
--=====================================================================================

function BLU:HandleSlashCommands(input)
    input = input:trim():lower()

    if input == "" then
        Settings.OpenToCategory(self.optionsFrame.name)
        if self.debugMode then
            self:PrintDebugMessage(BLU_L["OPTIONS_PANEL_OPENED"])
        end
    elseif input == "debug" then
        self:ToggleDebugMode()
    elseif input == "welcome" then
        self:ToggleWelcomeMessage()
    elseif input == "help" then
        self:PrintDebugMessage(BLU_L["HELP_COMMAND_RECOGNIZED"])
        self:DisplayBLUHelp()
    else
        self:PrintDebugMessage(string.format(BLU_L["UNKNOWN_SLASH_COMMAND"], input))
        print(BLU_PREFIX .. string.format(BLU_L["UNKNOWN_SLASH_COMMAND"], input))
    end
end

function BLU:DisplayBLUHelp()
    print(BLU_PREFIX .. BLU_L["HELP_COMMAND"])
    print(BLU_PREFIX .. BLU_L["HELP_DEBUG"])
    print(BLU_PREFIX .. BLU_L["HELP_WELCOME"])
    print(BLU_PREFIX .. BLU_L["HELP_PANEL"])
end

--=====================================================================================
-- Utility Functions
--=====================================================================================

function BLU:ToggleDebugMode()
    self.debugMode = not self.debugMode
    self.db.profile.debugMode = self.debugMode

    local statusMessage = self.debugMode and BLU_L["DEBUG_MODE_ENABLED"] or BLU_L["DEBUG_MODE_DISABLED"]
    print(BLU_PREFIX .. statusMessage)
    self:PrintDebugMessage("DEBUG_MODE_TOGGLED", tostring(self.debugMode))
end

function BLU:ToggleWelcomeMessage()
    self.showWelcomeMessage = not self.showWelcomeMessage
    self.db.profile.showWelcomeMessage = self.showWelcomeMessage

    local status = self.showWelcomeMessage and BLU_PREFIX .. BLU_L["WELCOME_MSG_ENABLED"] or BLU_PREFIX .. BLU_L["WELCOME_MSG_DISABLED"]
    print(status)
    self:PrintDebugMessage("SHOW_WELCOME_MESSAGE_TOGGLED", tostring(self.showWelcomeMessage))
    self:PrintDebugMessage(string.format(BLU_L["CURRENT_DB_SETTING"], tostring(self.db.profile.showWelcomeMessage)))
end

--=====================================================================================
-- Debug Message Functions
--=====================================================================================

function BLU:DebugMessage(message)
    if self.debugMode then
        print(BLU_PREFIX .. DEBUG_PREFIX .. message)
    end
end

local missingKeys = {}

function BLU:PrintDebugMessage(key, ...)
    if self.debugMode then
        if not key then 
            print("Attempted to print a debug message with a nil key. Please check the function call stack.")
            return
        end

        if not BLU_L[key] then
            print("Missing localization key: " .. tostring(key))
            return
        end

        local message = BLU_L[key]
        self:DebugMessage(string.format(message, ...))
    end
end


--=====================================================================================
-- Sound Selection Functions
--=====================================================================================

function BLU:RandomSoundID()
    self:PrintDebugMessage(BLU_L["SELECTING_RANDOM_SOUND_ID"])

    local validSoundIDs = {}

    for soundID, soundList in pairs(sounds) do
        if type(soundList) == "table" then
            for _, _ in pairs(soundList) do
                table.insert(validSoundIDs, { table = sounds, id = soundID })
            end
        end
    end

    for soundID, soundList in pairs(defaultSounds) do
        if type(soundList) == "table" then
            for _, _ in pairs(soundList) do
                table.insert(validSoundIDs, { table = defaultSounds, id = soundID })
            end
        end
    end

    if #validSoundIDs == 0 then
        self:PrintDebugMessage(BLU_L["NO_VALID_SOUND_IDS"])
        return nil
    end

    local randomIndex = math.random(1, #validSoundIDs)
    local selectedSoundID = validSoundIDs[randomIndex]
    self:PrintDebugMessage(string.format(BLU_L["RANDOM_SOUND_ID_SELECTED"], selectedSoundID.id))

    return selectedSoundID
end

function BLU:SelectSound(soundID)
    self:PrintDebugMessage(string.format(BLU_L["SELECTING_SOUND"], tostring(soundID)))

    if not soundID or soundID == 2 then
        local randomSoundID = self:RandomSoundID()
        if randomSoundID then
            self:PrintDebugMessage(string.format(BLU_L["USING_RANDOM_SOUND_ID"], randomSoundID.id))
            return randomSoundID
        end
    end

    self:PrintDebugMessage(string.format(BLU_L["USING_SPECIFIED_SOUND_ID"], soundID))
    return { table = sounds, id = soundID }
end

--=====================================================================================
-- Test and Play Sound Functions
--=====================================================================================

function BLU:TestSound(soundID, volumeKey, defaultSound, debugMessage)
    self:PrintDebugMessage(debugMessage)

    local sound = self:SelectSound(self.db.profile[soundID])
    if not sound then
        self:PrintDebugMessage(BLU_L["ERROR_SOUND_NOT_FOUND"] .. " " .. BLU_L["DEFAULT_SOUND_USED"])
    end

    local volumeLevel = self.db.profile[volumeKey]
    self:PlaySelectedSound(sound, volumeLevel, defaultSound)
end

function BLU:PlaySelectedSound(sound, volumeLevel, defaultTable)
    self:PrintDebugMessage(string.format(BLU_L["PLAYING_SOUND"], sound.id, volumeLevel))

    if volumeLevel == 0 then
        self:PrintDebugMessage(BLU_L["VOLUME_LEVEL_ZERO"])
        return
    end

    local soundFile = sound.id == 1 and defaultTable[volumeLevel] or sound.table[sound.id][volumeLevel]
    self:PrintDebugMessage(string.format(BLU_L["SOUND_FILE_TO_PLAY"], tostring(soundFile)))

    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    else
        self:PrintDebugMessage(string.format(BLU_L["ERROR_SOUND_NOT_FOUND_FOR_ID"], sound.id))
    end
end
