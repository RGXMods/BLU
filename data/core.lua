--=====================================================================================
-- BLU | Better Level Up!
--=====================================================================================
BLU = LibStub("AceAddon-3.0"):NewAddon("BLU", "AceEvent-3.0", "AceConsole-3.0")

--=====================================================================================
-- Version Number
--=====================================================================================
VersionNumber = C_AddOns.GetAddOnMetadata("BLU", "Version")

--=====================================================================================
-- Libraries and Variables
--=====================================================================================
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local BLU_PREFIX = "[|cff05dffaBLU|r] "
local DEBUG_PREFIX = "[|cff808080DEBUG|r] "
functionsHalted = false
chatFrameHooked = false
debugMode = false

local L = {
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
    VOLUME_LEVEL_ZERO = "|cffff0000Volume level is |cff8080ff0|r, sound not played.|r"
}

--=====================================================================================
-- Utility Functions
--=====================================================================================
function BLU:DebugMessage(message)
    if debugMode then
        print(BLU_PREFIX .. DEBUG_PREFIX .. message)
    end
end

function BLU:PrintDebugMessage(key, ...)
    if debugMode and L[key] then
        self:DebugMessage(L[key]:format(...))
    end
end

--=====================================================================================
-- Initialization
--=====================================================================================
function BLU:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("BLUDB", self.defaults, true)

    -- Load saved states
    debugMode = self.db.profile.debugMode or false
    showWelcomeMessage = self.db.profile.showWelcomeMessage ~= nil and self.db.profile.showWelcomeMessage or true

    -- Ensure the value is saved
    self.db.profile.showWelcomeMessage = showWelcomeMessage

    -- Debug messages for loaded states
    self:PrintDebugMessage("DEBUG_MODE_LOADED", tostring(debugMode))
    self:PrintDebugMessage("SHOW_WELCOME_MESSAGE_LOADED", tostring(showWelcomeMessage))

    -- Register options
    AC:RegisterOptionsTable("BLU_Options", self.options)
    self.optionsFrame = ACD:AddToBlizOptions("BLU_Options", "Better Level Up!")
    
    local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    AC:RegisterOptionsTable("BLU_Profiles", profiles)
    ACD:AddToBlizOptions("BLU_Profiles", "Profiles", "Better Level Up!")

    -- Register chat commands
    self:RegisterChatCommand("blu", "SlashCommand")

    -- Register shared events
    self:RegisterSharedEvents()
end

--=====================================================================================
-- Display Welcome Message
--=====================================================================================
function BLU:DisplayWelcomeMessage()
    if showWelcomeMessage then
        print(BLU_PREFIX .. L["WELCOME_MESSAGE"])
        self:PrintDebugMessage("WELCOME_MESSAGE_DISPLAYED")
    end
end


--=====================================================================================
-- Event Registration
--=====================================================================================
function BLU:RegisterSharedEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "HandlePlayerEnteringWorld")
    self:RegisterEvent("PLAYER_LEVEL_UP", "HandlePlayerLevelUp")
    self:RegisterEvent("QUEST_ACCEPTED", "HandleQuestAccepted")
    self:RegisterEvent("QUEST_TURNED_IN", "HandleQuestTurnedIn")
    self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", "ReputationChatFrameHook")
end

--=====================================================================================
-- Sound Selection Functions
--=====================================================================================

