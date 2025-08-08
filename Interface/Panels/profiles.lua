--=====================================================================================
-- BLU | Profiles Panel - Save/Load/Import/Export Configuration
-- Author: donniedice
-- Description: Complete profile management system with presets
--=====================================================================================

local addonName, BLU = ...

-- Predefined profile presets
local profilePresets = {
    {
        name = "Classic Gamer",
        desc = "Retro 8-bit and 16-bit sounds",
        settings = {
            events = {
                levelup = {sound = "final_fantasy.ogg", volume = 100},
                achievement = {sound = "zelda_chest.ogg", volume = 90},
                quest = {sound = "mario_coin.ogg", volume = 85},
                reputation = {sound = "sonic_ring.ogg", volume = 80}
            },
            volume = 100,
            channel = "Master"
        }
    },
    {
        name = "Modern RPG",
        desc = "Contemporary RPG sounds",
        settings = {
            events = {
                levelup = {sound = "skyrim.ogg", volume = 100},
                achievement = {sound = "witcher_3-1.ogg", volume = 95},
                quest = {sound = "elden_ring-1.ogg", volume = 90},
                reputation = {sound = "skyrim.ogg", volume = 85}
            },
            volume = 90,
            channel = "SFX"
        }
    },
    {
        name = "Warcraft Nostalgia",
        desc = "Classic Warcraft sounds",
        settings = {
            events = {
                levelup = {sound = "warcraft_3.ogg", volume = 100},
                achievement = {sound = "warcraft_3-2.ogg", volume = 100},
                quest = {sound = "warcraft_3-3.ogg", volume = 100},
                reputation = {sound = "warcraft_3.ogg", volume = 100}
            },
            volume = 85,
            channel = "Master"
        }
    },
    {
        name = "Minimal",
        desc = "Subtle notification sounds",
        settings = {
            events = {
                levelup = {sound = "minecraft.ogg", volume = 60},
                achievement = {sound = "minecraft.ogg", volume = 50},
                quest = {sound = "minecraft.ogg", volume = 40},
                reputation = {sound = "minecraft.ogg", volume = 30}
            },
            volume = 70,
            channel = "SFX"
        }
    }
}

