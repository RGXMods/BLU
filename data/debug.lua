--=====================================================================================
-- Debug Utility for Better Level Up (BLU)
--=====================================================================================

--=====================================================================================
-- Debug Messages
--=====================================================================================
local debugMessages = {
    ["ADDON_ENABLED"] = "|cff00ff00BLU: Addon Enabled|r",
    ["ADDON_DISABLED"] = "|cffff0000BLU: Addon Disabled|r",
    ["MUTE_SOUND"] = "Muted Sound ID: %s",
    ["UNMUTE_SOUND"] = "Unmuted Sound ID: %s",
    ["REPUTATION_CHAT_FRAME_HOOKED"] = "|cffffff00Reputation Chat Frame Hooked|r",
    ["RANK_FOUND_EXALTED"] = "|cff00ff00Rank found: Exalted|r",
    ["RANK_FOUND_REVERED"] = "|cffffff00Rank found: Revered|r",
    ["RANK_FOUND_HONORED"] = "|cffffff00Rank found: Honored|r",
    ["RANK_FOUND_FRIENDLY"] = "|cff00ff00Rank found: Friendly|r",
    ["RANK_FOUND_NEUTRAL"] = "|cffffffffRank found: Neutral|r",
    ["RANK_FOUND_UNFRIENDLY"] = "|cffff8000Rank found: Unfriendly|r",
    ["RANK_FOUND_HOSTILE"] = "|cffff0000Rank found: Hostile|r",
    ["RANK_FOUND_HATED"] = "|cffff0000Rank found: Hated|r",
    ["NO_RANK_FOUND"] = "|cffff0000No rank found in message|r",
    ["PLAYER_ENTERING_WORLD"] = "|cffffff00Player Entering World...|r",
    ["PLAYER_LEVEL_UP"] = "|cff00ff00Player Leveled Up|r",
    ["QUEST_ACCEPTED"] = "|cffffff00Quest Accepted|r",
    ["QUEST_TURNED_IN"] = "|cffffff00Quest Turned In|r",
    ["OPTIONS_PANEL_OPENED"] = "|cffffff00Options Panel Opened|r",
    ["COUNTDOWN_START"] = "|cffffff00Countdown Started|r",
    ["COUNTDOWN_TICK"] = "|cffffff00Countdown Tick: %s|r",
    ["FUNCTIONS_RESUMED"] = "|cff00ff00Functions Resumed|r",
    ["FUNCTIONS_HALTED"] = "|cffff0000Functions Halted|r",
    ["ERROR_SOUND_NOT_FOUND"] = "|cffff0000Error: Sound Not Found|r",
    ["MAJOR_FACTION_RENOWN_LEVEL_CHANGED"] = "|cffffff00Major Faction Renown Level Changed|r",
    ["PERKS_ACTIVITY_COMPLETED"] = "|cffffff00Perks Activity Completed|r",
    ["PET_BATTLE_LEVEL_CHANGED"] = "|cffffff00Pet Battle Level Changed|r",
    ["HONOR_LEVEL_UPDATE"] = "|cffffff00Honor Level Updated|r",
    ["ACHIEVEMENT_EARNED"] = "|cffffff00Achievement Earned|r",
    ["DEBUG_MODE_ENABLED"] = "|cff00ff00Debug Mode Enabled|r",
    ["DEBUG_MODE_DISABLED"] = "|cffff0000Debug Mode Disabled|r",
    ["SELECTING_RANDOM_SOUND_ID"] = "|cffffff00Selecting Random Sound ID|r",
    ["RANDOM_SOUND_ID_SELECTED"] = "|cffffff00Random Sound ID Selected: %s|r",
    ["SELECTING_SOUND"] = "|cffffff00Selecting Sound ID: %s|r",
    ["USING_RANDOM_SOUND_ID"] = "|cffffff00Using Random Sound ID: %s|r",
    ["USING_SPECIFIED_SOUND_ID"] = "|cffffff00Using Specified Sound ID: %s|r",
    ["PLAYING_SOUND"] = "|cffffff00Playing Sound ID: %s at Volume: %s|r",
    ["VOLUME_LEVEL_ZERO"] = "|cffff0000Volume Level is 0, sound will not play|r",
    ["SOUND_FILE_TO_PLAY"] = "|cffffff00Sound File to Play: %s|r",
}

--=====================================================================================
-- Debug Utility Functions
--=====================================================================================

-- Toggle for enabling or disabling debug mode
local debugMode = false

-- Function to print debug messages based on a key
function BLU:PrintDebugMessage(messageKey, ...)
    if debugMode then
        local message = debugMessages[messageKey]
        if message then
            print(string.format(message, ...))
        else
            print("Unknown debug message key: " .. messageKey)
        end
    end
end

-- Toggle debug mode and print the appropriate message
function BLU:ToggleDebugMode()
    debugMode = not debugMode
    self:PrintDebugMessage(debugMode and "DEBUG_MODE_ENABLED" or "DEBUG_MODE_DISABLED")
end

-- Ensure the debug function from initialization.lua is properly overridden
BLU.PrintDebugMessage = BLU.PrintDebugMessage
