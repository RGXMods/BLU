--=====================================================================================
-- BLU | Proper Initialization Manager
-- Author: donniedice
-- Description: Centralized initialization to prevent duplicates and ensure proper order
--=====================================================================================

local addonName, BLU = ...

-- Track what's been initialized
BLU.initialized = {}

-- Main initialization function
function BLU:Initialize()
    if self.isInitialized then
        return
    end
    
    self:PrintDebug("[Init] Starting BLU initialization")
    
    -- Phase 1: Core Systems (must be first)
    self:InitializePhase("core", {
        "database",        -- Database must be first
        "database_safety", -- Safety wrapper for database
        "config",         -- Configuration system
        "utils",          -- Utility functions
        "combat_protection" -- Combat lockdown protection
    })
    
    -- Phase 2: Sound Systems
    self:InitializePhase("sound", {
        "registry",       -- Sound registry
        "internal_sounds", -- Internal BLU sounds
        "sharedmedia"     -- SharedMedia integration
    })
    
    -- Phase 3: Interface
    self:InitializePhase("interface", {
        "localization",   -- Localization strings
        "design",         -- Design system (from modules/interface)
        "widgets",        -- Widget library
        "tabs",           -- Tab system
        "options_new"     -- Options panel (from modules/interface)
    })
    
    -- Phase 4: Feature Modules
    self:InitializePhase("features", {
        "levelup",
        "achievement", 
        "quest",
        "reputation",
        "battlepet",
        "honor",
        "renown",
        "tradingpost",
        "delve"
    })
    
    -- Phase 5: Final Setup
    self:RegisterSlashCommand()
    self:LoadSavedSettings()
    
    self.isInitialized = true
    self:Print("|cff00ccffBLU|r initialized successfully - Type |cffffff00/blu|r for options")
end

-- Initialize a phase of modules
function BLU:InitializePhase(phaseName, moduleList)
    self:PrintDebug("[Init] Phase: " .. phaseName)
    
    for _, moduleName in ipairs(moduleList) do
        if not self.initialized[moduleName] then
            self:InitializeModule(moduleName)
        end
    end
end

-- Initialize a single module
function BLU:InitializeModule(moduleName)
    -- Check if already initialized
    if self.initialized[moduleName] then
        self:PrintDebug("[Init] Module already initialized: " .. moduleName)
        return true
    end
    
    -- Find the module
    local module = nil
    
    -- Check in BLU.Modules
    if self.Modules and self.Modules[moduleName] then
        module = self.Modules[moduleName]
    -- Check special cases
    elseif moduleName == "database_safety" and self.InitializeDatabase then
        self:InitializeDatabase()
        self.initialized[moduleName] = true
        self:PrintDebug("[Init] Initialized: database_safety")
        return true
    elseif moduleName == "combat_protection" and self.InitializeCombatProtection then
        self:InitializeCombatProtection()
        self.initialized[moduleName] = true
        self:PrintDebug("[Init] Initialized: combat_protection")
        return true
    elseif moduleName == "localization" then
        if Localization and Localization.Init then
            Localization:Init()
            self.initialized[moduleName] = true
            self:PrintDebug("[Init] Initialized: localization")
            return true
        end
    -- Check in feature modules (they register themselves differently)
    elseif moduleName == "levelup" and LevelUp then
        module = LevelUp
    elseif moduleName == "achievement" and Achievement then
        module = Achievement
    elseif moduleName == "quest" and Quest then
        module = Quest
    elseif moduleName == "reputation" and Reputation then
        module = Reputation
    elseif moduleName == "battlepet" and BattlePet then
        module = BattlePet
    elseif moduleName == "honor" and HonorRank then
        module = HonorRank
    elseif moduleName == "renown" and RenownRank then
        module = RenownRank
    elseif moduleName == "tradingpost" and TradingPost then
        module = TradingPost
    elseif moduleName == "delve" and DelveCompanion then
        module = DelveCompanion
    end
    
    -- Initialize if found
    if module then
        if module.Init then
            module:Init()
            self.initialized[moduleName] = true
            self:PrintDebug("[Init] Initialized: " .. moduleName)
            return true
        else
            self:PrintDebug("[Init] Module has no Init: " .. moduleName)
            self.initialized[moduleName] = true -- Mark as handled
            return false
        end
    else
        self:PrintDebug("[Init] Module not found: " .. moduleName)
        return false
    end
