--=====================================================================================
-- BLU Initialization
-- Bootstrap the addon
--=====================================================================================

local addonName, addonTable = ...

-- Initialize core systems
BLU:RegisterEvent("ADDON_LOADED", function(event, addon)
    if addon ~= addonName then return end
    
    -- Initialize modules in order
    local initOrder = {
        "EventManager",
        "Localization",
        "Config",
        "Utils",
        "SoundRegistry",
        "SoundPakBridge",
        "GameSoundBrowser",
        "ModuleLoader",
        "Options"
    }
    
    for _, moduleName in ipairs(initOrder) do
        local module = BLU:GetModule(moduleName)
        if module and module.Init then
            module:Init()
        end
    end
    
    -- Load feature modules based on settings
    if BLU.LoadModulesFromSettings then
        BLU:LoadModulesFromSettings()
    end
    
    BLU:PrintDebug("BLU initialized successfully")
end)

-- Player login
BLU:RegisterEvent("PLAYER_LOGIN", function()
    if BLU.db and BLU.db.showWelcomeMessage then
        BLU:Print(BLU:Loc("ADDON_LOADED", BLU.version))
    end
end)