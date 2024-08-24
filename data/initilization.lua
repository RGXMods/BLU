-- initialization.lua
--=====================================================================================
-- BLU | Better Level Up!
--=====================================================================================
BLU = LibStub("AceAddon-3.0"):NewAddon("BLU", "AceEvent-3.0", "AceConsole-3.0")

--=====================================================================================
-- Version Number
--=====================================================================================
local VersionNumber = GetAddOnMetadata("BLU", "Version")

--=====================================================================================
-- Libraries and Variables
--=====================================================================================
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local BLU_PREFIX = "[|cff05dffaBLU|r] "
local DEBUG_PREFIX = "[|cff808080DEBUG|r] "

BLU.functionsHalted = false
BLU.chatFrameHooked = false
BLU.debugMode = false
BLU.showWelcomeMessage = true
BLU.haltTimerRunning = false

--=====================================================================================
-- Utility Functions
--=====================================================================================
function BLU:DebugMessage(message)
    if self.debugMode then
        print(BLU_PREFIX .. DEBUG_PREFIX .. message)
    end
end

function BLU:PrintDebugMessage(key, ...)
    if self.debugMode and L[key] then
        self:DebugMessage(L[key]:format(...))
    end
end

--=====================================================================================
-- Game Version Handling
--=====================================================================================
function BLU:GetGameVersion()
    local version
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        version = "retail"
    elseif WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
        if C_ClassicEra then
            version = "vanilla"
        elseif C_ClassicCataclysm then
            version = "cata"
        end
    else
        version = "unknown"
        self:PrintDebugMessage("ERROR_UNKNOWN_GAME_VERSION")
    end
    self:PrintDebugMessage("GAME_VERSION", version)
    return version
end

--=====================================================================================
-- Mute Sounds Function
--=====================================================================================
function BLU:MuteSounds()
    local gameVersion = self:GetGameVersion()
    local soundsToMute = muteSoundIDs[gameVersion]

    if not soundsToMute or #soundsToMute == 0 then
        self:PrintDebugMessage("NO_SOUNDS_TO_MUTE")
        return
    end

    for _, soundID in ipairs(soundsToMute) do
        MuteSoundFile(soundID)
        self:PrintDebugMessage("MUTING_SOUND", soundID)
    end
end

--=====================================================================================
-- Initialization
--=====================================================================================
function BLU:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("BLUDB", self.defaults, true)

    -- Load saved states
    self.debugMode = self.db.profile.debugMode or false
    self.showWelcomeMessage = self.db.profile.showWelcomeMessage

    -- Ensure the value is saved if not present (e.g., on first load)
    if self.showWelcomeMessage == nil then
        self.showWelcomeMessage = true  -- Default to true on first load
        self.db.profile.showWelcomeMessage = true
    end

    -- Debug messages for loaded states
    self:PrintDebugMessage("DEBUG_MODE_LOADED", tostring(self.debugMode))
    self:PrintDebugMessage("SHOW_WELCOME_MESSAGE_LOADED", tostring(self.showWelcomeMessage))

    -- Initialize options based on game version
    self:InitializeOptions()

    -- Register chat commands
    self:RegisterChatCommand("blu", "SlashCommand")

    -- Register shared events
    self:RegisterSharedEvents()

    -- Mute sounds based on the game version
    self:MuteSounds()
end

function BLU:InitializeOptions()
    local version = self:GetGameVersion()

    -- Ensure BLU.options is initialized
    self.options = self.options or {}

    if version ~= "retail" then
        self:RemoveOptionsForVersion(version)
    end

    -- Register options
    AC:RegisterOptionsTable("BLU_Options", self.options)
    self.optionsFrame = ACD:AddToBlizOptions("BLU_Options", "Better Level Up!")
    self:PrintDebugMessage("OPTIONS_REGISTERED")

    -- Register profiles
    local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    AC:RegisterOptionsTable("BLU_Profiles", profiles)
    ACD:AddToBlizOptions("BLU_Profiles", "Profiles", "Better Level Up!")
end

function BLU:RemoveOptionsForVersion(version)
    self.options.args = self.options.args or {}
    if version == "vanilla" then
        -- Remove options not applicable to Vanilla
        self.options.args.group2 = nil -- Remove Achievements
        self.options.args.group3 = nil -- Remove Battle Pet Level-Up
        self.options.args.group4 = nil -- Remove Honor Rank-Up
        self.options.args.group9 = nil -- Remove Renown Rank-Up
        self.options.args.group11 = nil -- Remove Trade Post Activity Complete

        -- Remove the associated profile settings for Vanilla
        self.defaults.profile.AchievementSoundSelect = nil
        self.defaults.profile.BattlePetLevelSoundSelect = nil
        self.defaults.profile.HonorSoundSelect = nil
        self.defaults.profile.RenownSoundSelect = nil
        self.defaults.profile.PostSoundSelect = nil
    elseif version == "cata" then
        -- Remove options not applicable to Cataclysm
        self.options.args.group3 = nil -- Remove Battle Pet Level-Up
        self.options.args.group4 = nil -- Remove Honor Rank-Up
        self.options.args.group9 = nil -- Remove Renown Rank-Up
        self.options.args.group11 = nil -- Remove Trade Post Activity Complete

        -- Remove the associated profile settings for Cataclysm
        self.defaults.profile.BattlePetLevelSoundSelect = nil
        self.defaults.profile.HonorSoundSelect = nil
        self.defaults.profile.RenownSoundSelect = nil
        self.defaults.profile.PostSoundSelect = nil
    end
