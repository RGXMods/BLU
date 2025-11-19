--=====================================================================================
-- BLU - interface/options/general.lua
-- General options panel
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

-- Create general panel
function BLU.CreateGeneralPanel(parent)
    BLU:PrintDebug("Creating General Panel...")

    local panel = CreateFrame("Frame", nil, parent)
    panel:SetPoint("TOPLEFT", 10, -10)
    panel:SetPoint("BOTTOMRIGHT", -10, 10)

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 0, 0)
    title:SetText("General Settings")
    title:SetTextColor(unpack(BLU.Modules.design.Colors.Primary))

    -- Placeholder content
    local description = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    description:SetJustifyH("LEFT")
    description:SetJustifyV("TOP")
    description:SetWidth(parent:GetWidth() - 20)
    description:SetText("This is the general settings panel. More options will be added here soon.")
    description:SetTextColor(0.7, 0.7, 0.7)

    return panel
end
