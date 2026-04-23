--=====================================================================================
-- BLU - interface/options/sounds.lua
-- Sound options panel
--=====================================================================================

local addonName = ...
local ADDON_PATH = "Interface\\AddOns\\" .. addonName .. "\\"
local BLU = _G["BLU"]

local Sounds = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["sounds"] = Sounds

local function GetAddonIconTexture(addonName)
    if not addonName or addonName == "" then
        return nil
    end

    if C_AddOns and C_AddOns.GetAddOnMetadata then
        local ok, icon = pcall(C_AddOns.GetAddOnMetadata, addonName, "IconTexture")
        if ok and type(icon) == "string" and icon ~= "" then
            return icon
        end
    elseif GetAddOnMetadata then
        local ok, icon = pcall(GetAddOnMetadata, addonName, "IconTexture")
        if ok and type(icon) == "string" and icon ~= "" then
            return icon
        end
    end

    return nil
end

function BLU.RefreshSoundPackUI()
    BLU:PrintDebug("[Options/Sounds] RefreshSoundPackUI called")
    if not BLU.OptionsPanel or not BLU.OptionsPanel.contents then
        return false
    end

    local soundsContent = nil
    if type(BLU.OptionsTabs) == "table" then
        for index, tabInfo in ipairs(BLU.OptionsTabs) do
            if tabInfo and (tabInfo.text == "Sounds" or tabInfo.create == BLU.CreateSoundsPanel) then
                soundsContent = BLU.OptionsPanel.contents[index]
                break
            end
        end
    end

    if not soundsContent then
        BLU:PrintDebug("[Options/Sounds] RefreshSoundPackUI could not resolve the Sounds tab content")
        return false
    end

    if not soundsContent:IsShown() then
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
    BLU:PrintDebug("[Options/Sounds] Creating Sounds panel")
    -- Wipe existing content
    for _, child in ipairs({panel:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end

    local leftColumnWidth = 300

    local installedPanel = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    installedPanel:SetPoint("TOPLEFT", 3, -5)
    installedPanel:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 6, 5)
    installedPanel:SetWidth(leftColumnWidth + 3)
    installedPanel:SetBackdrop(BLU.Modules.design.Backdrops.Dark)
    installedPanel:SetBackdropColor(0.06, 0.06, 0.06, 0.95)
    installedPanel:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

    local scrollFrame = CreateFrame("ScrollFrame", nil, installedPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 8, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", -8, 8)
    scrollFrame:EnableMouseWheel(true)

    if scrollFrame.ScrollBar then
        scrollFrame.ScrollBar:Hide()
        scrollFrame.ScrollBar.Show = function() end
    end

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(284)
    scrollFrame:SetScrollChild(content)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll() or 0
        local step = 28
        local maxScroll = math.max(0, (content:GetHeight() or 0) - self:GetHeight())
        local nextValue = current - (delta * step)
        if nextValue < 0 then
            nextValue = 0
        elseif nextValue > maxScroll then
            nextValue = maxScroll
        end
        self:SetVerticalScroll(nextValue)
    end)

    local header = BLU.Modules.design:CreateHeader(content, "Installed Sound Packs", "Interface\\Icons\\INV_Misc_Bag_33")
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("RIGHT", 0, 0)

    local startY = -40
    local rowsPerColumn = 12
    local maxColumns = 1
    local columnXStart = 10
    local columnWidth = 244
    local columnSpacing = 0
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
            icon = ADDON_PATH .. "media\\Textures\\icon.tga",
            status = "|cff05dffaBLU defaults|r",
            soundCount = 0,
        },
        {
            id = "other_games_blu",
            name = "other games-blu",
            icon = ADDON_PATH .. "media\\Textures\\icon.tga",
            status = "|cff05dffaBLU game library|r",
            soundCount = 0,
        },
        {
            id = "user_custom_sounds",
            name = "user custom sounds",
            icon = "Interface\\Icons\\INV_Misc_Coin_18",
            status = "|cffffaa00No user custom sounds loaded|r",
            soundCount = 0,
        },
    }

    local customSoundCount = 0

    local sharedMediaPacks = {}

    if BLU.SoundRegistry and BLU.SoundRegistry.GetAllSounds then
        local allSounds = BLU.SoundRegistry:GetAllSounds()
        for _, soundData in pairs(allSounds) do
            local isBluSound = soundData and (soundData.source == "BLU" or soundData.source == "BLU Built-in" or soundData.isInternal)
            local isUserCustomPack = soundData and (
                soundData.source == "UserCustom"
                or soundData.packId == "user_custom_sounds"
                or soundData.packName == "User Custom Sounds"
            )
            if isBluSound then
                if soundData.packId == "blu_default" then
                    packRows[1].soundCount = packRows[1].soundCount + 1
                else
                    packRows[2].soundCount = packRows[2].soundCount + 1
                end
            elseif isUserCustomPack then
                packRows[3].soundCount = packRows[3].soundCount + 1
                packRows[3].status = "|cff00ff00Loaded|r"
                customSoundCount = customSoundCount + 1
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
    BLU:PrintDebug("[Options/Sounds] Rendered " .. tostring(#packRows) .. " sound pack entries")

    local managerPanel = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    managerPanel:SetPoint("TOPLEFT", installedPanel, "TOPRIGHT", 8, 0)
    managerPanel:SetPoint("BOTTOMRIGHT", -8, 5)
    managerPanel:SetBackdrop(BLU.Modules.design.Backdrops.Dark)
    managerPanel:SetBackdropColor(0.06, 0.06, 0.06, 0.95)
    managerPanel:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

    local managerHeader = BLU.Modules.design:CreateHeader(managerPanel, "User Custom Sounds", "Interface\\Icons\\INV_Misc_Coin_18")
    managerHeader:SetPoint("TOPLEFT", 8, -8)
    managerHeader:SetPoint("TOPRIGHT", -8, -8)

    local managerNote = managerPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    managerNote:SetPoint("TOPLEFT", managerHeader, "BOTTOMLEFT", 4, -8)
    managerNote:SetPoint("RIGHT", managerPanel, "RIGHT", -12, 0)
    managerNote:SetJustifyH("LEFT")
    managerNote:SetTextColor(0.78, 0.78, 0.78)
    managerNote:SetText("Manage the sounds inside the User Custom Sounds pack here.")

    local addButton = BLU.Modules.design:CreateButton(managerPanel, "Add Custom Sound", 140, 24)
    addButton:SetPoint("TOPLEFT", managerNote, "BOTTOMLEFT", 0, -10)
    addButton:SetScript("OnClick", function()
        BLU:PrintDebug("[Options/Sounds] Add Custom Sound button clicked")
        StaticPopup_Show("BLU_ADD_CUSTOM_SOUND")
    end)

    local countLabel = managerPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    countLabel:SetPoint("LEFT", addButton, "RIGHT", 10, 0)
    countLabel:SetTextColor(0.7, 0.7, 0.7)
    countLabel:SetText("Loaded: " .. tostring(customSoundCount))

    local listFrame = CreateFrame("ScrollFrame", nil, managerPanel, "UIPanelScrollFrameTemplate")
    listFrame:SetPoint("TOPLEFT", addButton, "BOTTOMLEFT", 0, -12)
    listFrame:SetPoint("BOTTOMRIGHT", -10, 10)
    listFrame:EnableMouseWheel(true)

    if listFrame.ScrollBar then
        listFrame.ScrollBar:Hide()
        listFrame.ScrollBar.Show = function() end
    end

    local listContent = CreateFrame("Frame", nil, listFrame)
    listContent:SetWidth(294)
    listFrame:SetScrollChild(listContent)
    listFrame:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll() or 0
        local step = 28
        local maxScroll = math.max(0, (listContent:GetHeight() or 0) - self:GetHeight())
        local nextValue = current - (delta * step)
        if nextValue < 0 then
            nextValue = 0
        elseif nextValue > maxScroll then
            nextValue = maxScroll
        end
        self:SetVerticalScroll(nextValue)
    end)

    local customEntries = {}
    local userSounds = BLU.Modules and BLU.Modules["usersounds"]
    if userSounds and userSounds.GetCustomSoundEntries then
        customEntries = userSounds:GetCustomSoundEntries()
    end

    if #customEntries == 0 then
        local emptyText = listContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        emptyText:SetPoint("TOPLEFT", 4, -4)
        emptyText:SetPoint("RIGHT", -4, 0)
        emptyText:SetJustifyH("LEFT")
        emptyText:SetTextColor(0.65, 0.65, 0.65)
        emptyText:SetText("No manually added user custom sounds are loaded.")
        listContent:SetHeight(40)
    else
        local rowHeight = 48
        for index, entry in ipairs(customEntries) do
            local row = CreateFrame("Frame", nil, listContent, "BackdropTemplate")
            row:SetPoint("TOPLEFT", 0, -((index - 1) * (rowHeight + 6)))
            row:SetWidth(294)
            row:SetHeight(rowHeight)
            row:SetBackdrop(BLU.Modules.design.Backdrops.Solid)
            row:SetBackdropColor(0.08, 0.11, 0.15, 0.90)
            row:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)

            local soundName = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            soundName:SetPoint("TOPLEFT", 8, -6)
            soundName:SetPoint("RIGHT", -88, 0)
            soundName:SetJustifyH("LEFT")
            soundName:SetText(entry.name or "Custom Sound")

            local soundPath = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            soundPath:SetPoint("TOPLEFT", soundName, "BOTTOMLEFT", 0, -2)
            soundPath:SetPoint("RIGHT", -88, 0)
            soundPath:SetJustifyH("LEFT")
            soundPath:SetTextColor(0.65, 0.65, 0.65)
            soundPath:SetText(entry.file or "")

            local removeButton = BLU.Modules.design:CreateButton(row, "Remove", 68, 22)
            removeButton:SetPoint("TOPRIGHT", row, "TOPRIGHT", -6, -11)
            removeButton:SetFrameStrata("HIGH")
            removeButton:Show()
            if removeButton.label then
                removeButton.label:SetTextColor(1.0, 0.35, 0.35)
            end
            removeButton:SetScript("OnClick", function()
                local soundsModule = BLU.Modules and BLU.Modules["usersounds"]
                if soundsModule and soundsModule.RemoveCustomSound then
                    local ok, err = soundsModule:RemoveCustomSound(entry.file)
                    if ok then
                        BLU:Print("|cff00ccffBLU:|r Removed custom sound: " .. tostring(entry.name))
                        if BLU.RefreshSoundPackUI then
                            BLU.RefreshSoundPackUI()
                        end
                    else
                        BLU:Print("|cff00ccffBLU:|r Failed to remove custom sound: " .. tostring(err))
                    end
                end
            end)
        end

        listContent:SetHeight((#customEntries * (rowHeight + 6)) + 4)
    end
end

function Sounds:Init()
    BLU:PrintDebug("[Sounds] Sounds panel module initialized")
end

if BLU.RegisterModule then
    BLU:RegisterModule(Sounds, "sounds", "Sounds Panel")
end
