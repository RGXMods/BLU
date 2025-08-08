--=====================================================================================
-- BLU | Better Level-Up! - Main Settings Interface
-- Author: donniedice
-- Description: Complete options panel with all features
--=====================================================================================

local addonName, BLU = ...

-- Initialize settings namespace
BLU.Settings = BLU.Settings or {}
local Settings = BLU.Settings

-- Constants
local PANEL_WIDTH = 800
local PANEL_HEIGHT = 600
local TAB_HEIGHT = 32
local PADDING = 10

-- Create main options frame
function Settings:CreateMainFrame()
    if self.mainFrame then return self.mainFrame end
    
    -- Main frame
    local frame = CreateFrame("Frame", "BLUOptionsFrame", UIParent, "BackdropTemplate")
    frame:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    -- Backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.9)
    
    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -16)
    title:SetText("|cff00ccffBLU|r - Better Level-Up! v6.0.0")
    frame.title = title
    
    -- Subtitle
    local subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -4)
    subtitle:SetText("Complete Sound Replacement System")
    subtitle:SetTextColor(0.7, 0.7, 0.7)
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)
    
    -- Tab container
    local tabContainer = CreateFrame("Frame", nil, frame)
    tabContainer:SetPoint("TOPLEFT", PADDING, -60)
    tabContainer:SetPoint("TOPRIGHT", -PADDING, -60)
    tabContainer:SetHeight(TAB_HEIGHT)
    frame.tabContainer = tabContainer
    
    -- Content container
    local contentContainer = CreateFrame("Frame", nil, frame)
    contentContainer:SetPoint("TOPLEFT", PADDING, -100)
    contentContainer:SetPoint("BOTTOMRIGHT", -PADDING, 40)
    frame.contentContainer = contentContainer
    
    -- Bottom button bar
    local buttonBar = CreateFrame("Frame", nil, frame)
    buttonBar:SetPoint("BOTTOMLEFT", PADDING, PADDING)
    buttonBar:SetPoint("BOTTOMRIGHT", -PADDING, PADDING)
    buttonBar:SetHeight(30)
    frame.buttonBar = buttonBar
    
    -- Save button
    local saveBtn = CreateFrame("Button", nil, buttonBar, "UIPanelButtonTemplate")
    saveBtn:SetSize(100, 24)
    saveBtn:SetPoint("RIGHT", -5, 0)
    saveBtn:SetText("Save")
    saveBtn:SetScript("OnClick", function()
        BLU:SaveSettings()
        print("|cff00ccffBLU:|r Settings saved!")
    end)
    
    -- Defaults button
    local defaultsBtn = CreateFrame("Button", nil, buttonBar, "UIPanelButtonTemplate")
    defaultsBtn:SetSize(100, 24)
    defaultsBtn:SetPoint("RIGHT", saveBtn, "LEFT", -5, 0)
    defaultsBtn:SetText("Defaults")
    defaultsBtn:SetScript("OnClick", function()
        StaticPopup_Show("BLU_RESET_CONFIRM")
    end)
    
    -- Test mode button
    local testBtn = CreateFrame("Button", nil, buttonBar, "UIPanelButtonTemplate")
    testBtn:SetSize(100, 24)
    testBtn:SetPoint("LEFT", 5, 0)
    testBtn:SetText("Test Mode")
    testBtn:SetScript("OnClick", function()
        Settings:ToggleTestMode()
    end)
    frame.testBtn = testBtn
    
    self.mainFrame = frame
    return frame
end

-- Tab system
Settings.tabs = {}
Settings.panels = {}
Settings.activeTab = nil

function Settings:CreateTab(id, name, createFunc)
    local frame = self.mainFrame or self:CreateMainFrame()
    local index = #self.tabs + 1
    
    -- Create tab button
    local tab = CreateFrame("Button", nil, frame.tabContainer)
    tab:SetSize(120, TAB_HEIGHT)
    tab:SetPoint("LEFT", (index - 1) * 125, 0)
    tab.id = id
    
    -- Tab background
    local bg = tab:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    tab.bg = bg
    
    -- Tab text
    local text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("CENTER")
    text:SetText(name)
    tab.text = text
    
    -- Highlight
    tab:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    
    -- Click handler
    tab:SetScript("OnClick", function()
        self:ShowTab(id)
    end)
    
    -- Store tab
    self.tabs[id] = {
        button = tab,
        name = name,
        createFunc = createFunc
    }
    
    -- Create first tab as active
    if index == 1 then
        self:ShowTab(id)
    end
    
    return tab
end

function Settings:ShowTab(id)
    local tabData = self.tabs[id]
    if not tabData then return end
    
    -- Update tab appearance
    for tabId, data in pairs(self.tabs) do
        if tabId == id then
            data.button.bg:SetColorTexture(0.2, 0.2, 0.2, 1)
            data.button.text:SetTextColor(0, 0.8, 1)
        else
            data.button.bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
            data.button.text:SetTextColor(1, 1, 1)
        end
    end
    
    -- Hide all panels
    for _, panel in pairs(self.panels) do
        panel:Hide()
    end
    
    -- Create/show active panel
    if not self.panels[id] then
        self.panels[id] = tabData.createFunc(self.mainFrame.contentContainer)
    end
    self.panels[id]:Show()
    
    self.activeTab = id
end

-- Test mode
Settings.testMode = false

function Settings:ToggleTestMode()
    self.testMode = not self.testMode
    
    if self.testMode then
        self.mainFrame.testBtn:SetText("Exit Test")
        print("|cff00ccffBLU:|r Test mode enabled - Click sounds to preview")
        
        -- Enable test mode overlay
        if not self.testOverlay then
            self.testOverlay = CreateFrame("Frame", nil, UIParent)
            self.testOverlay:SetAllPoints()
            self.testOverlay:SetFrameStrata("TOOLTIP")
            self.testOverlay:EnableMouse(false)
            
            local text = self.testOverlay:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            text:SetPoint("TOP", 0, -100)
            text:SetText("|cff00ccffTEST MODE ACTIVE|r")
        end
        self.testOverlay:Show()
    else
        self.mainFrame.testBtn:SetText("Test Mode")
        print("|cff00ccffBLU:|r Test mode disabled")
        
        if self.testOverlay then
            self.testOverlay:Hide()
        end
    end
end

-- Reset confirmation dialog
StaticPopupDialogs["BLU_RESET_CONFIRM"] = {
    text = "Reset all BLU settings to defaults?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        BLU:ResetToDefaults()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Show/hide functions
function Settings:Show()
    if not self.mainFrame then
        self:CreateMainFrame()
        self:InitializeTabs()
    end
    self.mainFrame:Show()
end

function Settings:Hide()
    if self.mainFrame then
        self.mainFrame:Hide()
    end
end

function Settings:Toggle()
    if self.mainFrame and self.mainFrame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

-- Initialize on load
function Settings:InitializeTabs()
    -- Create all tabs
    self:CreateTab("general", "General", BLU.CreateGeneralPanel)
    self:CreateTab("sounds", "Sounds", BLU.CreateSoundsPanel)
    self:CreateTab("modules", "Modules", BLU.CreateModulesPanel)
    self:CreateTab("profiles", "Profiles", BLU.CreateProfilesPanel)
    self:CreateTab("advanced", "Advanced", BLU.CreateAdvancedPanel)
    self:CreateTab("about", "About", BLU.CreateAboutPanel)
end