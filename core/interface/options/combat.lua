--=====================================================================================
-- BLU - interface/options/combat.lua
-- Combat options panel
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

local COMBAT_TRIGGER_PAGES = {
    {
        { id = "combat_start_sound", title = "Combat Start Sound" },
        { id = "combat_end_sound", title = "Combat End Sound" },
        { id = "combat_music_track", title = "Combat Music Track" },
        { id = "low_health", title = "Low Health" },
        { id = "execute_window", title = "Execute Window" },
        { id = "interrupt_ready", title = "Interrupt Ready" },
        { id = "major_cooldown_ready", title = "Major Cooldown Ready" },
        { id = "defensive_ready", title = "Defensive Ready" },
    },
    {
        { id = "proc_trigger", title = "Proc Trigger" },
        { id = "critical_hit", title = "Critical Hit" },
        { id = "critical_heal", title = "Critical Heal" },
        { id = "resource_capped", title = "Resource Capped" },
        { id = "resource_low", title = "Resource Low" },
        { id = "target_lost", title = "Target Lost" },
    },
}

local function EnsureCombatDB()
    if not BLU or not BLU.db then
        return nil
    end

    BLU.db.combat = BLU.db.combat or {}
    BLU.db.combat.page = tonumber(BLU.db.combat.page) or 1
    BLU.db.combat.selectedSounds = BLU.db.combat.selectedSounds or {}
    BLU.db.combat.soundVolumes = BLU.db.combat.soundVolumes or {}
    BLU.db.modules = BLU.db.modules or {}

    return BLU.db.combat
end

local function GetSelectedSound(triggerId)
    local combat = EnsureCombatDB()
    return combat and combat.selectedSounds[triggerId] or "None"
end

local function SetSelectedSound(triggerId, soundId)
    local combat = EnsureCombatDB()
    if combat then
        combat.selectedSounds[triggerId] = soundId
    end
end

local function GetSelectedVolume(triggerId)
    local combat = EnsureCombatDB()
    return (combat and combat.soundVolumes[triggerId]) or "medium"
end

local function SetSelectedVolume(triggerId, volume)
    local combat = EnsureCombatDB()
    if combat then
        combat.soundVolumes[triggerId] = volume
    end
end

local function IsCombatModuleEnabled()
    if not BLU or not BLU.db then
        return true
    end

    local modules = BLU.db.modules
    if not modules or modules.combat == nil then
        return true
    end

    return modules.combat ~= false
end

local function SetCombatModuleEnabled(enabled)
    BLU.db.modules = BLU.db.modules or {}
    BLU.db.modules.combat = enabled == true
end

local function HasEntries(groupData)
    if type(groupData) ~= "table" then
        return false
    end

    if #groupData > 0 then
        return true
    end

    for _, value in pairs(groupData) do
        if type(value) == "table" and #value > 0 then
            return true
        end
    end

    return false
end

local function CountEntries(groupKey, hierarchy)
    local groupData = hierarchy[groupKey]
    if type(groupData) ~= "table" then
        return 0
    end

    if groupKey == "BLU WoW Defaults" or groupKey == "User Custom Sounds" then
        return #groupData
    end

    local count = 0
    for _, packSounds in pairs(groupData) do
        count = count + #packSounds
    end
    return count
end

local function ResolveDisplayText(value, hierarchy)
    if value == "None" then
        return "None"
    end

    if value == "random" then
        return "Random"
    end

    local function walk(node)
        if type(node) ~= "table" then
            return nil
        end

        if node.id == value then
            return node.name
        end

        for _, child in pairs(node) do
            local match = walk(child)
            if match then
                return match
            end
        end

        return nil
    end

    return walk(hierarchy) or "Select Sound"
end

local function GetCombatHierarchy()
    local hierarchy = {
        ["BLU WoW Defaults"] = {},
        ["BLU Other Game Sounds"] = {},
        ["User Custom Sounds"] = {},
        ["Shared Media"] = {},
    }

    if BLU.SoundRegistry and BLU.SoundRegistry.GetSoundsGroupedForUI then
        hierarchy = BLU.SoundRegistry:GetSoundsGroupedForUI("combat") or hierarchy
    end

    return hierarchy
end

