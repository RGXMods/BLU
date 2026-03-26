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

local TAB_BUTTON_WIDTH = 102
local TAB_BUTTON_HEIGHT = 24
local TAB_SPACING = 6
local TAB_ROW_PADDING = 8

-- Create a tab button (alpha.3 style)
function BLU.CreateTabButton(parent, text, index, row, col, panel, icon)
    local button = CreateFrame("Button", "BLUTab" .. text:gsub(" ", ""), parent)
    button:SetSize(TAB_BUTTON_WIDTH, TAB_BUTTON_HEIGHT)
    button.tabRow = row
    button.tabCol = col

    function button:UpdatePosition()
        local columnsPerRow = 6
        local rowWidth = (columnsPerRow * TAB_BUTTON_WIDTH) + ((columnsPerRow - 1) * TAB_SPACING)
        local parentWidth = parent:GetWidth()
        if not parentWidth or parentWidth <= 0 then
            parentWidth = rowWidth + (TAB_ROW_PADDING * 2)
        end

        local startX = math.floor((parentWidth - rowWidth) * 0.5)
        if startX < TAB_ROW_PADDING then
            startX = TAB_ROW_PADDING
        end

        local xOffset = startX + (self.tabCol - 1) * (TAB_BUTTON_WIDTH + TAB_SPACING)
        local yOffset = -8 - (self.tabRow - 1) * (TAB_BUTTON_HEIGHT + 4)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)
    end

    button:UpdatePosition()
    button:HookScript("OnShow", function(self)
        self:UpdatePosition()
    end)
    parent:HookScript("OnSizeChanged", function()
        button:UpdatePosition()
    end)

    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.08, 0.11, 0.15, 0.90)
    button.bg = bg

    local border = CreateFrame("Frame", nil, button, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    border:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
    button.border = border

    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    if icon then
        local iconTexture = button:CreateTexture(nil, "ARTWORK")
        iconTexture:SetSize(14, 14)
        iconTexture:SetPoint("LEFT", 6, 0)
        iconTexture:SetTexture(icon)
        button.icon = iconTexture

        buttonText:SetPoint("LEFT", iconTexture, "RIGHT", 4, 0)
        buttonText:SetPoint("RIGHT", -4, 0)
        buttonText:SetJustifyH("LEFT")
    else
        buttonText:SetPoint("CENTER", 0, 0)
    end
    buttonText:SetText(text)
    buttonText:SetTextColor(0.8, 0.8, 0.8, 1)
    button.text = buttonText

    button:SetScript("OnClick", function(self)
        BLU:PrintDebug("[Tabs] Clicked tab '" .. tostring(text) .. "' (" .. tostring(self.tabIndex) .. ")")
        panel:SelectTab(self.tabIndex)
    end)

    button:SetScript("OnEnter", function(self)
        BLU:PrintDebug("[Tabs] Hover enter on tab '" .. tostring(text) .. "'")
        if not self.isActive then
            self.border:SetBackdropBorderColor(unpack(BLU.Modules.design.Colors.Primary))
            self.text:SetTextColor(unpack(BLU.Modules.design.Colors.Primary))
        end
    end)

    button:SetScript("OnLeave", function(self)
        BLU:PrintDebug("[Tabs] Hover leave on tab '" .. tostring(text) .. "'")
        if not self.isActive then
            self.border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
            self.text:SetTextColor(0.7, 0.7, 0.7, 1)
        end
    end)

    button.tabIndex = index

    function button:SetActive(active)
        self.isActive = active
        if active then
            self.bg:SetColorTexture(0.11, 0.18, 0.24, 1)
            self.text:SetTextColor(unpack(BLU.Modules.design.Colors.Primary))
            self.border:SetBackdropBorderColor(unpack(BLU.Modules.design.Colors.Primary))
        else
            self.bg:SetColorTexture(0.08, 0.11, 0.15, 0.90)
            self.text:SetTextColor(0.7, 0.7, 0.7, 1)
            self.border:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
        end
    end

    return button
end

function Tabs:Init()
    BLU:PrintDebug("[Tabs] Initializing tab system (alpha.3 style)")
    
    -- Tab configuration - defined here so panel creation functions are available
    BLU.OptionsTabs = {
        -- Row 1: General first, then A-Z
        {text = "General",      create = BLU.CreateGeneralPanel, row = 1, col = 1, icon = "Interface\\Icons\\INV_Misc_Gear_08"},
        {text = "Achievement",  eventType = "achievement",       row = 1, col = 2, icon = "Interface\\Icons\\Achievement_Quests_Completed_08"},
        {text = "Battle Pets",  eventType = "battlepet",         row = 1, col = 3, icon = "Interface\\Icons\\INV_Pet_BattlePetTraining"},
        {text = "Delve",        eventType = "delvecompanion",    row = 1, col = 4, icon = "Interface\\Icons\\INV_Misc_Map_01"},
        {text = "Honor",        eventType = "honorrank",         row = 1, col = 5, icon = "Interface\\Icons\\PVPCurrency-Honor-Horde"},
        {text = "Housing",      create = BLU.CreateHousingPanel, row = 1, col = 6, icon = "Interface\\Icons\\Trade_Blacksmithing"},
        -- Row 2: A-Z continued, Sounds last
        {text = "Level Up",     eventType = "levelup",           row = 2, col = 1, icon = "Interface\\Icons\\Achievement_Level_100"},
        {text = "Quest",        eventType = "quest",             row = 2, col = 2, icon = "Interface\\Icons\\INV_Misc_Note_01"},
        {text = "Renown",       eventType = "renownrank",        row = 2, col = 3, icon = "Interface\\Icons\\UI_MajorFaction_Centaur"},
        {text = "Reputation",   eventType = "reputation",        row = 2, col = 4, icon = "Interface\\Icons\\Achievement_Reputation_01"},
        {text = "Trading Post", eventType = "tradingpost",       row = 2, col = 5, icon = "Interface\\Icons\\INV_Misc_Coin_02"},
        {text = "Sounds",       create = BLU.CreateSoundsPanel,  row = 2, col = 6, icon = "Interface\\Icons\\INV_Misc_Bell_01"},
    }
    
    BLU:PrintDebug("[Tabs] Registered " .. #BLU.OptionsTabs .. " tabs")
end

-- Register module
if BLU.RegisterModule then
    BLU:RegisterModule(Tabs, "tabs", "Tab System")
end
