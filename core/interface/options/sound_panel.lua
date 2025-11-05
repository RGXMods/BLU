--=====================================================================================
-- BLU - interface/options/sound_panel.lua
-- Sound selection panel for events
--=====================================================================================

local BLU = _G["BLU"]

function BLU.CreateEventSoundPanel(panel, eventType, eventName)
    -- Create scrollable content
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 5)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(680)
    scrollFrame:SetScrollChild(content)

    -- Event header
    local header = CreateFrame("Frame", nil, content)
    header:SetHeight(45)
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("RIGHT", 0, 0)

    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("LEFT", 0, 0)
    local icons = {
        levelup = "Interface\\Icons\\Achievement_Level_100",
        achievement = "Interface\\Icons\\Achievement_GuildPerk_MobileMailbox",
        quest = "Interface\\Icons\\INV_Misc_Note_01",
        reputation = "Interface\\Icons\\Achievement_Reputation_01",
        battlepet = "Interface\\Icons\\INV_Pet_BattlePetTraining",
        honorrank = "Interface\\Icons\\PVPCurrency-Honor-Horde",
        renownrank = "Interface\\Icons\\UI_MajorFaction_Renown",
        tradingpost = "Interface\\Icons\\INV_TradingPostCurrency",
        delvecompanion = "Interface\\Icons\\UI_MajorFaction_Delve"
    }
    icon:SetTexture(icons[eventType] or "Interface\\Icons\\INV_Misc_QuestionMark")

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    title:SetText("|cff" .. BLU.Modules.design.Colors.Primary:ToHex() .. eventName .. " Sounds|r")

    -- Module enable/disable section
    local moduleSection = BLU.Modules.design:CreateSection(content, "Module Control", "Interface\\Icons\\INV_Misc_Gear_08")
    moduleSection:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -10)
    moduleSection:SetPoint("RIGHT", -10, 0)
    moduleSection:SetHeight(140)

    -- Enable toggle
    local toggle = BLU.Modules.design:CreateCheckbox(moduleSection.content, "Enable " .. eventName .. " Module", "When enabled, BLU will respond to " .. eventName:lower() .. " events and play custom sounds")
    toggle:SetPoint("TOPLEFT", 20, -20)

    -- Sound selection section
    local soundSection = BLU.Modules.design:CreateSection(content, "Sound Selection", "Interface\\Icons\\INV_Misc_Bell_01")
    soundSection:SetPoint("TOPLEFT", moduleSection, "BOTTOMLEFT", 0, -10)
    soundSection:SetPoint("RIGHT", -20, 0)

    local sectionHeight = (eventType == "quest") and 260 or 150
    soundSection:SetHeight(sectionHeight)

    if eventType == "quest" then
        local questComplete = BLU.CreateSoundDropdown(soundSection.content, "quest_complete", "Quest Complete Sound", -20)
        local questProgress = BLU.CreateSoundDropdown(soundSection.content, "quest_progress", "Quest Progress Sound", -110)
    else
        local soundDropdown = BLU.CreateSoundDropdown(soundSection.content, eventType, eventName .. " Sound", -20)
    end

    local contentHeight = (eventType == "quest") and 450 or 400
    content:SetHeight(contentHeight)
end

function BLU.CreateSoundDropdown(parent, eventType, label, yOffset)
    local container = CreateFrame("Frame", nil, parent)
    container:SetPoint("TOPLEFT", 20, yOffset)
    container:SetSize(620, 90)

    local dropdownLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdownLabel:SetPoint("TOPLEFT", 0, 0)
    dropdownLabel:SetText(label)

    local dropdown = CreateFrame("Frame", nil, container, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", dropdownLabel, "BOTTOMLEFT", -20, -5)
    UIDropDownMenu_SetWidth(dropdown, 260)

    local testBtn = BLU.Modules.design:CreateStyledButton(container, "Test", 60, 22)
    testBtn:SetPoint("LEFT", dropdown, "RIGHT", 10, 0)

    local volumeDropdown = CreateFrame("Frame", nil, container, "UIDropDownMenuTemplate")
    volumeDropdown:SetPoint("LEFT", testBtn, "RIGHT", 10, 0)
    UIDropDownMenu_SetWidth(volumeDropdown, 120)

    -- Initialization logic for dropdowns, test button, and volume will be added here

    return container
end