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

local TAB_BUTTON_WIDTH_CORE = 94
local TAB_BUTTON_WIDTH_WIDE = 100
local TAB_BUTTON_HEIGHT = 22
local TAB_SPACING = 6
local TAB_ROW_PADDING = 8
local TAB_ROW_SPACING = 3
local TAB_COLUMNS_PER_ROW = 6

local function GetTabRowWidth()
    -- 1 core column + 5 wide columns + spacing + 16px gutter
    return TAB_BUTTON_WIDTH_CORE + (5 * TAB_BUTTON_WIDTH_WIDE) + (5 * TAB_SPACING) + 16
end

-- Generic "coming soon" placeholder panel — used by Combat, Collectibles, Loot, and Prey
local PLACEHOLDER_CONFIG = {
    Combat = {
        icon = "Interface\\Icons\\Ability_Warrior_Charge",
        body = "Combat-related sound triggers are planned for a future update. Likely coverage includes combat milestone triggers, proc-style notifications, and high-signal event moments.",
    },
    Collectibles = {
        icon = "Interface\\Icons\\INV_Misc_Toy_07",
        body = "Sound triggers for collectible milestones — mounts, pets, toys, transmog, and more — are planned for a future update. This placeholder tab reserves the category.",
    },
    Loot = {
        icon = "Interface\\Icons\\INV_Misc_Coin_02",
        body = "Loot-related sound triggers are planned for a future update. Likely coverage includes rare drops, boss loot, and other item acquisition events.",
    },
    Prey = {
        icon = "Interface\\Icons\\Ability_Hunter_MarkedForDeath",
        body = "Prey-system sound triggers are planned for a future update. This module will handle target-tracking and hunt-style progression events when the system is implemented.",
    },
}

local function CreateComingSoonPanel(panel, tabName)
    local cfg = PLACEHOLDER_CONFIG[tabName] or {
        icon = "Interface\\Icons\\INV_Misc_QuestionMark",
        body = "This module is planned for a future update. This placeholder tab reserves the category.",
    }

    local content = CreateFrame("Frame", nil, panel)
    content:SetPoint("TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    local titleBar = CreateFrame("Frame", nil, content, "BackdropTemplate")
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("RIGHT", 0, 0)
    titleBar:SetHeight(44)
    titleBar:SetBackdrop(BLU.Modules.design.Backdrops.Solid)
    titleBar:SetBackdropColor(0.06, 0.10, 0.16, 0.95)
    titleBar:SetBackdropBorderColor(0.10, 0.20, 0.28, 1)

    local icon = titleBar:CreateTexture(nil, "ARTWORK")
    icon:SetSize(24, 24)
    icon:SetPoint("LEFT", 10, 0)
    icon:SetTexture(cfg.icon)

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    title:SetText("|cff05dffa" .. tabName .. "|r")

    local section = BLU.Modules.design:CreateSection(content, "Coming Soon", "Interface\\Icons\\INV_Misc_Note_05")
    section:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, -10)
    section:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, -10)
    section:SetHeight(100)

    local body = section.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    body:SetPoint("TOPLEFT", 4, -4)
    body:SetPoint("RIGHT", -8, 0)
    body:SetJustifyH("LEFT")
    body:SetTextColor(0.82, 0.82, 0.82)
    body:SetText(cfg.body)
end

function Tabs:GetRowCount()
    local maxRow = 1
    if BLU.OptionsTabs then
        for _, tabInfo in ipairs(BLU.OptionsTabs) do
            if tabInfo.row and tabInfo.row > maxRow then
                maxRow = tabInfo.row
            end
        end
    end
    return maxRow
end

function Tabs:GetContainerHeight()
    return 6 + (self:GetRowCount() * TAB_BUTTON_HEIGHT) + ((self:GetRowCount() - 1) * TAB_ROW_SPACING) + 6
end

-- Create a tab button (alpha.3 style)
function BLU.CreateTabButton(parent, text, index, row, col, panel, icon)
    local buttonName = "BLUTab" .. tostring(index) .. text:gsub("%W", "")
    local button = CreateFrame("Button", buttonName, parent)
    button:SetSize(TAB_BUTTON_WIDTH_CORE, TAB_BUTTON_HEIGHT)
    button.tabRow = row
    button.tabCol = col
    button.isPlaceholder = false
    button:SetSize(TAB_BUTTON_WIDTH_CORE, TAB_BUTTON_HEIGHT)

    function button:UpdatePosition()
        local startX = TAB_ROW_PADDING
        local xOffset = startX
        local width = TAB_BUTTON_WIDTH_CORE

        if self.tabCol == 1 then
            xOffset = startX
            width = TAB_BUTTON_WIDTH_CORE
        else
            xOffset = startX + TAB_BUTTON_WIDTH_CORE + 16 + (self.tabCol - 2) * (TAB_BUTTON_WIDTH_WIDE + TAB_SPACING)
            width = TAB_BUTTON_WIDTH_WIDE
        end

        self:SetWidth(width)
        local yOffset = -6 - (self.tabRow - 1) * (TAB_BUTTON_HEIGHT + TAB_ROW_SPACING)
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
        if self.isPlaceholder then
            if active then
                self.bg:SetColorTexture(0.07, 0.08, 0.10, 0.90)
                self.text:SetTextColor(0.65, 0.72, 0.78, 1)
                self.border:SetBackdropBorderColor(unpack(BLU.Modules.design.Colors.Primary))
            else
                self.bg:SetColorTexture(0.05, 0.06, 0.08, 0.55)
                self.text:SetTextColor(0.42, 0.48, 0.52, 1)
                self.border:SetBackdropBorderColor(0.10, 0.14, 0.18, 1)
            end
            if self.icon then
                self.icon:SetDesaturated(true)
                self.icon:SetAlpha(active and 0.75 or 0.45)
            end
            return
        end
        if active then
            self.bg:SetColorTexture(0.11, 0.18, 0.24, 1)
            self.text:SetTextColor(unpack(BLU.Modules.design.Colors.Primary))
            self.border:SetBackdropBorderColor(unpack(BLU.Modules.design.Colors.Primary))
            if self.icon then
                self.icon:SetDesaturated(false)
                self.icon:SetAlpha(1)
            end
        else
            self.bg:SetColorTexture(0.08, 0.11, 0.15, 0.90)
            self.text:SetTextColor(0.7, 0.7, 0.7, 1)
            self.border:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
            if self.icon then
                self.icon:SetDesaturated(false)
                self.icon:SetAlpha(0.95)
            end
        end
    end

    function button:SetPlaceholder(placeholder)
        self.isPlaceholder = placeholder == true
        self:SetEnabled(true)
        self:SetActive(false)
    end

    return button
