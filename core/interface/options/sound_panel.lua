--=====================================================================================
-- BLU - interface/options/sound_panel.lua
-- Sound selection panel for events
--=====================================================================================

local BLU = _G["BLU"]

local SoundPanel = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["sound_panel"] = SoundPanel

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
    controlsFrame:SetSize(190, 60)

    local volumeDropdown = CreateFrame("Frame", nil, controlsFrame, "UIDropDownMenuTemplate")
    volumeDropdown:SetPoint("LEFT", 0, 0)
    UIDropDownMenu_SetWidth(volumeDropdown, 120)

    local function setVolume(self, volume)
        if not BLU.db or not BLU.db.profile then return end
        BLU.db.profile.soundVolumes = BLU.db.profile.soundVolumes or {}
        BLU.db.profile.soundVolumes[actualEventType] = volume
        UIDropDownMenu_SetText(volumeDropdown, volume)
    end

    UIDropDownMenu_Initialize(volumeDropdown, function(self)
        local volumes = {"Low", "Medium", "High"}
        for _, volume in ipairs(volumes) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = volume
            info.value = volume:lower()
            info.func = function() setVolume(self, volume:lower()) end
            info.checked = (BLU.db.profile.soundVolumes and BLU.db.profile.soundVolumes[actualEventType] or "medium") == volume:lower()
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetText(volumeDropdown, (BLU.db.profile.soundVolumes and BLU.db.profile.soundVolumes[actualEventType] or "medium"):gsub("^%l", string.upper))

    local testBtn = BLU.Modules.design:CreateButton(controlsFrame, "Test", 60, 22)
    testBtn:SetPoint("LEFT", volumeDropdown, "RIGHT", 10, 0)
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

        local function onSoundSelected(value, text)
            BLU.db.profile.selectedSounds[self.eventId] = value
            UIDropDownMenu_SetText(self, text)
            self.currentSound:SetText(text)
            local soundInfo = BLU.SoundRegistry:GetSound(value)
            if value == "default" then
                volumeDropdown:Show()
            else
                volumeDropdown:Hide()
            end
            CloseDropDownMenus()
        end

        local customHierarchy = BLU.SoundRegistry:GetSoundsGroupedForUI(self.eventId)

        if level == 1 then
            local specialOptions = {
                {text = "|cff00ff00Random|r", value = "random"},
                {text = "None", value = "None"},
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
            sep.notClickable = true; sep.notCheckable = true
            UIDropDownMenu_AddButton(sep, level)

            local sortedTopLevelKeys = {"BLU WoW Defaults", "BLU Other Game Sounds", "Shared Media"}

            for _, groupKey in ipairs(sortedTopLevelKeys) do
                if next(customHierarchy[groupKey]) then
                    local count = 0
                    if groupKey == "BLU WoW Defaults" then
                        count = #customHierarchy[groupKey]
                    else
                        for _, packSounds in pairs(customHierarchy[groupKey]) do count = count + #packSounds end
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

            if groupKey == "BLU WoW Defaults" then
                table.sort(subgroups, function(a, b) return a.name < b.name end)
                for _, sound in ipairs(subgroups) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = sound.name
                    info.value = sound.id
                    info.func = function() onSoundSelected(sound.id, sound.name) end
                    info.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == sound.id
                    UIDropDownMenu_AddButton(info, level)
                end
            else
                local sortedSubKeys = {}
                for subKey in pairs(subgroups) do table.insert(sortedSubKeys, subKey) end
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
            local groupKey = menuList.group
            local subKey = menuList.sub
            local soundsToDisplay = customHierarchy[groupKey][subKey]

            if soundsToDisplay then
                table.sort(soundsToDisplay, function(a, b) return a.name < b.name end)

                for _, sound in ipairs(soundsToDisplay) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = sound.name
                    info.value = sound.id
                    info.func = function() onSoundSelected(sound.id, sound.name) end
                    info.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == sound.id
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end
    end)

    local selectedValue = BLU.db and BLU.db.profile and BLU.db.profile.selectedSounds and BLU.db.profile.selectedSounds[actualEventType] or "None"
    local selectedText = selectedValue
    if selectedValue ~= "None" and selectedValue ~= "default" and selectedValue ~= "random" then
        local soundInfo = BLU.SoundRegistry:GetSound(selectedValue)
        if soundInfo then
            selectedText = soundInfo.name
        end
    end
    UIDropDownMenu_SetText(dropdown, selectedText)
    dropdown.currentSound:SetText(selectedText)

    return container
end

function BLU.CreateEventSoundPanel(panel, eventType, eventName)
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 5)

    local scrollBg = scrollFrame:CreateTexture(nil, "BACKGROUND")
    scrollBg:SetAllPoints()
    scrollBg:SetColorTexture(0.05, 0.05, 0.05, 0.3)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(680)
    scrollFrame:SetScrollChild(content)

    local header = CreateFrame("Frame", nil, content)
    header:SetHeight(45)
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("RIGHT", 0, 0)

    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("LEFT", 0, 0)
    local icons = {
        levelup = "Interface\Icons\Achievement_Level_100",
        achievement = "Interface\Icons\Achievement_GuildPerk_MobileMailbox",
        quest = "Interface\Icons\INV_Misc_Note_01",
        reputation = "Interface\Icons\Achievement_Reputation_01",
        battlepet = "Interface\Icons\INV_Pet_BattlePetTraining",
        honorrank = "Interface\Icons\PVPCurrency-Honor-Horde",
        renownrank = "Interface\Icons\UI_MajorFaction_Renown",
        tradingpost = "Interface\Icons\INV_TradingPostCurrency",
        delvecompanion = "Interface\Icons\UI_MajorFaction_Delve"
    }
    icon:SetTexture(icons[eventType] or "Interface\Icons\INV_Misc_QuestionMark")

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    title:SetText("|cff05dffa" .. eventName .. " Sounds|r")

    local moduleSection = BLU.Modules.design:CreateSection(content, "Module Control", "Interface\Icons\INV_Misc_Gear_08")
    moduleSection:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -10)
    moduleSection:SetPoint("RIGHT", -10, 0)
    moduleSection:SetHeight(140)

    local toggleFrame = CreateFrame("Frame", nil, moduleSection.content)
    toggleFrame:SetPoint("TOPLEFT", BLU.Modules.design.Layout.Spacing, -BLU.Modules.design.Layout.Spacing)
    toggleFrame:SetSize(500, 60)

    local switchFrame = CreateFrame("Frame", nil, toggleFrame)
    switchFrame:SetSize(60, 24)
    switchFrame:SetPoint("LEFT", 0, 0)

    local switchBg = switchFrame:CreateTexture(nil, "BACKGROUND")
    switchBg:SetAllPoints()
    switchBg:SetTexture("Interface\Buttons\WHITE8x8")

    local toggle = CreateFrame("Button", nil, switchFrame)
    toggle:SetSize(28, 28)
    toggle:EnableMouse(true)

    local toggleBg = toggle:CreateTexture(nil, "ARTWORK")
    toggleBg:SetAllPoints()
    toggleBg:SetTexture("Interface\Buttons\WHITE8x8")
    toggleBg:SetVertexColor(1, 1, 1, 1)

    local moduleText = toggleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    moduleText:SetPoint("LEFT", switchFrame, "RIGHT", 15, 5)
    moduleText:SetText("Enable " .. eventName .. " Module")

    local moduleDesc = toggleFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    moduleDesc:SetPoint("TOPLEFT", moduleText, "BOTTOMLEFT", 0, -3)
    moduleDesc:SetText("When enabled, BLU will respond to " .. eventName:lower() .. " events and play custom sounds")
    moduleDesc:SetTextColor(0.7, 0.7, 0.7)

    local status = toggleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    status:SetPoint("RIGHT", toggleFrame, "RIGHT", -10, 0)

    local function UpdateToggleState(enabled)
        if enabled then
            toggle:SetPoint("RIGHT", switchFrame, "RIGHT", -2, 0)
            switchBg:SetVertexColor(unpack(BLU.Modules.design.Colors.Primary))
            status:SetText("|cff00ff00ENABLED|r")
        else
            toggle:SetPoint("LEFT", switchFrame, "LEFT", 2, 0)
            switchBg:SetVertexColor(0.3, 0.3, 0.3, 1)
            status:SetText("|cffff0000DISABLED|r")
        end
    end

    local enabled = true
    if BLU.db and BLU.db.profile and BLU.db.profile.modules then
        enabled = BLU.db.profile.modules[eventType] ~= false
    end
    UpdateToggleState(enabled)

    toggle:SetScript("OnClick", function(self)
        if not BLU.db or not BLU.db.profile then
            BLU:PrintError("Database not ready. Please try again.")
            return
        end
        BLU.db.profile.modules = BLU.db.profile.modules or {}
        local currentlyEnabled = BLU.db.profile.modules[eventType] ~= false
        local newState = not currentlyEnabled

        BLU.db.profile.modules[eventType] = newState
        UpdateToggleState(newState)

        if newState then
            if BLU.LoadModule then
                BLU:LoadModule("features", eventType)
            end
        else
            if BLU.UnloadModule then
                BLU:UnloadModule(eventType)
            end
        end
    end)

    local soundSection = BLU.Modules.design:CreateSection(content, "Sound Selection", "Interface\Icons\INV_Misc_Bell_01")
    soundSection:SetPoint("TOPLEFT", moduleSection, "BOTTOMLEFT", 0, -10)
    soundSection:SetPoint("RIGHT", -20, 0)

    local sectionHeight = (eventType == "quest") and 260 or 150
    soundSection:SetHeight(sectionHeight)

    if eventType == "quest" then
        CreateSoundDropdown(soundSection.content, "quest", "Quest Complete Sound", -5, "quest_complete")
        CreateSoundDropdown(soundSection.content, "quest", "Quest Progress Sound", -95, "quest_progress")
    else
        CreateSoundDropdown(soundSection.content, eventType, eventName .. " Sound", -5)
    end

    local contentHeight = (eventType == "quest") and 450 or 400
    content:SetHeight(contentHeight)
end

function SoundPanel:Init()
    BLU:PrintDebug("[SoundPanel] Sound panel module initialized")
end

if BLU.RegisterModule then
    BLU:RegisterModule(SoundPanel, "sound_panel", "Sound Panel")
end