--=====================================================================================
-- BLU - interface/options/general.lua
-- General settings panel
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

-- Create general module
local General = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["general"] = General

function BLU.CreateGeneralPanel(content)
    if not content then
        BLU:PrintError("CreateGeneralPanel: content is nil")
        return
    end
    
    BLU:PrintDebug("[General] Creating general settings panel")
    
    -- Title
    local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -20)
    title:SetText("General Settings")
    title:SetTextColor(unpack(BLU.Modules.design.Colors.Primary))
    
    -- Enable addon checkbox
    local enableAddon = CreateFrame("CheckButton", nil, content, "InterfaceOptionsCheckButtonTemplate")
    enableAddon:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -20)
    enableAddon.Text:SetText("Enable BLU")
    
    if BLU.db and BLU.db.profile then
        enableAddon:SetChecked(BLU.db.profile.enabled ~= false)
    else
        enableAddon:SetChecked(true)
    end
    
    enableAddon:SetScript("OnClick", function(self)
        if BLU.db and BLU.db.profile then
            BLU.db.profile.enabled = self:GetChecked()
            if self:GetChecked() then
                BLU:Print("|cff00ff00BLU Enabled|r")
            else
                BLU:Print("|cffff0000BLU Disabled|r")
            end
        end
    end)
    
    -- Welcome message checkbox
    local welcomeMsg = CreateFrame("CheckButton", nil, content, "InterfaceOptionsCheckButtonTemplate")
    welcomeMsg:SetPoint("TOPLEFT", enableAddon, "BOTTOMLEFT", 0, -10)
    welcomeMsg.Text:SetText("Show Welcome Message")
    
    if BLU.db and BLU.db.profile then
        welcomeMsg:SetChecked(BLU.db.profile.showWelcomeMessage ~= false)
    else
        welcomeMsg:SetChecked(true)
    end
    
    welcomeMsg:SetScript("OnClick", function(self)
        if BLU.db and BLU.db.profile then
            BLU.db.profile.showWelcomeMessage = self:GetChecked()
        end
    end)
    
    -- Debug mode checkbox
    local debugMode = CreateFrame("CheckButton", nil, content, "InterfaceOptionsCheckButtonTemplate")
    debugMode:SetPoint("TOPLEFT", welcomeMsg, "BOTTOMLEFT", 0, -10)
    debugMode.Text:SetText("Debug Mode")
    
    if BLU.db and BLU.db.profile then
        debugMode:SetChecked(BLU.db.profile.debugMode == true)
    else
        debugMode:SetChecked(false) -- Default to false if not set
    end
    
    debugMode:SetScript("OnClick", function(self)
        if BLU.db and BLU.db.profile then
            BLU.db.profile.debugMode = self:GetChecked()
            BLU.debugMode = self:GetChecked()
            BLU:Print("Debug mode " .. (self:GetChecked() and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
        end
    end)
    
    -- Sound Channel dropdown
    local channelLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    channelLabel:SetPoint("TOPLEFT", debugMode, "BOTTOMLEFT", 5, -30)
    channelLabel:SetText("Sound Channel:")
    
    local channelDropdown = CreateFrame("Frame", "BLUSoundChannelDropdown", content, "UIDropDownMenuTemplate")
    channelDropdown:SetPoint("TOPLEFT", channelLabel, "BOTTOMLEFT", -15, -5)
    
    local channels = {"Master", "SFX", "Music", "Ambience", "Dialog"}
    
    UIDropDownMenu_SetWidth(channelDropdown, 150)
    UIDropDownMenu_SetText(channelDropdown, BLU.db and BLU.db.profile and BLU.db.profile.soundChannel or "Master")
    
    UIDropDownMenu_Initialize(channelDropdown, function(self, level)
        for _, channel in ipairs(channels) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = channel
            info.func = function()
                if BLU.db and BLU.db.profile then
                    BLU.db.profile.soundChannel = channel
                end
                UIDropDownMenu_SetText(channelDropdown, channel)
            end
            info.checked = (BLU.db and BLU.db.profile and BLU.db.profile.soundChannel == channel)
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    -- Master Volume Slider
    local volumeLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    volumeLabel:SetPoint("TOPLEFT", channelDropdown, "BOTTOMLEFT", 15, -30)
    volumeLabel:SetText("Master Volume:")
    
    local volumeSlider = CreateFrame("Slider", "BLUMasterVolumeSlider", content, "OptionsSliderTemplate")
    volumeSlider:SetPoint("TOPLEFT", volumeLabel, "BOTTOMLEFT", 5, -10)
    volumeSlider:SetWidth(250)
    volumeSlider:SetMinMaxValues(0, 100)
    volumeSlider:SetValueStep(1)
    volumeSlider:SetObeyStepOnDrag(true)
    
    local savedVolume = 100
    if BLU.db and BLU.db.profile and BLU.db.profile.masterVolume then
        savedVolume = BLU.db.profile.masterVolume * 100
    end
    volumeSlider:SetValue(savedVolume)
    
    volumeSlider.Low:SetText("0%")
    volumeSlider.High:SetText("100%")
    volumeSlider.Text:SetText(math.floor(savedVolume) .. "%")
    
    volumeSlider:SetScript("OnValueChanged", function(self, value)
        self.Text:SetText(math.floor(value) .. "%")
        if BLU.db and BLU.db.profile then
            BLU.db.profile.masterVolume = value / 100
        end
    end)
    
    -- Divider
    local divider = content:CreateTexture(nil, "ARTWORK")
    divider:SetHeight(1)
    divider:SetPoint("TOPLEFT", volumeSlider, "BOTTOMLEFT", -5, -30)
    divider:SetPoint("RIGHT", -20, 0)
    divider:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    
    -- Profile section
    local profileTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    profileTitle:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 0, -20)
    profileTitle:SetText("Profile Management:")
    profileTitle:SetTextColor(unpack(BLU.Modules.design.Colors.Primary))
    
    local profileDesc = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    profileDesc:SetPoint("TOPLEFT", profileTitle, "BOTTOMLEFT", 0, -5)
    profileDesc:SetWidth(content:GetWidth() - 40)
    profileDesc:SetJustifyH("LEFT")
    profileDesc:SetText("Profiles allow you to save different configurations. Coming soon!")
    profileDesc:SetTextColor(0.7, 0.7, 0.7)
    
    BLU:PrintDebug("[General] General settings panel created successfully")
end

function General:Init()
    BLU:PrintDebug("[General] General panel module initialized")
end

-- Register module
if BLU.RegisterModule then
    BLU:RegisterModule(General, "general", "General Settings Panel")
end