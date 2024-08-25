--=====================================================================================
-- BLU | Better Level Up! - localization.lua
--=====================================================================================
local colors = {
    prefix = "|cff05dffa",     -- BLU Prefix Color
    debug = "|cff808080",      -- Debug Prefix Color
    success = "|cff00ff00",    -- Success/Enabled/Positive Color
    error = "|cffff0000",      -- Error/Disabled/Negative Color
    highlight = "|cff8080ff",  -- Highlighted Text Color
    info = "|cffffff00",       -- Information/Warning Color
    test = "|cffc586c0",       -- Test Message Color
    sound = "|cffce9178"       -- Sound File Path Color
}

BLU_PREFIX = string.format("[%sBLU|r] ", colors.prefix)
DEBUG_PREFIX = string.format("[%sDEBUG|r] ", colors.debug)

--=====================================================================================
-- Localization Strings
--=====================================================================================
L = {
    -- General Text
    ADDON_DISABLED = string.format("Addon %sdisabled|r.", colors.error),
    ADDON_ENABLED = string.format("Addon %senabled|r.", colors.success),
    SLASH_COMMAND_HELP = string.format("Use %s/blu debug|r to toggle debug mode, %s/blu welcome|r to toggle the welcome message, or %s/blu|r to open options panel.", colors.prefix, colors.prefix, colors.prefix),
    WELCOME_MESSAGE = string.format("%sAddon Loaded!|r Type %s/blu|r to open options panel or %s/blu help|r for more commands.", colors.success, colors.prefix, colors.prefix),
    WELCOME_MESSAGE_DISPLAYED = string.format("Welcome message %sdisplayed|r.", colors.success),
    WELCOME_MSG_ENABLED = string.format("Welcome message %senabled|r.", colors.success),
    WELCOME_MSG_DISABLED = string.format("Welcome message %sdisabled|r.", colors.error),
    DEBUG_MODE_STATUS = "Debug mode %s.",
    DEBUG_MODE_TOGGLED = string.format("Debug mode toggled: %s%%s|r.", colors.highlight),
    SHOW_WELCOME_MESSAGE_TOGGLED = string.format("Welcome message toggled: %s%%s|r.", colors.highlight),
    OPTIONS_REGISTERED = "Options registered successfully.",

    -- Event Messages
    PLAYER_LEVEL_UP = string.format("%sPLAYER_LEVEL_UP|r event triggered.", colors.info),
    QUEST_ACCEPTED = string.format("%sQUEST_ACCEPTED|r event triggered.", colors.info),
    QUEST_TURNED_IN = string.format("%sQUEST_TURNED_IN|r event triggered.", colors.info),
    ACHIEVEMENT_EARNED = string.format("%sACHIEVEMENT_EARNED|r event triggered.", colors.info),
    HONOR_LEVEL_UPDATE = string.format("%sHONOR_LEVEL_UPDATE|r event triggered.", colors.info),
    MAJOR_FACTION_RENOWN_LEVEL_CHANGED = string.format("%sMAJOR_FACTION_RENOWN_LEVEL_CHANGED|r event triggered.", colors.info),
    PET_BATTLE_LEVEL_CHANGED = string.format("%sPET_BATTLE_LEVEL_CHANGED|r event triggered.", colors.info),
    PERKS_ACTIVITY_COMPLETED = string.format("%sPERKS_ACTIVITY_COMPLETED|r event triggered.", colors.info),
    PERKS_ACTIVITY_COMPLETED_MSG = string.format("%sPerks Activity Completed:|r %%s", colors.info),
    PERKS_ACTIVITY_ERROR = string.format("%sError: Activity name not found.|r", colors.error),
    DELVE_LEVEL_UP_DETECTED = string.format("%sDELVE_LEVEL_UP_DETECTED|r event triggered for level: %s%%s|r.", colors.info, colors.success),
    BRANN_LEVEL_FOUND = string.format("%sBrann Bronzebeard has reached Level %%s|r.", colors.info),
    NO_BRANN_LEVEL_FOUND = string.format("%sNo Delve Level found in chat message.|r", colors.error),
    REPUTATION_RANK_INCREASE = string.format("%sREPUTATION_RANK_INCREASE|r event triggered for rank: %s%%s|r.", colors.info, colors.success),

    -- Debug Messages
    FUNCTIONS_HALTED = string.format("Functions halted for %s15|r seconds|r.", colors.highlight),
    FUNCTIONS_RESUMED = string.format("Functions %sresumed|r after pause.", colors.success),
    NO_RANK_FOUND = string.format("%sNo reputation rank increase found in chat message.|r", colors.error),
    NO_VALID_SOUND_IDS = string.format("%sNo valid sound IDs found.|r", colors.error),
    RANDOM_SOUND_ID_SELECTED = string.format("Random sound ID selected: %s%%s|r", colors.highlight),
    SELECTING_SOUND = string.format("Selecting sound with ID: %s%%s|r", colors.highlight),
    USING_RANDOM_SOUND_ID = string.format("Using random sound ID: %s%%s|r", colors.highlight),
    USING_SPECIFIED_SOUND_ID = string.format("Using specified sound ID: %s%%s|r", colors.highlight),
    PLAYING_SOUND = string.format("Playing sound with ID: %s%%s|r and volume level: %s%%s|r", colors.highlight, colors.highlight),
    VOLUME_LEVEL_ZERO = string.format("%sVolume level is %s0|r, sound not played.|r", colors.error, colors.highlight),
    SOUND_FILE_TO_PLAY = string.format("Sound file to play: %s%%s|r", colors.sound),
    ERROR_SOUND_NOT_FOUND = string.format("%sSound file not found for sound ID: %s%%s|r", colors.error, colors.highlight),
    PROCESSING_SLASH_COMMAND = string.format("Processing slash command: %s%%s|r.", colors.highlight),
    UNKNOWN_SLASH_COMMAND = string.format("Unknown slash command: %s%%s|r.", colors.highlight),
    OPTIONS_PANEL_OPENED = string.format("Options panel %sopened|r.", colors.success),
    DEBUG_MODE_DISABLED = string.format("%sdisabled|r", colors.error),
    DEBUG_MODE_ENABLED = string.format("%senabled|r", colors.success),
    ERROR_UNKNOWN_GAME_VERSION = "Unknown game version detected.",
    GAME_VERSION = "Detected game version: %s.",
    MUTING_SOUND = string.format("Muting sound with ID: %s%%s|r", colors.highlight),
    NO_SOUNDS_TO_MUTE = string.format("%sNo sounds to mute for this game version.|r", colors.error),
    ERROR_OPTIONS_NOT_INITIALIZED = string.format("%sOptions not initialized properly.|r", colors.error),
    EVENTS_REGISTERED = "All shared events registered successfully.",
    HALT_TIMER_RUNNING = string.format("Halt timer already running. %sNo new timer started.|r", colors.info),

    -- New Test Sound Debug Messages
    TEST_ACHIEVEMENT_SOUND = string.format("%sTestAchievementSound|r triggered.", colors.test),
    TEST_BATTLE_PET_LEVEL_SOUND = string.format("%sTestBattlePetLevelSound|r triggered.", colors.test),
    TEST_DELVESOUND = string.format("%sTestDelveLevelUpSound|r triggered.", colors.test),
    TEST_HONOR_SOUND = string.format("%sTestHonorSound|r triggered.", colors.test),
    TEST_LEVEL_SOUND = string.format("%sTestLevelSound|r triggered.", colors.test),
    TEST_POST_SOUND = string.format("%sTestPostSound|r triggered.", colors.test),
    TEST_QUEST_ACCEPT_SOUND = string.format("%sTestQuestAcceptSound|r triggered.", colors.test),
    TEST_QUEST_SOUND = string.format("%sTestQuestSound|r triggered.", colors.test),
    TEST_RENOWN_SOUND = string.format("%sTestRenownSound|r triggered.", colors.test),
    TEST_REP_SOUND = string.format("%sTestRepSound|r triggered.", colors.test),
}
