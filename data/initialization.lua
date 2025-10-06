--=====================================================================================
-- BLU | Better Level-Up! - initialization.lua
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


BLU_L = BLU_L or {}

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
        self:PrintDebugMessage("ERROR_UNKNOWN_GAME_VERSION") 
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
        CHAT_MSG_SYSTEM = "ReputationChatFrameHook",
    }

    if version == "retail" then
        events.MAJOR_FACTION_RENOWN_LEVEL_CHANGED = "HandleRenownLevelChanged"
        events.PERKS_ACTIVITY_COMPLETED = "HandlePerksActivityCompleted"
        events.ACHIEVEMENT_EARNED = "HandleAchievementEarned"
        events.HONOR_LEVEL_UPDATE = "HandleHonorLevelUpdate"



        -- Battle pet events for retail
        events.UNIT_SPELLCAST_SUCCEEDED = "HandleBattlePetLevelUp"  -- Used for pet battle items
        events.PET_BATTLE_LEVEL_CHANGED = "HandleBattlePetLevelUp"
        events.UNIT_PET_EXPERIENCE = "HandleBattlePetLevelUp"
        events.PET_JOURNAL_LIST_UPDATE = "HandleBattlePetLevelUp"
    elseif version == "cata" then
        events.ACHIEVEMENT_EARNED = "HandleAchievementEarned"
    end

    for event, handler in pairs(events) do
        if type(self[handler]) == "function" then
            self:RegisterEvent(event, handler)
        end
    end
end


--=====================================================================================
-- Initialization, Mute Sounds, and Welcome Message
--=====================================================================================
function BLU:OnInitialize()
    -- Initialize the database with defaults
    self.db = LibStub("AceDB-3.0"):New("BLUDB", self.defaults, true)

    -- Apply default values if they are not set
    for key, value in pairs(self.defaults.profile) do
        if self.db.profile[key] == nil then
            self.db.profile[key] = value
        end
    end

    self.debugMode = self.db.profile.debugMode
    self.showWelcomeMessage = self.db.profile.showWelcomeMessage

    -- Register slash commands and events
    self:RegisterChatCommand("blu", "HandleSlashCommands")
    self:RegisterSharedEvents()

    -- Initialize options
    self:InitializeOptions()
    
    -- Mute sounds based on game version
    local soundsToMute = muteSoundIDs[self:GetGameVersion()]
    if soundsToMute and #soundsToMute > 0 then
        for _, soundID in ipairs(soundsToMute) do
            MuteSoundFile(soundID)
        end
    end

    -- Display the welcome message if enabled
    if self.showWelcomeMessage then
        print(BLU_PREFIX .. BLU_L["WELCOME_MESSAGE"])
        print(BLU_PREFIX .. BLU_L["VERSION"], "|cff8080ff", BLU.VersionNumber)
    end
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

    self.sortedOptions = {}

    -- Remove options based on game version
    if version ~= "retail" then
        self:RemoveOptionsForVersion(version)
    end

    -- Filter out incompatible groups and assign colors
    for _, group in pairs(self.options.args) do
        if self:IsGroupCompatibleWithVersion(group, version) then
            table.insert(self.sortedOptions, group)
        else
            self:PrintDebugMessage("SKIPPING_GROUP_NOT_COMPATIBLE") 
        end
    end

    self:AssignGroupColors()

    if not self.optionsRegistered then
        AC:RegisterOptionsTable("BLU_Options", self.options)
        self.optionsFrame = ACD:AddToBlizOptions("BLU_Options", BLU_L["OPTIONS_LIST_MENU_TITLE"]) 

        local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
        AC:RegisterOptionsTable("BLU_Profiles", profiles)
        ACD:AddToBlizOptions("BLU_Profiles", BLU_L["PROFILES_TITLE"], BLU_L["OPTIONS_LIST_MENU_TITLE"])

        self.optionsRegistered = true
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
                           group.name:match("Renown Rank%-Up!") or
                           group.name:match("Post%-Sound Select")) then
            return false
        end
    elseif version == "vanilla" then
        if group.name and (group.name:match("Achievement") or
                           group.name:match("Honor Rank%-Up!") or
                           group.name:match("Battle Pet Level%-Up!") or
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
        self.db.profile.HonorSoundSelect = nil
        self.db.profile.RenownSoundSelect = nil
        self.db.profile.PostSoundSelect = nil
    elseif version == "cata" then
        args.group3 = nil
        args.group4 = nil
        args.group5 = nil
        args.group9 = nil
        args.group11 = nil
        self.db.profile.BattlePetLevelSoundSelect = nil
        self.db.profile.HonorSoundSelect = nil
        self.db.profile.RenownSoundSelect = nil
        self.db.profile.PostSoundSelect = nil
    end
end

--=====================================================================================
-- Assign Group Colors
--=====================================================================================
function BLU:AssignGroupColors()
    local colors = { BLU_L.optionColor1, BLU_L.optionColor2 } 
    local patternIndex = 1

    if self.sortedOptions and #self.sortedOptions > 0 then
        table.sort(self.sortedOptions, function(a, b) return a.order < b.order end)

        for _, group in ipairs(self.sortedOptions) do
            if group.name and group.args then
                group.name = colors[patternIndex] .. group.name .. "|r"

                for _, arg in pairs(group.args) do
                    if arg.name and arg.name ~= "" then
                        arg.name = colors[patternIndex] .. arg.name .. "|r"
                    end

                    if arg.desc and arg.desc ~= "" then
                        arg.desc = colors[(patternIndex % 2) + 1] .. arg.desc .. "|r"
                    end
                end

                patternIndex = patternIndex % 2 + 1
            end
        end
    end
end
