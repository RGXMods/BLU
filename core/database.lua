--=====================================================================================
-- BLU Database System
-- Simple saved variables management (no external dependencies)
--=====================================================================================

local addonName, BLU = ...
local Database = {}

-- Remove loading message - not needed

-- Default settings
Database.defaults = {
    -- General
    enabled = true,
    showWelcomeMessage = true,
    debugMode = false,
    soundVolume = 100,
    soundChannel = "Master",
    randomSounds = false,
    
    -- Selected sounds per category
    selectedSounds = {
        levelup = "default",
        achievement = "default",
        reputation = "default",
        quest = "default",
        battlepet = "default",
        delvecompanion = "default",
        honorrank = "default",
        renownrank = "default",
        tradingpost = "default"
    }
}

-- Initialize database
function Database:Init()
    BLU:PrintDebug("Initializing database module")
    -- Check if variables are already loaded
    if C_AddOns.IsAddOnLoaded(addonName) then
        -- Variables should be available now
        self:LoadSavedVariables()
    else
        -- Wait for saved variables to load
        BLU:RegisterEvent("VARIABLES_LOADED", function()
            self:LoadSavedVariables()
        end)
    end
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
    
    -- Create easy access with profile structure
    BLU.db = {
        profile = BLUDB.profiles[BLUDB.currentProfile]
    }
    
    -- Merge with defaults (in case new settings were added)
    self:MergeDefaults(BLU.db.profile, self.defaults)
    
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
    BLU.db.profile = BLUDB.profiles[profile]
    BLU:Print("Profile reset to defaults")
end

-- Create new profile
function Database:CreateProfile(name)
    if BLUDB.profiles[name] then
        BLU:PrintError("Profile already exists: " .. name)
        return false
    end
    
    BLUDB.profiles[name] = self:CopyTable(BLU.db.profile)
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
    BLU.db.profile = BLUDB.profiles[name]
    
    -- Notify modules of profile change
    BLU:FireEvent("BLU_PROFILE_CHANGED", name)
    
    BLU:Print("Switched to profile: " .. name)
    return true
end

-- Delegate profile management to BLU functions
function Database:GetProfiles()
    return BLU:GetProfiles()
end

-- Get current profile
function Database:GetCurrentProfile()
    return BLUDB and BLUDB.currentProfile or "Default"
end

-- Copy profile
function Database:CopyProfile(from, to)
    return BLU:CopyProfile(from, to)
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

-- Database accessor function for safe access
function Database:Get(key)
    if not BLU.db or not BLU.db.profile then
        self:LoadSavedVariables()
    end
    
    if not key then
        return BLU.db.profile
    end
    
    local keys = type(key) == "string" and {key} or key
    local value = BLU.db.profile
    
    for _, k in ipairs(keys) do
        if type(value) ~= "table" then return nil end
        value = value[k]
    end
    
    return value
end