-- Function to select a random sound ID from available sounds
function RandomSoundID()
    BLU:PrintDebugMessage("SELECTING_RANDOM_SOUND_ID")

    local validSoundIDs = {}

    -- Collect all custom sound IDs
    for soundID, soundList in pairs(sounds) do
        for _, _ in pairs(soundList) do
            table.insert(validSoundIDs, {table = sounds, id = soundID})
        end
    end

    -- Collect all default sound IDs
    for soundID, soundList in pairs(defaultSounds) do
        for _, _ in pairs(soundList) do
            table.insert(validSoundIDs, {table = defaultSounds, id = soundID})
        end
    end

    -- Return nil if no valid sound IDs are found
    if #validSoundIDs == 0 then
        BLU:PrintDebugMessage("NO_VALID_SOUND_IDS")
        return nil
    end

    -- Select a random sound ID from the list
    local randomIndex = math.random(1, #validSoundIDs)
    local selectedSoundID = validSoundIDs[randomIndex]

    BLU:PrintDebugMessage("RANDOM_SOUND_ID_SELECTED", selectedSoundID.id)

    return selectedSoundID
end

--=====================================================================================

-- Function to select a sound based on the provided sound ID
function SelectSound(soundID)
    BLU:PrintDebugMessage("SELECTING_SOUND", tostring(soundID))

    -- If the sound ID is not provided or is set to random (2), return a random sound ID
    if not soundID or soundID == 2 then
        local randomSoundID = RandomSoundID()
        if randomSoundID then
            BLU:PrintDebugMessage("USING_RANDOM_SOUND_ID", randomSoundID.id)
            return randomSoundID
        end
    end

    -- Otherwise, return the specified sound ID
    BLU:PrintDebugMessage("USING_SPECIFIED_SOUND_ID", soundID)
    return {table = sounds, id = soundID}
end

--=====================================================================================
-- Function to play the selected sound with the specified volume level
function PlaySelectedSound(sound, volumeLevel, defaultTable)
    BLU:PrintDebugMessage("PLAYING_SOUND", sound.id, volumeLevel)

    -- Do not play the sound if the volume level is set to 0
    if volumeLevel == 0 then
        BLU:PrintDebugMessage("VOLUME_LEVEL_ZERO")
        return
    end

    -- Determine the sound file to play based on the sound ID and volume level
    local soundFile = sound.id == 1 and defaultTable[volumeLevel] or sound.table[sound.id][volumeLevel]

    BLU:PrintDebugMessage("SOUND_FILE_TO_PLAY", tostring(soundFile))

    -- Play the sound file using the "MASTER" sound channel
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    else
        BLU:PrintDebugMessage("ERROR_SOUND_NOT_FOUND", sound.id)
    end
end

--=====================================================================================
-- Event Handlers
--=====================================================================================
function BLU:HandlePlayerEnteringWorld(...)
    if haltTimerRunning then
        self:PrintDebugMessage("Halt timer already running. No new timer started.")
        return
    end

    self:PrintDebugMessage("PLAYER_LOGIN")
    self:PrintDebugMessage("COUNTDOWN_START")
    local countdownTime = 15
    functionsHalted = true
    haltTimerRunning = true -- Mark the timer as running

    C_Timer.NewTicker(1, function()
        countdownTime = countdownTime - 1
        self:PrintDebugMessage("COUNTDOWN_TICK", countdownTime)

        if countdownTime <= 0 then
            functionsHalted = false
            haltTimerRunning = false -- Reset the flag when timer ends
            self:PrintDebugMessage("FUNCTIONS_RESUMED")
        end
    end, 15)

    self:MuteSounds()

    -- Check the welcome message setting before displaying
    if showWelcomeMessage then
        self:DisplayWelcomeMessage()
    end
end

function BLU:HandlePlayerLevelUp()
    if functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("PLAYER_LEVEL_UP")
    local sound = SelectSound(self.db.profile["LevelSoundSelect"])
    PlaySelectedSound(sound, self.db.profile["LevelVolume"], defaultSounds[4])
end

function BLU:HandleQuestAccepted()
    if functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("QUEST_ACCEPTED")
    local sound = SelectSound(self.db.profile["QuestAcceptSoundSelect"])
    PlaySelectedSound(sound, self.db.profile["QuestAcceptVolume"], defaultSounds[7])
end

function BLU:HandleQuestTurnedIn()
    if functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("QUEST_TURNED_IN")
    local sound = SelectSound(self.db.profile["QuestSoundSelect"])
    PlaySelectedSound(sound, self.db.profile["QuestVolume"], defaultSounds[8])
end

--=====================================================================================
-- Display Welcome Message
--=====================================================================================
function BLU:DisplayWelcomeMessage()
    print(BLU_PREFIX .. "Addon Loaded! " .. "|cff00ff00Enjoy your adventure!|r")
    self:PrintDebugMessage("WELCOME_MESSAGE_DISPLAYED")
end

--=====================================================================================
-- ChatFrame Hooks
--=====================================================================================
function BLU:ReputationChatFrameHook()
    -- Ensure this hook is only added once
    if chatFrameHooked then return end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", function(_, _, msg)
        -- Debugging: Print the incoming message for analysis
        BLU:DebugMessage("|cffffff00Incoming chat message:|r " .. msg)

        -- Check for rank in the message and trigger the appropriate sound
        local rankFound = false
        if string.match(msg, "You are now Exalted with") then
            BLU:DebugMessage("|cff00ff00Rank found: Exalted|r")
            BLU:ReputationRankIncrease("Exalted")
            rankFound = true
        elseif string.match(msg, "You are now Revered with") then
            BLU:DebugMessage("|cff00ff00Rank found: Revered|r")
            BLU:ReputationRankIncrease("Revered")
            rankFound = true
        elseif string.match(msg, "You are now Honored with") then
            BLU:DebugMessage("|cff00ff00Rank found: Honored|r")
            BLU:ReputationRankIncrease("Honored")
            rankFound = true
        elseif string.match(msg, "You are now Friendly with") then
            BLU:DebugMessage("|cff00ff00Rank found: Friendly|r")
            BLU:ReputationRankIncrease("Friendly")
            rankFound = true
        elseif string.match(msg, "You are now Neutral with") then
            BLU:DebugMessage("|cff00ff00Rank found: Neutral|r")
            BLU:ReputationRankIncrease("Neutral")
            rankFound = true
        elseif string.match(msg, "You are now Unfriendly with") then
            BLU:DebugMessage("|cff00ff00Rank found: Unfriendly|r")
            BLU:ReputationRankIncrease("Unfriendly")
            rankFound = true
        elseif string.match(msg, "You are now Hostile with") then
            BLU:DebugMessage("|cff00ff00Rank found: Hostile|r")
            BLU:ReputationRankIncrease("Hostile")
            rankFound = true
        elseif string.match(msg, "You are now Hated with") then
            BLU:DebugMessage("|cff00ff00Rank found: Hated|r")
            BLU:ReputationRankIncrease("Hated")
            rankFound = true
        end

        if not rankFound then
            -- If no rank is found, output a debug message
            BLU:PrintDebugMessage("NO_RANK_FOUND")
        end

        -- Ensure the original message is not blocked
        return false
    end)

    -- Set the flag to prevent re-hooking
    chatFrameHooked = true
