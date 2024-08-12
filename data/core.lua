--=====================================================================================
-- BLU | Better Level Up!
--=====================================================================================
BLU = LibStub("AceAddon-3.0"):NewAddon("BLU", "AceEvent-3.0", "AceConsole-3.0")

--=====================================================================================
-- Version Number
--=====================================================================================
VersionNumber = C_AddOns.GetAddOnMetadata("BLU", "Version")

--=====================================================================================
-- Libraries
--=====================================================================================
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local BLU_PREFIX = "[|cff05dffaBLU|r] "
local DEBUG_PREFIX = "[|cff808080DEBUG|r] "
functionsHalted = false
chatFrameHooked = false
debugMode = false

--=====================================================================================
-- Debug Messages Table
--=====================================================================================
local debugMessages = {
    INITIALIZING_ADDON = "Initializing addon.",
    ENABLING_ADDON = "Enabling addon.",
    PLAYER_ENTERING_WORLD = "|cffffff00PLAYER_ENTERING_WORLD|r event triggered.",
    PLAYER_LEVEL_UP = "|cffffff00PLAYER_LEVEL_UP|r event triggered.",
    QUEST_ACCEPTED = "|cffffff00QUEST_ACCEPTED|r event triggered.",
    QUEST_TURNED_IN = "|cffffff00QUEST_TURNED_IN|r event triggered.",
    REPUTATION_RANK_INCREASE = "|cffffff00REPUTATION_RANK_INCREASE|r event triggered for rank: |cff00ff00%s|r.",
    MUTE_SOUND = "Muting sound with ID: |cff8080ff%s|r.",
    SOUND_PLAY = "Sound file to play: |cffce9178%s|r.",
    DEBUG_MODE_ENABLED = "Debug mode |cff00e012enabled|r.",
    DEBUG_MODE_DISABLED = "Debug mode |cffff0000disabled|r.",
    ADDON_ENABLED = "Addon |cff00e012enabled|r.",
    ADDON_DISABLED = "Addon |cffff0000disabled|r.",
    OPTIONS_PANEL_OPENED = "Options panel opened.",
    SELECTING_RANDOM_SOUND_ID = "Selecting a random sound ID...",
    NO_VALID_SOUND_IDS = "|cffff0000No valid sound IDs found.|r",
    RANDOM_SOUND_ID_SELECTED = "Random sound ID selected: |cff8080ff%s|r",
    SELECTING_SOUND = "Selecting sound with ID: |cff8080ff%s|r",
    USING_RANDOM_SOUND_ID = "Using random sound ID: |cff8080ff%s|r",
    USING_SPECIFIED_SOUND_ID = "Using specified sound ID: |cff8080ff%s|r",
    PLAYING_SOUND = "Playing sound with ID: |cff8080ff%s|r and volume level: |cff8080ff%s|r",
    VOLUME_LEVEL_ZERO = "|cffff0000Volume level is |cff8080ff0|r, sound not played.|r",
    SOUND_FILE_TO_PLAY = "Sound file to play: |cffce9178%s|r",
    ERROR_SOUND_NOT_FOUND = "|cffff0000Sound file not found for sound ID: |cff8080ff%s|r",
    INVALID_PARAMETERS = "|cffff0000Invalid parameters for event: |cff8080ff%s|r",
    REPUTATION_CHAT_FRAME_HOOKED = "Reputation chat frame hooked.",
    COUNTDOWN_START = "Starting countdown: |cff00ff0015 seconds|r remaining.",
    COUNTDOWN_TICK = "|cff00ff00%d seconds|r remaining.",
    FUNCTIONS_HALTED = "Functions halted for |cff00ff0015 seconds|r.",
    FUNCTIONS_RESUMED = "Functions resumed after pause.",
    TEST_ACHIEVEMENT_SOUND = "|cffc586c0TestAchievementSound|r triggered.",
    TEST_BATTLE_PET_LEVEL_SOUND = "|cffc586c0TestBattlePetLevelSound|r triggered.",
    TEST_HONOR_SOUND = "|cffc586c0TestHonorSound|r triggered.",
    TEST_LEVEL_SOUND = "|cffc586c0TestLevelSound|r triggered.",
    TEST_RENOWN_SOUND = "|cffc586c0TestRenownSound|r triggered.",
    TEST_REP_SOUND = "|cffc586c0TestRepSound|r triggered.",
    TEST_QUEST_ACCEPT_SOUND = "|cffc586c0TestQuestAcceptSound|r triggered.",
    TEST_QUEST_SOUND = "|cffc586c0TestQuestSound|r triggered.",
    TEST_POST_SOUND = "|cffc586c0TestPostSound|r triggered.",
    NO_RANK_FOUND = "|cffff0000No reputation rank increase found in chat message.|r"
}

--=====================================================================================
-- Utility Functions
--=====================================================================================

-- Function to print debug messages
function BLU:DebugMessage(message)
    if debugMode then
        print(BLU_PREFIX .. DEBUG_PREFIX .. message)
    end
