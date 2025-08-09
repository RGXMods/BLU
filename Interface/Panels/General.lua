--=====================================================================================
-- BLU | General Settings Panel
-- Author: donniedice
-- Description: Main settings and volume controls
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateGeneralPanel()
    local panel = CreateFrame("Frame", nil, UIParent)
    panel:Hide()
    
    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("General Settings")
    
    local yOffset = -50
    
    -- Enable addon checkbox
    local enableCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    enableCheck:SetPoint("TOPLEFT", 20, yOffset)
    enableCheck.text = enableCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableCheck.text:SetPoint("LEFT", enableCheck, "RIGHT", 5, 0)
    enableCheck.text:SetText("Enable BLU Sound System")
    enableCheck:SetChecked(BLU:GetDB("enabled") or true)
    enableCheck:SetScript("OnClick", function(self)
        BLU:SetDB("enabled", self:GetChecked())
    end)
    
    yOffset = yOffset - 40
    
    -- Master Volume Section
    local volumeTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    volumeTitle:SetPoint("TOPLEFT", 16, yOffset)
    volumeTitle:SetText("Volume Settings")
    volumeTitle:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    -- Master volume slider
    local volumeSlider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
    volumeSlider:SetPoint("TOPLEFT", 30, yOffset)
    volumeSlider:SetSize(300, 20)
    volumeSlider:SetMinMaxValues(0, 100)
    volumeSlider:SetValueStep(1)
    volumeSlider:SetObeyStepOnDrag(true)
    volumeSlider.Low:SetText("0")
    volumeSlider.High:SetText("100")
    volumeSlider.Text:SetText("Master Volume")
    
    -- Volume value display
    local volumeValue = volumeSlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    volumeValue:SetPoint("TOP", volumeSlider, "BOTTOM", 0, -5)
    volumeSlider.valueDisplay = volumeValue
    
    volumeSlider:SetValue(BLU:GetDB("soundVolume") or 100)
    volumeValue:SetText(string.format("%d%%", BLU:GetDB("soundVolume") or 100))
    
    volumeSlider:SetScript("OnValueChanged", function(self, value)
        BLU:SetDB("soundVolume", value)
        self.valueDisplay:SetText(string.format("%d%%", value))
    end)
    
    -- Test volume button
    local testVolumeBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    testVolumeBtn:SetSize(80, 22)
    testVolumeBtn:SetPoint("LEFT", volumeSlider, "RIGHT", 20, 0)
    testVolumeBtn:SetText("Test")
    testVolumeBtn:SetScript("OnClick", function()
        BLU:PlayTestSound("levelup", volumeSlider:GetValue())
    end)
    
    yOffset = yOffset - 60
    
    -- Sound Channel Info (using default)
    local channelInfo = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    channelInfo:SetPoint("TOPLEFT", 30, yOffset)
    channelInfo:SetText("Sound Channel: |cff00ff00Default|r (Follows game settings)")
    channelInfo:SetTextColor(0.8, 0.8, 0.8)
    
    yOffset = yOffset - 30
    
    -- Quick Settings Section
    local quickTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    quickTitle:SetPoint("TOPLEFT", 16, yOffset)
    quickTitle:SetText("Quick Settings")
    quickTitle:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    -- Play sounds in background
    local bgSoundsCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    bgSoundsCheck:SetPoint("TOPLEFT", 30, yOffset)
    bgSoundsCheck.text = bgSoundsCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bgSoundsCheck.text:SetPoint("LEFT", bgSoundsCheck, "RIGHT", 5, 0)
    bgSoundsCheck.text:SetText("Play sounds when game is in background")
    bgSoundsCheck:SetChecked(BLU:GetDB("playInBackground") or false)
    bgSoundsCheck:SetScript("OnClick", function(self)
        BLU:SetDB("playInBackground", self:GetChecked())
        SetCVar("Sound_EnableSoundWhenGameIsInBG", self:GetChecked() and "1" or "0")
    end)
    
    yOffset = yOffset - 30
    
    -- Random sound variation
    local randomCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    randomCheck:SetPoint("TOPLEFT", 30, yOffset)
    randomCheck.text = randomCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    randomCheck.text:SetPoint("LEFT", randomCheck, "RIGHT", 5, 0)
    randomCheck.text:SetText("Enable random sound variations")
    randomCheck:SetChecked(BLU:GetDB("randomSounds") or false)
    randomCheck:SetScript("OnClick", function(self)
        BLU:SetDB("randomSounds", self:GetChecked())
    end)
    
    yOffset = yOffset - 30
    
    -- Debug mode
    local debugCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    debugCheck:SetPoint("TOPLEFT", 30, yOffset)
    debugCheck.text = debugCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    debugCheck.text:SetPoint("LEFT", debugCheck, "RIGHT", 5, 0)
    debugCheck.text:SetText("Enable debug messages")
    debugCheck:SetChecked(BLU:GetDB("debugMode") or false)
    debugCheck:SetScript("OnClick", function(self)
        BLU:SetDB("debugMode", self:GetChecked())
    end)
    
    yOffset = yOffset - 50
    
    -- Performance Section
    local perfTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    perfTitle:SetPoint("TOPLEFT", 16, yOffset)
    perfTitle:SetText("Performance")
    perfTitle:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    -- Preload sounds
    local preloadCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    preloadCheck:SetPoint("TOPLEFT", 30, yOffset)
    preloadCheck.text = preloadCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    preloadCheck.text:SetPoint("LEFT", preloadCheck, "RIGHT", 5, 0)
    preloadCheck.text:SetText("Preload sounds on startup (uses more memory)")
    preloadCheck:SetChecked(BLU:GetDB("preloadSounds") or false)
    preloadCheck:SetScript("OnClick", function(self)
        BLU:SetDB("preloadSounds", self:GetChecked())
    end)
    
    yOffset = yOffset - 30
    
    -- Sound cache size
    local cacheTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cacheTitle:SetPoint("TOPLEFT", 30, yOffset)
    cacheTitle:SetText("Sound cache size:")
    
    local cacheSlider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
    cacheSlider:SetPoint("LEFT", cacheTitle, "RIGHT", 20, 0)
    cacheSlider:SetSize(200, 20)
    cacheSlider:SetMinMaxValues(10, 100)
    cacheSlider:SetValueStep(10)
    cacheSlider:SetObeyStepOnDrag(true)
    cacheSlider.Low:SetText("10")
    cacheSlider.High:SetText("100")
    cacheSlider.Text:SetText("")
    
    local cacheValue = cacheSlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cacheValue:SetPoint("TOP", cacheSlider, "BOTTOM", 0, -5)
    cacheValue:SetText(string.format("%d MB", BLU:GetDB("cacheSize") or 50))
    cacheSlider.valueDisplay = cacheValue
    
    cacheSlider:SetValue(BLU:GetDB("cacheSize") or 50)
    cacheSlider:SetScript("OnValueChanged", function(self, value)
        BLU:SetDB("cacheSize", value)
        self.valueDisplay:SetText(string.format("%d MB", value))
    end)
    
    -- Info text at bottom
    local infoText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    infoText:SetPoint("BOTTOMLEFT", 20, 20)
    infoText:SetPoint("BOTTOMRIGHT", -20, 20)
    infoText:SetJustifyH("LEFT")
    infoText:SetText("Tip: Use Test Mode to preview sounds without triggering game events. Access more options in the other tabs.")
    infoText:SetTextColor(0.7, 0.7, 0.7)
    
    -- Register with tab system
    if BLU.TabSystem then
        BLU.TabSystem:RegisterPanel("general", panel)
    end
    
    return panel
end