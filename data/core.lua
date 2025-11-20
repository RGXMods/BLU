BLU = LibStub("AceAddon-3.0"):NewAddon("BLU", "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")
BLU_L = BLU_L or {}

function BLU:GetGameVersion()
    local _, _, _, interfaceVersion = GetBuildInfo()

    if interfaceVersion >= 110000 then
        return "retail"
    elseif interfaceVersion >= 100000 and interfaceVersion < 110000 then
        return "retail"
    elseif interfaceVersion >= 50000 and interfaceVersion < 60000 then
        return "mists"
    elseif interfaceVersion >= 40000 and interfaceVersion < 50000 then
        return "cata"
    elseif interfaceVersion >= 30000 and interfaceVersion < 40000 then
        return "wrath"
    elseif interfaceVersion >= 20000 and interfaceVersion < 30000 then
        return "tbc"
    elseif interfaceVersion >= 10000 and interfaceVersion < 20000 then
        return "vanilla"
    else
        self:PrintDebugMessage("ERROR_UNKNOWN_GAME_VERSION: " .. tostring(interfaceVersion))
        return "unknown"
    end
end

function BLU:RegisterSharedEvents()
    local version = self:GetGameVersion()

    local events = {
        PLAYER_ENTERING_WORLD = "HandlePlayerEnteringWorld",
        PLAYER_LEVEL_UP = "HandlePlayerLevelUp",
        QUEST_ACCEPTED = "HandleQuestAccepted",
        QUEST_TURNED_IN = "HandleQuestTurnedInAndScanReputation",
        UPDATE_FACTION = "ScheduleReputationScan",
    }

    if version == "retail" then
        events.ACHIEVEMENT_EARNED = "HandleAchievementEarned"
        events.HONOR_LEVEL_UPDATE = "HandleHonorLevelUpdate"
        events.MAJOR_FACTION_RENOWN_LEVEL_CHANGED = "HandleRenownLevelChanged"
        events.PERKS_ACTIVITY_COMPLETED = "HandlePerksActivityCompleted"
        events.PET_BATTLE_LEVEL_CHANGED = "HandleBattlePetLevelUp"
        events.PET_JOURNAL_LIST_UPDATE = "HandleBattlePetLevelUp"
    elseif version == "mists" then
        events.ACHIEVEMENT_EARNED = "HandleAchievementEarned"
        events.PET_BATTLE_LEVEL_CHANGED = "HandleBattlePetLevelUp"
        events.PET_JOURNAL_LIST_UPDATE = "HandleBattlePetLevelUp"
    elseif version == "cata" or version == "wrath" then
        events.ACHIEVEMENT_EARNED = "HandleAchievementEarned"
    end

    for event, handler in pairs(events) do
        if type(self[handler]) == "function" then
            self:RegisterEvent(event, handler)
        end
    end
end

--=====================================================================================
-- BLU | Better Level-Up! - core.lua
--=====================================================================================

function BLU:HandleQuestTurnedInAndScanReputation()
    self:HandleQuestTurnedIn()
    self:ScheduleReputationScan()
end

function BLU:HandlePlayerLevelUp()
    self:HandleEvent("PLAYER_LEVEL_UP", "LevelSoundSelect", "LevelVolume", defaultSounds[4], "PLAYER_LEVEL_UP_TRIGGERED")
end

function BLU:HandleQuestAccepted()
    self:HandleEvent("QUEST_ACCEPTED", "QuestAcceptSoundSelect", "QuestAcceptVolume", defaultSounds[7], "QUEST_ACCEPTED_TRIGGERED")
end

function BLU:HandleQuestTurnedIn()
    self:HandleEvent("QUEST_TURNED_IN", "QuestSoundSelect", "QuestVolume", defaultSounds[8], "QUEST_TURNED_IN_TRIGGERED")
end

function BLU:HandleAchievementEarned()
    self:HandleEvent("ACHIEVEMENT_EARNED", "AchievementSoundSelect", "AchievementVolume", defaultSounds[1], "ACHIEVEMENT_EARNED_TRIGGERED")
end

function BLU:HandleHonorLevelUpdate()
    self:HandleEvent("HONOR_LEVEL_UPDATE", "HonorSoundSelect", "HonorVolume", defaultSounds[5], "HONOR_LEVEL_UPDATE_TRIGGERED")
end

