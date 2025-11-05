--=====================================================================================
-- BLU | Proper Initialization Manager
-- Author: donniedice
-- Description: Centralized initialization to prevent duplicates and ensure proper order
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

-- Track what's been initialized
BLU.initialized = {}

-- Main initialization function
function BLU:Initialize()
    BLU:PrintDebug("[Init] BLU:Initialize() called.")
    if self.isInitialized then
        BLU:PrintDebug("[Init] Already initialized, skipping.")
        return
    end
    
    BLU:PrintDebug("[Init] Starting BLU initialization")
    BLU:PrintDebug("[Init] BLU.db before Phase 1: " .. tostring(BLU.db))
    BLU:PrintDebug("[Init] BLUDB global before Phase 1: " .. tostring(_G["BLUDB"]))
    
    -- Phase 1: Core Systems (must be first)
    self:InitializePhase("core", {
        "database",        -- Database must be first
        "config",         -- Configuration system
        "utils",          -- Utility functions
        "combat_protection", -- Combat lockdown protection
        "sounds"          -- Sound muting/unmuting
    })

    BLU:PrintDebug("[Init] BLU.db after Phase 1: " .. tostring(BLU.db))
    BLU:PrintDebug("[Init] BLUDB global after Phase 1: " .. tostring(_G["BLUDB"]))
    
    -- Phase 2: Registry and Loader
    self:InitializePhase("registry", {
        "registry",
        "loader",
        "sharedmedia"
    })
    
    BLU:PrintDebug("[Init] BLU.db after Phase 2: " .. tostring(BLU.db))
    
    -- Phase 3: Interface System
    self:InitializePhase("interface", {
        "options"  -- Main options panel
    })
    
    BLU:PrintDebug("[Init] BLU.db after Phase 3: " .. tostring(BLU.db))
    BLU:PrintDebug("[Init] Options panel created: " .. tostring(BLU.OptionsPanel ~= nil))
    BLU:PrintDebug("[Init] OpenOptions available: " .. tostring(BLU.OpenOptions ~= nil))
    
    -- Phase 4: Feature Modules
    self:InitializePhase("modules", {
        "quest",
        "levelup",
        "achievement",
        "reputation",
        "battlepet",
        "honor",
        "renown",
        "tradingpost",
        "delve"
    })
    
    BLU:PrintDebug("[Init] BLU.db after Phase 4: " .. tostring(BLU.db))
    
    -- Phase 5: Final Setup
    self:LoadSavedSettings()
    
    self.isInitialized = true
    BLU:PrintDebug("[Init] BLU:Initialize() finished. BLU.db is " .. tostring(self.db))
    BLU:PrintDebug("[Init] BLUDB global at end: " .. tostring(_G["BLUDB"]))
    BLU:PrintDebug("[Init] OpenOptions function: " .. tostring(BLU.OpenOptions))
    
    self:ShowWelcomeMessage()
end

-- Initialize a phase of modules
function BLU:InitializePhase(phaseName, moduleList)
    self:PrintDebug("[Init] Phase: " .. phaseName)
    
    for _, moduleName in ipairs(moduleList) do
        if not self.initialized[moduleName] then
            local success = self:InitializeModule(moduleName)
            if not success then
                self:PrintDebug("[Init] Warning: Module '" .. moduleName .. "' failed to initialize")
            end
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
        self:PrintDebug("[Init] Found module in BLU.Modules: " .. moduleName)
        module = self.Modules[moduleName]
    end
    
    -- Initialize if found
    if module then
        self:PrintDebug("[Init] Attempting to call Init for module: " .. moduleName)
        if module.Init then
            local success, err = pcall(function() module:Init() end)
            if success then
                self.initialized[moduleName] = true
                self:PrintDebug("[Init] Successfully initialized: " .. moduleName)
                return true
            else
                self:PrintError("[Init] Error initializing " .. moduleName .. ": " .. tostring(err))
                return false
            end
        else
            self:PrintDebug("[Init] Module has no Init method: " .. moduleName)
            self.initialized[moduleName] = true -- Mark as handled
            return false
        end
    else
        self:PrintDebug("[Init] Module not found: " .. moduleName)
        return false
    end
end

-- Load saved settings
function BLU:LoadSavedSettings()
    if self.initialized.savedSettings then
        return
    end
    
    -- Ensure database exists
    if not self.db then
        if self.Modules and self.Modules.database and self.Modules.database.InitializeDatabase then
            self.Modules.database:InitializeDatabase()
        else
            self:PrintError("[Init] Cannot load settings - database not available")
            return
        end
    end
    
    -- Apply saved settings
    if self.db and self.db.profile then
        if self.db.profile.enabled == false then
            self:Print("|cffff0000BLU is currently disabled|r")
        end
        
        -- Sync debug mode
        if self.db.profile.debugMode ~= nil then
            self.debugMode = self.db.profile.debugMode
        end
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
    self:Print("  |cffffff00/blu status|r - Show addon status")
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
BLU:RegisterEvent("ADDON_LOADED", function(event, loadedAddonName)
    if loadedAddonName == "BLU" then
        BLU:PrintDebug("[Init] ADDON_LOADED event fired for BLU")
        
        -- Small delay to ensure everything is loaded
        C_Timer.After(0.1, function()
            BLU:Initialize()
            
            -- Verify initialization
            BLU:PrintDebug("[Init] Post-initialization check:")
            BLU:PrintDebug("[Init]   BLU.db: " .. tostring(BLU.db ~= nil))
            BLU:PrintDebug("[Init]   BLU.OpenOptions: " .. tostring(BLU.OpenOptions ~= nil))
            BLU:PrintDebug("[Init]   BLU.OptionsPanel: " .. tostring(BLU.OptionsPanel ~= nil))
            
            -- Test if /blu command works
            if BLU.OpenOptions then
                BLU:PrintDebug("[Init] /blu command should now work!")
            else
                BLU:PrintError("[Init] OpenOptions not available after initialization!")
            end
        end)
        
        -- Unregister this event
        BLU:UnregisterEvent("ADDON_LOADED", "core")
    end
end, "core")