function BLU.CreateProfilesPanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()
    panel:Hide()
    
    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Profile Management")
    
    local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    subtitle:SetPoint("TOPLEFT", 16, -35)
    subtitle:SetText("Save and manage your sound configurations")
    subtitle:SetTextColor(0.7, 0.7, 0.7)
    
    local yOffset = -60
    
    -- Current Profile Section
    local currentSection = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    currentSection:SetPoint("TOPLEFT", 16, yOffset)
    currentSection:SetText("Current Profile")
    currentSection:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    -- Profile dropdown
    local profileDropdown = CreateFrame("Frame", "BLUProfileDropdown", panel, "UIDropDownMenuTemplate")
    profileDropdown:SetPoint("TOPLEFT", 30, yOffset)
    UIDropDownMenu_SetWidth(profileDropdown, 200)
    
    -- Initialize profiles list
    BLU.db.profiles = BLU.db.profiles or {
        ["Default"] = {
            name = "Default",
            settings = {}
        }
    }
    BLU.db.currentProfile = BLU.db.currentProfile or "Default"
    UIDropDownMenu_SetText(profileDropdown, BLU.db.currentProfile)
    
    UIDropDownMenu_Initialize(profileDropdown, function(self, level)
        for name, profile in pairs(BLU.db.profiles) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = name
            info.value = name
            info.func = function()
                BLU.db.currentProfile = name
                UIDropDownMenu_SetText(profileDropdown, name)
                BLU:LoadProfile(name)
                print("|cff00ccffBLU:|r Loaded profile: " .. name)
            end
            info.checked = (BLU.db.currentProfile == name)
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    -- Profile action buttons
    local saveBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    saveBtn:SetSize(80, 22)
    saveBtn:SetPoint("LEFT", profileDropdown, "RIGHT", 10, 2)
    saveBtn:SetText("Save")
    saveBtn:SetScript("OnClick", function()
        local profileName = BLU.db.currentProfile
        BLU:SaveProfile(profileName)
        print("|cff00ccffBLU:|r Profile saved: " .. profileName)
    end)
    
    local newBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    newBtn:SetSize(80, 22)
    newBtn:SetPoint("LEFT", saveBtn, "RIGHT", 5, 0)
    newBtn:SetText("New")
    newBtn:SetScript("OnClick", function()
        StaticPopup_Show("BLU_NEW_PROFILE")
    end)
    
    local deleteBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    deleteBtn:SetSize(80, 22)
    deleteBtn:SetPoint("LEFT", newBtn, "RIGHT", 5, 0)
    deleteBtn:SetText("Delete")
    deleteBtn:SetScript("OnClick", function()
        if BLU.db.currentProfile == "Default" then
            print("|cff00ccffBLU:|r Cannot delete Default profile")
            return
        end
        StaticPopup_Show("BLU_DELETE_PROFILE", BLU.db.currentProfile)
    end)
    
    local renameBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    renameBtn:SetSize(80, 22)
    renameBtn:SetPoint("LEFT", deleteBtn, "RIGHT", 5, 0)
    renameBtn:SetText("Rename")
    renameBtn:SetScript("OnClick", function()
        if BLU.db.currentProfile == "Default" then
            print("|cff00ccffBLU:|r Cannot rename Default profile")
            return
        end
        StaticPopup_Show("BLU_RENAME_PROFILE", BLU.db.currentProfile)
    end)
    
    yOffset = yOffset - 50
    
    -- Profile Presets Section
    local presetsSection = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    presetsSection:SetPoint("TOPLEFT", 16, yOffset)
    presetsSection:SetText("Profile Presets")
    presetsSection:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    local presetsDesc = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    presetsDesc:SetPoint("TOPLEFT", 30, yOffset)
    presetsDesc:SetText("Load a preset configuration:")
    presetsDesc:SetTextColor(0.7, 0.7, 0.7)
    
    yOffset = yOffset - 25
    
    -- Create preset buttons
    for i, preset in ipairs(profilePresets) do
        local presetFrame = CreateFrame("Frame", nil, panel)
        presetFrame:SetSize(600, 40)
        presetFrame:SetPoint("TOPLEFT", 30, yOffset)
        
        -- Background
        local bg = presetFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
        if i % 2 == 0 then
            bg:SetColorTexture(0.15, 0.15, 0.15, 0.3)
        end
        
        -- Preset name
        local nameText = presetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameText:SetPoint("LEFT", 10, 5)
        nameText:SetText(preset.name)
        
        -- Preset description
        local descText = presetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        descText:SetPoint("LEFT", 10, -8)
        descText:SetText(preset.desc)
        descText:SetTextColor(0.7, 0.7, 0.7)
        
        -- Load button
        local loadBtn = CreateFrame("Button", nil, presetFrame, "UIPanelButtonTemplate")
        loadBtn:SetSize(80, 24)
        loadBtn:SetPoint("RIGHT", -10, 0)
        loadBtn:SetText("Load Preset")
        loadBtn:SetScript("OnClick", function()
            -- Apply preset settings
            for key, value in pairs(preset.settings) do
                BLU.db[key] = value
            end
            print("|cff00ccffBLU:|r Loaded preset: " .. preset.name)
            -- Refresh UI
            if BLU.RefreshOptions then
                BLU:RefreshOptions()
            end
        end)
        
        yOffset = yOffset - 45
    end
    
    yOffset = yOffset - 30
    
    -- Import/Export Section
    local importExportSection = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    importExportSection:SetPoint("TOPLEFT", 16, yOffset)
    importExportSection:SetText("Import / Export")
    importExportSection:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    -- Export button
    local exportBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    exportBtn:SetSize(120, 24)
    exportBtn:SetPoint("TOPLEFT", 30, yOffset)
    exportBtn:SetText("Export Profile")
    exportBtn:SetScript("OnClick", function()
        local profileData = BLU:SerializeProfile(BLU.db.currentProfile)
        BLU:ShowExportDialog(profileData)
    end)
    
    -- Import button
    local importBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    importBtn:SetSize(120, 24)
    importBtn:SetPoint("LEFT", exportBtn, "RIGHT", 10, 0)
    importBtn:SetText("Import Profile")
    importBtn:SetScript("OnClick", function()
        BLU:ShowImportDialog()
    end)
    
    -- Copy from character button
    local copyCharBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    copyCharBtn:SetSize(140, 24)
    copyCharBtn:SetPoint("LEFT", importBtn, "RIGHT", 10, 0)
    copyCharBtn:SetText("Copy from Character")
    copyCharBtn:SetScript("OnClick", function()
        BLU:ShowCharacterCopyDialog()
    end)
    
    yOffset = yOffset - 40
    
    -- Profile comparison
    local compareCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    compareCheck:SetPoint("TOPLEFT", 30, yOffset)
    compareCheck.text = compareCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    compareCheck.text:SetPoint("LEFT", compareCheck, "RIGHT", 5, 0)
    compareCheck.text:SetText("Show profile differences when switching")
    compareCheck:SetChecked(BLU.db.showProfileDiff)
    compareCheck:SetScript("OnClick", function(self)
        BLU.db.showProfileDiff = self:GetChecked()
    end)
    
    yOffset = yOffset - 30
    
    -- Auto-save option
    local autoSaveCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    autoSaveCheck:SetPoint("TOPLEFT", 30, yOffset)
    autoSaveCheck.text = autoSaveCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    autoSaveCheck.text:SetPoint("LEFT", autoSaveCheck, "RIGHT", 5, 0)
    autoSaveCheck.text:SetText("Auto-save profile changes")
    autoSaveCheck:SetChecked(BLU.db.autoSaveProfile)
    autoSaveCheck:SetScript("OnClick", function(self)
        BLU.db.autoSaveProfile = self:GetChecked()
    end)
    
    -- Info text
    local infoText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    infoText:SetPoint("BOTTOMLEFT", 20, 40)
    infoText:SetPoint("BOTTOMRIGHT", -20, 40)
    infoText:SetJustifyH("LEFT")
    infoText:SetText("Profiles allow you to save and switch between different sound configurations. Each profile stores all your sound selections, volume settings, and enabled modules.")
    infoText:SetTextColor(0.7, 0.7, 0.7)
    
    -- Profile stats
    local statsText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statsText:SetPoint("BOTTOMLEFT", 20, 20)
    local profileCount = 0
    for _ in pairs(BLU.db.profiles or {}) do
        profileCount = profileCount + 1
    end
    statsText:SetText(string.format("Total Profiles: %d | Current: %s", profileCount, BLU.db.currentProfile or "Default"))
    statsText:SetTextColor(0.7, 0.7, 0.7)
    panel.statsText = statsText
    
    -- Update stats function
    function panel:UpdateStats()
        local count = 0
        for _ in pairs(BLU.db.profiles or {}) do
            count = count + 1
        end
        self.statsText:SetText(string.format("Total Profiles: %d | Current: %s", count, BLU.db.currentProfile or "Default"))
    end
    
    return panel
end

-- Static popup dialogs
StaticPopupDialogs["BLU_NEW_PROFILE"] = {
    text = "Enter name for new profile:",
    button1 = "Create",
    button2 = "Cancel",
    hasEditBox = true,
    editBoxWidth = 200,
    OnAccept = function(self)
        local name = self.editBox:GetText()
        if name and name ~= "" then
            BLU:CreateProfile(name)
            UIDropDownMenu_SetText(BLUProfileDropdown, name)
            print("|cff00ccffBLU:|r Created new profile: " .. name)
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true
}

StaticPopupDialogs["BLU_DELETE_PROFILE"] = {
    text = "Delete profile '%s'?",
    button1 = "Delete",
    button2 = "Cancel",
    OnAccept = function(self, profileName)
        BLU:DeleteProfile(profileName)
        print("|cff00ccffBLU:|r Deleted profile: " .. profileName)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true
}

StaticPopupDialogs["BLU_RENAME_PROFILE"] = {
    text = "Enter new name for profile '%s':",
    button1 = "Rename",
    button2 = "Cancel",
    hasEditBox = true,
    editBoxWidth = 200,
    OnAccept = function(self, oldName)
        local newName = self.editBox:GetText()
        if newName and newName ~= "" then
            BLU:RenameProfile(oldName, newName)
            print("|cff00ccffBLU:|r Renamed profile: " .. oldName .. " to " .. newName)
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true
}