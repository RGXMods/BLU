--=====================================================================================
-- BLU - interface/options/sound_panel.lua
-- Sound selection panel for events
--=====================================================================================

local addonName = ...
local ADDON_PATH = "Interface\\AddOns\\" .. addonName .. "\\"
local BLU = _G["BLU"]

local SoundPanel = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["sound_panel"] = SoundPanel

local EVENT_MODULE_MAP = {
    honorrank = "honor",
    renownrank = "renown",
    delvecompanion = "delve",
    questaccept = "quest",
    questturnin = "quest",
    questprogress = "quest",
    achievementprogress = "achievement",
    petcapture = "battlepet",
    delvelifelost = "delve",
    delvelifegained = "delve",
    housingxpgained = "housing",
    housingleveledup = "housing",
    housingrewardsreceived = "housing",
    housingdecorcollected = "housing",
}

local function CreateSoundDropdown(parent, eventType, label, yOffset, soundType)
    local actualEventType = soundType or eventType
    BLU:PrintDebug("[Options/SoundPanel] Creating sound dropdown for '" .. tostring(actualEventType) .. "'")

    local container = CreateFrame("Frame", nil, parent)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
    container:SetPoint("RIGHT", parent, "RIGHT", -10, 0)
    container:SetHeight(90)

    local dropdownLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdownLabel:SetPoint("TOPLEFT", 10, -5)
    dropdownLabel:SetText(label)

    local currentLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    currentLabel:SetPoint("TOPLEFT", dropdownLabel, "BOTTOMLEFT", 0, -5)
    currentLabel:SetText("Currently selected: ")
    currentLabel:SetTextColor(0.7, 0.7, 0.7)

    local currentSound = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    currentSound:SetPoint("LEFT", currentLabel, "RIGHT", 5, 0)
    currentSound:SetTextColor(0.02, 0.87, 0.98)
    currentSound:SetWidth(360)
    currentSound:SetJustifyH("LEFT")
    currentSound:SetWordWrap(false)
    if currentSound.SetMaxLines then
        currentSound:SetMaxLines(1)
    end

    local controlsFrame = CreateFrame("Frame", nil, container)
    controlsFrame:SetPoint("TOPRIGHT", container, "TOPRIGHT", -8, -32)
    controlsFrame:SetSize(230, 24)

    local function volumeToStep(volume)
        if volume == "low" then
            return 1
        elseif volume == "high" then
            return 3
        end
        return 2
    end

    local function stepToVolume(step)
        if step <= 1 then
            return "low"
        elseif step >= 3 then
            return "high"
        end
        return "medium"
    end

    local volumeSlider = CreateFrame("Slider", nil, controlsFrame, "OptionsSliderTemplate")
    volumeSlider:SetPoint("LEFT", 0, -3)
    volumeSlider:SetWidth(108)
    volumeSlider:SetMinMaxValues(1, 3)
    volumeSlider:SetValueStep(1)
    volumeSlider:SetObeyStepOnDrag(true)
    volumeSlider.Low:SetText("")
    volumeSlider.High:SetText("")
    volumeSlider.Text:SetText("")
    volumeSlider.Low:Hide()
    volumeSlider.High:Hide()

    local medLabel = controlsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    medLabel:SetPoint("TOP", volumeSlider, "BOTTOM", 0, 2)
    medLabel:SetText("Medium")
    medLabel:SetTextColor(0.8, 0.8, 0.8)

    local sliderUpdating = false
    local function setVolumeSliderValue(volume)
        local step = volumeToStep(volume)
        sliderUpdating = true
        volumeSlider:SetValue(step)
        sliderUpdating = false
        medLabel:SetText(volume:gsub("^%l", string.upper))
    end

    volumeSlider:SetScript("OnValueChanged", function(self, value)
        if sliderUpdating then
            return
        end

        local step = math.floor((value or 2) + 0.5)
        if step < 1 then step = 1 end
        if step > 3 then step = 3 end

        if self:GetValue() ~= step then
            sliderUpdating = true
            self:SetValue(step)
            sliderUpdating = false
        end

        local volume = stepToVolume(step)
        medLabel:SetText(volume:gsub("^%l", string.upper))

        if not BLU.db or not BLU.db.profile then
            return
        end
        BLU.db.profile.soundVolumes = BLU.db.profile.soundVolumes or {}
        BLU.db.profile.soundVolumes[actualEventType] = volume
        BLU:PrintDebug("[Options/SoundPanel] Set volume for '" .. tostring(actualEventType) .. "' to '" .. tostring(volume) .. "'")
    end)

    local initialVolume = (BLU.db and BLU.db.profile and BLU.db.profile.soundVolumes and BLU.db.profile.soundVolumes[actualEventType]) or "medium"
    setVolumeSliderValue(initialVolume)

    -- Channel selector for soundpack/non-BLU sounds (BLU sounds always use Master)
    local CHANNEL_OPTIONS = {"Master", "SFX", "Music", "Ambience"}
    local channelDropdown = CreateFrame("Frame", "BLUChanDD_" .. actualEventType, controlsFrame, "UIDropDownMenuTemplate")
    channelDropdown:SetPoint("LEFT", -16, -5)
    UIDropDownMenu_SetWidth(channelDropdown, 100)
    channelDropdown:Hide()

    UIDropDownMenu_Initialize(channelDropdown, function(self, level)
        local current = (BLU.db and BLU.db.profile and BLU.db.profile.soundChannels and BLU.db.profile.soundChannels[actualEventType]) or "SFX"
        for _, channelName in ipairs(CHANNEL_OPTIONS) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = channelName
            info.value = channelName
            info.checked = current == channelName
            info.func = function()
                BLU.db.profile.soundChannels = BLU.db.profile.soundChannels or {}
                BLU.db.profile.soundChannels[actualEventType] = channelName
                UIDropDownMenu_SetText(channelDropdown, channelName)
                BLU:PrintDebug("[Options/SoundPanel] Set channel for '" .. tostring(actualEventType) .. "' to '" .. tostring(channelName) .. "'")
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    local initChannel = (BLU.db and BLU.db.profile and BLU.db.profile.soundChannels and BLU.db.profile.soundChannels[actualEventType]) or "SFX"
    UIDropDownMenu_SetText(channelDropdown, initChannel)

    local function isBluVolumeSelection(selectionValue)
        if selectionValue == "random" then
            return false  -- random: show channel dropdown, volume is always medium
        end
        if not selectionValue or selectionValue == "default" or selectionValue == "None" then
            return true  -- no sound selected: show volume slider as default state
        end

        if type(selectionValue) ~= "string" or selectionValue:match("^external:") then
            return false
        end

        if not (BLU.SoundRegistry and BLU.SoundRegistry.GetSound) then
            return false
        end

        local soundInfo = BLU.SoundRegistry:GetSound(selectionValue)
        if not soundInfo then
            return false
        end

        return soundInfo.isInternal == true
    end

    local function updateSoundControlMode(selectionValue)
        if isBluVolumeSelection(selectionValue) then
            local stored = (BLU.db and BLU.db.profile and BLU.db.profile.soundVolumes and BLU.db.profile.soundVolumes[actualEventType]) or "medium"
            setVolumeSliderValue(stored)
            volumeSlider:Show()
            medLabel:Show()
            channelDropdown:Hide()
        else
            volumeSlider:Hide()
            medLabel:Hide()
            local current = (BLU.db and BLU.db.profile and BLU.db.profile.soundChannels and BLU.db.profile.soundChannels[actualEventType]) or "SFX"
            UIDropDownMenu_SetText(channelDropdown, current)
            channelDropdown:Show()
        end
    end

    local testBtn = BLU.Modules.design:CreateButton(controlsFrame, "Test", 60, 22)
    testBtn:SetPoint("RIGHT", controlsFrame, "RIGHT", 0, -3)
    testBtn:SetScript("OnClick", function(self)
        BLU:PrintDebug("Test button clicked for event: " .. actualEventType)
        local selectedSound = BLU.db and BLU.db.profile and BLU.db.profile.selectedSounds and BLU.db.profile.selectedSounds[actualEventType]
        BLU:PrintDebug("Selected sound is: " .. tostring(selectedSound))

        local channel = (BLU.db and BLU.db.profile and BLU.db.profile.soundChannels and BLU.db.profile.soundChannels[actualEventType]) or "SFX"
        BLU:Print("Test [" .. actualEventType .. "] channel: " .. channel)

        self:SetText("Playing...")
        self:Disable()

        if BLU.PlayCategorySound then
            BLU:PlayCategorySound(actualEventType)
        elseif BLU.Modules.registry and BLU.Modules.registry.PlayCategorySound then
            BLU.Modules.registry:PlayCategorySound(actualEventType)
        end

        C_Timer.After(2, function()
            self:SetText("Test")
            self:Enable()
        end)
    end)

    local dropdown = CreateFrame("Frame", "BLUDropdown_" .. actualEventType, container, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", currentLabel, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(dropdown, 260)

    dropdown.currentSound = currentSound
    dropdown.eventId = actualEventType

    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local MAX_SOUNDS_PER_MENU_PAGE = 24
        local INLINE_PREVIEW_TEXTURE = ADDON_PATH .. "media\\Textures\\play.blp"
        local MENU_BUTTON_WIDTH = 212
        local MENU_TEXT_WIDTH = 174
        local MENU_LIST_MIN_WIDTH = 236
        local MENU_TITLE_TEXT_WIDTH = 186
        level = level or 1

        if not BLU.db or not BLU.db.profile then return end
        BLU.db.profile.selectedSounds = BLU.db.profile.selectedSounds or {}

        local function getDropDownListFrame(levelToUse)
            return _G["DropDownList" .. levelToUse] or _G["LibDropDownMenu_List" .. levelToUse]
        end

        local function shortenLabel(text, maxChars)
            if type(text) ~= "string" then
                return "", false
            end

            if #text <= maxChars then
                return text, false
            end

            return string.sub(text, 1, maxChars - 3) .. "...", true
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

        local function styleLastAddedButton(levelToUse, textWidth, buttonWidth)
            local listFrame = getDropDownListFrame(levelToUse)
            if not listFrame or not listFrame.numButtons then
                return
            end

            local button = _G[listFrame:GetName() .. "Button" .. listFrame.numButtons]
            if not button then
                return
            end

            local effectiveButtonWidth = buttonWidth or MENU_BUTTON_WIDTH
            button:SetWidth(effectiveButtonWidth)

            local normalText = _G[button:GetName() .. "NormalText"]
            if normalText then
                normalText:SetWordWrap(false)
                if normalText.SetMaxLines then
                    normalText:SetMaxLines(1)
                end
                normalText:SetWidth(textWidth or MENU_TEXT_WIDTH)
            end

            if listFrame:GetWidth() < MENU_LIST_MIN_WIDTH then
                listFrame:SetWidth(MENU_LIST_MIN_WIDTH)
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
                if button and button.bluPreviewButton then
                    button.bluPreviewButton:Hide()
                end
            end
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
                previewButton = CreateFrame("Button", nil, button)
                previewButton:SetSize(14, 14)
                previewButton:RegisterForClicks("LeftButtonUp")
                previewButton:SetScript("OnClick", function(btn)
                    if btn.soundId and BLU.SoundRegistry and BLU.SoundRegistry.PlaySound then
                        BLU.SoundRegistry:PlaySound(btn.soundId)
                    end
                end)
                previewButton:SetScript("OnEnter", function(btn)
                    GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
                    GameTooltip:SetText("Preview")
                    GameTooltip:AddLine("Click to play this sound.", 0.7, 0.7, 0.7, true)
                    GameTooltip:Show()
                end)
                previewButton:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)

                local texture = previewButton:CreateTexture(nil, "ARTWORK")
                texture:SetAllPoints()
                texture:SetTexture(INLINE_PREVIEW_TEXTURE)
                previewButton.texture = texture
                button.bluPreviewButton = previewButton
            end

            previewButton.soundId = soundId
            previewButton:Show()

            local normalText = _G[button:GetName() .. "NormalText"]
            if normalText then
                local stringWidth = normalText:GetStringWidth() or 0
                local defaultOffset = button:GetWidth() - 28
                local desiredOffset = 16 + stringWidth + 8
                if desiredOffset > defaultOffset then
                    desiredOffset = defaultOffset
                end
                if desiredOffset < 92 then
                    desiredOffset = 92
                end
                previewButton:ClearAllPoints()
                previewButton:SetPoint("LEFT", button, "LEFT", desiredOffset, 0)
            else
                previewButton:ClearAllPoints()
                previewButton:SetPoint("RIGHT", button, "RIGHT", -18, 0)
            end
        end

        hideInlinePreviewButtons(level)

        local function hasEntries(groupData)
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

        local function onSoundSelected(value, text)
            BLU.db.profile.selectedSounds[self.eventId] = value
            UIDropDownMenu_SetText(self, text)
            self.currentSound:SetText(text)
            updateSoundControlMode(value)
            BLU:PrintDebug("[Options/SoundPanel] Selected sound '" .. tostring(value) .. "' for '" .. tostring(self.eventId) .. "'")
            CloseDropDownMenus()
        end

        local function addSoundSelectEntry(levelToUse, soundId, soundName, parentLabel)
            local trimmedSoundName = trimSoundNameForSubmenu(soundName, parentLabel)
            local displayText, wasTruncated = shortenLabel(trimmedSoundName, 44)
            local selectInfo = UIDropDownMenu_CreateInfo()
            selectInfo.text = displayText
            selectInfo.value = soundId
            selectInfo.func = function()
                onSoundSelected(soundId, trimmedSoundName)
            end
            selectInfo.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == soundId
            if wasTruncated or trimmedSoundName ~= soundName then
                selectInfo.tooltipTitle = soundName
            end
            UIDropDownMenu_AddButton(selectInfo, levelToUse)
            styleLastAddedButton(levelToUse, MENU_TEXT_WIDTH, MENU_BUTTON_WIDTH)
            attachInlinePreviewButton(levelToUse, soundId)
        end

        local function renderPagedSoundList(levelToUse, sounds, page, parentLabel)
            table.sort(sounds, function(a, b) return a.name < b.name end)

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
                styleLastAddedButton(levelToUse, MENU_TITLE_TEXT_WIDTH, MENU_BUTTON_WIDTH)
            end

            for i = startIndex, endIndex do
                local sound = sounds[i]
                addSoundSelectEntry(levelToUse, sound.id, sound.name, parentLabel)
            end
        end
        local customHierarchy = {
            ["BLU WoW Defaults"] = {},
            ["BLU Other Game Sounds"] = {},
            ["Shared Media"] = {},
        }
        if BLU.SoundRegistry and BLU.SoundRegistry.GetSoundsGroupedForUI then
            customHierarchy = BLU.SoundRegistry:GetSoundsGroupedForUI(self.eventId) or customHierarchy
        end

        if level == 1 then
            local specialOptions = {
                {text = "|cffff4444None|r", value = "None"},
                {text = "|cff00ff00Random|r", value = "random"},
                {text = "Default Sound", value = "default"},
            }
            for _, info in ipairs(specialOptions) do
                local dInfo = UIDropDownMenu_CreateInfo()
                dInfo.text = info.text
                dInfo.value = info.value
                dInfo.func = function() onSoundSelected(info.value, info.text) end
                dInfo.checked = BLU.db.profile.selectedSounds[self.eventId] == info.value
                UIDropDownMenu_AddButton(dInfo, level)
                styleLastAddedButton(level, MENU_TITLE_TEXT_WIDTH, MENU_BUTTON_WIDTH)
            end

            local sep = UIDropDownMenu_CreateInfo()
            sep.notClickable = true
            sep.notCheckable = true
            UIDropDownMenu_AddButton(sep, level)
            styleLastAddedButton(level, MENU_TITLE_TEXT_WIDTH, MENU_BUTTON_WIDTH)

            local sortedTopLevelKeys = {"BLU WoW Defaults", "BLU Other Game Sounds", "User Custom Sounds", "Shared Media"}

            for _, groupKey in ipairs(sortedTopLevelKeys) do
                if hasEntries(customHierarchy[groupKey]) then
                    local count = 0
                    if groupKey == "BLU WoW Defaults" then
                        count = #customHierarchy[groupKey]
                        -- Avoid duplicating "Default Sound" with a one-item defaults submenu.
                        if count <= 1 then
                            count = 0
                        end
                    elseif groupKey == "User Custom Sounds" then
                        count = #customHierarchy[groupKey]
                    else
                        for _, packSounds in pairs(customHierarchy[groupKey]) do
                            count = count + #packSounds
                        end
                    end

                    if count > 0 then
                        local info = UIDropDownMenu_CreateInfo()
                        info.text = "|cffffff00" .. groupKey .. "|r (" .. count .. ")"
                        info.value = groupKey
                        info.hasArrow = true
                        info.menuList = groupKey
                        info.notCheckable = true
                        UIDropDownMenu_AddButton(info, level)
                        styleLastAddedButton(level, MENU_TITLE_TEXT_WIDTH, MENU_BUTTON_WIDTH)
                    end
                end
            end
        elseif level == 2 then
            local groupKey = menuList
            local subgroups = customHierarchy[groupKey]
            if type(subgroups) ~= "table" then
                return
            end

            if groupKey == "BLU WoW Defaults" or groupKey == "User Custom Sounds" then
                table.sort(subgroups, function(a, b) return a.name < b.name end)
                for _, sound in ipairs(subgroups) do
                    addSoundSelectEntry(level, sound.id, sound.name)
                end
            else
                local sortedSubKeys = {}
                for subKey in pairs(subgroups) do
                    table.insert(sortedSubKeys, subKey)
                end
                table.sort(sortedSubKeys)

                for _, subKey in ipairs(sortedSubKeys) do
                    local sounds = subgroups[subKey]
                    local pageCount = math.max(1, math.ceil(#sounds / MAX_SOUNDS_PER_MENU_PAGE))
                    local displaySubKey, subKeyTruncated = shortenLabel(subKey, 32)
                    local info = UIDropDownMenu_CreateInfo()
                    info.value = subKey
                    info.notCheckable = true
                    info.hasArrow = true
                    if pageCount > 1 then
                        info.menuList = {group = groupKey, sub = subKey, type = "pack_pages", pageCount = pageCount}
                    else
                        info.menuList = {group = groupKey, sub = subKey, type = "pack", page = 1}
                    end
                    info.text = displaySubKey .. " (" .. #sounds .. ")"
                    if subKeyTruncated then
                        info.tooltipTitle = subKey
                    end
                    UIDropDownMenu_AddButton(info, level)
                    styleLastAddedButton(level, MENU_TITLE_TEXT_WIDTH, MENU_BUTTON_WIDTH)
                end
            end
        elseif level == 3 then
            if type(menuList) ~= "table" then
                return
            end

            local groupKey = menuList.group
            local subKey = menuList.sub
            local groupData = customHierarchy[groupKey]
            local soundsToDisplay = groupData and groupData[subKey]

            if type(soundsToDisplay) == "table" then
                if menuList.type == "pack_pages" then
                    table.sort(soundsToDisplay, function(a, b) return a.name < b.name end)
                    local pageCount = math.max(1, math.ceil(#soundsToDisplay / MAX_SOUNDS_PER_MENU_PAGE))
                    for pageIndex = 1, pageCount do
                        local firstEntry = ((pageIndex - 1) * MAX_SOUNDS_PER_MENU_PAGE) + 1
                        local lastEntry = math.min(#soundsToDisplay, firstEntry + MAX_SOUNDS_PER_MENU_PAGE - 1)
                        local pageInfo = UIDropDownMenu_CreateInfo()
                        pageInfo.notCheckable = true
                        pageInfo.hasArrow = true
                        pageInfo.menuList = {group = groupKey, sub = subKey, type = "pack", page = pageIndex}
                        pageInfo.text = string.format("Page %d (%d-%d)", pageIndex, firstEntry, lastEntry)
                        UIDropDownMenu_AddButton(pageInfo, level)
                        styleLastAddedButton(level, MENU_TITLE_TEXT_WIDTH, MENU_BUTTON_WIDTH)
                    end
                else
                    renderPagedSoundList(level, soundsToDisplay, menuList.page or 1, subKey)
                end
            end
        elseif level == 4 then
            if type(menuList) ~= "table" or menuList.type ~= "pack" then
                return
            end

            local groupKey = menuList.group
            local subKey = menuList.sub
            local groupData = customHierarchy[groupKey]
            local soundsToDisplay = groupData and groupData[subKey]
            if type(soundsToDisplay) == "table" then
                renderPagedSoundList(level, soundsToDisplay, menuList.page or 1, subKey)
            end
        end
    end)

    local selectedValue = BLU.db and BLU.db.profile and BLU.db.profile.selectedSounds and BLU.db.profile.selectedSounds[actualEventType] or "default"
    if selectedValue == "None" then
        selectedValue = "default"
        if BLU.db and BLU.db.profile and BLU.db.profile.selectedSounds then
            BLU.db.profile.selectedSounds[actualEventType] = "default"
        end
    end

    local selectedText = selectedValue
    if selectedValue == "default" then
        selectedText = "Default Sound"
    elseif selectedValue == "random" then
        selectedText = "Random"
    else
        local soundInfo = BLU.SoundRegistry and BLU.SoundRegistry.GetSound and BLU.SoundRegistry:GetSound(selectedValue)
        if soundInfo then
            selectedText = soundInfo.name
        end
    end
    UIDropDownMenu_SetText(dropdown, selectedText)
    dropdown.currentSound:SetText(selectedText)
    updateSoundControlMode(selectedValue)

    return container
end

function BLU.CreateEventSoundPanel(panel, eventType, eventName)
    BLU:PrintDebug("[Options/SoundPanel] Creating event sound panel for '" .. tostring(eventType) .. "'")
    local content = CreateFrame("Frame", nil, panel)
    content:SetPoint("TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    local icons = {
        levelup      = "Interface\\Icons\\Achievement_Level_100",
        achievement  = "Interface\\Icons\\Achievement_GuildPerk_MobileMailbox",
        quest        = "Interface\\Icons\\INV_Misc_Note_01",
        reputation   = "Interface\\Icons\\Achievement_Reputation_01",
        battlepet    = "Interface\\Icons\\INV_Pet_BattlePetTraining",
        honorrank    = "Interface\\Icons\\PVPCurrency-Honor-Horde",
        renownrank   = "Interface\\Icons\\UI_MajorFaction_Centaur",
        tradingpost  = "Interface\\Icons\\INV_Misc_Coin_02",
        delvecompanion = "Interface\\Icons\\Ability_DungeonFinder",
    }

    -- Single titlebar: icon + title + module toggle
    local titleBar = CreateFrame("Frame", nil, content, "BackdropTemplate")
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("RIGHT", 0, 0)
    titleBar:SetHeight(44)
    titleBar:SetBackdrop(BLU.Modules.design.Backdrops.Solid)
    titleBar:SetBackdropColor(0.06, 0.10, 0.16, 0.95)
    titleBar:SetBackdropBorderColor(0.10, 0.20, 0.28, 1)

    local icon = titleBar:CreateTexture(nil, "ARTWORK")
    icon:SetSize(24, 24)
    icon:SetPoint("LEFT", 10, 0)
    icon:SetTexture(icons[eventType] or "Interface\\Icons\\INV_Misc_QuestionMark")

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    title:SetText("|cff05dffa" .. eventName .. " Sounds|r")

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
    toggleBg:SetVertexColor(1, 1, 1, 1)

    local status = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    status:SetPoint("RIGHT", switchFrame, "LEFT", -6, 0)

    local moduleToggleKey = eventType
    local moduleLoadName = EVENT_MODULE_MAP[eventType] or eventType

    local function UpdateToggleState(enabled)
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

    local function IsModuleEnabled()
        if not BLU.db or not BLU.db.profile then return true end
        local modules = BLU.db.profile.modules
        if not modules then return true end
        if modules[moduleToggleKey] ~= nil then return modules[moduleToggleKey] ~= false end
        if moduleLoadName ~= moduleToggleKey and modules[moduleLoadName] ~= nil then
            return modules[moduleLoadName] ~= false
        end
        return true
    end

    local function SetModuleEnabledState(enabled)
        BLU.db.profile.modules[moduleToggleKey] = enabled
        if moduleLoadName ~= moduleToggleKey then
            BLU.db.profile.modules[moduleLoadName] = enabled
        end
    end

    UpdateToggleState(IsModuleEnabled())

    toggle:SetScript("OnClick", function()
        if not BLU.db or not BLU.db.profile then return end
        BLU.db.profile.modules = BLU.db.profile.modules or {}
        local newState = not IsModuleEnabled()
        SetModuleEnabledState(newState)
        BLU:PrintDebug("[Options/SoundPanel] Toggled event module '" .. tostring(moduleLoadName) .. "' to " .. tostring(newState))
        UpdateToggleState(newState)
        if newState then
            if BLU.LoadModule then BLU:LoadModule("features", moduleLoadName) end
        else
            if BLU.UnloadModule then BLU:UnloadModule(moduleLoadName) end
        end
        C_Timer.After(0, function()
            if toggle and toggle:IsVisible() then UpdateToggleState(IsModuleEnabled()) end
        end)
    end)

    -- Sound dropdowns directly below titleBar
    local dropY = -54
    if eventType == "quest" then
        CreateSoundDropdown(content, "quest", "Quest Turn-In Sound",    dropY,       "questturnin")
        CreateSoundDropdown(content, "quest", "Quest Accept Sound",     dropY - 90,  "questaccept")
        CreateSoundDropdown(content, "quest", "Quest Progress Sound",   dropY - 180, "questprogress")
    elseif eventType == "delvecompanion" then
        CreateSoundDropdown(content, eventType, "Companion Level-Up Sound", dropY)
        CreateSoundDropdown(content, eventType, "Delve Life Lost Sound",    dropY - 90,  "delvelifelost")
        CreateSoundDropdown(content, eventType, "Delve Life Gained Sound",  dropY - 180, "delvelifegained")
    elseif eventType == "achievement" then
        CreateSoundDropdown(content, eventType, eventName .. " Sound",          dropY)
        CreateSoundDropdown(content, eventType, "Achievement Progress Sound",   dropY - 90, "achievementprogress")
    elseif eventType == "battlepet" then
        CreateSoundDropdown(content, eventType, eventName .. " Level-Up Sound", dropY)
        CreateSoundDropdown(content, eventType, "Pet Capture Sound",            dropY - 90, "petcapture")
    else
        CreateSoundDropdown(content, eventType, eventName .. " Sound", dropY)
    end
end

function BLU.CreateHousingPanel(panel)
    BLU:PrintDebug("[Options/SoundPanel] Creating Housing sound panel")
    local content = CreateFrame("Frame", nil, panel)
    content:SetPoint("TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    -- Titlebar: icon + title + module toggle
    local titleBar = CreateFrame("Frame", nil, content, "BackdropTemplate")
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("RIGHT", 0, 0)
    titleBar:SetHeight(44)
    titleBar:SetBackdrop(BLU.Modules.design.Backdrops.Solid)
    titleBar:SetBackdropColor(0.06, 0.10, 0.16, 0.95)
    titleBar:SetBackdropBorderColor(0.10, 0.20, 0.28, 1)

    local icon = titleBar:CreateTexture(nil, "ARTWORK")
    icon:SetSize(24, 24)
    icon:SetPoint("LEFT", 10, 0)
    icon:SetTexture("Interface\\Icons\\Trade_Blacksmithing")

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    title:SetText("|cff05dffaHousing Sounds|r")

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
    toggleBg:SetVertexColor(1, 1, 1, 1)

    local status = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    status:SetPoint("RIGHT", switchFrame, "LEFT", -6, 0)

    local function UpdateToggleState(enabled)
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

    local function IsModuleEnabled()
        if not (BLU.db and BLU.db.profile) then return true end
        local modules = BLU.db.profile.modules
        if modules and modules.housing ~= nil then return modules.housing ~= false end
        if BLU.db.profile.enableHousing ~= nil then return BLU.db.profile.enableHousing ~= false end
        return true
    end

    local function SetModuleEnabledState(enabled)
        BLU.db.profile.modules = BLU.db.profile.modules or {}
        BLU.db.profile.modules.housing = enabled
        BLU.db.profile.enableHousing = enabled
    end

    UpdateToggleState(IsModuleEnabled())

    toggle:SetScript("OnClick", function()
        if not (BLU.db and BLU.db.profile) then return end
        local newState = not IsModuleEnabled()
        SetModuleEnabledState(newState)
        BLU:PrintDebug("[Options/SoundPanel] Toggled Housing module to " .. tostring(newState))
        UpdateToggleState(newState)
        if newState then
            if BLU.LoadModule then BLU:LoadModule("features", "housing") end
        else
            if BLU.UnloadModule then BLU:UnloadModule("housing") end
        end
        C_Timer.After(0, function()
            if toggle and toggle:IsVisible() then UpdateToggleState(IsModuleEnabled()) end
        end)
    end)

    -- Sound dropdowns directly below titleBar
    CreateSoundDropdown(content, "housing", "House XP Gained Sound",       -54,  "housingxpgained")
    CreateSoundDropdown(content, "housing", "House Leveled Up Sound",       -144, "housingleveledup")
    CreateSoundDropdown(content, "housing", "House Rewards Received Sound", -234, "housingrewardsreceived")
    CreateSoundDropdown(content, "housing", "New Decor Collected Sound",    -324, "housingdecorcollected")
end

function SoundPanel:Init()
    BLU:PrintDebug("[SoundPanel] Sound panel module initialized")
end

if BLU.RegisterModule then
    BLU:RegisterModule(SoundPanel, "sound_panel", "Sound Panel")
end

