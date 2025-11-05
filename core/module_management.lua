--=====================================================================================
-- BLU | Module Management Functions
-- Author: donniedice
-- Description: Enable/disable/reload module functionality
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

-- Enable a specific module
function BLU:EnableModule(moduleName)
    if not moduleName then return false end
    
    -- Mark as enabled in database
    self.db = self.db or {}
    self.db.modules = self.db.modules or {}
    self.db.modules[moduleName] = true
    
    -- Load the module if it exists
    self.LoadedModules = self.LoadedModules or {}
    if not self.LoadedModules[moduleName] then
        -- Try to initialize the module
        if self.Modules and self.Modules[moduleName] then
            if self.Modules[moduleName].Init then
                self.Modules[moduleName]:Init()
            end
            self.LoadedModules[moduleName] = true
        end
    end
    
    -- Call module's Enable function if it exists
    if self.Modules and self.Modules[moduleName] and self.Modules[moduleName].Enable then
        self.Modules[moduleName]:Enable()
    end
    
    self:PrintDebug("Module enabled: " .. moduleName)
    return true
end

-- Disable a specific module
function BLU:DisableModule(moduleName)
    if not moduleName then return false end
    
    -- Mark as disabled in database
    self.db = self.db or {}
    self.db.modules = self.db.modules or {}
    self.db.modules[moduleName] = false
    
    -- Call module's Disable function if it exists
    if self.Modules and self.Modules[moduleName] then
        if self.Modules[moduleName].Disable then
            self.Modules[moduleName]:Disable()
        elseif self.Modules[moduleName].Cleanup then
            self.Modules[moduleName]:Cleanup()
        end
    end
    
    -- Mark as unloaded
    self.LoadedModules = self.LoadedModules or {}
    self.LoadedModules[moduleName] = false
    
    self:PrintDebug("Module disabled: " .. moduleName)
    return true
end

-- Reload all modules
function BLU:ReloadModules()
    self.LoadedModules = self.LoadedModules or {}
    
    -- Disable all loaded modules first
    for moduleName, isLoaded in pairs(self.LoadedModules) do
        if isLoaded then
            self:DisableModule(moduleName)
        end
    end
    
    -- Clear loaded modules tracking
    wipe(self.LoadedModules)
    
    -- Re-enable modules based on settings
    local moduleList = {
        "levelup", 
        "achievement", 
        "quest", 
        "reputation", 
        "honor", 
        "battlepet", 
        "renown", 
        "tradingpost", 
        "delve"
    }
    
    for _, moduleName in ipairs(moduleList) do
        -- Check if module should be enabled (default to true if not set)
        local isEnabled = true
        if self.db and self.db.modules then
            if self.db.modules[moduleName] == false then
                isEnabled = false
            end
        end
        
        if isEnabled then
            self:EnableModule(moduleName)
        end
    end
    
    self:PrintDebug("All modules reloaded")
    return true
end

-- Check if a module is enabled
function BLU:IsModuleEnabled(moduleName)
    if not moduleName then return false end
    
    -- Check database setting
    if self.db and self.db.modules then
        return self.db.modules[moduleName] ~= false
    end
    
    -- Default to enabled if not specified
    return true
end

-- Get list of all available modules
function BLU:GetAvailableModules()
    return {
        {id = "levelup", name = "Level Up", desc = "Plays sounds when you gain a level"},
        {id = "achievement", name = "Achievement", desc = "Plays sounds for achievements"},
        {id = "quest", name = "Quest Complete", desc = "Plays sounds for quest completion"},
        {id = "reputation", name = "Reputation", desc = "Plays sounds for reputation changes"},
        {id = "honor", name = "Honor", desc = "Plays sounds for honor gains"},
        {id = "battlepet", name = "Battle Pet", desc = "Plays sounds for pet levels"},
        {id = "renown", name = "Renown", desc = "Plays sounds for renown increases"},
        {id = "tradingpost", name = "Trading Post", desc = "Plays sounds for trading post"},
        {id = "delve", name = "Delve", desc = "Plays sounds for delve completion"}
    }
end

