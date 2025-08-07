--=====================================================================================
-- BLU - core/options_direct.lua
-- Direct simple options panel that definitely works
--=====================================================================================

local addonName, BLU = ...

-- Create panel immediately when this file loads
local panel = CreateFrame("Frame", "BLUMainPanel", UIParent)
panel.name = "Better Level-Up!"

-- Add title
local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("|cff05dffaB|retter |cff05dffaL|revel-|cff05dffaU|rp!")

local info = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
info:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
info:SetText("Sound replacement addon for World of Warcraft")

-- Store globally
BLU.SimplePanel = panel
_G["BLUMainPanel"] = panel

-- Register after everything loads
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    -- Try both registration methods
    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
        BLU:Print("|cff00ff00BLU options registered (Legacy)|r")
    end
    
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        if Settings.RegisterAddOnCategory then
            Settings.RegisterAddOnCategory(category)
        end
        panel.category = category
        BLU:Print("|cff00ff00BLU options registered (Modern)|r")
    end
end)

-- Override the /blu command directly
SLASH_BLUDIRECT1 = "/blu"
SlashCmdList["BLUDIRECT"] = function(msg)
    -- Create the full tabbed panel if it doesn't exist
    if not BLU.FullOptionsPanel and BLU.Modules and BLU.Modules.options_new then
        BLU:Print("Creating full options panel with tabs...")
        if BLU.Modules.options_new.CreateOptionsPanel then
            BLU.Modules.options_new:CreateOptionsPanel()
            BLU.FullOptionsPanel = BLU.OptionsPanel
        end
    end
    
    -- If we have the full panel, use that instead
    if BLU.FullOptionsPanel then
        panel = BLU.FullOptionsPanel
    end
    -- Handle debug
    if msg == "debug" then
        BLU:Print("Panel exists: " .. tostring(BLU.SimplePanel ~= nil))
        BLU:Print("Global panel: " .. tostring(_G["BLUMainPanel"] ~= nil))
        return
    end
    
    -- Try to open the panel
    local opened = false
    
    -- Method 1: Try Settings API
    if Settings and Settings.OpenToCategory then
        if panel.category and panel.category.ID then
            Settings.OpenToCategory(panel.category.ID)
            opened = true
        elseif panel.category then
            Settings.OpenToCategory(panel.category)
            opened = true
        else
            Settings.OpenToCategory(panel.name)
            opened = true
        end
    end
    
    -- Method 2: Try legacy API
    if not opened and InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel) -- Call twice
        opened = true
    end
    
    -- Method 3: Just open the main options
    if not opened then
        if Settings and Settings.Open then
            Settings.Open()
            BLU:Print("Opened Settings - look for 'Better Level-Up!' in the addon list")
        elseif InterfaceOptionsFrame then
            InterfaceOptionsFrame:Show()
            BLU:Print("Opened Interface Options - look for 'Better Level-Up!' in the addon list")
        else
            BLU:Print("Could not open options. Try: ESC -> Options -> AddOns -> Better Level-Up!")
        end
    end
end

BLU:Print("|cff05dffaBLU|r addon loaded - Type |cffffff00/blu|r for options")