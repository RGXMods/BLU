--=====================================================================================
-- BLU Config Module
-- Handles configuration and settings management
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local Config = {}
BLU.Modules["config"] = Config

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
        
        soundVolumes = {
            levelup = "medium",
            achievement = "medium",
            reputation = "medium",
            quest_complete = "medium",
            quest_progress = "medium",
            battlepet = "medium",
            delve = "medium",
            honorrank = "medium",
            renownrank = "medium",
            tradingpost = "medium",
        },
        
        -- Advanced settings
        soundChannel = "Master",
        interruptMusic = false,
        queueSounds = true,
        maxQueueSize = 3
    }
}

-- Profile changed handler
function Config:ApplySettings()
    if not BLU.db or not BLU.db.profile then return end

    BLU.debugMode = BLU.db.profile.debugMode
    BLU.showWelcomeMessage = BLU.db.profile.showWelcomeMessage

    BLU:PrintDebug("Settings applied. Debug mode is: " .. tostring(BLU.debugMode))
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
    -- Simple export without compression for now
    local settings = BLU.db.profile
    -- Convert to string representation
    local str = "BLU_SETTINGS:"
    for k, v in pairs(settings) do
        if type(v) == "string" or type(v) == "number" or type(v) == "boolean" then
            str = str .. k .. "=" .. tostring(v) .. ";"
        end
    end
    return str
end

function Config:ImportSettings(importString)
    -- Simple import for now
    if not importString:match("^BLU_SETTINGS:") then
        return false, "Invalid import string"
    end
    
    -- Parse settings
    local settings = {}
    for k, v in importString:gmatch("(%w+)=([^;]+);") do
        if v == "true" then
            settings[k] = true
        elseif v == "false" then
            settings[k] = false
        elseif tonumber(v) then
            settings[k] = tonumber(v)
        else
            settings[k] = v
        end
    end
    
    -- Apply imported settings
    for key, value in pairs(settings) do
        BLU.db.profile[key] = value
    end
    
    self:ApplySettings()
    if BLU.ReloadAllModules then
        BLU:ReloadAllModules()
    end
    
    return true
end

function Config:MigrateVolumeSettings()
    if not BLU.db or not BLU.db.profile or not BLU.db.profile.soundVolumes then return end

    local volumes = BLU.db.profile.soundVolumes
    for event, value in pairs(volumes) do
        if type(value) == "number" then
            if value <= 0.33 then
                volumes[event] = "low"
            elseif value <= 0.66 then
                volumes[event] = "medium"
            else
                volumes[event] = "high"
            end
            BLU:PrintDebug("Migrated volume setting for " .. event .. " from " .. value .. " to " .. volumes[event])
        end
    end
end

-- Export module
return Config