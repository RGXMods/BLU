--=====================================================================================
-- BLU | Tab System
-- Author: donniedice
-- Description: Tab navigation for options panel
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateTabs(parent)
    -- Create tab container
    local tabContainer = CreateFrame("Frame", nil, parent)
    tabContainer:SetPoint("TOPLEFT", 10, -30)
    tabContainer:SetPoint("TOPRIGHT", -10, -30)
    tabContainer:SetHeight(30)
    
    -- Tab definitions
    local tabInfo = {
        {id = "general", text = "General", panel = "general"},
        {id = "sounds", text = "Sounds", panel = "sounds"},
        {id = "modules", text = "Modules", panel = "modules"},
        {id = "profiles", text = "Profiles", panel = "profiles"},
        {id = "advanced", text = "Advanced", panel = "advanced"},
        {id = "about", text = "About", panel = "about"}
    }
    
    -- Create tabs
    local tabs = {}
    local previousTab = nil
    
    for i, info in ipairs(tabInfo) do
        local tab = CreateFrame("Button", nil, tabContainer, "PanelTabButtonTemplate")
        tab:SetText(info.text)
        tab.panel = info.panel
        tab.id = info.id
        
        if previousTab then
            tab:SetPoint("LEFT", previousTab, "RIGHT", -15, 0)
        else
            tab:SetPoint("BOTTOMLEFT", 0, -2)
        end
        
        -- Set up click handler
        tab:SetScript("OnClick", function(self)
            -- Deselect all tabs
            for _, t in pairs(tabs) do
                PanelTemplates_DeselectTab(t)
                if parent.panels and parent.panels[t.panel] then
                    parent.panels[t.panel]:Hide()
                end
            end
            
            -- Select this tab
            PanelTemplates_SelectTab(self)
            if parent.panels and parent.panels[self.panel] then
                parent.panels[self.panel]:Show()
            end
            
            -- Store selected tab
            BLU.db.selectedTab = self.id
        end)
        
        tabs[i] = tab
        previousTab = tab
    end
    
    -- Select first tab by default
    if tabs[1] then
        PanelTemplates_SelectTab(tabs[1])
    end
    
    -- Store tabs for later use
    parent.tabs = tabs
    
    return tabContainer
end