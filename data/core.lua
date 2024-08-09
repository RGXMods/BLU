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
reputationRanks = {
    "|cff05dffaExalted|r",
    "|cff00ffb3Revered|r",
    "|cff00ff88Honored|r",
    "|cff00e012Friendly|r",
    "|cffffff00Neutral|r",
    "|cffee6621Unfriendly|r",
    "|cffff0000Hostile|r",
    "|cff7d21220Hated|r"
}

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
end

--=====================================================================================
-- Debug Messages
--=====================================================================================
local debugMessages = {
    INITIALIZING_ADDON = "Initializing addon.",
    ENABLING_ADDON = "Enabling addon.",
    PLAYER_ENTERING_WORLD = "|cffffff00PLAYER_ENTERING_WORLD|r event triggered.",
    PLAYER_LEVEL_UP = "|cffffff00PLAYER_LEVEL_UP|r event triggered.",
    QUEST_ACCEPTED = "|cffffff00QUEST_ACCEPTED|r event triggered.",
    QUEST_TURNED_IN = "|cffffff00QUEST_TURNED_IN|r event triggered.",
    REPUTATION_RANK_INCREASE = "|cffffff00REPUTATION_RANK_INCREASE|r event triggered for |cff8080ff%s|r (Rank: |cff8080ff%s|r).",
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
    TEST_POST_SOUND = "|cffc586c0TestPostSound|r triggered."
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
-- Sound Selection Functions
--=====================================================================================

function BLU:RandomSoundID()
    self:PrintDebugMessage("SELECTING_RANDOM_SOUND_ID")

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

    if #validSoundIDs == 0 then
        self:PrintDebugMessage("NO_VALID_SOUND_IDS")
        return nil
    end

    local randomIndex = math.random(1, #validSoundIDs)
    local selectedSoundID = validSoundIDs[randomIndex]

    self:PrintDebugMessage("RANDOM_SOUND_ID_SELECTED", selectedSoundID.id)

    return selectedSoundID
end

function BLU:SelectSound(soundID)
    self:PrintDebugMessage("SELECTING_SOUND", tostring(soundID))

    if not soundID or soundID == 2 then
        local randomSoundID = self:RandomSoundID()
        if randomSoundID then
            self:PrintDebugMessage("USING_RANDOM_SOUND_ID", randomSoundID.id)
            return randomSoundID
        end
    end

    self:PrintDebugMessage("USING_SPECIFIED_SOUND_ID", soundID)
    return {table = sounds, id = soundID}
end

--=====================================================================================
-- Play Selected Sound Function
--=====================================================================================

function BLU:PlaySelectedSound(event, soundSelect, volume)

    self:PrintDebugMessage(event .. "_TRIGGERED")
    
    local sound = self:SelectSound(self.db.profile[soundSelect])
    local volumeLevel = self.db.profile[volume]

    if not sound or not volumeLevel then
        self:PrintDebugMessage("INVALID_PARAMETERS", event)
        return
    end
    
    if volumeLevel == 0 then
        self:PrintDebugMessage("VOLUME_LEVEL_ZERO")
        return
    end

    local soundFile = sound.id == 1 and defaultSounds[sound.id][volumeLevel] or sound.table[sound.id][volumeLevel]

    self:PrintDebugMessage("SOUND_FILE_TO_PLAY", tostring(soundFile))

    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    else
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND", sound.id)
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
    if functionsHalted then return end
    self:PlaySelectedSound("PLAYER_LEVEL_UP", "LevelSoundSelect", "LevelVolume")
end

function BLU:HandleQuestAccepted()
    if functionsHalted then return end
    self:PlaySelectedSound("QUEST_ACCEPTED", "QuestAcceptSoundSelect", "QuestAcceptVolume")
end

function BLU:HandleQuestTurnedIn()
    if functionsHalted then return end
    self:PlaySelectedSound("QUEST_TURNED_IN", "QuestSoundSelect", "QuestVolume")
end

function BLU:ReputationRankIncrease(factionName, newRank)
    if functionsHalted then return end
    self:PrintDebugMessage("REPUTATION_RANK_INCREASE", factionName, newRank)
    self:PlaySelectedSound("REPUTATION_RANK_INCREASE", "RepSoundSelect", "RepVolume")
end

--=====================================================================================
-- Test Sound Functions
--=====================================================================================

function BLU:TestAchievementSound()
    self:PrintDebugMessage("TEST_ACHIEVEMENT_SOUND")
    self:PlaySelectedSound("TEST_ACHIEVEMENT_SOUND", "AchievementSoundSelect", "AchievementVolume")
end

function BLU:TestBattlePetLevelSound()
    self:PrintDebugMessage("TEST_BATTLE_PET_LEVEL_SOUND")
    self:PlaySelectedSound("TEST_BATTLE_PET_LEVEL_SOUND", "BattlePetLevelSoundSelect", "BattlePetLevelVolume")
end

function BLU:TestHonorSound()
    self:PrintDebugMessage("TEST_HONOR_SOUND")
    self:PlaySelectedSound("TEST_HONOR_SOUND", "HonorSoundSelect", "HonorVolume")
end

function BLU:TestLevelSound()
    self:PrintDebugMessage("TEST_LEVEL_SOUND")
    self:PlaySelectedSound("TEST_LEVEL_SOUND", "LevelSoundSelect", "LevelVolume")
end

function BLU:TestRenownSound()
    self:PrintDebugMessage("TEST_RENOWN_SOUND")
    self:PlaySelectedSound("TEST_RENOWN_SOUND", "RenownSoundSelect", "RenownVolume")
end

function BLU:TestRepSound()
    self:PrintDebugMessage("TEST_REP_SOUND")
    self:PlaySelectedSound("TEST_REP_SOUND", "RepSoundSelect", "RepVolume")
end

function BLU:TestQuestAcceptSound()
    self:PrintDebugMessage("TEST_QUEST_ACCEPT_SOUND")
    self:PlaySelectedSound("TEST_QUEST_ACCEPT_SOUND", "QuestAcceptSoundSelect", "QuestAcceptVolume")
end

function BLU:TestQuestSound()
    self:PrintDebugMessage("TEST_QUEST_SOUND")
    self:PlaySelectedSound("TEST_QUEST_SOUND", "QuestSoundSelect", "QuestVolume")
end

function BLU:TestPostSound()
    self:PrintDebugMessage("TEST_POST_SOUND")
    self:PlaySelectedSound("TEST_POST_SOUND", "PostSoundSelect", "PostVolume")
end

--=====================================================================================
-- ChatFrame Hooks
--=====================================================================================

function BLU:ReputationChatFrameHook()
    if not chatFrameHooked then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg)
            for _, rank in ipairs(reputationRanks) do
                local reputationGainPattern = "You are now " .. rank .. " with (.+)%.?"
                local factionName = string.match(msg, reputationGainPattern)
                if factionName then
                    BLU:ReputationRankIncrease(factionName, rank)
                end
            end
            return false
        end)
        chatFrameHooked = true
        self:PrintDebugMessage("REPUTATION_CHAT_FRAME_HOOKED")
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
    self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", "ReputationRankIncrease")
    self:RegisterEvent("CHAT_MSG_SYSTEM", "ReputationChatFrameHook")
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
