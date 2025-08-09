--=====================================================================================
-- BLU - core/options_launcher.lua
-- Launches the full tabbed options panel
--=====================================================================================

local addonName, BLU = ...

-- This creates a launcher that opens the full tabbed interface
local function CreateFullOptionsPanel()
    if BLU.TabbedPanel then
        return BLU.TabbedPanel
    end
    
    -- Create main frame for tabs
    local frame = CreateFrame("Frame", "BLUTabbedOptions", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(850, 650)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    
    -- Set title
    frame.TitleText:SetText("|cff05dffaB|retter |cff05dffaL|revel-|cff05dffaU|rp! Options")
    
    -- Make close button work
    frame.CloseButton:SetScript("OnClick", function() frame:Hide() end)
    
    -- Store it
    BLU.TabbedPanel = frame
    
    -- Create the tab system
    if BLU.CreateTabs then
        BLU.CreateTabs(frame)
    end
    
    -- Create the panels
    local panelContainer = CreateFrame("Frame", nil, frame)
    panelContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -60)
    panelContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
    
    -- Store panels
    frame.panels = {}
    
    -- Create all panels
    if BLU.CreateGeneralPanel then
        frame.panels.general = BLU.CreateGeneralPanel(panelContainer)
    end
    if BLU.CreateSoundsPanel then
        frame.panels.sounds = BLU.CreateSoundsPanel(panelContainer)
    end
    if BLU.CreateModulesPanel then
        frame.panels.modules = BLU.CreateModulesPanel(panelContainer)
    end
    if BLU.CreateProfilesPanel then
        frame.panels.profiles = BLU.CreateProfilesPanel(panelContainer)
    end
    if BLU.CreateAdvancedPanel then
        frame.panels.advanced = BLU.CreateAdvancedPanel(panelContainer)
    end
    if BLU.CreateAboutPanel then
        frame.panels.about = BLU.CreateAboutPanel(panelContainer)
    end
    
    -- Show first panel
    if frame.panels.general then
        frame.panels.general:Show()
    end
    
    return frame
end

-- Hook into the existing slash command
local originalSlashHandler = SlashCmdList["BLU"]
SlashCmdList["BLU"] = function(msg)
    if msg == "" or msg == "options" or msg == "config" then
        local panel = CreateFullOptionsPanel()
        if panel then
            panel:Show()
            panel:Raise()
        else
            BLU:Print("Could not create options panel")
        end
    elseif originalSlashHandler then
        originalSlashHandler(msg)
    end
end

-- Also register in the interface options
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    -- Create a simple panel for the interface options
    local interfacePanel = CreateFrame("Frame", "BLUInterfacePanel", UIParent)
    interfacePanel.name = "Better Level-Up!"
    
    local title = interfacePanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("|cff05dffaB|retter |cff05dffaL|revel-|cff05dffaU|rp!")
    
    local subtitle = interfacePanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Sound replacement addon for World of Warcraft")
    
    local openButton = CreateFrame("Button", nil, interfacePanel, "UIPanelButtonTemplate")
    openButton:SetSize(200, 30)
    openButton:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -20)
    openButton:SetText("Open BLU Options")
    openButton:SetScript("OnClick", function()
        local panel = CreateFullOptionsPanel()
        if panel then
            -- Close the interface options
            if Settings and Settings.Close then
                Settings.Close()
            elseif InterfaceOptionsFrame then
                InterfaceOptionsFrame:Hide()
            end
            -- Show our panel
            panel:Show()
            panel:Raise()
        end
    end)
    
    local info = interfacePanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    info:SetPoint("TOPLEFT", openButton, "BOTTOMLEFT", 0, -20)
    info:SetPoint("RIGHT", -20, 0)
    info:SetJustifyH("LEFT")
    info:SetText("You can also type |cffffff00/blu|r to open the options panel.\n\n" ..
                 "Features:\n" ..
                 "• Replace default sounds with game sounds\n" ..
                 "• Support for 50+ game sound packs\n" ..
                 "• Per-event sound customization\n" ..
                 "• Volume control\n" ..
                 "• SharedMedia integration")
    
    -- Register it
    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(interfacePanel)
    end
    
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(interfacePanel, interfacePanel.name)
        if Settings.RegisterAddOnCategory then
            Settings.RegisterAddOnCategory(category)
        end
    end
end)