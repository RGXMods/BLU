BLU_L = BLU_L or {}
--=====================================================================================
-- BLU | Better Level-Up! - utils.lua
--=====================================================================================

-- Global table to hold the event queue
BLU_EventQueue = {}

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
function BLU:HandleEvent(eventName, soundSelectKey, volumeKey, defaultSound, debugMessage)
    if self.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end

    -- Mute the default sound for this event
    local version = self:GetGameVersion()
    local soundIDs = muteSoundIDs[version]
    if soundIDs then
        for _, soundID in ipairs(soundIDs) do
            MuteSoundFile(soundID)
        end
    end
    
    table.insert(BLU_EventQueue, {
        eventName = eventName,
        soundSelectKey = soundSelectKey,
        volumeKey = volumeKey,
        defaultSound = defaultSound,
        debugMessage = debugMessage
    })

    if not self.isProcessingQueue then
        self.isProcessingQueue = true
        self:ProcessEventQueue()
    end
end

--=====================================================================================
-- Process Event Queue
--=====================================================================================
function BLU:ProcessEventQueue()
    if #BLU_EventQueue == 0 then
        self.isProcessingQueue = false
        return
    end

    local event = table.remove(BLU_EventQueue, 1)

    -- Ensure the debug message is valid before playing the sound
    if event.debugMessage then
        self:PrintDebugMessage(event.debugMessage)
    else
        self:PrintDebugMessage("DEBUG_MESSAGE_MISSING")
    end

    -- Process the event (select sound, check volume, play sound)
    local sound = self:SelectSound(self.db.profile[event.soundSelectKey])
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND", tostring(event.soundSelectKey))
        -- Continue processing the queue after a short delay
        C_Timer.After(1, function() self:ProcessEventQueue() end)
        return
    end

    local volumeLevel = self.db.profile[event.volumeKey]
    if volumeLevel < 0 or volumeLevel > 3 then
        self:PrintDebugMessage("INVALID_VOLUME_LEVEL", tostring(volumeLevel))
        -- Continue processing the queue after a short delay
        C_Timer.After(1, function() self:ProcessEventQueue() end)
        return
    end

    -- Play the selected sound after debug message is printed
    self:PlaySelectedSound(sound, volumeLevel, event.defaultSound)

    -- Continue processing the queue after a 1-second delay
    C_Timer.After(1, function() self:ProcessEventQueue() end)
end

--=====================================================================================
-- Player Entering World Handler
--=====================================================================================
function BLU:HandlePlayerEnteringWorld()
    self:HaltOperations()
end

--=====================================================================================
-- Halt Operations
--=====================================================================================
function BLU:HaltOperations()

    -- Ensure functions are halted
    if not self.functionsHalted then
        self.functionsHalted = true
    end

    -- Cancel the existing timer if it's running
    if self.haltTimer then
        self.haltTimer:Cancel()
        self.haltTimer = nil
    end

    -- Initialize countdown variables
    local countdownTime = 5

    -- Start the countdown timer
    self.haltTimer = C_Timer.NewTicker(1, function()
        countdownTime = countdownTime - 1

        -- Debug message for each countdown tick
        -- self:PrintDebugMessage("COUNTDOWN_TICK", countdownTime)

        if countdownTime <= 0 then
            -- Call the resume function when countdown finishes
            self:ResumeOperations()
        end
    end, countdownTime)
end

--=====================================================================================
-- Resume Operations
--=====================================================================================
function BLU:ResumeOperations()

    -- Lift the function halt
    if self.functionsHalted then
        self.functionsHalted = false
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
    input = input:trim():lower()

    if input == "" then
        self:OpenOptionsPanel()
    elseif input == "debug" then
        self:ToggleDebugMode()
    elseif input == "welcome" then
        self:ToggleWelcomeMessage()
    elseif input == "help" then
        self:DisplayBLUHelp()
    else
        print(BLU_PREFIX .. BLU_L["UNKNOWN_SLASH_COMMAND"])
    end
end

--=====================================================================================
-- Open Options Panel (with Classic Era compatibility)
--=====================================================================================
function BLU:OpenOptionsPanel()
    -- Make sure options are initialized first
    if not self.optionsFrame then
        self:InitializeOptions()
    end
    
    if not self.optionsFrame then
        print(BLU_PREFIX .. "Options not initialized. Please reload UI.")
        return
    end
    
    local opened = false
    
    -- Try modern API first (Retail 10.0+)
    if Settings and Settings.OpenToCategory then
        -- In Retail, optionsFrame.name contains the category name
        local categoryName = self.optionsFrame.name or BLU_L["OPTIONS_PANEL_TITLE"]
        Settings.OpenToCategory(categoryName)
        opened = true
    end
    
    -- Try legacy API (Classic Era, Classic, older Retail)
    if not opened and InterfaceOptionsFrame_OpenToCategory then
        -- Classic needs the frame itself, not just the name
        -- Call twice to ensure it opens to the correct category (known Blizzard bug)
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        opened = true
    end
    
    -- Fallback: Try to show the Interface Options frame directly
    if not opened then
        if InterfaceOptionsFrame then
            InterfaceOptionsFrame:Show()
            opened = true
        elseif SettingsPanel then
            SettingsPanel:Show()
            opened = true
        end
    end
    
    if opened then
        if self.debugMode then
            self:PrintDebugMessage("OPTIONS_PANEL_OPENED")
        end
    else
        print(BLU_PREFIX .. "Unable to open options panel. Try /interface instead.")
    end
