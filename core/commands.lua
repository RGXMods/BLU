BLU:PrintDebug("core/commands.lua loaded.")
--=====================================================================================
-- BLU - core/commands.lua
-- Slash command handling
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

local function ParseCommandInput(msg)
    if type(msg) ~= "string" then
        return "", ""
    end

    msg = msg:gsub("^%s+", ""):gsub("%s+$", "")
    if msg == "" then
        return "", ""
    end

    local command, rest = msg:match("^(%S+)%s*(.-)$")
    return (command or ""):lower(), rest or ""
end

-- Register slash commands
SLASH_BLU1 = "/blu"
SLASH_BLU2 = "/bluesound"

SlashCmdList["BLU"] = function(msg)
    BLU:PrintDebug("/blu command executed with message: " .. tostring(msg))
    local command, rest = ParseCommandInput(msg)
    BLU:PrintDebug("[Commands] Parsed /blu command to command='" .. tostring(command) .. "', rest='" .. tostring(rest) .. "'")
    
    -- Check if database is ready
    if not BLU.db then
        BLU:Print("|cffff9900BLU is still loading...|r")
        BLU:Print("Please wait a moment and try again.")
        BLU:PrintDebug("Database not ready. BLU.db is " .. tostring(BLU.db))
        BLU:PrintDebug("BLUDB global is " .. tostring(_G["BLUDB"]))
        return
    end
    
    if command == "" or command == "options" or command == "config" then
        BLU:PrintDebug("[Commands] Opening options")
        -- Try to open options
        if BLU.OpenOptions then
            BLU:OpenOptions()
        else
            BLU:Print("|cff00ccffBLU:|r Options panel not available yet. Please wait a moment and try again.")
        end
    elseif command == "debug" then
        BLU:PrintDebug("[Commands] Toggling debug mode")
        if BLU.db then
            BLU.db.debugMode = not BLU.db.debugMode
            BLU.debugMode = BLU.db.debugMode
            BLU:Print("|cff00ccffBLU:|r Debug mode " .. (BLU.db.debugMode and "enabled" or "disabled"))
        else
            BLU:Print("|cff00ccffBLU:|r Database not loaded yet")
        end
    elseif command == "enable" then
        BLU:PrintDebug("[Commands] Enabling addon")
        if BLU.db then
            BLU.db.enabled = true
            if BLU.Enable then
                BLU:Enable()
            end
            BLU:Print("|cff00ff00BLU Enabled|r")
        end
    elseif command == "disable" then
        BLU:PrintDebug("[Commands] Disabling addon")
        if BLU.db then
            BLU.db.enabled = false
            if BLU.Disable then
                BLU:Disable()
            end
            BLU:Print("|cffff0000BLU Disabled|r")
        end
    elseif command == "status" then
        BLU:PrintDebug("[Commands] Showing addon status")
        BLU:Print("|cff00ccffBLU Status:|r")
        BLU:Print("  Database: " .. (BLU.db and "|cff00ff00Loaded|r" or "|cffff0000Not Loaded|r"))
        BLU:Print("  Options Panel: " .. (BLU.OptionsPanel and "|cff00ff00Created|r" or "|cffff9900Not Created|r"))
        BLU:Print("  Enabled: " .. ((BLU.db and BLU.db.enabled) and "|cff00ff00Yes|r" or "|cffff0000No|r"))
        BLU:Print("  Debug Mode: " .. (BLU.debugMode and "|cff00ff00On|r" or "|cff808080Off|r"))
    elseif command == "refresh" or command == "rescan" then
        BLU:PrintDebug("[Commands] Refreshing external sounds")
        if BLU.RefreshUserSounds then
            BLU:RefreshUserSounds()
            BLU:Print("|cff00ccffBLU:|r Rescanning user custom sounds...")
        end
    elseif command == "addcustom" then
        BLU:PrintDebug("[Commands] Adding profile custom sound")
        local soundPath, displayName = rest:match("^(.-)%s*|%s*(.+)$")
        soundPath = soundPath or rest
        soundPath = soundPath and soundPath:gsub("^%s+", ""):gsub("%s+$", "") or ""

        if soundPath == "" then
            BLU:Print("|cff00ccffBLU:|r Usage: /blu addcustom myfile[.ogg] | Optional Name")
            return
        end

        if BLU.Modules and BLU.Modules["usersounds"] and BLU.Modules["usersounds"].AddCustomSound then
            local ok, result, resolvedPath = BLU.Modules["usersounds"]:AddCustomSound(soundPath, displayName)
            if ok then
                if resolvedPath and displayName then
                    BLU:Print("|cff00ccffBLU:|r Added custom sound: " .. tostring(result) .. " (" .. tostring(resolvedPath) .. ")")
                else
                    BLU:Print("|cff00ccffBLU:|r Added custom sound: " .. tostring(result))
                end
            else
                BLU:Print("|cff00ccffBLU:|r Failed to add custom sound: " .. tostring(result))
            end
        end
    elseif command == "removecustom" then
        BLU:PrintDebug("[Commands] Removing profile custom sound")
        local matchValue = rest and rest:gsub("^%s+", ""):gsub("%s+$", "") or ""
        if matchValue == "" then
            BLU:Print("|cff00ccffBLU:|r Usage: /blu removecustom Interface\\AddOns\\file.ogg")
            return
        end

        if BLU.Modules and BLU.Modules["usersounds"] and BLU.Modules["usersounds"].RemoveCustomSound then
            local ok, err = BLU.Modules["usersounds"]:RemoveCustomSound(matchValue)
            if ok then
                BLU:Print("|cff00ccffBLU:|r Removed custom sound: " .. matchValue)
            else
                BLU:Print("|cff00ccffBLU:|r Failed to remove custom sound: " .. tostring(err))
            end
        end
    elseif command == "help" then
        BLU:PrintDebug("[Commands] Showing help")
        BLU:Print("|cff00ccffBLU Commands:|r")
        BLU:Print("  |cffffff00/blu|r - Open options")
        BLU:Print("  |cffffff00/blu debug|r - Toggle debug mode")
        BLU:Print("  |cffffff00/blu status|r - Show addon status")
        BLU:Print("  |cffffff00/blu refresh|r - Rescan external sound packs")
        BLU:Print("  |cffffff00/blu addcustom <file or path> | <name>|r - Add a custom sound file")
        BLU:Print("  |cffffff00/blu removecustom <path>|r - Remove a custom sound file")
        BLU:Print("  |cffffff00/blu enable|r - Enable addon")
        BLU:Print("  |cffffff00/blu disable|r - Disable addon")
        BLU:Print("  |cffffff00/blu help|r - Show this help")
    else
        -- Unknown command, show help
        BLU:PrintDebug("[Commands] Unknown /blu command: '" .. tostring(command) .. "'")
        BLU:Print("|cff00ccffBLU:|r Unknown command. Type |cffffff00/blu help|r for help.")
    end
end

-- Test command for simulating events
SLASH_BLUTEST1 = "/blutest"
SlashCmdList["BLUTEST"] = function(event)
    BLU:PrintDebug("[Commands] /blutest invoked with '" .. tostring(event) .. "'")
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
        BLU:PrintDebug("[Commands] /blutest requested usage output")
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
        BLU:PrintDebug("[Commands] Simulating event '" .. tostring(event:lower()) .. "'")
        handler()
    else
        BLU:PrintDebug("[Commands] Unknown /blutest event '" .. tostring(event) .. "'")
        BLU:Print("Unknown event: " .. event)
        local available_events = ""
        for eventName, _ in pairs(events) do
            available_events = available_events .. eventName .. ", "
        end
        BLU:Print("Available events: " .. available_events:sub(1, -3))
    end
end
