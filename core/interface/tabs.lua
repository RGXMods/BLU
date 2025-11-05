--=====================================================================================
-- BLU - interface/tabs.lua
-- Tab creation and management for the options panel
--=====================================================================================

local addonName, BLU = ...

function BLU:CreateTabs(panel)
    local tabContainer = CreateFrame("Frame", nil, panel)
    tabContainer:SetPoint("TOPLEFT", panel.header, "BOTTOMLEFT", 0, -2)
    tabContainer:SetPoint("TOPRIGHT", panel.header, "BOTTOMRIGHT", 0, -2)
    tabContainer:SetHeight(60) -- Height for two rows of tabs

    local tabBg = tabContainer:CreateTexture(nil, "BACKGROUND")
    tabBg:SetAllPoints()
    tabBg:SetColorTexture(0.03, 0.03, 0.03, 0.6)

    local tabs = {
        -- Row 1
        {text = "General", create = BLU.CreateGeneralPanel, row = 1, col = 1},
        {text = "Sounds", create = BLU.CreateSoundsPanel, row = 1, col = 2},
        {text = "Modules", create = BLU.CreateModulesPanel, row = 1, col = 3},
        {text = "About", create = BLU.CreateAboutPanel, row = 1, col = 4},
        {text = "Level Up", eventType = "levelup", row = 1, col = 5},
        {text = "Achievement", eventType = "achievement", row = 1, col = 6},
        {text = "Quest", eventType = "quest", row = 1, col = 7},
        -- Row 2
        {text = "Reputation", eventType = "reputation", row = 2, col = 1},
        {text = "Battle Pets", eventType = "battlepet", row = 2, col = 2},
        {text = "Honor", eventType = "honorrank", row = 2, col = 3},
        {text = "Renown", eventType = "renownrank", row = 2, col = 4},
        {text = "Trading Post", eventType = "tradingpost", row = 2, col = 5},
        {text = "Delve", eventType = "delvecompanion", row = 2, col = 6}
    }

    panel.tabs = {}
    panel.contents = {}

    for i, tabInfo in ipairs(tabs) do
        local tab = BLU:CreateTabButton(tabContainer, tabInfo.text, i, tabInfo.row, tabInfo.col, panel)
        panel.tabs[i] = tab

        local content = CreateFrame("Frame", nil, panel, "BackdropTemplate")
        content:SetPoint("TOPLEFT", tabContainer, "BOTTOMLEFT", 0, -10)
        content:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 10)
        content:SetBackdrop(BLU.Design.Backdrops.Dark)
        content:SetBackdropColor(0.06, 0.06, 0.06, 0.95)
        content:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
        content:Hide()

        if tabInfo.create then
            tabInfo.create(content)
        elseif tabInfo.eventType then
            BLU.CreateEventSoundPanel(content, tabInfo.eventType, tabInfo.text)
        end

        panel.contents[i] = content
    end

    function panel:SelectTab(index)
        for i, tab in ipairs(self.tabs) do
            tab:SetActive(i == index)
            self.contents[i]:SetShown(i == index)
        end
    end

    panel:SelectTab(1)
end

function BLU:CreateTabButton(parent, text, index, row, col, panel)
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
        edgeFile = "Interface\Buttons\WHITE8x8",
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
            self.border:SetBackdropBorderColor(unpack(BLU.Design.Colors.Primary))
            self.text:SetTextColor(unpack(BLU.Design.Colors.Primary))
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
            self.text:SetTextColor(unpack(BLU.Design.Colors.Primary))
            self.border:SetBackdropBorderColor(unpack(BLU.Design.Colors.Primary))
        else
            self.bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
            self.text:SetTextColor(0.7, 0.7, 0.7, 1)
            self.border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        end
    end

    return button
end

if BLU.RegisterModule then
    BLU:RegisterModule("tabs", BLU)
end
