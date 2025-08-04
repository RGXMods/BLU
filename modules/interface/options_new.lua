--=====================================================================================
-- BLU - interface/options_new.lua
-- New options panel with SimpleQuestPlates-inspired design
--=====================================================================================

local addonName, BLU = ...

-- Create options module
local Options = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["options_new"] = Options

-- Panel dimensions
local PANEL_WIDTH = 700
local PANEL_HEIGHT = 600

-- Initialize options module
function Options:Init()
    BLU:PrintDebug("[Options] Initializing new options module")
    
    -- Make functions available globally
    BLU.CreateOptionsPanel = function()
        return self:CreateOptionsPanel()
    end
    
    BLU.OpenOptions = function()
        return self:OpenOptions()
    end
    
    BLU:PrintDebug("[Options] Functions registered")
    
    -- Create the panel after a short delay
    C_Timer.After(0.1, function()
        if not BLU.OptionsPanel then
            self:CreateOptionsPanel()
        end
    end)
end

-- Removed preview section - tabs will be module based

-- Create tab button with SimpleQuestPlates style
local function CreateTabButton(parent, text, icon, index, totalTabs)
    local button = CreateFrame("Button", "BLUTab" .. text:gsub(" ", ""), parent)
    button:SetSize(110, 28)
    
    -- Position
    if index == 1 then
        button:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, -2)
    else
        button:SetPoint("LEFT", parent[index-1], "RIGHT", 2, 0)
    end
    parent[index] = button
    
    -- Background with gradient
    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\Buttons\\UI-DialogBox-Button-Up")
    bg:SetTexCoord(0, 1, 0, 0.71875)
    bg:SetVertexColor(0.2, 0.2, 0.2, 1)
    button.bg = bg
    
    -- Border for active state
    local border = button:CreateTexture(nil, "BORDER")
    border:SetPoint("BOTTOMLEFT", 0, -2)
    border:SetPoint("BOTTOMRIGHT", 0, -2)
    border:SetHeight(2)
    border:SetColorTexture(0.02, 0.37, 1, 1)
    border:Hide()
    button.border = border
    
    -- Icon
    if icon then
        local tabIcon = button:CreateTexture(nil, "ARTWORK")
        tabIcon:SetSize(16, 16)
        tabIcon:SetPoint("LEFT", 8, 0)
        tabIcon:SetTexture(icon)
        button.icon = tabIcon
    end
    
    -- Text
    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    if icon then
        buttonText:SetPoint("LEFT", button.icon, "RIGHT", 5, 0)
    else
        buttonText:SetPoint("CENTER", 0, 0)
    end
    buttonText:SetText(text)
    button.text = buttonText
    
    -- Removed separate active indicator - using border instead
    
    -- Scripts
    button:SetScript("OnClick", function(self)
        self:GetParent():GetParent():SelectTab(self.tabIndex)
    end)
    
    button:SetScript("OnEnter", function(self)
        if not self.isActive then
            self.bg:SetVertexColor(0.3, 0.3, 0.3, 1)
        end
    end)
    
    button:SetScript("OnLeave", function(self)
        if not self.isActive then
            self.bg:SetVertexColor(0.2, 0.2, 0.2, 1)
        end
    end)
    
    button.tabIndex = index
    
    function button:SetActive(active)
        self.isActive = active
        if active then
            self.bg:SetVertexColor(0.02, 0.37, 1, 1)
            self.text:SetTextColor(1, 1, 1, 1)
            self.border:Show()
            if self.icon then
                self.icon:SetVertexColor(1, 1, 1, 1)
            end
        else
            self.bg:SetVertexColor(0.2, 0.2, 0.2, 1)
            self.text:SetTextColor(0.7, 0.7, 0.7, 1)
            self.border:Hide()
            if self.icon then
                self.icon:SetVertexColor(0.7, 0.7, 0.7, 1)
            end
        end
    end
    
    return button
end