end

-- Register slash command
function BLU:RegisterSlashCommand()
    if self.initialized.slashCommand then
        return
    end
    
    SLASH_BLU1 = "/blu"
    SlashCmdList["BLU"] = function(msg)
        msg = msg:trim():lower()
        
        if msg == "" or msg == "options" or msg == "config" then
            self:OpenOptions()
        elseif msg == "test" then
            self:PlayTestSound("levelup")
        elseif msg == "debug" then
            self.db.debugMode = not self.db.debugMode
            self:Print("Debug mode " .. (self.db.debugMode and "enabled" or "disabled"))
        elseif msg == "reload" then
            ReloadUI()
        elseif msg == "help" then
            self:ShowHelp()
        else
            self:ShowHelp()
        end
    end
    
    self.initialized.slashCommand = true
    self:PrintDebug("[Init] Slash command registered")
end

-- Open options panel
function BLU:OpenOptions()
    -- Try modules/interface/options_new first
    if self.Modules and self.Modules.options_new and self.Modules.options_new.OpenOptions then
        self.Modules.options_new:OpenOptions()
        return
    end
    
    -- Fallback to simple message
    self:Print("Options panel not available. Please check your installation.")
end

-- Load saved settings
function BLU:LoadSavedSettings()
    if self.initialized.savedSettings then
        return
    end
    
    -- Ensure database exists
    if not self.db then
        if self.Modules and self.Modules.database and self.Modules.database.GetDB then
            self.db = self.Modules.database:GetDB()
        else
            self.db = {}
        end
    end
    
    -- Apply saved settings
    if self.db.enabled == false then
        self:Print("|cffff0000BLU is currently disabled|r")
    end
    
    self.initialized.savedSettings = true
    self:PrintDebug("[Init] Saved settings loaded")
end

-- Show help
function BLU:ShowHelp()
    self:Print("BLU Commands:")
    self:Print("  |cffffff00/blu|r - Open options")
    self:Print("  |cffffff00/blu test|r - Play test sound")
    self:Print("  |cffffff00/blu debug|r - Toggle debug mode")
    self:Print("  |cffffff00/blu reload|r - Reload UI")
    self:Print("  |cffffff00/blu help|r - Show this help")
end

-- Play test sound
function BLU:PlayTestSound(eventType)
    if self.Modules and self.Modules.registry and self.Modules.registry.PlaySound then
        self.Modules.registry:PlaySound(eventType or "levelup")
        self:Print("Playing test sound: " .. (eventType or "levelup"))
    else
        self:Print("Sound system not available")
    end
end

-- Hook into ADDON_LOADED
BLU:RegisterEvent("ADDON_LOADED", function(event, addon)
    if addon ~= addonName then return end
    
    -- Initialize everything
    BLU:Initialize()
    
    -- Unregister this event
    BLU:UnregisterEvent("ADDON_LOADED")
end)

-- Hook into PLAYER_LOGIN for final setup
BLU:RegisterEvent("PLAYER_LOGIN", function()
    -- Final initialization tasks that require player to be fully loaded
    if BLU.Modules and BLU.Modules.options_new then
        -- Ensure options panel is created
        if not BLU.OptionsPanel and BLU.Modules.options_new.CreateOptionsPanel then
            BLU.Modules.options_new:CreateOptionsPanel()
        end
    end
    
    BLU:PrintDebug("[Init] PLAYER_LOGIN complete")
end)