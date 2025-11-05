--=====================================================================================
-- BLU - interface/options/sounds.lua
-- Sound options panel
--=====================================================================================

local BLU = _G["BLU"]

function BLU.CreateSoundsPanel(panel)
    -- Content for the Sounds tab
    local content = panel

    local soundsText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    soundsText:SetPoint("TOPLEFT", 20, -20)
    soundsText:SetText("Sound Options")

    local soundsDescription = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    soundsDescription:SetPoint("TOPLEFT", soundsText, "BOTTOMLEFT", 0, -10)
    soundsDescription:SetWidth(660)
    soundsDescription:SetText("Configure the sounds that are played for each event. You can also set the volume for each sound.")

end