-- Clear sound cache (for memory management)
function BLU:ClearSoundCache()
    if self.SoundRegistry and self.SoundRegistry.soundCache then
        wipe(self.SoundRegistry.soundCache)
    end
    
    -- Force garbage collection
    collectgarbage("collect")
    
    self:PrintDebug("Sound cache cleared")
end

-- Rebuild database with defaults
function BLU:RebuildDatabase()
    -- Save current profile name if exists
    local currentProfile = self.db and self.db.currentProfile or "Default"
    
    -- Initialize fresh database
    self:InitializeDatabase()
    
    -- Restore profile name
    if self.db then
        self.db.currentProfile = currentProfile
    end
    
    self:PrintDebug("Database rebuilt with defaults")
end

-- Play test sound for preview
function BLU:PlayTestSound(soundType, volume)
    soundType = soundType or "levelup"
    volume = volume or (self.db and self.db.volume or 100)
    
    -- Get a sample sound for the type
    local testSounds = {
        levelup = "Interface\\AddOns\\BLU\\media\\sounds\\final_fantasy.ogg",
        achievement = "Interface\\AddOns\\BLU\\media\\sounds\\pokemon.ogg",
        quest = "Interface\\AddOns\\BLU\\media\\sounds\\quest_default.ogg",
        reputation = "Interface\\AddOns\\BLU\\media\\sounds\\rep_default.ogg",
        honor = "Interface\\AddOns\\BLU\\media\\sounds\\honor_default.ogg",
        battlepet = "Interface\\AddOns\\BLU\\media\\sounds\\battle_pet_level_default.ogg",
        renown = "Interface\\AddOns\\BLU\\media\\sounds\\renown_default.ogg",
        tradingpost = "Interface\\AddOns\\BLU\\media\\sounds\\post_default.ogg",
        delve = "Interface\\AddOns\\BLU\\media\\sounds\\quest_default.ogg"
    }
    
    local soundFile = testSounds[soundType]
    if soundFile then
        -- Play the sound using default channel
        local willPlay, handle = PlaySoundFile(soundFile)
        if willPlay then
            print("|cff00ccffBLU:|r Playing test sound: " .. soundType)
        else
            print("|cff00ccffBLU:|r Failed to play test sound")
        end
    else
        print("|cff00ccffBLU:|r No test sound available for: " .. soundType)
    end
end

-- Play default sound for an event type
function BLU:PlayDefaultSound(eventType, volume)
    volume = volume or (self.db and self.db.volume or 100)
    
    local defaultSounds = {
        levelup = "Interface\\AddOns\\BLU\\media\\sounds\\level_default.ogg",
        achievement = "Interface\\AddOns\\BLU\\media\\sounds\\achievement_default.ogg",
        quest = "Interface\\AddOns\\BLU\\media\\sounds\\quest_default.ogg",
        quest_accept = "Interface\\AddOns\\BLU\\media\\sounds\\quest_accept_default.ogg",
        reputation = "Interface\\AddOns\\BLU\\media\\sounds\\rep_default.ogg",
        honor = "Interface\\AddOns\\BLU\\media\\sounds\\honor_default.ogg",
        battlepet = "Interface\\AddOns\\BLU\\media\\sounds\\battle_pet_level_default.ogg",
        renown = "Interface\\AddOns\\BLU\\media\\sounds\\renown_default.ogg",
        tradingpost = "Interface\\AddOns\\BLU\\media\\sounds\\post_default.ogg"
    }
    
    local soundFile = defaultSounds[eventType]
    if soundFile then
        local willPlay, handle = PlaySoundFile(soundFile)
        if willPlay then
            self:PrintDebug("Playing default sound for: " .. eventType)
        end
    end
end

-- Refresh options UI if open
function BLU:RefreshOptions()
    -- Update all panels if they exist
    if self.Settings and self.Settings.panels then
        for panelId, panel in pairs(self.Settings.panels) do
            if panel.UpdateModuleStates then
                panel:UpdateModuleStates()
            end
            if panel.UpdateMemoryUsage then
                panel:UpdateMemoryUsage()
            end
        end
    end
end
