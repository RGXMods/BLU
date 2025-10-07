-- libs/utils.lua
local utils = {}

function utils:ToggleDebugMode()
    self.addon.debugMode = not self.addon.debugMode
    self.addon.db.profile.debugMode = self.addon.debugMode

    local statusMessage = self.addon.debugMode and BLU_L["DEBUG_MODE_ENABLED"] or BLU_L["DEBUG_MODE_DISABLED"]

    print(BLU_PREFIX .. statusMessage)

    if self.addon.debugMode then
        self:PrintDebugMessage("DEBUG_MODE_TOGGLED", tostring(self.addon.debugMode))
    end
end

function utils:PrintDebugMessage(key, ...)
    if self.addon.debugMode and BLU_L[key] then
        self:DebugMessage(BLU_L[key]:format(...))
    end
end

function utils:DebugMessage(message)
    if self.addon.debugMode then
        print(BLU_PREFIX .. DEBUG_PREFIX .. message)
    end
end

function utils:ToggleWelcomeMessage()
    self.addon.showWelcomeMessage = not self.addon.showWelcomeMessage
    self.addon.db.profile.showWelcomeMessage = self.addon.showWelcomeMessage

    local status = self.addon.showWelcomeMessage and BLU_PREFIX .. BLU_L["WELCOME_MSG_ENABLED"] or BLU_PREFIX .. BLU_L["WELCOME_MSG_DISABLED"]
    print(status)
    self:PrintDebugMessage("SHOW_WELCOME_MESSAGE_TOGGLED", tostring(self.addon.showWelcomeMessage))
    self:PrintDebugMessage("CURRENT_DB_SETTING", tostring(self.addon.db.profile.showWelcomeMessage))
end

function utils:DisplayBLUHelp()
    local helpCommand = BLU_L["HELP_COMMAND"] or "/blu help - Displays help information."
    local helpDebug = BLU_L["HELP_DEBUG"] or "/blu debug - Toggles debug mode."
    local helpWelcome = BLU_L["HELP_WELCOME"] or "/blu welcome - Toggles welcome messages."
    local helpPanel = BLU_L["HELP_PANEL"] or "/blu panel - Opens the options panel."

    print(BLU_PREFIX .. helpCommand)
    print(BLU_PREFIX .. helpDebug)
    print(BLU_PREFIX .. helpWelcome)
    print(BLU_PREFIX .. helpPanel)
end

function utils:RandomSoundID()
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

function utils:SelectSound(soundID)
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

function utils:TestSound(soundID, volumeKey, defaultSound, debugMessage)
    self:PrintDebugMessage(debugMessage)

    local sound = self:SelectSound(self.addon.db.profile[soundID])

    local volumeLevel = self.addon.db.profile[volumeKey]
    self:PlaySelectedSound(sound, volumeLevel, defaultSound)
end

function utils:PlaySelectedSound(sound, volumeLevel, defaultTable)
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

BLULib = BLULib or {}
BLULib.Utils = utils
