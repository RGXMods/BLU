--=====================================================================================
-- BLU - interface/panels/general.lua
-- General settings panel
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateGeneralPanel(panel)
    local widgets = BLU.Widgets
    
    -- General Settings header
    local generalHeader = widgets:CreateHeader(panel, "General Settings")
    generalHeader:SetPoint("TOPLEFT", 0, 0)
    
    local divider1 = widgets:CreateDivider(panel)
    divider1:SetPoint("TOPLEFT", generalHeader, "BOTTOMLEFT", 0, -5)
    
    -- Enable addon checkbox
    local enableCheck = widgets:CreateCheckbox(panel, "Enable BLU", "Enable or disable the addon")
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
    local welcomeCheck = widgets:CreateCheckbox(panel, "Show welcome message on login", "Display addon loaded message when you log in")
    welcomeCheck:SetPoint("TOPLEFT", enableCheck, "BOTTOMLEFT", 0, -5)
    welcomeCheck:SetChecked(BLU.db.profile.showWelcomeMessage)
    welcomeCheck:SetScript("OnClick", function(self)
        BLU.db.profile.showWelcomeMessage = self:GetChecked()
    end)
    
    -- Debug mode checkbox
    local debugCheck = widgets:CreateCheckbox(panel, "Enable debug mode", "Show debug messages in chat")
    debugCheck:SetPoint("TOPLEFT", welcomeCheck, "BOTTOMLEFT", 0, -5)
    debugCheck:SetChecked(BLU.db.profile.debugMode)
    debugCheck:SetScript("OnClick", function(self)
        BLU.db.profile.debugMode = self:GetChecked()
    end)
    
    -- Sound Settings header
    local soundHeader = widgets:CreateHeader(panel, "Sound Settings")
    soundHeader:SetPoint("TOPLEFT", debugCheck, "BOTTOMLEFT", 0, -20)
    
    local divider2 = widgets:CreateDivider(panel)
    divider2:SetPoint("TOPLEFT", soundHeader, "BOTTOMLEFT", 0, -5)
    
    -- Volume slider
    local volumeSlider = widgets:CreateSlider(panel, "Sound Volume", 0, 100, 5, "Adjust the volume of BLU sounds")
    volumeSlider:SetPoint("TOPLEFT", divider2, "BOTTOMLEFT", 0, -20)
    volumeSlider:SetValue(BLU.db.profile.soundVolume or 100)
    volumeSlider:SetScript("OnValueChanged", function(self, value)
        BLU.db.profile.soundVolume = value
        self.value:SetText(value .. "%")
    end)
    volumeSlider.value:SetText((BLU.db.profile.soundVolume or 100) .. "%")
    
    -- Sound channel dropdown
    local channelDropdown = widgets:CreateDropdown(panel, "Sound Channel", 200, {
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
    local testButton = widgets:CreateButton(panel, "Test Sound", 120, 22, "Play a test sound")
    testButton:SetPoint("TOPLEFT", channelDropdown, "BOTTOMLEFT", 20, -10)
    testButton:SetScript("OnClick", function()
        -- Play test sound using selected levelup sound
        if BLU.PlayCategorySound then
            BLU:PlayCategorySound("levelup")
        else
            BLU:Print("Test sound functionality not yet implemented")
        end
    end)
    
    -- Reset button
    local resetButton = widgets:CreateButton(panel, "Reset to Defaults", 120, 22, "Reset all settings to default values")
    resetButton:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)
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