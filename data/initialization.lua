--=====================================================================================
-- BLU | Better Level-Up! - initialization.lua
--=====================================================================================
BLU = LibStub("AceAddon-3.0"):NewAddon("BLU", "AceEvent-3.0", "AceConsole-3.0")

--=====================================================================================
-- Version Number (API differs between Retail and Classic)
--=====================================================================================
if C_AddOns and C_AddOns.GetAddOnMetadata then
    -- Retail 10.0+ API
    BLU.VersionNumber = C_AddOns.GetAddOnMetadata("BLU", "Version")
else
    -- Classic Era / Classic / older API
    BLU.VersionNumber = GetAddOnMetadata("BLU", "Version")
end

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

    -- Classic Era: 11500-11599 (1.15.x)
    -- Classic/SoD: 11500+ but < 20000
    if interfaceVersion < 20000 then
        return "vanilla"
    -- TBC Classic: 20000-29999
    elseif interfaceVersion >= 20000 and interfaceVersion < 30000 then
        return "tbc"
    -- Wrath Classic: 30000-39999
    elseif interfaceVersion >= 30000 and interfaceVersion < 40000 then
        return "wrath"
    -- Cata Classic: 40000-49999
    elseif interfaceVersion >= 40000 and interfaceVersion < 50000 then
        return "cata"
    -- MoP Remix/Classic: 50000-59999
    elseif interfaceVersion >= 50000 and interfaceVersion < 60000 then
        return "mop"
    -- Retail: 100000+
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

    -- Base events for all versions
    local events = {
        PLAYER_ENTERING_WORLD = "HandlePlayerEnteringWorld",
        PLAYER_LEVEL_UP = "HandlePlayerLevelUp",
        QUEST_ACCEPTED = "HandleQuestAccepted",
        QUEST_TURNED_IN = "HandleQuestTurnedIn",
        CHAT_MSG_SYSTEM = "ReputationChatFrameHook",
    }

    -- Retail-only events
    if version == "retail" then
        events.MAJOR_FACTION_RENOWN_LEVEL_CHANGED = "HandleRenownLevelChanged"
        events.PERKS_ACTIVITY_COMPLETED = "HandlePerksActivityCompleted"
        events.ACHIEVEMENT_EARNED = "HandleAchievementEarned"
        events.HONOR_LEVEL_UPDATE = "HandleHonorLevelUpdate"
        -- Note: Battle pet events are handled by battlepets.lua separately
    
    -- Cata Classic has achievements
    elseif version == "cata" then
        events.ACHIEVEMENT_EARNED = "HandleAchievementEarned"
    
    -- Wrath Classic has achievements
    elseif version == "wrath" then
        events.ACHIEVEMENT_EARNED = "HandleAchievementEarned"
    end
    
    -- Vanilla/Classic Era: Only base events (level, quest, reputation)

    for event, handler in pairs(events) do
        if type(self[handler]) == "function" then
            self:RegisterEvent(event, handler)
        else
            -- Debug: handler function doesn't exist
            if self.debugMode then
                print("|cffff0000BLU Debug:|r Handler missing for " .. event .. ": " .. handler)
            end
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
    local soundsToMute = muteSoundIDs and muteSoundIDs[self:GetGameVersion()]
    if soundsToMute and #soundsToMute > 0 then
        for _, soundID in ipairs(soundsToMute) do
            MuteSoundFile(soundID)
        end
    end

    -- Display the welcome message if enabled
    if self.showWelcomeMessage then
        print(BLU_PREFIX .. (BLU_L["WELCOME_MESSAGE"] or "Welcome to BLU!"))
        print(BLU_PREFIX .. (BLU_L["VERSION"] or "Version:"), "|cff8080ff", BLU.VersionNumber or "Unknown")
    end
end

