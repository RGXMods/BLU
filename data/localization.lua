-- localization.lua
--=====================================================================================
-- BLU | Better Level Up! - localization.lua
--=====================================================================================
BLU_PREFIX = "[|cff05dffaBLU|r] "
DEBUG_PREFIX = "[|cff808080DEBUG|r] "

--=====================================================================================
-- 
--=====================================================================================
L = {
    -- General Text
    ADDON_DISABLED = "Addon |cffff0000disabled|r.",
    ADDON_ENABLED = "Addon |cff00ff00enabled|r.",
    SLASH_COMMAND_HELP = "Use |cff05dffa/blu debug|r to toggle debug mode, |cff05dffa/blu welcome|r to toggle the welcome message, or |cff05dffa/blu|r to open options panel.",
    WELCOME_MESSAGE = "|cff00ff00Addon Loaded!|r Type |cff05dffa/blu|r to open options panel or |cff05dffa/blu help|r for more commands.",
    WELCOME_MESSAGE_DISPLAYED = "Welcome message |cff00ff00displayed|r.",
    
    -- Debug Messages
    COUNTDOWN_START = "Starting countdown: |cff8080ff15|r seconds|r remaining.",
    COUNTDOWN_TICK = "|cff8080ff%d|r seconds|r remaining.",
    DEBUG_MODE_DISABLED = "Debug mode |cffff0000disabled|r.",
    DEBUG_MODE_ENABLED = "Debug mode |cff00ff00enabled|r.",
    DEBUG_MODE_LOADED = "Debug mode loaded: |cff8080ff%s|r.",
    DEBUG_MODE_TOGGLED = "Debug mode toggled: |cff8080ff%s|r.",
    DELVE_LEVEL_UP_DETECTED = "|cffffff00DELVE_LEVEL_UP_DETECTED|r event triggered for level: |cff00ff00%s|r.",
    ENABLING_ADDON = "Enabling addon.",
    ERROR_SOUND_NOT_FOUND = "|cffff0000Sound file not found for sound ID: |cff8080ff%s|r",
    FUNCTIONS_HALTED = "Functions halted for |cff8080ff15|r seconds|r.",
    FUNCTIONS_RESUMED = "Functions |cff00ff00resumed|r after pause.",
    INITIALIZING_ADDON = "Initializing addon.",
    INVALID_PARAMETERS = "|cffff0000Invalid parameters for event: |cff8080ff%s|r",
    MAJOR_FACTION_RENOWN_LEVEL_CHANGED = "|cffffff00MAJOR_FACTION_RENOWN_LEVEL_CHANGED|r event triggered.",
    MUTE_SOUND = "Muting sound with ID: |cff8080ff%s|r.",
    NO_RANK_FOUND = "|cffff0000No reputation rank increase found in chat message.|r",
    NO_VALID_SOUND_IDS = "|cffff0000No valid sound IDs found.|r",
    OPTIONS_PANEL_OPENED = "Options panel |cff00ff00opened|r.",
    PERKS_ACTIVITY_COMPLETED = "|cffffff00PERKS_ACTIVITY_COMPLETED|r event triggered.",
    PET_BATTLE_LEVEL_CHANGED = "|cffffff00PET_BATTLE_LEVEL_CHANGED|r event triggered.",
    PLAYER_LEVEL_UP = "|cffffff00PLAYER_LEVEL_UP|r event triggered.",
    PLAYER_LOGIN = "|cffffff00PLAYER_LOGIN|r event triggered.",
    PLAYING_SOUND = "Playing sound with ID: |cff8080ff%s|r and volume level: |cff8080ff%s|r",
    QUEST_ACCEPTED = "|cffffff00QUEST_ACCEPTED|r event triggered.",
    QUEST_TURNED_IN = "|cffffff00QUEST_TURNED_IN|r event triggered.",
    RANDOM_SOUND_ID_SELECTED = "Random sound ID selected: |cff8080ff%s|r",
    REPUTATION_CHAT_FRAME_HOOKED = "Reputation chat frame hooked.",
    REPUTATION_RANK_INCREASE = "|cffffff00REPUTATION_RANK_INCREASE|r event triggered for rank: |cff00ff00%s|r.",
    SELECTING_RANDOM_SOUND_ID = "Selecting a random sound ID...",
    SELECTING_SOUND = "Selecting sound with ID: |cff8080ff%s|r",
    SHOW_WELCOME_MESSAGE_LOADED = "Welcome message setting loaded: |cff8080ff%s|r.",
    SHOW_WELCOME_MESSAGE_TOGGLED = "Welcome message setting toggled: |cff8080ff%s|r.",
    SOUND_FILE_TO_PLAY = "Sound file to play: |cffce9178%s|r",
    TEST_ACHIEVEMENT_SOUND = "|cffc586c0TestAchievementSound|r triggered.",
    TEST_BATTLE_PET_LEVEL_SOUND = "|cffc586c0TestBattlePetLevelSound|r triggered.",
    TEST_DELVESOUND = "|cffc586c0TestDelveLevelUpSound|r triggered.",
    TEST_HONOR_SOUND = "|cffc586c0TestHonorSound|r triggered.",
    TEST_LEVEL_SOUND = "|cffc586c0TestLevelSound|r triggered.",
    TEST_POST_SOUND = "|cffc586c0TestPostSound|r triggered.",
    TEST_QUEST_ACCEPT_SOUND = "|cffc586c0TestQuestAcceptSound|r triggered.",
    TEST_QUEST_SOUND = "|cffc586c0TestQuestSound|r triggered.",
    TEST_RENOWN_SOUND = "|cffc586c0TestRenownSound|r triggered.",
    TEST_REP_SOUND = "|cffc586c0TestRepSound|r triggered.",
    USING_RANDOM_SOUND_ID = "Using random sound ID: |cff8080ff%s|r",
    USING_SPECIFIED_SOUND_ID = "Using specified sound ID: |cff8080ff%s|r",
    VOLUME_LEVEL_ZERO = "|cffff0000Volume level is |cff8080ff0|r, sound not played.|r",

    -- Additional Suggestions
    PROCESSING_SLASH_COMMAND = "Processing slash command: |cff8080ff%s|r.",
    UNKNOWN_SLASH_COMMAND = "Unknown slash command: |cff8080ff%s|r.",
    EVENT_REGISTERED = "Event registered: |cff8080ff%s|r.",
    ERROR_INITIALIZING_ADDON = "|cffff0000Error initializing addon: |cff8080ff%s|r.",
    MUTING_SOUNDS_FOR_VERSION = "Muting sounds for game version: |cff8080ff%s|r.",
}
