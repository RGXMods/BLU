--=====================================================================================
-- BLU - interface/options/tabs.lua
-- Tab system for options panel
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

-- Create tabs module
local Tabs = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["tabs"] = Tabs

-- Tab configuration
BLU.OptionsTabs = {
    -- Row 1
    {text = "General", row = 1, col = 1, create = function(content)
        if BLU.CreateGeneralPanel then
            BLU.CreateGeneralPanel(content)
        else
            local label = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            label:SetPoint("CENTER")
            label:SetText("General Settings\n(Loading...)")
        end
    end},
    
    {text = "Level Up", row = 1, col = 2, eventType = "levelup"},
    {text = "Achievement", row = 1, col = 3, eventType = "achievement"},
    {text = "Quest", row = 1, col = 4, eventType = "quest"},
    {text = "Reputation", row = 1, col = 5, eventType = "reputation"},
    
    -- Row 2
    {text = "Battle Pet", row = 2, col = 1, eventType = "battlepet"},
    {text = "Honor", row = 2, col = 2, eventType = "honor"},
    {text = "Renown", row = 2, col = 3, eventType = "renown"},
    {text = "Trading Post", row = 2, col = 4, eventType = "tradingpost"},
    {text = "Delves", row = 2, col = 5, eventType = "delve"},
    
    -- Row 3
    {text = "About", row = 3, col = 1, create = function(content)
        if BLU.CreateAboutPanel then
            BLU.CreateAboutPanel(content)
        else
            local label = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            label:SetPoint("CENTER")
            label:SetText("About BLU\n(Loading...)")
        end
    end},
}

-- Create a tab button
function BLU.CreateTabButton(parent, text, index, row, col, panel)
    if not parent then
        BLU:PrintError("CreateTabButton: parent is nil")
        return nil
    end
    
    if not BLU.Modules.design or not BLU.Modules.design.Backdrops then
        BLU:PrintError("CreateTabButton: BLU.Modules.design not loaded")
        return nil
    end
    
    local tab = CreateFrame("Button", nil, parent, "BackdropTemplate")
    tab:SetSize(120, 35)
    
    -- Calculate position
    local xOffset = 5 + ((col - 1) * 125)
    local yOffset = -5 - ((row - 1) * 40)
    tab:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)
    
    -- Styling
    tab:SetBackdrop(BLU.Modules.design.Backdrops.Button)
    tab:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
    tab:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    -- Text
    local label = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("CENTER")
    label:SetText(text)
    tab.label = label
    
    -- Click handler
    tab:SetScript("OnClick", function()
        if panel and panel.SelectTab then
            panel:SelectTab(index)
        end
    end)
    
    -- Hover effects
    tab:SetScript("OnEnter", function(self)
        if not self.isActive then
            self:SetBackdropColor(0.2, 0.2, 0.2, 1)
            self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        end
    end)
    
    tab:SetScript("OnLeave", function(self)
        if not self.isActive then
            self:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
            self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        end
    end)
    
    -- Active state
    function tab:SetActive(active)
        self.isActive = active
        if active then
            self:SetBackdropColor(0.02, 0.47, 0.98, 0.3)
            self:SetBackdropBorderColor(0.02, 0.47, 0.98, 1)
            self.label:SetTextColor(0.02, 0.47, 0.98)
        else
            self:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
            self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
            self.label:SetTextColor(1, 1, 1)
        end
    end
    
    return tab
end

function Tabs:Init()
    BLU:PrintDebug("[Tabs] Initializing tab system")
    
    -- Verify everything is loaded
    if not BLU.OptionsTabs then
        BLU:PrintError("[Tabs] BLU.OptionsTabs not defined!")
        return
    end
    
    if not BLU.CreateTabButton then
        BLU:PrintError("[Tabs] BLU.CreateTabButton not defined!")
        return
    end
    
    BLU:PrintDebug("[Tabs] Tab system initialized successfully")
    BLU:PrintDebug("[Tabs] Number of tabs configured: " .. #BLU.OptionsTabs)
end

-- Register module
if BLU.RegisterModule then
    BLU:RegisterModule(Tabs, "tabs", "Tab System")
end