-- Create main options panel
function Options:CreateOptionsPanel()
    BLU:PrintDebug("Creating new options panel...")
    
    -- Create main frame
    local panel = CreateFrame("Frame", "BLUOptionsPanel", UIParent)
    panel.name = "Better Level-Up!"
    
    -- Custom icon for the settings menu
    panel.OnCommit = function() end
    panel.OnDefault = function() end
    panel.OnRefresh = function() end
    
    -- Store reference
    BLU.OptionsPanel = panel
    
    -- Compact header
    local header = CreateFrame("Frame", nil, panel)
    header:SetHeight(60)
    header:SetPoint("TOPLEFT", 10, -10)
    header:SetPoint("TOPRIGHT", -10, -10)
    
    -- Header background
    local headerBg = header:CreateTexture(nil, "BACKGROUND")
    headerBg:SetAllPoints()
    headerBg:SetColorTexture(0.05, 0.05, 0.05, 0.9)
    
    -- Header border
    local headerBorder = CreateFrame("Frame", nil, header, "BackdropTemplate")
    headerBorder:SetAllPoints()
    headerBorder:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    headerBorder:SetBackdropBorderColor(0.02, 0.37, 1, 0.5)
    
    -- Icon
    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(48, 48)
    icon:SetPoint("LEFT", 10, 0)
    icon:SetTexture("Interface\\Icons\\Achievement_Level_100")
    
    -- Icon border
    local iconBorder = header:CreateTexture(nil, "OVERLAY")
    iconBorder:SetSize(52, 52)
    iconBorder:SetPoint("CENTER", icon, "CENTER")
    iconBorder:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    iconBorder:SetTexCoord(0.5, 0.625, 0.5, 0.625)
    iconBorder:SetVertexColor(0.02, 0.37, 1, 1)
    
    -- Title
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", icon, "RIGHT", 10, 8)
    title:SetText("|cff05dffaBLU|r - Better Level-Up!")
    
    -- Subtitle
    local subtitle = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    subtitle:SetText("Iconic game sounds for WoW events")
    subtitle:SetTextColor(0.7, 0.7, 0.7)
    
    -- Version
    local version = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    version:SetPoint("RIGHT", -10, 0)
    version:SetText("v" .. (BLU.version or "5.3.0"))
    version:SetTextColor(0.5, 0.5, 0.5)
    
    -- Tab container (directly under header)
    local tabContainer = CreateFrame("Frame", nil, panel)
    tabContainer:SetHeight(32)
    tabContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -5)
    tabContainer:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -5)
    
    -- Create tabs with icons
    local tabs = {
        {text = "General", icon = "Interface\\Icons\\INV_Misc_Gear_01", create = BLU.CreateGeneralPanel},
        {text = "Sounds", icon = "Interface\\Icons\\INV_Misc_Bell_01", create = BLU.CreateSoundsPanel},
        {text = "Modules", icon = "Interface\\Icons\\INV_Misc_Gear_08", create = BLU.CreateModulesPanel},
        {text = "About", icon = "Interface\\Icons\\INV_Misc_Book_09", create = BLU.CreateAboutPanel}
    }
    
    panel.tabs = {}
    panel.contents = {}
    
    for i, tabInfo in ipairs(tabs) do
        local tab = CreateTabButton(tabContainer, tabInfo.text, tabInfo.icon, i, #tabs)
        panel.tabs[i] = tab
        
        -- Create content frame
        local content = CreateFrame("Frame", nil, panel)
        content:SetPoint("TOPLEFT", tabContainer, "BOTTOMLEFT", 0, -2)
        content:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 10)
        
        -- Content background
        local contentBg = content:CreateTexture(nil, "BACKGROUND")
        contentBg:SetAllPoints()
        contentBg:SetColorTexture(0.02, 0.02, 0.02, 0.9)
        
        -- Content border
        local contentBorder = CreateFrame("Frame", nil, content, "BackdropTemplate")
        contentBorder:SetAllPoints()
        contentBorder:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        contentBorder:SetBackdropBorderColor(0.1, 0.1, 0.1, 1)
        
        content:Hide()
        
        -- Create tab content
        if tabInfo.create then
            tabInfo.create(content)
        end
        
        panel.contents[i] = content
    end
    
    -- Tab selection function
    function panel:SelectTab(index)
        for i, tab in ipairs(self.tabs) do
            tab:SetActive(i == index)
            self.contents[i]:SetShown(i == index)
        end
    end
    
    -- Select first tab
    panel:SelectTab(1)
    
    -- Register the panel with custom icon
    local category
    if Settings and Settings.RegisterCanvasLayoutCategory then
        -- Dragonflight+ (10.0+)
        category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        -- Add custom icon to the settings menu
        category.name = "|T" .. "Interface\\Icons\\Achievement_Level_100" .. ":16:16:0:0|t " .. panel.name
        Settings.RegisterAddOnCategory(category)
        BLU.OptionsCategory = category
        BLU:PrintDebug("Options panel registered with new Settings API")
    else
        -- Pre-Dragonflight
        InterfaceOptions_AddCategory(panel)
        BLU.OptionsCategory = panel
        BLU:PrintDebug("Options panel registered with legacy API")
    end
    
    return panel
end

-- Open options
function Options:OpenOptions()
    -- Create panel if it doesn't exist
    if not BLU.OptionsPanel then
        self:CreateOptionsPanel()
    end
    
    if not BLU.OptionsCategory then
        BLU:Print("Options panel not properly registered.")
        return
    end
    
    if Settings and Settings.OpenToCategory and BLU.OptionsCategory and BLU.OptionsCategory.ID then
        Settings.OpenToCategory(BLU.OptionsCategory.ID)
        C_Timer.After(0.1, function()
            Settings.OpenToCategory(BLU.OptionsCategory.ID)
        end)
    elseif InterfaceOptionsFrame_OpenToCategory and BLU.OptionsCategory then
        InterfaceOptionsFrame_OpenToCategory(BLU.OptionsCategory)
        InterfaceOptionsFrame_OpenToCategory(BLU.OptionsCategory)
    else
        BLU:Print("Unable to open options panel")
    end
end

-- Removed RGX Mods panel - keeping focus on core functionality