end

--=====================================================================================
-- Display BLU Help
--=====================================================================================
function BLU:DisplayBLUHelp()
    local helpCommand = BLU_L["HELP_COMMAND"] or "/blu help - Displays help information."
    local helpDebug = BLU_L["HELP_DEBUG"] or "/blu debug - Toggles debug mode."
    local helpWelcome = BLU_L["HELP_WELCOME"] or "/blu welcome - Toggles welcome messages."
    local helpPanel = BLU_L["HELP_PANEL"] or "/blu - Opens the options panel."

    print(BLU_PREFIX .. helpCommand)
    print(BLU_PREFIX .. helpDebug)
    print(BLU_PREFIX .. helpWelcome)
    print(BLU_PREFIX .. helpPanel)
end

--=====================================================================================
-- Utility Functions
--=====================================================================================
-- Function: GetLocalizedString
-- Purpose: Retrieves the localized string based on the user's locale.
--[[
function BLU:GetLocalizedString(key)
    local locale = GetLocale()
    if BLU_L[key] and BLU_L[key][locale] then
        return BLU_L[key][locale]
    elseif BLU_L[key] and BLU_L[key]["enUS"] then
        return BLU_L[key]["enUS"] -- Fallback to English
    else
        return key -- If no localization is found, return the key itself
    end
end
]]
--=====================================================================================
-- Toggle Debug Mode
--=====================================================================================
function BLU:ToggleDebugMode()
    self.debugMode = not self.debugMode
    self.db.profile.debugMode = self.debugMode

    -- Use the localized strings directly, assuming they are defined
    local statusMessage = self.debugMode and BLU_L["DEBUG_MODE_ENABLED"] or BLU_L["DEBUG_MODE_DISABLED"]

    print(BLU_PREFIX .. statusMessage)

    -- Only print the debug message if debug mode is enabled
    if self.debugMode then
        self:PrintDebugMessage("DEBUG_MODE_TOGGLED", tostring(self.debugMode))
    end
end
--=====================================================================================
-- Toggle Welcome Message
--=====================================================================================

function BLU:ToggleWelcomeMessage()
    self.showWelcomeMessage = not self.showWelcomeMessage
    self.db.profile.showWelcomeMessage = self.showWelcomeMessage

    local status = self.showWelcomeMessage and BLU_PREFIX .. BLU_L["WELCOME_MSG_ENABLED"] or BLU_PREFIX .. BLU_L["WELCOME_MSG_DISABLED"]
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
    if self.debugMode and BLU_L[key] then
        self:DebugMessage(BLU_L[key]:format(...))
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

    self:PrintDebugMessage("RANDOM_SOUND_ID_SELECTED", "|cff8080ff" .. selectedSoundID.id .. "|r")

    return selectedSoundID
end
--=====================================================================================
-- Select Sound
--=====================================================================================
function BLU:SelectSound(soundID)
    self:PrintDebugMessage("SELECTING_SOUND", "|cff8080ff" .. tostring(soundID) .. "|r")

    if not soundID or soundID == 2 then
        local randomSoundID = self:RandomSoundID()
        if randomSoundID then
            self:PrintDebugMessage("USING_RANDOM_SOUND_ID", "|cff8080ff" .. randomSoundID.id .. "|r")
            return randomSoundID
        end
    end

    self:PrintDebugMessage("USING_SPECIFIED_SOUND_ID", "|cff8080ff" .. soundID .. "|r")
    return {table = sounds, id = soundID}
end

--=====================================================================================
-- Test Sound Functions with Detailed Debug Output
--=====================================================================================

function BLU:TestSound(soundID, volumeKey, defaultSound, debugMessage)
    self:PrintDebugMessage(debugMessage)

    local sound = self:SelectSound(self.db.profile[soundID])

    local volumeLevel = self.db.profile[volumeKey]
    self:PlaySelectedSound(sound, volumeLevel, defaultSound)
end
--=====================================================================================
-- Play Selected Sound
--=====================================================================================
function BLU:PlaySelectedSound(sound, volumeLevel, defaultTable)
    self:PrintDebugMessage("PLAYING_SOUND", sound.id, volumeLevel)

    if volumeLevel == 0 then
        self:PrintDebugMessage("VOLUME_LEVEL_ZERO")
        return
    end

    local soundFile = sound.id == 1 and defaultTable[volumeLevel] or sound.table[sound.id][volumeLevel]

    self:PrintDebugMessage("SOUND_FILE_TO_PLAY", "|cffce9178" .. tostring(soundFile) .. "|r")

    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    else
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND", "|cff8080ff" .. sound.id .. "|r")
    end
end