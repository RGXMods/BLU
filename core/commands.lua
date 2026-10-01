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

local function EnsureReadyForOptions()
    if not BLU then
        return false
    end

    if not BLU.db and BLU.Modules and BLU.Modules.database and BLU.Modules.database.Init then
        local ok, err = pcall(function()
            BLU.Modules.database:Init()
        end)
        if not ok then
            BLU:PrintError("[Commands] Database recovery failed: " .. tostring(err))
        end
    end

    if (not BLU.OpenOptions or not BLU.CreateOptionsPanel) and BLU.Initialize then
        local ok, err = pcall(function()
            BLU:Initialize()
        end)
        if not ok then
            BLU:PrintError("[Commands] Initialization recovery failed: " .. tostring(err))
        end
    end

    if (not BLU.OpenOptions or not BLU.CreateOptionsPanel)
        and BLU.Modules and BLU.Modules.options and BLU.Modules.options.Init then
        local ok, err = pcall(function()
            BLU.Modules.options:Init()
        end)
        if not ok then
            BLU:PrintError("[Commands] Options recovery failed: " .. tostring(err))
        end
    end

    if BLU.CreateOptionsPanel and not BLU.OptionsPanel then
        local ok, err = pcall(function()
            BLU:CreateOptionsPanel()
        end)
        if not ok then
            BLU:PrintError("[Commands] Options panel recovery failed: " .. tostring(err))
        end
    end

    return BLU.db ~= nil and BLU.OpenOptions ~= nil
end

-- Register slash commands
SLASH_BLU1 = "/blu"
SLASH_BLU2 = "/bluesound"

SlashCmdList["BLU"] = function(msg)
    BLU:PrintDebug("/blu command executed with message: " .. tostring(msg))
    local command, rest = ParseCommandInput(msg)
    BLU:PrintDebug("[Commands] Parsed /blu command to command='" .. tostring(command) .. "', rest='" .. tostring(rest) .. "'")
    
    -- Recover if the normal login/world initialization path did not complete.
    if not EnsureReadyForOptions() then
        BLU:Print(BLU:Loc("CMD_STILL_LOADING"))
        BLU:Print(BLU:Loc("CMD_PLEASE_WAIT"))
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
            BLU:Print(BLU:Loc("CMD_OPTIONS_UNAVAILABLE"))
        end
    elseif command == "debug" then
        BLU:PrintDebug("[Commands] Toggling debug mode")
        if BLU.db then
            BLU.db.debugMode = not BLU.db.debugMode
            BLU.debugMode = BLU.db.debugMode
            BLU:Print(BLU:Loc("CMD_DEBUG_ENABLED", BLU.db.debugMode and BLU:Loc("CMD_DEBUG_ON") or BLU:Loc("CMD_DEBUG_OFF")))
        else
            BLU:Print(BLU:Loc("CMD_DB_NOT_LOADED"))
        end
    elseif command == "enable" then
        BLU:PrintDebug("[Commands] Enabling addon")
        if BLU.db then
            BLU.db.enabled = true
            if BLU.Enable then
                BLU:Enable()
            end
            BLU:Print(BLU:Loc("CMD_ENABLED_MSG"))
        end
    elseif command == "disable" then
        BLU:PrintDebug("[Commands] Disabling addon")
        if BLU.db then
            BLU.db.enabled = false
            if BLU.Disable then
                BLU:Disable()
            end
            BLU:Print(BLU:Loc("CMD_DISABLED_MSG"))
        end
    elseif command == "icon" then
        BLU:PrintDebug("[Commands] Handling minimap icon command: " .. tostring(rest))
        local sub = (rest or ""):lower()
        if sub == "on" then
            if BLU.db then BLU.db.minimapIconEnabled = true end
            if BLU.Modules.minimap then BLU.Modules.minimap:SetIconVisible(true) end
            BLU:Print(BLU:Loc("CMD_ICON_SHOWN"))
        elseif sub == "off" then
            if BLU.db then BLU.db.minimapIconEnabled = false end
            if BLU.Modules.minimap then BLU.Modules.minimap:SetIconVisible(false) end
            BLU:Print(BLU:Loc("CMD_ICON_HIDDEN"))
        else
            BLU:Print(BLU:Loc("CMD_ICON_USAGE"))
        end
    elseif command == "status" then
        BLU:PrintDebug("[Commands] Showing addon status")
        BLU:Print(BLU:Loc("CMD_STATUS_HEADER"))
        BLU:Print(BLU:Loc("CMD_STATUS_DB", BLU.db and BLU:Loc("CMD_STATUS_DB_LOADED") or BLU:Loc("CMD_STATUS_DB_NOT_LOADED")))
        BLU:Print(BLU:Loc("CMD_STATUS_PANEL", BLU.OptionsPanel and BLU:Loc("CMD_STATUS_PANEL_CREATED") or BLU:Loc("CMD_STATUS_PANEL_NOT_CREATED")))
        BLU:Print(BLU:Loc("CMD_STATUS_ENABLED", (BLU.db and BLU.db.enabled) and BLU:Loc("CMD_STATUS_YES") or BLU:Loc("CMD_STATUS_NO")))
        BLU:Print(BLU:Loc("CMD_STATUS_DEBUG", BLU.debugMode and BLU:Loc("CMD_STATUS_ON") or BLU:Loc("CMD_STATUS_OFF")))
    elseif command == "refresh" or command == "rescan" then
        BLU:PrintDebug("[Commands] Refreshing external sounds")
        if BLU.RefreshUserSounds then
            BLU:RefreshUserSounds()
            BLU:Print(BLU:Loc("CMD_RESCANNING"))
        end
    elseif command == "addcustom" then
        BLU:PrintDebug("[Commands] Adding profile custom sound")
        local soundPath, displayName = rest:match("^(.-)%s*|%s*(.+)$")
        soundPath = soundPath or rest
        soundPath = soundPath and soundPath:gsub("^%s+", ""):gsub("%s+$", "") or ""

        if soundPath == "" then
            BLU:Print(BLU:Loc("CMD_ADDCUSTOM_USAGE"))
            return
        end

        if BLU.Modules and BLU.Modules["usersounds"] and BLU.Modules["usersounds"].AddCustomSound then
            local ok, result, resolvedPath = BLU.Modules["usersounds"]:AddCustomSound(soundPath, displayName)
            if ok then
                if resolvedPath and displayName then
                    BLU:Print(BLU:Loc("CMD_ADDCUSTOM_ADDED_PATH", tostring(result), tostring(resolvedPath)))
                else
                    BLU:Print(BLU:Loc("CMD_ADDCUSTOM_ADDED", tostring(result)))
                end
            else
                BLU:Print(BLU:Loc("CMD_ADDCUSTOM_FAILED", tostring(result)))
            end
        end
    elseif command == "removecustom" then
        BLU:PrintDebug("[Commands] Removing profile custom sound")
        local matchValue = rest and rest:gsub("^%s+", ""):gsub("%s+$", "") or ""
        if matchValue == "" then
            BLU:Print(BLU:Loc("CMD_REMOVECUSTOM_USAGE"))
            return
        end

        if BLU.Modules and BLU.Modules["usersounds"] and BLU.Modules["usersounds"].RemoveCustomSound then
            local ok, err = BLU.Modules["usersounds"]:RemoveCustomSound(matchValue)
            if ok then
                BLU:Print(BLU:Loc("CMD_REMOVECUSTOM_REMOVED", matchValue))
            else
                BLU:Print(BLU:Loc("CMD_REMOVECUSTOM_FAILED", tostring(err)))
            end
        end
    elseif command == "help" then
        BLU:PrintDebug("[Commands] Showing help")
        BLU:Print(BLU:Loc("CMD_HELP_HEADER"))
        BLU:Print(BLU:Loc("CMD_HELP_LINE_OPTIONS"))
        BLU:Print(BLU:Loc("CMD_HELP_LINE_DEBUG"))
        BLU:Print(BLU:Loc("CMD_HELP_LINE_STATUS"))
        BLU:Print(BLU:Loc("CMD_HELP_LINE_REFRESH"))
        BLU:Print(BLU:Loc("CMD_HELP_LINE_ADDCUSTOM"))
        BLU:Print(BLU:Loc("CMD_HELP_LINE_REMOVECUSTOM"))
        BLU:Print(BLU:Loc("CMD_HELP_LINE_ENABLE"))
        BLU:Print(BLU:Loc("CMD_HELP_LINE_DISABLE"))
        BLU:Print(BLU:Loc("CMD_HELP_LINE_HELP"))
    else
        -- Unknown command, show help
        BLU:PrintDebug("[Commands] Unknown /blu command: '" .. tostring(command) .. "'")
        BLU:Print(BLU:Loc("CMD_UNKNOWN"))
    end
