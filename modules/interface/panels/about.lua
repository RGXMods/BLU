--=====================================================================================
-- BLU - interface/panels/about.lua
-- About panel with addon information and credits
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateAboutPanel(panel)
    local widgets = BLU.Widgets
    
    -- Create scrollable content
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth(), 700)
    scrollFrame:SetScrollChild(content)
    
    -- Large addon icon
    local icon = content:CreateTexture(nil, "ARTWORK")
    icon:SetSize(128, 128)
    icon:SetPoint("TOP", 0, -20)
    icon:SetTexture("Interface\\AddOns\\BLU\\media\\images\\icon")
    
    -- Title
    local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("TOP", icon, "BOTTOM", 0, -10)
    title:SetText("|cff05dffaBLU|r - Better Level-Up!")
    
    -- Version
    local version = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    version:SetPoint("TOP", title, "BOTTOM", 0, -5)
    version:SetText("Version " .. (BLU.version or "v5.3.0-alpha"))
    version:SetTextColor(0.7, 0.7, 0.7)
    
    -- Tagline
    local tagline = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    tagline:SetPoint("TOP", version, "BOTTOM", 0, -10)
    tagline:SetText("Play sounds from 50+ games when events fire in WoW!")
    
    -- Author section
    local authorHeader = widgets:CreateHeader(content, "|TInterface\\Icons\\Achievement_Character_Human_Male:20:20|t Author")
    authorHeader:SetPoint("TOP", tagline, "BOTTOM", 0, -30)
    
    local authorDivider = widgets:CreateDivider(content)
    authorDivider:SetPoint("TOPLEFT", authorHeader, "BOTTOMLEFT", 0, -5)
    authorDivider:SetPoint("RIGHT", content, "RIGHT", -20, 0)
    
    local authorInfo = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    authorInfo:SetPoint("TOP", authorDivider, "BOTTOM", 0, -10)
    authorInfo:SetText("Created by |cff05dffadonniedice|r\nEmail: 60427166+donniedice@users.noreply.github.com")
    authorInfo:SetJustifyH("CENTER")
    
    -- RGX Mods section
    local rgxHeader = widgets:CreateHeader(content, "|TInterface\\Icons\\VAS_RaceChange:20:20|t RGX Mods")
    rgxHeader:SetPoint("TOP", authorInfo, "BOTTOM", 0, -30)
    
    local rgxDivider = widgets:CreateDivider(content)
    rgxDivider:SetPoint("TOPLEFT", rgxHeader, "BOTTOMLEFT", 0, -5)
    rgxDivider:SetPoint("RIGHT", content, "RIGHT", -20, 0)
    
    local rgxInfo = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    rgxInfo:SetPoint("TOP", rgxDivider, "BOTTOM", 0, -10)
    rgxInfo:SetText("A |cffffd700RealmGX Community Project|r\nJoin our community at |cffffd700discord.gg/rgxmods|r")
    rgxInfo:SetJustifyH("CENTER")
    
    -- Features section
    local featuresHeader = widgets:CreateHeader(content, "|TInterface\\Icons\\Trade_Engineering:20:20|t Features")
    featuresHeader:SetPoint("TOP", rgxInfo, "BOTTOM", 0, -30)
    
    local featuresDivider = widgets:CreateDivider(content)
    featuresDivider:SetPoint("TOPLEFT", featuresHeader, "BOTTOMLEFT", 0, -5)
    featuresDivider:SetPoint("RIGHT", content, "RIGHT", -20, 0)
    
    -- Feature list
    local features = {
        "|TInterface\\Icons\\INV_Misc_Bell_01:16:16|t Over 50 game sound packs to choose from",
        "|TInterface\\Icons\\Achievement_Level_100:16:16|t Customizable sounds for every event type",
        "|TInterface\\Icons\\INV_Misc_Gear_08:16:16|t Modular system - enable only what you need",
        "|TInterface\\Icons\\Spell_ChargePositive:16:16|t Volume control and channel selection",
        "|TInterface\\Icons\\INV_Misc_Book_09:16:16|t SharedMedia compatibility for custom sounds",
        "|TInterface\\Icons\\Achievement_General:16:16|t Zero external dependencies",
        "|TInterface\\Icons\\Spell_Nature_TimeStop:16:16|t Optimized for performance"
    }
    
    local featureY = -10
    for _, feature in ipairs(features) do
        local featureText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        featureText:SetPoint("TOP", featuresDivider, "BOTTOM", 0, featureY)
        featureText:SetText(feature)
        featureText:SetJustifyH("LEFT")
        featureText:SetWidth(400)
        featureY = featureY - 20
    end
    
    -- Links section
    local linksHeader = widgets:CreateHeader(content, "|TInterface\\Icons\\INV_Misc_Web_01:20:20|t Links")
    linksHeader:SetPoint("TOP", featuresDivider, "BOTTOM", 0, featureY - 20)
    
    local linksDivider = widgets:CreateDivider(content)
    linksDivider:SetPoint("TOPLEFT", linksHeader, "BOTTOMLEFT", 0, -5)
    linksDivider:SetPoint("RIGHT", content, "RIGHT", -20, 0)
    
    -- Link buttons
    local linkY = -15
    local links = {
        {text = "GitHub Repository", url = "https://github.com/donniedice/BLU", icon = "Achievement_Profession_Fishing_FindFish"},
        {text = "Report Issues", url = "https://github.com/donniedice/BLU/issues", icon = "INV_Misc_Note_05"},
        {text = "CurseForge", url = "https://www.curseforge.com/wow/addons/blu", icon = "INV_Misc_Gem_Bloodstone_01"},
        {text = "Wago.io", url = "https://addons.wago.io/addons/blu", icon = "INV_Misc_Gem_Sapphire_01"},
        {text = "WoWInterface", url = "https://www.wowinterface.com/downloads/info26465", icon = "INV_Misc_Gem_Emerald_01"}
    }
    
    for _, link in ipairs(links) do
        local linkFrame = CreateFrame("Frame", nil, content)
        linkFrame:SetSize(300, 24)
        linkFrame:SetPoint("TOP", linksDivider, "BOTTOM", 0, linkY)
        
        local linkIcon = linkFrame:CreateTexture(nil, "ARTWORK")
        linkIcon:SetSize(20, 20)
        linkIcon:SetPoint("LEFT", 0, 0)
        linkIcon:SetTexture("Interface\\Icons\\" .. link.icon)
        
        local linkText = linkFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        linkText:SetPoint("LEFT", linkIcon, "RIGHT", 5, 0)
        linkText:SetText(link.text .. " - |cff05dffa" .. link.url .. "|r")
        
        linkY = linkY - 25
    end
    
    -- Support section
    local supportHeader = widgets:CreateHeader(content, "|TInterface\\Icons\\INV_Misc_Coin_01:20:20|t Support")
    supportHeader:SetPoint("TOP", linksDivider, "BOTTOM", 0, linkY - 20)
    
    local supportDivider = widgets:CreateDivider(content)
    supportDivider:SetPoint("TOPLEFT", supportHeader, "BOTTOMLEFT", 0, -5)
    supportDivider:SetPoint("RIGHT", content, "RIGHT", -20, 0)
    
    local supportInfo = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    supportInfo:SetPoint("TOP", supportDivider, "BOTTOM", 0, -10)
    supportInfo:SetText("If you enjoy BLU, please consider:\n• Starring the project on GitHub\n• Leaving a review on addon sites\n• Sharing with your friends\n• Reporting bugs and suggesting features")
    supportInfo:SetJustifyH("CENTER")
    supportInfo:SetWidth(400)
    
    -- Footer
    local footer = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    footer:SetPoint("BOTTOM", content, "BOTTOM", 0, 20)
    footer:SetText("Made with |cffff0000♥|r for the WoW community")
    footer:SetTextColor(0.5, 0.5, 0.5)
    
    content:SetHeight(700)
end