--=====================================================================================
-- BLU - interface/options/general.lua
-- General options panel
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

local function IsProfileReady()
    return BLU and BLU.db
end

local function EnsureProfileDefaults()
    if not BLU or not BLU.db then
        return false 
    end

    local profile = BLU.db
    profile.soundVolume = tonumber(profile.soundVolume) or 100
    profile.soundChannel = profile.soundChannel or "Master"
    profile.maxQueueSize = tonumber(profile.maxQueueSize) or 3
    profile.queueSounds = profile.queueSounds ~= false
    profile.muteInInstances = profile.muteInInstances == true
    profile.muteInCombat = profile.muteInCombat == true
    profile.modules = profile.modules or {}
    return true
end

local function CreateCheckbox(parent, text, x, y, checked, onClick, tooltip)
    local checkbox = BLU.Modules.design:CreateCheckbox(parent, text, tooltip)
    checkbox:SetPoint("TOPLEFT", x, y)
    checkbox.check:SetChecked(checked)
    checkbox.check:SetScript("OnClick", onClick)
    return checkbox
end

local SOUND_CHANNELS = {
    "Master",
    "SFX",
    "Music",
    "Ambience",
    "Dialog",
}


local CHANNEL_CVARS = {
    Master   = "Sound_MasterVolume",
    SFX      = "Sound_SFXVolume",
    Music    = "Sound_MusicVolume",
    Ambience = "Sound_AmbienceVolume",
    Dialog   = "Sound_DialogVolume",
}

local function GetChannelVolume(profile)
    local cvar = CHANNEL_CVARS[profile.soundChannel or "Master"] or "Sound_MasterVolume"
    return math.floor((tonumber(GetCVar(cvar)) or 1) * 100)
end

local function SetChannelVolume(profile, val)
    local cvar = CHANNEL_CVARS[profile.soundChannel or "Master"] or "Sound_MasterVolume"
    SetCVar(cvar, val / 100)
end

