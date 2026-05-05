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

-- "Default" is the permanent baseline profile.
-- It can be loaded, modified, and reset like any other profile.
-- It cannot be deleted, renamed, or duplicated by name.
local PROTECTED_PROFILE = "Default"

-- Ensure the Default profile slot exists. Only creates it if absent — never
-- overwrites user edits. Reset is handled explicitly via the Reset button.
function Database:EnsureDefaultTemplate()
    BLUDB.profiles = BLUDB.profiles or {}
    if not BLUDB.profiles[PROTECTED_PROFILE] then
        local tpl = {}
        if BLU.Modules and BLU.Modules.config and BLU.Modules.config.defaults then
            self:MergeDefaults(tpl, BLU.Modules.config.defaults.profile)
        end
        tpl.currentProfile = PROTECTED_PROFILE
        BLUDB.profiles[PROTECTED_PROFILE] = tpl
    end
end


-- Initialize database with defaults
function Database:InitializeDatabase()
    BLU:PrintDebug("Database:InitializeDatabase called.")
    BLUDB = BLUDB or {}
    BLUDB.profiles = BLUDB.profiles or {}
    BLUDB.global = BLUDB.global or {}

    -- Ensure the Default profile exists (creates it only if absent).
    self:EnsureDefaultTemplate()

    local activeProfile = BLUDB.activeProfile

    -- Resolve active profile: must exist in the profiles table.
    -- Fall back to Default — the user can create their own profile when ready.
    if not activeProfile or not BLUDB.profiles[activeProfile] then
        activeProfile = PROTECTED_PROFILE
    end

    -- Set active database reference and persist selection globally
    BLU.db = BLUDB.profiles[activeProfile]
    BLU.db.currentProfile = activeProfile
    BLUDB.activeProfile = activeProfile

    -- Fill in any missing defaults
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
        self:MergeDefaults(BLU.db, defaults.profile)
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
    if not name or name == "" or name == PROTECTED_PROFILE then
        return false
    end

    BLUDB.profiles = BLUDB.profiles or {}

    -- New profile always starts from clean defaults
    local newProfile = {}
    if BLU.Modules and BLU.Modules.config and BLU.Modules.config.defaults then
        self:MergeDefaults(newProfile, BLU.Modules.config.defaults.profile)
    end
    newProfile.currentProfile = name
    BLUDB.profiles[name] = newProfile

    -- Switch to the new profile immediately
    self:LoadProfile(name)

    return true
end

function Database:LoadProfile(name)
    BLU:PrintDebug("[Database] LoadProfile called for '" .. tostring(name) .. "'")

    if not name or not BLUDB.profiles[name] then
        return false
    end

    self:SaveSettings()

    BLU.db = BLUDB.profiles[name]
    BLU.db.currentProfile = name
    BLUDB.activeProfile = name

    -- Fill any keys the saved profile is missing (never overwrites existing values)
    if BLU.Modules and BLU.Modules.config and BLU.Modules.config.defaults then
        self:MergeDefaults(BLU.db, BLU.Modules.config.defaults.profile)
    end

    -- Force all tabs to fully rebuild, then refresh whatever is currently visible
    if BLU.InvalidateAllTabs then
        BLU:InvalidateAllTabs()
    end
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
    if not name or name == PROTECTED_PROFILE then
        return false
    end

    if BLUDB.profiles and BLUDB.profiles[name] then
        BLUDB.profiles[name] = nil

        -- If we deleted the active profile, find another profile to switch to.
        -- Prefer any existing non-Default profile; fall back to Default.
        if BLUDB.activeProfile == name then
            local fallback = PROTECTED_PROFILE
            for profileName in pairs(BLUDB.profiles) do
                if profileName ~= PROTECTED_PROFILE then
                    fallback = profileName
                    break
                end
            end

            self:LoadProfile(fallback)
        else
            if BLU.InvalidateAllTabs then BLU:InvalidateAllTabs() end
            if BLU.RefreshOptions then BLU:RefreshOptions() end
            if BLU.RefreshProfilesUI then BLU:RefreshProfilesUI() end
        end

        return true
    end

    return false
end

function Database:RenameProfile(oldName, newName)
    BLU:PrintDebug("[Database] RenameProfile called from '" .. tostring(oldName) .. "' to '" .. tostring(newName) .. "'")
    if not oldName or not newName or oldName == PROTECTED_PROFILE or newName == PROTECTED_PROFILE then
        return false
    end
    
    if BLUDB.profiles and BLUDB.profiles[oldName] then
        BLUDB.profiles[newName] = BLUDB.profiles[oldName]
        BLUDB.profiles[oldName] = nil
        
        -- Update current profile name if needed
        if BLUDB.activeProfile == oldName then
            BLUDB.activeProfile = newName
            -- Re-link the active reference to the new database key
            BLU.db = BLUDB.profiles[newName]
            -- Synchronize the internal name key
            BLU.db.currentProfile = newName
        end

        -- Invalidate all tabs so label changes show immediately on the next view,
        -- then refresh whatever is currently visible.
        if BLU.InvalidateAllTabs then BLU:InvalidateAllTabs() end
        if BLU.RefreshOptions then BLU:RefreshOptions() end
        if BLU.RefreshProfilesUI then BLU:RefreshProfilesUI() end

        return true
    end

    return false
end

-- Profile serialization for import/export
function Database:SerializeProfile(name)
    BLU:PrintDebug("[Database] SerializeProfile called for '" .. tostring(name) .. "'")
    local profile = BLUDB.profiles[name or BLUDB.activeProfile]
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
