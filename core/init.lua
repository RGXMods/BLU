--=====================================================================================
-- BLU Initialization
-- Bootstrap the addon
--=====================================================================================

local addonName, addonTable = ...

-- Remove loading message - not needed

-- Initialize core systems
BLU:RegisterEvent("ADDON_LOADED", function(event, addon)
    if addon ~= addonName then return end
    
    -- ADDON_LOADED event fired
    
    -- Load saved variables first
    if BLU.LoadSettings then
        BLU:LoadSettings()
    end
    
    -- Initialize modules in order
    -- Note: Only modules with Init() functions need to be here
    local initOrder = {
        "database",      -- Has Init()
        "localization",  -- Has Init()
        "registry",      -- Has Init()
        "loader"         -- Has Init()
        -- "config" and "utils" don't have Init()
        -- "events" is loaded but doesn't need Init()
    }
    
    -- Debug: Print available modules (disabled for release)
    --[[
    if BLU.debugMode then
        print("|cff05dffaBLU Available modules:|r")
        if BLU.Modules then
            for k, v in pairs(BLU.Modules) do
                print("  - " .. k)
            end
        end
    end
    --]]
    
    for _, moduleName in ipairs(initOrder) do
        local module = BLU.Modules[moduleName]
        if module and module.Init then
            print("|cff05dffaBLU Initializing module: " .. moduleName .. "|r")
            module:Init()
        else
            print("|cffff0000BLU Module not found or has no Init: " .. moduleName .. "|r")
        end
    end
    
    -- Load feature modules based on settings
    if BLU.LoadModulesFromSettings then
        BLU:LoadModulesFromSettings()
    end
    
    -- Create simple options panel
    if BLU.CreateSimpleOptionsPanel then
        BLU:CreateSimpleOptionsPanel()
    else
        print("|cffff0000BLU: CreateSimpleOptionsPanel not found!|r")
    end
    
    BLU:PrintDebug("BLU initialized successfully")
    BLU.isInitialized = true
end)

BLU:RegisterEvent("PLAYER_LOGIN", function()
    -- Show welcome message
    if BLU.db and BLU.db.profile and BLU.db.profile.showWelcomeMessage then
        BLU:Print("v" .. (BLU.version or "Unknown") .. " loaded! Type |cff05dffa/blu|r for options")
        BLU:Print("Join our community at |cffffd700discord.gg/rgxmods|r")
        BLU:Print("|cff00ff00Build: 2025-08-04 - Simple options panel active|r")
    end
end)

-- Register for VARIABLES_LOADED to ensure database is ready
BLU:RegisterEvent("VARIABLES_LOADED", function()
    BLU:PrintDebug("Variables loaded - database should be ready")
end)

BLU:RegisterEvent("PLAYER_LOGOUT", function()
    if BLU.SaveSettings then
        BLU:SaveSettings()
    end
end)