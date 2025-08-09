--=====================================================================================
-- BLU | Advanced Settings Panel - Technical Configuration
-- Author: donniedice
-- Description: Advanced technical settings, debugging, and experimental features
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateAdvancedPanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()
    panel:Hide()
    
    -- Create scrollable container
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth(), 800)
    scrollFrame:SetScrollChild(content)
    
    -- Title
    local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Advanced Settings")
    
    local subtitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    subtitle:SetPoint("TOPLEFT", 16, -35)
    subtitle:SetText("Warning: These settings are for advanced users")
    subtitle:SetTextColor(1, 0.8, 0)
    
    local yOffset = -60
    
    -- Sound Engine Section
    local engineSection = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    engineSection:SetPoint("TOPLEFT", 16, yOffset)
    engineSection:SetText("Sound Engine")
    engineSection:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    -- Sound handle pooling
    local poolingCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    poolingCheck:SetPoint("TOPLEFT", 30, yOffset)
    poolingCheck.text = poolingCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    poolingCheck.text:SetPoint("LEFT", poolingCheck, "RIGHT", 5, 0)
    poolingCheck.text:SetText("Enable sound handle pooling (reduces memory allocation)")
    poolingCheck:SetChecked(BLU.db.soundPooling)
    poolingCheck:SetScript("OnClick", function(self)
        BLU.db.soundPooling = self:GetChecked()
    end)
    
    yOffset = yOffset - 30
    
    -- Async loading
    local asyncCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    asyncCheck:SetPoint("TOPLEFT", 30, yOffset)
    asyncCheck.text = asyncCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    asyncCheck.text:SetPoint("LEFT", asyncCheck, "RIGHT", 5, 0)
    asyncCheck.text:SetText("Asynchronous sound loading (experimental)")
    asyncCheck:SetChecked(BLU.db.asyncLoading)
    asyncCheck:SetScript("OnClick", function(self)
        BLU.db.asyncLoading = self:GetChecked()
    end)
    
    yOffset = yOffset - 30
    
    -- Sound queue size
    local queueLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    queueLabel:SetPoint("TOPLEFT", 30, yOffset)
    queueLabel:SetText("Sound queue size:")
    
    local queueSlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
    queueSlider:SetPoint("LEFT", queueLabel, "RIGHT", 20, 0)
    queueSlider:SetSize(200, 20)
    queueSlider:SetMinMaxValues(1, 10)
    queueSlider:SetValueStep(1)
    queueSlider:SetObeyStepOnDrag(true)
    queueSlider.Low:SetText("1")
    queueSlider.High:SetText("10")
    queueSlider.Text:SetText("")
    
    local queueValue = queueSlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    queueValue:SetPoint("LEFT", queueSlider, "RIGHT", 10, 0)
    queueSlider:SetValue(BLU.db.soundQueueSize or 3)
    queueValue:SetText(tostring(BLU.db.soundQueueSize or 3))
    
    queueSlider:SetScript("OnValueChanged", function(self, value)
        BLU.db.soundQueueSize = value
        queueValue:SetText(tostring(value))
    end)
    
    yOffset = yOffset - 30
    
    -- Fade time
    local fadeLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fadeLabel:SetPoint("TOPLEFT", 30, yOffset)
    fadeLabel:SetText("Sound fade time (ms):")
    
    local fadeSlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
    fadeSlider:SetPoint("LEFT", fadeLabel, "RIGHT", 20, 0)
    fadeSlider:SetSize(200, 20)
    fadeSlider:SetMinMaxValues(0, 1000)
    fadeSlider:SetValueStep(50)
    fadeSlider:SetObeyStepOnDrag(true)
    fadeSlider.Low:SetText("0")
    fadeSlider.High:SetText("1000")
    fadeSlider.Text:SetText("")
    
    local fadeValue = fadeSlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fadeValue:SetPoint("LEFT", fadeSlider, "RIGHT", 10, 0)
    fadeSlider:SetValue(BLU.db.fadeTime or 200)
    fadeValue:SetText(tostring(BLU.db.fadeTime or 200) .. " ms")
    
    fadeSlider:SetScript("OnValueChanged", function(self, value)
        BLU.db.fadeTime = value
        fadeValue:SetText(tostring(value) .. " ms")
    end)
    
    yOffset = yOffset - 50
    
    -- Module System Section
    local moduleSection = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    moduleSection:SetPoint("TOPLEFT", 16, yOffset)
    moduleSection:SetText("Module System")
    moduleSection:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    -- Lazy loading
    local lazyCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    lazyCheck:SetPoint("TOPLEFT", 30, yOffset)
    lazyCheck.text = lazyCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lazyCheck.text:SetPoint("LEFT", lazyCheck, "RIGHT", 5, 0)
    lazyCheck.text:SetText("Enable lazy module loading")
    lazyCheck:SetChecked(BLU.db.lazyLoading)
    lazyCheck:SetScript("OnClick", function(self)
        BLU.db.lazyLoading = self:GetChecked()
    end)
    
    yOffset = yOffset - 30
    
    -- Module timeout
    local timeoutLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    timeoutLabel:SetPoint("TOPLEFT", 30, yOffset)
    timeoutLabel:SetText("Module load timeout (sec):")
    
    local timeoutSlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
    timeoutSlider:SetPoint("LEFT", timeoutLabel, "RIGHT", 20, 0)
    timeoutSlider:SetSize(200, 20)
    timeoutSlider:SetMinMaxValues(1, 30)
    timeoutSlider:SetValueStep(1)
    timeoutSlider:SetObeyStepOnDrag(true)
    timeoutSlider.Low:SetText("1")
    timeoutSlider.High:SetText("30")
    timeoutSlider.Text:SetText("")
    
    local timeoutValue = timeoutSlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    timeoutValue:SetPoint("LEFT", timeoutSlider, "RIGHT", 10, 0)
    timeoutSlider:SetValue(BLU.db.moduleTimeout or 5)
    timeoutValue:SetText(tostring(BLU.db.moduleTimeout or 5) .. " sec")
    
    timeoutSlider:SetScript("OnValueChanged", function(self, value)
        BLU.db.moduleTimeout = value
        timeoutValue:SetText(tostring(value) .. " sec")
    end)
    
    yOffset = yOffset - 50
    
    -- Debugging Section
    local debugSection = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    debugSection:SetPoint("TOPLEFT", 16, yOffset)
    debugSection:SetText("Debugging")
    debugSection:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    -- Debug level dropdown
    local debugLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    debugLabel:SetPoint("TOPLEFT", 30, yOffset)
    debugLabel:SetText("Debug level:")
    
    local debugDropdown = CreateFrame("Frame", "BLUDebugDropdown", content, "UIDropDownMenuTemplate")
    debugDropdown:SetPoint("LEFT", debugLabel, "RIGHT", 10, 0)
    UIDropDownMenu_SetWidth(debugDropdown, 150)
    
    local debugLevels = {
        {value = 0, text = "Off"},
        {value = 1, text = "Errors only"},
        {value = 2, text = "Warnings"},
        {value = 3, text = "Info"},
        {value = 4, text = "Verbose"},
        {value = 5, text = "Trace"}
    }
    
    UIDropDownMenu_SetText(debugDropdown, debugLevels[(BLU.db.debugLevel or 0) + 1].text)
    
    UIDropDownMenu_Initialize(debugDropdown, function(self, level)
        for _, debugInfo in ipairs(debugLevels) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = debugInfo.text
            info.value = debugInfo.value
            info.func = function()
                BLU.db.debugLevel = debugInfo.value
                UIDropDownMenu_SetText(debugDropdown, debugInfo.text)
            end
            info.checked = (BLU.db.debugLevel == debugInfo.value)
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    yOffset = yOffset - 30
    
    -- Console output
    local consoleCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    consoleCheck:SetPoint("TOPLEFT", 30, yOffset)
    consoleCheck.text = consoleCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    consoleCheck.text:SetPoint("LEFT", consoleCheck, "RIGHT", 5, 0)
    consoleCheck.text:SetText("Output debug to console")
    consoleCheck:SetChecked(BLU.db.debugToConsole)
    consoleCheck:SetScript("OnClick", function(self)
        BLU.db.debugToConsole = self:GetChecked()
    end)
    
    yOffset = yOffset - 30
    
    -- Log to file
    local logCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    logCheck:SetPoint("TOPLEFT", 30, yOffset)
    logCheck.text = logCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    logCheck.text:SetPoint("LEFT", logCheck, "RIGHT", 5, 0)
    logCheck.text:SetText("Log debug to SavedVariables")
    logCheck:SetChecked(BLU.db.debugToFile)
    logCheck:SetScript("OnClick", function(self)
        BLU.db.debugToFile = self:GetChecked()
    end)
    
    yOffset = yOffset - 30
    
    -- Performance profiling
    local profilingCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    profilingCheck:SetPoint("TOPLEFT", 30, yOffset)
    profilingCheck.text = profilingCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    profilingCheck.text:SetPoint("LEFT", profilingCheck, "RIGHT", 5, 0)
    profilingCheck.text:SetText("Enable performance profiling")
    profilingCheck:SetChecked(BLU.db.profiling)
    profilingCheck:SetScript("OnClick", function(self)
        BLU.db.profiling = self:GetChecked()
    end)
    
    yOffset = yOffset - 50
    
    -- Experimental Features Section
    local expSection = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    expSection:SetPoint("TOPLEFT", 16, yOffset)
    expSection:SetText("Experimental Features")
    expSection:SetTextColor(1, 0.5, 0)
    
    yOffset = yOffset - 30
    
    -- 3D positional audio
    local posAudioCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    posAudioCheck:SetPoint("TOPLEFT", 30, yOffset)
    posAudioCheck.text = posAudioCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    posAudioCheck.text:SetPoint("LEFT", posAudioCheck, "RIGHT", 5, 0)
    posAudioCheck.text:SetText("3D positional audio (EXPERIMENTAL)")
    posAudioCheck:SetChecked(BLU.db.positionalAudio)
    posAudioCheck:SetScript("OnClick", function(self)
        BLU.db.positionalAudio = self:GetChecked()
    end)
    
    yOffset = yOffset - 30
    
    -- Dynamic compression
    local compressionCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    compressionCheck:SetPoint("TOPLEFT", 30, yOffset)
    compressionCheck.text = compressionCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    compressionCheck.text:SetPoint("LEFT", compressionCheck, "RIGHT", 5, 0)
    compressionCheck.text:SetText("Dynamic audio compression")
    compressionCheck:SetChecked(BLU.db.dynamicCompression)
    compressionCheck:SetScript("OnClick", function(self)
        BLU.db.dynamicCompression = self:GetChecked()
    end)
    
    yOffset = yOffset - 30
    
    -- AI-powered sound selection
    local aiSoundCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    aiSoundCheck:SetPoint("TOPLEFT", 30, yOffset)
    aiSoundCheck.text = aiSoundCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    aiSoundCheck.text:SetPoint("LEFT", aiSoundCheck, "RIGHT", 5, 0)
    aiSoundCheck.text:SetText("AI-powered contextual sound selection")
    aiSoundCheck:SetChecked(BLU.db.aiSounds)
    aiSoundCheck:SetScript("OnClick", function(self)
        BLU.db.aiSounds = self:GetChecked()
    end)
    
    yOffset = yOffset - 50
    
    -- Integration Section
    local intSection = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    intSection:SetPoint("TOPLEFT", 16, yOffset)
    intSection:SetText("Integration")
    intSection:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    -- WeakAuras integration
    local waCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    waCheck:SetPoint("TOPLEFT", 30, yOffset)
    waCheck.text = waCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    waCheck.text:SetPoint("LEFT", waCheck, "RIGHT", 5, 0)
    waCheck.text:SetText("Enable WeakAuras integration")
    waCheck:SetChecked(BLU.db.weakAurasIntegration)
    waCheck:SetScript("OnClick", function(self)
        BLU.db.weakAurasIntegration = self:GetChecked()
    end)
    
    yOffset = yOffset - 30
    
    -- Discord Rich Presence
    local discordCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    discordCheck:SetPoint("TOPLEFT", 30, yOffset)
    discordCheck.text = discordCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    discordCheck.text:SetPoint("LEFT", discordCheck, "RIGHT", 5, 0)
    discordCheck.text:SetText("Discord Rich Presence support")
    discordCheck:SetChecked(BLU.db.discordIntegration)
    discordCheck:SetScript("OnClick", function(self)
        BLU.db.discordIntegration = self:GetChecked()
    end)
    
    yOffset = yOffset - 50
    
    -- Maintenance Section
    local maintSection = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    maintSection:SetPoint("TOPLEFT", 16, yOffset)
    maintSection:SetText("Maintenance")
    maintSection:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    -- Clear cache button
    local clearCacheBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    clearCacheBtn:SetSize(150, 24)
    clearCacheBtn:SetPoint("TOPLEFT", 30, yOffset)
    clearCacheBtn:SetText("Clear Sound Cache")
    clearCacheBtn:SetScript("OnClick", function()
        BLU:ClearSoundCache()
        print("|cff00ccffBLU:|r Sound cache cleared")
    end)
    
    -- Reset settings button
    local resetBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    resetBtn:SetSize(150, 24)
    resetBtn:SetPoint("LEFT", clearCacheBtn, "RIGHT", 10, 0)
    resetBtn:SetText("Reset Advanced Settings")
    resetBtn:SetScript("OnClick", function()
        StaticPopup_Show("BLU_RESET_ADVANCED")
    end)
    
    -- Rebuild database button
    local rebuildBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    rebuildBtn:SetSize(150, 24)
    rebuildBtn:SetPoint("LEFT", resetBtn, "RIGHT", 10, 0)
    rebuildBtn:SetText("Rebuild Database")
    rebuildBtn:SetScript("OnClick", function()
        BLU:RebuildDatabase()
        print("|cff00ccffBLU:|r Database rebuilt")
    end)
    
    -- Warning text
    local warningText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    warningText:SetPoint("BOTTOMLEFT", 20, 40)
    warningText:SetPoint("BOTTOMRIGHT", -20, 40)
    warningText:SetJustifyH("LEFT")
    warningText:SetText("WARNING: These settings can affect addon performance and stability. Only change them if you know what you're doing.")
    warningText:SetTextColor(1, 0.5, 0)
    
    return panel
end

-- Reset dialog
StaticPopupDialogs["BLU_RESET_ADVANCED"] = {
    text = "Reset all advanced settings to defaults?",
    button1 = "Reset",
    button2 = "Cancel",
    OnAccept = function()
        BLU:ResetAdvancedSettings()
        print("|cff00ccffBLU:|r Advanced settings reset to defaults")
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true
}