--=====================================================================================
-- BLU - interface/panels/general_new.lua
-- General settings panel with new design
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateGeneralPanel(panel)
    -- Debug: Check panel dimensions
    BLU:PrintDebug("Creating General Panel - Panel size: " .. tostring(panel:GetWidth()) .. "x" .. tostring(panel:GetHeight()))
    
    -- Create scrollable content with standardized positioning
    local scrollFrame, content = BLU.Design:CreatePanelScrollFrame(panel, 700)
    
    -- Debug: Check if scroll frame was created
    if not scrollFrame then
        BLU:PrintError("Failed to create scroll frame for General panel")
        return
    end
    
    -- No header needed - more compact
    
    -- Core Settings Section
    local coreSection = BLU.Design:CreateSection(content, "Core Settings", "Interface\\Icons\\Achievement_General")
    coreSection:SetPoint("TOPLEFT", BLU.Design.Layout.ContentMargin, -BLU.Design.Layout.ContentMargin)
    coreSection:SetPoint("RIGHT", -BLU.Design.Layout.ContentMargin, 0)
    coreSection:SetHeight(150)
    
    -- Enable addon
    local enableCheck = BLU.Design:CreateCheckbox(coreSection.content, "Enable |cff05dffaBLU|r", "Enable or disable all |cff05dffaBLU|r functionality")
    enableCheck:SetPoint("TOPLEFT", 5, -5)
    
    -- Set checkbox state with database check
    local enabled = true
    if BLU.db and BLU.db.profile then
        enabled = BLU.db.profile.enabled ~= false
    end
    enableCheck.check:SetChecked(enabled)
    enableCheck.check:SetScript("OnClick", function(self)
        BLU.db.profile.enabled = self:GetChecked()
        if BLU.db.profile.enabled then
            BLU:Enable()
            BLU:Print("|cff00ff00|cff05dffaBLU|r Enabled|r")
        else
            BLU:Disable()
            BLU:Print("|cffff0000|cff05dffaBLU|r Disabled|r")
        end
    end)
    
    -- Welcome message
    local welcomeCheck = BLU.Design:CreateCheckbox(coreSection.content, "Show welcome message", "Display addon loaded message on login")
    welcomeCheck:SetPoint("TOPLEFT", enableCheck, "BOTTOMLEFT", 0, -8)
    
    -- Set checkbox state with database check
    local showWelcome = true
    if BLU.db and BLU.db.profile then
        showWelcome = BLU.db.profile.showWelcomeMessage ~= false
    end
    welcomeCheck.check:SetChecked(showWelcome)
    welcomeCheck.check:SetScript("OnClick", function(self)
        BLU.db.profile.showWelcomeMessage = self:GetChecked()
    end)
    
    -- Debug mode
    local debugCheck = BLU.Design:CreateCheckbox(coreSection.content, "Debug mode", "Show debug messages in chat")
    debugCheck:SetPoint("TOPLEFT", welcomeCheck, "BOTTOMLEFT", 0, -8)
    
    -- Set checkbox state with database check
    local debugMode = false
    if BLU.db and BLU.db.profile then
        debugMode = BLU.db.profile.debugMode == true
    end
    debugCheck.check:SetChecked(debugMode)
    debugCheck.check:SetScript("OnClick", function(self)
        BLU.db.profile.debugMode = self:GetChecked()
        BLU.debugMode = self:GetChecked()
    end)
    
    -- Show sound names
    local showNamesCheck = BLU.Design:CreateCheckbox(coreSection.content, "Show sound names in chat", "Display the name of sounds when they play")
    showNamesCheck:SetPoint("TOPLEFT", debugCheck, "BOTTOMLEFT", 0, -8)
    
    -- Set checkbox state with database check
    local showNames = false
    if BLU.db and BLU.db.profile then
        showNames = BLU.db.profile.showSoundNames == true
    end
    showNamesCheck.check:SetChecked(showNames)
    showNamesCheck.check:SetScript("OnClick", function(self)
        BLU.db.profile.showSoundNames = self:GetChecked()
    end)
    
    -- Behavior Settings Section
    local behaviorSection = BLU.Design:CreateSection(content, "Behavior Settings", "Interface\\Icons\\INV_Misc_GroupLooking")
    behaviorSection:SetPoint("TOPLEFT", coreSection, "BOTTOMLEFT", 0, -BLU.Design.Layout.SectionSpacing)
    behaviorSection:SetPoint("RIGHT", -BLU.Design.Layout.ContentMargin, 0)
    behaviorSection:SetHeight(130)
    
    -- Random sounds
    local randomCheck = BLU.Design:CreateCheckbox(behaviorSection.content, "Random sounds", "Play random sounds from all available packs")
    randomCheck:SetPoint("TOPLEFT", 5, -5)
    
    -- Set checkbox state with database check
    local randomSounds = false
    if BLU.db and BLU.db.profile then
        randomSounds = BLU.db.profile.randomSounds == true
    end
    randomCheck.check:SetChecked(randomSounds)
    randomCheck.check:SetScript("OnClick", function(self)
        BLU.db.profile.randomSounds = self:GetChecked()
    end)
    
    -- Mute in instances
    local muteCheck = BLU.Design:CreateCheckbox(behaviorSection.content, "Mute in instances", "Disable sounds while in dungeons, raids, or PvP")
    muteCheck:SetPoint("TOPLEFT", randomCheck, "BOTTOMLEFT", 0, -8)
    
    -- Set checkbox state with database check
    local muteInInstances = false
    if BLU.db and BLU.db.profile then
        muteInInstances = BLU.db.profile.muteInInstances == true
    end
    muteCheck.check:SetChecked(muteInInstances)
    muteCheck.check:SetScript("OnClick", function(self)
        BLU.db.profile.muteInInstances = self:GetChecked()
    end)
    
    -- Mute in combat
    local combatCheck = BLU.Design:CreateCheckbox(behaviorSection.content, "Mute in combat", "Disable sounds while in combat")
    combatCheck:SetPoint("TOPLEFT", muteCheck, "BOTTOMLEFT", 0, -BLU.Design.Layout.Spacing)
    
    -- Set checkbox state with database check
    local muteInCombat = false
    if BLU.db and BLU.db.profile then
        muteInCombat = BLU.db.profile.muteInCombat == true
    end
    combatCheck.check:SetChecked(muteInCombat)
    combatCheck.check:SetScript("OnClick", function(self)
        BLU.db.profile.muteInCombat = self:GetChecked()
    end)
    
    -- Module Management Section
    local moduleSection = BLU.Design:CreateSection(content, "Module Management", "Interface\\Icons\\INV_Misc_Gear_08")
    moduleSection:SetPoint("TOPLEFT", behaviorSection, "BOTTOMLEFT", 0, -BLU.Design.Layout.Spacing)
    moduleSection:SetPoint("RIGHT", -BLU.Design.Layout.Spacing, 0)
    moduleSection:SetHeight(120)
    
    -- Module status display
    local moduleStatus = moduleSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    moduleStatus:SetPoint("TOPLEFT", BLU.Design.Layout.Spacing/2, -BLU.Design.Layout.Spacing/2)
    moduleStatus:SetPoint("RIGHT", -BLU.Design.Layout.Spacing/2, 0)
    moduleStatus:SetJustifyH("LEFT")
    
    -- Count enabled modules
    local enabledCount = 0
    local totalCount = 0
    local modules = {"levelup", "achievement", "quest", "reputation", "battlepet", "honorrank", "renownrank", "tradingpost", "delvecompanion"}
    
    for _, moduleId in ipairs(modules) do
        totalCount = totalCount + 1
        if BLU.db and BLU.db.profile and BLU.db.profile.modules then
            if BLU.db.profile.modules[moduleId] ~= false then
                enabledCount = enabledCount + 1
            end
        else
            enabledCount = enabledCount + 1 -- Default enabled
        end
    end
    
    moduleStatus:SetText(string.format("Event Modules Status: |cff05dffa%d/%d|r enabled\\n\\nEach event module can be individually controlled in its respective tab.", enabledCount, totalCount))
    
    -- Module management buttons
    local enableAllBtn = BLU.Design:CreateButton(moduleSection.content, "Enable All", 80, 22)
    enableAllBtn:SetPoint("TOPLEFT", moduleStatus, "BOTTOMLEFT", 0, -BLU.Design.Layout.Spacing)
    enableAllBtn:SetScript("OnClick", function(self)
        if not BLU.db or not BLU.db.profile then return end
        BLU.db.profile.modules = BLU.db.profile.modules or {}
        
        for _, moduleId in ipairs(modules) do
            BLU.db.profile.modules[moduleId] = true
            if BLU.LoadModule then
                BLU:LoadModule("features", moduleId)
            end
        end
        
        BLU:Print("All event modules enabled")
        moduleStatus:SetText(string.format("Event Modules Status: |cff05dffa%d/%d|r enabled\\n\\nEach event module can be individually controlled in its respective tab.", #modules, #modules))
    end)
    
    local disableAllBtn = BLU.Design:CreateButton(moduleSection.content, "Disable All", 80, 22)
    disableAllBtn:SetPoint("LEFT", enableAllBtn, "RIGHT", 10, 0)
    disableAllBtn:SetScript("OnClick", function(self)
        if not BLU.db or not BLU.db.profile then return end
        BLU.db.profile.modules = BLU.db.profile.modules or {}
        
        for _, moduleId in ipairs(modules) do
            BLU.db.profile.modules[moduleId] = false
            if BLU.UnloadModule then
                BLU:UnloadModule(moduleId)
            end
        end
        
        BLU:Print("All event modules disabled")
        moduleStatus:SetText(string.format("Event Modules Status: |cff05dffa%d/%d|r enabled\\n\\nEach event module can be individually controlled in its respective tab.", 0, #modules))
    end)
    
    -- Actions Section
    local actionsSection = BLU.Design:CreateSection(content, "Actions", "Interface\\Icons\\ACHIEVEMENT_GUILDPERK_QUICK AND DEAD")
    actionsSection:SetPoint("TOPLEFT", moduleSection, "BOTTOMLEFT", 0, -BLU.Design.Layout.Spacing)
    actionsSection:SetPoint("RIGHT", -BLU.Design.Layout.Spacing, 0)
    actionsSection:SetHeight(60)
    
    -- Reset button
    local resetBtn = BLU.Design:CreateButton(actionsSection.content, "Reset to Defaults", 120, 24)
    resetBtn:SetPoint("LEFT", 10, 0)
    resetBtn:SetScript("OnClick", function()
        StaticPopup_Show("BLU_RESET_CONFIRM")
    end)
    
    -- Reload UI button
    local reloadBtn = BLU.Design:CreateButton(actionsSection.content, "Reload UI", 80, 24)
    reloadBtn:SetPoint("LEFT", resetBtn, "RIGHT", 10, 0)
    reloadBtn:SetScript("OnClick", function()
        ReloadUI()
    end)
    
    -- Test all sounds button
    local testAllBtn = BLU.Design:CreateButton(actionsSection.content, "Test All", 80, 24)
    testAllBtn:SetPoint("LEFT", reloadBtn, "RIGHT", 10, 0)
    testAllBtn:SetScript("OnClick", function(self)
        self:SetText("Testing...")
        self:Disable()
        BLU:Print("Testing all event sounds...")
        
        local events = {"levelup", "achievement", "quest", "reputation"}
        local index = 1
        
        local function playNext()
            if index <= #events then
                BLU:Print("Playing: " .. events[index])
                if BLU.PlaySound then
                    BLU:PlaySound(events[index])
                elseif BLU.Modules.registry and BLU.Modules.registry.PlaySound then
                    BLU.Modules.registry:PlaySound(events[index])
                else
                    BLU:Print("Sound system not available")
                end
                index = index + 1
                C_Timer.After(2, playNext)
            else
                BLU:Print("Test complete!")
                self:SetText("Test All")
                self:Enable()
            end
        end
        
        playNext()
    end)
    
    -- Reset confirmation dialog
    StaticPopupDialogs["BLU_RESET_CONFIRM"] = {
        text = "Are you sure you want to reset all |cff05dffaBLU|r settings to defaults?\n\nThis cannot be undone.",
        button1 = YES,
        button2 = NO,
        OnAccept = function()
            BLU:ResetSettings()
            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }
    
    -- Content height already set by CreatePanelScrollFrame
end