--=====================================================================================
-- Options Initialization
--=====================================================================================
function BLU:InitializeOptions()
    local version = self:GetGameVersion()

    if not self.options or not self.options.args then
        if self.debugMode then
            print("|cffff0000BLU Debug:|r Options table not initialized yet")
        end
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
        end
    end

    self:AssignGroupColors()

    if not self.optionsRegistered then
        AC:RegisterOptionsTable("BLU_Options", self.options)
        self.optionsFrame = ACD:AddToBlizOptions("BLU_Options", BLU_L["OPTIONS_LIST_MENU_TITLE"] or "BLU") 

        local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
        AC:RegisterOptionsTable("BLU_Profiles", profiles)
        ACD:AddToBlizOptions("BLU_Profiles", BLU_L["PROFILES_TITLE"] or "Profiles", BLU_L["OPTIONS_LIST_MENU_TITLE"] or "BLU")

        self.optionsRegistered = true
    end
end

function BLU:IsGroupCompatibleWithVersion(group, version)
    -- Retail gets everything
    if version == "retail" then
        return true
    end
    
    -- Check group name for version-specific features
    if group.name then
        local name = group.name
        
        -- Features NOT available in Classic Era (vanilla)
        if version == "vanilla" then
            if name:match("Achievement") or
               name:match("Honor") or
               name:match("Battle Pet") or
               name:match("Renown") or
               name:match("Delve") or
               name:match("Trade Post") or
               name:match("Post%-Sound") then
                return false
            end
        end
        
        -- Features NOT available in TBC Classic
        if version == "tbc" then
            if name:match("Achievement") or
               name:match("Battle Pet") or
               name:match("Renown") or
               name:match("Delve") or
               name:match("Trade Post") or
               name:match("Post%-Sound") then
                return false
            end
        end
        
        -- Features NOT available in Wrath Classic
        if version == "wrath" then
            if name:match("Battle Pet") or
               name:match("Renown") or
               name:match("Delve") or
               name:match("Trade Post") or
               name:match("Post%-Sound") then
                return false
            end
        end
        
        -- Features NOT available in Cata Classic
        if version == "cata" then
            if name:match("Battle Pet") or
               name:match("Renown") or
               name:match("Delve") or
               name:match("Trade Post") or
               name:match("Post%-Sound") then
                return false
            end
        end
        
        -- Features NOT available in MoP (has battle pets but not newer features)
        if version == "mop" then
            if name:match("Renown") or
               name:match("Delve") or
               name:match("Trade Post") or
               name:match("Post%-Sound") then
                return false
            end
        end
    end
    
    return true
end

function BLU:RemoveOptionsForVersion(version)
    local args = self.options.args

    if version == "vanilla" then
        -- Classic Era: Only Level, Quest Accept, Quest Complete, Reputation
        args.group2 = nil  -- Achievement
        args.group3 = nil  -- Battle Pet
        args.group4 = nil  -- Delve
        args.group5 = nil  -- Honor
        args.group9 = nil  -- Renown
        args.group11 = nil -- Trade Post
    elseif version == "tbc" then
        -- TBC: Add Honor back
        args.group2 = nil  -- Achievement (added in Wrath)
        args.group3 = nil  -- Battle Pet
        args.group4 = nil  -- Delve
        args.group9 = nil  -- Renown
        args.group11 = nil -- Trade Post
    elseif version == "wrath" then
        -- Wrath: Has Achievements and Honor
        args.group3 = nil  -- Battle Pet
        args.group4 = nil  -- Delve
        args.group9 = nil  -- Renown
        args.group11 = nil -- Trade Post
    elseif version == "cata" then
        -- Cata: Same as Wrath
        args.group3 = nil  -- Battle Pet
        args.group4 = nil  -- Delve
        args.group9 = nil  -- Renown
        args.group11 = nil -- Trade Post
    elseif version == "mop" then
        -- MoP: Has Battle Pets
        args.group4 = nil  -- Delve
        args.group9 = nil  -- Renown
        args.group11 = nil -- Trade Post
    end
end

--=====================================================================================
-- Assign Group Colors
--=====================================================================================
function BLU:AssignGroupColors()
    local colors = { 
        BLU_L.optionColor1 or "|cffffffff", 
        BLU_L.optionColor2 or "|cffcccccc" 
    }
    local patternIndex = 1

    if self.sortedOptions and #self.sortedOptions > 0 then
        table.sort(self.sortedOptions, function(a, b) 
            return (a.order or 0) < (b.order or 0) 
        end)

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