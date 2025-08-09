--=====================================================================================
-- BLU | Simple Options Panel with Tabs
-- Author: donniedice
-- Description: Clean tabbed interface for BLU options
--=====================================================================================

local addonName, BLU = ...

local function CreateOptionsFrame()
    -- Check if already exists
    if BLU.OptionsFrame then
        return BLU.OptionsFrame
    end
    
    -- Create main frame
    local frame = CreateFrame("Frame", "BLUOptionsFrame", UIParent, "BasicFrameTemplateWithInset")
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
    
    -- Close button
    frame.CloseButton:SetScript("OnClick", function() frame:Hide() end)
    
    -- Create tab holder
    local tabHolder = CreateFrame("Frame", nil, frame)
    tabHolder:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -28)
    tabHolder:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -28)
    tabHolder:SetHeight(30)
    
    -- Create content area
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -65)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
    
    -- Tab info
    local tabs = {
        {id = "general", text = "General"},
        {id = "sounds", text = "Sounds"},
        {id = "modules", text = "Modules"},
        {id = "profiles", text = "Profiles"},
        {id = "advanced", text = "Advanced"},
        {id = "about", text = "About"}
    }
    
    -- Create panels storage
    frame.panels = {}
    
    -- Create tabs
    frame.tabs = {}
    local previousTab = nil
    
    for i, tabInfo in ipairs(tabs) do
        -- Create tab button
        local tab = CreateFrame("Button", nil, tabHolder, "PanelTabButtonTemplate")
        tab:SetText(tabInfo.text)
        tab.id = tabInfo.id
        tab:SetID(i)
        
        -- Position
        if previousTab then
            tab:SetPoint("LEFT", previousTab, "RIGHT", -15, 0)
        else
            tab:SetPoint("BOTTOMLEFT", 0, -1)
        end
        
        -- Create panel for this tab
        local panel = CreateFrame("Frame", nil, content)
        panel:SetAllPoints()
        panel:Hide()
        
        -- Add content based on tab
        if tabInfo.id == "general" then
            -- General panel content
            local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            title:SetPoint("TOPLEFT", 16, -16)
            title:SetText("General Settings")
            
            -- Enable checkbox
            local enableCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
            enableCheck:SetPoint("TOPLEFT", 20, -50)
            enableCheck.text = enableCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            enableCheck.text:SetPoint("LEFT", enableCheck, "RIGHT", 5, 0)
            enableCheck.text:SetText("Enable BLU Sound System")
            enableCheck:SetChecked(BLU.db and BLU.db.enabled ~= false)
            enableCheck:SetScript("OnClick", function(self)
                if BLU.db then
                    BLU.db.enabled = self:GetChecked()
                end
            end)
            
            -- Volume slider
            local volumeSlider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
            volumeSlider:SetPoint("TOPLEFT", 30, -100)
            volumeSlider:SetSize(300, 20)
            volumeSlider:SetMinMaxValues(0, 100)
            volumeSlider:SetValueStep(1)
            volumeSlider:SetObeyStepOnDrag(true)
            volumeSlider.Low:SetText("0")
            volumeSlider.High:SetText("100")
            volumeSlider.Text:SetText("Master Volume")
            volumeSlider:SetValue(BLU.db and BLU.db.soundVolume or 100)
            
            local volumeValue = volumeSlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            volumeValue:SetPoint("TOP", volumeSlider, "BOTTOM", 0, -5)
            volumeValue:SetText(string.format("%d%%", BLU.db and BLU.db.soundVolume or 100))
            volumeSlider.valueDisplay = volumeValue
            
            volumeSlider:SetScript("OnValueChanged", function(self, value)
                if BLU.db then
                    BLU.db.soundVolume = value
                end
                self.valueDisplay:SetText(string.format("%d%%", value))
            end)
            
        elseif tabInfo.id == "sounds" then
            -- Sounds panel content
            local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            title:SetPoint("TOPLEFT", 16, -16)
            title:SetText("Sound Settings")
            
            local info = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            info:SetPoint("TOPLEFT", 20, -50)
            info:SetText("Configure sounds for each event type")
            
        elseif tabInfo.id == "modules" then
            -- Modules panel content
            local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            title:SetPoint("TOPLEFT", 16, -16)
            title:SetText("Module Management")
            
            local info = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            info:SetPoint("TOPLEFT", 20, -50)
            info:SetText("Enable or disable BLU modules")
            
        elseif tabInfo.id == "profiles" then
            -- Profiles panel content
            local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            title:SetPoint("TOPLEFT", 16, -16)
            title:SetText("Profile Management")
            
            local info = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            info:SetPoint("TOPLEFT", 20, -50)
            info:SetText("Save and load sound configurations")
            
        elseif tabInfo.id == "advanced" then
            -- Advanced panel content
            local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            title:SetPoint("TOPLEFT", 16, -16)
            title:SetText("Advanced Settings")
            
            local info = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            info:SetPoint("TOPLEFT", 20, -50)
            info:SetText("Technical settings and debugging options")
            
        elseif tabInfo.id == "about" then
            -- About panel content
            local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            title:SetPoint("TOPLEFT", 16, -16)
            title:SetText("|cff00ccffBLU|r - Better Level-Up!")
            
            local version = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            version:SetPoint("TOPLEFT", 20, -50)
            version:SetText("Version: 6.0.0-alpha")
            
            local author = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            author:SetPoint("TOPLEFT", 20, -70)
            author:SetText("Author: donniedice")
            
            local desc = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            desc:SetPoint("TOPLEFT", 20, -100)
            desc:SetPoint("RIGHT", -20, 0)
            desc:SetJustifyH("LEFT")
            desc:SetText("BLU replaces default World of Warcraft sounds with iconic audio from over 50 classic and modern games.")
        end
        
        -- Store references
        frame.panels[tabInfo.id] = panel
        frame.tabs[i] = tab
        tab.panel = panel
        
        -- Tab click handler
        tab:SetScript("OnClick", function(self)
            -- Hide all panels and deselect tabs
            for _, t in pairs(frame.tabs) do
                PanelTemplates_DeselectTab(t)
                t.panel:Hide()
            end
            
            -- Show this panel and select tab
            PanelTemplates_SelectTab(self)
            self.panel:Show()
        end)
        
        previousTab = tab
    end
    
    -- Select first tab
    if frame.tabs[1] then
        PanelTemplates_SelectTab(frame.tabs[1])
        frame.tabs[1].panel:Show()
    end
    
    -- Store frame
    BLU.OptionsFrame = frame
    
    return frame
end

-- Register slash command
SLASH_BLU1 = "/blu"
SlashCmdList["BLU"] = function(msg)
    local frame = CreateOptionsFrame()
    if frame then
        frame:Show()
        frame:Raise()
    end
end

-- Also add to interface options
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    -- Create simple panel for interface options
    local panel = CreateFrame("Frame", "BLUInterfacePanel", UIParent)
    panel.name = "Better Level-Up!"
    
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("|cff05dffaB|retter |cff05dffaL|revel-|cff05dffaU|rp!")
    
    local openButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    openButton:SetSize(200, 30)
    openButton:SetPoint("TOPLEFT", 20, -60)
    openButton:SetText("Open BLU Options")
    openButton:SetScript("OnClick", function()
        local frame = CreateOptionsFrame()
        if frame then
            if Settings and Settings.Close then
                Settings.Close()
            elseif InterfaceOptionsFrame then
                InterfaceOptionsFrame:Hide()
            end
            frame:Show()
            frame:Raise()
        end
    end)
    
    -- Register panel
    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end
    
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        if Settings.RegisterAddOnCategory then
            Settings.RegisterAddOnCategory(category)
        end
    end
end)

print("|cff05dffaBLU|r loaded - Type |cffffff00/blu|r for options")