--=====================================================================================
-- BLU - interface/options/profiles.lua
-- Profile management options panel
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

local Profiles = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["profiles"] = Profiles

local function GetProfileUIState()
    BLU._profileUIState = BLU._profileUIState or {}
    return BLU._profileUIState
end

local function GetCharacterProfileName()
    local playerName = UnitName and UnitName("player") or "Player"
    local realmName = GetRealmName and GetRealmName() or "Realm"
    return tostring(playerName) .. "-" .. tostring(realmName)
end

local function GetActiveProfileName()
    if BLU and BLU.GetDB then
        return BLU.GetDB("currentProfile", nil)
    end

    if BLU and BLU.db then
        return BLU.db.currentProfile
    end

    return nil
end

local function RefreshProfileUI(selectedProfile)
    local uiState = GetProfileUIState()
    if selectedProfile and selectedProfile ~= "" then
        uiState.selectedProfile = selectedProfile
    end

    if uiState.panel and uiState.panel.Refresh then
        local ok = pcall(uiState.panel.Refresh, uiState.panel)
        if ok then
            return
        end
    end

    if BLU.RefreshProfilesUI then
        BLU:RefreshProfilesUI()
    end
end

local function RefreshProfileUIDeferred(selectedProfile)
    C_Timer.After(0.05, function()
        RefreshProfileUI(selectedProfile)
    end)
end

local function GetPopupEditBox(self)
    if not self then
        return nil
    end

    if self.editBox then
        return self.editBox
    end

    local namedEditBox = self.GetName and _G[self:GetName() .. "EditBox"]
    if namedEditBox then
        self.editBox = namedEditBox
        return namedEditBox
    end

    return nil
end

local function ConfigurePopupEditBox(self)
    local editBox = GetPopupEditBox(self)
    if not self or not editBox then
        return
    end

    editBox:SetAutoFocus(false)
    editBox:SetScript("OnEnterPressed", function(activeEditBox)
        local popup = activeEditBox:GetParent()
        if popup and popup.button1 and popup.button1:IsShown() and popup.button1:IsEnabled() then
            popup.button1:Click()
        end
    end)
end

local function PopupEditBoxAccept(self)
    if not self then
        return
    end

    local popup = self:GetParent()
    if popup and popup.button1 and popup.button1:IsShown() and popup.button1:IsEnabled() then
        popup.button1:Click()
    end
end

local function GetSuggestedProfileCopyName(profileName)
    local sourceName = tostring(profileName or GetActiveProfileName() or "Profile")
    local normalizedBase = sourceName:gsub("%s+Copy%s*%d*$", "")
    if normalizedBase == "" then
        normalizedBase = sourceName
    end

    local baseName = normalizedBase .. " Copy"
    local candidate = baseName
    local suffix = 2

    while BLUDB and BLUDB.profiles and BLUDB.profiles[candidate] do
        candidate = baseName .. " " .. tostring(suffix)
        suffix = suffix + 1
    end

    return candidate
end

local function DeepCopyTable(value)
    if BLU and BLU.Modules and BLU.Modules.utils and BLU.Modules.utils.DeepCopy then
        return BLU.Modules.utils:DeepCopy(value)
    end

    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, entry in pairs(value) do
        copy[key] = DeepCopyTable(entry)
    end
    return copy
end

local function ApplyTable(target, source)
    if type(target) ~= "table" or type(source) ~= "table" then
        return
    end

    for key, value in pairs(source) do
        if type(value) == "table" then
            target[key] = target[key] or {}
            ApplyTable(target[key], value)
        else
            target[key] = value
        end
    end
end

local function ApplyPresetToProfile(profileName, presetSettings)
    if type(profileName) ~= "string" or profileName == "" then
        return false, "Select a profile first."
    end

    if not BLUDB then
        return false, "Profile database is not ready yet."
    end

    BLUDB.profiles = BLUDB.profiles or {}
    BLUDB.profiles[profileName] = BLUDB.profiles[profileName] or {}

    local targetProfile = BLUDB.profiles[profileName]
    local defaults = BLU.Modules and BLU.Modules.config and BLU.Modules.config.defaults and BLU.Modules.config.defaults.profile

    wipe(targetProfile)
    if defaults then
        ApplyTable(targetProfile, DeepCopyTable(defaults))
    end
    ApplyTable(targetProfile, DeepCopyTable(presetSettings or {}))

    local activeProfileName = GetActiveProfileName() or "Default"
    if profileName == activeProfileName and BLU and BLU.db then
        BLU.db.profile = targetProfile
        BLU.db.currentProfile = profileName

        if BLU.Modules and BLU.Modules.config and BLU.Modules.config.ApplySettings then
            BLU.Modules.config:ApplySettings()
        end

        if BLU.RefreshOptions then
            BLU:RefreshOptions()
        end
    end

    return true