end

function Tabs:Init()
    BLU:PrintDebug("[Tabs] Initializing tab system (alpha.3 style)")
    
    -- Tab configuration - defined here so panel creation functions are available
    -- Helpers for coming-soon panels so each tab gets the same styled placeholder
    local function combatPanel(p)       CreateComingSoonPanel(p, "Combat")       end
    local function collectiblesPanel(p) CreateComingSoonPanel(p, "Collectibles") end
    local function lootPanel(p)         CreateComingSoonPanel(p, "Loot")         end
    local function preyPanel(p)         CreateComingSoonPanel(p, "Prey")         end

    BLU.OptionsTabs = {
        -- Row 1: Core management column 1
        -- Row 1
        {text = "General",      create = BLU.CreateGeneralPanel,  row = 1, col = 1, icon = "Interface\\Icons\\INV_Misc_Gear_08"},
        {text = "Achievement",  eventType = "achievement",    row = 1, col = 2, icon = "Interface\\Icons\\Achievement_Quests_Completed_08"},
        {text = "Battle Pets",  eventType = "battlepet",      row = 1, col = 3, icon = "Interface\\Icons\\INV_Pet_BattlePetTraining"},
        {text = "Collectibles", create = collectiblesPanel,   row = 1, col = 4, icon = "Interface\\Icons\\INV_Misc_Toy_07"},
        {text = "Combat",       create = combatPanel,         row = 1, col = 5, icon = "Interface\\Icons\\Ability_Warrior_Charge"},
        {text = "Delve",        eventType = "delvecompanion", row = 1, col = 6, icon = "Interface\\Icons\\INV_Misc_Map_01"},
        -- Row 2
        {text = "Debug",        create = BLU.CreateDebugPanel,    row = 2, col = 1, icon = "Interface\\Icons\\INV_Misc_Gear_03"},
        {text = "Honor",        eventType = "honorrank",           row = 2, col = 2, icon = "Interface\\Icons\\PVPCurrency-Honor-Horde"},
        {text = "Housing",      create = BLU.CreateHousingPanel,  row = 2, col = 3, icon = "Interface\\Icons\\Trade_Blacksmithing"},
        {text = "Level Up",     eventType = "levelup",             row = 2, col = 4, icon = "Interface\\Icons\\Achievement_Level_100"},
        {text = "Loot",         create = lootPanel,               row = 2, col = 5, icon = "Interface\\Icons\\INV_Misc_Coin_02"},
        {text = "Prey",         create = preyPanel,               row = 2, col = 6, icon = "Interface\\Icons\\Ability_Hunter_MarkedForDeath"},
        -- Row 3
        {text = "Profiles",     create = BLU.CreateProfilesPanel, row = 3, col = 1, icon = "Interface\\Icons\\Ability_Marksmanship"},
        {text = "Quest",        eventType = "quest",               row = 3, col = 2, icon = "Interface\\Icons\\INV_Misc_Note_01"},
        {text = "Renown",       eventType = "renownrank",          row = 3, col = 3, icon = "Interface\\Icons\\UI_MajorFaction_Centaur"},
        {text = "Reputation",   eventType = "reputation",          row = 3, col = 4, icon = "Interface\\Icons\\Achievement_Reputation_01"},
        {text = "Trading Post", eventType = "tradingpost",         row = 3, col = 5, icon = "Interface\\Icons\\INV_Misc_Coin_02"},
        {text = "Future 1",     placeholder = true,               row = 3, col = 6, icon = "Interface\\Icons\\INV_Misc_QuestionMark"},
        -- Row 4
        {text = "Sounds",       create = BLU.CreateSoundsPanel,   row = 4, col = 1, icon = "Interface\\Icons\\INV_Misc_Bell_01"},
        {text = "Future 2",     placeholder = true,               row = 4, col = 2, icon = "Interface\\Icons\\INV_Misc_QuestionMark"},
        {text = "Future 3",     placeholder = true,               row = 4, col = 3, icon = "Interface\\Icons\\INV_Misc_QuestionMark"},
        {text = "Future 4",     placeholder = true,               row = 4, col = 4, icon = "Interface\\Icons\\INV_Misc_QuestionMark"},
        {text = "Future 5",     placeholder = true,               row = 4, col = 5, icon = "Interface\\Icons\\INV_Misc_QuestionMark"},
        {text = "Future 6",     placeholder = true,               row = 4, col = 6, icon = "Interface\\Icons\\INV_Misc_QuestionMark"},
    }
    
    BLU:PrintDebug("[Tabs] Registered " .. #BLU.OptionsTabs .. " tabs")
end

-- Register module
if BLU.RegisterModule then
    BLU:RegisterModule(Tabs, "tabs", "Tab System")
end
