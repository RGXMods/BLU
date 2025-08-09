--=====================================================================================
-- BLU | Profiles Panel
-- Author: donniedice
-- Description: Profile management - create, switch, delete, import/export
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateProfilesPanel()
    local panel = CreateFrame("Frame", nil, UIParent)
    panel:Hide()
    
    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Profile Management")
    
    local yOffset = -50
    
    -- Current Profile Section
    local currentTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    currentTitle:SetPoint("TOPLEFT", 16, yOffset)
    currentTitle:SetText("Current Profile")
    currentTitle:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    -- Current profile display
    local currentProfileFrame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    currentProfileFrame:SetPoint("TOPLEFT", 30, yOffset)
    currentProfileFrame:SetSize(300, 40)
    currentProfileFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    currentProfileFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    currentProfileFrame:SetBackdropBorderColor(0.02, 0.37, 1, 1)
    
    local currentProfileText = currentProfileFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    currentProfileText:SetPoint("CENTER")
    currentProfileText:SetText(BLU.db and BLU.db.currentProfile or "Default")
    panel.currentProfileText = currentProfileText
    
    yOffset = yOffset - 60
    
    -- Profile List Section
    local listTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    listTitle:SetPoint("TOPLEFT", 16, yOffset)
    listTitle:SetText("Available Profiles")
    listTitle:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    -- Profile list frame
    local listFrame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    listFrame:SetPoint("TOPLEFT", 30, yOffset)
    listFrame:SetSize(350, 150)
    listFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    listFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.5)
    
    -- Scroll frame for profile list
    local scrollFrame = CreateFrame("ScrollFrame", nil, listFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -25, 5)
    
    local listContent = CreateFrame("Frame", nil, scrollFrame)
    listContent:SetSize(320, 500)
    scrollFrame:SetScrollChild(listContent)
    
    panel.profileButtons = {}
    
    -- Function to refresh profile list
    function panel:RefreshProfileList()
        -- Hide all existing buttons
        for _, btn in ipairs(self.profileButtons) do
            btn:Hide()
        end
        
        -- Get profiles
        local profiles = BLU:GetProfiles()
        local buttonYOffset = -5
        local buttonIndex = 1
        
        for _, profileName in ipairs(profiles) do
            local btn = self.profileButtons[buttonIndex]
            if not btn then
                btn = CreateFrame("Button", nil, listContent)
                btn:SetSize(310, 25)
                
                local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
                highlight:SetAllPoints()
                highlight:SetColorTexture(0.3, 0.3, 0.3, 0.3)
                
                btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                btn.text:SetPoint("LEFT", 10, 0)
                
                self.profileButtons[buttonIndex] = btn
            end
            
            btn:SetPoint("TOPLEFT", 5, buttonYOffset)
            btn.text:SetText(profileName)
            
            -- Highlight current profile
            if profileName == (BLU.db and BLU.db.currentProfile or "Default") then
                btn.text:SetTextColor(0.02, 0.37, 1)
            else
                btn.text:SetTextColor(1, 1, 1)
            end
            
            btn:SetScript("OnClick", function()
                self:SwitchProfile(profileName)
            end)
            
            btn:Show()
            buttonIndex = buttonIndex + 1
            buttonYOffset = buttonYOffset - 30
        end
    end
    
    -- Profile Controls
    local controlsY = yOffset - 160
    
    -- New profile
    local newButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    newButton:SetSize(100, 25)
    newButton:SetPoint("TOPLEFT", 30, controlsY)
    newButton:SetText("New Profile")
    
    local newEditBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    newEditBox:SetSize(150, 25)
    newEditBox:SetPoint("LEFT", newButton, "RIGHT", 10, 0)
    newEditBox:SetAutoFocus(false)
    newEditBox:SetText("Enter name...")
    newEditBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == "Enter name..." then
            self:SetText("")
        end
    end)
    
    newButton:SetScript("OnClick", function()
        local name = newEditBox:GetText()
        if name and name ~= "" and name ~= "Enter name..." then
            if BLU:CreateProfile(name) then
                BLU:Print("|cff00ff00Profile created:|r " .. name)
                panel:RefreshProfileList()
                newEditBox:SetText("Enter name...")
            else
                BLU:Print("|cffff0000Profile already exists:|r " .. name)
            end
        end
    end)
    
    controlsY = controlsY - 35
    
    -- Copy profile
    local copyButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    copyButton:SetSize(100, 25)
    copyButton:SetPoint("TOPLEFT", 30, controlsY)
    copyButton:SetText("Copy Profile")
    
    local copyEditBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    copyEditBox:SetSize(150, 25)
    copyEditBox:SetPoint("LEFT", copyButton, "RIGHT", 10, 0)
    copyEditBox:SetAutoFocus(false)
    copyEditBox:SetText("New name...")
    copyEditBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == "New name..." then
            self:SetText("")
        end
    end)
    
    copyButton:SetScript("OnClick", function()
        local name = copyEditBox:GetText()
        if name and name ~= "" and name ~= "New name..." then
            if BLU:CopyProfile(BLU.db.currentProfile, name) then
                BLU:Print("|cff00ff00Profile copied:|r " .. name)
                panel:RefreshProfileList()
                copyEditBox:SetText("New name...")
            else
                BLU:Print("|cffff0000Failed to copy profile|r")
            end
        end
    end)
    
    controlsY = controlsY - 35
    
    -- Delete profile
    local deleteButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    deleteButton:SetSize(100, 25)
    deleteButton:SetPoint("TOPLEFT", 30, controlsY)
    deleteButton:SetText("Delete Profile")
    
    deleteButton:SetScript("OnClick", function()
        local current = BLU.db.currentProfile
        if current == "Default" then
            BLU:Print("|cffff0000Cannot delete Default profile|r")
            return
        end
        
        StaticPopupDialogs["BLU_DELETE_PROFILE"] = {
            text = "Delete profile: " .. current .. "?",
            button1 = "Delete",
            button2 = "Cancel",
            OnAccept = function()
                if BLU:DeleteProfile(current) then
                    BLU:Print("|cff00ff00Profile deleted:|r " .. current)
                    panel:RefreshProfileList()
                    panel.currentProfileText:SetText("Default")
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("BLU_DELETE_PROFILE")
    end)
    
    -- Reset profile
    local resetButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetButton:SetSize(100, 25)
    resetButton:SetPoint("LEFT", deleteButton, "RIGHT", 10, 0)
    resetButton:SetText("Reset Profile")
    
    resetButton:SetScript("OnClick", function()
        StaticPopupDialogs["BLU_RESET_PROFILE"] = {
            text = "Reset current profile to defaults?",
            button1 = "Reset",
            button2 = "Cancel",
            OnAccept = function()
                BLU:ResetProfile()
                BLU:Print("|cff00ff00Profile reset to defaults|r")
                panel:RefreshProfileList()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("BLU_RESET_PROFILE")
    end)
    
    controlsY = controlsY - 50
    
    -- Import/Export Section
    local importExportTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    importExportTitle:SetPoint("TOPLEFT", 16, controlsY)
    importExportTitle:SetText("Import / Export")
    importExportTitle:SetTextColor(0, 0.8, 1)
    
    controlsY = controlsY - 30
    
    -- Export button
    local exportButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    exportButton:SetSize(100, 25)
    exportButton:SetPoint("TOPLEFT", 30, controlsY)
    exportButton:SetText("Export Profile")
    
    -- Import button
    local importButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    importButton:SetSize(100, 25)
    importButton:SetPoint("LEFT", exportButton, "RIGHT", 10, 0)
    importButton:SetText("Import Profile")
    
    -- Export/Import text box
    local textBoxFrame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    textBoxFrame:SetPoint("TOPLEFT", 30, controlsY - 35)
    textBoxFrame:SetSize(400, 100)
    textBoxFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    textBoxFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.5)
    
    local textBox = CreateFrame("EditBox", nil, textBoxFrame)
    textBox:SetMultiLine(true)
    textBox:SetAutoFocus(false)
    textBox:SetFontObject(GameFontNormalSmall)
    textBox:SetPoint("TOPLEFT", 5, -5)
    textBox:SetPoint("BOTTOMRIGHT", -5, 5)
    textBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    
    exportButton:SetScript("OnClick", function()
        local exportString = BLU:ExportProfile()
        if exportString then
            textBox:SetText(exportString)
            textBox:HighlightText()
            textBox:SetFocus()
            BLU:Print("|cff00ff00Profile exported - Copy the text below|r")
        end
    end)
    
    importButton:SetScript("OnClick", function()
        local importString = textBox:GetText()
        if importString and importString ~= "" then
            if BLU:ImportProfile(importString) then
                BLU:Print("|cff00ff00Profile imported successfully|r")
                panel:RefreshProfileList()
                textBox:SetText("")
            else
                BLU:Print("|cffff0000Failed to import profile - Invalid data|r")
            end
        end
    end)
    
    -- Switch profile function
    function panel:SwitchProfile(profileName)
        if BLU:SwitchProfile(profileName) then
            self.currentProfileText:SetText(profileName)
            self:RefreshProfileList()
            BLU:Print("|cff00ff00Switched to profile:|r " .. profileName)
            
            -- Reload UI prompt
            StaticPopupDialogs["BLU_RELOAD_UI"] = {
                text = "Profile switched. Reload UI for changes to take effect?",
                button1 = "Reload",
                button2 = "Later",
                OnAccept = function()
                    ReloadUI()
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
            }
            StaticPopup_Show("BLU_RELOAD_UI")
        end
    end
    
    -- Initialize list
    panel:SetScript("OnShow", function(self)
        self:RefreshProfileList()
    end)
    
    -- Register with tab system
    if BLU.TabSystem then
        BLU.TabSystem:RegisterPanel("profiles", panel)
    end
    
    return panel
end