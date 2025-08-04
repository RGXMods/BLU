--=====================================================================================
-- BLU - interface/tabs.lua
-- Tab system for options panel
--=====================================================================================

local addonName, BLU = ...

BLU.Tabs = {}
local tabs = {}
local activeTab = nil

-- Create tab button
local function CreateTabButton(parent, id, text, panel)
    local button = CreateFrame("Button", "BLUTab"..id, parent)
    button:SetSize(100, 32)
    button:SetID(id)
    
    -- Normal texture
    button:SetNormalTexture("Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab")
    button:SetHighlightTexture("Interface\\OptionsFrame\\UI-OptionsFrame-MouseOverTab")
    button:SetPushedTexture("Interface\\OptionsFrame\\UI-OptionsFrame-ActiveTab")
    button:SetDisabledTexture("Interface\\OptionsFrame\\UI-OptionsFrame-ActiveTab")
    
    -- Text
    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.text:SetPoint("CENTER", 0, -3)
    button.text:SetText(text)
    
    -- Panel reference
    button.panel = panel
    
    -- Click handler
    button:SetScript("OnClick", function(self)
        BLU.Tabs:SelectTab(self:GetID())
    end)
    
    return button
end

-- Initialize tab system
function BLU.Tabs:Init(parent)
    self.parent = parent
    self.content = CreateFrame("Frame", nil, parent)
    self.content:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, -100)
    self.content:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -16, 16)
end

-- Add a tab
function BLU.Tabs:AddTab(text, createFunc)
    local id = #tabs + 1
    
    -- Create content panel
    local panel = CreateFrame("Frame", nil, self.content)
    panel:SetAllPoints()
    panel:Hide()
    
    -- Let the create function populate the panel
    if createFunc then
        createFunc(panel)
    end
    
    -- Create tab button
    local button = CreateTabButton(self.parent, id, text, panel)
    
    -- Position button
    if id == 1 then
        button:SetPoint("TOPLEFT", self.parent, "TOPLEFT", 20, -60)
    else
        button:SetPoint("LEFT", tabs[id-1], "RIGHT", -8, 0)
    end
    
    tabs[id] = button
    
    -- Select first tab by default
    if id == 1 then
        self:SelectTab(1)
    end
    
    return panel
end

-- Select a tab
function BLU.Tabs:SelectTab(id)
    -- Hide all panels and reset buttons
    for i, tab in ipairs(tabs) do
        tab.panel:Hide()
        tab:SetEnabled(true)
        tab:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
    end
    
    -- Show selected panel and highlight button
    local selectedTab = tabs[id]
    if selectedTab then
        selectedTab.panel:Show()
        selectedTab:SetEnabled(false)
        activeTab = id
    end
end

-- Get active tab
function BLU.Tabs:GetActiveTab()
    return activeTab
end