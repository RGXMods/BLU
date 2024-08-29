--=====================================================================================
-- BLU | Better Level Up! - initialization.lua
--=====================================================================================
BLU = LibStub("AceAddon-3.0"):NewAddon("BLU", "AceEvent-3.0", "AceConsole-3.0")

--=====================================================================================
-- Version Number
--=====================================================================================
BLU.VersionNumber = C_AddOns.GetAddOnMetadata("BLU", "Version")

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
BLU.sortedOptions = {}
BLU.optionsRegistered = false

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
    elseif input == "help" then
        self:PrintDebugMessage("HELP_COMMAND_RECOGNIZED")
        print(BLU_PREFIX .. L["SLASH_COMMAND_HELP"])
    else
        self:PrintDebugMessage("UNKNOWN_SLASH_COMMAND", input)
        print(BLU_PREFIX .. L["UNKNOWN_SLASH_COMMAND"])
    end
end

function BLU:ToggleDebugMode()
    self.debugMode = not self.debugMode
    self.db.profile.debugMode = self.debugMode
    local status = self.debugMode and BLU_PREFIX .. L["DEBUG_MODE_ENABLED"] or BLU_PREFIX .. L["DEBUG_MODE_DISABLED"]
    print(status)
    self:PrintDebugMessage("DEBUG_MODE_TOGGLED", tostring(self.debugMode))
end

function BLU:ToggleWelcomeMessage()
    -- Toggle the welcome message setting
    self.showWelcomeMessage = not self.showWelcomeMessage
    self.db.profile.showWelcomeMessage = self.showWelcomeMessage

    -- Print out the status to debug
    local status = self.showWelcomeMessage and BLU_PREFIX .. L["WELCOME_MSG_ENABLED"] or BLU_PREFIX .. L["WELCOME_MSG_DISABLED"]
    print(status)
    self:PrintDebugMessage("SHOW_WELCOME_MESSAGE_TOGGLED", tostring(self.showWelcomeMessage))
    self:PrintDebugMessage("Current DB setting: ", tostring(self.db.profile.showWelcomeMessage))
end

--=====================================================================================
-- Game Version Handling
--=====================================================================================
function BLU:GetGameVersion()
    local _, _, _, interfaceVersion = GetBuildInfo()

    if interfaceVersion < 20000 then
        return "vanilla"
    elseif interfaceVersion >= 40000 and interfaceVersion < 50000 then
        return "cata"
    elseif interfaceVersion >= 100000 then
        return "retail"
    else
        self:PrintDebugMessage(L["ERROR_UNKNOWN_GAME_VERSION"])
        return "unknown"
    end
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
    -- Initialize the database with defaults
    self.db = LibStub("AceDB-3.0"):New("BLUDB", self.defaults, true)

    -- Apply default values to the profile if not already set
    for key, value in pairs(self.defaults.profile) do
        if self.db.profile[key] == nil then
            self.db.profile[key] = value
        end
    end

    -- Set initial values from the database or apply defaults
    self.debugMode = self.db.profile.debugMode or false
    self.showWelcomeMessage = self.db.profile.showWelcomeMessage

    -- Register chat commands
    self:RegisterSlashCommands()

    -- Register shared events
    self:RegisterSharedEvents()

    -- Initialize and apply colors to options
    self:InitializeOptions()

    -- Debug messages for loaded states
    self:PrintDebugMessage("DEBUG_MODE_LOADED", tostring(self.debugMode))
    self:PrintDebugMessage("SHOW_WELCOME_MESSAGE_LOADED", tostring(self.showWelcomeMessage))
end

--=====================================================================================
-- Options Initialization
--=====================================================================================
function BLU:InitializeOptions()
    local version = self:GetGameVersion()

    -- Ensure options are available
    if not self.options or not self.options.args then
        self:PrintDebugMessage(L["ERROR_OPTIONS_NOT_INITIALIZED"])
        return
    end

    -- Initialize sortedOptions table
    self.sortedOptions = {}

    -- Remove options based on game version
    if version ~= "retail" then
        self:RemoveOptionsForVersion(version)
    end

    -- Filter out groups based on game version
    for _, group in pairs(self.options.args) do
        if self:IsGroupCompatibleWithVersion(group, version) then
            table.insert(self.sortedOptions, group)
        else
            self:PrintDebugMessage("SKIPPING_GROUP_NOT_COMPATIBLE", group.name or "Unnamed Group")
        end
    end

    -- Apply colors to the options
    self:AssignGroupColors()

    -- Register the options with the system only once
    if not self.optionsRegistered then
        AC:RegisterOptionsTable("BLU_Options", self.options)
        self.optionsFrame = ACD:AddToBlizOptions("BLU_Options", L["OPTIONS_LIST_MENU_TITLE"])

        local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
        AC:RegisterOptionsTable("BLU_Profiles", profiles)
        ACD:AddToBlizOptions("BLU_Profiles", L["PROFILES_TITLE"], L["OPTIONS_LIST_MENU_TITLE"])

        self.optionsRegistered = true
        self:PrintDebugMessage(L["OPTIONS_REGISTERED"])
    else
        self:PrintDebugMessage("OPTIONS_ALREADY_REGISTERED")
    end
end

function BLU:IsGroupCompatibleWithVersion(group, version)
    -- Logic to determine if the group is compatible with the current game version
    if version == "cata" then
        if group.name and (group.name:match("Honor Rank%-Up!") or group.name:match("Battle Pet Level%-Up!") or group.name:match("Delve Companion Level%-Up!")) then
            return false
        end
    elseif version == "vanilla" then
        -- Add conditions for vanilla if necessary
    end
    return true
