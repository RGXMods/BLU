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
    
    BLUDB.profiles[charKey] = BLUDB.profiles[charKey] or {}
    
    -- Set active database reference
    BLU.db = BLUDB.profiles[charKey]
    BLU.db.currentProfile = charKey
    
    -- Initialize with defaults
    self:ApplyDefaults()
    
    BLU:PrintDebug("BLU.db after setting: " .. tostring(BLU.db))
    
    return BLU.db
end

-- Apply default settings
function Database:ApplyDefaults()
    BLU:PrintDebug("[Database] ApplyDefaults called")
    if not BLU.Modules.config or not BLU.Modules.config.defaults then
        BLU:PrintError("Database:ApplyDefaults - Config defaults not found!")
        return
    end

    local defaults = BLU.Modules.config.defaults
    
    -- Merge defaults into BLU.db
    if BLU.db then
        BLU.db.profile = BLU.db.profile or {}
        self:MergeDefaults(BLU.db.profile, defaults.profile)
    end
end

-- Local implementation of MergeDefaults (don't depend on BLU.MergeDefaults)
function Database:MergeDefaults(target, defaults)
    BLU:PrintDebug("[Database] MergeDefaults called")
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
    BLU:PrintDebug("[Database] GetDB called for path '" .. tostring(path) .. "'")
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
    BLU:PrintDebug("[Database] SetDB called for path '" .. tostring(path) .. "' => " .. tostring(value))
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
    BLU:PrintDebug("[Database] SaveSettings called")
    -- Trigger SavedVariables write
    if BLU.db then
        BLU.db.lastSaved = time()
        local version = (BLU.GetMetadata and BLU:GetMetadata(addonName, "Version"))
            or (C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(addonName, "Version"))
            or (GetAddOnMetadata and GetAddOnMetadata(addonName, "Version"))
            or BLU.version or "v6.0.0"
        BLU.db.version = version
    end
end

BLU.SaveSettings = function()
    return Database:SaveSettings()
end

-- Profile management
function Database:CreateProfile(name)
    BLU:PrintDebug("[Database] CreateProfile called for '" .. tostring(name) .. "'")
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
    
    -- Refresh UI to show the new profile in lists
    if BLU.RefreshOptions then
        BLU:RefreshOptions()
    end
    if BLU.RefreshProfilesUI then
        BLU:RefreshProfilesUI()
    end

    return true
end

function Database:LoadProfile(name)
    BLU:PrintDebug("[Database] LoadProfile called for '" .. tostring(name) .. "'")
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
    if BLU.RefreshProfilesUI then
        BLU:RefreshProfilesUI()
    end
    
    return true
end

function Database:DeleteProfile(name)
    BLU:PrintDebug("[Database] DeleteProfile called for '" .. tostring(name) .. "'")
    if not name or name == "Default" then
        return false
    end
    
    if BLUDB.profiles and BLUDB.profiles[name] then
        BLUDB.profiles[name] = nil
        
        -- Switch to Default if we deleted current
        if self:GetDB("currentProfile") == name then
            self:LoadProfile("Default")
        else
            if BLU.RefreshOptions then
                BLU:RefreshOptions()
            end
            if BLU.RefreshProfilesUI then
                BLU:RefreshProfilesUI()
            end
        end
        
        return true
    end
    
    return false
end

function Database:RenameProfile(oldName, newName)
    BLU:PrintDebug("[Database] RenameProfile called from '" .. tostring(oldName) .. "' to '" .. tostring(newName) .. "'")
    if not oldName or not newName or oldName == "Default" then
        return false
    end
    
    if BLUDB.profiles and BLUDB.profiles[oldName] then
        BLUDB.profiles[newName] = BLUDB.profiles[oldName]
        BLUDB.profiles[oldName] = nil
        
        -- Update current profile name if needed
        if self:GetDB("currentProfile") == oldName then
            self:SetDB("currentProfile", newName)
            -- Re-link the active reference to the new database key
            BLU.db = BLUDB.profiles[newName]
            -- Synchronize the internal name key
            BLU.db.currentProfile = newName
        end

        -- Trigger a global UI refresh to update labels and lists in realtime
        if BLU.RefreshOptions then
            BLU:RefreshOptions()
        end
        if BLU.RefreshProfilesUI then
            BLU:RefreshProfilesUI()
        end

        return true
    end
    
    return false
end

-- Profile serialization for import/export
function Database:SerializeProfile(name)
    BLU:PrintDebug("[Database] SerializeProfile called for '" .. tostring(name) .. "'")
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
    BLU:PrintDebug("[Database] DeserializeProfile called")
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
    BLU:PrintDebug("[Database] ShowExportDialog called")
    -- Create export dialog with copyable text
    StaticPopupDialogs["BLU_EXPORT_PROFILE"] = {
        text = "Copy this profile data:",
        button1 = "Close",
        hasEditBox = true,
        editBoxWidth = 350,
        OnShow = function(self)
            if self.editBox then
                self.editBox:SetText(data)
                self.editBox:HighlightText()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true
    }
    StaticPopup_Show("BLU_EXPORT_PROFILE")
end

function Database:ShowImportDialog()
    BLU:PrintDebug("[Database] ShowImportDialog called")
    StaticPopupDialogs["BLU_IMPORT_PROFILE"] = {
        text = "Paste profile data to import:",
        button1 = "Import",
        button2 = "Cancel",
        hasEditBox = true,
        editBoxWidth = 350,
        OnAccept = function(self)
            BLU:PrintDebug("[Database] Import dialog accepted")
            if not self.editBox then
                BLU:PrintError("Import failed: EditBox not found")
                return
            end
            
            local data = self.editBox:GetText() or ""
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
-- Map Database methods to BLU object safely for both '.' and ':' calls
function BLU.CreateProfile(self, name)
    if type(self) == "string" and name == nil then
        name = self
    end
    return Database:CreateProfile(name)
end

function BLU.LoadProfile(self, name)
    if type(self) == "string" and name == nil then
        name = self
    end
    return Database:LoadProfile(name)
end

function BLU.DeleteProfile(self, name)
    if type(self) == "string" and name == nil then
        name = self
    end
    return Database:DeleteProfile(name)
end

function BLU.RenameProfile(self, oldName, newName)
    if type(self) == "string" and newName == nil then
        newName = oldName
        oldName = self
    end
    return Database:RenameProfile(oldName, newName)
end

function BLU.SerializeProfile(self, name)
    if type(self) == "string" and name == nil then
        name = self
    end
    return Database:SerializeProfile(name)
end

function BLU.ImportProfile(self, data, name)
    if type(self) == "string" and data == nil then
        data = self
    end
    return Database:DeserializeProfile(data)
end

function BLU.ShowExportDialog(self, data)
    if type(self) == "string" and data == nil then
        data = self
    end
    return Database:ShowExportDialog(data)
end
function BLU:ShowImportDialog() return Database:ShowImportDialog() end
