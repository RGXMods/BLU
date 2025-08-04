--=====================================================================================
-- BLU - interface/panels/about.lua
-- About panel with credits and information
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateAboutPanel(panel)
    
    -- Logo/Icon area
    local icon = panel:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOP", 0, -20)
    icon:SetSize(64, 64)
    icon:SetTexture("Interface\\AddOns\\BLU\\media\\images\\icon")
    
    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", icon, "BOTTOM", 0, -10)
    title:SetText("Better Level-Up!")
    
    -- Version
    local version = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    version:SetPoint("TOP", title, "BOTTOM", 0, -5)
    version:SetText("Version " .. (BLU.version or BLU.VERSION or "v6.0.0-alpha"))
    version:SetTextColor(0.7, 0.7, 0.7)
    
    -- Author section
    local authorHeader = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    authorHeader:SetPoint("TOP", version, "BOTTOM", 0, -30)
    authorHeader:SetText("Created by")
    
    local author = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    author:SetPoint("TOP", authorHeader, "BOTTOM", 0, -5)
    author:SetText("DonnieDice")
    
    -- RGX Mods section
    local rgxHeader = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    rgxHeader:SetPoint("TOP", author, "BOTTOM", 0, -30)
    rgxHeader:SetText("An RGX Mods Project")
    rgxHeader:SetTextColor(0.02, 0.87, 1.0)
    
    local rgxDesc = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    rgxDesc:SetPoint("TOP", rgxHeader, "BOTTOM", 0, -5)
    rgxDesc:SetPoint("LEFT", 40, 0)
    rgxDesc:SetPoint("RIGHT", -40, 0)
    rgxDesc:SetJustifyH("CENTER")
    rgxDesc:SetText("Part of the RealmGX Community Project\nProviding quality addons for World of Warcraft")
    
    -- Links section
    local linksHeader = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    linksHeader:SetPoint("TOP", rgxDesc, "BOTTOM", 0, -30)
    linksHeader:SetText("Links")
    
    -- GitHub
    local github = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    github:SetPoint("TOP", linksHeader, "BOTTOM", 0, -10)
    github:SetText("GitHub: github.com/donniedice/BLU")
    
    -- Support
    local support = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    support:SetPoint("TOP", github, "BOTTOM", 0, -5)
    support:SetText("Support: 60427166+donniedice@users.noreply.github.com")
    
    -- Credits
    local creditsHeader = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    creditsHeader:SetPoint("TOP", support, "BOTTOM", 0, -30)
    creditsHeader:SetText("Special Thanks")
    
    local credits = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    credits:SetPoint("TOP", creditsHeader, "BOTTOM", 0, -10)
    credits:SetPoint("LEFT", 40, 0)
    credits:SetPoint("RIGHT", -40, 0)
    credits:SetJustifyH("CENTER")
    credits:SetText("All the game developers whose iconic sounds are featured\nThe WoW addon community for inspiration and support\nEveryone who has contributed feedback and suggestions")
    credits:SetTextColor(0.7, 0.7, 0.7)
end