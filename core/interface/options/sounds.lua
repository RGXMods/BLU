--=====================================================================================
-- BLU - interface/options/sounds.lua
-- Sound options panel
--=====================================================================================

local BLU = _G["BLU"]

local Sounds = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["sounds"] = Sounds

function BLU.CreateSoundsPanel(panel)
    -- Wipe existing content
    for _, child in ipairs({panel:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end

    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 5)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(680)
    scrollFrame:SetScrollChild(content)

    local header = BLU.Modules.design:CreateHeader(content, "Installed Sound Packs", "Interface\\Icons\\INV_Misc_Bag_33")
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("RIGHT", 0, 0)

    local yOffset = -40

    local function createPackEntry(parent, pack, y)
        local frame = CreateFrame("Frame", nil, parent)
        frame:SetSize(620, 40)
        frame:SetPoint("TOPLEFT", 10, y)

        local icon = frame:CreateTexture(nil, "ARTWORK")
        icon:SetSize(24, 24)
        icon:SetPoint("LEFT", 0, 0)
        icon:SetTexture(pack.icon or "Interface\\Icons\\INV_Misc_QuestionMark")

        local name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.name = name
        name:SetPoint("LEFT", icon, "RIGHT", 10, 5)
        name:SetText(pack.name or "Unknown Pack")

        local status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        status:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
        status:SetText(pack.status or "|cff00ff00Loaded|r")

        return frame
    end

    local packRows = {
        {
            id = "wow_default_blu",
            name = "wow default-blu",
            icon = "Interface\\Icons\\Achievement_General",
            status = "|cff05dffaBLU defaults|r",
            soundCount = 0,
        },
        {
            id = "other_games_blu",
            name = "other games-blu",
            icon = "Interface\\Icons\\INV_Misc_Bag_33",
            status = "|cff05dffaBLU game library|r",
            soundCount = 0,
        },
    }

    if BLU.SoundRegistry and BLU.SoundRegistry.GetAllSounds then
        local allSounds = BLU.SoundRegistry:GetAllSounds()
        for _, soundData in pairs(allSounds) do
            local isBluSound = soundData and (soundData.source == "BLU" or soundData.source == "BLU Built-in" or soundData.isInternal)
            if isBluSound then
                if soundData.packId == "blu_default" then
                    packRows[1].soundCount = packRows[1].soundCount + 1
                else
                    packRows[2].soundCount = packRows[2].soundCount + 1
                end
            end
        end
    end

    for _, pack in ipairs(packRows) do
        local frame = createPackEntry(content, pack, yOffset)
        frame.name:SetText(pack.name .. " (" .. pack.soundCount .. ")")
        yOffset = yOffset - 45
    end

    content:SetHeight(math.abs(yOffset) + 50)
end

function Sounds:Init()
    BLU:PrintDebug("[Sounds] Sounds panel module initialized")
end

if BLU.RegisterModule then
    BLU:RegisterModule(Sounds, "sounds", "Sounds Panel")
end
