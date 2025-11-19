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

    local function createPackEntry(parent, pack, x, y)
        local frame = CreateFrame("Frame", nil, parent)
        frame:SetSize(200, 40)
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
        -- Set status color based on source
        local statusText = ""
        if pack.source == "BLU Built-in" then
            statusText = "|cff05dffaBLU Built-in|r"
        elseif pack.source == "SharedMedia" then
            statusText = "|cff00ff00SharedMedia|r"
        elseif pack.source == "WoW Built-in" then
            statusText = "|cffb0b0b0WoW Sound|r"
        else
            statusText = "|cff00ff00Loaded|r"
        end
        status:SetText(statusText)

        return frame
    end

    local allSounds = BLU.SoundRegistry:GetAllSounds()
    local uniquePacks = {}

    for _, soundData in pairs(allSounds) do
        local id = soundData.packId or soundData.packName or soundData.source

        if id and not uniquePacks[id] then
            local packName = soundData.packName or id
            if soundData.source == "WoW Built-in" then
                packName = "WoW Default Sounds"
                id = "WoW Default Sounds"
            elseif soundData.source == "Test" then
                packName = "Test Sounds (LSM Missing)"
                id = "Test Sounds"
            end

            uniquePacks[id] = {
                id = id,
                name = packName,
                source = soundData.source,
                icon = "Interface\\Icons\\INV_Misc_Bag_33",
                soundCount = 0,
            }

            if soundData.source == "BLU Built-in" and soundData.packId then
                uniquePacks[id].icon = "Interface\\Icons\\ACHIEVEMENT_GUILDPERK_HONORABLEMENTION"
            end

            if soundData.source == "SharedMedia" and soundData.packId then
                local success, _, _, addonIcon = pcall(C_AddOns.GetAddOnInfo, soundData.packId)
                if success and addonIcon and addonIcon ~= "" then
                    uniquePacks[id].icon = addonIcon
                end
            end
        end
        if id then
            uniquePacks[id].soundCount = uniquePacks[id].soundCount + 1
        end
    end

    local packsArray = {}
    for _, pack in pairs(uniquePacks) do
        table.insert(packsArray, pack)
    end

    table.sort(packsArray, function(a, b)
        return a.name < b.name
    end)

    local xOffset = 10
    local col = 0

    if #packsArray == 0 then
        local noPacks = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        noPacks:SetPoint("TOPLEFT", xOffset, yOffset)
        noPacks:SetText("|cffff0000No sound packs detected or loaded by BLU.|r")
        yOffset = yOffset - 20
    else
        for _, pack in ipairs(packsArray) do
            local frame = createPackEntry(content, pack, xOffset + (col * 210), yOffset)

            frame.name:SetText(pack.name .. " (" .. pack.soundCount .. ")")

            col = col + 1
            if col >= 3 then
                col = 0
                yOffset = yOffset - 45
            end
        end
    end

    content:SetHeight(math.abs(yOffset) + 50)
end

function Sounds:Init()
    BLU:PrintDebug("[Sounds] Sounds panel module initialized")
end

if BLU.RegisterModule then
    BLU:RegisterModule(Sounds, "sounds", "Sounds Panel")
end