function BLU.CreateGeneralPanel(panel)
    BLU:PrintDebug("[Options/General] Creating General panel")
    local content = CreateFrame("Frame", nil, panel)
    content:SetPoint("TOPLEFT", 1, -8)
    content:SetPoint("BOTTOMRIGHT", -7, 8)

    local contentBg = content:CreateTexture(nil, "BACKGROUND")
    contentBg:SetAllPoints()
    contentBg:SetColorTexture(0.04, 0.06, 0.08, 0.35)

    if not EnsureProfileDefaults() then
        local unavailable = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        unavailable:SetPoint("TOPLEFT", 0, -12)
        unavailable:SetText("|cffff6666Database not ready. Reopen this tab in a moment.|r")
        content:SetHeight(60)
        return
    end

    local profile = BLU.db

    -- Left column: Core on top, Behavior below
    local coreSection = BLU.Modules.design:CreateSection(content, "Core", "Interface\\Icons\\Achievement_General")
    coreSection:SetPoint("TOPLEFT", content, "TOPLEFT", 2, -2)
    coreSection:SetPoint("TOPRIGHT", content, "TOP", -4, -2)
    coreSection:SetHeight(104)

    CreateCheckbox(coreSection.content, "Enable BLU", 4, -6, profile.enabled ~= false, function(self)
        profile.enabled = self:GetChecked()
        BLU:PrintDebug("[Options/General] Enable BLU set to " .. tostring(profile.enabled))
        if profile.enabled then
            if BLU.Enable then BLU:Enable() end
            if BLU.ReloadModules then BLU:ReloadModules() end
        else
            if BLU.Disable then BLU:Disable() end
        end
    end, "Turn the addon on or off without changing your saved sound selections.")

    CreateCheckbox(coreSection.content, "Show welcome message", 4, -32, profile.showWelcomeMessage ~= false, function(self)
        profile.showWelcomeMessage = self:GetChecked()
    end, "Shows BLU's startup message after login or reload.")

    local behaviorSection = BLU.Modules.design:CreateSection(content, "Behavior", "Interface\\Icons\\INV_Misc_GroupLooking")
    behaviorSection:SetPoint("TOPLEFT", coreSection, "BOTTOMLEFT", 0, -12)
    behaviorSection:SetPoint("TOPRIGHT", content, "TOP", -4, -12)
    behaviorSection:SetHeight(104)

    CreateCheckbox(behaviorSection.content, "Mute in instances", 4, -6, profile.muteInInstances == true, function(self)
        profile.muteInInstances = self:GetChecked()
    end, "Suppresses BLU playback while you are inside instanced content.")

    CreateCheckbox(behaviorSection.content, "Mute in combat", 4, -34, profile.muteInCombat == true, function(self)
        profile.muteInCombat = self:GetChecked()
    end, "Suppresses BLU playback while your character is in combat.")

    -- Right column: Sound Output, anchored to top-right, same top as Core
    local soundSection = BLU.Modules.design:CreateSection(content, "Sound Output", "Interface\\Icons\\INV_Misc_Bell_01")
    soundSection:SetPoint("TOPLEFT", content, "TOP", 4, -2)
    soundSection:SetPoint("TOPRIGHT", content, "TOPRIGHT", -2, -2)
    soundSection:SetHeight(220)

    local soundDesc = soundSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    soundDesc:SetPoint("TOPLEFT", 8, -8)
    soundDesc:SetPoint("RIGHT", soundSection.content, "RIGHT", -8, 0)
    soundDesc:SetJustifyH("LEFT")
    soundDesc:SetWordWrap(true)
    soundDesc:SetTextColor(0.72, 0.78, 0.86)
    soundDesc:SetText("All BLU sounds play through the selected channel. Adjusting the volume here changes your in-game channel level.")

    local soundChannelLabel = soundSection.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    soundChannelLabel:SetPoint("TOPLEFT", 8, -52)
    soundChannelLabel:SetText("Sound Channel")

    local soundChannelDropdown = CreateFrame("Frame", nil, soundSection.content, "UIDropDownMenuTemplate")
    soundChannelDropdown:SetPoint("TOPLEFT", soundChannelLabel, "BOTTOMLEFT", -16, -2)
    UIDropDownMenu_SetWidth(soundChannelDropdown, 160)
    soundChannelDropdown:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Sound Channel", 1, 1, 1)
        GameTooltip:AddLine("Pick which WoW audio channel BLU uses for playback. The volume slider below controls that same channel.", 0.82, 0.82, 0.82, true)
        GameTooltip:Show()
    end)
    soundChannelDropdown:SetScript("OnLeave", GameTooltip_Hide)

    local volumeLabel = soundSection.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    volumeLabel:SetPoint("TOPLEFT", 8, -120)
    volumeLabel:SetText("Channel Volume")

    local volumeValueText = soundSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    volumeValueText:SetPoint("LEFT", volumeLabel, "RIGHT", 8, 0)
    volumeValueText:SetTextColor(0.72, 0.78, 0.86)

    local volumeSlider = BLU.Modules.widgets:CreateSlider(soundSection.content, "", 0, 100, 1, "Adjusts the selected WoW sound channel volume. This affects BLU because BLU plays through that channel.")
    volumeSlider:SetPoint("TOPLEFT", volumeLabel, "BOTTOMLEFT", 0, -10)
    volumeSlider:SetPoint("RIGHT", soundSection.content, "RIGHT", -12, 0)
    volumeSlider.Low:SetText("")
    volumeSlider.High:SetText("")
    volumeSlider.value:SetPoint("TOP", volumeSlider, "BOTTOM", 0, -200)

    local function RefreshVolumeSlider()
        local vol = GetChannelVolume(profile)
        volumeSlider:SetValue(vol)
        volumeValueText:SetText(vol .. "%")
    end

    volumeSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        SetChannelVolume(profile, value)
        volumeValueText:SetText(value .. "%")
    end)

    local function SetSelectedChannel(channel)
        profile.soundChannel = channel or "Master"
        UIDropDownMenu_SetSelectedValue(soundChannelDropdown, profile.soundChannel)
        UIDropDownMenu_SetText(soundChannelDropdown, profile.soundChannel)
        RefreshVolumeSlider()
    end

    UIDropDownMenu_Initialize(soundChannelDropdown, function(_, level)
        level = level or 1
        local dd = BLU.Modules and BLU.Modules.dropdown
        if dd and dd.ResetLevel then
            dd:ResetLevel(level)
        end

        for _, channel in ipairs(SOUND_CHANNELS) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = channel
            info.value = channel
            info.checked = (profile.soundChannel == channel)
            info.func = function() SetSelectedChannel(channel) end
            UIDropDownMenu_AddButton(info)
            if dd and dd.StyleLastAddedButton then
                dd:StyleLastAddedButton(level, {minWidth = 140})
            end
        end
    end)

    SetSelectedChannel(profile.soundChannel or "Master")

    StaticPopupDialogs["BLU_ADD_CUSTOM_SOUND"] = {
        text = "Add a custom sound file for BLU.",
        subText = "Enter a short file name like myfile or myfile.ogg. You can also paste a full path like Interface\\AddOns\\myfile.ogg. BLU will try common AddOns folders automatically.",
        button1 = ADD,
        button2 = CANCEL,
        hasEditBox = true,
        maxLetters = 255,
        editBoxWidth = 320,
        OnShow = function(self)
            if self.editBox then
                self._bluCustomSoundText = ""
                self.editBox:SetText("")
                self.editBox:SetAutoFocus(false)
                self.editBox:SetFocus()
            end
        end,
        OnHide = function(self)
            self._bluCustomSoundText = nil
        end,
        EditBoxOnTextChanged = function(self)
            local parent = self:GetParent()
            if parent then
                parent._bluCustomSoundText = self:GetText() or ""
            end
        end,
        EditBoxOnEnterPressed = function(self)
            local parent = self:GetParent()
            if parent and parent.button1 then
                parent._bluCustomSoundText = self:GetText() or ""
                parent.button1:Click()
            end
        end,
        OnAccept = function(self)
            local soundInput = self._bluCustomSoundText or (self.editBox and self.editBox:GetText()) or ""
            soundInput = soundInput:gsub("^%s+", ""):gsub("%s+$", "")
            BLU:PrintDebug("[Options/General] Add Custom Sound popup accepted with input '" .. tostring(soundInput) .. "'")

            if soundInput == "" then
                BLU:Print("|cff00ccffBLU:|r Enter a file name like myfile or myfile.ogg.")
                return
            end

            if BLU.Modules and BLU.Modules["usersounds"] and BLU.Modules["usersounds"].AddCustomSound then
                local ok, result, resolvedPath = BLU.Modules["usersounds"]:AddCustomSound(soundInput)
                if ok then
                    if resolvedPath and soundInput:find("[/\\]") then
                        BLU:Print("|cff00ccffBLU:|r Added custom sound: " .. tostring(result) .. " (" .. tostring(resolvedPath) .. ")")
                    else
                        BLU:Print("|cff00ccffBLU:|r Added custom sound: " .. tostring(result))
                    end
                else
                    BLU:Print("|cff00ccffBLU:|r Failed to add custom sound: " .. tostring(result))
                end
            else
                BLU:Print("|cff00ccffBLU:|r User custom sounds are not available yet.")
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    content:SetHeight(480)
end