function BLU:HandleBattlePetLevelUp()
    self:HandleEvent("PET_BATTLE_LEVEL_CHANGED", "BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds[2], "BATTLE_PET_LEVEL_UP_TRIGGERED")
end

function BLU:HandleRenownLevelChanged()
    self:HandleEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", "RenownSoundSelect", "RenownVolume", defaultSounds[6], "MAJOR_FACTION_RENOWN_LEVEL_CHANGED_TRIGGERED")
end

function BLU:HandlePerksActivityCompleted()
    self:HandleEvent("PERKS_ACTIVITY_COMPLETED", "PostSoundSelect", "PostVolume", defaultSounds[9], "PERKS_ACTIVITY_COMPLETED_TRIGGERED")
end

--=====================================================================================
-- Test Sound Trigger Functions
--=====================================================================================
function BLU:TestAchievementSound()
    self:TestSound("AchievementSoundSelect", "AchievementVolume", defaultSounds[1], "TEST_ACHIEVEMENT_SOUND")
end

function BLU:TestBattlePetLevelSound()
    self:TestSound("BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds[2], "TEST_BATTLE_PET_LEVEL_SOUND")
end

function BLU:TestDelveLevelUpSound()
    self:TestSound("DelveLevelUpSoundSelect", "DelveLevelUpVolume", defaultSounds[3], "TEST_DELVE_LEVEL_UP_SOUND")
end

function BLU:TestHonorSound()
    self:TestSound("HonorSoundSelect", "HonorVolume", defaultSounds[5], "TEST_HONOR_SOUND")
end

function BLU:TestLevelSound()
    self:TestSound("LevelSoundSelect", "LevelVolume", defaultSounds[4], "TEST_LEVEL_SOUND")
end

function BLU:TestPostSound()
    self:TestSound("PostSoundSelect", "PostVolume", defaultSounds[9], "TEST_POST_SOUND")
end

function BLU:TestQuestAcceptSound()
    self:TestSound("QuestAcceptSoundSelect", "QuestAcceptVolume", defaultSounds[7], "TEST_QUEST_ACCEPT_SOUND")
end

function BLU:TestQuestSound()
    self:TestSound("QuestSoundSelect", "QuestVolume", defaultSounds[8], "TEST_QUEST_SOUND")
end

function BLU:TestRenownSound()
    self:TestSound("RenownSoundSelect", "RenownVolume", defaultSounds[6], "TEST_RENOWN_SOUND")
end

function BLU:TestRepSound()
    self:TestSound("RepSoundSelect", "RepVolume", defaultSounds[6], "TEST_REP_SOUND")
end

--=====================================================================================
-- Reputation Event Handler
--=====================================================================================
local function GetReputationFunctions()
    local GetNumFactions = _G.GetNumFactions or (C_Reputation and C_Reputation.GetNumFactions)
    local GetFactionInfo = _G.GetFactionInfo or (C_Reputation and function(factionIndex)
        if not factionIndex then return nil end
        local factionData = C_Reputation.GetFactionDataByIndex(factionIndex)
        if not factionData then return nil end
        return factionData.name, factionData.description, factionData.reaction, factionData.currentReactionThreshold, factionData.nextReactionThreshold, factionData.currentStanding, factionData.atWarWith, factionData.canToggleAtWar, factionData.isHeader, factionData.isCollapsed, factionData.isHeaderWithRep, factionData.isWatched, factionData.isChild, factionData.factionID, factionData.hasBonusRepGain, factionData.canSetInactive
    end)
    return GetNumFactions, GetFactionInfo
end

function BLU:InitializeReputationCache()
    local GetNumFactions, GetFactionInfo = GetReputationFunctions()
    if not GetNumFactions then return end

    self.db.char.reputationCache = self.db.char.reputationCache or {}
    for i = 1, GetNumFactions() do
        local name, _, standingId, _, _, _, _, _, _, _, _, _, _, factionID = GetFactionInfo(i)
        if factionID and not self.db.char.reputationCache[factionID] then
            self.db.char.reputationCache[factionID] = {
                name = name,
                standingId = standingId
            }
        end
    end
end

function BLU:ScanForReputationChanges()
    local GetNumFactions, GetFactionInfo = GetReputationFunctions()
    if not GetNumFactions then return end

    if not self.db.char.reputationCache then
        self:InitializeReputationCache()
        return
    end

    for i = 1, GetNumFactions() do
        local name, _, standingId, _, _, _, _, _, _, _, _, _, _, factionID = GetFactionInfo(i)
        if factionID and self.db.char.reputationCache[factionID] then
            local oldStandingId = self.db.char.reputationCache[factionID].standingId
            if standingId > oldStandingId then
                self:PrintDebugMessage("Reputation rank-up detected for " .. name)
                self:HandleEvent("REPUTATION_RANK_INCREASE", "RepSoundSelect", "RepVolume", defaultSounds[6], "REPUTATION_RANK_INCREASE_TRIGGERED")
            end
            self.db.char.reputationCache[factionID].standingId = standingId
        elseif factionID then
             self.db.char.reputationCache[factionID] = {
                name = name,
                standingId = standingId
            }
        end
    end
end

function BLU:ScheduleReputationScan()
    if self.reputationScanTimer then
        self:CancelTimer(self.reputationScanTimer)
    end
    self.reputationScanTimer = self:ScheduleTimer("ScanForReputationChanges", 1)
end

--=====================================================================================
-- Delve Level-Up Event Handler
--=====================================================================================
function BLU:OnDelveCompanionLevelUp(event, ...)
    if self:GetGameVersion() == "retail" then return end
    self:PrintDebugMessage(event .. " event fired, awaiting CHAT_MSG_SYSTEM for confirmation.")

    if event == "CHAT_MSG_SYSTEM" then
        local msg = ...
        self:PrintDebugMessage("INCOMING_CHAT_MESSAGE: " .. msg)

        local levelUpMatch = string.match(msg, "Brann Bronzebeard has reached Level (%d+)")
        if levelUpMatch then
            local level = tonumber(levelUpMatch)
            self:PrintDebugMessage("|cff00ff00Brann Level-Up detected: Level " .. level .. "|r")
            self:TriggerDelveLevelUpSound(level)
        else
            self:PrintDebugMessage("NO_LEVEL_FOUND")
        end
    end
end

function BLU:TriggerDelveLevelUpSound(level)
    self:HandleEvent("DELVE_LEVEL_UP", "DelveLevelUpSoundSelect", "DelveLevelUpVolume", defaultSounds[3], "DELVE_LEVEL_UP_TRIGGERED")
end

--=====================================================================================
-- Saved Variables Cleanup for Version Compatibility
--=====================================================================================
function BLU:CleanupIncompatibleSavedVariables(version)
    if version ~= "retail" then
        self.db.profile.HonorSoundSelect = nil
        self.db.profile.HonorVolume = nil
        self.db.profile.DelveLevelUpSoundSelect = nil
        self.db.profile.DelveLevelUpVolume = nil
        self.db.profile.RenownSoundSelect = nil
        self.db.profile.RenownVolume = nil
        self.db.profile.PostSoundSelect = nil
        self.db.profile.PostVolume = nil
        
        if version ~= "mists" then
            self.db.profile.BattlePetLevelSoundSelect = nil
            self.db.profile.BattlePetLevelVolume = nil
        end
    end
    
    if version == "vanilla" or version == "tbc" then
        self.db.profile.AchievementSoundSelect = nil
        self.db.profile.AchievementVolume = nil
    end
end

--=====================================================================================
-- Options Initialization
--=====================================================================================
function BLU:InitializeOptions()
    local AC = LibStub("AceConfig-3.0")
    local ACD = LibStub("AceConfigDialog-3.0")
    local version = self:GetGameVersion()

    if not self.options or not self.options.args then
        self:PrintDebugMessage("ERROR_OPTIONS_NOT_INITIALIZED")
        return
    end

    self.sortedOptions = {}
    self:RemoveOptionsForVersion(version)

    for _, group in pairs(self.options.args) do
        if self:IsGroupCompatibleWithVersion(group, version) then
            table.insert(self.sortedOptions, group)
        else
            self:PrintDebugMessage("SKIPPING_GROUP_NOT_COMPATIBLE") 
        end
    end

    if not self.optionsRegistered then
        self:AssignGroupColors()
        AC:RegisterOptionsTable("BLU_Options", self.options)
        self.optionsFrame = ACD:AddToBlizOptions("BLU_Options", BLU_L["OPTIONS_PANEL_TITLE"]) 

        local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
        AC:RegisterOptionsTable("BLU_Profiles", profiles)
        ACD:AddToBlizOptions("BLU_Profiles", BLU_L["PROFILES_TITLE"], BLU_L["OPTIONS_PANEL_TITLE"])

        self.optionsRegistered = true
    else
        self:PrintDebugMessage("OPTIONS_ALREADY_REGISTERED")
    end
end

function BLU:IsGroupCompatibleWithVersion(group, version)
    if not group or not group.name then return true end
    
    local incompatible = {
        retail = {"Delve", "Reputation"},
        mists = {"Honor", "Delve", "Renown", "Post"},
        cata = {"Battle Pet", "Honor", "Delve", "Renown", "Post"},
        wrath = {"Battle Pet", "Honor", "Delve", "Renown", "Post"},
        tbc = {"Achievement", "Battle Pet", "Honor", "Delve", "Renown", "Post"},
        vanilla = {"Achievement", "Battle Pet", "Honor", "Delve", "Renown", "Post"},
    }
    
    local patterns = incompatible[version] or {}
    for _, pattern in ipairs(patterns) do
        if group.name:match(pattern) then
            return false
        end
    end
    
    return true
end

function BLU:RemoveOptionsForVersion(version)
    local args = self.options.args
    
    local groupsToRemove = {
        vanilla = {"group2", "group3", "group4", "group5", "group9", "group11"},
        tbc = {"group2", "group3", "group4", "group5", "group9", "group11"},
        wrath = {"group3", "group4", "group5", "group9", "group11"},
        cata = {"group3", "group4", "group5", "group9", "group11"},
        mists = {"group4", "group5", "group9", "group11"},
        retail = {"group4", "group10"},
    }
    
    local toRemove = groupsToRemove[version] or {}
    for _, groupName in ipairs(toRemove) do
        args[groupName] = nil
    end
    
    if version ~= "retail" then
        self.db.profile.HonorSoundSelect = nil
        self.db.profile.DelveLevelUpSoundSelect = nil
        self.db.profile.RenownSoundSelect = nil
        self.db.profile.PostSoundSelect = nil
        
        if version ~= "mists" then
            self.db.profile.BattlePetLevelSoundSelect = nil
        end
    end
    
    if version == "vanilla" or version == "tbc" then
        self.db.profile.AchievementSoundSelect = nil
    end
end

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

--=====================================================================================
-- Addon Initialization
--=====================================================================================
function BLU:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("BLUDB", self.defaults, true)

    if C_AddOns and C_AddOns.GetAddOnMetadata then
        self.VersionNumber = C_AddOns.GetAddOnMetadata("BLU", "Version")
    else
        self.VersionNumber = GetAddOnMetadata("BLU", "Version")
    end
    
    local version = self:GetGameVersion()
    self:CleanupIncompatibleSavedVariables(version)
    
    self.db.char.reputationCache = self.db.char.reputationCache or {}
    
    self.debugMode = self.db.profile.debugMode or false
    self.showWelcomeMessage = self.db.profile.showWelcomeMessage
    if self.showWelcomeMessage == nil then
        self.showWelcomeMessage = true
        self.db.profile.showWelcomeMessage = true
    end

    self.functionsHalted = false
    self.sortedOptions = {}
    self.optionsRegistered = false
    
    self:RegisterChatCommand("blu", "HandleSlashCommands")
    self:InitializeOptions()
end

--=====================================================================================
-- Addon Enable/Disable
--=====================================================================================
function BLU:OnEnable()
    self:RegisterSharedEvents()
    self:InitializeReputationCache()
    self:MuteSounds()
    
    if self.showWelcomeMessage then
        print(BLU_PREFIX .. BLU_L["WELCOME_MESSAGE"])
        print(BLU_PREFIX .. BLU_L["VERSION"] .. " " .. self.VersionNumber)
    end
end

function BLU:OnDisable()
    self:UnmuteSounds()
end

function BLU:MuteSounds()
    local version = self:GetGameVersion()
    local soundIDs = muteSoundIDs[version]
    if soundIDs then
        for _, soundID in ipairs(soundIDs) do
            MuteSoundFile(soundID)
        end
    end
end

function BLU:UnmuteSounds()
    local version = self:GetGameVersion()
    local soundIDs = muteSoundIDs[version]
    if soundIDs then
        for _, soundID in ipairs(soundIDs) do
            UnmuteSoundFile(soundID)
        end
    end
end

function BLU:OnDisable()
    self:UnmuteSounds()
end

function BLU:UnmuteSounds()
    local version = self:GetGameVersion()
    local soundIDs = muteSoundIDs[version]
    if soundIDs then
        for _, soundID in ipairs(soundIDs) do
            UnmuteSoundFile(soundID)
        end
    end
end