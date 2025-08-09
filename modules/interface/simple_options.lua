--=====================================================================================
-- BLU - Simple Options Panel
-- A basic working options panel without complex features
--=====================================================================================

local addonName, BLU = ...

-- Create a simple options panel that definitely works
function BLU:CreateSimpleOptionsPanel()
    print("|cff05dffaBLU: Creating simple options panel...|r")
    
    -- Create the main panel frame
    local panel = CreateFrame("Frame", "BLUSimpleOptionsPanel")
    panel.name = "Better Level-Up! (Simple)"
    
    -- Title
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("|cff05dffaBLU|r - Better Level-Up! v5.3.0-alpha")
    
    -- Version
    local version = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    version:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    version:SetText("Version: " .. (BLU.version or "Unknown") .. " - Updated: 2025-08-04")
    
    -- Enable checkbox
    local enableCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    enableCheck:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -20)
    enableCheck.Text:SetText("Enable BLU")
    enableCheck:SetScript("OnClick", function(self)
        if BLU.db and BLU.db.profile then
            BLU.db.profile.enabled = self:GetChecked()
        end
    end)
    
    -- Volume slider
    local volumeSlider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
    volumeSlider:SetPoint("TOPLEFT", enableCheck, "BOTTOMLEFT", 0, -40)
    volumeSlider:SetWidth(200)
    volumeSlider:SetMinMaxValues(0, 100)
    volumeSlider:SetValueStep(5)
    volumeSlider.Text:SetText("Sound Volume")
    volumeSlider.Low:SetText("0%")
    volumeSlider.High:SetText("100%")
    
    local volumeValue = volumeSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    volumeValue:SetPoint("TOP", volumeSlider, "BOTTOM", 0, -5)
    
    volumeSlider:SetScript("OnValueChanged", function(self, value)
        volumeValue:SetText(value .. "%")
        if BLU.db and BLU.db.profile then
            BLU.db.profile.soundVolume = value
        end
    end)
    
    -- Debug mode checkbox
    local debugCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    debugCheck:SetPoint("LEFT", enableCheck, "RIGHT", 150, 0)
    debugCheck.Text:SetText("Debug Mode")
    debugCheck:SetScript("OnClick", function(self)
        if BLU.db and BLU.db.profile then
            BLU.db.profile.debugMode = self:GetChecked()
            BLU.debugMode = self:GetChecked()
        end
    end)
    
    -- Test sound button
    local testButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    testButton:SetPoint("TOPLEFT", volumeSlider, "BOTTOMLEFT", 0, -30)
    testButton:SetSize(120, 22)
    testButton:SetText("Test Sound")
    testButton:SetScript("OnClick", function()
        if BLU.PlayCategorySound then
            BLU:PlayCategorySound("levelup")
        else
            PlaySound(888) -- Level up sound
        end
    end)
    
    -- Sound channel dropdown
    local channelLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    channelLabel:SetPoint("TOPLEFT", testButton, "BOTTOMLEFT", 0, -20)
    channelLabel:SetText("Sound Channel:")
    
    local channelDropdown = CreateFrame("Frame", "BLUChannelDropdown", panel, "UIDropDownMenuTemplate")
    channelDropdown:SetPoint("LEFT", channelLabel, "RIGHT", 10, 0)
    UIDropDownMenu_SetWidth(channelDropdown, 150)
    
    local channels = {"Master", "Sound", "Music", "Ambience"}
    
    UIDropDownMenu_Initialize(channelDropdown, function(self)
        for _, channel in ipairs(channels) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = channel
            info.value = channel
            info.func = function()
                if BLU.db and BLU.db.profile then
                    BLU.db.profile.soundChannel = channel
                end
                UIDropDownMenu_SetText(channelDropdown, channel)
            end
            if BLU.db and BLU.db.profile and BLU.db.profile.soundChannel == channel then
                info.checked = true
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    -- Sound selection header
    local soundHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    soundHeader:SetPoint("TOPLEFT", channelLabel, "BOTTOMLEFT", 0, -30)
    soundHeader:SetText("Sound Selection")
    
    -- Level up sound dropdown
    local levelLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    levelLabel:SetPoint("TOPLEFT", soundHeader, "BOTTOMLEFT", 0, -10)
    levelLabel:SetText("Level Up:")
    
    local levelDropdown = CreateFrame("Frame", "BLULevelDropdown", panel, "UIDropDownMenuTemplate")
    levelDropdown:SetPoint("LEFT", levelLabel, "RIGHT", 10, 0)
    UIDropDownMenu_SetWidth(levelDropdown, 180)
    
    local soundPacks = {
        {value = "default", text = "Default WoW"},
        {value = "wowdefault", text = "WoW Built-in"},
        {value = "finalfantasy", text = "Final Fantasy"},
        {value = "zelda", text = "Legend of Zelda"},
        {value = "pokemon", text = "Pokemon"},
        {value = "mario", text = "Super Mario"}
    }
    
    UIDropDownMenu_Initialize(levelDropdown, function(self)
        for _, pack in ipairs(soundPacks) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = pack.text
            info.value = pack.value
            info.func = function()
                if BLU.db and BLU.db.profile and BLU.db.profile.selectedSounds then
                    BLU.db.profile.selectedSounds.levelup = pack.value
                end
                UIDropDownMenu_SetText(levelDropdown, pack.text)
            end
            if BLU.db and BLU.db.profile and BLU.db.profile.selectedSounds and 
               BLU.db.profile.selectedSounds.levelup == pack.value then
                info.checked = true
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    -- Preview level up button
    local previewLevel = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    previewLevel:SetPoint("LEFT", levelDropdown, "RIGHT", 10, 2)
    previewLevel:SetSize(70, 22)
    previewLevel:SetText("Preview")
    previewLevel:SetScript("OnClick", function()
        if BLU.PlayCategorySound then
            BLU:PlayCategorySound("levelup")
        end
    end)
    
    -- Achievement sound dropdown
    local achieveLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    achieveLabel:SetPoint("TOPLEFT", levelLabel, "BOTTOMLEFT", 0, -10)
    achieveLabel:SetText("Achievement:")
    
    local achieveDropdown = CreateFrame("Frame", "BLUAchieveDropdown", panel, "UIDropDownMenuTemplate")
    achieveDropdown:SetPoint("LEFT", achieveLabel, "RIGHT", 10, 0)
    UIDropDownMenu_SetWidth(achieveDropdown, 180)
    
    UIDropDownMenu_Initialize(achieveDropdown, function(self)
        for _, pack in ipairs(soundPacks) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = pack.text
            info.value = pack.value
            info.func = function()
                if BLU.db and BLU.db.profile and BLU.db.profile.selectedSounds then
                    BLU.db.profile.selectedSounds.achievement = pack.value
                end
                UIDropDownMenu_SetText(achieveDropdown, pack.text)
            end
            if BLU.db and BLU.db.profile and BLU.db.profile.selectedSounds and 
               BLU.db.profile.selectedSounds.achievement == pack.value then
                info.checked = true
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    -- Preview achievement button
    local previewAchieve = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    previewAchieve:SetPoint("LEFT", achieveDropdown, "RIGHT", 10, 2)
    previewAchieve:SetSize(70, 22)
    previewAchieve:SetText("Preview")
    previewAchieve:SetScript("OnClick", function()
        if BLU.PlayCategorySound then
            BLU:PlayCategorySound("achievement")
        end
    end)
    
    -- Quest sound dropdown
    local questLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    questLabel:SetPoint("TOPLEFT", achieveLabel, "BOTTOMLEFT", 0, -10)
    questLabel:SetText("Quest Complete:")
    
    local questDropdown = CreateFrame("Frame", "BLUQuestDropdown", panel, "UIDropDownMenuTemplate")
    questDropdown:SetPoint("LEFT", questLabel, "RIGHT", 10, 0)
    UIDropDownMenu_SetWidth(questDropdown, 180)
    
    UIDropDownMenu_Initialize(questDropdown, function(self)
        for _, pack in ipairs(soundPacks) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = pack.text
            info.value = pack.value
            info.func = function()
                if BLU.db and BLU.db.profile and BLU.db.profile.selectedSounds then
                    BLU.db.profile.selectedSounds.quest = pack.value
                end
                UIDropDownMenu_SetText(questDropdown, pack.text)
            end
            if BLU.db and BLU.db.profile and BLU.db.profile.selectedSounds and 
               BLU.db.profile.selectedSounds.quest == pack.value then
                info.checked = true
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    -- Preview quest button
    local previewQuest = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    previewQuest:SetPoint("LEFT", questDropdown, "RIGHT", 10, 2)
    previewQuest:SetSize(70, 22)
    previewQuest:SetText("Preview")
    previewQuest:SetScript("OnClick", function()
        if BLU.PlayCategorySound then
            BLU:PlayCategorySound("quest")
        end
    end)
    
    -- Info text
    local info = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    info:SetPoint("TOPLEFT", questLabel, "BOTTOMLEFT", 0, -30)
    info:SetWidth(500)
    info:SetJustifyH("LEFT")
    info:SetText("Note: Most sound packs show as available but need actual sound files (.ogg) to work.\nOnly 'WoW Built-in' sounds work without files.\n\nType |cff05dffa/blu|r to open this panel.")
    
    -- Initialize values when panel is shown
    panel:SetScript("OnShow", function(self)
        if BLU.db and BLU.db.profile then
            enableCheck:SetChecked(BLU.db.profile.enabled)
            debugCheck:SetChecked(BLU.db.profile.debugMode)
            volumeSlider:SetValue(BLU.db.profile.soundVolume or 100)
            
            -- Set channel dropdown
            UIDropDownMenu_SetText(channelDropdown, BLU.db.profile.soundChannel or "Master")
            
            -- Set sound dropdowns
            if BLU.db.profile.selectedSounds then
                -- Level up
                local levelupSound = BLU.db.profile.selectedSounds.levelup or "default"
                for _, pack in ipairs(soundPacks) do
                    if pack.value == levelupSound then
                        UIDropDownMenu_SetText(levelDropdown, pack.text)
                        break
                    end
                end
                
                -- Achievement
                local achieveSound = BLU.db.profile.selectedSounds.achievement or "default"
                for _, pack in ipairs(soundPacks) do
                    if pack.value == achieveSound then
                        UIDropDownMenu_SetText(achieveDropdown, pack.text)
                        break
                    end
                end
                
                -- Quest
                local questSound = BLU.db.profile.selectedSounds.quest or "default"
                for _, pack in ipairs(soundPacks) do
                    if pack.value == questSound then
                        UIDropDownMenu_SetText(questDropdown, pack.text)
                        break
                    end
                end
            else
                UIDropDownMenu_SetText(levelDropdown, "Default WoW")
                UIDropDownMenu_SetText(achieveDropdown, "Default WoW")
                UIDropDownMenu_SetText(questDropdown, "Default WoW")
            end
        end
    end)
    
    -- Store reference
    BLU.OptionsPanel = panel
    
    -- Register the panel based on WoW version
    local category
    if Settings and Settings.RegisterCanvasLayoutCategory then
        -- Dragonflight+ (10.0+)
        category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
        BLU.OptionsCategory = category
        print("|cff05dffaBLU: Options panel registered with new Settings API|r")
    else
        -- Pre-Dragonflight
        InterfaceOptions_AddCategory(panel)
        BLU.OptionsCategory = panel
        print("|cff05dffaBLU: Options panel registered with legacy API|r")
    end
    
    print("|cff05dffaBLU: Panel creation complete. Type /blu to open.|r")
    
    return panel
end

-- Simple open function
function BLU:OpenSimpleOptions()
    print("|cff05dffaBLU: OpenSimpleOptions called|r")
    
    if not BLU.OptionsPanel then
        print("|cff05dffaBLU: Panel doesn't exist, creating now...|r")
        BLU:CreateSimpleOptionsPanel()
    else
        print("|cff05dffaBLU: Panel already exists|r")
    end
    
    if Settings and Settings.OpenToCategory and BLU.OptionsCategory then
        -- Try new API
        print("|cff05dffaBLU: Using new Settings API|r")
        Settings.OpenToCategory(BLU.OptionsCategory)
    elseif InterfaceOptionsFrame then
        -- Try legacy API
        print("|cff05dffaBLU: Using legacy InterfaceOptions API|r")
        InterfaceOptionsFrame_OpenToCategory(BLU.OptionsPanel)
        -- Call twice to ensure it opens to the right panel
        InterfaceOptionsFrame_OpenToCategory(BLU.OptionsPanel)
    else
        BLU:Print("Cannot open options - no compatible API found")
    end
end