--=====================================================================================
-- BLU - interface/panels/sounds_new.lua
-- Sound pack display panel showing installed packs
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

function BLU.CreateSoundsPanel(panel)
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 5)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(680)
    scrollFrame:SetScrollChild(content)
    
    local header = BLU.Design:CreateHeader(content, "Installed Sound Packs", "Interface\Icons\INV_Misc_Bag_33")
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("RIGHT", 0, 0)

    local yOffset = -40

    local function createPackEntry(parent, pack, x, y)
        local frame = CreateFrame("Frame", nil, parent)
        frame:SetSize(200, 40)
        frame:SetPoint("TOPLEFT", x, y)

        local icon = frame:CreateTexture(nil, "ARTWORK")
        icon:SetSize(24, 24)
        icon:SetPoint("LEFT", 0, 0)
        icon:SetTexture(pack.icon or "Interface\Icons\INV_Misc_QuestionMark")

        local name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("LEFT", icon, "RIGHT", 10, 5)
        name:SetText(pack.name)

        local status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        status:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
        status:SetText("|cff00ff00Loaded|r")
        status:SetTextColor(0,1,0)

        return frame
    end

    local packs = BLU.SoundRegistry:GetRegisteredPacks()
    local xOffset = 10
    local col = 0
    for _, pack in ipairs(packs) do
        createPackEntry(content, pack, xOffset + (col * 210), yOffset)
        col = col + 1
        if col >= 3 then
            col = 0
            yOffset = yOffset - 45
        end
    end

    content:SetHeight(math.abs(yOffset) + 50)
end