local function FlattenHierarchySounds(hierarchy)
    local sounds = {}

    local function addEntry(entry)
        if type(entry) == "table" and type(entry.id) == "string" then
            table.insert(sounds, entry)
        end
    end

    for _, groupKey in ipairs({"BLU WoW Defaults", "BLU Other Game Sounds", "User Custom Sounds", "Shared Media"}) do
        local groupData = hierarchy[groupKey]
        if type(groupData) == "table" then
            if groupKey == "BLU WoW Defaults" or groupKey == "User Custom Sounds" then
                for _, entry in ipairs(groupData) do
                    addEntry(entry)
                end
            else
                for _, packEntries in pairs(groupData) do
                    for _, entry in ipairs(packEntries) do
                        addEntry(entry)
                    end
                end
            end
        end
    end

    return sounds
end

local function PlayCombatTriggerPreview(triggerId)
    local hierarchy = GetCombatHierarchy()
    local selected = GetSelectedSound(triggerId)
    local volume = GetSelectedVolume(triggerId)

    if selected == "None" then
        BLU:Print("|cff00ccffBLU:|r No sound selected for this combat trigger.")
        return
    end

    if selected == "random" then
        local pool = FlattenHierarchySounds(hierarchy)
        if #pool == 0 then
            BLU:Print("|cff00ccffBLU:|r No sounds available to preview.")
            return
        end
        selected = pool[math.random(#pool)].id
    end

    if BLU.SoundRegistry and BLU.SoundRegistry.PlaySound then
        BLU.SoundRegistry:PlaySound(selected, nil, {
            categoryOverride = "combat",
            volumeSettingOverride = volume,
        })
    end
end

local function SelectionHasVolumeVariants(selectionValue)
    if selectionValue == "None" or selectionValue == "random" or selectionValue == "default" then
        return false
    end

    if not (BLU.SoundRegistry and BLU.SoundRegistry.GetSound) then
        return false
    end

    local soundInfo = BLU.SoundRegistry:GetSound(selectionValue)
    return soundInfo and soundInfo.hasVolumeVariants == true or false
end

local function BuildSoundButtonMenu(dropdownFrame, getTriggerId, labelFontString)
    local hierarchy = GetCombatHierarchy()

    local function onSelected(value)
        local triggerId = getTriggerId()
        if not triggerId then
            return
        end

        SetSelectedSound(triggerId, value)
        labelFontString:SetText(ResolveDisplayText(value, hierarchy))
        CloseDropDownMenus()
    end

    dropdownFrame.initialize = function(_, level, menuList)
        local MAX_SOUNDS_PER_MENU_PAGE = 24
        level = level or 1
        local dd = BLU.Modules.dropdown

        local function shortenLabel(text, maxChars)
            if dd and dd.ShortenLabel then
                return dd:ShortenLabel(text, maxChars)
            end

            text = tostring(text or "")
            if #text <= maxChars then
                return text, false
            end

            return string.sub(text, 1, math.max(1, maxChars - 3)) .. "...", true
        end

        local function trimSoundNameForSubmenu(soundName, parentLabel)
            if type(soundName) ~= "string" then
                return ""
            end

            if type(parentLabel) ~= "string" or parentLabel == "" then
                return soundName
            end

            local escapedParent = string.gsub(parentLabel, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
            local withoutDashPrefix = string.gsub(soundName, "^" .. escapedParent .. "%s*%-%s*", "")
            if withoutDashPrefix ~= soundName then
                return withoutDashPrefix
            end

            local withoutColonPrefix = string.gsub(soundName, "^" .. escapedParent .. "%s*:%s*", "")
            if withoutColonPrefix ~= soundName then
                return withoutColonPrefix
            end

            return soundName
        end

        local function getDropDownListFrame(levelToUse)
            if dd and dd.GetListFrame then
                return dd:GetListFrame(levelToUse)
            end

            return _G["DropDownList" .. tostring(levelToUse or 1)]
        end

        local baseMinWidth = 220

        local function getMinWidthForLevel(levelToUse)
            if (levelToUse or 1) <= 1 then
                return baseMinWidth
            end

            return math.max(150, math.floor(baseMinWidth * 0.58))
        end

        local function getLeftInsetForLevel(levelToUse)
            if (levelToUse or 1) == 1 then
                return 24
            end

            if (levelToUse or 1) >= 3 then
                return 24
            end

            return 10
        end

        local function shouldCompactRightControl(levelToUse)
            return (levelToUse or 1) < 3
        end

        local function forceListFrameWidth(levelToUse)
            if dd and dd.ForceWidth then
                dd:ForceWidth(levelToUse, getMinWidthForLevel(levelToUse), getLeftInsetForLevel(levelToUse), {
                    countKey = "bluCountLabel",
                    previewKey = "bluPreviewButton",
                    compactRightControl = shouldCompactRightControl(levelToUse),
                })
            end
        end

        local function styleLastAddedButton(levelToUse, options)
            if dd and dd.StyleLastAddedButton then
                dd:StyleLastAddedButton(levelToUse, options)
            end
        end

        local function resetDropDownListFrame(levelToUse)
            if dd and dd.ResetLevel then
                dd:ResetLevel(levelToUse)
            end
        end

        local function hideInlinePreviewButtons(levelToUse)
            local listFrame = getDropDownListFrame(levelToUse)
            if not listFrame then
                return
            end

            local maxButtons = UIDROPDOWNMENU_MAXBUTTONS or 32
            for i = 1, maxButtons do
                local button = _G[listFrame:GetName() .. "Button" .. i]
                if button then
                    if button.bluPreviewButton then
                        button.bluPreviewButton:Hide()
                    end
                    if button.bluCountLabel then
                        button.bluCountLabel:Hide()
                    end
                end
            end
        end

        local function formatTopLevelGroupLabel(groupKey, count)
            local text = tostring(groupKey or "")
            if groupKey == "BLU Other Game Sounds" or groupKey == "Shared Media" then
                text = "|cffffff00" .. text .. "|r"
            end

            return text .. " (" .. tostring(count or 0) .. ")"
        end

        local function attachInlinePreviewButton(levelToUse, soundId)
            local listFrame = getDropDownListFrame(levelToUse)
            if not listFrame or not listFrame.numButtons then
                return
            end

            local button = _G[listFrame:GetName() .. "Button" .. listFrame.numButtons]
            if not button then
                return
            end

            local previewButton = button.bluPreviewButton
            if not previewButton then
                previewButton = CreateFrame("Button", nil, button, "BackdropTemplate")
                previewButton:SetSize(34, 16)
                previewButton:SetBackdrop(BLU.Modules.design.Backdrops.Button)
                previewButton:SetBackdropColor(0.08, 0.10, 0.13, 0.95)
                previewButton:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
                previewButton:RegisterForClicks("LeftButtonUp")
                previewButton:SetScript("OnClick", function(btn)
                    if btn.soundId and BLU.SoundRegistry and BLU.SoundRegistry.PlaySound then
                        BLU.SoundRegistry:PlaySound(btn.soundId, nil, {
                            categoryOverride = "combat",
                            volumeSettingOverride = GetSelectedVolume(getTriggerId()),
                        })
                    end
                end)
                previewButton:SetScript("OnEnter", function(btn)
                    btn:SetBackdropColor(0.12, 0.16, 0.22, 1)
                    btn:SetBackdropBorderColor(unpack(BLU.Modules.design.Colors.Primary))
                    GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
                    GameTooltip:SetText("Play")
                    GameTooltip:AddLine("Click to preview this sound.", 0.7, 0.7, 0.7, true)
                    GameTooltip:Show()
                end)
                previewButton:SetScript("OnLeave", function(btn)
                    btn:SetBackdropColor(0.08, 0.10, 0.13, 0.95)
                    btn:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
                    GameTooltip:Hide()
                end)

                local previewLabel = previewButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                previewLabel:SetPoint("CENTER", 0, 0)
                previewLabel:SetText("Play")
                previewLabel:SetTextColor(unpack(BLU.Modules.design.Colors.Primary))
                previewButton.label = previewLabel
                button.bluPreviewButton = previewButton
            end

            previewButton.soundId = soundId
            previewButton:Show()

            local normalText = _G[button:GetName() .. "NormalText"]
            previewButton:ClearAllPoints()
            previewButton:SetPoint("RIGHT", button, "RIGHT", -8, 0)

            if normalText then
                normalText:ClearAllPoints()
                normalText:SetPoint("LEFT", button, "LEFT", 10, 0)
                normalText:SetPoint("RIGHT", previewButton, "LEFT", -6, 0)
                normalText:SetJustifyH("LEFT")
            end
        end

        local function attachInlineCountLabel(levelToUse, text)
            local listFrame = getDropDownListFrame(levelToUse)
            if not listFrame or not listFrame.numButtons then
                return
            end

            local button = _G[listFrame:GetName() .. "Button" .. listFrame.numButtons]
            if not button then
                return
            end

            local countLabel = button.bluCountLabel
            if not countLabel then
                countLabel = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                countLabel:SetJustifyH("RIGHT")
                countLabel:SetTextColor(0.72, 0.72, 0.72)
                button.bluCountLabel = countLabel
            end

            countLabel:SetText(text or "")
            countLabel:Show()
        end

        local function addSoundSelectEntry(levelToUse, soundId, soundName, parentLabel)
            local triggerId = getTriggerId()
            local trimmedSoundName = trimSoundNameForSubmenu(soundName, parentLabel)
            local maxChars = 46
            if levelToUse >= 3 then
                maxChars = 120
            elseif levelToUse >= 2 then
                maxChars = 60
            end
            local displayText, wasTruncated = shortenLabel(trimmedSoundName, maxChars)
            local info = UIDropDownMenu_CreateInfo()
            info.text = displayText
            info.value = soundId
            info.func = function()
                onSelected(soundId)
            end
            info.checked = triggerId and GetSelectedSound(triggerId) == soundId
            if wasTruncated or trimmedSoundName ~= soundName then
                info.tooltipTitle = soundName
            end
            UIDropDownMenu_AddButton(info, levelToUse)
            styleLastAddedButton(levelToUse, {hasPreview = true, minWidth = (levelToUse >= 3 and 220 or nil)})
            attachInlinePreviewButton(levelToUse, soundId)
        end

        local function renderPagedSoundList(levelToUse, sounds, page, parentLabel)
            table.sort(sounds, function(a, b)
                return tostring(a.name or "") < tostring(b.name or "")
            end)

            local totalSounds = #sounds
            local totalPages = math.max(1, math.ceil(totalSounds / MAX_SOUNDS_PER_MENU_PAGE))
            local safePage = math.max(1, math.min(page or 1, totalPages))
            local startIndex = ((safePage - 1) * MAX_SOUNDS_PER_MENU_PAGE) + 1
            local endIndex = math.min(totalSounds, startIndex + MAX_SOUNDS_PER_MENU_PAGE - 1)

            if totalPages > 1 then
                local pageInfo = UIDropDownMenu_CreateInfo()
                pageInfo.text = string.format("|cff7fd0ffPage %d/%d|r", safePage, totalPages)
                pageInfo.isTitle = true
                pageInfo.notCheckable = true
                UIDropDownMenu_AddButton(pageInfo, levelToUse)
            end

            for index = startIndex, endIndex do
                local sound = sounds[index]
                addSoundSelectEntry(levelToUse, sound.id, sound.name, parentLabel)
            end
        end

        resetDropDownListFrame(level)
        hideInlinePreviewButtons(level)

        if level == 1 then
            local noneInfo = UIDropDownMenu_CreateInfo()
            noneInfo.text = "|cffff6666None|r"
            noneInfo.checked = GetSelectedSound(getTriggerId()) == "None"
            noneInfo.func = function() onSelected("None") end
            UIDropDownMenu_AddButton(noneInfo, level)
            styleLastAddedButton(level, {minWidth = 150})

            local randomInfo = UIDropDownMenu_CreateInfo()
            randomInfo.text = "|cff66ff66Random|r"
            randomInfo.checked = GetSelectedSound(getTriggerId()) == "random"
            randomInfo.func = function() onSelected("random") end
            UIDropDownMenu_AddButton(randomInfo, level)
            styleLastAddedButton(level, {minWidth = 150})

            local spacer = UIDropDownMenu_CreateInfo()
            spacer.notClickable = true
            spacer.notCheckable = true
            UIDropDownMenu_AddButton(spacer, level)
            styleLastAddedButton(level, {minWidth = 150})

            for _, groupKey in ipairs({"BLU WoW Defaults", "BLU Other Game Sounds", "User Custom Sounds", "Shared Media"}) do
                if HasEntries(hierarchy[groupKey]) then
                    local count = CountEntries(groupKey, hierarchy)
                    if count > 0 then
                        local info = UIDropDownMenu_CreateInfo()
                        info.text = formatTopLevelGroupLabel(groupKey, count)
                        info.notCheckable = true
                        info.hasArrow = true
                        info.menuList = groupKey
                        UIDropDownMenu_AddButton(info, level)
                        styleLastAddedButton(level, {hasArrow = true, notCheckable = true})
                    end
                end
            end
        elseif level == 2 then
            local groupKey = menuList
            local groupData = hierarchy[groupKey]
            if type(groupData) ~= "table" then
                return
            end

            if groupKey == "BLU WoW Defaults" or groupKey == "User Custom Sounds" then
                table.sort(groupData, function(a, b) return tostring(a.name or "") < tostring(b.name or "") end)
                for _, entry in ipairs(groupData) do
                    addSoundSelectEntry(level, entry.id, entry.name)
                end
            else
                local sortedSubKeys = {}
                for subKey in pairs(groupData) do
                    table.insert(sortedSubKeys, subKey)
                end
                table.sort(sortedSubKeys)

                for _, subKey in ipairs(sortedSubKeys) do
                    local sounds = groupData[subKey]
                    local pageCount = math.max(1, math.ceil(#sounds / MAX_SOUNDS_PER_MENU_PAGE))
                    local displaySubKey, subKeyTruncated = shortenLabel(subKey, 60)
                    local info = UIDropDownMenu_CreateInfo()
                    info.notCheckable = true
                    info.hasArrow = true
                    if pageCount > 1 then
                        info.menuList = {group = groupKey, sub = subKey, type = "pack_pages", pageCount = pageCount}
                    else
                        info.menuList = {group = groupKey, sub = subKey, type = "pack", page = 1}
                    end
                    info.text = displaySubKey
                    if subKeyTruncated then
                        info.tooltipTitle = subKey
                    end
                    UIDropDownMenu_AddButton(info, level)
                    attachInlineCountLabel(level, "(" .. #sounds .. ")")
                    styleLastAddedButton(level, {hasArrow = true, notCheckable = true})
                end
            end
        elseif level == 3 then
            if type(menuList) ~= "table" then
                return
            end

            local groupKey = menuList.group
            local subKey = menuList.sub
            local groupData = hierarchy[groupKey]
            local soundsToDisplay = groupData and groupData[subKey]
            if type(soundsToDisplay) ~= "table" then
                return
            end

            if menuList.type == "pack_pages" then
                table.sort(soundsToDisplay, function(a, b) return tostring(a.name or "") < tostring(b.name or "") end)
                local pageCount = math.max(1, math.ceil(#soundsToDisplay / MAX_SOUNDS_PER_MENU_PAGE))
                for pageIndex = 1, pageCount do
                    local firstEntry = ((pageIndex - 1) * MAX_SOUNDS_PER_MENU_PAGE) + 1
                    local lastEntry = math.min(#soundsToDisplay, firstEntry + MAX_SOUNDS_PER_MENU_PAGE - 1)
                    local info = UIDropDownMenu_CreateInfo()
                    info.notCheckable = true
                    info.hasArrow = true
                    info.menuList = {group = groupKey, sub = subKey, type = "pack", page = pageIndex}
                    info.text = string.format("Page %d (%d-%d)", pageIndex, firstEntry, lastEntry)
                    UIDropDownMenu_AddButton(info, level)
                    styleLastAddedButton(level, {hasArrow = true, notCheckable = true})
                end
            else
                renderPagedSoundList(level, soundsToDisplay, menuList.page or 1, subKey)
            end
        elseif level == 4 then
            if type(menuList) ~= "table" or menuList.type ~= "pack" then
                return
            end

            local groupKey = menuList.group
            local subKey = menuList.sub
            local groupData = hierarchy[groupKey]
            local soundsToDisplay = groupData and groupData[subKey]
            if type(soundsToDisplay) == "table" then
                renderPagedSoundList(level, soundsToDisplay, menuList.page or 1, subKey)
            end
        end

        forceListFrameWidth(level)
    end
end

local function CreateVolumeControl(parent, getTriggerId)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(64, 28)

    local button = CreateFrame("Button", nil, frame)
    button:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    button:SetSize(64, 18)

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetTextColor(0.70, 0.78, 0.86)
    label:SetPoint("BOTTOMLEFT", button, "TOPLEFT", 0, 1)

    local track = frame:CreateTexture(nil, "ARTWORK")
    track:SetSize(64, 4)
    track:SetPoint("CENTER", button, "CENTER", 0, 0)
    track:SetColorTexture(0.14, 0.20, 0.28, 1)

    local fill = frame:CreateTexture(nil, "ARTWORK")
    fill:SetHeight(4)
    fill:SetPoint("LEFT", track, "LEFT", 0, 0)
    fill:SetColorTexture(unpack(BLU.Modules.design.Colors.Primary))

    local thumb = frame:CreateTexture(nil, "ARTWORK")
    thumb:SetSize(8, 8)
    thumb:SetTexture("Interface\\Buttons\\WHITE8x8")
    thumb:SetVertexColor(1, 1, 1, 1)

    local function apply(volume)
        local triggerId = getTriggerId()
        if not triggerId then
            return
        end

        local width = 28
        if volume == "low" then
            width = 18
        elseif volume == "high" then
            width = 56
        else
            volume = "medium"
        end

        SetSelectedVolume(triggerId, volume)
        fill:SetWidth(width)
        thumb:ClearAllPoints()
        thumb:SetPoint("CENTER", track, "LEFT", width, 0)
        label:SetText(volume:gsub("^%l", string.upper))
    end

    button:SetScript("OnMouseDown", function(self)
        local cursorX = GetCursorPosition()
        local scale = self:GetEffectiveScale()
        local left = self:GetLeft() and (self:GetLeft() * scale) or 0
        local width = math.max(1, (self:GetWidth() or 1) * scale)
        local percent = math.max(0, math.min(1, (cursorX - left) / width))
        if percent < 0.34 then
            apply("low")
        elseif percent > 0.66 then
            apply("high")
        else
            apply("medium")
        end
    end)

    button:SetScript("OnMouseWheel", function()
        local triggerId = getTriggerId()
        if not triggerId then
            return
        end

        local current = GetSelectedVolume(triggerId)
        if current == "low" then
            apply("medium")
        elseif current == "medium" then
            apply("high")
        else
            apply("low")
        end
    end)
    button:EnableMouseWheel(true)

    apply(GetSelectedVolume(getTriggerId()))
    frame.Refresh = function()
        local triggerId = getTriggerId()
        if not triggerId then
            return
        end

        apply(GetSelectedVolume(triggerId))
    end

    return frame
end

local function CreateCombatRow(parent)
    local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    row:SetHeight(72)
    row:SetBackdrop(BLU.Modules.design.Backdrops.Solid)
    row:SetBackdropColor(0.08, 0.11, 0.15, 0.92)
    row:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)

    local title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 10, -6)
    title:SetPoint("RIGHT", -10, 0)
    title:SetJustifyH("LEFT")
    title:SetTextColor(1.0, 0.82, 0.18)

    local dropdownButton = CreateFrame("Button", nil, row, "BackdropTemplate")
    dropdownButton:SetPoint("TOPLEFT", row, "TOPLEFT", 10, -28)
    dropdownButton:SetHeight(22)
    dropdownButton:SetWidth(146)
    dropdownButton:SetBackdrop(BLU.Modules.design.Backdrops.Button)
    dropdownButton:SetBackdropColor(0.10, 0.14, 0.19, 0.96)
    dropdownButton:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
    dropdownButton:RegisterForClicks("LeftButtonUp")

    local dropdownLabel = dropdownButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dropdownLabel:SetPoint("LEFT", 8, 0)
    dropdownLabel:SetPoint("RIGHT", -18, 0)
    dropdownLabel:SetJustifyH("LEFT")
    dropdownLabel:SetTextColor(0.84, 0.84, 0.84, 1)
    dropdownLabel:SetText("Select Sound")

    local dropdownArrow = dropdownButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dropdownArrow:SetPoint("RIGHT", -6, 0)
    dropdownArrow:SetText("v")
    dropdownArrow:SetTextColor(0.70, 0.78, 0.86, 1)

    local dropdownFrame = CreateFrame("Frame", nil, row, "UIDropDownMenuTemplate")
    dropdownFrame.displayMode = "MENU"
    BuildSoundButtonMenu(dropdownFrame, function()
        return row._combatTriggerId
    end, dropdownLabel)

    dropdownButton:SetScript("OnClick", function(self)
        if not row._combatTriggerId then
            return
        end

        BuildSoundButtonMenu(dropdownFrame, function()
            return row._combatTriggerId
        end, dropdownLabel)
        ToggleDropDownMenu(1, nil, dropdownFrame, self, 0, 0)
    end)
    dropdownButton:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(unpack(BLU.Modules.design.Colors.Primary))
    end)
    dropdownButton:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
    end)

    local volumeControl = CreateVolumeControl(row, function()
        return row._combatTriggerId
    end)

    local testButton = BLU.Modules.design:CreateActionButton(
        row,
        "Test",
        46,
        20,
        "Test Combat Trigger",
        "Preview the currently selected sound for this trigger."
    )
    testButton:SetPoint("TOPRIGHT", row, "TOPRIGHT", -10, -31)
    testButton:SetScript("OnClick", function()
        if row._combatTriggerId then
            PlayCombatTriggerPreview(row._combatTriggerId)
        end
    end)

    local function LayoutControls(showVolume)
        dropdownButton:ClearAllPoints()
        volumeControl:ClearAllPoints()
        testButton:ClearAllPoints()

        dropdownButton:SetPoint("TOPLEFT", row, "TOPLEFT", 10, -28)
        dropdownButton:SetWidth(146)

        if showVolume then
            volumeControl:SetPoint("LEFT", dropdownButton, "RIGHT", 12, 0)
            testButton:SetPoint("LEFT", volumeControl, "RIGHT", 12, 0)
        else
            testButton:SetPoint("LEFT", dropdownButton, "RIGHT", 18, 0)
        end
    end

    row.Refresh = function()
        if not row._combatTriggerId then
            title:SetText("")
            dropdownLabel:SetText("Select Sound")
            volumeControl:Hide()
            LayoutControls(false)
            return
        end

        local selectedSound = GetSelectedSound(row._combatTriggerId)
        local showVolume = SelectionHasVolumeVariants(selectedSound)

        title:SetText(row._combatTriggerTitle or "")
        dropdownLabel:SetText(ResolveDisplayText(selectedSound, GetCombatHierarchy()))

        if showVolume then
            volumeControl:Show()
            volumeControl:Refresh()
        else
            volumeControl:Hide()
        end

        LayoutControls(showVolume)
    end

    function row:SetTriggerInfo(triggerInfo)
        self._combatTriggerId = triggerInfo and triggerInfo.id or nil
        self._combatTriggerTitle = triggerInfo and triggerInfo.title or ""
        self:Refresh()
    end

    return row
end

function BLU.CreateCombatPanel(panel)
    for _, child in ipairs({panel:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end

    local content = CreateFrame("Frame", nil, panel)
    content:SetPoint("TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    local combat = EnsureCombatDB()
    if not combat then
        return
    end
    local totalPages = #COMBAT_TRIGGER_PAGES

    local titleBar = CreateFrame("Frame", nil, content, "BackdropTemplate")
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", 0, 0)
    titleBar:SetHeight(44)
    titleBar:SetBackdrop(BLU.Modules.design.Backdrops.Solid)
    titleBar:SetBackdropColor(0.06, 0.10, 0.16, 0.95)
    titleBar:SetBackdropBorderColor(0.10, 0.20, 0.28, 1)

    local icon = titleBar:CreateTexture(nil, "ARTWORK")
    icon:SetSize(24, 24)
    icon:SetPoint("LEFT", 10, 0)
    icon:SetTexture("Interface\\Icons\\Ability_Warrior_Charge")

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    title:SetText("|cff05dffaCombat|r")

    local switchFrame = CreateFrame("Frame", nil, titleBar)
    switchFrame:SetSize(44, 20)
    switchFrame:SetPoint("RIGHT", -10, 0)

    local switchBg = switchFrame:CreateTexture(nil, "BACKGROUND")
    switchBg:SetAllPoints()
    switchBg:SetTexture("Interface\\Buttons\\WHITE8x8")

    local toggle = CreateFrame("Button", nil, switchFrame)
    toggle:SetSize(18, 18)
    toggle:EnableMouse(true)

    local toggleBg = toggle:CreateTexture(nil, "ARTWORK")
    toggleBg:SetAllPoints()
    toggleBg:SetTexture("Interface\\Buttons\\WHITE8x8")

    local status = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    status:SetPoint("RIGHT", switchFrame, "LEFT", -6, 0)

    local function RefreshToggle()
        local enabled = IsCombatModuleEnabled()
        toggle:ClearAllPoints()
        if enabled then
            toggle:SetPoint("RIGHT", switchFrame, "RIGHT", -1, 0)
            switchBg:SetVertexColor(unpack(BLU.Modules.design.Colors.Primary))
            status:SetText("|cff00ff00ON|r")
        else
            toggle:SetPoint("LEFT", switchFrame, "LEFT", 1, 0)
            switchBg:SetVertexColor(0.3, 0.3, 0.3, 1)
            status:SetText("|cffff0000OFF|r")
        end
    end

    toggle:SetScript("OnClick", function()
        local enabled = not IsCombatModuleEnabled()
        SetCombatModuleEnabled(enabled)
        RefreshToggle()
        if enabled then
            if BLU.LoadModule then BLU:LoadModule("features", "combat") end
        else
            if BLU.UnloadModule then BLU:UnloadModule("combat") end
        end
    end)

    RefreshToggle()

    local body = CreateFrame("Frame", nil, content, "BackdropTemplate")
    body:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, -10)
    body:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, -10)
    body:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 0, 0)
    body:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 0)
    body:SetBackdrop(BLU.Modules.design.Backdrops.Panel)
    body:SetBackdropColor(0.03, 0.03, 0.03, 0.6)
    body:SetBackdropBorderColor(0.1, 0.1, 0.1, 1)

    local triggerArea = CreateFrame("Frame", nil, body)
    triggerArea:SetPoint("TOPLEFT", body, "TOPLEFT", 6, -6)
    triggerArea:SetPoint("TOPRIGHT", body, "TOPRIGHT", -6, -6)
    triggerArea:SetPoint("BOTTOMLEFT", body, "BOTTOMLEFT", 6, 6)
    triggerArea:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -6, 6)

    local triggerHeader = CreateFrame("Frame", nil, triggerArea)
    triggerHeader:SetPoint("TOPLEFT", triggerArea, "TOPLEFT", 0, 0)
    triggerHeader:SetPoint("TOPRIGHT", triggerArea, "TOPRIGHT", 0, 0)
    triggerHeader:SetHeight(24)

    local pageLabel = triggerHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    pageLabel:SetPoint("RIGHT", -126, -1)
    pageLabel:SetTextColor(0.70, 0.78, 0.86)

    local prevButton = BLU.Modules.design:CreateActionButton(triggerHeader, "Prev", 56, 20, "Previous Page", "Show the previous set of combat triggers.")
    prevButton:SetPoint("RIGHT", -66, -1)

    local nextButton = BLU.Modules.design:CreateActionButton(triggerHeader, "Next", 56, 20, "Next Page", "Show the next set of combat triggers.")
    nextButton:SetPoint("RIGHT", -6, -1)

    local triggerRows = {}
    local rowStartY = -30
    local rowHeight = 72
    local rowGap = 8

    for index = 1, 8 do
        local row = CreateCombatRow(triggerArea)
        local column = ((index - 1) % 2)
        local visualRow = math.floor((index - 1) / 2)
        local y = rowStartY - (visualRow * (rowHeight + rowGap))

        if column == 0 then
            row:SetPoint("TOPLEFT", triggerArea, "TOPLEFT", 0, y)
            row:SetPoint("TOPRIGHT", triggerArea, "TOP", -5, y)
        else
            row:SetPoint("TOPLEFT", triggerArea, "TOP", 5, y)
            row:SetPoint("TOPRIGHT", triggerArea, "TOPRIGHT", 0, y)
        end

        triggerRows[index] = row
    end

    local function RenderPage()
        combat.page = math.max(1, math.min(totalPages, combat.page))
        pageLabel:SetText(string.format("Page %d of %d", combat.page, totalPages))

        local page = COMBAT_TRIGGER_PAGES[combat.page] or {}
        for index, row in ipairs(triggerRows) do
            local triggerInfo = page[index]
            if triggerInfo then
                row:Show()
                row:SetTriggerInfo(triggerInfo)
            else
                row:SetTriggerInfo(nil)
                row:Hide()
            end
        end

        prevButton:SetEnabled(combat.page > 1)
        nextButton:SetEnabled(combat.page < totalPages)
    end

    prevButton:SetScript("OnClick", function()
        combat.page = combat.page - 1
        RenderPage()
    end)

    nextButton:SetScript("OnClick", function()
        combat.page = combat.page + 1
        RenderPage()
    end)

    RenderPage()
end
