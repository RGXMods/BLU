--=====================================================================================
-- BLU - interface/panels/general_new.lua
-- General settings panel with new design
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateGeneralPanel(panel)
    -- Create scrollable content
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth() - 20, 600)
    scrollFrame:SetScrollChild(content)
    
    -- No header needed - more compact
    
    -- Core Settings Section
    local coreSection = BLU.Design:CreateSection(content, "Core Settings", "Interface\\Icons\\Achievement_General")
    coreSection:SetPoint("TOPLEFT", 0, 0)
    coreSection:SetPoint("RIGHT", -20, 0)
    coreSection:SetHeight(140)
    
    -- Enable addon
    local enableCheck = BLU.Design:CreateCheckbox(coreSection.content, "Enable BLU", "Enable or disable all BLU functionality")
    enableCheck:SetPoint("TOPLEFT", 0, -5)
    enableCheck.check:SetChecked(BLU.db.profile.enabled ~= false)
    enableCheck.check:SetScript("OnClick", function(self)
        BLU.db.profile.enabled = self:GetChecked()
        if BLU.db.profile.enabled then
            BLU:Enable()
            BLU:Print("|cff00ff00BLU Enabled|r")
        else
            BLU:Disable()
            BLU:Print("|cffff0000BLU Disabled|r")
        end
    end)
    
    -- Welcome message
    local welcomeCheck = BLU.Design:CreateCheckbox(coreSection.content, "Show welcome message", "Display addon loaded message on login")
    welcomeCheck:SetPoint("TOPLEFT", enableCheck, "BOTTOMLEFT", 0, -8)
    welcomeCheck.check:SetChecked(BLU.db.profile.showWelcomeMessage)
    welcomeCheck.check:SetScript("OnClick", function(self)
        BLU.db.profile.showWelcomeMessage = self:GetChecked()
    end)
    
    -- Debug mode
    local debugCheck = BLU.Design:CreateCheckbox(coreSection.content, "Debug mode", "Show debug messages in chat")
    debugCheck:SetPoint("TOPLEFT", welcomeCheck, "BOTTOMLEFT", 0, -8)
    debugCheck.check:SetChecked(BLU.db.profile.debugMode)
    debugCheck.check:SetScript("OnClick", function(self)
        BLU.db.profile.debugMode = self:GetChecked()
        BLU.debugMode = self:GetChecked()
    end)
    
    -- Show sound names
    local showNamesCheck = BLU.Design:CreateCheckbox(coreSection.content, "Show sound names in chat", "Display the name of sounds when they play")
    showNamesCheck:SetPoint("TOPLEFT", debugCheck, "BOTTOMLEFT", 0, -8)
    showNamesCheck.check:SetChecked(BLU.db.profile.showSoundNames)
    showNamesCheck.check:SetScript("OnClick", function(self)
        BLU.db.profile.showSoundNames = self:GetChecked()
    end)
    
    -- Audio Settings Section
    local audioSection = BLU.Design:CreateSection(content, "Audio Settings", "Interface\\Icons\\INV_Misc_Ear_Human_01")
    audioSection:SetPoint("TOPLEFT", coreSection, "BOTTOMLEFT", 0, -10)
    audioSection:SetPoint("RIGHT", -20, 0)
    audioSection:SetHeight(160)
    
    -- Volume slider
    local volumeLabel = audioSection.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    volumeLabel:SetPoint("TOPLEFT", 0, -5)
    volumeLabel:SetText("Sound Volume")
    
    local volumeSlider = CreateFrame("Slider", "BLUVolumeSlider", audioSection.content, "OptionsSliderTemplate")
    volumeSlider:SetPoint("TOPLEFT", volumeLabel, "BOTTOMLEFT", 0, -5)
    volumeSlider:SetWidth(250)
    volumeSlider:SetMinMaxValues(0, 100)
    volumeSlider:SetValueStep(5)
    volumeSlider:SetObeyStepOnDrag(true)
    volumeSlider.Low:SetText("0%")
    volumeSlider.High:SetText("100%")
    
    local volumeValue = volumeSlider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    volumeValue:SetPoint("TOP", volumeSlider, "BOTTOM", 0, -5)
    
    volumeSlider:SetValue(BLU.db.profile.soundVolume or 100)
    volumeValue:SetText((BLU.db.profile.soundVolume or 100) .. "%")
    
    volumeSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value / 5) * 5  -- Round to nearest 5
        BLU.db.profile.soundVolume = value
        volumeValue:SetText(value .. "%")
    end)
    
    -- Sound channel
    local channelLabel = audioSection.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    channelLabel:SetPoint("TOPLEFT", volumeSlider, "BOTTOMLEFT", 0, -20)
    channelLabel:SetText("Sound Channel")
    
    local channelDropdown = CreateFrame("Frame", "BLUChannelDropdown", audioSection.content, "UIDropDownMenuTemplate")
    channelDropdown:SetPoint("TOPLEFT", channelLabel, "BOTTOMLEFT", -20, -5)
    UIDropDownMenu_SetWidth(channelDropdown, 200)
    
    local channels = {
        {text = "Master", value = "Master"},
        {text = "Sound", value = "Sound"},
        {text = "Music", value = "Music"},
        {text = "Ambience", value = "Ambience"},
        {text = "Dialog", value = "Dialog"}
    }
    
    UIDropDownMenu_Initialize(channelDropdown, function(self)
        for _, channel in ipairs(channels) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = channel.text
            info.value = channel.value
            info.func = function()
                BLU.db.profile.soundChannel = channel.value
                UIDropDownMenu_SetText(self, channel.text)
            end
            info.checked = BLU.db.profile.soundChannel == channel.value
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    UIDropDownMenu_SetText(channelDropdown, BLU.db.profile.soundChannel or "Master")
    
    -- Test button
    local testBtn = BLU.Design:CreateButton(audioSection.content, "Test", 80, 22)
    testBtn:SetPoint("LEFT", channelDropdown, "RIGHT", 10, 2)
    testBtn:SetScript("OnClick", function()
        if BLU.PlaySound then
            BLU:PlaySound("levelup")
        elseif BLU.Modules.registry and BLU.Modules.registry.PlaySound then
            BLU.Modules.registry:PlaySound("levelup")
        else
            BLU:Print("Sound system not available")
        end
    end)
    
    -- Behavior Settings Section
    local behaviorSection = BLU.Design:CreateSection(content, "Behavior Settings", "Interface\\Icons\\INV_Misc_GroupLooking")
    behaviorSection:SetPoint("TOPLEFT", audioSection, "BOTTOMLEFT", 0, -10)
    behaviorSection:SetPoint("RIGHT", -20, 0)
    behaviorSection:SetHeight(120)
    
    -- Random sounds
    local randomCheck = BLU.Design:CreateCheckbox(behaviorSection.content, "Random sounds", "Play random sounds from all available packs")
    randomCheck:SetPoint("TOPLEFT", 0, -5)
    randomCheck.check:SetChecked(BLU.db.profile.randomSounds)
    randomCheck.check:SetScript("OnClick", function(self)
        BLU.db.profile.randomSounds = self:GetChecked()
    end)
    
    -- Mute in instances
    local muteCheck = BLU.Design:CreateCheckbox(behaviorSection.content, "Mute in instances", "Disable sounds while in dungeons, raids, or PvP")
    muteCheck:SetPoint("TOPLEFT", randomCheck, "BOTTOMLEFT", 0, -8)
    muteCheck.check:SetChecked(BLU.db.profile.muteInInstances)
    muteCheck.check:SetScript("OnClick", function(self)
        BLU.db.profile.muteInInstances = self:GetChecked()
    end)
    
    -- Mute in combat
    local combatCheck = BLU.Design:CreateCheckbox(behaviorSection.content, "Mute in combat", "Disable sounds while in combat")
    combatCheck:SetPoint("TOPLEFT", muteCheck, "BOTTOMLEFT", 0, -8)
    combatCheck.check:SetChecked(BLU.db.profile.muteInCombat)
    combatCheck.check:SetScript("OnClick", function(self)
        BLU.db.profile.muteInCombat = self:GetChecked()
    end)
    
    -- Actions Section
    local actionsSection = BLU.Design:CreateSection(content, "Actions", "Interface\\Icons\\ACHIEVEMENT_GUILDPERK_QUICK AND DEAD")
    actionsSection:SetPoint("TOPLEFT", behaviorSection, "BOTTOMLEFT", 0, -10)
    actionsSection:SetPoint("RIGHT", -20, 0)
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
    testAllBtn:SetScript("OnClick", function()
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
            end
        end
        
        playNext()
    end)
    
    -- Reset confirmation dialog
    StaticPopupDialogs["BLU_RESET_CONFIRM"] = {
        text = "Are you sure you want to reset all BLU settings to defaults?\n\nThis cannot be undone.",
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
    
    content:SetHeight(550)
end