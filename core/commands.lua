--=====================================================================================
-- BLU - core/commands.lua
-- Slash command handling
--=====================================================================================

local addonName, BLU = ...

-- Register slash commands
SLASH_BLU1 = "/blu"
SLASH_BLU2 = "/bluesound"

SlashCmdList["BLU"] = function(msg)
    msg = (msg or ""):trim():lower()
    
    if msg == "" or msg == "options" or msg == "config" then
        -- Try to open options
        if BLU.Modules and BLU.Modules.options_new and BLU.Modules.options_new.OpenOptions then
            BLU.Modules.options_new:OpenOptions()
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
        if BLU.db then
            BLU.db.debugMode = not BLU.db.debugMode
            BLU:Print("|cff00ccffBLU:|r Debug mode " .. (BLU.db.debugMode and "enabled" or "disabled"))
        else
            BLU:Print("|cff00ccffBLU:|r Database not loaded yet")
        end
    elseif msg == "reload" then
        ReloadUI()
    elseif msg == "help" then
        BLU:Print("|cff00ccffBLU Commands:|r")
        BLU:Print("  |cffffff00/blu|r - Open options")
        BLU:Print("  |cffffff00/blu test|r - Play test sound")
        BLU:Print("  |cffffff00/blu debug|r - Toggle debug mode")
        BLU:Print("  |cffffff00/blu reload|r - Reload UI")
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
    
    local events = {
        levelup = function() 
            BLU:Print("Simulating PLAYER_LEVEL_UP...")
            if BLU.Modules.LevelUp and BLU.Modules.LevelUp.OnLevelUp then
                BLU.Modules.LevelUp:OnLevelUp("PLAYER_LEVEL_UP", UnitLevel("player") + 1)
            end
        end,
        achievement = function()
            BLU:Print("Simulating ACHIEVEMENT_EARNED...")
            if BLU.Modules.Achievement and BLU.Modules.Achievement.OnAchievementEarned then
                BLU.Modules.Achievement:OnAchievementEarned("ACHIEVEMENT_EARNED", 6193, false)
            end
        end,
        quest = function()
            BLU:Print("Simulating QUEST_TURNED_IN...")
            if BLU.Modules.Quest and BLU.Modules.Quest.OnQuestTurnedIn then
                BLU.Modules.Quest:OnQuestTurnedIn("QUEST_TURNED_IN", 12345, 1000, 50)
            end
        end,
        reputation = function()
            BLU:Print("Simulating CHAT_MSG_COMBAT_FACTION_CHANGE...")
            if BLU.Modules.Reputation and BLU.Modules.Reputation.OnReputationMessage then
                local chatFrame = DEFAULT_CHAT_FRAME
                BLU.Modules.Reputation:OnReputationMessage(chatFrame, "CHAT_MSG_COMBAT_FACTION_CHANGE", 
                    "You are now Friendly with Valdrakken Accord.")
            end
        end
    }
    
    if event == "" then
        BLU:Print("Usage: /blutest [levelup|achievement|quest|reputation]")
        return
    end
    
    local handler = events[event:lower()]
    if handler then
        handler()
    else
        BLU:Print("Unknown event: " .. event)
        BLU:Print("Available: levelup, achievement, quest, reputation")
    end
end

