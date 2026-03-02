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

    local hero = CreateFrame("Frame", nil, content, "BackdropTemplate")
    hero:SetPoint("TOPLEFT", 0, 0)
    hero:SetPoint("RIGHT", 0, 0)
    hero:SetHeight(74)
    hero:SetBackdrop(BLU.Modules.design.Backdrops.Solid)
    hero:SetBackdropColor(0.06, 0.11, 0.16, 0.95)
    hero:SetBackdropBorderColor(0.10, 0.22, 0.30, 1)

    local heroIcon = hero:CreateTexture(nil, "ARTWORK")
    heroIcon:SetSize(32, 32)
    heroIcon:SetPoint("LEFT", 12, 0)
    heroIcon:SetTexture("Interface\\AddOns\\BLU\\media\\Textures\\icon.tga")

    local heroTitle = hero:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heroTitle:SetPoint("TOPLEFT", heroIcon, "TOPRIGHT", 12, 2)
    heroTitle:SetText("|cff05dffaBLU General Settings|r")

    local heroSubtitle = hero:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    heroSubtitle:SetPoint("TOPLEFT", heroTitle, "BOTTOMLEFT", 0, -4)
    heroSubtitle:SetText("Core behavior and addon controls")
    heroSubtitle:SetTextColor(0.74, 0.82, 0.90)

    if not EnsureProfileDefaults() then
        local unavailable = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        unavailable:SetPoint("TOPLEFT", hero, "BOTTOMLEFT", 0, -12)
        unavailable:SetText("|cffff6666Database not ready. Reopen this tab in a moment.|r")
        content:SetHeight(140)
        return
    end

    local profile = BLU.db.profile

    local coreSection = BLU.Modules.design:CreateSection(content, "Core", "Interface\\Icons\\Achievement_General")
    coreSection:SetPoint("TOPLEFT", hero, "BOTTOMLEFT", 0, -12)
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

    local testBtn = BLU.Modules.design:CreateButton(actionsSection.content, "Test Level Up", 120, 24)
    testBtn:SetPoint("TOPLEFT", 4, -8)
    testBtn:SetScript("OnClick", function()
        BLU:PlayCategorySound("levelup")
    end)

    local rebuildBtn = BLU.Modules.design:CreateButton(actionsSection.content, "Reload Modules", 120, 24)
    rebuildBtn:SetPoint("LEFT", testBtn, "RIGHT", 10, 0)
    rebuildBtn:SetScript("OnClick", function()
        if BLU.ReloadModules then
            BLU:ReloadModules()
        end
    end)

    local reloadUiBtn = BLU.Modules.design:CreateButton(actionsSection.content, "Reload UI", 90, 24)
    reloadUiBtn:SetPoint("LEFT", rebuildBtn, "RIGHT", 10, 0)
    reloadUiBtn:SetScript("OnClick", function()
        ReloadUI()
    end)

    local resetBtn = BLU.Modules.design:CreateButton(actionsSection.content, "Reset Profile", 110, 24)
    resetBtn:SetPoint("LEFT", reloadUiBtn, "RIGHT", 10, 0)
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

    content:SetHeight(470)
end
