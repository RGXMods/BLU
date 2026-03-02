--=====================================================================================
-- BLU | Better Level-Up! - utils.lua
-- Utility functions for event handling, sound playback, and slash commands
--=====================================================================================

-- Event queue for processing sounds
BLU_EventQueue = BLU_EventQueue or {}

local EVENT_QUEUE_DELAY_SECONDS = 1
local EVENT_QUEUE_MAX_SIZE = 40
local EVENT_DEDUPE_WINDOW_SECONDS = 0.2

local queueHead = 1
local queueTail = 0

local function GetQueueSize()
    if queueTail < queueHead then
        return 0
    end

    return (queueTail - queueHead) + 1
end

local function QueueEvent(eventData)
    queueTail = queueTail + 1
    BLU_EventQueue[queueTail] = eventData
end

local function DequeueEvent()
    if queueTail < queueHead then
        return nil
    end

    local eventData = BLU_EventQueue[queueHead]
    BLU_EventQueue[queueHead] = nil
    queueHead = queueHead + 1

    if queueHead > queueTail then
        queueHead = 1
        queueTail = 0
    end

    return eventData
end

--=====================================================================================
-- Database Get/Set Functions
--=====================================================================================
function BLU:GetValue(info)
    return self.db.profile[info[#info]]
end

function BLU:SetValue(info, value)
    self.db.profile[info[#info]] = value
end

--=====================================================================================
-- Event Handling
--=====================================================================================
function BLU:HandleEvent(eventName, soundSelectKey, volumeKey, defaultSound, debugMessage)
    if self.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end

    self.recentQueuedEvents = self.recentQueuedEvents or {}

    local now = GetTime and GetTime() or 0
    local eventSignature = table.concat({
        tostring(eventName),
        tostring(soundSelectKey),
        tostring(volumeKey)
    }, "|")

    local lastQueuedAt = self.recentQueuedEvents[eventSignature]
    if lastQueuedAt and (now - lastQueuedAt) < EVENT_DEDUPE_WINDOW_SECONDS then
        return
    end
    self.recentQueuedEvents[eventSignature] = now

    if GetQueueSize() >= EVENT_QUEUE_MAX_SIZE then
        DequeueEvent()
        self:PrintDebugMessage("EVENT_QUEUE_DROPPED_OLDEST")
    end
    
    -- Queue the event
    QueueEvent({
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

function BLU:ProcessEventQueue()
    local event = DequeueEvent()
    if not event then
        self.isProcessingQueue = false
        return
    end

    if event.debugMessage then
        self:PrintDebugMessage(event.debugMessage)
    end

    local sound = self:SelectSound(self.db.profile[event.soundSelectKey])
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND", tostring(event.soundSelectKey))
        C_Timer.After(EVENT_QUEUE_DELAY_SECONDS, function() self:ProcessEventQueue() end)
        return
    end

    local volumeLevel = self.db.profile[event.volumeKey]
    if not volumeLevel or volumeLevel < 0 or volumeLevel > 3 then
        volumeLevel = 2 -- Default to medium
    end

    self:PlaySelectedSound(sound, volumeLevel, event.defaultSound)
    C_Timer.After(EVENT_QUEUE_DELAY_SECONDS, function() self:ProcessEventQueue() end)
end

--=====================================================================================
-- Player Entering World Handler
--=====================================================================================
function BLU:HandlePlayerEnteringWorld()
    self:HaltOperations()
end

function BLU:HaltOperations()
    if not self.functionsHalted then
        self.functionsHalted = true
    end

    if self.haltTimer then
        self.haltTimer:Cancel()
        self.haltTimer = nil
    end

    local countdownTime = 5
    self.haltTimer = C_Timer.NewTicker(1, function()
        countdownTime = countdownTime - 1
        if countdownTime <= 0 then
            self:ResumeOperations()
        end
    end, countdownTime)
end

function BLU:ResumeOperations()
    if self.functionsHalted then
        self.functionsHalted = false
    end

    self.countdownRunning = false

    if self.haltTimer then
        self.haltTimer:Cancel()
        self.haltTimer = nil
    end
end

--=====================================================================================
-- Slash Command Handler
--=====================================================================================
function BLU:HandleSlashCommands(input)
    input = (input or ""):trim():lower()

    if input == "" then
        self:OpenOptionsPanel()
    elseif input == "debug" then
        self:ToggleDebugMode()
    elseif input == "welcome" then
        self:ToggleWelcomeMessage()
    elseif input == "help" then
        self:DisplayHelp()
    else
        print(BLU_PREFIX .. (BLU_L["UNKNOWN_SLASH_COMMAND"] or "Unknown command. Type /blu help for available commands."))
    end
end

--=====================================================================================
-- Options Panel (Multi-version compatible)
--=====================================================================================
function BLU:OpenOptionsPanel()
    -- Ensure options are initialized
    if not self.optionsFrame then
        self:InitializeOptions()
    end
    
    if not self.optionsFrame then
        print(BLU_PREFIX .. "Options not initialized. Please reload UI with /reload")
        return
    end
    
    local opened = false
    
    -- Try modern API first (Retail 10.0+)
    if Settings and Settings.OpenToCategory then
        local categoryID = self.optionsCategoryID

        if type(categoryID) ~= "number" and self.ResolveOptionsCategoryID then
            categoryID = self:ResolveOptionsCategoryID(BLU_L["OPTIONS_PANEL_TITLE"] or "BLU")
        end

        if type(categoryID) ~= "number" then
            categoryID = tonumber(categoryID)
        end

        if categoryID then
            local ok = pcall(Settings.OpenToCategory, categoryID)
            opened = ok
        end
    end
    
    -- Try legacy API (Classic Era, Classic, older Retail)
    if not opened and InterfaceOptionsFrame_OpenToCategory then
        -- Classic needs the frame itself, called twice (Blizzard bug workaround)
        local okFirst = pcall(InterfaceOptionsFrame_OpenToCategory, self.optionsFrame)
        local okSecond = pcall(InterfaceOptionsFrame_OpenToCategory, self.optionsFrame)
        opened = okFirst or okSecond
    end
    
    -- Fallback: Show Interface Options frame directly
    if not opened then
        if InterfaceOptionsFrame then
            InterfaceOptionsFrame:Show()
            opened = true
        elseif SettingsPanel then
            SettingsPanel:Show()
            opened = true
        end
    end
    
    if not opened then
        print(BLU_PREFIX .. "Unable to open options. Try /interface instead.")
    end
end

--=====================================================================================
-- Help Display
--=====================================================================================
function BLU:DisplayHelp()
    print(BLU_PREFIX .. "|cff8080ffBLU Commands:|r")
    print(BLU_PREFIX .. "  /blu - Open options panel")
    print(BLU_PREFIX .. "  /blu debug - Toggle debug mode")
    print(BLU_PREFIX .. "  /blu welcome - Toggle welcome message")
    print(BLU_PREFIX .. "  /blu help - Show this help")
end

--=====================================================================================
-- Toggle Functions
--=====================================================================================
function BLU:ToggleDebugMode()
    self.debugMode = not self.debugMode
    self.db.profile.debugMode = self.debugMode

    local status = self.debugMode 
        and (BLU_L["DEBUG_MODE_ENABLED"] or "Debug mode |cff00ff00enabled|r") 
        or (BLU_L["DEBUG_MODE_DISABLED"] or "Debug mode |cffff0000disabled|r")
    print(BLU_PREFIX .. status)
end

function BLU:ToggleWelcomeMessage()
    self.showWelcomeMessage = not self.showWelcomeMessage
    self.db.profile.showWelcomeMessage = self.showWelcomeMessage

    local status = self.showWelcomeMessage 
        and (BLU_L["WELCOME_MSG_ENABLED"] or "Welcome message |cff00ff00enabled|r") 
        or (BLU_L["WELCOME_MSG_DISABLED"] or "Welcome message |cffff0000disabled|r")
    print(BLU_PREFIX .. status)
end

--=====================================================================================
-- Debug Messaging
--=====================================================================================
function BLU:DebugMessage(message)
    if self.debugMode then
        print(BLU_PREFIX .. "|cffff8000[Debug]|r " .. message)
    end
end

function BLU:PrintDebugMessage(key, ...)
    if not self.debugMode then return end
    
    if BLU_L and BLU_L[key] then
        self:DebugMessage(BLU_L[key]:format(...))
    else
        -- Fallback: print key directly if no localization found
        self:DebugMessage(tostring(key))
    end
end

--=====================================================================================
-- Sound Selection
--=====================================================================================
function BLU:RandomSoundID()
    self:PrintDebugMessage("SELECTING_RANDOM_SOUND_ID")

    local validSoundIDs = {}

    if sounds then
        for soundID, _ in pairs(sounds) do
            table.insert(validSoundIDs, {table = sounds, id = soundID})
        end
    end

    if defaultSounds then
        for soundID, _ in pairs(defaultSounds) do
            table.insert(validSoundIDs, {table = defaultSounds, id = soundID})
        end
    end

    if #validSoundIDs == 0 then
        self:PrintDebugMessage("NO_VALID_SOUND_IDS")
        return nil
    end

    local randomIndex = math.random(1, #validSoundIDs)
    local selected = validSoundIDs[randomIndex]

    self:PrintDebugMessage("RANDOM_SOUND_ID_SELECTED", "|cff8080ff" .. selected.id .. "|r")
    return selected
end

function BLU:SelectSound(soundID)
    self:PrintDebugMessage("SELECTING_SOUND", "|cff8080ff" .. tostring(soundID) .. "|r")

    -- Random sound (value 2)
    if not soundID or soundID == 2 then
        local randomSound = self:RandomSoundID()
        if randomSound then
            self:PrintDebugMessage("USING_RANDOM_SOUND_ID", "|cff8080ff" .. randomSound.id .. "|r")
            return randomSound
        end
    end

    self:PrintDebugMessage("USING_SPECIFIED_SOUND_ID", "|cff8080ff" .. soundID .. "|r")
    return {table = sounds, id = soundID}
end

--=====================================================================================
-- Test Sound Function
--=====================================================================================
function BLU:TestSound(soundID, volumeKey, defaultSound, debugMessage)
    if debugMessage then
        self:PrintDebugMessage(debugMessage)
    end

    local sound = self:SelectSound(self.db.profile[soundID])
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND", tostring(soundID))
        return
    end
    
    local volumeLevel = self.db.profile[volumeKey]
    if not volumeLevel or volumeLevel < 0 or volumeLevel > 3 then
        volumeLevel = 2
    end
    
    self:PlaySelectedSound(sound, volumeLevel, defaultSound)
end

--=====================================================================================
-- Sound Playback
--=====================================================================================
function BLU:PlaySelectedSound(sound, volumeLevel, defaultTable)
    self:PrintDebugMessage("PLAYING_SOUND", tostring(sound.id), tostring(volumeLevel))

    if volumeLevel == 0 then
        self:PrintDebugMessage("VOLUME_LEVEL_ZERO")
        return
    end

    local soundFile
    
    -- Default sound (value 1)
    if sound.id == 1 then
        soundFile = defaultTable and defaultTable[volumeLevel]
    else
        -- Custom sound
        soundFile = sound.table and sound.table[sound.id] and sound.table[sound.id][volumeLevel]
    end

    self:PrintDebugMessage("SOUND_FILE_TO_PLAY", "|cffce9178" .. tostring(soundFile) .. "|r")

    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    else
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND", "|cff8080ff" .. tostring(sound.id) .. "|r")
    end
end