end

function BLU:RemoveOptionsForVersion(version)
    local args = self.options.args

    if version == "vanilla" then
        args.group2 = nil
        args.group3 = nil
        args.group4 = nil
        args.group5 = nil
        args.group9 = nil
        args.group11 = nil
        self.db.profile.AchievementSoundSelect = nil
        self.db.profile.BattlePetLevelSoundSelect = nil
        self.db.profile.DelveLevelUpSoundSelect = nil
        self.db.profile.HonorSoundSelect = nil
        self.db.profile.RenownSoundSelect = nil
        self.db.profile.PostSoundSelect = nil
        self:PrintDebugMessage(L["VANILLA_OPTIONS_REMOVED"])
    elseif version == "cata" then
        args.group3 = nil
        args.group4 = nil
        args.group5 = nil
        args.group9 = nil
        args.group11 = nil
        self.db.profile.BattlePetLevelSoundSelect = nil
        self.db.profile.DelveLevelUpSoundSelect = nil
        self.db.profile.HonorSoundSelect = nil
        self.db.profile.RenownSoundSelect = nil
        self.db.profile.PostSoundSelect = nil
        self:PrintDebugMessage(L["CATA_OPTIONS_REMOVED"])
    end
end

--=====================================================================================
-- Assign Group Colors
--=====================================================================================
function BLU:AssignGroupColors()
    local colors = { L.optionColor1, L.optionColor2 }  -- Blue, White
    local patternIndex = 1

    -- Sort the groups by their order value
    if self.sortedOptions and #self.sortedOptions > 0 then
        table.sort(self.sortedOptions, function(a, b) return a.order < b.order end)

        for _, group in ipairs(self.sortedOptions) do
            -- Check if the group should be processed
            if group.name and group.args then
                -- Apply color to the group header
                group.name = colors[patternIndex] .. group.name .. "|r"
                self:PrintDebugMessage("GROUP_COLOR_APPLIED", group.name)

                for _, arg in pairs(group.args) do
                    -- Apply color only if the argument has a name and description
                    if arg.name and arg.name ~= "" then
                        arg.name = colors[patternIndex] .. arg.name .. "|r"
                        self:PrintDebugMessage("ARGUMENT_NAME_COLOR_APPLIED", arg.name)
                    else
                        self:PrintDebugMessage("SKIPPING_ARGUMENT_NAME")
                    end

                    if arg.desc and arg.desc ~= "" then
                        arg.desc = colors[(patternIndex % 2) + 1] .. arg.desc .. "|r"
                        self:PrintDebugMessage("DESCRIPTION_COLOR_APPLIED", arg.desc)
                    else
                        self:PrintDebugMessage("SKIPPING_ARGUMENT_DESC")
                    end
                end

                -- Alternate the pattern index for the next group
                patternIndex = patternIndex % 2 + 1
            else
                self:PrintDebugMessage("SKIPPING_GROUP", group.name or "Unnamed Group")
            end
        end
    else
        self:PrintDebugMessage("NO_GROUPS_TO_COLOR")
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
        CHAT_MSG_COMBAT_FACTION_CHANGE = "ReputationChatFrameHook", -- Registering the event
    }

    if version == "retail" then
        events.MAJOR_FACTION_RENOWN_LEVEL_CHANGED = "HandleRenownLevelChanged"
        events.PERKS_ACTIVITY_COMPLETED = "HandlePerksActivityCompleted"
        events.PET_BATTLE_LEVEL_CHANGED = "HandlePetBattleLevelChanged"
        events.ACHIEVEMENT_EARNED = "HandleAchievementEarned"
        events.HONOR_LEVEL_UPDATE = "HandleHonorLevelUpdate"
        events.UPDATE_FACTION = "DelveLevelUpChatFrameHook"
    elseif version == "cata" then
        events.ACHIEVEMENT_EARNED = "HandleAchievementEarned"
        -- Additional event handlers for other versions if necessary
    end

    for event, handler in pairs(events) do
        self:RegisterEvent(event, handler)
    end

    self:PrintDebugMessage(L["EVENTS_REGISTERED"])
end

--=====================================================================================
-- Handle Player Entering World
--=====================================================================================
function BLU:HandlePlayerEnteringWorld()
    if not self.haltTimerRunning then
        self.haltTimerRunning = true
        self.functionsHalted = true
        local countdownTime = 15

        -- Debug message to confirm timer initiation
        self:PrintDebugMessage("HALT_TIMER_STARTED", countdownTime)

        C_Timer.NewTicker(1, function()
            countdownTime = countdownTime - 1
            self:PrintDebugMessage("COUNTDOWN_TICK", countdownTime)
            if countdownTime <= 0 then
                self.functionsHalted = false
                self.haltTimerRunning = false
                self:PrintDebugMessage(L["FUNCTIONS_RESUMED"])
            end
        end, 15)

        self:MuteSounds()

        if self.showWelcomeMessage then
            self:DisplayWelcomeMessage()
        end
    else
        self:PrintDebugMessage(L["HALT_TIMER_RUNNING"])
    end
end

--=====================================================================================
-- Display Welcome Message
--=====================================================================================
function BLU:DisplayWelcomeMessage()
    print(BLU_PREFIX .. L["WELCOME_MESSAGE"])
    self:PrintDebugMessage(L["WELCOME_MESSAGE_DISPLAYED"])
end

--=====================================================================================
-- GetValue and SetValue Methods
--=====================================================================================
function BLU:GetValue(info)
    return self.db.profile[info[#info]]
end

function BLU:SetValue(info, value)
    self.db.profile[info[#info]] = value
end
