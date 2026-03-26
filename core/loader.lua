--=====================================================================================
-- BLU Module Loader System
-- Handles dynamic loading and unloading of modules based on user settings
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
BLU.Modules = BLU.Modules or {}
BLU.LoadedModules = {}

-- Module loader registration
local Loader = {}
BLU.Modules["loader"] = Loader

-- Initialize
function Loader:Init()
    -- Module loading functions are attached to BLU directly
    BLU:PrintDebug("Loader module initialized")
end

-- Module registry
local moduleRegistry = {
    -- Core modules (always loaded)
    core = {
        "core",
        "config",
        "utils",
        "localization",
        "registry",
        "events",
        "sound_muter"
    },
    
    -- Feature modules (loaded on demand)
    features = {
        levelup = "levelup",
        achievement = "achievement",
        reputation = "reputation",
        quest = "quest",
        battlepet = "battlepet",
        honor = "honor",
        renown = "renown",
        tradingpost = "tradingpost",
        delve = "delve",
        housing = "housing",

        -- UI/event aliases mapped to concrete module ids.
        honorrank = "honor",
        renownrank = "renown",
        delvecompanion = "delve",
        questaccept = "quest",
        questturnin = "quest"
    },
    

}

local function ResolveModuleKey(moduleType, moduleName)
    local moduleKey = moduleRegistry[moduleType] and moduleRegistry[moduleType][moduleName]
    if moduleKey then
        BLU:PrintDebug("[Loader] Resolved module '" .. tostring(moduleName) .. "' in type '" .. tostring(moduleType) .. "' to key '" .. tostring(moduleKey) .. "'")
        return moduleKey
    end

    BLU:PrintDebug("[Loader] Using passthrough module key for '" .. tostring(moduleName) .. "'")
    return moduleName
end

local moduleSettingKeyMap = {
    honor = "honorrank",
    renown = "renownrank",
    delve = "delvecompanion",
    housing = "housing",
}

local moduleLegacyToggleMap = {
    levelup = "enableLevelUp",
    achievement = "enableAchievement",
    reputation = "enableReputation",
    quest = "enableQuest",
    battlepet = "enableBattlePet",
    honor = "enableHonorRank",
    renown = "enableRenownRank",
    tradingpost = "enableTradingPost",
    delve = "enableDelveCompanion",
    housing = "enableHousing",
}

local function IsFeatureEnabled(db, moduleName)
    if not db then
        return true
    end

    local moduleSettingKey = moduleSettingKeyMap[moduleName] or moduleName
    if db.modules and db.modules[moduleSettingKey] == false then
        return false
    end

    local legacyKey = moduleLegacyToggleMap[moduleName]
    if legacyKey and db[legacyKey] == false then
        return false
    end

    return true
end

-- Module loader function
function BLU:LoadModule(moduleType, moduleName)
    self:PrintDebug("[Loader] LoadModule called for type='" .. tostring(moduleType) .. "', module='" .. tostring(moduleName) .. "'")
    -- All modules must be pre-loaded via XML files in WoW
    -- This function now just enables/initializes already loaded modules
    
    local moduleKey = ResolveModuleKey(moduleType, moduleName)
    
    -- Check if module exists in BLU.Modules (pre-loaded via XML)
    local module = self.Modules[moduleKey]
    
    if not module then
        self:PrintDebug("Module not found: " .. tostring(moduleName) .. " (key: " .. tostring(moduleKey) .. ")")
        return false
    end
    
    -- Check if already initialized
    if self.LoadedModules[moduleName] or self.LoadedModules[moduleKey] then
        self:PrintDebug("Module already loaded: " .. moduleName)
        return true
    end
    
    -- Mark as loaded
    self.LoadedModules[moduleName] = module
    self.LoadedModules[moduleKey] = module
    
    -- Initialize module if it has an Init function
    if type(module.Init) == "function" then
        local success, err = pcall(module.Init, module)
        if success then
            self:PrintDebug("Successfully initialized module: " .. moduleName)
        else
            self:PrintDebug("Failed to initialize module: " .. moduleName .. " - " .. tostring(err))
            self.LoadedModules[moduleName] = nil
            self.LoadedModules[moduleKey] = nil
            return false
        end
    else
        self:PrintDebug("Module loaded (no Init): " .. moduleName)
    end
    
    return true
end

-- Module unloader function
function BLU:UnloadModule(moduleName)
    self:PrintDebug("[Loader] UnloadModule called for '" .. tostring(moduleName) .. "'")
    local moduleKey = ResolveModuleKey("features", moduleName)
    local module = self.LoadedModules[moduleName] or self.LoadedModules[moduleKey]
    if not module then
        return
    end
    
    -- Call cleanup if available
    if module and type(module.Cleanup) == "function" then
        module:Cleanup()
    end
    
    -- Unregister events if available
    if module and type(module.UnregisterEvents) == "function" then
        module:UnregisterEvents()
    end
    
    self.LoadedModules[moduleName] = nil
    self.LoadedModules[moduleKey] = nil
    self:PrintDebug("Unloaded module: " .. moduleName)
end

-- Load modules based on saved settings
function BLU:LoadModulesFromSettings()
    self:PrintDebug("[Loader] LoadModulesFromSettings called")
    if not self.db or not self.db.profile then
        self:PrintDebug("[Loader] LoadModulesFromSettings aborted; profile not ready")
        return
    end

    local db = self.db.profile
    
    -- Load all feature modules if addon is enabled
    if db.enabled then
        local featureModules = {
            "levelup",
            "achievement",
            "reputation",
            "quest",
            "battlepet",
            "delve",
            "honor",
            "renown",
            "tradingpost",
            "housing",
        }

        for _, moduleName in ipairs(featureModules) do
            if IsFeatureEnabled(db, moduleName) then
                self:PrintDebug("[Loader] Feature module enabled by settings: " .. tostring(moduleName))
                self:LoadModule("features", moduleName)
            else
                self:PrintDebug("[Loader] Feature module disabled by settings: " .. tostring(moduleName))
                self:UnloadModule(moduleName)
            end
        end
    end
    
    -- Load sound modules for selected games
    local soundsToLoad = {}
    
    -- Collect all unique sound modules needed from selectedSounds
    if db.selectedSounds then
        for category, game in pairs(db.selectedSounds) do
            if game and game ~= "default" and game ~= "None" then
                soundsToLoad[game:lower()] = true
            end
        end
    end
    
    -- Always load WoW default sounds as fallback
    soundsToLoad["wowdefault"] = true
    
    -- Load Final Fantasy if we have the files
    -- soundsToLoad["finalfantasy"] = true
    
    -- Load required sound modules
    for soundModule in pairs(soundsToLoad) do
        self:PrintDebug("[Loader] Loading sound module dependency '" .. tostring(soundModule) .. "'")
        self:LoadModule("sounds", soundModule)
    end
    
    -- Initialize sound browser
    if BLU.SoundBrowser and BLU.SoundBrowser.Init then
        BLU.SoundBrowser:Init()
    end
end

-- Update module loading when settings change
function BLU:UpdateModuleLoading(feature, enabled)
    self:PrintDebug("[Loader] UpdateModuleLoading called for '" .. tostring(feature) .. "' => " .. tostring(enabled))
    if enabled then
        self:LoadModule("features", feature)
    else
        self:UnloadModule(feature)
    end
end

-- Debug print function removed - using core framework BLU:PrintDebug() instead
