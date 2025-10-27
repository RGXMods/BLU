--=====================================================================================
-- BLU | Database Safety Layer
-- Author: donniedice
-- Description: Safe database access patterns to prevent nil errors
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

-- Initialize database with defaults
function BLU:InitializeDatabase()
    BLUDB = BLUDB or {}
    BLUDB.profiles = BLUDB.profiles or {}
    BLUDB.global = BLUDB.global or {}
    
    -- Character-specific database
    local charKey = UnitName("player") .. "-" .. GetRealmName()
    BLUDB.profiles[charKey] = BLUDB.profiles[charKey] or {}
    
    -- Set active database reference
    self.db = BLUDB.profiles[charKey]
    
    -- Apply defaults
    self:ApplyDefaults()
    
    return self.db
end

-- Safe getter for database values
function BLU:GetDB(path, default)
    if not self.db then
        self:InitializeDatabase()
    end
    
    if not path then
        return self.db
    end
    
    local value = self.db
    
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
function BLU:SetDB(path, value)
    if not self.db then
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
    
    local current = self.db
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

-- Apply default settings
function BLU:ApplyDefaults()
    local defaults = {
        enabled = true,
        volume = 100,
        debug = false,
        testMode = false,
        
        -- Event defaults
        events = {
            levelup = {enabled = true, sound = "default", volume = 100},
            achievement = {enabled = true, sound = "default", volume = 100},
            quest = {enabled = true, sound = "default", volume = 100},
            reputation = {enabled = true, sound = "default", volume = 90},
            honor = {enabled = true, sound = "default", volume = 90},
            battlepet = {enabled = true, sound = "default", volume = 85},
            renown = {enabled = true, sound = "default", volume = 85},
            tradingpost = {enabled = true, sound = "default", volume = 80},
            delve = {enabled = true, sound = "default", volume = 80}
        },
        
        -- Module defaults
        modules = {
            levelup = true,
            achievement = true,
            quest = true,
            reputation = false,
            honor = true,
            battlepet = true,
            renown = true,
            tradingpost = true,
            delve = false
        },
        
        -- Performance defaults
        preloadSounds = false,
        cacheSize = 50,
        lazyLoading = true,
        
        -- Advanced defaults
        soundPooling = false,
        asyncLoading = false,
        soundQueueSize = 3,
        fadeTime = 200,
        moduleTimeout = 5,
        debugLevel = 0,
        debugToConsole = false,
        debugToFile = false,
        profiling = false,
        
        -- Experimental defaults
        positionalAudio = false,
        dynamicCompression = false,
        aiSounds = false,
        weakAurasIntegration = false,
        discordIntegration = false,
        
        -- Profile defaults
        currentProfile = "Default",
        autoSaveProfile = true,
        showProfileDiff = false,
        
        -- UI defaults
        playInBackground = false,
        randomVariations = false
    }
    
    -- Merge defaults with existing settings
    self:MergeDefaults(self.db, defaults)
end

-- Recursively merge defaults
function BLU:MergeDefaults(target, defaults)
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

-- Save settings
function BLU:SaveSettings()
    -- Trigger SavedVariables write
    if self.db then
        self.db.lastSaved = time()
        self.db.version = GetAddOnMetadata(addonName, "Version")
    end
end

-- Reset to defaults
function BLU:ResetToDefaults()
    if self.db then
        wipe(self.db)
        self:ApplyDefaults()
        self:SaveSettings()
    end
end

-- Reset advanced settings only
function BLU:ResetAdvancedSettings()
    if self.db then
        -- Reset only advanced settings
        self.db.soundPooling = false
        self.db.asyncLoading = false
        self.db.soundQueueSize = 3
        self.db.fadeTime = 200
        self.db.moduleTimeout = 5
        self.db.debugLevel = 0
        self.db.debugToConsole = false
        self.db.debugToFile = false
        self.db.profiling = false
        self.db.positionalAudio = false
        self.db.dynamicCompression = false
        self.db.aiSounds = false
        self.db.weakAurasIntegration = false
        self.db.discordIntegration = false
        self:SaveSettings()
    end
end

-- Profile management
function BLU:CreateProfile(name)
    if not name or name == "" then return false end
    
    BLUDB.profiles = BLUDB.profiles or {}
    BLUDB.profiles[name] = BLUDB.profiles[name] or {}
    
    -- Copy current settings to new profile
    if self.db then
        for key, value in pairs(self.db) do
            if type(value) == "table" then
                BLUDB.profiles[name][key] = {}
                for k, v in pairs(value) do
                    BLUDB.profiles[name][key][k] = v
                end
            else
                BLUDB.profiles[name][key] = value
            end
        end
    end
    
    -- Switch to new profile
    self:SetDB("currentProfile", name)
    self:LoadProfile(name)
    
    return true
end

function BLU:LoadProfile(name)
    if not name or not BLUDB.profiles[name] then
        return false
    end
    
    -- Save current profile first
    self:SaveProfile(self:GetDB("currentProfile"))
    
    -- Load new profile
    self.db = BLUDB.profiles[name]
    self:SetDB("currentProfile", name)
    self:ApplyDefaults()
    
    -- Refresh UI if needed
    if self.RefreshOptions then
        self:RefreshOptions()
    end
    
    return true
end

function BLU:SaveProfile(name)
    if not name then
        name = self:GetDB("currentProfile", "Default")
    end
    
    BLUDB.profiles = BLUDB.profiles or {}
    BLUDB.profiles[name] = self.db
    
    return true
end

function BLU:DeleteProfile(name)
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

function BLU:RenameProfile(oldName, newName)
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
function BLU:SerializeProfile(name)
    local profile = BLUDB.profiles[name or self:GetDB("currentProfile")]
    if not profile then return "" end
    
    -- Simple serialization (could be enhanced with LibSerialize)
    local str = "BLU_PROFILE_v1:"
    for key, value in pairs(profile) do
        if type(value) ~= "table" then
            str = str .. key .. "=" .. tostring(value) .. ";"
        end
    end
    
    return str
end

function BLU:DeserializeProfile(str)
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
function BLU:ShowExportDialog(data)
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

function BLU:ShowImportDialog()
    StaticPopupDialogs["BLU_IMPORT_PROFILE"] = {
        text = "Paste profile data to import:",
        button1 = "Import",
        button2 = "Cancel",
        hasEditBox = true,
        editBoxWidth = 350,
        OnAccept = function(self)
            local data = self.editBox:GetText()
            local profile = BLU:DeserializeProfile(data)
            if profile then
                -- Create new profile with imported data
                local name = "Imported_" .. date("%Y%m%d_%H%M%S")
                BLUDB.profiles[name] = profile
                BLU:LoadProfile(name)
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

local DatabaseSafety = {}
function DatabaseSafety:Init()
    -- The safety functions are already on the BLU object.
    BLU:PrintDebug("Database safety layer initialized")
end
BLU.Modules["database_safety"] = DatabaseSafety