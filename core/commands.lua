BLU:PrintDebug("core/commands.lua loaded.")
--=====================================================================================
-- BLU - core/commands.lua
-- Slash command handling
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

-- Register slash commands
SLASH_BLU1 = "/blu"
SLASH_BLU2 = "/bluesound"

SlashCmdList["BLU"] = function(msg)
    BLU:PrintDebug("/blu command executed with message: " .. tostring(msg))
    msg = (msg or ""):trim():lower()
    
    -- Check if database is ready
    if not BLU.db then
        BLU:Print("|cffff9900BLU is still loading...|r")
        BLU:Print("Please wait a moment and try again.")
        BLU:PrintDebug("Database not ready. BLU.db is " .. tostring(BLU.db))
        BLU:PrintDebug("BLUDB global is " .. tostring(_G["BLUDB"]))
        return
    end
    
    if msg == "" or msg == "options" or msg == "config" then
        -- Try to open options
        if BLU.OpenOptions then
            BLU:OpenOptions()
        else
            BLU:Print("|cff00ccffBLU:|r Options panel not available yet. Please wait a moment and try again.")
        end
    elseif msg == "test" then
        if BLU.PlayTestSound then
            BLU:PlayTestSound("levelup")
        else
            BLU:Print("|cff00ccffBLU:|r Playing test sound...")
        end
    elseif msg == "debug" then
        if BLU.db and BLU.db.profile then
            BLU.db.profile.debugMode = not BLU.db.profile.debugMode
            BLU.debugMode = BLU.db.profile.debugMode
            BLU:Print("|cff00ccffBLU:|r Debug mode " .. (BLU.db.profile.debugMode and "enabled" or "disabled"))
        else
            BLU:Print("|cff00ccffBLU:|r Database not loaded yet")
        end
    elseif msg == "enable" then
        if BLU.db and BLU.db.profile then
            BLU.db.profile.enabled = true
            if BLU.Enable then
                BLU:Enable()
            end
            BLU:Print("|cff00ff00BLU Enabled|r")
        end
    elseif msg == "disable" then
        if BLU.db and BLU.db.profile then
            BLU.db.profile.enabled = false
            if BLU.Disable then
                BLU:Disable()
            end
            BLU:Print("|cffff0000BLU Disabled|r")
        end
    elseif msg == "status" then
        BLU:Print("|cff00ccffBLU Status:|r")
        BLU:Print("  Database: " .. (BLU.db and "|cff00ff00Loaded|r" or "|cffff0000Not Loaded|r"))
        BLU:Print("  Options Panel: " .. (BLU.OptionsPanel and "|cff00ff00Created|r" or "|cffff9900Not Created|r"))
        BLU:Print("  Enabled: " .. ((BLU.db and BLU.db.profile and BLU.db.profile.enabled) and "|cff00ff00Yes|r" or "|cffff0000No|r"))
        BLU:Print("  Debug Mode: " .. (BLU.debugMode and "|cff00ff00On|r" or "|cff808080Off|r"))
    elseif msg == "help" then
        BLU:Print("|cff00ccffBLU Commands:|r")
        BLU:Print("  |cffffff00/blu|r - Open options")
        BLU:Print("  |cffffff00/blu test|r - Play test sound")
        BLU:Print("  |cffffff00/blu debug|r - Toggle debug mode")
        BLU:Print("  |cffffff00/blu status|r - Show addon status")
        BLU:Print("  |cffffff00/blu enable|r - Enable addon")
        BLU:Print("  |cffffff00/blu disable|r - Disable addon")
        BLU:Print("  |cffffff00/blu help|r - Show this help")
    else
        -- Unknown command, show help
        BLU:Print("|cff00ccffBLU:|r Unknown command. Type |cffffff00/blu help|r for help.")
    end
end

-- Test command for simulating events
SLASH_BLUTEST1 = "/blutest"
SlashCmdList["BLUTEST"] = function(event)
    if not BLU.db then
        BLU:Print("Database not loaded yet")
        return
    end

    local events = {}
    for moduleName, module in pairs(BLU.Modules) do
        for functionName, _ in pairs(module) do
            if functionName:find("^On") then
                local eventName = functionName:gsub("On", ""):lower()
                events[eventName] = function()
                    BLU:Print("Simulating " .. functionName .. "...")
                    if module[functionName] then
                        module[functionName](module)
                    end
                end
            end
        end
    end

    if event == "" then
        BLU:Print("Usage: /blutest [event]")
        local available_events = ""
        for eventName, _ in pairs(events) do
            available_events = available_events .. eventName .. ", "
        end
        BLU:Print("Available events: " .. available_events:sub(1, -3))
        return
    end

    local handler = events[event:lower()]
    if handler then
        handler()
    else
        BLU:Print("Unknown event: " .. event)
        local available_events = ""
        for eventName, _ in pairs(events) do
            available_events = available_events .. eventName .. ", "
        end
        BLU:Print("Available events: " .. available_events:sub(1, -3))
    end
end