end

function BLU:ReputationRankIncrease(rank)
    if functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("REPUTATION_RANK_INCREASE", rank)
    local sound = SelectSound(self.db.profile.RepSoundSelect)
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND")
        return
    end
    local volumeLevel = self.db.profile.RepVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[6])
end

--=====================================================================================
-- Test Sound Functions
--=====================================================================================

function BLU:TestAchievementSound()
    self:PrintDebugMessage("TEST_ACHIEVEMENT_SOUND")
    local sound = SelectSound(self.db.profile["AchievementSoundSelect"])
    PlaySelectedSound(sound, self.db.profile["AchievementVolume"], defaultSounds[1])
end

function BLU:TestBattlePetLevelSound()
    self:PrintDebugMessage("TEST_BATTLE_PET_LEVEL_SOUND")
    local sound = SelectSound(self.db.profile["BattlePetLevelSoundSelect"])
    PlaySelectedSound(sound, self.db.profile["BattlePetLevelVolume"], defaultSounds[2])
end

function BLU:TestHonorSound()
    self:PrintDebugMessage("TEST_HONOR_SOUND")
    local sound = SelectSound(self.db.profile["HonorSoundSelect"])
    PlaySelectedSound(sound, self.db.profile["HonorVolume"], defaultSounds[3])
