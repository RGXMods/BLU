--=====================================================================================
-- BLU | Better Level-Up! - initialization.lua
-- Simplified initialization for retail-only support with modular architecture
--=====================================================================================

local addonName, addonTable = ...

-- Load core module first
local CoreModule = assert(loadfile("Interface\\AddOns\\BLU\\modules\\Core.lua"))()

-- Load module loader
local ModuleLoader = assert(loadfile("Interface\\AddOns\\BLU\\modules\\ModuleLoader.lua"))()

-- Initialize localization
BLU_L = BLU_L or {}

-- Simple initialization complete message
function BLU:PrintInitMessage()
    if self.debugMode then
        self:Print("BLU Modular System Initialized")
        self:Print("Loaded Modules: " .. table.concat(self:GetLoadedModuleNames(), ", "))
    end
end

-- Get list of loaded module names
function BLU:GetLoadedModuleNames()
    local names = {}
    for name in pairs(self.LoadedModules or {}) do
        table.insert(names, name)
    end
    return names
end

-- Export initialization
return true