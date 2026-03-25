--=====================================================================================
-- BLU - interface/options/general.lua
-- General options panel
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

local function IsProfileReady()
    return BLU and BLU.db and BLU.db.profile
end

local function EnsureProfileDefaults()
    if not IsProfileReady() then
        return false
    end

    local profile = BLU.db.profile
    profile.soundVolume = tonumber(profile.soundVolume) or 100
    profile.soundChannel = profile.soundChannel or "Master"
    profile.maxQueueSize = tonumber(profile.maxQueueSize) or 3
    profile.queueSounds = profile.queueSounds ~= false
    profile.muteInInstances = profile.muteInInstances == true
    profile.muteInCombat = profile.muteInCombat == true
    profile.modules = profile.modules or {}
    return true
end

local function CreateCheckbox(parent, text, x, y, checked, onClick)
    local checkbox = BLU.Modules.design:CreateCheckbox(parent, text)
    checkbox:SetPoint("TOPLEFT", x, y)
    checkbox.check:SetChecked(checked)
    checkbox.check:SetScript("OnClick", onClick)
    return checkbox
end

function BLU.CreateGeneralPanel(panel)
    local content = CreateFrame("Frame", nil, panel)
    content:SetPoint("TOPLEFT", 8, -8)
    content:SetPoint("BOTTOMRIGHT", -8, 8)

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

    local profile = BLU.db.profile

    local coreSection = BLU.Modules.design:CreateSection(content, "Core", "Interface\\Icons\\Achievement_General")
    coreSection:SetPoint("TOPLEFT", 0, 0)
    coreSection:SetPoint("RIGHT", 0, 0)
    coreSection:SetHeight(146)

    CreateCheckbox(coreSection.content, "Enable BLU", 4, -6, profile.enabled ~= false, function(self)
        profile.enabled = self:GetChecked()
        if profile.enabled then
            if BLU.Enable then
                BLU:Enable()
            end
            if BLU.ReloadModules then
                BLU:ReloadModules()
            end
        else
            if BLU.Disable then
                BLU:Disable()
            end
        end
    end)

    CreateCheckbox(coreSection.content, "Show welcome message", 4, -36, profile.showWelcomeMessage ~= false, function(self)
        profile.showWelcomeMessage = self:GetChecked()
    end)

    CreateCheckbox(coreSection.content, "Debug mode", 4, -66, profile.debugMode == true, function(self)
        profile.debugMode = self:GetChecked()
        BLU.debugMode = profile.debugMode
    end)

    local behaviorSection = BLU.Modules.design:CreateSection(content, "Behavior", "Interface\\Icons\\INV_Misc_GroupLooking")
    behaviorSection:SetPoint("TOPLEFT", coreSection, "BOTTOMLEFT", 0, -10)
    behaviorSection:SetPoint("RIGHT", 0, 0)
    behaviorSection:SetHeight(112)

    CreateCheckbox(behaviorSection.content, "Mute in instances", 4, -8, profile.muteInInstances == true, function(self)
        profile.muteInInstances = self:GetChecked()
    end)

    CreateCheckbox(behaviorSection.content, "Mute in combat", 4, -38, profile.muteInCombat == true, function(self)
        profile.muteInCombat = self:GetChecked()
    end)

    local actionsSection = BLU.Modules.design:CreateSection(content, "Actions", "Interface\\Icons\\INV_Misc_Gear_08")
    actionsSection:SetPoint("TOPLEFT", behaviorSection, "BOTTOMLEFT", 0, -10)
    actionsSection:SetPoint("RIGHT", 0, 0)
    actionsSection:SetHeight(84)

    local resetBtn = BLU.Modules.design:CreateButton(actionsSection.content, "Reset Profile", 110, 24)
    resetBtn:SetPoint("TOPLEFT", 4, -8)
    resetBtn:SetScript("OnClick", function()
        StaticPopup_Show("BLU_CONFIRM_RESET_PROFILE")
    end)

    StaticPopupDialogs["BLU_CONFIRM_RESET_PROFILE"] = {
        text = "Reset BLU profile settings to defaults and reload UI?",
        button1 = YES,
        button2 = NO,
        OnAccept = function()
            if IsProfileReady() then
                wipe(BLU.db.profile)
                if BLU.Modules and BLU.Modules.database and BLU.Modules.database.ApplyDefaults then
                    BLU.Modules.database:ApplyDefaults()
                end
            end
            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    content:SetHeight(384)
end
