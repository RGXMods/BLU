--=====================================================================================
-- BLU | Better Level-Up! - core.lua
-- Consolidated addon core with version-aware functionality
--=====================================================================================

-- Safely create or get the BLU addon (prevents "already exists" error)
local addonName = "BLU"
BLU = LibStub("AceAddon-3.0"):GetAddon(addonName, true) or LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")
BLU_L = BLU_L or {}

--=====================================================================================
-- Game Version Detection (cached for performance)
--=====================================================================================
local cachedGameVersion = nil

function BLU:GetGameVersion()
    if cachedGameVersion then return cachedGameVersion end
    
    local _, _, _, interfaceVersion = GetBuildInfo()
    
    if interfaceVersion >= 110000 then
        cachedGameVersion = "retail"
    elseif interfaceVersion >= 100000 then
        cachedGameVersion = "retail"
    elseif interfaceVersion >= 50000 and interfaceVersion < 60000 then
        cachedGameVersion = "mists"
    elseif interfaceVersion >= 40000 and interfaceVersion < 50000 then
        cachedGameVersion = "cata"
    elseif interfaceVersion >= 30000 and interfaceVersion < 40000 then
        cachedGameVersion = "wrath"
    elseif interfaceVersion >= 20000 and interfaceVersion < 30000 then
        cachedGameVersion = "tbc"
    elseif interfaceVersion >= 10000 and interfaceVersion < 20000 then
        cachedGameVersion = "vanilla"
    else
        cachedGameVersion = "unknown"
    end
    
    return cachedGameVersion
end

--=====================================================================================
-- Feature Compatibility Tables (single source of truth)
--=====================================================================================
local FEATURE_AVAILABILITY = {
    Achievement = { retail = true, mists = true, cata = true, wrath = true },
    BattlePet = { retail = true, mists = true },
    Honor = { retail = true },
    Delve = { retail = true },
    Renown = { retail = true },
    Post = { retail = true },
    Level = { retail = true, mists = true, cata = true, wrath = true, tbc = true, vanilla = true },
    Quest = { retail = true, mists = true, cata = true, wrath = true, tbc = true, vanilla = true },
    QuestAccept = { retail = true, mists = true, cata = true, wrath = true, tbc = true, vanilla = true },
    Reputation = { retail = true, mists = true, cata = true, wrath = true, tbc = true, vanilla = true },
}

function BLU:IsFeatureAvailable(feature)
    local version = self:GetGameVersion()
    return FEATURE_AVAILABILITY[feature] and FEATURE_AVAILABILITY[feature][version] or false
end

--=====================================================================================
-- Event Registration
--=====================================================================================
function BLU:RegisterSharedEvents()
    local version = self:GetGameVersion()
    
    -- Base events for all versions
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "HandlePlayerEnteringWorld")
    self:RegisterEvent("PLAYER_LEVEL_UP", "HandlePlayerLevelUp")
    self:RegisterEvent("QUEST_ACCEPTED", "HandleQuestAccepted")
    self:RegisterEvent("QUEST_TURNED_IN", "HandleQuestTurnedInAndScanReputation")
    self:RegisterEvent("UPDATE_FACTION", "ScheduleReputationScan")
    
    -- Version-specific events
    if self:IsFeatureAvailable("Achievement") then
        self:RegisterEvent("ACHIEVEMENT_EARNED", "HandleAchievementEarned")
    end
    
    if version == "retail" then
        self:RegisterEvent("HONOR_LEVEL_UPDATE", "HandleHonorLevelUpdate")
        self:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", "HandleRenownLevelChanged")
        self:RegisterEvent("PERKS_ACTIVITY_COMPLETED", "HandlePerksActivityCompleted")
        -- Note: Battle pet events handled by separate battlepets.lua for retail
    end
end

--=====================================================================================
-- Event Handlers
--=====================================================================================
function BLU:HandleQuestTurnedInAndScanReputation()
    self:HandleQuestTurnedIn()
    self:ScheduleReputationScan()
end

function BLU:HandlePlayerLevelUp()
    self:HandleEvent("PLAYER_LEVEL_UP", "LevelSoundSelect", "LevelVolume", defaultSounds and defaultSounds[4], "PLAYER_LEVEL_UP_TRIGGERED")
end

function BLU:HandleQuestAccepted()
    self:HandleEvent("QUEST_ACCEPTED", "QuestAcceptSoundSelect", "QuestAcceptVolume", defaultSounds and defaultSounds[7], "QUEST_ACCEPTED_TRIGGERED")
end

function BLU:HandleQuestTurnedIn()
    self:HandleEvent("QUEST_TURNED_IN", "QuestSoundSelect", "QuestVolume", defaultSounds and defaultSounds[8], "QUEST_TURNED_IN_TRIGGERED")
end

function BLU:HandleAchievementEarned()
    if not self:IsFeatureAvailable("Achievement") then return end
    self:HandleEvent("ACHIEVEMENT_EARNED", "AchievementSoundSelect", "AchievementVolume", defaultSounds and defaultSounds[1], "ACHIEVEMENT_EARNED_TRIGGERED")
