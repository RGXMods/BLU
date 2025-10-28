--=====================================================================================
-- BLU - interface/panels/general_new.lua
-- General settings panel with new design
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

function BLU.CreateGeneralPanel(panel)
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 5)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(680)
    scrollFrame:SetScrollChild(content)
    
    local coreSection = BLU.Design:CreateSection(content, "Core Settings", "Interface\Icons\Achievement_General")
    coreSection:SetPoint("TOPLEFT", 0, 0)
    coreSection:SetPoint("RIGHT", 0, 0)
    coreSection:SetHeight(120)

    local enableCheck = BLU.Design:CreateCheckbox(coreSection.content, "Enable BLU", "Enable or disable all BLU functionality")
    enableCheck:SetPoint("TOPLEFT", 10, -10)
    enableCheck.check:SetChecked(BLU.db.profile.enabled)
    enableCheck.check:SetScript("OnClick", function(self)
        if not BLU.db or not BLU.db.profile then return end
        BLU.db.profile.enabled = self:GetChecked()
        if BLU.db.profile.enabled then BLU:Enable() else BLU:Disable() end
        BLU:Print(BLU.db.profile.enabled and "|cff00ff00BLU Enabled|r" or "|cffff0000BLU Disabled|r")
    end)

    local welcomeCheck = BLU.Design:CreateCheckbox(coreSection.content, "Show welcome message", "Display addon loaded message on login")
    welcomeCheck:SetPoint("TOPLEFT", enableCheck, "BOTTOMLEFT", 0, -15)
    welcomeCheck.check:SetChecked(BLU.db.profile.showWelcomeMessage)
    welcomeCheck.check:SetScript("OnClick", function(self)
        if not BLU.db or not BLU.db.profile then return end
        BLU.db.profile.showWelcomeMessage = self:GetChecked()
        BLU.Modules.config:ApplySettings()
    end)

    local debugCheck = BLU.Design:CreateCheckbox(coreSection.content, "Debug mode", "Show debug messages in chat")
    debugCheck:SetPoint("TOPLEFT", welcomeCheck, "BOTTOMLEFT", 0, -15)
    debugCheck.check:SetChecked(BLU.db.profile.debugMode)
    debugCheck.check:SetScript("OnClick", function(self)
        if not BLU.db or not BLU.db.profile then return end
        BLU.db.profile.debugMode = self:GetChecked()
        BLU.Modules.config:ApplySettings()
    end)

    local audioSection = BLU.Design:CreateSection(content, "Audio Settings", "Interface\Icons\INV_Misc_Headphones_01")
    audioSection:SetPoint("TOPLEFT", coreSection, "BOTTOMLEFT", 0, -10)
    audioSection:SetPoint("RIGHT", 0, 0)
    audioSection:SetHeight(150)

    local volumeSlider = BLU.Widgets:CreateSlider(audioSection.content, "Master Volume", 0, 100, 5, "Sets the master volume for all BLU sounds.")
    volumeSlider:SetPoint("TOPLEFT", 10, -10)
    volumeSlider:SetValue(BLU.db.profile.masterVolume * 100)
    volumeSlider.value:SetText(string.format("%d%%", BLU.db.profile.masterVolume * 100))
    volumeSlider:SetScript("OnValueChanged", function(self, value)
        if not BLU.db or not BLU.db.profile then return end
        BLU.db.profile.masterVolume = value / 100
        self.value:SetText(string.format("%d%%", value))
    end)

    local channelDropdown = BLU.Widgets:CreateDropdown(audioSection.content, "Sound Channel", 200, {}, "Select the audio channel for sounds.")
    channelDropdown:SetPoint("TOPLEFT", volumeSlider, "BOTTOMLEFT", 0, -30)
    
    UIDropDownMenu_Initialize(channelDropdown, function(self)
        local channels = {"Master", "SFX", "Music", "Ambience"}
        for _, channel in ipairs(channels) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = channel
            info.value = channel
            info.func = function()
                if not BLU.db or not BLU.db.profile then return end
                BLU.db.profile.soundChannel = channel
                UIDropDownMenu_SetText(self, channel)
            end
            info.checked = (BLU.db.profile.soundChannel == channel)
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetText(channelDropdown, BLU.db.profile.soundChannel or "Master")

    local behaviorSection = BLU.Design:CreateSection(content, "Behavior Settings", "Interface\Icons\INV_Misc_GroupLooking")
    behaviorSection:SetPoint("TOPLEFT", audioSection, "BOTTOMLEFT", 0, -10)
    behaviorSection:SetPoint("RIGHT", 0, 0)
    behaviorSection:SetHeight(120)

    local muteCheck = BLU.Design:CreateCheckbox(behaviorSection.content, "Mute in instances", "Disable sounds while in dungeons, raids, or PvP")
    muteCheck:SetPoint("TOPLEFT", 10, -10)
    muteCheck.check:SetChecked(BLU.db.profile.muteInInstances or false)
    muteCheck.check:SetScript("OnClick", function(self)
        if not BLU.db or not BLU.db.profile then return end
        BLU.db.profile.muteInInstances = self:GetChecked()
    end)

    local combatCheck = BLU.Design:CreateCheckbox(behaviorSection.content, "Mute in combat", "Disable sounds while in combat")
    combatCheck:SetPoint("TOPLEFT", muteCheck, "BOTTOMLEFT", 0, -15)
    combatCheck.check:SetChecked(BLU.db.profile.muteInCombat or false)
    combatCheck.check:SetScript("OnClick", function(self)
        if not BLU.db or not BLU.db.profile then return end
        BLU.db.profile.muteInCombat = self:GetChecked()
    end)

    local actionsSection = BLU.Design:CreateSection(content, "Actions", "Interface\Icons\ACHIEVEMENT_GUILDPERK_QUICK AND DEAD")
    actionsSection:SetPoint("TOPLEFT", behaviorSection, "BOTTOMLEFT", 0, -10)
    actionsSection:SetPoint("RIGHT", 0, 0)
    actionsSection:SetHeight(60)

    local resetBtn = BLU.Design:CreateButton(actionsSection.content, "Reset to Defaults", 120, 24)
    resetBtn:SetPoint("LEFT", 10, 0)
    resetBtn:SetScript("OnClick", function()
        StaticPopup_Show("BLU_RESET_CONFIRM")
    end)

    local reloadBtn = BLU.Design:CreateButton(actionsSection.content, "Reload UI", 80, 24)
    reloadBtn:SetPoint("LEFT", resetBtn, "RIGHT", 10, 0)
    reloadBtn:SetScript("OnClick", function()
        ReloadUI()
    end)

    StaticPopupDialogs["BLU_RESET_CONFIRM"] = {
        text = "Are you sure you want to reset all BLU settings to defaults?\n\nThis cannot be undone.",
        button1 = YES,
        button2 = NO,
        OnAccept = function()
            if BLU.ResetToDefaults then
                BLU:ResetToDefaults()
            end
            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }

    content:SetHeight(600)
end