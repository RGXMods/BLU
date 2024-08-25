--=====================================================================================
-- BLU | Better Level Up!
--=====================================================================================
BLU = LibStub("AceAddon-3.0"):NewAddon("BLU", "AceEvent-3.0", "AceConsole-3.0")

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
-- Slash Command Registration
--=====================================================================================
function BLU:RegisterSlashCommands()
    self:RegisterChatCommand("blu", "HandleSlashCommands")
end

function BLU:HandleSlashCommands(input)
    if not input or input:trim() == "" then
        -- Correct method to open the options panel
        Settings.OpenToCategory(self.optionsFrame.name)
    elseif input:trim() == "debug" then
        self.debugMode = not self.debugMode
        self:PrintDebugMessage("Debug mode toggled: " .. tostring(self.debugMode))
    elseif input:trim() == "welcome" then
        self.showWelcomeMessage = not self.showWelcomeMessage
        self:Print("Welcome message toggled: " .. tostring(self.showWelcomeMessage))
    else
        self:Print("Unknown command. Type '/blu' for options.")
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
    -- Load saved states
    self.db = LibStub("AceDB-3.0"):New("BLUDB", self.defaults, true)
    self.debugMode = self.db.profile.debugMode or false
    self.showWelcomeMessage = self.db.profile.showWelcomeMessage or true

    -- Register slash commands
    self:RegisterSlashCommands()

    -- Delay getting VersionNumber until PLAYER_LOGIN
    self:RegisterEvent("PLAYER_LOGIN", "OnPlayerLogin")
end

function BLU:OnPlayerLogin()
    -- Initialize options based on game version
    self:InitializeOptions()

    -- Register shared events
    self:RegisterSharedEvents()

    -- Mute sounds based on the game version
    self:MuteSounds()
end

--=====================================================================================
-- Options Initialization
--=====================================================================================
function BLU:InitializeOptions()
    local version = self:GetGameVersion()

    -- Ensure BLU.options is initialized
    if not self.options or not self.options.args then
        self:PrintDebugMessage("ERROR_OPTIONS_NOT_INITIALIZED")
        return
    end

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
-- Handle Player Entering World
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
end -- <<--- Add this missing end statement to close the function properly
