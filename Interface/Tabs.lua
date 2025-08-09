--=====================================================================================
-- BLU | Tab System
-- Author: donniedice
-- Description: Tab navigation system for the options panel
--=====================================================================================

local addonName, BLU = ...

-- Create the TabSystem namespace
BLU.TabSystem = BLU.TabSystem or {}
local TabSystem = BLU.TabSystem

-- Tab configuration
TabSystem.tabs = {
    { id = "general", label = "General", order = 1 },
    { id = "sounds", label = "Sounds", order = 2 },
    { id = "modules", label = "Modules", order = 3 },
    { id = "profiles", label = "Profiles", order = 4 },
    { id = "advanced", label = "Advanced", order = 5 },
    { id = "about", label = "About", order = 6 }
}

-- Create the tab bar
function TabSystem:CreateTabBar(parent)
    local tabBar = CreateFrame("Frame", nil, parent)
    tabBar:SetHeight(40)
    tabBar:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    tabBar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, -10)
    
    -- Store tab buttons
    tabBar.buttons = {}
    
    -- Create tab buttons
    local previousButton = nil
    for _, tabInfo in ipairs(self.tabs) do
        local button = self:CreateTabButton(tabBar, tabInfo)
        
        if previousButton then
            button:SetPoint("LEFT", previousButton, "RIGHT", 2, 0)
        else
            button:SetPoint("LEFT", tabBar, "LEFT", 0, 0)
        end
        
        tabBar.buttons[tabInfo.id] = button
        previousButton = button
    end
    
    return tabBar
end

-- Create individual tab button
function TabSystem:CreateTabButton(parent, tabInfo)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(100, 32)
    
    -- Normal texture
    button:SetNormalTexture("Interface\\ChatFrame\\ChatFrameTab")
    local normal = button:GetNormalTexture()
    normal:SetTexCoord(0, 1, 0, 1)
    
    -- Highlight texture
    button:SetHighlightTexture("Interface\\ChatFrame\\ChatFrameTab-Highlight")
    local highlight = button:GetHighlightTexture()
    highlight:SetBlendMode("ADD")
    
    -- Pushed texture
    button:SetPushedTexture("Interface\\ChatFrame\\ChatFrameTab-Selected")
    
    -- Text
    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.text:SetPoint("CENTER", 0, 0)
    button.text:SetText(tabInfo.label)
    
    -- Store tab info
    button.tabId = tabInfo.id
    button.tabInfo = tabInfo
    
    -- Click handler
    button:SetScript("OnClick", function(self)
        TabSystem:SelectTab(self.tabId)
    end)
    
    -- Tooltip
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(tabInfo.label)
        GameTooltip:Show()
    end)
    
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    return button
end

-- Select a tab
function TabSystem:SelectTab(tabId)
    if not self.currentParent then return end
    
    -- Update button states
    if self.tabBar and self.tabBar.buttons then
        for id, button in pairs(self.tabBar.buttons) do
            if id == tabId then
                -- Selected state
                button:SetNormalTexture("Interface\\ChatFrame\\ChatFrameTab-Selected")
                button.text:SetTextColor(1, 1, 1)
                button.selected = true
            else
                -- Normal state
                button:SetNormalTexture("Interface\\ChatFrame\\ChatFrameTab")
                button.text:SetTextColor(0.7, 0.7, 0.7)
                button.selected = false
            end
        end
    end
    
    -- Hide all panels
    if self.panels then
        for _, panel in pairs(self.panels) do
            if panel then
                panel:Hide()
            end
        end
    end
    
    -- Show selected panel
    if self.panels and self.panels[tabId] then
        self.panels[tabId]:Show()
        self.activeTab = tabId
        
        -- Call panel's OnShow handler if it exists
        if self.panels[tabId].OnShow then
            self.panels[tabId]:OnShow()
        end
    end
    
    -- Save selected tab
    if BLU.db and BLU.db.profile then
        BLU.db.profile.selectedTab = tabId
    end
end

-- Initialize tab system with a parent frame
function TabSystem:Initialize(parent)
    self.currentParent = parent
    self.panels = {}
    
    -- Create tab bar
    self.tabBar = self:CreateTabBar(parent)
    
    -- Create content area
    local contentArea = CreateFrame("Frame", nil, parent)
    contentArea:SetPoint("TOPLEFT", self.tabBar, "BOTTOMLEFT", 0, -5)
    contentArea:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -10, 10)
    self.contentArea = contentArea
    
    return contentArea
end

-- Register a panel for a tab
function TabSystem:RegisterPanel(tabId, panel)
    if not self.panels then
        self.panels = {}
    end
    
    self.panels[tabId] = panel
    panel:SetParent(self.contentArea)
    panel:SetAllPoints(self.contentArea)
    panel:Hide()
end

-- Get the currently selected tab
function TabSystem:GetSelectedTab()
    return self.activeTab
end

-- Refresh the tab system
function TabSystem:Refresh()
    if self.activeTab then
        self:SelectTab(self.activeTab)
    else
        -- Select first tab by default
        self:SelectTab("general")
    end
end