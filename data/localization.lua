-- =====================================================================================
-- BLU | Better Level-Up! - localization.lua
-- =====================================================================================
-- Localization in Debug Messages and Non-Debug Messages

-- 1. Debug Messages:
-- PrintDebugMessage automatically looks up keys from BLU.L, 
-- so you don't need to prefix with BLU.L.
-- Example:
-- self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND", tostring(event.soundSelectKey))

-- 2. Non-Debug Messages:
-- Direct print() statements require explicit BLU.L references 
-- since there's no automatic lookup.
-- Example:
-- print(BLU_PREFIX .. BLU.L["UNKNOWN_SLASH_COMMAND"])

-- Debug handling is automatic, non-debug messages need explicit localization references.

BLU = BLU or {}  -- Ensure BLU is defined
BLU_L = BLU_L or {}  -- Ensure the localization table exists

local colors = {
    prefix = "|cff05dffa",      -- BLU Prefix Color
    debug = "|cff808080",       -- Debug Prefix Color
    success = "|cff00ff00",     -- Success/Enabled/Positive Color
    error = "|cffff0000",       -- Error/Disabled/Negative Color
    highlight = "|cff8080ff",   -- Highlighted Text Color
    info = "|cffffff00",        -- Information/Warning Color
    test = "|cffc586c0",        -- Test Message Color
    sound = "|cffce9178",       -- Sound File Path Color
    white = "|cffffffff",       -- White Color
    warning = "|cffffcc00"      -- Warning Color
}

BLU_PREFIX = string.format("|Tinterface/addons/blu/images/icon:16:16|t - [%sBLU|r] ", colors.prefix)
DEBUG_PREFIX = string.format("[%sDEBUG|r] ", colors.debug)

-- =====================================================================================
-- Localization Strings
-- =====================================================================================

