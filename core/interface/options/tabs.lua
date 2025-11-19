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

-- Tab configuration from alpha.3
BLU.OptionsTabs = {
    -- Row 1
    {text = "General", create = BLU.CreateGeneralPanel, row = 1, col = 1},
    {text = "Sounds", create = BLU.CreateSoundsPanel, row = 1, col = 2},
    {text = "Level Up", eventType = "levelup", row = 1, col = 3},
    {text = "Achievement", eventType = "achievement", row = 1, col = 4},
    {text = "Quest", eventType = "quest", row = 1, col = 5},
    {text = "Reputation", eventType = "reputation", row = 1, col = 6},
    -- Row 2
    {text = "Battle Pets", eventType = "battlepet", row = 2, col = 1},
    {text = "Honor", eventType = "honorrank", row = 2, col = 2},
    {text = "Renown", eventType = "renownrank", row = 2, col = 3},
    {text = "Trading Post", eventType = "tradingpost", row = 2, col = 4},
    {text = "Delve", eventType = "delvecompanion", row = 2, col = 5},
    {text = "About", create = BLU.CreateAboutPanel, row = 2, col = 6}
}

-- Create a tab button (alpha.3 style)
function BLU.CreateTabButton(parent, text, index, row, col, panel)
    local button = CreateFrame("Button", "BLUTab" .. text:gsub(" ", ""), parent)
    button:SetSize(80, 22)

    local tabWidth = 80
    local tabSpacing = 3
    local xOffset = 10 + (col - 1) * (tabWidth + tabSpacing)
    local yOffset = -8 - (row - 1) * 26
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)

    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    button.bg = bg

    local border = CreateFrame("Frame", nil, button, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({
        edgeFile = "Interface/Buttons/WHITE8x8",
        edgeSize = 1,
    })
    border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    button.border = border

    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    buttonText:SetPoint("CENTER", 0, 0)
    buttonText:SetText(text)
    buttonText:SetTextColor(0.8, 0.8, 0.8, 1)
    button.text = buttonText

    button:SetScript("OnClick", function(self)
        panel:SelectTab(self.tabIndex)
    end)

    button:SetScript("OnEnter", function(self)
        if not self.isActive then
            self.border:SetBackdropBorderColor(unpack(BLU.Modules.design.Colors.Primary))
            self.text:SetTextColor(unpack(BLU.Modules.design.Colors.Primary))
        end
    end)

    button:SetScript("OnLeave", function(self)
        if not self.isActive then
            self.border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
            self.text:SetTextColor(0.7, 0.7, 0.7, 1)
        end
    end)

    button.tabIndex = index

    function button:SetActive(active)
        self.isActive = active
        if active then
            self.bg:SetColorTexture(0.08, 0.08, 0.08, 1)
            self.text:SetTextColor(unpack(BLU.Modules.design.Colors.Primary))
            self.border:SetBackdropBorderColor(unpack(BLU.Modules.design.Colors.Primary))
        else
            self.bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
            self.text:SetTextColor(0.7, 0.7, 0.7, 1)
            self.border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        end
    end

    return button
end

function Tabs:Init()
    BLU:PrintDebug("[Tabs] Initializing tab system (alpha.3 style)")
end

-- Register module
if BLU.RegisterModule then
    BLU:RegisterModule(Tabs, "tabs", "Tab System")
end