-- Safe setter
function Database:Set(key, value)
    if not BLU.db or not BLU.db.profile then
        self:LoadSavedVariables()
    end
    
    local keys = type(key) == "string" and {key} or key
    local target = BLU.db.profile
    
    for i = 1, #keys - 1 do
        local k = keys[i]
        if type(target[k]) ~= "table" then
            target[k] = {}
        end
        target = target[k]
    end
    
    target[keys[#keys]] = value
end

-- Hook into BLU
function BLU:GetDB(key)
    return Database:Get(key)
end

function BLU:SetDB(key, value)
    Database:Set(key, value)
end

function BLU:LoadSettings()
    Database:Init()
end

function BLU:SaveSettings()
    Database:Save()
end

function BLU:ResetSettings()
    Database:ResetProfile()
end

--=====================================================================================
-- Profile Management Functions
--=====================================================================================

-- Get list of all profiles
function BLU:GetProfiles()
    if not BLUDB or not BLUDB.profiles then
        return {"Default"}
    end
    
    local profiles = {}
    for name in pairs(BLUDB.profiles) do
        table.insert(profiles, name)
    end
    
    -- Ensure Default always exists
    local hasDefault = false
    for _, name in ipairs(profiles) do
        if name == "Default" then
            hasDefault = true
            break
        end
    end
    if not hasDefault then
        table.insert(profiles, 1, "Default")
    end
    
    table.sort(profiles)
    return profiles
end

-- Create a new profile
function BLU:CreateProfile(name)
    if not name or name == "" then return false end
    
    BLUDB = BLUDB or {}
    BLUDB.profiles = BLUDB.profiles or {}
    
    -- Check if profile already exists
    if BLUDB.profiles[name] then
        return false
    end
    
    -- Copy current profile settings
    BLUDB.profiles[name] = self:CopyTable(self.db.profile or self:GetDefaultProfile())
    return true
end

-- Switch to a different profile
function BLU:SwitchProfile(name)
    if not name then return false end
    
    BLUDB = BLUDB or {}
    BLUDB.profiles = BLUDB.profiles or {}
    
    -- Create profile if it doesn't exist
    if not BLUDB.profiles[name] and name ~= "Default" then
        BLUDB.profiles[name] = self:GetDefaultProfile()
    end
    
    -- Switch profile
    BLUDB.currentProfile = name
    
    if name == "Default" then
        self.db.profile = BLUDB.profiles.Default or self:GetDefaultProfile()
    else
        self.db.profile = BLUDB.profiles[name]
    end
    
    self.db.currentProfile = name
    return true
end

-- Delete a profile
function BLU:DeleteProfile(name)
    if not name or name == "Default" then return false end
    
    if BLUDB and BLUDB.profiles then
        BLUDB.profiles[name] = nil
        
        -- If we deleted the current profile, switch to Default
        if BLUDB.currentProfile == name then
            self:SwitchProfile("Default")
        end
        return true
    end
    
    return false
end

-- Copy a profile
function BLU:CopyProfile(source, destination)
    if not source or not destination or destination == "" then return false end
    
    BLUDB = BLUDB or {}
    BLUDB.profiles = BLUDB.profiles or {}
    
    local sourceProfile
    if source == "Default" then
        sourceProfile = BLUDB.profiles.Default or self:GetDefaultProfile()
    else
        sourceProfile = BLUDB.profiles[source]
    end
    
    if not sourceProfile then return false end
    
    BLUDB.profiles[destination] = self:CopyTable(sourceProfile)
    return true
end

-- Reset current profile to defaults
function BLU:ResetProfile()
    local currentProfile = self.db.currentProfile or "Default"
    
    if currentProfile == "Default" then
        BLUDB.profiles.Default = self:GetDefaultProfile()
        self.db.profile = BLUDB.profiles.Default
    else
        BLUDB.profiles[currentProfile] = self:GetDefaultProfile()
        self.db.profile = BLUDB.profiles[currentProfile]
    end
    
    return true
end

-- Export profile as string
function BLU:ExportProfile()
    if not self.db or not self.db.profile then return nil end
    
    -- Simple serialization (could be improved with proper serialization library)
    local profileData = self:CopyTable(self.db.profile)
    local export = "BLU_PROFILE_v1:"
    
    -- Convert to simple string format
    local function serialize(tbl, depth)
        depth = depth or 0
        if depth > 10 then return "..." end -- Prevent infinite recursion
        
        local result = "{"
        local first = true
        for k, v in pairs(tbl) do
            if not first then result = result .. "," end
            first = false
            
            if type(k) == "string" then
                result = result .. k .. "="
            else
                result = result .. "[" .. tostring(k) .. "]="
            end
            
            if type(v) == "table" then
                result = result .. serialize(v, depth + 1)
            elseif type(v) == "string" then
                result = result .. '"' .. v .. '"'
            elseif type(v) == "boolean" then
                result = result .. (v and "true" or "false")
            else
                result = result .. tostring(v)
            end
        end
        result = result .. "}"
        return result
    end
    
    export = export .. serialize(profileData)
    return export
end

-- Import profile from string
function BLU:ImportProfile(importString)
    if not importString or not importString:match("^BLU_PROFILE_v1:") then
        return false
    end
    
    -- Remove header
    local data = importString:gsub("^BLU_PROFILE_v1:", "")
    
    -- Simple deserialization (needs proper implementation)
    -- For now, just create a new profile with defaults
    local profileName = "Imported_" .. date("%Y%m%d_%H%M%S")
    
    BLUDB = BLUDB or {}
    BLUDB.profiles = BLUDB.profiles or {}
    BLUDB.profiles[profileName] = self:GetDefaultProfile()
    
    -- TODO: Properly deserialize the data string
    
    self:SwitchProfile(profileName)
    return true
end

-- Utility: Deep copy a table
function BLU:CopyTable(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[self:CopyTable(orig_key)] = self:CopyTable(orig_value)
        end
        setmetatable(copy, self:CopyTable(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- Reset all settings to defaults
function BLU:ResetToDefaults()
    BLUDB = {
        profiles = {
            Default = self:GetDefaultProfile()
        },
        currentProfile = "Default",
        global = {
            notFirstTime = true
        }
    }
    
    self.db = {
        profile = BLUDB.profiles.Default,
        currentProfile = "Default",
        global = BLUDB.global
    }
    
    return true
end

-- Get default profile
function BLU:GetDefaultProfile()
    return Database:CopyTable(Database.defaults)
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["database"] = Database

-- Export
BLU.Database = Database
return Database