end

function BLU:HandleHonorLevelUpdate()
    if not self:IsFeatureAvailable("Honor") then return end
    self:HandleEvent("HONOR_LEVEL_UPDATE", "HonorSoundSelect", "HonorVolume", defaultSounds and defaultSounds[5], "HONOR_LEVEL_UPDATE_TRIGGERED")
end

function BLU:HandleBattlePetLevelUp()
    if not self:IsFeatureAvailable("BattlePet") then return end
    self:HandleEvent("PET_BATTLE_LEVEL_CHANGED", "BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds and defaultSounds[2], "BATTLE_PET_LEVEL_UP_TRIGGERED")
end

function BLU:HandleRenownLevelChanged()
    if not self:IsFeatureAvailable("Renown") then return end
    self:HandleEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", "RenownSoundSelect", "RenownVolume", defaultSounds and defaultSounds[6], "MAJOR_FACTION_RENOWN_LEVEL_CHANGED_TRIGGERED")
end

function BLU:HandlePerksActivityCompleted()
    if not self:IsFeatureAvailable("Post") then return end
    self:HandleEvent("PERKS_ACTIVITY_COMPLETED", "PostSoundSelect", "PostVolume", defaultSounds and defaultSounds[9], "PERKS_ACTIVITY_COMPLETED_TRIGGERED")
end

--=====================================================================================
-- Test Sound Functions
--=====================================================================================
function BLU:TestAchievementSound()
    if not self:IsFeatureAvailable("Achievement") then return end
    self:TestSound("AchievementSoundSelect", "AchievementVolume", defaultSounds and defaultSounds[1], "TEST_ACHIEVEMENT_SOUND")
end

function BLU:TestBattlePetLevelSound()
    if not self:IsFeatureAvailable("BattlePet") then return end
    self:TestSound("BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds and defaultSounds[2], "TEST_BATTLE_PET_LEVEL_SOUND")
end

function BLU:TestDelveLevelUpSound()
    if not self:IsFeatureAvailable("Delve") then return end
    self:TestSound("DelveLevelUpSoundSelect", "DelveLevelUpVolume", defaultSounds and defaultSounds[3], "TEST_DELVE_LEVEL_UP_SOUND")
end

function BLU:TestHonorSound()
    if not self:IsFeatureAvailable("Honor") then return end
    self:TestSound("HonorSoundSelect", "HonorVolume", defaultSounds and defaultSounds[5], "TEST_HONOR_SOUND")
end

function BLU:TestLevelSound()
    self:TestSound("LevelSoundSelect", "LevelVolume", defaultSounds and defaultSounds[4], "TEST_LEVEL_SOUND")
end

function BLU:TestPostSound()
    if not self:IsFeatureAvailable("Post") then return end
    self:TestSound("PostSoundSelect", "PostVolume", defaultSounds and defaultSounds[9], "TEST_POST_SOUND")
end

function BLU:TestQuestAcceptSound()
    self:TestSound("QuestAcceptSoundSelect", "QuestAcceptVolume", defaultSounds and defaultSounds[7], "TEST_QUEST_ACCEPT_SOUND")
end

function BLU:TestQuestSound()
    self:TestSound("QuestSoundSelect", "QuestVolume", defaultSounds and defaultSounds[8], "TEST_QUEST_SOUND")
end

function BLU:TestRenownSound()
    if not self:IsFeatureAvailable("Renown") then return end
    self:TestSound("RenownSoundSelect", "RenownVolume", defaultSounds and defaultSounds[6], "TEST_RENOWN_SOUND")
end

function BLU:TestRepSound()
    self:TestSound("RepSoundSelect", "RepVolume", defaultSounds and defaultSounds[6], "TEST_REP_SOUND")
end

--=====================================================================================
-- Reputation System
--=====================================================================================
local function GetReputationFunctions()
    local GetNumFactions = _G.GetNumFactions or (C_Reputation and C_Reputation.GetNumFactions)
    local GetFactionInfo = _G.GetFactionInfo or (C_Reputation and function(factionIndex)
        if not factionIndex then return nil end
        local factionData = C_Reputation.GetFactionDataByIndex(factionIndex)
        if not factionData then return nil end
        return factionData.name, factionData.description, factionData.reaction, 
               factionData.currentReactionThreshold, factionData.nextReactionThreshold, 
               factionData.currentStanding, factionData.atWarWith, factionData.canToggleAtWar, 
               factionData.isHeader, factionData.isCollapsed, factionData.isHeaderWithRep, 
               factionData.isWatched, factionData.isChild, factionData.factionID, 
               factionData.hasBonusRepGain, factionData.canSetInactive
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
            if standingId and oldStandingId and standingId > oldStandingId then
                self:PrintDebugMessage("Reputation rank-up detected for " .. (name or "Unknown"))
                self:HandleEvent("REPUTATION_RANK_INCREASE", "RepSoundSelect", "RepVolume", defaultSounds and defaultSounds[6], "REPUTATION_RANK_INCREASE_TRIGGERED")
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
-- Options System
--=====================================================================================
-- Map option groups to features for filtering
local OPTION_GROUP_FEATURES = {
    group2 = "Achievement",
    group3 = "BattlePet",
    group4 = "Delve",
    group5 = "Honor",
    group6 = "Level",
    group7 = "QuestAccept",
    group8 = "Quest",
    group9 = "Renown",
    group10 = "Reputation",
    group11 = "Post",
}

function BLU:FilterOptionsForVersion()
    if not self.options or not self.options.args then return end
    
    for groupKey, feature in pairs(OPTION_GROUP_FEATURES) do
        if not self:IsFeatureAvailable(feature) then
            self.options.args[groupKey] = nil
        end
    end
end

function BLU:InitializeOptions()
    local AC = LibStub("AceConfig-3.0")
    local ACD = LibStub("AceConfigDialog-3.0")

    if not self.options or not self.options.args then
        if self.debugMode then
            print(BLU_PREFIX .. "|cffff0000Options table not loaded|r")
        end
        return
    end

    -- Filter options based on game version (single pass)
    self:FilterOptionsForVersion()
    
    -- Build sorted options list and apply colors
    self.sortedOptions = {}
    for _, group in pairs(self.options.args) do
        if group.order then
            table.insert(self.sortedOptions, group)
        end
    end
    
    self:AssignGroupColors()

    if not self.optionsRegistered then
        local optionsTitle = BLU_L["OPTIONS_PANEL_TITLE"] or "BLU | Better Level-Up!"
        local profilesTitle = BLU_L["PROFILES_TITLE"] or "Profiles"
        
        AC:RegisterOptionsTable("BLU_Options", self.options)
        self.optionsFrame = ACD:AddToBlizOptions("BLU_Options", optionsTitle)

        local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
        AC:RegisterOptionsTable("BLU_Profiles", profiles)
        ACD:AddToBlizOptions("BLU_Profiles", profilesTitle, optionsTitle)

        self.optionsRegistered = true
    end
end

function BLU:AssignGroupColors()
    local colors = { 
        BLU_L.optionColor1 or "|cffffffff", 
        BLU_L.optionColor2 or "|cffcccccc" 
    }
    local patternIndex = 1

    if not self.sortedOptions or #self.sortedOptions == 0 then return end
    
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

--=====================================================================================
-- Sound Muting System
--=====================================================================================
function BLU:MuteSounds()
    local version = self:GetGameVersion()
    local soundIDs = muteSoundIDs and muteSoundIDs[version]
    if soundIDs then
        for _, soundID in ipairs(soundIDs) do
            MuteSoundFile(soundID)
        end
    end
end

function BLU:UnmuteSounds()
    local version = self:GetGameVersion()
    local soundIDs = muteSoundIDs and muteSoundIDs[version]
    if soundIDs then
        for _, soundID in ipairs(soundIDs) do
            UnmuteSoundFile(soundID)
        end
    end
end

--=====================================================================================
-- Addon Lifecycle
--=====================================================================================
function BLU:OnInitialize()
    -- Initialize database
    self.db = LibStub("AceDB-3.0"):New("BLUDB", self.defaults, true)

    -- Get version number (API differs between versions)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        self.VersionNumber = C_AddOns.GetAddOnMetadata("BLU", "Version")
    elseif GetAddOnMetadata then
        self.VersionNumber = GetAddOnMetadata("BLU", "Version")
    else
        self.VersionNumber = "Unknown"
    end
    
    -- Initialize character-specific data
    self.db.char.reputationCache = self.db.char.reputationCache or {}
    
    -- Load settings
    self.debugMode = self.db.profile.debugMode or false
    self.showWelcomeMessage = self.db.profile.showWelcomeMessage
    if self.showWelcomeMessage == nil then
        self.showWelcomeMessage = true
        self.db.profile.showWelcomeMessage = true
    end

    -- Initialize state
    self.functionsHalted = false
    self.sortedOptions = {}
    self.optionsRegistered = false
    
    -- Register slash commands
    self:RegisterChatCommand("blu", "HandleSlashCommands")
    
    -- Initialize options panel
    self:InitializeOptions()
end

function BLU:OnEnable()
    self:RegisterSharedEvents()
    self:InitializeReputationCache()
    self:MuteSounds()
    
    if self.showWelcomeMessage then
        local welcomeMsg = BLU_L["WELCOME_MESSAGE"] or "Loaded successfully!"
        local versionText = BLU_L["VERSION"] or "Version:"
        print(BLU_PREFIX .. welcomeMsg)
        print(BLU_PREFIX .. versionText .. " |cff8080ff" .. (self.VersionNumber or "Unknown") .. "|r")
    end
end

function BLU:OnDisable()
    self:UnmuteSounds()
end