end

--=====================================================================================
-- Event Registration
--=====================================================================================
function BLU:RegisterSharedEvents()
    local version = self:GetGameVersion()

    -- Register events based on version
    if version == "retail" then
        self:RegisterEvent("PLAYER_ENTERING_WORLD", "HandlePlayerEnteringWorld")
        self:RegisterEvent("PLAYER_LEVEL_UP", "HandlePlayerLevelUp")
        self:RegisterEvent("QUEST_ACCEPTED", "HandleQuestAccepted")
        self:RegisterEvent("QUEST_TURNED_IN", "HandleQuestTurnedIn")
        self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", "ReputationChatFrameHook")
        self:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", "HandleRenownLevelChanged")
        self:RegisterEvent("PERKS_ACTIVITY_COMPLETED", "HandlePerksActivityCompleted")
        self:RegisterEvent("PET_BATTLE_LEVEL_CHANGED", "HandlePetBattleLevelChanged")
        self:RegisterEvent("ACHIEVEMENT_EARNED", "HandleAchievementEarned")
        self:RegisterEvent("HONOR_LEVEL_UPDATE", "HandleHonorLevelUpdate")
        self:RegisterEvent("UPDATE_FACTION", "HandleUpdateFaction")
    elseif version == "cata" then
        self:RegisterEvent("PLAYER_ENTERING_WORLD", "HandlePlayerEnteringWorld")
        self:RegisterEvent("PLAYER_LEVEL_UP", "HandlePlayerLevelUp")
        self:RegisterEvent("QUEST_ACCEPTED", "HandleQuestAccepted")
        self:RegisterEvent("QUEST_TURNED_IN", "HandleQuestTurnedIn")
        self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", "ReputationChatFrameHook")
        self:RegisterEvent("ACHIEVEMENT_EARNED", "HandleAchievementEarned")
    elseif version == "vanilla" then
        -- Vanilla-specific events (if any)
        self:RegisterEvent("PLAYER_ENTERING_WORLD", "HandlePlayerEnteringWorld")
        self:RegisterEvent("PLAYER_LEVEL_UP", "HandlePlayerLevelUp")
        self:RegisterEvent("QUEST_ACCEPTED", "HandleQuestAccepted")
        self:RegisterEvent("QUEST_TURNED_IN", "HandleQuestTurnedIn")
        self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", "ReputationChatFrameHook")
    end

    self:PrintDebugMessage("EVENTS_REGISTERED")
end

--=====================================================================================
-- HandlePlayerEnteringWorld
--=====================================================================================
function BLU:HandlePlayerEnteringWorld(...)
    if self.haltTimerRunning then
        self:PrintDebugMessage("Halt timer already running. No new timer started.")
        return
    end

    self:PrintDebugMessage("PLAYER_LOGIN")
    self:PrintDebugMessage("COUNTDOWN_START")
    local countdownTime = 15
    self.functionsHalted = true
    self.haltTimerRunning = true -- Mark the timer as running

    C_Timer.NewTicker(1, function()
        countdownTime = countdownTime - 1
        self:PrintDebugMessage("COUNTDOWN_TICK", countdownTime)

        if countdownTime <= 0 then
            self.functionsHalted = false
            self.haltTimerRunning = false -- Reset the flag when the timer ends
            self:PrintDebugMessage("FUNCTIONS_RESUMED")
        end
    end, 15)

    -- Mute sounds based on the game version
    self:PrintDebugMessage("MUTING_SOUNDS_FOR_VERSION", self:GetGameVersion())
    self:MuteSounds()

    -- Check the welcome message setting before displaying
    if self.showWelcomeMessage then
        self:PrintDebugMessage("WELCOME_MESSAGE_DISPLAYED")
        self:DisplayWelcomeMessage()
    end
end

--=====================================================================================
-- Slash Command
--=====================================================================================
function BLU:SlashCommand(input)
    self:PrintDebugMessage("PROCESSING_SLASH_COMMAND", input)

    if input == "debug" then
        self.debugMode = not self.debugMode
        self.db.profile.debugMode = self.debugMode
        self:PrintDebugMessage("DEBUG_MODE_TOGGLED", tostring(self.debugMode))
        local status = self.debugMode and "DEBUG_MODE_ENABLED" or "DEBUG_MODE_DISABLED"
        self:PrintDebugMessage(status)
    elseif input == "welcome" then
        self.showWelcomeMessage = not self.showWelcomeMessage
        self.db.profile.showWelcomeMessage = self.showWelcomeMessage
        self:PrintDebugMessage("SHOW_WELCOME_MESSAGE_TOGGLED", tostring(self.showWelcomeMessage))
        local status = self.showWelcomeMessage and "|cff00ff00enabled|r" or "|cffff0000disabled|r"
        print(BLU_PREFIX .. "Welcome message " .. status)
    elseif input == "enable" then
        self:Enable()
        self:PrintDebugMessage("ENABLING_ADDON")
        print(BLU_PREFIX .. L["ADDON_ENABLED"])
    elseif input == "disable" then
        self:Disable()
        print(BLU_PREFIX .. L["ADDON_DISABLED"])
    elseif input == "help" then
        print(L["SLASH_COMMAND_HELP"])
    else
        -- Log unknown command
        self:PrintDebugMessage("UNKNOWN_SLASH_COMMAND", input)
        Settings.OpenToCategory(self.optionsFrame.name)
        if self.debugMode then
            self:PrintDebugMessage("OPTIONS_PANEL_OPENED")
        end
    end
end
