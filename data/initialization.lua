--=====================================================================================
-- Initialization
--=====================================================================================

-- Ensure VersionNumber is defined properly
local function InitializeVersionNumber()
    local version = C_AddOns.GetAddOnMetadata("BLU", "Version")
    if version then
        return version
    else
        print("Error: Unable to retrieve VersionNumber")
        return "unknown"
    end
end

-- Initialize the addon
VersionNumber = InitializeVersionNumber()
BLU = LibStub("AceAddon-3.0"):NewAddon("BLU", "AceEvent-3.0", "AceConsole-3.0")

-- Temporarily define a basic debug function for initialization purposes
function BLU:PrintDebugMessage(messageKey, ...)
    local debugMode = self.db.profile.debugMode -- Use profile setting for debug mode
    local debugMessages = {
        ["INITIALIZING_ADDON"] = "Initializing addon.",
        ["GAME_VERSION"] = "Game version detected: %s.",
        ["DB_LOADED"] = "Database loaded.",
        ["OPTIONS_REGISTERED"] = "Options registered.",
        ["EVENTS_REGISTERED"] = "Events registered.",
        ["ERROR_UNKNOWN_GAME_VERSION"] = "Error: Unknown game version detected.",
        -- Add more messages as needed for the initialization phase
    }
    if debugMode then
        local message = debugMessages[messageKey]
        if message then
            print(string.format(message, ...))
        else
            print("Unknown debug message key: " .. messageKey)
        end
    end
end

function BLU:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("BLUDB", self.defaults, true)

    -- Debug log for initialization
    self:PrintDebugMessage("INITIALIZING_ADDON")
    self:PrintDebugMessage("DB_LOADED")

    -- Initialize options based on game version
    self:InitializeOptions()

    -- Register chat commands
    self:RegisterChatCommand("blu", "SlashCommand")

    -- Register shared events
    self:RegisterSharedEvents()
end

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

-- Initialize options based on game version
function BLU:InitializeOptions()
    local version = self:GetGameVersion()

    -- Ensure BLU.options is initialized
    if not BLU.options then
        BLU.options = {}
    end

    if version ~= "retail" then
        self:RemoveOptionsForVersion(version)
    end

    -- Register options
    LibStub("AceConfig-3.0"):RegisterOptionsTable("BLU_Options", BLU.options)
    BLU.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BLU_Options", "Better Level Up!")
    self:PrintDebugMessage("OPTIONS_REGISTERED")

    -- Register profiles
    local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(BLU.db)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("BLU_Profiles", profiles)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BLU_Profiles", "Profiles", "Better Level Up!")
end

function BLU:RemoveOptionsForVersion(version)
    if not BLU.options then
        BLU.options = {}
    end

    BLU.options.args = BLU.options.args or {}
    if version == "vanilla" or version == "cata" then
        BLU.options.args.group3 = nil -- Remove Battle Pet Level-Up
        BLU.options.args.group4 = nil -- Remove Honor Rank-Up
        BLU.options.args.group6 = nil -- Remove Renown Rank-Up
        BLU.options.args.group10 = nil -- Remove Trade Post Activity Complete
        BLU.defaults.profile.BattlePetLevelSoundSelect = nil
        BLU.defaults.profile.HonorSoundSelect = nil
        BLU.defaults.profile.RenownSoundSelect = nil
        BLU.defaults.profile.PostSoundSelect = nil
    end
end

function BLU:RegisterSharedEvents()
    local eventHandlers = {
        "HandlePlayerEnteringWorld",
        "HandlePlayerLevelUp",
        "HandleQuestAccepted",
        "HandleQuestTurnedIn",
        "ReputationChatFrameHook",
    }

    for _, handler in ipairs(eventHandlers) do
        if not self[handler] then
            print("Warning: Method '" .. handler .. "' not found.")
        end
    end

    local version = self:GetGameVersion()

    -- Register events based on version
    if version == "retail" then
        self:RegisterEvent("PLAYER_ENTERING_WORLD", "HandlePlayerEnteringWorld")
        self:RegisterEvent("PLAYER_LEVEL_UP", "HandlePlayerLevelUp")
        self:RegisterEvent("QUEST_ACCEPTED", "HandleQuestAccepted")
        self:RegisterEvent("QUEST_TURNED_IN", "HandleQuestTurnedIn")
        self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", "ReputationChatFrameHook")
    elseif version == "cata" then
        self:RegisterEvent("PLAYER_ENTERING_WORLD", "HandlePlayerEnteringWorld")
        self:RegisterEvent("PLAYER_LEVEL_UP", "HandlePlayerLevelUp")
        self:RegisterEvent("QUEST_ACCEPTED", "HandleQuestAccepted")
        self:RegisterEvent("QUEST_TURNED_IN", "HandleQuestTurnedIn")
        self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", "ReputationChatFrameHook")
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

function BLU:OnEnable()
    self:PrintDebugMessage("ENABLING_ADDON")

    local version = self:GetGameVersion()
    local events = {
        retail = {
            "MAJOR_FACTION_RENOWN_LEVEL_CHANGED",
            "PERKS_ACTIVITY_COMPLETED",
            "PET_BATTLE_LEVEL_CHANGED",
            "ACHIEVEMENT_EARNED",
            "HONOR_LEVEL_UPDATE",
        },
        cata = {
            "ACHIEVEMENT_EARNED",
        },
        vanilla = {
            "ACHIEVEMENT_EARNED", -- Add more Vanilla-specific events if needed
        }
    }

    for _, event in ipairs(events[version] or {}) do
        local methodName = "Handle" .. event:gsub("_", "")
        if self[methodName] then
            self:RegisterEvent(event, methodName)
        else
            print("Warning: Method '" .. methodName .. "' not found.")
        end
    end

    self:PrintDebugMessage("EVENTS_REGISTERED")
end

-- Additional initialization code...
