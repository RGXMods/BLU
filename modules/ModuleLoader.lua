--=====================================================================================
-- BLU Module Loader System
-- Handles dynamic loading and unloading of modules based on user settings
--=====================================================================================

local addonName, addonTable = ...
BLU = BLU or {}
BLU.Modules = BLU.Modules or {}
BLU.LoadedModules = {}

-- Module registry
local moduleRegistry = {
    -- Core modules (always loaded)
    core = {
        "Core",
        "Config",
        "Utils",
        "Localization"
    },
    
    -- Feature modules (loaded on demand)
    features = {
        levelUp = "modules/features/LevelUp.lua",
        achievement = "modules/features/Achievement.lua",
        reputation = "modules/features/Reputation.lua",
        quest = "modules/features/Quest.lua",
        battlePet = "modules/features/BattlePet.lua",
        delveCompanion = "modules/features/DelveCompanion.lua",
        honorRank = "modules/features/HonorRank.lua",
        renownRank = "modules/features/RenownRank.lua",
        tradingPost = "modules/features/TradingPost.lua"
    },
    
    -- Sound modules (loaded per game selection)
    sounds = {
        finalfantasy = "modules/sounds/FinalFantasy.lua",
        zelda = "modules/sounds/Zelda.lua",
        pokemon = "modules/sounds/Pokemon.lua",
        mario = "modules/sounds/Mario.lua",
        skyrim = "modules/sounds/Skyrim.lua",
        warcraft = "modules/sounds/Warcraft.lua",
        eldenring = "modules/sounds/EldenRing.lua",
        darksouls = "modules/sounds/DarkSouls.lua",
        witcher = "modules/sounds/Witcher.lua",
        metalgear = "modules/sounds/MetalGear.lua"
    }
}

-- Module loader function
function BLU:LoadModule(moduleType, moduleName)
    local modulePath = moduleRegistry[moduleType] and moduleRegistry[moduleType][moduleName]
    
    if not modulePath then
        self:PrintDebug("Module not found: " .. tostring(moduleName))
        return false
    end
    
    -- Check if already loaded
    if self.LoadedModules[moduleName] then
        self:PrintDebug("Module already loaded: " .. moduleName)
        return true
    end
    
    -- Load the module
    local success, module = pcall(function()
        return assert(loadfile("Interface\\AddOns\\BLU\\" .. modulePath))()
    end)
    
    if success then
        self.LoadedModules[moduleName] = module
        self:PrintDebug("Successfully loaded module: " .. moduleName)
        
        -- Initialize module if it has an Init function
        if module and type(module.Init) == "function" then
            module:Init()
        end
        
        return true
    else
        self:PrintDebug("Failed to load module: " .. moduleName .. " - " .. tostring(module))
        return false
    end
end

-- Module unloader function
function BLU:UnloadModule(moduleName)
    if not self.LoadedModules[moduleName] then
        return
    end
    
    local module = self.LoadedModules[moduleName]
    
    -- Call cleanup if available
    if module and type(module.Cleanup) == "function" then
        module:Cleanup()
    end
    
    -- Unregister events if available
    if module and type(module.UnregisterEvents) == "function" then
        module:UnregisterEvents()
    end
    
    self.LoadedModules[moduleName] = nil
    self:PrintDebug("Unloaded module: " .. moduleName)
end

-- Load modules based on saved settings
function BLU:LoadModulesFromSettings()
    local db = self.db.profile
    
    -- Load enabled feature modules
    if db.enableLevelUp then self:LoadModule("features", "levelUp") end
    if db.enableAchievement then self:LoadModule("features", "achievement") end
    if db.enableReputation then self:LoadModule("features", "reputation") end
    if db.enableQuest then self:LoadModule("features", "quest") end
    if db.enableBattlePet then self:LoadModule("features", "battlePet") end
    if db.enableDelveCompanion then self:LoadModule("features", "delveCompanion") end
    if db.enableHonorRank then self:LoadModule("features", "honorRank") end
    if db.enableRenownRank then self:LoadModule("features", "renownRank") end
    if db.enableTradingPost then self:LoadModule("features", "tradingPost") end
    
    -- Load sound modules for selected games
    local soundsToLoad = {}
    
    -- Collect all unique sound modules needed
    local function addSoundModule(soundName)
        if soundName and soundName ~= "None" then
            local game = soundName:match("^(%w+)_")
            if game then
                soundsToLoad[game:lower()] = true
            end
        end
    end
    
    -- Check all sound selections
    addSoundModule(db.levelUpSound)
    addSoundModule(db.achievementSound)
    addSoundModule(db.reputationSound)
    addSoundModule(db.questAcceptSound)
    addSoundModule(db.questTurnInSound)
    addSoundModule(db.battlePetSound)
    addSoundModule(db.delveCompanionSound)
    addSoundModule(db.honorRankSound)
    addSoundModule(db.renownRankSound)
    addSoundModule(db.tradingPostSound)
    
    -- Load required sound modules
    for soundModule in pairs(soundsToLoad) do
        self:LoadModule("sounds", soundModule)
    end
end

-- Update module loading when settings change
function BLU:UpdateModuleLoading(feature, enabled)
    if enabled then
        self:LoadModule("features", feature)
    else
        self:UnloadModule(feature)
    end
end

-- Debug print function
function BLU:PrintDebug(message)
    if self.debugMode then
        print("|cff05dffaBLU Debug:|r " .. message)
    end
end