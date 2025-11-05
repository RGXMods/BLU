--=====================================================================================
-- BLU - interface/sound_panel.lua
-- Sound selection panel for each event type
--=====================================================================================

local addonName, BLU = ...

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

    local moduleSection = BLU.Design:CreateSection(content, "Module Control", "Interface\Icons\INV_Misc_Gear_08")
    moduleSection:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -10)
    moduleSection:SetPoint("RIGHT", 0, 0)
    moduleSection:SetHeight(110)

    local toggleFrame = CreateFrame("Frame", nil, moduleSection.content)
    toggleFrame:SetPoint("TOPLEFT", BLU.Design.Layout.Spacing, -BLU.Design.Layout.Spacing)
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
            switchBg:SetVertexColor(unpack(BLU.Design.Colors.Primary))
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

    local soundSection = BLU.Design:CreateSection(content, "Sound Selection", "Interface\Icons\INV_Misc_Bell_01")
    soundSection:SetPoint("TOPLEFT", moduleSection, "BOTTOMLEFT", 0, -10)
    soundSection:SetPoint("RIGHT", 0, 0)

    local sectionHeight = (eventType == "quest") and 260 or 150
    soundSection:SetHeight(sectionHeight)

    if eventType == "quest" then
        BLU:CreateSoundDropdown(soundSection.content, "quest", "Quest Complete Sound", -5, "quest_complete")
        BLU:CreateSoundDropdown(soundSection.content, "quest", "Quest Progress Sound", -95, "quest_progress")
    else
        BLU:CreateSoundDropdown(soundSection.content, eventType, eventName .. " Sound", -5)
    end

    local contentHeight = (eventType == "quest") and 450 or 400
    content:SetHeight(contentHeight)
end

