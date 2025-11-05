--=====================================================================================
-- BLU - interface/options/about.lua
-- About panel
--=====================================================================================

local BLU = _G["BLU"]

function BLU.CreateAboutPanel(panel)
    -- Content for the About tab
    local content = panel

    local aboutText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    aboutText:SetPoint("TOPLEFT", 20, -20)
    aboutText:SetText("Better Level-Up! v" .. BLU.version)

    local authorText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    authorText:SetPoint("TOPLEFT", aboutText, "BOTTOMLEFT", 0, -10)
    authorText:SetText("by donniedice")

    local descriptionText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    descriptionText:SetPoint("TOPLEFT", authorText, "BOTTOMLEFT", 0, -20)
    descriptionText:SetWidth(660)
    descriptionText:SetText("BLU replaces the default sounds for various events in World of Warcraft with iconic sounds from other games. You can configure which sounds are used for each event in the options panel.")

    local discordText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    discordText:SetPoint("TOPLEFT", descriptionText, "BOTTOMLEFT", 0, -20)
    discordText:SetText("Join the RGX Mods community on Discord: discord.gg/rgxmods")
end