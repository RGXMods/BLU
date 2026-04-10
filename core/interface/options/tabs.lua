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

local COMBAT_TRIGGER_PAGES = {
    {
        {
            title = "Combat Start",
            sound = "BLU Defaults",
            volume = "Medium",
        },
        {
            title = "Combat End",
            sound = "Final Fantasy",
            volume = "Low",
        },
        {
            title = "Low Health",
            sound = "Alarm Bell",
            volume = "High",
        },
        {
            title = "Execute Window",
            sound = "Warcraft 3",
            volume = "Medium",
        },
        {
            title = "Interrupt Ready",
            sound = "SharedMedia Pack",
            volume = "Medium",
        },
        {
            title = "Rare Enemy Tagged",
            sound = "Elden Ring",
            volume = "High",
        },
        {
            title = "Target Kill",
            sound = "User Custom",
            volume = "Medium",
        },
        {
            title = "Major Cooldown Ready",
            sound = "Pokemon",
            volume = "Low",
        },
    },
    {
        {
            title = "Proc Trigger",
            sound = "BLU Defaults",
            volume = "Medium",
        },
        {
            title = "Defensive Ready",
            sound = "Zelda",
            volume = "Low",
        },
        {
            title = "Enemy Cast Started",
            sound = "Kirby",
            volume = "Medium",
        },
        {
            title = "Enemy Cast Interruptible",
            sound = "Diablo 2",
            volume = "High",
        },
        {
            title = "Boss Engage",
            sound = "SharedMedia Pack",
            volume = "High",
        },
        {
            title = "Boss Defeated",
            sound = "Final Fantasy",
            volume = "Medium",
        },
        {
            title = "Add Spawn",
            sound = "Mario",
            volume = "Medium",
        },
        {
            title = "Execute Refresh",
            sound = "User Custom",
            volume = "Low",
        },
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

local function CreateCombatPrototypePanel(panel)
    local content = CreateFrame("Frame", nil, panel)
    content:SetPoint("TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    BLU._combatTabState = BLU._combatTabState or {page = 1}
    local state = BLU._combatTabState
    local totalPages = #COMBAT_TRIGGER_PAGES

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
    icon:SetTexture("Interface\\Icons\\Ability_Warrior_Charge")

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    title:SetText("|cff05dffaCombat|r")

    local introSection = BLU.Modules.design:CreateSection(content, "Combat Prototype", "Interface\\Icons\\INV_Misc_Note_05")
    introSection:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, -10)
    introSection:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, -10)
    introSection:SetHeight(78)

    local intro = introSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    intro:SetPoint("TOPLEFT", 4, -4)
    intro:SetPoint("RIGHT", -8, 0)
    intro:SetJustifyH("LEFT")
    intro:SetWordWrap(true)
    intro:SetTextColor(0.82, 0.82, 0.82)
    intro:SetText("This tab is a visual test bed for future combat settings. The goal here is to compare direct combat cue options, dedicated combat music controls, and a compact paged trigger layout before module logic is built.")

    local function CreateCompactMockRow(parent, x, y, titleText, soundText, volumeText, tooltipText)
        local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        row:SetPoint("TOPLEFT", x, y)
        row:SetHeight(74)
        row:SetBackdrop(BLU.Modules.design.Backdrops.Solid)
        row:SetBackdropColor(0.08, 0.11, 0.15, 0.92)
        row:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)

        local rowTitle = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        rowTitle:SetPoint("TOPLEFT", 10, -8)
        rowTitle:SetPoint("RIGHT", -10, 0)
        rowTitle:SetJustifyH("LEFT")
        rowTitle:SetText(titleText)

        local fakeDropdown = CreateFrame("Button", nil, row, "BackdropTemplate")
        fakeDropdown:SetPoint("TOPLEFT", rowTitle, "BOTTOMLEFT", 0, -8)
        fakeDropdown:SetSize(146, 22)
        fakeDropdown:SetBackdrop(BLU.Modules.design.Backdrops.Button)
        fakeDropdown:SetBackdropColor(0.10, 0.14, 0.19, 0.96)
        fakeDropdown:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
        fakeDropdown:RegisterForClicks("LeftButtonUp")

        local dropdownText = fakeDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        dropdownText:SetPoint("LEFT", 8, 0)
        dropdownText:SetPoint("RIGHT", -18, 0)
        dropdownText:SetJustifyH("LEFT")
        dropdownText:SetTextColor(0.84, 0.84, 0.84, 1)
        dropdownText:SetText(soundText or "Select Sound")

        local dropdownArrow = fakeDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        dropdownArrow:SetPoint("RIGHT", -6, 0)
        dropdownArrow:SetText("v")
        dropdownArrow:SetTextColor(0.70, 0.78, 0.86, 1)

        local soundChoices = {
            "BLU Defaults",
            "Final Fantasy",
            "Warcraft 3",
            "SharedMedia Pack",
            "User Custom",
            "Pokemon",
            "Elden Ring",
            "Zelda",
            "Kirby",
            "Diablo 2",
            "Mario",
        }
        local selectedSound = soundText or soundChoices[1]

        local volumeLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        volumeLabel:SetPoint("BOTTOMLEFT", row, "TOPLEFT", 170, -28)
        volumeLabel:SetTextColor(0.70, 0.78, 0.86)
        volumeLabel:SetText(volumeText or "Medium")

        local slider = CreateFrame("Slider", nil, row)
        slider:SetPoint("LEFT", fakeDropdown, "RIGHT", 16, 0)
        slider:SetSize(64, 16)
        slider:SetMinMaxValues(1, 3)
        slider:SetValueStep(1)
        slider:SetObeyStepOnDrag(true)

        local sliderTrack = row:CreateTexture(nil, "ARTWORK")
        sliderTrack:SetSize(64, 4)
        sliderTrack:SetPoint("CENTER", slider, "CENTER", 0, 0)
        sliderTrack:SetColorTexture(0.14, 0.20, 0.28, 1)

        local sliderFill = row:CreateTexture(nil, "ARTWORK")
        sliderFill:SetHeight(4)
        sliderFill:SetPoint("LEFT", sliderTrack, "LEFT", 0, 0)
        sliderFill:SetColorTexture(unpack(BLU.Modules.design.Colors.Primary))

        local fillWidth = 28
        if volumeText == "Low" then
            fillWidth = 18
        elseif volumeText == "High" then
            fillWidth = 56
        end
        sliderFill:SetWidth(fillWidth)

        local sliderThumb = row:CreateTexture(nil, "ARTWORK")
        sliderThumb:SetSize(8, 8)
        sliderThumb:SetTexture("Interface\\Buttons\\WHITE8x8")
        sliderThumb:SetVertexColor(1, 1, 1, 1)

        local testButton = BLU.Modules.design:CreateActionButton(
            row,
            "Test",
            46,
            20,
            "Prototype Test Button",
            tooltipText or "Visual placeholder only. This row is for layout testing."
        )
        testButton:SetPoint("LEFT", slider, "RIGHT", 16, 0)

        local function applyVolume(step)
            local normalized = math.max(1, math.min(3, math.floor((step or 2) + 0.5)))
            local label = "Medium"
            local width = 28
            if normalized == 1 then
                label = "Low"
                width = 18
            elseif normalized == 3 then
                label = "High"
                width = 56
            end

            sliderFill:SetWidth(width)
            sliderThumb:ClearAllPoints()
            sliderThumb:SetPoint("CENTER", sliderTrack, "LEFT", width, 0)
            volumeLabel:SetText(label)
            slider:SetValue(normalized)
        end

        local dropdownMenu = CreateFrame("Frame", nil, row, "UIDropDownMenuTemplate")
        dropdownMenu.displayMode = "MENU"
        dropdownMenu.initialize = function(self, level)
            local info = UIDropDownMenu_CreateInfo()
            for _, choice in ipairs(soundChoices) do
                info = UIDropDownMenu_CreateInfo()
                info.text = choice
                info.checked = (choice == selectedSound)
                info.func = function()
                    selectedSound = choice
                    dropdownText:SetText(choice)
                    CloseDropDownMenus()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end

        fakeDropdown:SetScript("OnClick", function(self)
            ToggleDropDownMenu(1, nil, dropdownMenu, self, 0, 0)
        end)

        fakeDropdown:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(unpack(BLU.Modules.design.Colors.Primary))
        end)
        fakeDropdown:SetScript("OnLeave", function(self)
            self:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
        end)

        slider:SetScript("OnMouseDown", function(self)
            local minVal, maxVal = self:GetMinMaxValues()
            local cursorX = GetCursorPosition()
            local effectiveScale = self:GetEffectiveScale()
            local left = self:GetLeft() * effectiveScale
            local width = self:GetWidth() * effectiveScale
            local percent = 0
            if width > 0 then
                percent = (cursorX - left) / width
            end
            local value = minVal + ((maxVal - minVal) * percent)
            applyVolume(value)
        end)
        slider:SetScript("OnMouseWheel", function(self, delta)
            applyVolume((self:GetValue() or 2) + delta)
        end)
        slider:EnableMouseWheel(true)

        applyVolume((volumeText == "Low" and 1) or (volumeText == "High" and 3) or 2)

        function row:SetMockData(trigger)
            trigger = trigger or {}
            rowTitle:SetText(trigger.title or titleText or "")
            selectedSound = trigger.sound or soundText or soundChoices[1]
            dropdownText:SetText(selectedSound)
            applyVolume((trigger.volume == "Low" and 1) or (trigger.volume == "High" and 3) or 2)
        end

        row:SetMockData({
            title = titleText,
            sound = soundText,
            volume = volumeText,
        })

        return row
    end

    local topGrid = CreateFrame("Frame", nil, content)
    topGrid:SetPoint("TOPLEFT", introSection, "BOTTOMLEFT", 0, -10)
    topGrid:SetPoint("TOPRIGHT", introSection, "BOTTOMRIGHT", 0, -10)
    topGrid:SetHeight(214)

    local cuesSection = BLU.Modules.design:CreateSection(topGrid, "Combat Cues", "Interface\\Icons\\Ability_Rogue_Sprint")
    cuesSection:SetPoint("TOPLEFT", 0, 0)
    cuesSection:SetPoint("BOTTOMLEFT", 0, 0)
    cuesSection:SetPoint("RIGHT", topGrid, "CENTER", -5, 0)

    local cuesNote = cuesSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    cuesNote:SetPoint("TOPLEFT", 4, -4)
    cuesNote:SetPoint("RIGHT", -8, 0)
    cuesNote:SetJustifyH("LEFT")
    cuesNote:SetWordWrap(true)
    cuesNote:SetTextColor(0.78, 0.82, 0.88)
    cuesNote:SetText("One-shot sounds that fire at a combat boundary. This is the clearest place for separate start and end cues.")

    local cueStartRow = CreateCompactMockRow(
        cuesSection.content,
        4,
        -44,
        "Combat Start Sound",
        "BLU Defaults",
        "Medium",
        "Placeholder for a one-shot sound that plays once when combat starts."
    )
    cueStartRow:SetPoint("RIGHT", cuesSection.content, "RIGHT", -4, 0)

    local cueEndRow = CreateCompactMockRow(
        cuesSection.content,
        4,
        -126,
        "Combat End Sound",
        "Final Fantasy",
        "Low",
        "Placeholder for a one-shot sound that plays once when combat ends."
    )
    cueEndRow:SetPoint("RIGHT", cuesSection.content, "RIGHT", -4, 0)

    local musicSection = BLU.Modules.design:CreateSection(topGrid, "Combat Music", "Interface\\Icons\\INV_Misc_Bag_10_Black")
    musicSection:SetPoint("TOPLEFT", topGrid, "TOP", 5, 0)
    musicSection:SetPoint("BOTTOMRIGHT", topGrid, "BOTTOMRIGHT", 0, 0)

    local musicNote = musicSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    musicNote:SetPoint("TOPLEFT", 4, -4)
    musicNote:SetPoint("RIGHT", -8, 0)
    musicNote:SetJustifyH("LEFT")
    musicNote:SetWordWrap(true)
    musicNote:SetTextColor(0.78, 0.82, 0.88)
    musicNote:SetText("Persistent combat music should likely live as its own system instead of being mixed into normal one-shot triggers.")

    local musicTrackRow = CreateCompactMockRow(
        musicSection.content,
        4,
        -44,
        "Combat Music Track",
        "SharedMedia Pack",
        "Medium",
        "Placeholder for selecting the looping combat music track."
    )
    musicTrackRow:SetPoint("RIGHT", musicSection.content, "RIGHT", -4, 0)

    local musicState = musicSection.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    musicState:SetPoint("TOPLEFT", musicTrackRow, "BOTTOMLEFT", 2, -8)
    musicState:SetPoint("RIGHT", musicSection.content, "RIGHT", -8, 0)
    musicState:SetJustifyH("LEFT")
    musicState:SetTextColor(0.70, 0.78, 0.86)
    musicState:SetText("Placeholder behavior: start on combat begin, stop on combat end, with room later for fades, boss-only filters, or instance-only rules.")

    local futureSection = BLU.Modules.design:CreateSection(content, "Future Trigger Paging", "Interface\\Icons\\Ability_Warrior_Charge")
    futureSection:SetPoint("TOPLEFT", topGrid, "BOTTOMLEFT", 0, -10)
    futureSection:SetPoint("TOPRIGHT", topGrid, "BOTTOMRIGHT", 0, -10)
    futureSection:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 0, 0)
    futureSection:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 0)

    local futureNote = futureSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    futureNote:SetPoint("TOPLEFT", 4, -4)
    futureNote:SetPoint("RIGHT", -190, 0)
    futureNote:SetJustifyH("LEFT")
    futureNote:SetWordWrap(true)
    futureNote:SetTextColor(0.78, 0.82, 0.88)
    futureNote:SetText("This area is for the broader combat-trigger catalog. It keeps the compact 2-column layout so we can test fitting up to 8 options on a single page.")

    local pageLabel = futureSection.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    pageLabel:SetPoint("TOPRIGHT", -126, -6)
    pageLabel:SetTextColor(0.70, 0.78, 0.86)

    local prevButton = BLU.Modules.design:CreateActionButton(
        futureSection.content,
        "Prev",
        56,
        20,
        "Previous Page",
        "Show the previous set of combat trigger options."
    )
    prevButton:SetPoint("TOPRIGHT", -66, -2)

    local nextButton = BLU.Modules.design:CreateActionButton(
        futureSection.content,
        "Next",
        56,
        20,
        "Next Page",
        "Show the next set of combat trigger options."
    )
    nextButton:SetPoint("TOPRIGHT", -6, -2)

    local triggerRows = {}
    local rowAnchorParent = futureSection.content
    local rowStartY = -74
    local rowHeight = 74
    local rowGap = 10
    local columnGap = 10
    local columnWidth = 0

    for index = 1, 8 do
        local visualRow = math.floor((index - 1) / 2)
        local row = CreateCompactMockRow(
            rowAnchorParent,
            0,
            rowStartY - (visualRow * (rowHeight + rowGap)),
            "",
            "BLU Defaults",
            "Medium",
            "Visual placeholder for how a compact event-row test button would fit in this layout."
        )

        triggerRows[index] = {
            frame = row,
        }
    end

    local function updateRowWidths()
        local availableWidth = rowAnchorParent:GetWidth()
        if not availableWidth or availableWidth <= 0 then
            availableWidth = panel:GetWidth() or 640
        end

        columnWidth = math.floor((availableWidth - columnGap) / 2)
        if columnWidth < 260 then
            columnWidth = 260
        end

        for index, row in ipairs(triggerRows) do
            local column = ((index - 1) % 2)
            local xOffset = column == 0 and 0 or (columnWidth + columnGap)
            row.frame:ClearAllPoints()
            row.frame:SetPoint("TOPLEFT", xOffset, rowStartY - (math.floor((index - 1) / 2) * (rowHeight + rowGap)))
            row.frame:SetWidth(columnWidth)
        end
    end

    local function renderPage()
        if state.page < 1 then
            state.page = 1
        elseif state.page > totalPages then
            state.page = totalPages
        end

        local page = COMBAT_TRIGGER_PAGES[state.page] or {}
        pageLabel:SetText(string.format("Page %d of %d", state.page, totalPages))

        for index, row in ipairs(triggerRows) do
            local trigger = page[index]
            if trigger then
                row.frame:Show()
                row.frame:SetMockData(trigger)
            else
                row.frame:Hide()
            end
        end

        if state.page <= 1 then
            prevButton:Disable()
            if prevButton.label then
                prevButton.label:SetTextColor(0.45, 0.45, 0.45, 1)
            end
        else
            prevButton:Enable()
            if prevButton.label then
                prevButton.label:SetTextColor(0.80, 0.80, 0.80, 1)
            end
        end

        if state.page >= totalPages then
            nextButton:Disable()
            if nextButton.label then
                nextButton.label:SetTextColor(0.45, 0.45, 0.45, 1)
            end
        else
            nextButton:Enable()
            if nextButton.label then
                nextButton.label:SetTextColor(0.80, 0.80, 0.80, 1)
            end
        end
    end

    prevButton:SetScript("OnClick", function()
        state.page = math.max(1, state.page - 1)
        renderPage()
    end)

    nextButton:SetScript("OnClick", function()
        state.page = math.min(totalPages, state.page + 1)
        renderPage()
    end)

    renderPage()
    updateRowWidths()
    rowAnchorParent:HookScript("OnSizeChanged", updateRowWidths)
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
    local function combatPanel(p)
        if BLU.CreateCombatPanel then
            BLU.CreateCombatPanel(p)
        else
            CreateComingSoonPanel(p, "Combat")
        end
    end
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
