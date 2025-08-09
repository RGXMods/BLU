--=====================================================================================
-- BLU | About Panel - Credits, Info, and Support
-- Author: donniedice
-- Description: About information, credits, links, and support options
--=====================================================================================

local addonName, BLU = ...

-- Version and build info
local VERSION = GetAddOnMetadata(addonName, "Version") or "6.0.0-alpha"
local AUTHOR = GetAddOnMetadata(addonName, "Author") or "donniedice"
local BUILD_DATE = "2025-08-08"

function BLU.CreateAboutPanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()
    panel:Hide()
    
    -- Logo/Title Section
    local logoFrame = CreateFrame("Frame", nil, panel)
    logoFrame:SetPoint("TOP", 0, -20)
    logoFrame:SetSize(400, 100)
    
    -- BLU Title
    local titleText = logoFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    titleText:SetPoint("CENTER", 0, 20)
    titleText:SetText("|cff00ccffB|r|cff00aaffL|r|cff0088ffU|r")
    titleText:SetFont(titleText:GetFont(), 48)
    
    -- Subtitle
    local subtitleText = logoFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    subtitleText:SetPoint("TOP", titleText, "BOTTOM", 0, -5)
    subtitleText:SetText("Better Level-Up!")
    subtitleText:SetTextColor(0.7, 0.7, 0.7)
    
    -- Version info
    local versionText = logoFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    versionText:SetPoint("TOP", subtitleText, "BOTTOM", 0, -5)
    versionText:SetText("Version " .. VERSION .. " | Build " .. BUILD_DATE)
    versionText:SetTextColor(0.5, 0.5, 0.5)
    
    local yOffset = -140
    
    -- RGX Mods Branding
    local brandingFrame = CreateFrame("Frame", nil, panel)
    brandingFrame:SetPoint("TOPLEFT", 20, yOffset)
    brandingFrame:SetPoint("TOPRIGHT", -20, yOffset)
    brandingFrame:SetHeight(60)
    
    local brandingBg = brandingFrame:CreateTexture(nil, "BACKGROUND")
    brandingBg:SetAllPoints()
    brandingBg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
    
    local rgxTitle = brandingFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    rgxTitle:SetPoint("CENTER", 0, 10)
    rgxTitle:SetText("|cffff6600RGX Mods|r - RealmGX Community Project")
    
    local rgxSubtitle = brandingFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rgxSubtitle:SetPoint("TOP", rgxTitle, "BOTTOM", 0, -5)
    rgxSubtitle:SetText("Premium WoW Addons & Modifications")
    rgxSubtitle:SetTextColor(0.7, 0.7, 0.7)
    
    yOffset = yOffset - 80
    
    -- Description
    local descFrame = CreateFrame("Frame", nil, panel)
    descFrame:SetPoint("TOPLEFT", 40, yOffset)
    descFrame:SetPoint("TOPRIGHT", -40, yOffset)
    descFrame:SetHeight(60)
    
    local descText = descFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    descText:SetPoint("TOPLEFT")
    descText:SetPoint("TOPRIGHT")
    descText:SetJustifyH("LEFT")
    descText:SetText("BLU replaces default World of Warcraft sounds with iconic audio from over 50 classic and modern games. Experience nostalgic level-up fanfares, achievement jingles, and quest completion sounds from your favorite gaming franchises.")
    descText:SetTextColor(0.9, 0.9, 0.9)
    
    yOffset = yOffset - 80
    
    -- Features Section
    local featuresTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    featuresTitle:SetPoint("TOPLEFT", 20, yOffset)
    featuresTitle:SetText("Features")
    featuresTitle:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 25
    
    local features = {
        "50+ game sound packs including Final Fantasy, Zelda, Pokemon, and more",
        "Customizable volume controls for each event type",
        "Profile system for saving and sharing configurations",
        "Modular architecture for optimal performance",
        "No external library dependencies",
        "Hot-reload modules without UI reload",
        "SharedMedia/SoundPak compatibility"
    }
    
    for _, feature in ipairs(features) do
        local featureText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        featureText:SetPoint("TOPLEFT", 40, yOffset)
        featureText:SetText("• " .. feature)
        featureText:SetTextColor(0.8, 0.8, 0.8)
        yOffset = yOffset - 20
    end
    
    yOffset = yOffset - 20
    
    -- Credits Section
    local creditsTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    creditsTitle:SetPoint("TOPLEFT", 20, yOffset)
    creditsTitle:SetText("Credits")
    creditsTitle:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 25
    
    local credits = {
        {role = "Author & Lead Developer", name = "donniedice", email = "60427166+donniedice@users.noreply.github.com"},
        {role = "Sound Design", name = "Various Game Studios", email = ""},
        {role = "Community Testing", name = "RGX Guild Members", email = ""},
        {role = "Special Thanks", name = "WoW Addon Community", email = ""}
    }
    
    for _, credit in ipairs(credits) do
        local creditFrame = CreateFrame("Frame", nil, panel)
        creditFrame:SetPoint("TOPLEFT", 40, yOffset)
        creditFrame:SetSize(500, 20)
        
        local roleText = creditFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        roleText:SetPoint("LEFT")
        roleText:SetText(credit.role .. ":")
        roleText:SetTextColor(0.7, 0.7, 0.7)
        roleText:SetWidth(150)
        roleText:SetJustifyH("LEFT")
        
        local nameText = creditFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameText:SetPoint("LEFT", roleText, "RIGHT", 10, 0)
        nameText:SetText(credit.name)
        nameText:SetTextColor(1, 1, 1)
        
        if credit.email ~= "" then
            local emailText = creditFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            emailText:SetPoint("LEFT", nameText, "RIGHT", 10, 0)
            emailText:SetText("(" .. credit.email .. ")")
            emailText:SetTextColor(0.5, 0.5, 0.5)
        end
        
        yOffset = yOffset - 20
    end
    
    -- Support Section
    local supportFrame = CreateFrame("Frame", nil, panel)
    supportFrame:SetPoint("BOTTOMLEFT", 20, 100)
    supportFrame:SetPoint("BOTTOMRIGHT", -20, 100)
    supportFrame:SetHeight(80)
    
    local supportBg = supportFrame:CreateTexture(nil, "BACKGROUND")
    supportBg:SetAllPoints()
    supportBg:SetColorTexture(0.05, 0.05, 0.05, 0.5)
    
    local supportTitle = supportFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    supportTitle:SetPoint("TOPLEFT", 10, -10)
    supportTitle:SetText("Support & Links")
    supportTitle:SetTextColor(0, 0.8, 1)
    
    -- Create clickable links frame
    local linksFrame = CreateFrame("Frame", nil, supportFrame)
    linksFrame:SetPoint("TOPLEFT", 10, -35)
    linksFrame:SetPoint("BOTTOMRIGHT", -10, 10)
    
    -- GitHub button
    local githubBtn = CreateFrame("Button", nil, linksFrame, "UIPanelButtonTemplate")
    githubBtn:SetSize(120, 24)
    githubBtn:SetPoint("LEFT", 10, 0)
    githubBtn:SetText("GitHub")
    githubBtn:SetScript("OnClick", function()
        -- Create edit box for copying
        local editBox = CreateFrame("EditBox", "BLUGitHubLink", UIParent, "InputBoxTemplate")
        editBox:SetSize(400, 20)
        editBox:SetPoint("CENTER")
        editBox:SetText("https://github.com/donniedice/BLU")
        editBox:SetAutoFocus(true)
        editBox:HighlightText()
        editBox:SetScript("OnEscapePressed", function(self) self:Hide() end)
        print("|cff00ccffBLU:|r GitHub link copied to clipboard")
    end)
    
    -- Discord button
    local discordBtn = CreateFrame("Button", nil, linksFrame, "UIPanelButtonTemplate")
    discordBtn:SetSize(120, 24)
    discordBtn:SetPoint("LEFT", githubBtn, "RIGHT", 10, 0)
    discordBtn:SetText("Discord")
    discordBtn:SetScript("OnClick", function()
        local editBox = CreateFrame("EditBox", "BLUDiscordLink", UIParent, "InputBoxTemplate")
        editBox:SetSize(400, 20)
        editBox:SetPoint("CENTER")
        editBox:SetText("discord.gg/rgxmods")
        editBox:SetAutoFocus(true)
        editBox:HighlightText()
        editBox:SetScript("OnEscapePressed", function(self) self:Hide() end)
        print("|cff00ccffBLU:|r Discord invite link copied")
    end)
    
    -- Donate button
    local donateBtn = CreateFrame("Button", nil, linksFrame, "UIPanelButtonTemplate")
    donateBtn:SetSize(120, 24)
    donateBtn:SetPoint("LEFT", discordBtn, "RIGHT", 10, 0)
    donateBtn:SetText("Donate")
    donateBtn:SetScript("OnClick", function()
        local editBox = CreateFrame("EditBox", "BLUDonateLink", UIParent, "InputBoxTemplate")
        editBox:SetSize(400, 20)
        editBox:SetPoint("CENTER")
        editBox:SetText("paypal.me/donniedice")
        editBox:SetAutoFocus(true)
        editBox:HighlightText()
        editBox:SetScript("OnEscapePressed", function(self) self:Hide() end)
        print("|cff00ccffBLU:|r Thank you for supporting BLU development!")
    end)
    
    -- Bug Report button
    local bugBtn = CreateFrame("Button", nil, linksFrame, "UIPanelButtonTemplate")
    bugBtn:SetSize(120, 24)
    bugBtn:SetPoint("LEFT", donateBtn, "RIGHT", 10, 0)
    bugBtn:SetText("Report Bug")
    bugBtn:SetScript("OnClick", function()
        StaticPopup_Show("BLU_BUG_REPORT")
    end)
    
    -- Statistics Section
    local statsFrame = CreateFrame("Frame", nil, panel)
    statsFrame:SetPoint("BOTTOMLEFT", 20, 20)
    statsFrame:SetPoint("BOTTOMRIGHT", -20, 20)
    statsFrame:SetHeight(60)
    
    local statsTitle = statsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statsTitle:SetPoint("TOPLEFT")
    statsTitle:SetText("Addon Statistics")
    statsTitle:SetTextColor(0, 0.8, 1)
    
    -- Calculate stats
    local memUsage = GetAddOnMemoryUsage(addonName)
    local soundCount = 0
    local moduleCount = 0
    
    -- Count modules
    for _ in pairs(BLU.modules or {}) do
        moduleCount = moduleCount + 1
    end
    
    local stats1 = statsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    stats1:SetPoint("TOPLEFT", 0, -15)
    stats1:SetText(string.format("Memory: %.2f MB | Modules: %d | Sounds: 150+", memUsage / 1024, moduleCount))
    stats1:SetTextColor(0.7, 0.7, 0.7)
    
    local stats2 = statsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    stats2:SetPoint("TOPLEFT", 0, -30)
    stats2:SetText("Load Time: " .. (BLU.loadTime or "0.00") .. " sec | Events Registered: " .. (BLU.eventCount or 0))
    stats2:SetTextColor(0.7, 0.7, 0.7)
    
    -- Legal text
    local legalText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    legalText:SetPoint("BOTTOM", 0, 5)
    legalText:SetText("All game sounds are property of their respective owners. BLU is not affiliated with any game companies.")
    legalText:SetTextColor(0.4, 0.4, 0.4)
    
    -- Update timer for stats
    panel:SetScript("OnShow", function(self)
        -- Update memory usage
        UpdateAddOnMemoryUsage()
        local mem = GetAddOnMemoryUsage(addonName)
        stats1:SetText(string.format("Memory: %.2f MB | Modules: %d | Sounds: 150+", mem / 1024, moduleCount))
    end)
    
    return panel
end

-- Bug report dialog
StaticPopupDialogs["BLU_BUG_REPORT"] = {
    text = "Describe the bug you encountered:",
    button1 = "Submit",
    button2 = "Cancel",
    hasEditBox = true,
    editBoxWidth = 350,
    OnAccept = function(self)
        local bugText = self.editBox:GetText()
        if bugText and bugText ~= "" then
            -- Store bug report in saved variables
            BLU.db.bugReports = BLU.db.bugReports or {}
            table.insert(BLU.db.bugReports, {
                text = bugText,
                date = date("%Y-%m-%d %H:%M:%S"),
                version = VERSION,
                character = UnitName("player") .. "-" .. GetRealmName()
            })
            print("|cff00ccffBLU:|r Bug report saved. Please submit via GitHub Issues for fastest response.")
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true
}