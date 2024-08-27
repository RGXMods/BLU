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

BLU.functionsHalted = false
BLU.chatFrameHooked = false
BLU.delveChatFrameHooked = false
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
    input = input:trim():lower()  -- Convert input to lowercase
    if input == "" then
        Settings.OpenToCategory(self.optionsFrame.name)
        if self.debugMode then
            self:PrintDebugMessage("OPTIONS_PANEL_OPENED")
        end
    elseif input == "debug" then
        self:ToggleDebugMode()
    elseif input == "welcome" then
        self:ToggleWelcomeMessage()
    else
        self:PrintDebugMessage("UNKNOWN_SLASH_COMMAND", input)
        print(L["SLASH_COMMAND_HELP"])
    end
end

function BLU:ToggleDebugMode()
    self.debugMode = not self.debugMode
    self.db.profile.debugMode = self.debugMode
    local status = self.debugMode and L["DEBUG_MODE_ENABLED"] or L["DEBUG_MODE_DISABLED"]
    print(status)
    self:PrintDebugMessage("DEBUG_MODE_TOGGLED", tostring(self.debugMode))
end

function BLU:ToggleWelcomeMessage()
    self.showWelcomeMessage = not self.showWelcomeMessage
    self.db.profile.showWelcomeMessage = self.showWelcomeMessage
    local status = self.showWelcomeMessage and L["WELCOME_MSG_ENABLED"] or L["WELCOME_MSG_DISABLED"]
    print(status)
    self:PrintDebugMessage("SHOW_WELCOME_MESSAGE_TOGGLED", tostring(self.showWelcomeMessage))
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
    local soundsToMute = muteSoundIDs[self:GetGameVersion()]

    if soundsToMute and #soundsToMute > 0 then
        for _, soundID in ipairs(soundsToMute) do
            MuteSoundFile(soundID)
            self:PrintDebugMessage("MUTING_SOUND", soundID)
        end
    else
        self:PrintDebugMessage("NO_SOUNDS_TO_MUTE")
    end
end

--=====================================================================================
-- Initialization
--=====================================================================================
function BLU:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("BLUDB", self.defaults, true)
    self.debugMode = self.db.profile.debugMode or false
    self.showWelcomeMessage = self.db.profile.showWelcomeMessage or true

    self:RegisterSlashCommands()
    self:RegisterEvent("PLAYER_LOGIN", "OnPlayerLogin")
end

function BLU:OnPlayerLogin()
    self:InitializeOptions()
    self:RegisterSharedEvents()
    self:MuteSounds()
end

--=====================================================================================
-- Options Initialization
--=====================================================================================
function BLU:InitializeOptions()
    local version = self:GetGameVersion()

    if not self.options or not self.options.args then
        self:PrintDebugMessage("ERROR_OPTIONS_NOT_INITIALIZED")
        return
    end

    if version ~= "retail" then
        self:RemoveOptionsForVersion(version)
    end

    AC:RegisterOptionsTable("BLU_Options", self.options)
    self.optionsFrame = ACD:AddToBlizOptions("BLU_Options", "Better Level Up!")

    local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    AC:RegisterOptionsTable("BLU_Profiles", profiles)
    ACD:AddToBlizOptions("BLU_Profiles", "Profiles", "Better Level Up!")
    self:PrintDebugMessage("OPTIONS_REGISTERED")
end

function BLU:RemoveOptionsForVersion(version)
    if version == "vanilla" then
        self.options.args.group2 = nil
        self.options.args.group3 = nil
        self.options.args.group4 = nil
        self.options.args.group9 = nil
        self.options.args.group11 = nil
    elseif version == "cata" then
        self.options.args.group3 = nil
        self.options.args.group4 = nil
        self.options.args.group9 = nil
        self.options.args.group11 = nil
    end
end

--=====================================================================================
-- Event Registration
--=====================================================================================
function BLU:RegisterSharedEvents()
    local version = self:GetGameVersion()

    local events = {
        PLAYER_ENTERING_WORLD = "HandlePlayerEnteringWorld",
        PLAYER_LEVEL_UP = "HandlePlayerLevelUp",
        QUEST_ACCEPTED = "HandleQuestAccepted",
        QUEST_TURNED_IN = "HandleQuestTurnedIn",
        CHAT_MSG_COMBAT_FACTION_CHANGE = "ReputationChatFrameHook"
    }

    if version == "retail" then
        events.MAJOR_FACTION_RENOWN_LEVEL_CHANGED = "HandleRenownLevelChanged"
        events.PERKS_ACTIVITY_COMPLETED = "HandlePerksActivityCompleted"
        events.PET_BATTLE_LEVEL_CHANGED = "HandlePetBattleLevelChanged"
        events.ACHIEVEMENT_EARNED = "HandleAchievementEarned"
        events.HONOR_LEVEL_UPDATE = "HandleHonorLevelUpdate"
    elseif version == "cata" then
        events.ACHIEVEMENT_EARNED = "HandleAchievementEarned"
    end

    for event, handler in pairs(events) do
        self:RegisterEvent(event, handler)
    end

    self:PrintDebugMessage("EVENTS_REGISTERED")
end

--=====================================================================================
-- Handle Player Entering World
--=====================================================================================
function BLU:HandlePlayerEnteringWorld()
    if not self.haltTimerRunning then
        self.haltTimerRunning = true
        self.functionsHalted = true
        local countdownTime = 15

        C_Timer.NewTicker(1, function()
            countdownTime = countdownTime - 1
            self:PrintDebugMessage("COUNTDOWN_TICK", countdownTime)
            if countdownTime <= 0 then
                self.functionsHalted = false
                self.haltTimerRunning = false
                self:PrintDebugMessage("FUNCTIONS_RESUMED")
            end
        end, 15)

        self:MuteSounds()

        if self.showWelcomeMessage then
            self:DisplayWelcomeMessage()
        end
    else
        self:PrintDebugMessage("HALT_TIMER_RUNNING")
    end
end

--=====================================================================================
-- Display Welcome Message
--=====================================================================================
function BLU:DisplayWelcomeMessage()
    print(L["WELCOME_MESSAGE"])
    self:PrintDebugMessage("WELCOME_MESSAGE_DISPLAYED")
end