-- Disabled - handled by options_direct.lua
--[[
SlashCmdList["BLU"] = function(msg)
    -- Test which panel exists
    if msg == "test" then
        BLU:Print("=== BLU Panel Test ===")
        if _G["BLUOptionsPanel"] then
            local panel = _G["BLUOptionsPanel"]
            BLU:PrintDebug("BLUOptionsPanel exists")
            BLU:PrintDebug("Panel name: " .. (panel.name or "no name"))
            -- Check for children
            local children = {panel:GetChildren()}
            BLU:PrintDebug("Number of children: " .. #children)
            for i, child in ipairs(children) do
                if child.GetText and child:GetText() then
                    BLU:PrintDebug("Child " .. i .. " text: " .. child:GetText())
                end
            end
        else
            BLU:PrintDebug("BLUOptionsPanel does NOT exist")
        end
        return
    end
    
    -- Debug information
    if msg == "debug" then
        BLU:Print("=== BLU Debug Info ===")
        BLU:PrintDebug("Database loaded: " .. (BLU.db and "Yes" or "No"))
        BLU:PrintDebug("Options panel created: " .. (BLU.OptionsPanel and "Yes" or "No"))
        BLU:PrintDebug("Options category registered: " .. (BLU.OptionsCategory and "Yes" or "No"))
        BLU:PrintDebug("OpenSimpleOptions function: " .. (BLU.OpenSimpleOptions and "Yes" or "No"))
        BLU:PrintDebug("CreateSimpleOptionsPanel function: " .. (BLU.CreateSimpleOptionsPanel and "Yes" or "No"))
        if BLU.db and BLU.db.profile then
            BLU:PrintDebug("Addon enabled: " .. (BLU.db.profile.enabled and "Yes" or "No"))
        end
        -- Try to create panel manually
        if msg == "debug create" and BLU.CreateOptionsPanel then
            BLU:PrintDebug("Attempting to create options panel...")
            BLU:CreateOptionsPanel()
        end
        return
    end
    
    if not BLU.db then
        BLU:Print("Database not loaded yet - try again in a moment")
        return
    end
    
    -- Debug what's available
    if msg == "status" then
        BLU:Print("=== BLU Options Status ===")
        BLU:PrintDebug("OpenOptions: " .. (BLU.OpenOptions and "Available" or "Not found"))
        BLU:PrintDebug("OpenSimpleOptions: " .. (BLU.OpenSimpleOptions and "Available" or "Not found"))
        BLU:PrintDebug("CreateOptionsPanel: " .. (BLU.CreateOptionsPanel and "Available" or "Not found"))
        BLU:PrintDebug("OptionsPanel: " .. (BLU.OptionsPanel and "Exists" or "Not created"))
        BLU:PrintDebug("Tabs system: " .. (BLU.Tabs and "Loaded" or "Not loaded"))
        BLU:PrintDebug("Widgets system: " .. (BLU.Widgets and "Loaded" or "Not loaded"))
        return
    end
    
    -- Try to force create panel
    if msg == "create" then
        if BLU.CreateOptionsPanel then
            BLU:Print("Force creating options panel...")
            BLU:CreateOptionsPanel()
        else
            BLU:Print("CreateOptionsPanel function not found")
        end
        return
    end
    
    -- Try multiple approaches to open options
    local opened = false
    
    -- Method 1: Try BLU.OpenOptions
    if BLU.OpenOptions then
        BLU:OpenOptions()
        opened = true
    -- Method 2: Try through the module
    elseif BLU.Modules and BLU.Modules.options_new and BLU.Modules.options_new.OpenOptions then
        BLU.Modules.options_new:OpenOptions()
        opened = true
    -- Method 3: Create panel if needed and try again
    elseif BLU.CreateOptionsPanel then
        BLU:Print("Creating options panel...")
        BLU:CreateOptionsPanel()
        C_Timer.After(0.1, function()
            if BLU.OpenOptions then
                BLU:OpenOptions()
            elseif BLU.Modules and BLU.Modules.options_new and BLU.Modules.options_new.OpenOptions then
                BLU.Modules.options_new:OpenOptions()
            else
                BLU:Print("Options panel not properly registered. Try |cff05dffa/reload|r")
            end
        end)
        opened = true
    end
    
    -- If nothing worked, show error
    if not opened then
        BLU:Print("Options panel not properly registered. Try |cff05dffa/reload|r")
        BLU:PrintDebug("BLU.OpenOptions: " .. tostring(BLU.OpenOptions))
        BLU:PrintDebug("BLU.OptionsPanel: " .. tostring(BLU.OptionsPanel))
        BLU:PrintDebug("BLU.CreateOptionsPanel: " .. tostring(BLU.CreateOptionsPanel))
    end
end
--]]