end

local PROFILE_PRESETS = {
    {
        name = "donniedice's Preset",
        description = "Chat-safe and less noisy during dungeons or combat.",
        settings = {
            debugMode = false,
            showWelcomeMessage = false,
            muteInInstances = true,
            muteInCombat = true,
            queueSounds = true,
            maxQueueSize = 2,
        },
    },
    {
        name = "Future Preset 1",
        description = "Placeholder for a future custom profile configuration.",
        settings = {},
    },
    {
        name = "Future Preset 2",
        description = "Placeholder for a future custom profile configuration.",
        settings = {},
    },
    {
        name = "Future Preset 3",
        description = "Placeholder for a future custom profile configuration.",
        settings = {},
    },
    {
        name = "Future Preset 4",
        description = "Placeholder for a future custom profile configuration.",
        settings = {},
    },
    {
        name = "Future Preset 5",
        description = "Placeholder for a future custom profile configuration.",
        settings = {},
    },
}

local function GetOrderedProfiles()
    local profiles = {}
    local source = BLUDB and BLUDB.profiles or {}

    for profileName in pairs(source) do
        profiles[#profiles + 1] = profileName
    end

    table.sort(profiles, function(a, b)
        local active = GetActiveProfileName()
        if a == active and b ~= active then
            return true
        end
        if b == active and a ~= active then
            return false
        end
        return tostring(a):lower() < tostring(b):lower()
    end)

    return profiles
end

local function EnsurePopupConfig(targetPanel)
    StaticPopupDialogs["BLU_PROFILE_CREATE"] = {
        text = "Create a new BLU profile",
        subText = "Enter a unique profile name.",
        button1 = "Create",
        button2 = "Cancel",
        enterClicksFirstButton = true,
        EditBoxOnEnterPressed = PopupEditBoxAccept,
        hasEditBox = true,
        maxLetters = 48,
        editBoxWidth = 260,
        OnShow = function(self)
            local editBox = GetPopupEditBox(self)
            if editBox then
                editBox:SetText("")
                ConfigurePopupEditBox(self)
                editBox:SetFocus()
            end
        end,
        OnAccept = function(self)
            local editBox = GetPopupEditBox(self)
            local profileName = (editBox and editBox:GetText() or ""):gsub("^%s+", ""):gsub("%s+$", "")
            if profileName == "" then
                BLU:Print("Enter a profile name first.")
                return
            end

            if BLUDB and BLUDB.profiles and BLUDB.profiles[profileName] then
                BLU:Print("Profile already exists: " .. tostring(profileName))
                return
            end

            if BLU.CreateProfile and BLU:CreateProfile(profileName) then
                BLU:PrintDebug("[Options/Profiles] Created profile: " .. tostring(profileName))
                RefreshProfileUIDeferred(profileName)
            else
                BLU:Print("Failed to create profile: " .. tostring(profileName))
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    StaticPopupDialogs["BLU_PROFILE_RENAME"] = {
        text = "Rename the selected BLU profile",
        subText = "Enter a new profile name.",
        button1 = "Rename",
        button2 = "Cancel",
        enterClicksFirstButton = true,
        EditBoxOnEnterPressed = PopupEditBoxAccept,
        hasEditBox = true,
        maxLetters = 48,
        editBoxWidth = 260,
        OnShow = function(self, data)
            local editBox = GetPopupEditBox(self)
            if editBox then
                editBox:SetText(data or "")
                ConfigurePopupEditBox(self)
                editBox:HighlightText()
                editBox:SetFocus()
            end
        end,
        OnAccept = function(self, data)
            local oldName = data
            local editBox = GetPopupEditBox(self)
            local newName = (editBox and editBox:GetText() or ""):gsub("^%s+", ""):gsub("%s+$", "")

            if not oldName or oldName == "" or newName == "" then
                BLU:Print("Select a profile and enter a new name.")
                return
            end

            if oldName == "Default" then
                BLU:Print("Default cannot be renamed.")
                return
            end

            if BLUDB and BLUDB.profiles and BLUDB.profiles[newName] then
                BLU:Print("Profile already exists: " .. tostring(newName))
                return
            end

            if BLU.RenameProfile and BLU:RenameProfile(oldName, newName) then
                BLU:PrintDebug("[Options/Profiles] Renamed profile: " .. tostring(oldName) .. " → " .. tostring(newName))
                RefreshProfileUIDeferred(newName)
            else
                BLU:Print("Failed to rename profile: " .. tostring(oldName))
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    StaticPopupDialogs["BLU_PROFILE_DELETE"] = {
        text = "Delete the selected BLU profile?",
        subText = "This removes the saved profile data.",
        button1 = "Delete",
        button2 = "Cancel",
        OnAccept = function(_, data)
            if not data or data == "" then
                BLU:Print("Select a profile first.")
                return
            end

            if data == "Default" then
                BLU:Print("Default cannot be deleted.")
                return
            end

            if BLU.DeleteProfile and BLU:DeleteProfile(data) then
                BLU:PrintDebug("[Options/Profiles] Deleted profile: " .. tostring(data))
                RefreshProfileUI(GetActiveProfileName() or "Default")
            else
                BLU:Print("Failed to delete profile: " .. tostring(data))
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    StaticPopupDialogs["BLU_PROFILE_RESET"] = {
        text = "Reset the active BLU profile?",
        subText = "This restores the current profile to defaults.",
        button1 = "Reset",
        button2 = "Cancel",
        OnAccept = function()
            local activeProfile = GetActiveProfileName() or "Default"
            ApplyPresetToProfile(activeProfile, {})
            BLU:PrintDebug("[Options/Profiles] Reset profile: " .. tostring(activeProfile))
            RefreshProfileUI(activeProfile)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
end

function BLU.CreateProfilesPanel(panel)
    BLU:PrintDebug("[Options/Profiles] Creating Profiles panel")

    for _, child in ipairs({panel:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end

    panel.profileState = GetProfileUIState()
    panel.profileState.panel = panel
    panel.profileState.selectedProfile = panel.profileState.selectedProfile or GetActiveProfileName() or "Default"

    EnsurePopupConfig(panel)

    local content = CreateFrame("Frame", nil, panel)
    content:SetPoint("TOPLEFT", 1, -8)
    content:SetPoint("BOTTOMRIGHT", -7, 8)

    -- Main profile section: saved profiles, current profile, and actions are combined
    local col1X = 16
    local col2X = 215
    local col3X = 492
    local colGap  = 8

    local mainSection = BLU.Modules.design:CreateSection(content, "Profiles", "Interface\\Icons\\Ability_Marksmanship")
    mainSection:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    mainSection:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
    mainSection:SetHeight(175)

    -- Highlight frame for Active Profile info
    local activeHighlight = CreateFrame("Frame", nil, mainSection.content, "BackdropTemplate")
    activeHighlight:SetPoint("TOPLEFT", 8, -8)
    activeHighlight:SetPoint("BOTTOMLEFT", 8, 8)
    activeHighlight:SetWidth(col2X - 24)
    activeHighlight:SetBackdrop(BLU.Modules.design.Backdrops.Dark)
    activeHighlight:SetBackdropColor(0.1, 0.12, 0.16, 0.6)
    activeHighlight:SetBackdropBorderColor(0.2, 0.3, 0.4, 0.5)

    local profileDropdownLabel = mainSection.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    profileDropdownLabel:SetPoint("TOPLEFT", col2X, -16)
    profileDropdownLabel:SetText("|cff05dffaProfile|r")

    local profileDropdown = CreateFrame("Frame", "BLUProfilesDropdown", mainSection.content, "UIDropDownMenuTemplate")
    profileDropdown:SetPoint("TOPLEFT", profileDropdownLabel, "BOTTOMLEFT", -15, -4)
    UIDropDownMenu_SetWidth(profileDropdown, 220)
    profileDropdown.xOffset = 18

    local profileCount = mainSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    profileCount:SetPoint("TOPLEFT", profileDropdown, "BOTTOMLEFT", 20, -4)
    profileCount:SetPoint("RIGHT", mainSection.content, "RIGHT", -10, 0)
    profileCount:SetJustifyH("LEFT")
    profileCount:SetTextColor(0.72, 0.72, 0.72)

    local currentProfileLabel = activeHighlight:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentProfileLabel:SetPoint("TOPLEFT", activeHighlight, "TOPLEFT", 12, -12)
    currentProfileLabel:SetText("Active")

    local currentProfileValue = activeHighlight:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    currentProfileValue:SetPoint("TOPLEFT", currentProfileLabel, "BOTTOMLEFT", 0, -2)
    currentProfileValue:SetPoint("RIGHT", activeHighlight, "RIGHT", -10, 0)
    currentProfileValue:SetJustifyH("LEFT")
    currentProfileValue:SetJustifyV("TOP")
    currentProfileValue:SetWordWrap(true)

    local characterProfileLabel = activeHighlight:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    characterProfileLabel:SetPoint("TOPLEFT", currentProfileValue, "BOTTOMLEFT", 0, -10)
    characterProfileLabel:SetPoint("RIGHT", activeHighlight, "RIGHT", -10, 0)
    characterProfileLabel:SetTextColor(0.76, 0.76, 0.76)
    characterProfileLabel:SetJustifyH("LEFT")

    local actionButtonWidth = 84
    local createButton = BLU.Modules.design:CreateButton(mainSection.content, "Create", actionButtonWidth, 22)
    createButton:SetPoint("TOPLEFT", mainSection.content, "TOPLEFT", col3X, -8)
    createButton:SetScript("OnClick", function()
        StaticPopup_Show("BLU_PROFILE_CREATE")
    end)

    local renameButton = BLU.Modules.design:CreateButton(mainSection.content, "Rename", actionButtonWidth, 22)
    renameButton:SetPoint("TOPLEFT", createButton, "BOTTOMLEFT", 0, -6)
    renameButton:SetScript("OnClick", function()
        local selected = panel.profileState.selectedProfile
        if not selected or selected == "" then return end
        StaticPopup_Show("BLU_PROFILE_RENAME", nil, nil, selected)
    end)

    local resetButton = BLU.Modules.design:CreateButton(mainSection.content, "Reset", actionButtonWidth, 22)
    resetButton:SetPoint("TOPLEFT", renameButton, "BOTTOMLEFT", 0, -6)
    resetButton:SetScript("OnClick", function()
        StaticPopup_Show("BLU_PROFILE_RESET")
    end)
    resetButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Reset Profile", 1, 1, 1)
        GameTooltip:AddLine("Restores the current profile to default settings.", 0.82, 0.82, 0.82, true)
        GameTooltip:Show()
    end)
    resetButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local copyActiveButton = BLU.Modules.design:CreateButton(mainSection.content, "Copy", actionButtonWidth, 22)
    copyActiveButton:SetPoint("TOPLEFT", resetButton, "BOTTOMLEFT", 0, -6)
    copyActiveButton:SetScript("OnClick", function()
        local sourceProfileName = GetActiveProfileName() or "Default"
        local newProfileName = GetSuggestedProfileCopyName()

        if BLU.LoadProfile then
            BLU:LoadProfile(sourceProfileName)
        end

        if BLU.CreateProfile and BLU:CreateProfile(newProfileName) then
            BLU:PrintDebug("[Options/Profiles] Copied profile: " .. tostring(sourceProfileName) .. " -> " .. tostring(newProfileName))
            RefreshProfileUI(newProfileName)
        else
            BLU:Print("Failed to copy profile: " .. tostring(sourceProfileName))
        end
    end)
    copyActiveButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Duplicate Active Profile", 1, 1, 1)
        GameTooltip:AddLine("Creates `Copy`, then `Copy 2`, `Copy 3`, and so on as needed.", 0.82, 0.82, 0.82, true)
        GameTooltip:Show()
    end)
    copyActiveButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- ── Presets section: full width bottom section ───────────────────────────
    local presetsSection = BLU.Modules.design:CreateSection(content, "Presets", "Interface\\Icons\\INV_Inscription_Scroll")
    presetsSection:SetPoint("TOPLEFT", mainSection, "BOTTOMLEFT", 0, -4)
    presetsSection:SetPoint("TOPRIGHT", mainSection, "BOTTOMRIGHT", 0, -4)
    presetsSection:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 0, 4)
    presetsSection:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 4)

    local presetColWidth = 180
    for presetIndex, preset in ipairs(PROFILE_PRESETS) do
        local col = (presetIndex - 1) % 3
        local row = math.floor((presetIndex - 1) / 3)
        local presetButton = BLU.Modules.design:CreateButton(presetsSection.content, preset.name, presetColWidth, 22)
        presetButton:SetPoint("TOPLEFT", 12 + (col * (presetColWidth + 12)), -12 - (row * 30))
        presetButton:SetScript("OnClick", function()
            local selectedProfileName = panel.profileState and panel.profileState.selectedProfile or GetActiveProfileName() or "Default"
            local ok, err = ApplyPresetToProfile(selectedProfileName, preset.settings)
            if not ok then
                BLU:PrintDebug("[Options/Profiles] Preset apply failed: " .. tostring(err))
                return
            end
            BLU:PrintDebug("[Options/Profiles] Applied preset '" .. tostring(preset.name) .. "' to: " .. tostring(selectedProfileName))
            if panel.Refresh then panel:Refresh() end
        end)
        presetButton:SetScript("OnEnter", function(button)
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:SetText(preset.name)
            GameTooltip:AddLine(preset.description, 0.82, 0.82, 0.82, true)
            GameTooltip:Show()
        end)
        presetButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    -- ── DROPDOWN INIT ────────────────────────────────────────────────────────
    local function profileDropdown_OnInitialize(self, level, menuList)
        local dd = BLU.Modules.dropdown
        local function getDropDownListFrame(levelToUse)
            return dd:GetListFrame(levelToUse)
        end

        local BASE_MIN_WIDTH = math.floor(profileDropdown:GetWidth() or 200)
        if BASE_MIN_WIDTH < 100 then BASE_MIN_WIDTH = 200 end

        local function getMinWidthForLevel(levelToUse)
            if (levelToUse or 1) <= 1 then
                return math.max(140, math.floor(BASE_MIN_WIDTH * 0.6))
            end

            return math.max(120, math.floor(BASE_MIN_WIDTH * 0.55))
        end

        local function getLeftInsetForLevel(levelToUse)
            if (levelToUse or 1) >= 1 then
                return 24
            end

            return 8
        end

        local function forceListFrameWidth(levelToUse)
            dd:ForceWidth(levelToUse, getMinWidthForLevel(levelToUse), getLeftInsetForLevel(levelToUse), {
                deleteKey = "bluDeleteButton",
                compactRightControl = false,
            })
        end

        level = level or 1
        local activeProfileName = GetActiveProfileName() or "Default"
        if level == 1 then
            -- Hide stale delete buttons from previous open before adding new buttons
            local listFrame = getDropDownListFrame(level)
            if listFrame then
                local maxButtons = UIDROPDOWNMENU_MAXBUTTONS or 32
                for i = 1, maxButtons do
                    local button = _G[listFrame:GetName() .. "Button" .. i]
                    if button and button.bluDeleteButton then
                        button.bluDeleteButton:Hide()
                    end
                end
            end

            for _, profileName in ipairs(GetOrderedProfiles()) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = (profileName == activeProfileName)
                    and ("|cff05dffa" .. profileName .. "|r")
                    or profileName
                info.value        = profileName
                info.notCheckable = true
                info.func = function()
                    panel.profileState.selectedProfile = profileName
                    if BLU.LoadProfile then BLU:LoadProfile(profileName) end
                    if panel.Refresh then panel:Refresh() end
                    CloseDropDownMenus()
                end
                UIDropDownMenu_AddButton(info, level)

                -- Attach inline delete button to non-Default profiles
                if profileName ~= "Default" then
                    local lf = getDropDownListFrame(level)
                    if lf and lf.numButtons then
                        local button = _G[lf:GetName() .. "Button" .. lf.numButtons]
                        if button then
                            local deleteButton = button.bluDeleteButton
                            if not deleteButton then
                                deleteButton = CreateFrame("Button", nil, button, "BackdropTemplate")
                                deleteButton:SetSize(18, 16)
                                deleteButton:SetBackdrop(BLU.Modules.design.Backdrops.Button)
                                deleteButton:SetBackdropColor(0.15, 0.05, 0.05, 0.95)
                                deleteButton:SetBackdropBorderColor(0.3, 0.1, 0.1, 1)
                                deleteButton:RegisterForClicks("LeftButtonUp")
                                deleteButton:SetScript("OnClick", function(btn)
                                    if btn.profileName then
                                        StaticPopup_Show("BLU_PROFILE_DELETE", btn.profileName, nil, btn.profileName)
                                        CloseDropDownMenus()
                                    end
                                end)
                                deleteButton:SetScript("OnEnter", function(btn)
                                    btn:SetBackdropColor(0.2, 0.07, 0.07, 1)
                                    GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
                                    GameTooltip:SetText("Delete Profile")
                                    GameTooltip:AddLine(btn.profileName or "", 0.82, 0.82, 0.82, true)
                                    GameTooltip:Show()
                                end)
                                deleteButton:SetScript("OnLeave", function(btn)
                                    btn:SetBackdropColor(0.15, 0.05, 0.05, 0.95)
                                    GameTooltip:Hide()
                                end)
                                local lbl = deleteButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                                lbl:SetPoint("CENTER", 0, 0)
                                lbl:SetText("x")
                                lbl:SetTextColor(1, 0.3, 0.3)
                                button.bluDeleteButton = deleteButton
                            end
                            deleteButton.profileName = profileName
                            deleteButton:Show()
                        end
                    end
                end
            end

            forceListFrameWidth(level)
        end
    end

    UIDropDownMenu_Initialize(profileDropdown, profileDropdown_OnInitialize)

    -- ── REFRESH ──────────────────────────────────────────────────────────────
    function panel:Refresh()
        local activeProfileName   = GetActiveProfileName() or "Default"
        local selectedProfile     = self.profileState.selectedProfile
        local profileNames        = GetOrderedProfiles()
        local characterProfileName = GetCharacterProfileName()

        if not selectedProfile or not (BLUDB and BLUDB.profiles and BLUDB.profiles[selectedProfile]) then
            selectedProfile = activeProfileName
        end
        self.profileState.selectedProfile = selectedProfile

        -- Re-initialize the dropdown to rebuild the list with updated names
        UIDropDownMenu_Initialize(profileDropdown, profileDropdown_OnInitialize)

        UIDropDownMenu_SetText(profileDropdown, tostring(selectedProfile))
        currentProfileValue:SetText("|cff05dffa" .. tostring(activeProfileName) .. "|r")
        characterProfileLabel:SetText("Character: |cff95a5a6" .. tostring(characterProfileName) .. "|r")
        profileCount:SetText("Saved: |cffffd700" .. tostring(#profileNames) .. "|r")
    end

    panel:SetScript("OnShow", function(self)
        if self.Refresh then
            self:Refresh()
        end
    end)

    panel:Refresh()
end

function BLU.RefreshProfilesUI()
    BLU:PrintDebug("[Options/Profiles] RefreshProfilesUI called")
    if not BLU.OptionsPanel or not BLU.OptionsPanel.contents then
        return false
    end

    local profilesContent = nil
    if type(BLU.OptionsTabs) == "table" then
        for index, tabInfo in ipairs(BLU.OptionsTabs) do
            if tabInfo and (tabInfo.text == "Profiles" or tabInfo.create == BLU.CreateProfilesPanel) then
                profilesContent = BLU.OptionsPanel.contents[index]
                break
            end
        end
    end

    if not profilesContent then
        BLU:PrintDebug("[Options/Profiles] RefreshProfilesUI could not resolve the Profiles tab content")
        return false
    end

    if not profilesContent:IsShown() then
        return false
    end

    local ok, err = pcall(BLU.CreateProfilesPanel, profilesContent)
    if not ok then
        BLU:PrintDebug("[Options/Profiles] Failed to rebuild Profiles tab: " .. tostring(err))
        return false
    end

    return true
end

function Profiles:Init()
    BLU:PrintDebug("[Profiles] Profiles panel module initialized")
end

if BLU.RegisterModule then
    BLU:RegisterModule(Profiles, "profiles", "Profiles Panel")
end
