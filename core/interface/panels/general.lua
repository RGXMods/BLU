--=====================================================================================
-- BLU - interface/panels/general_new.lua
-- General settings panel with new design
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateGeneralPanel(panel)
    -- Create scrollable content with proper sizing
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 5)
    
    -- Add scroll frame background
    local scrollBg = scrollFrame:CreateTexture(nil, "BACKGROUND")
    scrollBg:SetAllPoints()
    scrollBg:SetColorTexture(0.05, 0.05, 0.05, 0.3)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(680)  -- Fixed width to fill available space
    scrollFrame:SetScrollChild(content)
    
    -- No header needed - more compact
    
    -- Core Settings Section
    local coreSection = BLU.Design:CreateSection(content, "Core Settings", "Interface\Icons\Achievement_General")
    coreSection:SetPoint("TOPLEFT", 0, 0)
    coreSection:SetPoint("RIGHT", 0, 0)
    coreSection:SetHeight(140)
    
    -- Enable addon
    local enableCheck = BLU.Design:CreateCheckbox(coreSection.content, "Enable BLU", "Enable or disable all BLU functionality")
    enableCheck:SetPoint("TOPLEFT", 5, -5)
    
    -- Set checkbox state with database check
    local enabled = true
    if BLU.db and BLU.db.profile then
        enabled = BLU.db.profile.enabled ~= false
    end
    enableCheck.check:SetChecked(enabled)
    enableCheck.check:SetScript("OnClick", function(self)
        if not BLU.db or not BLU.db.profile then
            BLU:Print("Database not ready. Please try again.")
            self:SetChecked(not self:GetChecked())
            return
        end
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
    
    -- Set checkbox state with database check
    local showWelcome = true
    if BLU.db and BLU.db.profile then
        showWelcome = BLU.db.profile.showWelcomeMessage ~= false
    end
    welcomeCheck.check:SetChecked(showWelcome)
    welcomeCheck.check:SetScript("OnClick", function(self)
        if not BLU.db or not BLU.db.profile then
            self:SetChecked(not self:GetChecked())
            return
        end
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
        if not BLU.db or not BLU.db.profile then
            self:SetChecked(not self:GetChecked())
            return
        end
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
        if not BLU.db or not BLU.db.profile then
            self:SetChecked(not self:GetChecked())
            return
        end
        BLU.db.profile.showSoundNames = self:GetChecked()
    end)
    
    -- Audio Settings Section
    local audioSection = BLU.Design:CreateSection(content, "Audio Settings", "Interface\Icons\INV_Misc_Ear_Human_01")
    audioSection:SetPoint("TOPLEFT", coreSection, "BOTTOMLEFT", 0, -10)
    audioSection:SetPoint("RIGHT", 0, 0)
    audioSection:SetHeight(180)
    
    -- Volume slider
    local volumeLabel = audioSection.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    volumeLabel:SetPoint("TOPLEFT", 5, -5)
    volumeLabel:SetText("BLU Sound Volume")
    
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
    
    -- Set slider value with database check
    local currentVolume = 100
    if BLU.db and BLU.db.profile then
        currentVolume = BLU.db.profile.soundVolume or 100
    end
    volumeSlider:SetValue(currentVolume)
    volumeValue:SetText(currentVolume .. "% ")
    
    volumeSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value / 5) * 5  -- Round to nearest 5
        if BLU.db and BLU.db.profile then
            BLU.db.profile.soundVolume = value
        end
        volumeValue:SetText(value .. "% ")
    end)
    
    -- Sound channel
    local channelLabel = audioSection.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    channelLabel:SetPoint("TOPLEFT", volumeSlider, "BOTTOMLEFT", 0, -20)
    channelLabel:SetText("Sound Channel")
    
    -- Volume note
    local volumeNote = audioSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    volumeNote:SetPoint("TOPLEFT", volumeLabel, "TOPRIGHT", 10, 0)
    volumeNote:SetText("|cff888888(BLU sounds only)|r")
    
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
        -- Ensure database is initialized
        if not BLU.db or not BLU.db.profile then
            BLU:PrintDebug("Database not initialized for channel dropdown")
            return
        end
        
        for _, channel in ipairs(channels) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = channel.text
            info.value = channel.value
            info.func = function()
                if BLU.db and BLU.db.profile then
                    BLU.db.profile.soundChannel = channel.value
                end
                UIDropDownMenu_SetText(self, channel.text)
                CloseDropDownMenus()
            end
            info.checked = (BLU.db and BLU.db.profile and BLU.db.profile.soundChannel == channel.value)
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    -- Set current text with proper database check
    local currentChannel = "Master"
    if BLU.db and BLU.db.profile then
        currentChannel = BLU.db.profile.soundChannel or "Master"
    end
    UIDropDownMenu_SetText(channelDropdown, currentChannel)
    
    -- Volume info text
    local volumeInfo = audioSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    volumeInfo:SetPoint("TOPLEFT", channelDropdown, "BOTTOMLEFT", 20, -10)
    volumeInfo:SetPoint("RIGHT", -10, 0)
    volumeInfo:SetText("|cff888888Note: Volume control applies only to BLU internal sounds. External sounds and default WoW sounds use your system volume settings.|r")
    volumeInfo:SetJustifyH("LEFT")
    
    -- Test button
    local testBtn = BLU.Design:CreateButton(audioSection.content, "Test", 80, 22)
    testBtn:SetPoint("LEFT", channelDropdown, "RIGHT", 10, 2)
    testBtn:SetScript("OnClick", function(self)
        -- Visual feedback
        self:SetText("Playing...")
        self:Disable()
        
        -- Play sound
        if BLU.PlaySound then
            BLU:PlaySound("levelup")
        elseif BLU.Modules.registry and BLU.Modules.registry.PlaySound then
            BLU.Modules.registry:PlaySound("levelup")
        else
            BLU:Print("Sound system not available")
        end
        
        -- Reset button after delay
        C_Timer.After(2, function()
            self:SetText("Test")
            self:Enable()
        end)
    end)
    
    -- Behavior Settings Section
    local behaviorSection = BLU.Design:CreateSection(content, "Behavior Settings", "Interface\Icons\INV_Misc_GroupLooking")
    behaviorSection:SetPoint("TOPLEFT", audioSection, "BOTTOMLEFT", 0, -10)
    behaviorSection:SetPoint("RIGHT", 0, 0)
    behaviorSection:SetHeight(120)
    
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
        if not BLU.db or not BLU.db.profile then
            self:SetChecked(not self:GetChecked())
            return
        end
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
        if not BLU.db or not BLU.db.profile then
            self:SetChecked(not self:GetChecked())
            return
        end
        BLU.db.profile.muteInInstances = self:GetChecked()
    end)
    
    -- Mute in combat
    local combatCheck = BLU.Design:CreateCheckbox(behaviorSection.content, "Mute in combat", "Disable sounds while in combat")
    combatCheck:SetPoint("TOPLEFT", muteCheck, "BOTTOMLEFT", 0, -8)
    
    -- Set checkbox state with database check
    local muteInCombat = false
    if BLU.db and BLU.db.profile then
        muteInCombat = BLU.db.profile.muteInCombat == true
    end
    combatCheck.check:SetChecked(muteInCombat)
    combatCheck.check:SetScript("OnClick", function(self)
        if not BLU.db or not BLU.db.profile then
            self:SetChecked(not self:GetChecked())
            return
        end
        BLU.db.profile.muteInCombat = self:GetChecked()
    end)
    
    -- Actions Section
    local actionsSection = BLU.Design:CreateSection(content, "Actions", "Interface\Icons\ACHIEVEMENT_GUILDPERK_QUICK AND DEAD")
    actionsSection:SetPoint("TOPLEFT", behaviorSection, "BOTTOMLEFT", 0, -10)
    actionsSection:SetPoint("RIGHT", 0, 0)
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
    
    -- Calculate total content height
    local totalHeight = 140 + 180 + 120 + 60 + 50  -- Sum of all section heights + spacing
    content:SetHeight(totalHeight)
end

if BLU.RegisterModule then
    BLU:RegisterModule("general", BLU)
end