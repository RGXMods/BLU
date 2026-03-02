--=====================================================================================
-- BLU - interface/options/sound_panel.lua
-- Sound selection panel for events
--=====================================================================================

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
}

local function CreateSoundDropdown(parent, eventType, label, yOffset, soundType)
    local actualEventType = soundType or eventType

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

    local controlsFrame = CreateFrame("Frame", nil, container)
    controlsFrame:SetPoint("TOPRIGHT", container, "TOPRIGHT", -150, -20)
    controlsFrame:SetSize(230, 60)

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
    volumeSlider:SetPoint("LEFT", 6, 2)
    volumeSlider:SetWidth(130)
    volumeSlider:SetMinMaxValues(1, 3)
    volumeSlider:SetValueStep(1)
    volumeSlider:SetObeyStepOnDrag(true)
    volumeSlider.Low:SetText("Low")
    volumeSlider.High:SetText("High")
    volumeSlider.Text:SetText("")

    local sliderValue = controlsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sliderValue:SetPoint("TOP", volumeSlider, "BOTTOM", 0, -2)
    sliderValue:SetText("Medium")

    local sliderUpdating = false
    local function setVolumeSliderValue(volume)
        local step = volumeToStep(volume)
        sliderUpdating = true
        volumeSlider:SetValue(step)
        sliderUpdating = false
        sliderValue:SetText(volume:gsub("^%l", string.upper))
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
        sliderValue:SetText(volume:gsub("^%l", string.upper))

        if not BLU.db or not BLU.db.profile then
            return
        end
        BLU.db.profile.soundVolumes = BLU.db.profile.soundVolumes or {}
        BLU.db.profile.soundVolumes[actualEventType] = volume
    end)

    local initialVolume = (BLU.db and BLU.db.profile and BLU.db.profile.soundVolumes and BLU.db.profile.soundVolumes[actualEventType]) or "medium"
    setVolumeSliderValue(initialVolume)

    local channelHint = controlsFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    channelHint:SetPoint("LEFT", 8, 2)
    channelHint:SetPoint("RIGHT", -72, 2)
    channelHint:SetJustifyH("LEFT")
    channelHint:SetText("Uses game channel")
    channelHint:Hide()

    local function isBluVolumeSelection(selectionValue)
        if not selectionValue or selectionValue == "default" or selectionValue == "random" then
            return true
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

        return soundInfo.source == "BLU" or soundInfo.source == "BLU Built-in" or soundInfo.isInternal == true
    end

    local function updateSoundControlMode(selectionValue)
        if isBluVolumeSelection(selectionValue) then
            local stored = (BLU.db and BLU.db.profile and BLU.db.profile.soundVolumes and BLU.db.profile.soundVolumes[actualEventType]) or "medium"
            setVolumeSliderValue(stored)
            volumeSlider:Show()
            sliderValue:Show()
            volumeSlider.Low:Show()
            volumeSlider.High:Show()
            channelHint:Hide()
        else
            volumeSlider:Hide()
            sliderValue:Hide()
            volumeSlider.Low:Hide()
            volumeSlider.High:Hide()
            channelHint:Show()
        end
    end

    local testBtn = BLU.Modules.design:CreateButton(controlsFrame, "Test", 60, 22)
    testBtn:SetPoint("RIGHT", controlsFrame, "RIGHT", 0, 2)
    testBtn:SetScript("OnClick", function(self)
        BLU:PrintDebug("Test button clicked for event: " .. actualEventType)
        local selectedSound = BLU.db and BLU.db.profile and BLU.db.profile.selectedSounds and BLU.db.profile.selectedSounds[actualEventType]
        BLU:PrintDebug("Selected sound is: " .. tostring(selectedSound))

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
        level = level or 1

        if not BLU.db or not BLU.db.profile then return end
        BLU.db.profile.selectedSounds = BLU.db.profile.selectedSounds or {}

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
            CloseDropDownMenus()
        end

        local function previewSound(soundId)
            if soundId and BLU.SoundRegistry and BLU.SoundRegistry.PlaySound then
                BLU.SoundRegistry:PlaySound(soundId)
            end
        end

        local function addSoundSelectAndPreviewEntries(levelToUse, soundId, soundName)
            local selectInfo = UIDropDownMenu_CreateInfo()
            selectInfo.text = soundName .. "  |cff7fd0ff|TInterface\\Buttons\\UI-SpellbookIcon-NextPage-Up:12:12:0:0|t|r"
            selectInfo.value = soundId
            selectInfo.func = function()
                onSoundSelected(soundId, soundName)
                previewSound(soundId)
            end
            selectInfo.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == soundId
            UIDropDownMenu_AddButton(selectInfo, levelToUse)
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
            end

            local sep = UIDropDownMenu_CreateInfo()
            sep.notClickable = true
            sep.notCheckable = true
            UIDropDownMenu_AddButton(sep, level)

            local sortedTopLevelKeys = {"BLU WoW Defaults", "BLU Other Game Sounds", "Shared Media"}

            for _, groupKey in ipairs(sortedTopLevelKeys) do
                if hasEntries(customHierarchy[groupKey]) then
                    local count = 0
                    if groupKey == "BLU WoW Defaults" then
                        count = #customHierarchy[groupKey]
                    else
                        for _, packSounds in pairs(customHierarchy[groupKey]) do
                            count = count + #packSounds
                        end
                    end

                    local info = UIDropDownMenu_CreateInfo()
                    info.text = "|cffffff00" .. groupKey .. "|r (" .. count .. ")"
                    info.value = groupKey
                    info.hasArrow = true
                    info.menuList = groupKey
                    info.notCheckable = true
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        elseif level == 2 then
            local groupKey = menuList
            local subgroups = customHierarchy[groupKey]
            if type(subgroups) ~= "table" then
                return
            end

            if groupKey == "BLU WoW Defaults" then
                table.sort(subgroups, function(a, b) return a.name < b.name end)
                for _, sound in ipairs(subgroups) do
                    addSoundSelectAndPreviewEntries(level, sound.id, sound.name)
                end
            else
                local sortedSubKeys = {}
                for subKey in pairs(subgroups) do
                    table.insert(sortedSubKeys, subKey)
                end
                table.sort(sortedSubKeys)

                for _, subKey in ipairs(sortedSubKeys) do
                    local sounds = subgroups[subKey]
                    local info = UIDropDownMenu_CreateInfo()
                    info.value = subKey
                    info.notCheckable = true
                    info.hasArrow = true
                    info.menuList = {group = groupKey, sub = subKey, type = "pack"}
                    info.text = subKey .. " (" .. #sounds .. ")"
                    UIDropDownMenu_AddButton(info, level)
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
                table.sort(soundsToDisplay, function(a, b) return a.name < b.name end)

                for _, sound in ipairs(soundsToDisplay) do
                    addSoundSelectAndPreviewEntries(level, sound.id, sound.name)
                end
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
    local content = CreateFrame("Frame", nil, panel)
    content:SetPoint("TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    local header = CreateFrame("Frame", nil, content)
    header:SetHeight(44)
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("RIGHT", 0, 0)

    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("LEFT", 0, 0)
    local icons = {
        levelup = "Interface\\Icons\\Achievement_Level_100",
        achievement = "Interface\\Icons\\Achievement_GuildPerk_MobileMailbox",
        quest = "Interface\\Icons\\INV_Misc_Note_01",
        reputation = "Interface\\Icons\\Achievement_Reputation_01",
        battlepet = "Interface\\Icons\\INV_Pet_BattlePetTraining",
        honorrank = "Interface\\Icons\\PVPCurrency-Honor-Horde",
        renownrank = "Interface\\Icons\\UI_MajorFaction_Centaur",
        tradingpost = "Interface\\Icons\\INV_Tradingpost_Currency",
        delvecompanion = "Interface\\Icons\\UI_MajorFaction_Delve"
    }
    icon:SetTexture(icons[eventType] or "Interface\\Icons\\INV_Misc_QuestionMark")

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    title:SetText("|cff05dffa" .. eventName .. " Sounds|r")

    local moduleSection = BLU.Modules.design:CreateSection(content, "Module Control", "Interface\\Icons\\INV_Misc_Gear_08")
    moduleSection:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -8)
    moduleSection:SetPoint("RIGHT", -10, 0)
    moduleSection:SetHeight(86)

    local toggleFrame = CreateFrame("Frame", nil, moduleSection.content)
    toggleFrame:SetPoint("TOPLEFT", 0, 0)
    toggleFrame:SetPoint("RIGHT", 0, 0)
    toggleFrame:SetHeight(26)

    local switchFrame = CreateFrame("Frame", nil, toggleFrame)
    switchFrame:SetSize(44, 20)
    switchFrame:SetPoint("LEFT", 0, 0)

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

    local moduleText = toggleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    moduleText:SetPoint("LEFT", switchFrame, "RIGHT", 10, 0)
    moduleText:SetText("Enable " .. eventName .. " Module")

    local status = toggleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    status:SetPoint("RIGHT", toggleFrame, "RIGHT", -4, 0)

    local function UpdateToggleState(enabled)
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

    local moduleToggleKey = eventType
    local moduleLoadName = EVENT_MODULE_MAP[eventType] or eventType
    local enabled = true
    if BLU.db and BLU.db.profile and BLU.db.profile.modules then
        enabled = BLU.db.profile.modules[moduleToggleKey] ~= false
    end
    UpdateToggleState(enabled)

    toggle:SetScript("OnClick", function(self)
        if not BLU.db or not BLU.db.profile then
            BLU:PrintError("Database not ready. Please try again.")
            return
        end
        BLU.db.profile.modules = BLU.db.profile.modules or {}
        local currentlyEnabled = BLU.db.profile.modules[moduleToggleKey] ~= false
        local newState = not currentlyEnabled

        BLU.db.profile.modules[moduleToggleKey] = newState
        UpdateToggleState(newState)

        if newState then
            if BLU.LoadModule then
                BLU:LoadModule("features", moduleLoadName)
            end
        else
            if BLU.UnloadModule then
                BLU:UnloadModule(moduleLoadName)
            end
        end
    end)

    local soundSection = BLU.Modules.design:CreateSection(content, "Sound Selection", "Interface\\Icons\\INV_Misc_Bell_01")
    soundSection:SetPoint("TOPLEFT", moduleSection, "BOTTOMLEFT", 0, -8)
    soundSection:SetPoint("RIGHT", -10, 0)

    local sectionHeight = (eventType == "quest") and 240 or 130
    soundSection:SetHeight(sectionHeight)

    if eventType == "quest" then
        CreateSoundDropdown(soundSection.content, "quest", "Quest Turn-In Sound", -5, "questturnin")
        CreateSoundDropdown(soundSection.content, "quest", "Quest Accept Sound", -95, "questaccept")
    else
        CreateSoundDropdown(soundSection.content, eventType, eventName .. " Sound", -5)
    end
end

function SoundPanel:Init()
    BLU:PrintDebug("[SoundPanel] Sound panel module initialized")
end

if BLU.RegisterModule then
    BLU:RegisterModule(SoundPanel, "sound_panel", "Sound Panel")
end