function BLU:CreateSoundDropdown(parent, eventType, label, yOffset, soundType)
    local actualEventType = soundType or eventType

    local container = CreateFrame("Frame", nil, parent)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
    container:SetPoint("RIGHT", parent, "RIGHT", -10, 0)
    container:SetHeight(90)

    local dropdownLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdownLabel:SetPoint("TOPLEFT", 10, -5)
    dropdownLabel:SetText(BLU.Design.Colors.PrimaryHex .. label .. "|r")

    local currentLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    currentLabel:SetPoint("TOPLEFT", dropdownLabel, "BOTTOMLEFT", 0, -5)
    currentLabel:SetText("Currently selected: ")
    currentLabel:SetTextColor(0.7, 0.7, 0.7)

    local currentSound = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    currentSound:SetPoint("LEFT", currentLabel, "RIGHT", 5, 0)
    currentSound:SetTextColor(0.02, 0.87, 0.98)

    local controlsFrame = CreateFrame("Frame", nil, container)
    controlsFrame:SetPoint("TOPRIGHT", container, "TOPRIGHT", -10, -20)
    controlsFrame:SetSize(180, 60)

    local volumeSlider = CreateFrame("Slider", nil, controlsFrame, "OptionsSliderTemplate")
    volumeSlider:SetSize(100, 20)
    volumeSlider:SetPoint("LEFT", 0, 0)
    volumeSlider:SetMinMaxValues(0, 100)
    volumeSlider:SetValueStep(5)
    volumeSlider:SetObeyStepOnDrag(true)

    volumeSlider.Text:SetText("Volume")
    volumeSlider.Low:SetText("0")
    volumeSlider.High:SetText("100")

    local volume = 100
    if BLU.db and BLU.db.profile and BLU.db.profile.soundVolumes then
        volume = BLU.db.profile.soundVolumes[actualEventType] or 100
    end
    volumeSlider:SetValue(volume)

    local volumeValue = controlsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    volumeValue:SetPoint("TOP", volumeSlider, "BOTTOM", 0, -2)
    volumeValue:SetText(volume .. "%")

    volumeSlider:SetScript("OnValueChanged", function(self, value)
        volumeValue:SetText(math.floor(value) .. "%")
        if BLU.db and BLU.db.profile then
            BLU.db.profile.soundVolumes = BLU.db.profile.soundVolumes or {}
            BLU.db.profile.soundVolumes[actualEventType] = value
        end
    end)

    local testBtn = BLU.Design:CreateButton(controlsFrame, "Test", 60, 22)
    testBtn:SetPoint("RIGHT", 0, 0)
    testBtn:SetScript("OnClick", function(self)
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

        if not BLU.db or not BLU.db.profile then
            return
        end
        BLU.db.profile.selectedSounds = BLU.db.profile.selectedSounds or {}

        if level == 1 then
            local info = UIDropDownMenu_CreateInfo()
            info.text = "Default WoW Sound"
            info.value = "default"
            info.func = function()
                BLU.db.profile.selectedSounds[self.eventId] = "default"
                UIDropDownMenu_SetText(self, "Default WoW Sound")
                self.currentSound:SetText("Default WoW Sound")
                CloseDropDownMenus()
            end
            info.checked = BLU.db.profile.selectedSounds[self.eventId] == "default"
            UIDropDownMenu_AddButton(info, level)

            info = UIDropDownMenu_CreateInfo()
            info.text = "|cffffff00WoW Game Sounds|r"
            info.value = "wow_sounds"
            info.hasArrow = true
            info.menuList = "wow_sounds"
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)

            info = UIDropDownMenu_CreateInfo()
            info.text = "|cff05dffaBLU Sound Packs|r"
            info.value = "blu_builtin"
            info.hasArrow = true
            info.menuList = "blu_builtin"
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)

            if BLU.Modules.sharedmedia and BLU.Modules.sharedmedia.GetSoundCategories then
                local success, categories = pcall(function() return BLU.Modules.sharedmedia:GetSoundCategories() end)
                if success and categories and type(categories) == "table" then
                    local categoryCount = 0
                    for category, sounds in pairs(categories) do
                        if sounds and type(sounds) == "table" and #sounds > 0 then
                            categoryCount = categoryCount + 1
                            info = UIDropDownMenu_CreateInfo()
                            info.text = "|cffffff00" .. category .. "|r (" .. #sounds .. ")"
                            info.value = category
                            info.hasArrow = true
                            info.menuList = category
                            info.notCheckable = true
                            UIDropDownMenu_AddButton(info, level)
                        end
                    end

                    if categoryCount > 0 then
                        info = UIDropDownMenu_CreateInfo()
                        info.text = ""
                        info.notClickable = true
                        info.notCheckable = true
                        UIDropDownMenu_AddButton(info, level)
                    end
                end
            end

            info = UIDropDownMenu_CreateInfo()
            info.text = "|cff888888Browse Sound Files...|r"
            info.value = "browse"
            info.func = function()
                BLU:Print("Sound browser not yet implemented")
                CloseDropDownMenus()
            end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
        elseif level == 2 then
            if menuList == "blu_builtin" then
                local builtinSounds = {}

                if BLU.Modules and BLU.Modules.registry and BLU.Modules.registry.GetSoundsByCategory then
                    local categorySounds = BLU.Modules.registry:GetSoundsByCategory(dropdown.eventId)
                    local packNames = {}

                    for soundId, soundData in pairs(categorySounds) do
                        local packName = soundId:match("^(.+)_" .. dropdown.eventId)
                        if packName and not packNames[packName] then
                            packNames[packName] = true
                            local displayName = packName:gsub("^%l", string.upper):gsub("_", " ")
                            local nameMap = {
                                finalfantasy = "Final Fantasy",
                                zelda = "Legend of Zelda",
                                pokemon = "Pokemon",
                                mario = "Super Mario",
                                sonic = "Sonic the Hedgehog",
                                elderscrolls = "Elder Scrolls",
                                witcher = "The Witcher",
                                diablo = "Diablo",
                                warcraft = "Warcraft",
                                allgames = "All Games Mix"
                            }
                            displayName = nameMap[packName] or displayName
                            table.insert(builtinSounds, {value = soundId, text = displayName})
                        end
                    end
                else
                    builtinSounds = {
                        {value = "finalfantasy_" .. dropdown.eventId, text = "Final Fantasy"},
                        {value = "zelda_" .. dropdown.eventId, text = "Legend of Zelda"},
                        {value = "pokemon_" .. dropdown.eventId, text = "Pokemon"},
                        {value = "mario_" .. dropdown.eventId, text = "Super Mario"},
                        {value = "sonic_" .. dropdown.eventId, text = "Sonic the Hedgehog"},
                        {value = "elderscrolls_" .. dropdown.eventId, text = "Elder Scrolls"},
                        {value = "witcher_" .. dropdown.eventId, text = "The Witcher"},
                        {value = "diablo_" .. dropdown.eventId, text = "Diablo"},
                        {value = "warcraft_" .. dropdown.eventId, text = "Warcraft"},
                        {value = "allgames_" .. dropdown.eventId, text = "All Games Mix"}
                    }
                end

                for _, sound in ipairs(builtinSounds) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = sound.text
                    info.value = sound.value
                    info.func = function()
                        BLU.db.profile.selectedSounds[dropdown.eventId] = sound.value
                        UIDropDownMenu_SetText(dropdown, sound.text)
                        dropdown.currentSound:SetText(sound.text)
                        CloseDropDownMenus()
                    end
                    info.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == sound.value
                    UIDropDownMenu_AddButton(info, level)
                end
            elseif menuList == "wow_sounds" then
                local wowSounds = {
                    levelup = {
                        {value = "wow_levelup_fanfare", text = "Level Up Fanfare"},
                        {value = "wow_levelup_ding", text = "Level Ding"},
                        {value = "wow_levelup_gong", text = "Gong"},
                        {value = "wow_levelup_epic", text = "Epic Victory"}
                    },
                    achievement = {
                        {value = "wow_achievement_default", text = "Achievement Earned"},
                        {value = "wow_achievement_guild", text = "Guild Achievement"},
                        {value = "wow_achievement_legendary", text = "Legendary Alert"}
                    },
                    quest = {
                        {value = "wow_quest_complete", text = "Quest Complete"},
                        {value = "wow_quest_objective", text = "Quest Objective"},
                        {value = "wow_quest_accepted", text = "Quest Accepted"}
                    },
                    quest_complete = {
                        {value = "wow_quest_complete", text = "Quest Complete"},
                        {value = "wow_quest_objective", text = "Quest Objective Complete"},
                        {value = "wow_bonus_objective", text = "Bonus Objective"}
                    },
                    quest_progress = {
                        {value = "wow_quest_progress", text = "Quest Progress"},
                        {value = "wow_quest_accepted", text = "Quest Accepted"},
                        {value = "wow_quest_objective", text = "Objective Update"}
                    },
                    reputation = {
                        {value = "wow_rep_increase", text = "Reputation Increase"},
                        {value = "wow_rep_rank", text = "Reputation Rank Up"},
                        {value = "wow_rep_exalted", text = "Exalted!"}
                    },
                    battlepet = {
                        {value = "wow_pet_victory", text = "Pet Battle Victory"},
                        {value = "wow_pet_capture", text = "Pet Captured"},
                        {value = "wow_pet_levelup", text = "Pet Level Up"}
                    },
                    honor = {
                        {value = "wow_honor_rank", text = "Honor Rank Up"},
                        {value = "wow_pvp_victory", text = "PvP Victory"}
                    },
                    renown = {
                        {value = "wow_renown_rank", text = "Renown Rank Up"},
                        {value = "wow_covenant_renown", text = "Covenant Renown"}
                    },
                    tradingpost = {
                        {value = "wow_trading_complete", text = "Trading Post Complete"},
                        {value = "wow_trading_reward", text = "Trading Post Reward"}
                    },
                    delve = {
                        {value = "wow_delve_complete", text = "Delve Complete"},
                        {value = "wow_delve_companion", text = "Companion Level"}
                    }
                }
                local eventSounds = wowSounds[dropdown.eventId] or wowSounds[eventType] or {}
                for _, sound in ipairs(eventSounds) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = sound.text
                    info.value = sound.value
                    info.func = function()
                        BLU.db.profile.selectedSounds[dropdown.eventId] = sound.value
                        UIDropDownMenu_SetText(dropdown, sound.text)
                        dropdown.currentSound:SetText(sound.text)
                        CloseDropDownMenus()
                    end
                    info.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == sound.value
                    UIDropDownMenu_AddButton(info, level)
                end
            else
                if BLU.Modules.sharedmedia and BLU.Modules.sharedmedia.GetSoundCategories then
                    local categories = BLU.Modules.sharedmedia:GetSoundCategories()
                    if categories and categories[menuList] then
                        for _, soundName in ipairs(categories[menuList]) do
                            local info = UIDropDownMenu_CreateInfo()
                            info.text = soundName
                            info.value = "external:" .. soundName
                            info.func = function()
                                BLU.db.profile.selectedSounds[dropdown.eventId] = "external:" .. soundName
                                UIDropDownMenu_SetText(dropdown, soundName)
                                dropdown.currentSound:SetText(soundName)
                                CloseDropDownMenus()
                            end
                            info.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == "external:" .. soundName
                            UIDropDownMenu_AddButton(info, level)
                        end
                    end
                end
            end
        end
    end)

    C_Timer.After(0.1, function()
        local currentValue = "default"
        if BLU.db and BLU.db.profile and BLU.db.profile.selectedSounds then
            currentValue = BLU.db.profile.selectedSounds[actualEventType] or "default"
        end

        if currentValue == "default" then
            UIDropDownMenu_SetText(dropdown, "Default WoW Sound")
            currentSound:SetText("Default WoW Sound")
        elseif currentValue:match("^external:") then
            local soundName = currentValue:gsub("^external:", "")
            UIDropDownMenu_SetText(dropdown, soundName)
            currentSound:SetText(soundName)
        elseif currentValue:match("^wow_") then
            UIDropDownMenu_SetText(dropdown, "WoW Sound")
            currentSound:SetText("WoW Sound")
        else
            local packName = currentValue:match("^(.+)_" .. actualEventType .. "$")
            if packName then
                local packNames = {
                    finalfantasy = "Final Fantasy",
                    zelda = "Legend of Zelda",
                    pokemon = "Pokemon",
                    mario = "Super Mario",
                    sonic = "Sonic the Hedgehog",
                    metalgear = "Metal Gear Solid",
                    elderscrolls = "Elder Scrolls",
                    warcraft = "Warcraft",
                    eldenring = "Elden Ring",
                    castlevania = "Castlevania",
                    diablo = "Diablo",
                    fallout = "Fallout",
                    blu_default = "BLU Defaults"
                }
                local displayName = packNames[packName] or packName
                UIDropDownMenu_SetText(dropdown, displayName)
                currentSound:SetText(displayName)
            end
        end
    end)

    return container
end

if BLU.RegisterModule then
    BLU:RegisterModule("sound_panel", BLU)
end