end

-- Test command for simulating events
SLASH_BLUTEST1 = "/blutest"
SlashCmdList["BLUTEST"] = function(event)
    BLU:PrintDebug("[Commands] /blutest invoked with '" .. tostring(event) .. "'")
    if not BLU.db then
        BLU:Print(BLU:Loc("BLUTEST_DB_NOT_LOADED"))
        return
    end

    local events = {}
    for moduleName, module in pairs(BLU.Modules) do
        for functionName, _ in pairs(module) do
            if functionName:find("^On") then
                local eventName = functionName:gsub("On", ""):lower()
                events[eventName] = function()
                    BLU:Print(BLU:Loc("BLUTEST_SIMULATING", functionName))
                    if module[functionName] then
                        module[functionName](module)
                    end
                end
            end
        end
    end

    if event == "" then
        BLU:PrintDebug("[Commands] /blutest requested usage output")
        BLU:Print(BLU:Loc("BLUTEST_USAGE"))
        local available_events = ""
        for eventName, _ in pairs(events) do
            available_events = available_events .. eventName .. ", "
        end
        BLU:Print(BLU:Loc("BLUTEST_AVAILABLE", available_events:sub(1, -3)))
        return
    end

    local handler = events[event:lower()]
    if handler then
        BLU:PrintDebug("[Commands] Simulating event '" .. tostring(event:lower()) .. "'")
        handler()
    else
        BLU:PrintDebug("[Commands] Unknown /blutest event '" .. tostring(event) .. "'")
        BLU:Print(BLU:Loc("BLUTEST_UNKNOWN_EVENT", event))
        local available_events = ""
        for eventName, _ in pairs(events) do
            available_events = available_events .. eventName .. ", "
        end
        BLU:Print(BLU:Loc("BLUTEST_AVAILABLE", available_events:sub(1, -3)))
    end
end
