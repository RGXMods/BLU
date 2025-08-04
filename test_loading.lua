-- BLU Loading Test
-- This file helps diagnose loading issues

local addonName, BLU = ...

-- Hook into various loading stages
local loadingStages = {}

local function LogStage(stage, detail)
    table.insert(loadingStages, {
        stage = stage,
        detail = detail or "",
        time = GetTime()
    })
end

-- Override RegisterEvent to track registrations
local originalRegisterEvent = BLU.RegisterEvent
BLU.RegisterEvent = function(self, event, handler)
    LogStage("RegisterEvent", event)
    return originalRegisterEvent(self, event, handler)
end

-- Hook into module loading
local originalLoadModule = BLU.LoadModule
if originalLoadModule then
    BLU.LoadModule = function(self, moduleType, moduleName)
        LogStage("LoadModule", moduleType .. ":" .. moduleName)
        return originalLoadModule(self, moduleType, moduleName)
    end
end

-- Add debug command
SLASH_BLUTEST1 = "/blutest"
SlashCmdList["BLUTEST"] = function()
    print("|cff05dffa=== BLU Loading Test ===|r")
    print("Modules loaded:", BLU.Modules and #BLU.Modules or "nil")
    
    if BLU.Modules then
        print("Available modules:")
        for k, v in pairs(BLU.Modules) do
            print("  -", k, type(v))
        end
    end
    
    print("\nLoading stages:")
    for i, stage in ipairs(loadingStages) do
        print(string.format("  [%.2f] %s: %s", stage.time, stage.stage, stage.detail))
    end
    
    print("\nDatabase status:")
    print("  BLU.db:", BLU.db and "loaded" or "nil")
    if BLU.db then
        print("  Profile:", BLU.db.profile and "loaded" or "nil")
        if BLU.db.profile then
            print("  Enabled:", BLU.db.profile.enabled)
            print("  Sound volume:", BLU.db.profile.soundVolume)
        end
    end
    
    print("\nOptions status:")
    print("  OptionsPanel:", BLU.OptionsPanel and "created" or "nil")
    print("  OptionsCategory:", BLU.OptionsCategory and "registered" or "nil")
    print("  OpenOptions function:", BLU.OpenOptions and "available" or "nil")
end