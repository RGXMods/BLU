-- libs/utils.lua
local utils = {}

function utils.ToggleDebugMode(addon)
    addon.db.profile.debugMode = not addon.db.profile.debugMode
    local statusMessage = addon.db.profile.debugMode and addon.L["DEBUG_MODE_ENABLED"] or addon.L["DEBUG_MODE_DISABLED"]
    addon:Print(statusMessage)
end

function utils.ToggleWelcomeMessage(addon)
    addon.db.profile.showWelcomeMessage = not addon.db.profile.showWelcomeMessage
    local status = addon.db.profile.showWelcomeMessage and addon.L["WELCOME_MSG_ENABLED"] or addon.L["WELCOME_MSG_DISABLED"]
    addon:Print(status)
end

function utils.DisplayBLUHelp(addon)
    addon:Print(addon.L["HELP_COMMAND"])
    addon:Print(addon.L["HELP_DEBUG"])
    addon:Print(addon.L["HELP_WELCOME"])
    addon:Print(addon.L["HELP_PANEL"])
end

function utils.RandomSoundID(addon)
    addon:PrintDebug("SELECTING_RANDOM_SOUND_ID")
    local soundsModule = addon:GetModule("Sounds")
    local validSoundIDs = {}
    for soundID, _ in pairs(soundsModule.soundOptions) do
        if soundID ~= 1 and soundID ~= 2 then -- Exclude Default and Random
            table.insert(validSoundIDs, soundID)
        end
    end
    if #validSoundIDs == 0 then
        addon:PrintDebug("NO_VALID_SOUND_IDS")
        return nil
    end
    local randomIndex = math.random(1, #validSoundIDs)
    local selectedSoundID = validSoundIDs[randomIndex]
    addon:PrintDebug("RANDOM_SOUND_ID_SELECTED", selectedSoundID)
    return selectedSoundID
end

function utils.SelectSound(addon, soundID)
    addon:PrintDebug("SELECTING_SOUND", soundID)
    if not soundID or soundID == 2 then
        local randomSoundID = utils.RandomSoundID(addon)
        if randomSoundID then
            addon:PrintDebug("USING_RANDOM_SOUND_ID", randomSoundID)
            return randomSoundID
        end
    end
    addon:PrintDebug("USING_SPECIFIED_SOUND_ID", soundID)
    return soundID
end

function utils.PlaySelectedSound(addon, soundID, volumeLevel, defaultSound)
    addon:PrintDebug("PLAYING_SOUND", soundID, volumeLevel)
    if volumeLevel == 0 then
        addon:PrintDebug("VOLUME_LEVEL_ZERO")
        return
    end
    local soundsModule = addon:GetModule("Sounds")
    local soundFile
    if soundID == 1 then
        soundFile = defaultSound[volumeLevel]
    else
        soundFile = soundsModule.soundOptions[soundID] and soundsModule.soundOptions[soundID][volumeLevel]
    end

    if soundFile then
        addon:PrintDebug("SOUND_FILE_TO_PLAY", soundFile)
        PlaySoundFile(soundFile, "MASTER")
    else
        addon:PrintDebug("ERROR_SOUND_NOT_FOUND", soundID)
    end
end

function utils.TestSound(addon, soundSelectKey, volumeKey, defaultSound, debugMessage)
    addon:PrintDebug(debugMessage)
    local soundID = addon.db.profile[soundSelectKey]
    local volume = addon.db.profile[volumeKey]
    local soundToPlay = utils.SelectSound(addon, soundID)
    if soundToPlay then
        utils.PlaySelectedSound(addon, soundToPlay, volume, defaultSound)
    end
end

BLULib = BLULib or {}
BLULib.Utils = utils
