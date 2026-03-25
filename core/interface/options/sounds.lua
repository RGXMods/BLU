--=====================================================================================
-- BLU - interface/options/sounds.lua
-- Sound options panel
--=====================================================================================

local BLU = _G["BLU"]

local Sounds = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["sounds"] = Sounds

local function GetAddonIconTexture(addonName)
    if not addonName or addonName == "" then
        return nil
    end

    if C_AddOns and C_AddOns.GetAddOnMetadata then
        local icon = C_AddOns.GetAddOnMetadata(addonName, "IconTexture")
        if type(icon) == "string" and icon ~= "" then
            return icon
        end
    elseif GetAddOnMetadata then
        local icon = GetAddOnMetadata(addonName, "IconTexture")
        if type(icon) == "string" and icon ~= "" then
            return icon
        end
    end

    return nil
end

function BLU.RefreshSoundPackUI()
    if not BLU.OptionsPanel or not BLU.OptionsPanel.contents then
        return false
    end

    local soundsContent = BLU.OptionsPanel.contents[2]
    if not soundsContent or not soundsContent:IsShown() then
        return false
    end

    if not BLU.CreateSoundsPanel then
        return false
    end

    local ok, err = pcall(BLU.CreateSoundsPanel, soundsContent)
    if not ok then
        BLU:PrintDebug("Failed to rebuild Sounds tab: " .. tostring(err))
        return false
    end

    return true
end

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

    local startY = -40
    local rowsPerColumn = 9
    local maxColumns = 2
    local columnXStart = 10
    local columnWidth = 312
    local columnSpacing = 16
    local rowStep = 45
    local blockSpacing = 18

    local function createPackEntry(parent, pack, x, y)
        local frame = CreateFrame("Frame", nil, parent)
        frame:SetSize(columnWidth, 40)
        frame:SetPoint("TOPLEFT", x, y)

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
            icon = "Interface\\AddOns\\BLU\\media\\Textures\\icon.tga",
            status = "|cff05dffaBLU defaults|r",
            soundCount = 0,
        },
        {
            id = "other_games_blu",
            name = "other games-blu",
            icon = "Interface\\AddOns\\BLU\\media\\Textures\\icon.tga",
            status = "|cff05dffaBLU game library|r",
            soundCount = 0,
        },
        {
            id = "user_custom_sounds",
            name = "user custom sounds",
            icon = "Interface\\Icons\\INV_Misc_Coin_18",
            status = "|cffffaa00Drop custom01-custom24 into AddOns or AddOns\\sounds|r",
            soundCount = 0,
        },
    }

    local sharedMediaPacks = {}

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
            elseif soundData and soundData.source == "UserCustom" then
                packRows[3].soundCount = packRows[3].soundCount + 1
                packRows[3].status = "|cff00ff00Loaded|r"
            elseif soundData and soundData.source == "SharedMedia" then
                local packId = soundData.packId or soundData.packName or "SharedMedia"
                local packName = soundData.packName or soundData.packId or "SharedMedia"

                if not sharedMediaPacks[packId] then
                    sharedMediaPacks[packId] = {
                        id = "sharedmedia_" .. tostring(packId),
                        name = packName,
                        icon = GetAddonIconTexture(packId) or "Interface\\Icons\\INV_Misc_Book_11",
                        status = "|cff00ff00SharedMedia loaded|r",
                        soundCount = 0,
                    }
                end

                sharedMediaPacks[packId].soundCount = sharedMediaPacks[packId].soundCount + 1
            end
        end
    end

    local sharedRows = {}
    for _, row in pairs(sharedMediaPacks) do
        table.insert(sharedRows, row)
    end
    table.sort(sharedRows, function(a, b)
        return string.lower(a.name) < string.lower(b.name)
    end)

    for _, row in ipairs(sharedRows) do
        table.insert(packRows, row)
    end

    if #sharedRows == 0 then
        table.insert(packRows, {
            id = "sharedmedia_none",
            name = "shared media packs",
            icon = "Interface\\Icons\\INV_Misc_Book_11",
            status = "|cffffaa00No SharedMedia packs loaded|r",
            soundCount = 0,
        })
    end

    for index, pack in ipairs(packRows) do
        local zeroIndex = index - 1
        local entriesPerBlock = rowsPerColumn * maxColumns
        local blockIndex = math.floor(zeroIndex / entriesPerBlock)
        local indexInBlock = zeroIndex % entriesPerBlock
        local columnIndex = math.floor(indexInBlock / rowsPerColumn)
        local rowIndex = indexInBlock % rowsPerColumn

        local xOffset = columnXStart + (columnIndex * (columnWidth + columnSpacing))
        local yOffset = startY - (rowIndex * rowStep) - (blockIndex * ((rowsPerColumn * rowStep) + blockSpacing))

        local frame = createPackEntry(content, pack, xOffset, yOffset)
        frame.name:SetText(pack.name .. " (" .. pack.soundCount .. ")")
    end

    local entriesPerBlock = rowsPerColumn * maxColumns
    local blockCount = math.max(1, math.ceil(#packRows / entriesPerBlock))
    local totalHeight = math.abs(startY) + (blockCount * (rowsPerColumn * rowStep)) + ((blockCount - 1) * blockSpacing) + 50
    content:SetHeight(totalHeight)
end

function Sounds:Init()
    BLU:PrintDebug("[Sounds] Sounds panel module initialized")
end

if BLU.RegisterModule then
    BLU:RegisterModule(Sounds, "sounds", "Sounds Panel")
end