end

-- Function to print debug messages based on a key
function BLU:PrintDebugMessage(key, ...)
    if debugMode and debugMessages[key] then
        self:DebugMessage(debugMessages[key]:format(...))
    end
end

--=====================================================================================
-- Initialization
--=====================================================================================
function BLU:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("BLUDB", self.defaults, true)
    
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
    self:PrintDebugMessage("PLAYER_ENTERING_WORLD")

    self:PrintDebugMessage("COUNTDOWN_START")
    local countdownTime = 15
    functionsHalted = true
    C_Timer.NewTicker(1, function()
        countdownTime = countdownTime - 1
        self:PrintDebugMessage("COUNTDOWN_TICK", countdownTime)
    end, 15)

    C_Timer.After(15, function()
        functionsHalted = false
        self:PrintDebugMessage("FUNCTIONS_RESUMED")
    end)

    self:MuteSounds()
end

function BLU:HandlePlayerLevelUp()
    if functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("PLAYER_LEVEL_UP")
    local sound = SelectSound(self.db.profile["LevelSoundSelect"])
    local volumeLevel = self.db.profile["LevelVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[4])
end

function BLU:HandleQuestAccepted()
    if functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("QUEST_ACCEPTED")
    local sound = SelectSound(self.db.profile["QuestAcceptSoundSelect"])
    local volumeLevel = self.db.profile["QuestAcceptVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[7])
end

function BLU:HandleQuestTurnedIn()
    if functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("QUEST_TURNED_IN")
    local sound = SelectSound(self.db.profile["QuestSoundSelect"])
    local volumeLevel = self.db.profile["QuestVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[8])
end

--=====================================================================================
-- ChatFrame Hooks
--=====================================================================================
function BLU:ReputationChatFrameHook()
    if not chatFrameHooked then
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
        chatFrameHooked = true
    end
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
    local volumeLevel = self.db.profile["AchievementVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[1])
end

function BLU:TestBattlePetLevelSound()
    self:PrintDebugMessage("TEST_BATTLE_PET_LEVEL_SOUND")
    local sound = SelectSound(self.db.profile["BattlePetLevelSoundSelect"])
    local volumeLevel = self.db.profile["BattlePetLevelVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[2])
end

function BLU:TestHonorSound()
    self:PrintDebugMessage("TEST_HONOR_SOUND")
    local sound = SelectSound(self.db.profile["HonorSoundSelect"])
    local volumeLevel = self.db.profile["HonorVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[3])
end

function BLU:TestLevelSound()
    self:PrintDebugMessage("TEST_LEVEL_SOUND")
    local sound = SelectSound(self.db.profile["LevelSoundSelect"])
    local volumeLevel = self.db.profile["LevelVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[4])
end

function BLU:TestRenownSound()
    self:PrintDebugMessage("TEST_RENOWN_SOUND")
    local sound = SelectSound(self.db.profile["RenownSoundSelect"])
    local volumeLevel = self.db.profile["RenownVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[5])
end

function BLU:TestRepSound()
    self:PrintDebugMessage("TEST_REP_SOUND")
    local sound = SelectSound(self.db.profile["RepSoundSelect"])
    local volumeLevel = self.db.profile["RepVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[6])
end

function BLU:TestQuestAcceptSound()
    self:PrintDebugMessage("TEST_QUEST_ACCEPT_SOUND")
    local sound = SelectSound(self.db.profile["QuestAcceptSoundSelect"])
    local volumeLevel = self.db.profile["QuestAcceptVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[7])
end

function BLU:TestQuestSound()
    self:PrintDebugMessage("TEST_QUEST_SOUND")
    local sound = SelectSound(self.db.profile["QuestSoundSelect"])
    local volumeLevel = self.db.profile["QuestVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[8])
end

function BLU:TestPostSound()
    self:PrintDebugMessage("TEST_POST_SOUND")
    local sound = SelectSound(self.db.profile["PostSoundSelect"])
    local volumeLevel = self.db.profile["PostVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[9])
end

--=====================================================================================
-- Slash Command
--=====================================================================================

function BLU:SlashCommand(input)
    if input == "debug" then
        if debugMode then
            self:PrintDebugMessage("DEBUG_MODE_DISABLED")
            debugMode = false
        else
            debugMode = true
            self:PrintDebugMessage("DEBUG_MODE_ENABLED")
        end
    elseif input == "enable" then
        self:Enable()
        print(BLU_PREFIX .. debugMessages["ADDON_ENABLED"])
    elseif input == "disable" then
        self:Disable()
        print(BLU_PREFIX .. debugMessages["ADDON_DISABLED"])
    else
        Settings.OpenToCategory(self.optionsFrame.name)
        if debugMode then
            self:PrintDebugMessage("OPTIONS_PANEL_OPENED")
        end
    end
end

-- Register the Slash Command
SLASH_BLUDEBUG1 = "/blu"
SlashCmdList["BLUDEBUG"] = function(msg)
    BLU:SlashCommand(msg)
end
