--=====================================================================================
-- BLU | Database Safety Layer
-- Author: donniedice
-- Description: Safe database access patterns to prevent nil errors
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

-- Create database module
local Database = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["database"] = Database

-- Initialize database with defaults
function Database:InitializeDatabase()
    BLU:PrintDebug("Database:InitializeDatabase called.")
    BLUDB = BLUDB or {}
    BLUDB.profiles = BLUDB.profiles or {}
    BLUDB.global = BLUDB.global or {}
    
    BLU:PrintDebug("BLUDB after initialization: " .. tostring(BLUDB))
    
    -- Character-specific database
    local charKey = UnitName("player") .. "-" .. GetRealmName()
    BLUDB.profiles[charKey] = BLUDB.profiles[charKey] or {}
    
    -- Set active database reference
    BLU.db = BLUDB.profiles[charKey]
    
    -- Initialize with defaults
    self:ApplyDefaults()
    
    BLU:PrintDebug("BLU.db after setting: " .. tostring(BLU.db))
    
    return BLU.db
end

-- Apply default settings
function Database:ApplyDefaults()
    local defaults = {
        profile = {
            enabled = true,
            showWelcomeMessage = true,
            debugMode = false,
            soundChannel = "Master",
            selectedSounds = {},
            modules = {},
            events = {}
        }
    }
    
    -- Merge defaults into BLU.db
    if BLU.db then
        BLU.db.profile = BLU.db.profile or {}
        self:MergeDefaults(BLU.db.profile, defaults.profile)
    end
end

