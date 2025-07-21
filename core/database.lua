--=====================================================================================
-- BLU Database System
-- Simple saved variables management (no external dependencies)
--=====================================================================================

local addonName, addonTable = ...
local Database = {}

-- Default settings
Database.defaults = {
    -- General
    showWelcomeMessage = true,
    debugMode = false,
    masterVolume = 0.5,
    soundChannel = "Master",
    
    -- Features
    enableLevelUp = true,
    enableAchievement = true,
    enableReputation = true,
    enableQuest = true,
    enableBattlePet = true,
    enableDelveCompanion = true,
    enableHonorRank = true,
    enableRenownRank = true,
    enableTradingPost = true,
    
    -- Sounds
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
    
    -- Volumes
    levelUpVolume = 1.0,
    achievementVolume = 1.0,
    reputationVolume = 1.0,
    questVolume = 1.0,
    battlePetVolume = 1.0,
    delveCompanionVolume = 1.0,
    honorRankVolume = 1.0,
    renownRankVolume = 1.0,
    tradingPostVolume = 1.0
}

-- Initialize database
function Database:Init()
    -- Wait for saved variables to load
    BLU:RegisterEvent("VARIABLES_LOADED", function()
        self:LoadSavedVariables()
    end)
end

-- Load saved variables
function Database:LoadSavedVariables()
    -- Initialize saved variables if they don't exist
    if not BLUDB then
        BLUDB = {
            profiles = {
                Default = self:CopyTable(self.defaults)
            },
            currentProfile = "Default"
        }
    end
    
    -- Ensure current profile exists
    if not BLUDB.profiles[BLUDB.currentProfile] then
        BLUDB.currentProfile = "Default"
        if not BLUDB.profiles.Default then
            BLUDB.profiles.Default = self:CopyTable(self.defaults)
        end
    end
    
    -- Create easy access
    BLU.db = BLUDB.profiles[BLUDB.currentProfile]
    
    -- Merge with defaults (in case new settings were added)
    self:MergeDefaults(BLU.db, self.defaults)
    
    BLU:PrintDebug("Database loaded: " .. BLUDB.currentProfile)
end

-- Save settings
function Database:Save()
    -- Settings are automatically saved by WoW
    BLU:PrintDebug("Settings saved")
end

-- Reset profile
function Database:ResetProfile()
    local profile = BLUDB.currentProfile
    BLUDB.profiles[profile] = self:CopyTable(self.defaults)
    BLU.db = BLUDB.profiles[profile]
    BLU:Print("Profile reset to defaults")
end

-- Create new profile
function Database:CreateProfile(name)
    if BLUDB.profiles[name] then
        BLU:PrintError("Profile already exists: " .. name)
        return false
    end
    
    BLUDB.profiles[name] = self:CopyTable(BLU.db)
    BLU:Print("Profile created: " .. name)
    return true
end

-- Delete profile
function Database:DeleteProfile(name)
    if name == "Default" then
        BLU:PrintError("Cannot delete Default profile")
        return false
    end
    
    if name == BLUDB.currentProfile then
        BLU:PrintError("Cannot delete active profile")
        return false
    end
    
    BLUDB.profiles[name] = nil
    BLU:Print("Profile deleted: " .. name)
    return true
end

-- Switch profile
function Database:SetProfile(name)
    if not BLUDB.profiles[name] then
        BLU:PrintError("Profile does not exist: " .. name)
        return false
    end
    
    BLUDB.currentProfile = name
    BLU.db = BLUDB.profiles[name]
    
    -- Notify modules of profile change
    BLU:FireEvent("BLU_PROFILE_CHANGED", name)
    
    BLU:Print("Switched to profile: " .. name)
    return true
end

-- Get profile list
function Database:GetProfiles()
    local profiles = {}
    for name in pairs(BLUDB.profiles) do
        table.insert(profiles, name)
    end
    table.sort(profiles)
    return profiles
end

-- Get current profile
function Database:GetCurrentProfile()
    return BLUDB.currentProfile
end

-- Copy profile
function Database:CopyProfile(from, to)
    if not BLUDB.profiles[from] then
        BLU:PrintError("Source profile does not exist: " .. from)
        return false
    end
    
    BLUDB.profiles[to] = self:CopyTable(BLUDB.profiles[from])
    BLU:Print("Profile copied: " .. from .. " -> " .. to)
    return true
end

-- Utility: Deep copy table
function Database:CopyTable(src)
    if type(src) ~= "table" then
        return src
    end
    
    local copy = {}
    for k, v in pairs(src) do
        copy[k] = self:CopyTable(v)
    end
    
    return copy
end

-- Utility: Merge defaults into table
function Database:MergeDefaults(tbl, defaults)
    for k, v in pairs(defaults) do
        if tbl[k] == nil then
            if type(v) == "table" then
                tbl[k] = self:CopyTable(v)
            else
                tbl[k] = v
            end
        elseif type(v) == "table" and type(tbl[k]) == "table" then
            self:MergeDefaults(tbl[k], v)
        end
    end
end

-- Hook into BLU
function BLU:LoadSettings()
    Database:Init()
end

function BLU:SaveSettings()
    Database:Save()
end

-- Export
BLU.Database = Database
return Database