BLU_L = {
    -- Option Colors (Cycle with Color Alternation)
    optionColor1 = colors.prefix,
    optionColor2 = colors.white,

    -- Option Labels and Descriptions
    OPTIONS_PANEL_TITLE = string.format("|Tinterface/addons/blu/images/icon:16:16|t - %sBLU|r %s|| %sB|r%setter %sL|r%sevel-%sU|r%sp!",
        colors.prefix, colors.white, colors.prefix, colors.white, colors.prefix, colors.white, colors.prefix, colors.white),

    -- Profiles
    PROFILES_TITLE = "Profiles",

-- =====================================================================================
-- Localization for initialization.lua
-- =====================================================================================
    
    -- BLU:GetGameVersion()
    ERROR_UNKNOWN_GAME_VERSION = string.format("%sUnknown game version detected.|r", colors.error),

    -- BLU:OnInitialize()
    WELCOME_MESSAGE = string.format("Welcome! Use %s/blu|r to open the options panel or %s/blu help|r for more commands.", colors.prefix, colors.prefix),
    VERSION = string.format("%sVersion: %%s|r", colors.info),  -- %%s for placeholder

    -- BLU:InitializeOptions()
    ERROR_OPTIONS_NOT_INITIALIZED = string.format("%sOptions not initialized properly.|r", colors.error),
    SKIPPING_GROUP_NOT_COMPATIBLE = string.format("%sIncompatible or Unnamed Options Group|r", colors.error),
    OPTIONS_LIST_MENU_TITLE = string.format("|Tinterface/addons/blu/images/icon:16:16|t - %sB|r%setter %sL|r%sevel-%sU|r%sp!",
        colors.prefix, colors.white, colors.prefix, colors.white, colors.prefix, colors.white),
    OPTIONS_ALREADY_REGISTERED = string.format("%sOptions already registered.|r", colors.info),

-- =====================================================================================
-- Localization for utils.lua
-- =====================================================================================
    
    -- BLU:ProcessEventQueue()
    ERROR_SOUND_NOT_FOUND = string.format("%sSound not found for sound ID: %%s.|r", colors.error),
    INVALID_VOLUME_LEVEL = string.format("%sInvalid volume level: %%d.|r", colors.error),

    -- BLU:HaltOperations()
    COUNTDOWN_TICK = string.format("%sCountdown: %s%%d%s seconds remaining.|r", colors.info, colors.highlight, colors.info),

    -- BLU:HandleSlashCommands(input)
    OPTIONS_PANEL_OPENED = string.format("Options panel %sopened|r.", colors.success),
    UNKNOWN_SLASH_COMMAND = string.format("Unknown slash command: %%s.|r", colors.highlight),

    -- BLU:DisplayBLUHelp()
    HELP_COMMAND = string.format("%sAvailable commands:|r", colors.info),
    HELP_DEBUG = string.format(" %s/blu debug|r - Toggle debug mode.", colors.prefix),
    HELP_WELCOME = string.format(" %s/blu welcome|r - Toggles the welcome message on/off.", colors.prefix),
    HELP_PANEL = string.format(" %s/blu|r - Open the options panel.", colors.prefix),

    -- BLU:ToggleDebugMode()
    DEBUG_MODE_ENABLED = string.format("%sDebug Mode Enabled|r", colors.success),
    DEBUG_MODE_DISABLED = string.format("%sDebug Mode Disabled|r", colors.error),
    DEBUG_MODE_TOGGLED = string.format("Debug mode toggled: %s%%s|r.", colors.highlight),

    -- BLU:ToggleWelcomeMessage()
    WELCOME_MSG_ENABLED = string.format("Welcome message %senabled|r.", colors.success),
    WELCOME_MSG_DISABLED = string.format("Welcome message %sdisabled|r.", colors.error),
    SHOW_WELCOME_MESSAGE_TOGGLED = string.format("Welcome message toggled: %s%%s|r.", colors.highlight),
    CURRENT_DB_SETTING = string.format("Current DB setting: %%s.|r", colors.info),

    -- BLU:RandomSoundID()
    SELECTING_RANDOM_SOUND = string.format("Selecting Random %sSoundID|r", colors.highlight),
    NO_VALID_SOUND_IDS = string.format("%sNo valid sound IDs found.|r", colors.error),
    RANDOM_SOUND_ID_SELECTED = string.format("Random sound ID selected: %%s.|r", colors.highlight),

    -- BLU:SelectSound()
    SELECTING_SOUND = string.format("Selecting sound with ID: %%s.|r", colors.highlight),
    USING_RANDOM_SOUND_ID = string.format("Using random sound ID: %%s.|r", colors.highlight),
    USING_SPECIFIED_SOUND_ID = string.format("Using specified sound ID: %%s.|r", colors.highlight),

    -- PlaySelectedSound()
    PLAYING_SOUND = string.format("Playing sound with ID: %%s and volume level: %%d.|r", colors.highlight),
    VOLUME_LEVEL_ZERO = string.format("%sVolume level is %s0|r, sound not played.|r", colors.error, colors.highlight),
    SOUND_FILE_TO_PLAY = string.format("Sound file to play: %%s.|r", colors.sound),

-- =====================================================================================
-- Localization for core.lua
-- =====================================================================================
    
    -- BLU:HandlePlayerLevelUp()
    PLAYER_LEVEL_UP_TRIGGERED = string.format("%sPLAYER_LEVEL_UP|r triggered for PetID: %%s | Species: %%s | Level: %%s|r", colors.info),

    -- BLU:HandleQuestAccepted()
    QUEST_ACCEPTED_TRIGGERED = string.format("%sQUEST_ACCEPTED|r triggered for PetID: %%s | Species: %%s | Level: %%s|r", colors.info),

    -- BLU:HandleQuestTurnedIn()
    QUEST_TURNED_IN_TRIGGERED = string.format("%sQUEST_TURNED_IN|r triggered for PetID: %%s | Species: %%s | Level: %%s|r", colors.info),

    -- BLU:HandleAchievementEarned()
    ACHIEVEMENT_EARNED_TRIGGERED = string.format("%sACHIEVEMENT_EARNED|r triggered for PetID: %%s | Species: %%s | Level: %%s|r", colors.info),

    -- BLU:HandleHonorLevelUpdate()
    HONOR_LEVEL_UPDATE_TRIGGERED = string.format("%sHONOR_LEVEL_UPDATE|r triggered for PetID: %%s | Species: %%s | Level: %%s|r", colors.info),

    -- BLU:HandleRenownLevelChanged()
    MAJOR_FACTION_RENOWN_LEVEL_CHANGED_TRIGGERED = string.format("%sMAJOR_FACTION_RENOWN_LEVEL_CHANGED|r triggered for PetID: %%s | Species: %%s | Level: %%s|r", colors.info),

    -- BLU:HandlePerksActivityCompleted()
    PERKS_ACTIVITY_COMPLETED_TRIGGERED = string.format("%sPERKS_ACTIVITY_COMPLETED|r triggered for PetID: %%s | Species: %%s | Level: %%s|r", colors.info),

-- =====================================================================================

    -- BLU:TestAchievementSound()
    TEST_ACHIEVEMENT_SOUND = string.format("%sTestAchievementSound|r triggered.|r", colors.info),
    
    -- BLU:TestBattlePetLevelSound()
    --TEST_BATTLE_PET_LEVEL_SOUND = string.format("%sTestBattlePetLevelSound|r triggered.|r", colors.info),
    
    -- BLU:TestDelveLevelUpSound()
    TEST_DELVE_LEVEL_UP_SOUND = string.format("%sTestDelveLevelUpSound|r triggered.|r", colors.info),
   
    -- BLU:TestHonorSound()
    TEST_HONOR_SOUND = string.format("%sTestHonorSound|r triggered.|r", colors.info),
    
    -- BLU:TestLevelSound()
    TEST_LEVEL_SOUND = string.format("%sTestLevelSound|r triggered.|r", colors.info),
    
    -- BLU:TestPostSound()
    TEST_POST_SOUND = string.format("%sTestPostSound|r triggered.|r", colors.info),
   
    -- BLU:TestQuestAcceptSound()
    TEST_QUEST_ACCEPT_SOUND = string.format("%sTestQuestAcceptSound|r triggered.|r", colors.info),
  
    -- BLU:TestQuestSound()
    TEST_QUEST_SOUND = string.format("%sTestQuestSound|r triggered.|r", colors.info),
    
    -- BLU:TestRenownSound()
    TEST_RENOWN_SOUND = string.format("%sTestRenownSound|r triggered.|r", colors.info),
    
    -- BLU:TestRepSound()
    TEST_REP_SOUND = string.format("%sTestRepSound|r triggered.|r", colors.info),

-- =====================================================================================
    
    -- BLU:ReputationChatFrameHook()
    INCOMING_CHAT_MESSAGE = string.format("%sIncoming chat message: %%s|r", colors.highlight),
    NO_RANK_FOUND = string.format("%sNo reputation rank increase found in chat message.|r", colors.error),
    FUNCTIONS_HALTED = string.format("%sFunctions halted. Event not processed.|r", colors.info),

    -- BLU:ReputationRankIncrease()
    REPUTATION_RANK_TRIGGERED = string.format("Reputation rank increase triggered for rank: %%s|r", colors.info),

    -- BLU:OnDelveCompantionLevelUp(event, ...)
    DELVE_LEVEL_UP = string.format("%sBrann Bronzebeard has reached Level %%s|r", colors.info),
    NO_BRANN_LEVEL_FOUND = string.format("%sNo Delve Level found in chat message.|r", colors.error),

    -- Option Labels and Descriptions for Volume Controls
    ACHIEVEMENT_EARNED = "Achievement Earned!",
    ACHIEVEMENT_VOLUME_LABEL = "Achievement Volume",
    ACHIEVEMENT_VOLUME_DESC = "Adjust the volume for the Achievement Earned! sound.",

    BATTLE_PET_LEVEL_UP = "Battle Pet Level-Up!",
    BATTLE_PET_VOLUME_LABEL = "Battle Pet Volume",
    BATTLE_PET_VOLUME_DESC = "Adjust the volume for the Battle Pet Level-Up! sound.",

    DELVE_COMPANION_LEVEL_UP = "Delve Companion Level-Up!",
    DELVE_VOLUME_LABEL = "Delve Volume",
    DELVE_VOLUME_DESC = "Adjust the volume for the Delve Level-Up! sound.",

    HONOR_RANK_UP = "Honor Rank-Up!",
    HONOR_VOLUME_LABEL = "Honor Volume",
    HONOR_VOLUME_DESC = "Adjust the volume for the Honor Rank-Up! sound.",

    LEVEL_UP = "Level-Up!",
    LEVEL_VOLUME_LABEL = "Level-Up Volume",
    LEVEL_VOLUME_DESC = "Adjust the volume for the Level-Up! sound.",

    QUEST_ACCEPTED = "Quest Accepted!",
    QUEST_ACCEPT_VOLUME_LABEL = "Quest Accept Volume",
    QUEST_ACCEPT_VOLUME_DESC = "Adjust the volume for the Quest Accepted! sound.",
    QUEST_COMPLETE = "Quest Complete!",
    QUEST_COMPLETE_VOLUME_LABEL = "Quest Complete Volume",
    QUEST_COMPLETE_VOLUME_DESC = "Adjust the volume for the Quest Complete! sound.",

    RENOWN_RANK_UP = "Renown Rank-Up!",
    RENOWN_VOLUME_LABEL = "Renown Volume",
    RENOWN_VOLUME_DESC = "Adjust the volume for the Renown Rank-Up! sound.",

    REPUTATION_RANK_UP = "Reputation Rank-Up!",
    REP_VOLUME_LABEL = "Reputation Volume",
    REP_VOLUME_DESC = "Adjust the volume for the Reputation Rank-Up! sound.",

    TRADE_POST_ACTIVITY_COMPLETE = "Trade Post Activity Complete!",
    POST_VOLUME_LABEL = "Trade Post Volume",
    POST_VOLUME_DESC = "Adjust the volume for the Trade Post Activity Complete! sound.",
-- =====================================================================================
-- Localization for battlepets.lua
-- =====================================================================================

    -- BLU:HandlePetLevelUp()
    INVALID_PET_LEVEL = string.format("%sInvalid petID or currentLevel. PetID: %%s, Level: %%s|r", colors.error),
    SKIPPING_LEVEL_UP_DETECTION = string.format("%sSkipping level-up detection during initial data load|r", colors.error),
    PET_LEVEL_UP_TRIGGERED = string.format("%sPET_LEVEL_UP|r triggered for PetID: %%s | Species: %%s | Level: %%s|r", colors.info),
    SOUND_PLAYED = string.format("%sSOUND_PLAYED for PetID: %%s|r", colors.info),
    COOLDOWN_ACTIVE = string.format("%sCooldown active or functions halted for PetID: %%s. No sound played.|r", colors.info),
    NO_LEVEL_UP_DETECTED = string.format("%sNo level-up detected for PetID: %%s | Species: %%s | Level: %%s|r", colors.info),
   
    -- BLU:UpdatePetData()
    PET_JOURNAL_NOT_UNLOCKED = string.format("%sPet Journal is not unlocked, skipping pet data update.|r", colors.info),
    NO_PETS_FOUND = string.format("%sNo pets found, skipping pet data update.|r", colors.info),
    UPDATING_PET_DATA = string.format("%sUpdating pet data for %%s pets.|r", colors.info),
    UPDATE_PET_DATA_FAILED = string.format("%sFailed to retrieve pet info for PetID: %%s|r", colors.error),
    UPDATE_PET_DATA_INIT = string.format("%sPet data initialized and previous pet levels stored.|r", colors.info),

    -- BLU:CheckPetJournalForLevelUps()
    SKIPPING_LEVEL_UP_CHECK = string.format("%sSkipping level-up check as initial load is incomplete.|r", colors.info),
    PET_LEVELS_CHECKED = string.format("%sPet levels checked and compared with previous levels.|r", colors.info),

    -- BLU:PLAYER_LOGIN()
    SOUNDS_ENABLED = string.format("%sPet level-up sounds are now enabled.|r", colors.success),
    INIT_LOAD_COMPLETE = string.format("%sTracked Pet Levels Initialized on Login. Sounds halted for 15 seconds.|r", colors.info),
    
    -- BLU:PET_BATTLE_LEVEL_CHANGED
    INVALID_PET_BATTLE_PARAMS = string.format("%sInvalid parameters for PET_BATTLE_LEVEL_CHANGED.|r", colors.error),
    SPECIES_ID_NIL = string.format("%sspeciesID is nil for PetID: %%s|r", colors.error),
}