-- Local implementation of MergeDefaults (don't depend on BLU.MergeDefaults)
function Database:MergeDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if target[key] == nil then
            if type(value) == "table" then
                target[key] = {}
                self:MergeDefaults(target[key], value)
            else
                target[key] = value
            end
        elseif type(value) == "table" and type(target[key]) == "table" then
            self:MergeDefaults(target[key], value)
        end
    end
end

-- Module Init function (called by initialization.lua)
function Database:Init()
    BLU:PrintDebug("Database:Init() called")
    self:InitializeDatabase()
    
    -- Make InitializeDatabase available globally
    BLU.InitializeDatabase = function()
        return self:InitializeDatabase()
    end
    
    BLU:PrintDebug("Database module initialized. BLU.db is " .. tostring(BLU.db))
end

-- Safe getter for database values
function Database:GetDB(path, default)
    if not BLU.db then
        self:InitializeDatabase()
    end
    
    if not path then
        return BLU.db
    end
    
    local value = BLU.db
    
    -- Handle table path (e.g., {"selectedSounds", "levelup"})
    if type(path) == "table" then
        for _, key in ipairs(path) do
            if type(value) ~= "table" then
                return default
            end
            value = value[key]
            if value == nil then
                return default
            end
        end
    -- Handle string path (e.g., "events.levelup.sound")
    elseif type(path) == "string" then
        for key in string.gmatch(path, "[^%.]+") do
            if type(value) ~= "table" then
                return default
            end
            value = value[key]
            if value == nil then
                return default
            end
        end
    else
        return default
    end
    
    return value
end

-- Safe setter for database values
function Database:SetDB(path, value)
    if not BLU.db then
        self:InitializeDatabase()
    end
    
    if not path then
        return false
    end
    
    -- Parse path and create tables as needed
    local keys = {}
    
    -- Handle table path (e.g., {"selectedSounds", "levelup"})
    if type(path) == "table" then
        keys = path
    -- Handle string path (e.g., "events.levelup.sound")
    elseif type(path) == "string" then
        for key in string.gmatch(path, "[^%.]+") do
            table.insert(keys, key)
        end
    else
        return false
    end
    
    local current = BLU.db
    for i = 1, #keys - 1 do
        local key = keys[i]
        if type(current[key]) ~= "table" then
            current[key] = {}
        end
        current = current[key]
    end
    
    -- Set the final value
    current[keys[#keys]] = value
    return true
end

-- Make GetDB and SetDB available globally
BLU.GetDB = function(path, default)
    return Database:GetDB(path, default)
end

BLU.SetDB = function(path, value)
    return Database:SetDB(path, value)
end

-- Save settings
function Database:SaveSettings()
    -- Trigger SavedVariables write
    if BLU.db then
        BLU.db.lastSaved = time()
        BLU.db.version = GetAddOnMetadata(addonName, "Version")
    end
end

BLU.SaveSettings = function()
    return Database:SaveSettings()
end

-- Profile management
function Database:CreateProfile(name)
    if not name or name == "" then
        return false
    end
    
    BLUDB.profiles = BLUDB.profiles or {}
    BLUDB.profiles[name] = BLUDB.profiles[name] or {}
    
    -- Copy current settings to new profile
    if BLU.db then
        BLUDB.profiles[name] = BLU.Modules.utils:DeepCopy(BLU.db)
    end
    
    -- Switch to new profile
    self:SetDB("currentProfile", name)
    self:LoadProfile(name)
    
    return true
end

function Database:LoadProfile(name)
    if not name or not BLUDB.profiles[name] then
        return false
    end
    
    -- Save current profile first
    self:SaveSettings()
    
    -- Load new profile
    BLU.db = BLUDB.profiles[name]
    self:SetDB("currentProfile", name)
    self:ApplyDefaults()
    
    -- Refresh UI if needed
    if BLU.RefreshOptions then
        BLU:RefreshOptions()
    end
    
    return true
end

function Database:DeleteProfile(name)
    if not name or name == "Default" then
        return false
    end
    
    if BLUDB.profiles and BLUDB.profiles[name] then
        BLUDB.profiles[name] = nil
        
        -- Switch to Default if we deleted current
        if self:GetDB("currentProfile") == name then
            self:LoadProfile("Default")
        end
        
        return true
    end
    
    return false
end

function Database:RenameProfile(oldName, newName)
    if not oldName or not newName or oldName == "Default" then
        return false
    end
    
    if BLUDB.profiles and BLUDB.profiles[oldName] then
        BLUDB.profiles[newName] = BLUDB.profiles[oldName]
        BLUDB.profiles[oldName] = nil
        
        -- Update current profile name if needed
        if self:GetDB("currentProfile") == oldName then
            self:SetDB("currentProfile", newName)
        end
        
        return true
    end
    
    return false
end

-- Profile serialization for import/export
function Database:SerializeProfile(name)
    local profile = BLUDB.profiles[name or self:GetDB("currentProfile")]
    if not profile then
        return ""
    end
    
    -- Simple serialization (could be enhanced with LibSerialize)
    local str = "BLU_PROFILE_v1:"
    for key, value in pairs(profile) do
        if type(value) ~= "table" then
            str = str .. key .. "=" .. tostring(value) .. ";"
        end
    end
    
    return str
end

function Database:DeserializeProfile(str)
    if not str or not string.find(str, "^BLU_PROFILE_v1:") then
        return nil
    end
    
    local profile = {}
    str = string.sub(str, 16) -- Remove header
    
    for pair in string.gmatch(str, "([^;]+)") do
        local key, value = string.match(pair, "([^=]+)=(.+)")
        if key and value then
            -- Convert to proper types
            if value == "true" then
                profile[key] = true
            elseif value == "false" then
                profile[key] = false
            elseif tonumber(value) then
                profile[key] = tonumber(value)
            else
                profile[key] = value
            end
        end
    end
    
    return profile
end

-- Export/Import dialogs
function Database:ShowExportDialog(data)
    -- Create export dialog with copyable text
    StaticPopupDialogs["BLU_EXPORT_PROFILE"] = {
        text = "Copy this profile data:",
        button1 = "Close",
        hasEditBox = true,
        editBoxWidth = 350,
        OnShow = function(self)
            self.editBox:SetText(data)
            self.editBox:HighlightText()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true
    }
    StaticPopup_Show("BLU_EXPORT_PROFILE")
end

function Database:ShowImportDialog()
    StaticPopupDialogs["BLU_IMPORT_PROFILE"] = {
        text = "Paste profile data to import:",
        button1 = "Import",
        button2 = "Cancel",
        hasEditBox = true,
        editBoxWidth = 350,
        OnAccept = function(self)
            local data = self.editBox:GetText()
            local profile = Database:DeserializeProfile(data)
            if profile then
                -- Create new profile with imported data
                local name = "Imported_" .. date("%Y%m%d_%H%M%S")
                BLUDB.profiles[name] = profile
                Database:LoadProfile(name)
                print("|cff00ccffBLU:|r Profile imported as: " .. name)
            else
                print("|cff00ccffBLU:|r Invalid profile data")
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true
    }
    StaticPopup_Show("BLU_IMPORT_PROFILE")
end

-- Make profile functions available globally
BLU.CreateProfile = function(name) return Database:CreateProfile(name) end
BLU.LoadProfile = function(name) return Database:LoadProfile(name) end
BLU.DeleteProfile = function(name) return Database:DeleteProfile(name) end
BLU.RenameProfile = function(old, new) return Database:RenameProfile(old, new) end
BLU.SerializeProfile = function(name) return Database:SerializeProfile(name) end
BLU.ImportProfile = function(data, name) return Database:DeserializeProfile(data) end
BLU.ShowExportDialog = function(data) return Database:ShowExportDialog(data) end
BLU.ShowImportDialog = function() return Database:ShowImportDialog() end
