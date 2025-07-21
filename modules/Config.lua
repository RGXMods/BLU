--=====================================================================================
-- BLU Config Module
-- Handles configuration and settings management
--=====================================================================================

local addonName, addonTable = ...
local Config = {}

-- Default configuration
Config.defaults = {
    profile = {
        -- General settings
        showWelcomeMessage = true,
        masterVolume = 0.5,
        debugMode = false,
        
        -- Feature toggles
        enableLevelUp = true,
        enableAchievement = true,
        enableReputation = true,
        enableQuest = true,
        enableBattlePet = true,
        enableDelveCompanion = true,
        enableHonorRank = true,
        enableRenownRank = true,
        enableTradingPost = true,
        
        -- Sound selections (will be populated dynamically)
        levelUpSound = "None",
        achievementSound = "None",
        reputationSound = "None",
        questAcceptSound = "None",
        questTurnInSound = "None",
        battlePetSound = "None",
        delveCompanionSound = "None",
        honorRankSound = "None",
        renownRankSound = "None",
        tradingPostSound = "None",
        
        -- Volume settings
        levelUpVolume = 1.0,
        achievementVolume = 1.0,
        reputationVolume = 1.0,
        questVolume = 1.0,
        battlePetVolume = 1.0,
        delveCompanionVolume = 1.0,
        honorRankVolume = 1.0,
        renownRankVolume = 1.0,
        tradingPostVolume = 1.0,
        
        -- Advanced settings
        soundChannel = "Master",
        interruptMusic = false,
        queueSounds = true,
        maxQueueSize = 3
    }
}

-- Initialize config module
function Config:Init()
    -- Set up saved variables
    self:InitializeDatabase()
    
    -- Apply settings
    self:ApplySettings()
    
    BLU:PrintDebug("Config module initialized")
end

-- Initialize database
function Config:InitializeDatabase()
    local AceDB = LibStub("AceDB-3.0")
    BLU.db = AceDB:New("BLUDB", self.defaults, true)
    
    -- Handle profile changes
    BLU.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    BLU.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    BLU.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
end

-- Profile changed handler
function Config:OnProfileChanged()
    BLU:ReloadAllModules()
    self:ApplySettings()
end

-- Apply current settings
function Config:ApplySettings()
    -- Update debug mode
    BLU.debugMode = BLU.db.profile.debugMode
    
    -- Update welcome message setting
    BLU.showWelcomeMessage = BLU.db.profile.showWelcomeMessage
end

-- Get setting value
function Config:Get(key)
    return BLU.db.profile[key]
end

-- Set setting value
function Config:Set(key, value)
    BLU.db.profile[key] = value
    
    -- Handle special cases
    if key == "debugMode" then
        BLU.debugMode = value
    elseif key:match("^enable") then
        -- Feature toggle changed, update module loading
        local feature = key:gsub("^enable", "")
        feature = feature:sub(1,1):lower() .. feature:sub(2)
        BLU:UpdateModuleLoading(feature, value)
    end
end

-- Get all available sounds for a category
function Config:GetAvailableSounds(category)
    local sounds = {
        {value = "None", text = "None"}
    }
    
    -- Add BLU sounds
    for soundId, soundData in pairs(BLU.soundRegistry or {}) do
        if not soundData.category or soundData.category == category or soundData.category == "all" then
            table.insert(sounds, {
                value = soundId,
                text = soundData.name
            })
        end
    end
    
    -- Sort by name
    table.sort(sounds, function(a, b)
        if a.value == "None" then return true end
        if b.value == "None" then return false end
        return a.text < b.text
    end)
    
    return sounds
end

-- Reset to defaults
function Config:ResetToDefaults()
    BLU.db:ResetProfile()
end

-- Export/Import functionality
function Config:ExportSettings()
    local AceSerializer = LibStub("AceSerializer-3.0")
    local LibDeflate = LibStub("LibDeflate")
    
    local settings = BLU.db.profile
    local serialized = AceSerializer:Serialize(settings)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForPrint(compressed)
    
    return encoded
end

function Config:ImportSettings(importString)
    local AceSerializer = LibStub("AceSerializer-3.0")
    local LibDeflate = LibStub("LibDeflate")
    
    local decoded = LibDeflate:DecodeForPrint(importString)
    if not decoded then return false, "Invalid import string" end
    
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then return false, "Failed to decompress" end
    
    local success, settings = AceSerializer:Deserialize(decompressed)
    if not success then return false, "Failed to deserialize" end
    
    -- Apply imported settings
    for key, value in pairs(settings) do
        BLU.db.profile[key] = value
    end
    
    self:ApplySettings()
    BLU:ReloadAllModules()
    
    return true
end

-- Export module
return Config