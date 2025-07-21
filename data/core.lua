--=====================================================================================
-- BLU Core Module
-- Essential functionality (no external dependencies)
--=====================================================================================

local addonName, addonTable = ...

-- This module extends the BLU framework with core addon functionality

-- Initialize function (called by framework)
function BLU:InitializeModules()
    -- Module storage
    self.LoadedModules = {}
    self.soundRegistry = {}
end

-- Slash command handler
function BLU:HandleSlashCommand(input)
    if not input or input:trim() == "" then
        -- Open options
        if self.modules.Options then
            self.modules.Options:Open()
        end
    else
        local command = input:match("^(%S*)%s*(.-)$")
        command = command:lower()
        
        if command == "debug" then
            self.debugMode = not self.debugMode
            if self.db then
                self.db.debugMode = self.debugMode
            end
            self:Print(self:Loc(self.debugMode and "DEBUG_ENABLED" or "DEBUG_DISABLED"))
        elseif command == "reset" then
            if self.Database then
                self.Database:ResetProfile()
            end
            ReloadUI()
        elseif command == "reload" then
            self:Print(self:Loc("RELOADING_MODULES"))
            self:ReloadAllModules()
        else
            self:Print(self:Loc("SLASH_UNKNOWN"))
        end
    end
end

-- Sound registration API
function BLU:RegisterSound(soundId, soundData)
    self.soundRegistry[soundId] = soundData
    self:PrintDebug(self:Loc("SOUND_REGISTERED", soundId) or ("Registered sound: " .. soundId))
end

function BLU:UnregisterSound(soundId)
    self.soundRegistry[soundId] = nil
end

function BLU:GetSound(soundId)
    return self.soundRegistry[soundId]
end

function BLU:PlaySound(soundId, volume)
    local sound = self.soundRegistry[soundId]
    if not sound then
        self:PrintDebug(self:Loc("ERROR_SOUND_NOT_FOUND", soundId) or ("Sound not found: " .. soundId))
        return
    end
    
    volume = volume or 1.0
    local channel = self.db and self.db.soundChannel or "Master"
    PlaySoundFile(sound.file, channel)
end

-- Module loading from settings
function BLU:LoadModulesFromSettings()
    if not self.db then return end
    
    -- Load enabled feature modules
    local features = {
        {key = "enableLevelUp", module = "levelUp"},
        {key = "enableAchievement", module = "achievement"},
        {key = "enableReputation", module = "reputation"},
        {key = "enableQuest", module = "quest"},
        {key = "enableBattlePet", module = "battlePet"},
        {key = "enableDelveCompanion", module = "delveCompanion"},
        {key = "enableHonorRank", module = "honorRank"},
        {key = "enableRenownRank", module = "renownRank"},
        {key = "enableTradingPost", module = "tradingPost"}
    }
    
    for _, feature in ipairs(features) do
        if self.db[feature.key] then
            self:LoadModule("features", feature.module)
        end
    end
    
    -- Load sound modules for selected games
    local soundsToLoad = {}
    
    -- Collect all unique sound modules needed
    local soundSettings = {
        "levelUpSound", "achievementSound", "reputationSound",
        "questAcceptSound", "questTurnInSound", "battlePetSound",
        "delveCompanionSound", "honorRankSound", "renownRankSound",
        "tradingPostSound"
    }
    
    for _, setting in ipairs(soundSettings) do
        local soundName = self.db[setting]
        if soundName and soundName ~= "None" then
            local game = soundName:match("^(%w+)_")
            if game then
                soundsToLoad[game:lower()] = true
            end
        end
    end
    
    -- Load required sound modules
    for soundModule in pairs(soundsToLoad) do
        self:LoadModule("sounds", soundModule)
    end
end

-- Load module
function BLU:LoadModule(moduleType, moduleName)
    -- This will be implemented by ModuleLoader
    if self.modules.ModuleLoader then
        return self.modules.ModuleLoader:LoadModule(moduleType, moduleName)
    end
end

-- Update module loading
function BLU:UpdateModuleLoading(feature, enabled)
    if enabled then
        self:LoadModule("features", feature)
    else
        self:UnloadModule(feature)
    end
end

-- Unload module
function BLU:UnloadModule(moduleName)
    if self.modules.ModuleLoader then
        return self.modules.ModuleLoader:UnloadModule(moduleName)
    end
end

-- Reload all modules
function BLU:ReloadAllModules()
    -- Unload all feature modules
    for moduleName in pairs(self.LoadedModules or {}) do
        self:UnloadModule(moduleName)
    end
    
    -- Reload based on current settings
    self:LoadModulesFromSettings()
    
    self:Print("Modules reloaded successfully")
end

-- Module registration
local Core = {}

function Core:Init()
    -- Core is already initialized by framework
    BLU:PrintDebug(BLU:Loc("MODULE_LOADED", "Core"))
end

-- Export
BLU:RegisterModule("Core", Core)
return Core