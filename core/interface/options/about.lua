--=====================================================================================
-- BLU - interface/options/about.lua
-- Housing panel
--=====================================================================================

local BLU = _G["BLU"]

local Housing = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["about"] = Housing
BLU.Modules["housing"] = Housing

local function CreateBulletList(parent, items, startY)
    BLU:PrintDebug("[Options/About] CreateBulletList called with " .. tostring(#items) .. " items")
    local yOffset = startY or -10
    for _, item in ipairs(items) do
        local text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("TOPLEFT", 20, yOffset)
        text:SetPoint("RIGHT", -20, 0)
        text:SetJustifyH("LEFT")
        text:SetText("* " .. item)
        yOffset = yOffset - 24
    end
    return yOffset
end

function BLU.CreateAboutPanel(panel)
    BLU:PrintDebug("[Options/About] Creating About panel")
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 8, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetPoint("TOPLEFT", 0, 0)
    content:SetPoint("TOPRIGHT", -8, 0)
    content:SetHeight(980)
    scrollFrame:SetScrollChild(content)

    local contentBg = content:CreateTexture(nil, "BACKGROUND")
    contentBg:SetAllPoints()
    contentBg:SetColorTexture(0.05, 0.05, 0.05, 0.3)

    local hero = CreateFrame("Frame", nil, content)
    hero:SetPoint("TOPLEFT", 0, 0)
    hero:SetPoint("RIGHT", 0, 0)
    hero:SetHeight(120)

    local heroBg = hero:CreateTexture(nil, "BACKGROUND")
    heroBg:SetAllPoints()
    heroBg:SetColorTexture(0.02, 0.37, 1, 0.1)

    local heroIcon = hero:CreateTexture(nil, "ARTWORK")
    heroIcon:SetSize(80, 80)
    heroIcon:SetPoint("LEFT", 20, 0)
    heroIcon:SetTexture("Interface\\Icons\\INV_11_Housing_Gold_Candelabra")

    local title = hero:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("LEFT", heroIcon, "RIGHT", 20, 15)
    title:SetText("|cff05dffaHousing|r")
    title:SetFont(title:GetFont(), 24)

    local subtitle = hero:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
    subtitle:SetText("Future support for housing-related progression and event sound triggers")
    subtitle:SetTextColor(0.8, 0.8, 0.8)

    local status = hero:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    status:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -6)
    status:SetText("|cffffd700Planning phase|r - trigger design and event mapping in progress")
    status:SetTextColor(0.9, 0.9, 0.9)

    local overviewSection = BLU.Modules.design:CreateSection(content, "Housing Direction", "Interface\\Icons\\INV_11_Housing_Gold_Candelabra")
    overviewSection:SetPoint("TOPLEFT", hero, "BOTTOMLEFT", 0, -BLU.Modules.design.Layout.Spacing)
    overviewSection:SetPoint("RIGHT", -BLU.Modules.design.Layout.Spacing, 0)
    overviewSection:SetHeight(170)

    local overviewText = overviewSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    overviewText:SetPoint("TOPLEFT", 10, -4)
    overviewText:SetPoint("RIGHT", -10, 0)
    overviewText:SetJustifyH("LEFT")
    overviewText:SetText(
        "BLU's Housing tab is reserved for the upcoming player-housing trigger set. " ..
        "The goal is to support meaningful home-related moments with the same per-event sound customization " ..
        "used across Level Up, Achievement, Reputation, and the other BLU modules."
    )

    local triggerSection = BLU.Modules.design:CreateSection(content, "Planned Trigger Types", "Interface\\Icons\\Ability_Repair")
    triggerSection:SetPoint("TOPLEFT", overviewSection, "BOTTOMLEFT", 0, -BLU.Modules.design.Layout.Spacing)
    triggerSection:SetPoint("RIGHT", -BLU.Modules.design.Layout.Spacing, 0)
    triggerSection:SetHeight(220)

    CreateBulletList(triggerSection.content, {
        "|cff05dffaPlot unlocks and first-time access|r",
        "|cff05dffaRoom, wing, or feature upgrades|r",
        "|cff05dffaMajor decoration, trophy, or collectible placement milestones|r",
        "|cff05dffaVisitor, companion, or housing NPC progression moments|r",
        "|cff05dffaProfession and utility station unlocks tied to housing|r",
        "|cff05dffaSpecial housing achievements or prestige-style progress events|r",
    }, -10)

    local designSection = BLU.Modules.design:CreateSection(content, "Implementation Notes", "Interface\\Icons\\INV_Misc_Note_05")
    designSection:SetPoint("TOPLEFT", triggerSection, "BOTTOMLEFT", 0, -BLU.Modules.design.Layout.Spacing)
    designSection:SetPoint("RIGHT", -BLU.Modules.design.Layout.Spacing, 0)
    designSection:SetHeight(180)

    CreateBulletList(designSection.content, {
        "Confirm Blizzard housing APIs and event names once they are stable on live/beta clients.",
        "Map housing triggers into BLU's existing registry so the Sounds tab can reuse the same pack picker flow.",
        "Keep housing event sounds isolated by trigger type instead of collapsing everything into one generic event.",
        "Add safe fallback handling for clients/builds where housing systems are unavailable.",
    }, -10)

    local communitySection = BLU.Modules.design:CreateSection(content, "Feedback & Community", "Interface\\Icons\\INV_Misc_GroupNeedMore")
    communitySection:SetPoint("TOPLEFT", designSection, "BOTTOMLEFT", 0, -BLU.Modules.design.Layout.Spacing)
    communitySection:SetPoint("RIGHT", -BLU.Modules.design.Layout.Spacing, 0)
    communitySection:SetHeight(120)

    local communityText = communitySection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    communityText:SetPoint("TOPLEFT", 10, -4)
    communityText:SetPoint("RIGHT", -10, 0)
    communityText:SetJustifyH("LEFT")
    communityText:SetText(
        "Want a specific housing trigger in BLU? Share it in |cffffd700discord.gg/rgxmods|r " ..
        "so we can prioritize the events that will feel best in regular play."
    )
end

function Housing:Init()
    BLU:PrintDebug("[Options/About] About panel module initialized")
end

if BLU.RegisterModule then
    BLU:RegisterModule(Housing, "about", "Housing Panel")
end
