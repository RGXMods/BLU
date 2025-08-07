--=====================================================================================
-- BLU - core/events.lua
-- Event handling system
--=====================================================================================

local addonName, BLU = ...

-- Event frame
local eventFrame = CreateFrame("Frame")
local events = {}

-- Register event
function BLU:RegisterEvent(event, handler)
    events[event] = handler
    eventFrame:RegisterEvent(event)
end

-- Unregister event
function BLU:UnregisterEvent(event)
    events[event] = nil
    eventFrame:UnregisterEvent(event)
end

-- Event handler
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if events[event] then
        events[event](event, ...)
    end
end)

-- Core initialization events
BLU:RegisterEvent("ADDON_LOADED", function(event, addon)
    if addon ~= addonName then return end
    
    -- Load settings
    BLU:LoadSettings()
    
    -- Unregister this event
    BLU:UnregisterEvent("ADDON_LOADED")
end)

BLU:RegisterEvent("PLAYER_LOGIN", function()
    -- Initialize options module if not already done
    if BLU.Modules.options_new and not BLU.LoadedModules["options_new"] then
        BLU:PrintDebug("Initializing options_new module during PLAYER_LOGIN")
        BLU.Modules.options_new:Init()
        BLU.LoadedModules["options_new"] = BLU.Modules.options_new
    end
    
    -- Create options panel for immediate addon settings registration
    if BLU.CreateOptionsPanel and not BLU.OptionsPanel then
        BLU:PrintDebug("Creating options panel during PLAYER_LOGIN for immediate registration")
        BLU:CreateOptionsPanel()
    end
    
    -- Show welcome
    if BLU.db.profile.showWelcomeMessage then
        BLU:Print("v" .. (BLU.version or "Unknown") .. " loaded! Type |cff05dffa/blu|r for options")
    end
end)