end

function BLU:TestLevelSound()
    self:PrintDebugMessage("TEST_LEVEL_SOUND")
    local sound = SelectSound(self.db.profile["LevelSoundSelect"])
    PlaySelectedSound(sound, self.db.profile["LevelVolume"], defaultSounds[4])
end

function BLU:TestRenownSound()
    self:PrintDebugMessage("TEST_RENOWN_SOUND")
    local sound = SelectSound(self.db.profile["RenownSoundSelect"])
    PlaySelectedSound(sound, self.db.profile["RenownVolume"], defaultSounds[5])
end

function BLU:TestRepSound()
    self:PrintDebugMessage("TEST_REP_SOUND")
    local sound = SelectSound(self.db.profile["RepSoundSelect"])
    PlaySelectedSound(sound, self.db.profile["RepVolume"], defaultSounds[6])
end

function BLU:TestQuestAcceptSound()
    self:PrintDebugMessage("TEST_QUEST_ACCEPT_SOUND")
    local sound = SelectSound(self.db.profile["QuestAcceptSoundSelect"])
    PlaySelectedSound(sound, self.db.profile["QuestAcceptVolume"], defaultSounds[7])
end

function BLU:TestQuestSound()
    self:PrintDebugMessage("TEST_QUEST_SOUND")
    local sound = SelectSound(self.db.profile["QuestSoundSelect"])
    PlaySelectedSound(sound, self.db.profile["QuestVolume"], defaultSounds[8])
end

function BLU:TestPostSound()
    self:PrintDebugMessage("TEST_POST_SOUND")
    local sound = SelectSound(self.db.profile["PostSoundSelect"])
    PlaySelectedSound(sound, self.db.profile["PostVolume"], defaultSounds[9])
end

function BLU:TestDelveLevelUpSound()
    self:PrintDebugMessage("TEST_DELVESOUND")
    local sound = SelectSound(self.db.profile["DelveLevelUpSoundSelect"])
    PlaySelectedSound(sound, self.db.profile["DelveLevelUpVolume"], defaultSounds[6])
end

--=====================================================================================
-- Slash Command
--=====================================================================================
function BLU:SlashCommand(input)
    if input == "debug" then
        debugMode = not debugMode
        self.db.profile.debugMode = debugMode
        self:PrintDebugMessage("DEBUG_MODE_TOGGLED", tostring(debugMode))
        local status = debugMode and "DEBUG_MODE_ENABLED" or "DEBUG_MODE_DISABLED"
        self:PrintDebugMessage(status)
    elseif input == "welcome" then
        showWelcomeMessage = not showWelcomeMessage
        self.db.profile.showWelcomeMessage = showWelcomeMessage
        self:PrintDebugMessage("SHOW_WELCOME_MESSAGE_TOGGLED", tostring(showWelcomeMessage))
        local status = showWelcomeMessage and "|cff00ff00enabled|r" or "|cffff0000disabled|r"
        print(BLU_PREFIX .. "Welcome message " .. status)
    elseif input == "enable" then
        self:Enable()
        print(BLU_PREFIX .. L["ADDON_ENABLED"])
    elseif input == "disable" then
        self:Disable()
        print(BLU_PREFIX .. L["ADDON_DISABLED"])
    elseif input == "help" then
        print(L["SLASH_COMMAND_HELP"])
    else
        Settings.OpenToCategory(self.optionsFrame.name)
        if debugMode then
            self:PrintDebugMessage("OPTIONS_PANEL_OPENED")
        end
    end
end