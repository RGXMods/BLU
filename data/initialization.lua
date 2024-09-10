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
BLU.debugMode = false
BLU.showWelcomeMessage = true
BLU.sortedOptions = {}
BLU.optionsRegistered = false

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
-- Event Registration
--=====================================================================================
function BLU:RegisterSharedEvents()
    local version = self:GetGameVersion()

    local events = {
        PLAYER_ENTERING_WORLD = "HandlePlayerEnteringWorld",
        PLAYER_LEVEL_UP = "HandlePlayerLevelUp",
        QUEST_ACCEPTED = "HandleQuestAccepted",
        QUEST_TURNED_IN = "HandleQuestTurnedIn",
        CHAT_MSG_SYSTEM = "ReputationChatFrameHook", -- Reputation hook
    }

    if version == "retail" then
        events.MAJOR_FACTION_RENOWN_LEVEL_CHANGED = "HandleRenownLevelChanged"
        events.PERKS_ACTIVITY_COMPLETED = "HandlePerksActivityCompleted"
        events.PET_BATTLE_LEVEL_CHANGED = "HandlePetLevelUp"
        events.PET_JOURNAL_LIST_UPDATE = "HandlePetLevelUp"
        events.UNIT_PET_EXPERIENCE = "HandlePetLevelUp"
        events.BAG_UPDATE_DELAYED = "HandlePetLevelUp"
        events.ACHIEVEMENT_EARNED = "HandleAchievementEarned"
        events.HONOR_LEVEL_UPDATE = "HandleHonorLevelUpdate"

        -- Register events for Delve Companion level-up handling
        events.TRAIT_CONFIG_UPDATED = "OnDelveCompanionLevelUp"
        events.UPDATE_FACTION = "OnDelveCompanionLevelUp"
        events.CHAT_MSG_SYSTEM = "OnDelveCompanionLevelUp" -- For Brann level-up system messages
    elseif version == "cata" then
        events.ACHIEVEMENT_EARNED = "HandleAchievementEarned"
    end

    for event, handler in pairs(events) do
        self:RegisterEvent(event, handler)
    end

    self:PrintDebugMessage(L["EVENTS_REGISTERED"])
end

--=====================================================================================
-- Initialization, Mute Sounds, and Display Welcome Message
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
    self:RegisterChatCommand("blu", "HandleSlashCommands")

    -- Register shared events, including chat frame hooks
    self:RegisterSharedEvents()

    -- Initialize and apply colors to options
    self:InitializeOptions()

    -- Debug messages for loaded states
    self:PrintDebugMessage("DEBUG_MODE_LOADED", tostring(self.debugMode))
    self:PrintDebugMessage("SHOW_WELCOME_MESSAGE_LOADED", tostring(self.showWelcomeMessage))

    -- Mute sounds during initialization if needed
    local soundsToMute = muteSoundIDs[self:GetGameVersion()]
    if soundsToMute and #soundsToMute > 0 then
        for _, soundID in ipairs(soundsToMute) do
            MuteSoundFile(soundID)
            self:PrintDebugMessage("MUTING_SOUND", soundID)
        end
    else
        self:PrintDebugMessage("NO_SOUNDS_TO_MUTE")
    end

    -- Display the welcome message if enabled
    if self.showWelcomeMessage then
        print(BLU_PREFIX .. L["WELCOME_MESSAGE"])
        print(BLU_PREFIX .. string.format(L["VERSION"], BLU.VersionNumber))
    end
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
    if version == "retail" then
        return true
    elseif version == "cata" then
        if group.name and (group.name:match("Honor Rank%-Up!") or
                           group.name:match("Battle Pet Level%-Up!") or
                           group.name:match("Delve Companion Level%-Up!") or
                           group.name:match("Renown Rank%-Up!") or
                           group.name:match("Post%-Sound Select")) then
            return false
        end
    elseif version == "vanilla" then
        if group.name and (group.name:match("Achievement") or
                           group.name:match("Honor Rank%-Up!") or
                           group.name:match("Battle Pet Level%-Up!") or
                           group.name:match("Delve Companion Level%-Up!") or
                           group.name:match("Renown Rank%-Up!") or
                           group.name:match("Post%-Sound Select")) then
            return false
        end
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