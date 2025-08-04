--=====================================================================================
-- BLU - interface/panels/general.lua
-- General settings panel
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateGeneralPanel(panel)
    local widgets = BLU.Widgets
    
    -- Create scrollable content
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth(), 600)
    scrollFrame:SetScrollChild(content)
    
    -- General Settings section with icon
    local generalHeader = widgets:CreateHeader(content, "|TInterface\\AddOns\\BLU\\media\\images\\icon:20:20|t General Settings")
    generalHeader:SetPoint("TOPLEFT", 0, 0)
    
    local divider1 = widgets:CreateDivider(content)
    divider1:SetPoint("TOPLEFT", generalHeader, "BOTTOMLEFT", 0, -5)
    
    -- Enable addon checkbox
    local enableCheck = widgets:CreateCheckbox(content, "Enable BLU", "Enable or disable the addon")
    enableCheck:SetPoint("TOPLEFT", divider1, "BOTTOMLEFT", 0, -10)
    enableCheck:SetChecked(BLU.db.profile.enabled)
    enableCheck:SetScript("OnClick", function(self)
        BLU.db.profile.enabled = self:GetChecked()
        if BLU.db.profile.enabled then
            BLU:Enable()
        else
            BLU:Disable()
        end
    end)
    
    -- Welcome message checkbox
    local welcomeCheck = widgets:CreateCheckbox(content, "Show welcome message on login", "Display addon loaded message when you log in")
    welcomeCheck:SetPoint("TOPLEFT", enableCheck, "BOTTOMLEFT", 0, -5)
    welcomeCheck:SetChecked(BLU.db.profile.showWelcomeMessage)
    welcomeCheck:SetScript("OnClick", function(self)
        BLU.db.profile.showWelcomeMessage = self:GetChecked()
    end)
    
    -- Debug mode checkbox
    local debugCheck = widgets:CreateCheckbox(content, "Enable debug mode", "Show debug messages in chat")
    debugCheck:SetPoint("TOPLEFT", welcomeCheck, "BOTTOMLEFT", 0, -5)
    debugCheck:SetChecked(BLU.db.profile.debugMode)
    debugCheck:SetScript("OnClick", function(self)
        BLU.db.profile.debugMode = self:GetChecked()
    end)
    
    -- Random sounds checkbox
    local randomCheck = widgets:CreateCheckbox(content, "Enable random sounds", "Play random sounds from all available packs")
    randomCheck:SetPoint("TOPLEFT", debugCheck, "BOTTOMLEFT", 0, -5)
    randomCheck:SetChecked(BLU.db.profile.randomSounds)
    randomCheck:SetScript("OnClick", function(self)
        BLU.db.profile.randomSounds = self:GetChecked()
    end)
    
    -- Sound Settings header with sound icon
    local soundHeader = widgets:CreateHeader(content, "|TInterface\\Icons\\INV_Misc_Ear_Human_01:20:20|t Sound Settings")
    soundHeader:SetPoint("TOPLEFT", randomCheck, "BOTTOMLEFT", 0, -20)
    
    local divider2 = widgets:CreateDivider(content)
    divider2:SetPoint("TOPLEFT", soundHeader, "BOTTOMLEFT", 0, -5)
    
    -- Volume slider
    local volumeSlider = widgets:CreateSlider(content, "Sound Volume", 0, 100, 5, "Adjust the volume of BLU sounds")
    volumeSlider:SetPoint("TOPLEFT", divider2, "BOTTOMLEFT", 0, -20)
    volumeSlider:SetValue(BLU.db.profile.soundVolume or 100)
    volumeSlider:SetScript("OnValueChanged", function(self, value)
        BLU.db.profile.soundVolume = value
        self.value:SetText(value .. "%")
    end)
    volumeSlider.value:SetText((BLU.db.profile.soundVolume or 100) .. "%")
    
    -- Sound channel dropdown
    local channelDropdown = widgets:CreateDropdown(content, "Sound Channel", 200, {
        {text = "Master", value = "Master"},
        {text = "Sound", value = "Sound"},
        {text = "Music", value = "Music"},
        {text = "Ambience", value = "Ambience"}
    }, "Select which audio channel to play BLU sounds through")
    channelDropdown:SetPoint("TOPLEFT", volumeSlider, "BOTTOMLEFT", 0, -30)
    
    UIDropDownMenu_Initialize(channelDropdown, function(self)
        for _, item in ipairs(self.items) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = item.text
            info.value = item.value
            info.func = function()
                BLU.db.profile.soundChannel = item.value
                UIDropDownMenu_SetText(self, item.text)
            end
            info.checked = BLU.db.profile.soundChannel == item.value
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetText(channelDropdown, BLU.db.profile.soundChannel or "Master")
    
    -- Test sound button
    local testButton = widgets:CreateButton(content, "Test Sound", 120, 22, "Play a test sound")
    testButton:SetPoint("TOPLEFT", channelDropdown, "BOTTOMLEFT", 20, -10)
    testButton:SetScript("OnClick", function()
        -- Play test sound using selected levelup sound
        if BLU.PlayCategorySound then
            BLU:PlayCategorySound("levelup")
        else
            BLU:Print("Test sound functionality not yet implemented")
        end
    end)
    
    -- Advanced Settings header
    local advancedHeader = widgets:CreateHeader(content, "|TInterface\\Icons\\INV_Misc_Gear_01:20:20|t Advanced Settings")
    advancedHeader:SetPoint("TOPLEFT", testButton, "BOTTOMLEFT", -20, -30)
    
    local divider3 = widgets:CreateDivider(content)
    divider3:SetPoint("TOPLEFT", advancedHeader, "BOTTOMLEFT", 0, -5)
    
    -- Chat output checkbox
    local chatCheck = widgets:CreateCheckbox(content, "Show sound names in chat", "Display the name of played sounds in chat")
    chatCheck:SetPoint("TOPLEFT", divider3, "BOTTOMLEFT", 0, -10)
    chatCheck:SetChecked(BLU.db.profile.showSoundNames)
    chatCheck:SetScript("OnClick", function(self)
        BLU.db.profile.showSoundNames = self:GetChecked()
    end)
    
    -- Mute in instances checkbox
    local muteCheck = widgets:CreateCheckbox(content, "Mute in instances", "Disable sounds while in dungeons or raids")
    muteCheck:SetPoint("TOPLEFT", chatCheck, "BOTTOMLEFT", 0, -5)
    muteCheck:SetChecked(BLU.db.profile.muteInInstances)
    muteCheck:SetScript("OnClick", function(self)
        BLU.db.profile.muteInInstances = self:GetChecked()
    end)
    
    -- Reset button
    local resetButton = widgets:CreateButton(content, "Reset to Defaults", 120, 22, "Reset all settings to default values")
    resetButton:SetPoint("TOPLEFT", muteCheck, "BOTTOMLEFT", 0, -30)
    resetButton:SetScript("OnClick", function()
        StaticPopup_Show("BLU_RESET_CONFIRM")
    end)
    
    -- Reset confirmation dialog
    StaticPopupDialogs["BLU_RESET_CONFIRM"] = {
        text = "Are you sure you want to reset all BLU settings to defaults?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            BLU:ResetSettings()
            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }
end