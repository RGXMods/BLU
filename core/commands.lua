--=====================================================================================
-- BLU - core/commands.lua
-- Slash command handling
--=====================================================================================

local addonName, BLU = ...

-- Register slash commands
SLASH_BLU1 = "/blu"
SLASH_BLU2 = "/bluesound"

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

SlashCmdList["BLU"] = function(msg)
    -- Test which panel exists
    if msg == "test" then
        print("|cff05dffa=== BLU Panel Test ===|r")
        if _G["BLUOptionsPanel"] then
            local panel = _G["BLUOptionsPanel"]
            print("BLUOptionsPanel exists")
            print("Panel name:", panel.name or "no name")
            -- Check for children
            local children = {panel:GetChildren()}
            print("Number of children:", #children)
            for i, child in ipairs(children) do
                if child.GetText and child:GetText() then
                    print("Child " .. i .. " text:", child:GetText())
                end
            end
        else
            print("BLUOptionsPanel does NOT exist")
        end
        return
    end
    
    -- Debug information
    if msg == "debug" then
        print("|cff05dffa=== BLU Debug Info ===|r")
        print("Database loaded:", BLU.db and "Yes" or "No")
        print("Options panel created:", BLU.OptionsPanel and "Yes" or "No")
        print("Options category registered:", BLU.OptionsCategory and "Yes" or "No")
        print("OpenSimpleOptions function:", BLU.OpenSimpleOptions and "Yes" or "No")
        print("CreateSimpleOptionsPanel function:", BLU.CreateSimpleOptionsPanel and "Yes" or "No")
        if BLU.db and BLU.db.profile then
            print("Addon enabled:", BLU.db.profile.enabled and "Yes" or "No")
        end
        -- Try to create panel manually
        if msg == "debug create" and BLU.CreateOptionsPanel then
            print("Attempting to create options panel...")
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
        print("|cff05dffa=== BLU Options Status ===|r")
        print("OpenOptions:", BLU.OpenOptions and "Available" or "Not found")
        print("OpenSimpleOptions:", BLU.OpenSimpleOptions and "Available" or "Not found") 
        print("CreateOptionsPanel:", BLU.CreateOptionsPanel and "Available" or "Not found")
        print("OptionsPanel:", BLU.OptionsPanel and "Exists" or "Not created")
        print("Tabs system:", BLU.Tabs and "Loaded" or "Not loaded")
        print("Widgets system:", BLU.Widgets and "Loaded" or "Not loaded")
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
    
    -- Use new tabbed options panel
    if BLU.OpenOptions then
        BLU:OpenOptions()
    else
        -- Try to create it if it doesn't exist
        if BLU.Modules and BLU.Modules.options_new and not BLU.OptionsPanel then
            BLU:Print("|cffff0000Options panel not initialized. Creating now...|r")
            if BLU.Modules.options_new.Init then
                BLU.Modules.options_new:Init()
            end
            C_Timer.After(0.1, function()
                if BLU.OpenOptions then
                    BLU:OpenOptions()
                end
            end)
        else
            BLU:Print("Options panel not available - type |cff05dffa/reload|r")
        end
    end
end