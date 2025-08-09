--=====================================================================================
-- BLU | Advanced Settings Panel
-- Author: donniedice
-- Description: Debug options, cache management, database tools
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateAdvancedPanel()
    local panel = CreateFrame("Frame", nil, UIParent)
    panel:Hide()
    
    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Advanced Settings")
    
    local yOffset = -50
    
    -- Debug Section
    local debugTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    debugTitle:SetPoint("TOPLEFT", 16, yOffset)
    debugTitle:SetText("Debug Options")
    debugTitle:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    -- Debug mode checkbox
    local debugCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    debugCheck:SetPoint("TOPLEFT", 30, yOffset)
    debugCheck.text = debugCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    debugCheck.text:SetPoint("LEFT", debugCheck, "RIGHT", 5, 0)
    debugCheck.text:SetText("Enable debug mode (verbose logging)")
    debugCheck:SetChecked(BLU.debugMode or false)
    debugCheck:SetScript("OnClick", function(self)
        BLU.debugMode = self:GetChecked()
        BLU:SetDB("debugMode", BLU.debugMode)
        BLU:Print("Debug mode: " .. (BLU.debugMode and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r"))
    end)
    
    yOffset = yOffset - 30
    
    -- Test mode checkbox
    local testModeCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    testModeCheck:SetPoint("TOPLEFT", 30, yOffset)
    testModeCheck.text = testModeCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    testModeCheck.text:SetPoint("LEFT", testModeCheck, "RIGHT", 5, 0)
    testModeCheck.text:SetText("Test mode (play sounds without events)")
    testModeCheck:SetChecked(BLU:GetDB("testMode") or false)
    testModeCheck:SetScript("OnClick", function(self)
        BLU:SetDB("testMode", self:GetChecked())
        BLU:Print("Test mode: " .. (self:GetChecked() and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r"))
    end)
    
    yOffset = yOffset - 30
    
    -- Auto preview checkbox
    local autoPreviewCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    autoPreviewCheck:SetPoint("TOPLEFT", 30, yOffset)
    autoPreviewCheck.text = autoPreviewCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    autoPreviewCheck.text:SetPoint("LEFT", autoPreviewCheck, "RIGHT", 5, 0)
    autoPreviewCheck.text:SetText("Auto-preview sounds on selection")
    autoPreviewCheck:SetChecked(BLU:GetDB("autoPreview") or false)
    autoPreviewCheck:SetScript("OnClick", function(self)
        BLU:SetDB("autoPreview", self:GetChecked())
    end)
    
    yOffset = yOffset - 50
    
    -- Cache Management Section
    local cacheTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    cacheTitle:SetPoint("TOPLEFT", 16, yOffset)
    cacheTitle:SetText("Cache Management")
    cacheTitle:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    -- Cache info
    local cacheInfo = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cacheInfo:SetPoint("TOPLEFT", 30, yOffset)
    cacheInfo:SetText("Sound cache stores recently played sounds for faster playback")
    cacheInfo:SetTextColor(0.7, 0.7, 0.7)
    
    yOffset = yOffset - 30
    
    -- Clear cache button
    local clearCacheBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    clearCacheBtn:SetSize(120, 25)
    clearCacheBtn:SetPoint("TOPLEFT", 30, yOffset)
    clearCacheBtn:SetText("Clear Cache")
    clearCacheBtn:SetScript("OnClick", function()
        if BLU.ClearSoundCache then
            BLU:ClearSoundCache()
        end
        collectgarbage("collect")
        BLU:Print("|cff00ff00Sound cache cleared|r")
    end)
    
    -- Cache size display
    local cacheSizeText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cacheSizeText:SetPoint("LEFT", clearCacheBtn, "RIGHT", 20, 0)
    cacheSizeText:SetText("Cache size: calculating...")
    
    -- Update cache size
    local function UpdateCacheSize()
        UpdateAddOnMemoryUsage()
        local memory = GetAddOnMemoryUsage(addonName)
        cacheSizeText:SetText(string.format("Memory usage: %.2f MB", memory / 1024))
    end
    
    -- Reload sounds button
    local reloadSoundsBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    reloadSoundsBtn:SetSize(120, 25)
    reloadSoundsBtn:SetPoint("LEFT", clearCacheBtn, "RIGHT", 200, 0)
    reloadSoundsBtn:SetText("Reload Sounds")
    reloadSoundsBtn:SetScript("OnClick", function()
        if BLU.Registry then
            BLU.Registry:ReloadAllSounds()
        end
        BLU:Print("|cff00ff00Sound registry reloaded|r")
    end)
    
    yOffset = yOffset - 50
    
    -- Database Tools Section
    local dbTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    dbTitle:SetPoint("TOPLEFT", 16, yOffset)
    dbTitle:SetText("Database Tools")
    dbTitle:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    -- Database info
    local dbInfo = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dbInfo:SetPoint("TOPLEFT", 30, yOffset)
    dbInfo:SetText("Manage saved variables and settings database")
    dbInfo:SetTextColor(0.7, 0.7, 0.7)
    
    yOffset = yOffset - 30
    
    -- Rebuild database button
    local rebuildDbBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    rebuildDbBtn:SetSize(120, 25)
    rebuildDbBtn:SetPoint("TOPLEFT", 30, yOffset)
    rebuildDbBtn:SetText("Rebuild Database")
    rebuildDbBtn:SetScript("OnClick", function()
        StaticPopupDialogs["BLU_REBUILD_DB"] = {
            text = "This will rebuild the database with default values. Continue?",
            button1 = "Rebuild",
            button2 = "Cancel",
            OnAccept = function()
                if BLU.RebuildDatabase then
                    BLU:RebuildDatabase()
                end
                BLU:Print("|cff00ff00Database rebuilt|r")
                ReloadUI()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("BLU_REBUILD_DB")
    end)
    
    -- Validate database button
    local validateDbBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    validateDbBtn:SetSize(120, 25)
    validateDbBtn:SetPoint("LEFT", rebuildDbBtn, "RIGHT", 10, 0)
    validateDbBtn:SetText("Validate Database")
    validateDbBtn:SetScript("OnClick", function()
        local issues = BLU:ValidateDatabase()
        if issues == 0 then
            BLU:Print("|cff00ff00Database validation passed|r")
        else
            BLU:Print(string.format("|cffff0000Database validation found %d issues (auto-fixed)|r", issues))
        end
    end)
    
    -- Export database button
    local exportDbBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    exportDbBtn:SetSize(120, 25)
    exportDbBtn:SetPoint("LEFT", validateDbBtn, "RIGHT", 10, 0)
    exportDbBtn:SetText("Export Database")
    exportDbBtn:SetScript("OnClick", function()
        if BLU.ExportDatabase then
            local data = BLU:ExportDatabase()
            BLU:Print("|cff00ff00Database exported to clipboard (use Ctrl+V to paste)|r")
            -- Note: WoW doesn't have clipboard API, would need to show in editbox
        end
    end)
    
    yOffset = yOffset - 50
    
    -- Module Debugging Section
    local moduleDebugTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    moduleDebugTitle:SetPoint("TOPLEFT", 16, yOffset)
    moduleDebugTitle:SetText("Module Debugging")
    moduleDebugTitle:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    -- List loaded modules button
    local listModulesBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    listModulesBtn:SetSize(120, 25)
    listModulesBtn:SetPoint("TOPLEFT", 30, yOffset)
    listModulesBtn:SetText("List Modules")
    listModulesBtn:SetScript("OnClick", function()
        BLU:Print("|cff00ff00Loaded modules:|r")
        if BLU.Modules then
            for name, module in pairs(BLU.Modules) do
                local status = module.enabled and "|cff00ff00enabled|r" or "|cffff0000disabled|r"
                BLU:Print(string.format("  %s: %s", name, status))
            end
        end
    end)
    
    -- Test all sounds button
    local testAllBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    testAllBtn:SetSize(120, 25)
    testAllBtn:SetPoint("LEFT", listModulesBtn, "RIGHT", 10, 0)
    testAllBtn:SetText("Test All Sounds")
    testAllBtn:SetScript("OnClick", function()
        StaticPopupDialogs["BLU_TEST_ALL"] = {
            text = "This will play all registered sounds. Continue?",
            button1 = "Test",
            button2 = "Cancel",
            OnAccept = function()
                BLU:TestAllSounds()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("BLU_TEST_ALL")
    end)
    
    -- Force reload modules
    local reloadModulesBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    reloadModulesBtn:SetSize(120, 25)
    reloadModulesBtn:SetPoint("LEFT", testAllBtn, "RIGHT", 10, 0)
    reloadModulesBtn:SetText("Reload Modules")
    reloadModulesBtn:SetScript("OnClick", function()
        if BLU.ReloadAllModules then
            BLU:ReloadAllModules()
        end
        BLU:Print("|cff00ff00All modules reloaded|r")
    end)
    
    yOffset = yOffset - 50
    
    -- Reset Section
    local resetTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    resetTitle:SetPoint("TOPLEFT", 16, yOffset)
    resetTitle:SetText("Reset Options")
    resetTitle:SetTextColor(1, 0.3, 0.3)
    
    yOffset = yOffset - 30
    
    -- Reset warning
    local resetWarning = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    resetWarning:SetPoint("TOPLEFT", 30, yOffset)
    resetWarning:SetText("|cffff0000Warning: These actions cannot be undone!|r")
    
    yOffset = yOffset - 30
    
    -- Reset to defaults button
    local resetDefaultsBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetDefaultsBtn:SetSize(150, 25)
    resetDefaultsBtn:SetPoint("TOPLEFT", 30, yOffset)
    resetDefaultsBtn:SetText("Reset to Defaults")
    resetDefaultsBtn:SetScript("OnClick", function()
        StaticPopupDialogs["BLU_RESET_DEFAULTS"] = {
            text = "Reset all settings to default values?",
            button1 = "Reset",
            button2 = "Cancel",
            OnAccept = function()
                BLU:ResetToDefaults()
                BLU:Print("|cff00ff00Settings reset to defaults|r")
                ReloadUI()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("BLU_RESET_DEFAULTS")
    end)
    
    -- Full reset button
    local fullResetBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    fullResetBtn:SetSize(150, 25)
    fullResetBtn:SetPoint("LEFT", resetDefaultsBtn, "RIGHT", 10, 0)
    fullResetBtn:SetText("Full Reset (All Data)")
    fullResetBtn:SetScript("OnClick", function()
        StaticPopupDialogs["BLU_FULL_RESET"] = {
            text = "|cffff0000WARNING: This will delete ALL saved data including profiles!|r\n\nAre you sure?",
            button1 = "DELETE ALL",
            button2 = "Cancel",
            OnAccept = function()
                BLUDB = nil
                BLU:Print("|cffff0000All data deleted. Reloading UI...|r")
                C_Timer.After(1, ReloadUI)
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("BLU_FULL_RESET")
    end)
    
    -- Update functions
    panel:SetScript("OnShow", function()
        UpdateCacheSize()
        C_Timer.NewTicker(2, function()
            if panel:IsVisible() then
                UpdateCacheSize()
            end
        end)
    end)
    
    -- Register with tab system
    if BLU.TabSystem then
        BLU.TabSystem:RegisterPanel("advanced", panel)
    end
    
    return panel
end