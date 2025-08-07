--=====================================================================================
-- BLU - interface/panels/quest_panel.lua
-- Special Quest panel with both Accept and Turn In sound options
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateQuestPanel(panel)
    -- Create scrollable content with standardized positioning
    local scrollFrame, content = BLU.Design:CreatePanelScrollFrame(panel, 900)
    
    -- Event header
    local header = CreateFrame("Frame", nil, content)
    header:SetHeight(50)
    header:SetPoint("TOPLEFT", BLU.Design.Layout.ContentMargin, -BLU.Design.Layout.ContentMargin)
    header:SetPoint("RIGHT", -BLU.Design.Layout.ContentMargin, 0)
    
    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("LEFT", 0, 0)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
    
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    title:SetText("|cff05dffaB|retter |cff05dffaL|revel-|cff05dffaU|rp! Quest Events")
    
    -- Module enable/disable section
    local moduleSection = BLU.Design:CreateSection(content, "Module Control", "Interface\\Icons\\INV_Misc_Gear_08")
    moduleSection:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -BLU.Design.Layout.SectionSpacing)
    moduleSection:SetPoint("RIGHT", -BLU.Design.Layout.ContentMargin, 0)
    moduleSection:SetHeight(120)
    
    -- Enable toggle
    local toggleFrame = CreateFrame("Frame", nil, moduleSection.content)
    toggleFrame:SetPoint("TOPLEFT", 10, -10)
    toggleFrame:SetSize(500, 60)
    
    -- Toggle switch
    local switchFrame = CreateFrame("Frame", nil, toggleFrame)
    switchFrame:SetSize(60, 24)
    switchFrame:SetPoint("LEFT", 0, 0)
    
    local switchBg = switchFrame:CreateTexture(nil, "BACKGROUND")
    switchBg:SetAllPoints()
    switchBg:SetTexture("Interface\\Buttons\\WHITE8x8")
    
    local toggle = CreateFrame("Button", nil, switchFrame)
    toggle:SetSize(28, 28)
    toggle:EnableMouse(true)
    
    local toggleBg = toggle:CreateTexture(nil, "ARTWORK")
    toggleBg:SetAllPoints()
    toggleBg:SetTexture("Interface\\Buttons\\WHITE8x8")
    toggleBg:SetVertexColor(1, 1, 1, 1)
    
    -- Module text
    local moduleText = toggleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    moduleText:SetPoint("LEFT", switchFrame, "RIGHT", 15, 5)
    moduleText:SetText("Enable Quest Module")
    
    local moduleDesc = toggleFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    moduleDesc:SetPoint("TOPLEFT", moduleText, "BOTTOMLEFT", 0, -3)
    moduleDesc:SetText("When enabled, |cff05dffaB|retter |cff05dffaL|revel-|cff05dffaU|rp! will respond to quest accept and turn-in events")
    moduleDesc:SetTextColor(0.7, 0.7, 0.7)
    
    -- Status text
    local status = toggleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    status:SetPoint("RIGHT", toggleFrame, "RIGHT", -10, 0)
    
    -- Initialize state and update function
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
    
    -- Set initial state
    local enabled = true
    if BLU.db and BLU.db.profile and BLU.db.profile.modules then
        enabled = BLU.db.profile.modules.quest ~= false
    end
    UpdateToggleState(enabled)
    
    -- Click handler
    toggle:SetScript("OnClick", function(self)
        BLU.db.profile.modules = BLU.db.profile.modules or {}
        local currentlyEnabled = BLU.db.profile.modules.quest ~= false
        local newState = not currentlyEnabled
        
        BLU.db.profile.modules.quest = newState
        UpdateToggleState(newState)
        
        -- Load/unload module
        if newState then
            if BLU.LoadModule then
                BLU:LoadModule("features", "quest")
            end
        else
            if BLU.UnloadModule then
                BLU:UnloadModule("quest")
            end
        end
    end)
    
    -- Helper function to create sound selection for each quest event
    local function CreateQuestSoundSelection(parent, questEventType, questEventName, yOffset)
        local section = BLU.Design:CreateSection(parent, questEventName .. " Sound", "Interface\\Icons\\INV_Misc_Bell_01")
        section:SetPoint("TOPLEFT", 0, yOffset)
        section:SetPoint("RIGHT", -BLU.Design.Layout.ContentMargin, 0)
        section:SetHeight(200)
        
        -- Current sound display
        local currentLabel = section.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        currentLabel:SetPoint("TOPLEFT", BLU.Design.Layout.Spacing, -BLU.Design.Layout.Spacing)
        currentLabel:SetText("Current Sound:")
        
        local currentSound = section.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        currentSound:SetPoint("LEFT", currentLabel, "RIGHT", BLU.Design.Layout.Spacing, 0)
        
        -- Test button
        local testBtn = BLU.Design:CreateButton(section.content, "Test", 80, 25)
        testBtn:SetPoint("LEFT", currentSound, "RIGHT", BLU.Design.Layout.Padding, 0)
        testBtn:SetScript("OnClick", function(self)
            self:SetText("Playing...")
            self:Disable()
            
            -- Play sound
            if BLU.PlayCategorySound then
                BLU:PlayCategorySound(questEventType)
            elseif BLU.Modules.registry and BLU.Modules.registry.PlayCategorySound then
                BLU.Modules.registry:PlayCategorySound(questEventType)
            end
            
            C_Timer.After(2, function()
                self:SetText("Test")
                self:Enable()
            end)
        end)
        
        -- Sound dropdown
        local dropdownContainer = BLU.Design:CreateDropdown(section.content, "Select Sound:", 280)
        dropdownContainer:SetPoint("TOPLEFT", currentLabel, "BOTTOMLEFT", 0, -(BLU.Design.Layout.Spacing + 10))
        local dropdown = dropdownContainer.dropdown
        
        -- Initialize dropdown
        dropdown.eventId = questEventType
        UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
            level = level or 1
            
            BLU.db.profile.selectedSounds = BLU.db.profile.selectedSounds or {}
            
            if level == 1 then
                -- Default option
                local info = UIDropDownMenu_CreateInfo()
                info.text = "Default WoW Sound"
                info.value = "default"
                info.func = function()
                    BLU.db.profile.selectedSounds[self.eventId] = "default"
                    UIDropDownMenu_SetText(self, "Default WoW Sound")
                    currentSound:SetText("Default WoW Sound")
                    CloseDropDownMenus()
                end
                info.checked = BLU.db.profile.selectedSounds[self.eventId] == "default"
                UIDropDownMenu_AddButton(info, level)
                
                -- WoW's built-in sounds
                info = UIDropDownMenu_CreateInfo()
                info.text = "|cffffff00WoW Game Sounds|r"
                info.value = "wow_sounds"
                info.hasArrow = true
                info.menuList = "wow_sounds"
                info.notCheckable = true
                UIDropDownMenu_AddButton(info, level)
                
                -- BLU internal sounds
                info = UIDropDownMenu_CreateInfo()
                info.text = "|cff05dffaBLU Sound Packs|r"
                info.value = "blu_sounds"
                info.hasArrow = true
                info.menuList = "blu_sounds"
                info.notCheckable = true
                UIDropDownMenu_AddButton(info, level)
                
                -- Check for SharedMedia sounds
                if BLU.Modules.sharedmedia and BLU.Modules.sharedmedia.GetSoundCategories then
                    local categories = BLU.Modules.sharedmedia:GetSoundCategories()
                    if categories and next(categories) then
                        info = UIDropDownMenu_CreateInfo()
                        info.text = "|cff00ff00SharedMedia Sounds|r"
                        info.value = "sharedmedia"
                        info.hasArrow = true
                        info.menuList = "sharedmedia"
                        info.notCheckable = true
                        UIDropDownMenu_AddButton(info, level)
                    end
                end
            elseif level == 2 then
                if menuList == "wow_sounds" then
                    -- Add some common WoW quest sounds
                    local wowSounds = {
                        {text = "Quest Complete", value = "Interface\\AddOns\\BLU\\media\\sounds\\wow\\QuestComplete.ogg"},
                        {text = "Quest Add", value = "Interface\\AddOns\\BLU\\media\\sounds\\wow\\QuestAdd.ogg"},
                        {text = "Objective Complete", value = "Interface\\AddOns\\BLU\\media\\sounds\\wow\\ObjectiveComplete.ogg"},
                    }
                    
                    for _, sound in ipairs(wowSounds) do
                        local info = UIDropDownMenu_CreateInfo()
                        info.text = sound.text
                        info.value = sound.value
                        info.func = function()
                            BLU.db.profile.selectedSounds[dropdown.eventId] = sound.value
                            UIDropDownMenu_SetText(dropdown, sound.text)
                            currentSound:SetText(sound.text)
                            CloseDropDownMenus()
                        end
                        info.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == sound.value
                        UIDropDownMenu_AddButton(info, level)
                    end
                elseif menuList == "blu_sounds" then
                    -- Get BLU internal sounds for quests
                    if BLU.Modules.registry and BLU.Modules.registry.GetSoundsForCategory then
                        local sounds = BLU.Modules.registry:GetSoundsForCategory(questEventType)
                        if sounds then
                            for _, sound in ipairs(sounds) do
                                local info = UIDropDownMenu_CreateInfo()
                                info.text = sound.name
                                info.value = sound.file
                                info.func = function()
                                    BLU.db.profile.selectedSounds[dropdown.eventId] = sound.file
                                    UIDropDownMenu_SetText(dropdown, sound.name)
                                    currentSound:SetText(sound.name)
                                    CloseDropDownMenus()
                                end
                                info.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == sound.file
                                UIDropDownMenu_AddButton(info, level)
                            end
                        end
                    end
                elseif menuList == "sharedmedia" then
                    -- SharedMedia sounds
                    if BLU.Modules.sharedmedia and BLU.Modules.sharedmedia.GetSoundCategories then
                        local categories = BLU.Modules.sharedmedia:GetSoundCategories()
                        for category, sounds in pairs(categories) do
                            local info = UIDropDownMenu_CreateInfo()
                            info.text = category
                            info.value = category
                            info.hasArrow = true
                            info.menuList = "sharedmedia_" .. category
                            info.notCheckable = true
                            UIDropDownMenu_AddButton(info, level)
                        end
                    end
                elseif menuList and menuList:match("^sharedmedia_") then
                    local category = menuList:gsub("^sharedmedia_", "")
                    if BLU.Modules.sharedmedia and BLU.Modules.sharedmedia.GetSoundCategories then
                        local categories = BLU.Modules.sharedmedia:GetSoundCategories()
                        local sounds = categories[category]
                        if sounds then
                            for _, sound in ipairs(sounds) do
                                local info = UIDropDownMenu_CreateInfo()
                                info.text = sound.name
                                info.value = sound.file
                                info.func = function()
                                    BLU.db.profile.selectedSounds[dropdown.eventId] = sound.file
                                    UIDropDownMenu_SetText(dropdown, sound.name)
                                    currentSound:SetText(sound.name)
                                    CloseDropDownMenus()
                                end
                                info.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == sound.file
                                UIDropDownMenu_AddButton(info, level)
                            end
                        end
                    end
                end
            end
        end)
        
        -- Set initial text
        local selectedSound = BLU.db and BLU.db.profile and BLU.db.profile.selectedSounds and 
                            BLU.db.profile.selectedSounds[questEventType] or "default"
        if selectedSound == "default" then
            UIDropDownMenu_SetText(dropdown, "Default WoW Sound")
            currentSound:SetText("Default WoW Sound")
        else
            -- Try to find the sound name
            local soundName = "Custom Sound"
            UIDropDownMenu_SetText(dropdown, soundName)
            currentSound:SetText(soundName)
        end
        
        return section
    end
    
    -- Quest Accept sound selection
    local acceptSection = CreateQuestSoundSelection(content, "questaccept", "Quest Accept", 
        -(moduleSection:GetHeight() + BLU.Design.Layout.SectionSpacing * 2))
    acceptSection:SetPoint("TOPLEFT", moduleSection, "BOTTOMLEFT", 0, -BLU.Design.Layout.SectionSpacing)
    
    -- Quest Turn In sound selection
    local turninSection = CreateQuestSoundSelection(content, "questturnin", "Quest Turn In", 
        -(acceptSection:GetHeight() + BLU.Design.Layout.SectionSpacing))
    turninSection:SetPoint("TOPLEFT", acceptSection, "BOTTOMLEFT", 0, -BLU.Design.Layout.SectionSpacing)
    
    -- Info section
    local infoSection = BLU.Design:CreateSection(content, "Quest Sound Information", "Interface\\Icons\\INV_Misc_Note_02")
    infoSection:SetPoint("TOPLEFT", turninSection, "BOTTOMLEFT", 0, -BLU.Design.Layout.SectionSpacing)
    infoSection:SetPoint("RIGHT", -BLU.Design.Layout.ContentMargin, 0)
    infoSection:SetHeight(100)
    
    local infoText = infoSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    infoText:SetPoint("TOPLEFT", BLU.Design.Layout.Spacing, -BLU.Design.Layout.Spacing)
    infoText:SetPoint("RIGHT", -BLU.Design.Layout.Spacing, 0)
    infoText:SetJustifyH("LEFT")
    infoText:SetText(
        "|cff05dffaQuest Accept|r plays when you accept a new quest from an NPC or item.\n\n" ..
        "|cff05dffaQuest Turn In|r plays when you complete and turn in a quest to an NPC.\n\n" ..
        "Each event can have its own unique sound from |cff05dffaBLU|r packs, WoW defaults, or SharedMedia addons."
    )
end