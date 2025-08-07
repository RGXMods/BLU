--=====================================================================================
-- BLU - interface/panels/event_simple.lua
-- Simplified event sound panel - just a dropdown for sound selection
--=====================================================================================

local addonName, BLU = ...

-- Create a simple event panel with just a dropdown
function BLU.CreateSimpleEventPanel(panel, eventType, eventName)
    -- Create scrollable content
    local scrollFrame, content = BLU.Design:CreatePanelScrollFrame(panel, 400)
    
    -- Header
    local header = CreateFrame("Frame", nil, content)
    header:SetHeight(50)
    header:SetPoint("TOPLEFT", BLU.Design.Layout.ContentMargin, -BLU.Design.Layout.ContentMargin)
    header:SetPoint("RIGHT", -BLU.Design.Layout.ContentMargin, 0)
    
    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("LEFT", 0, 0)
    
    -- Set appropriate icon based on event type
    local icons = {
        levelup = "Interface\\Icons\\Achievement_Level_100",
        achievement = "Interface\\Icons\\Achievement_GuildPerk_MobileMailbox",
        quest = "Interface\\Icons\\INV_Misc_Note_01",
        reputation = "Interface\\Icons\\Achievement_Reputation_01",
        battlepet = "Interface\\Icons\\INV_Pet_BattlePetTraining",
        honorrank = "Interface\\Icons\\PVPCurrency-Honor-Horde",
        renownrank = "Interface\\Icons\\UI_MajorFaction_Renown",
        tradingpost = "Interface\\Icons\\INV_TradingPostCurrency",
        delvecompanion = "Interface\\Icons\\UI_MajorFaction_Delve"
    }
    icon:SetTexture(icons[eventType] or "Interface\\Icons\\INV_Misc_QuestionMark")
    
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    title:SetText("|cff05dffaB|retter |cff05dffaL|revel-|cff05dffaU|rp! " .. eventName)
    
    -- Main sound selection section
    local soundSection = BLU.Design:CreateSection(content, "Sound Selection", "Interface\\Icons\\INV_Misc_Bell_01")
    soundSection:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -BLU.Design.Layout.SectionSpacing)
    soundSection:SetPoint("RIGHT", -BLU.Design.Layout.ContentMargin, 0)
    soundSection:SetHeight(250)
    
    -- Current selection display
    local currentLabel = soundSection.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentLabel:SetPoint("TOPLEFT", BLU.Design.Layout.Spacing, -BLU.Design.Layout.Spacing)
    currentLabel:SetText("Current Selection:")
    
    local currentSound = soundSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    currentSound:SetPoint("LEFT", currentLabel, "RIGHT", BLU.Design.Layout.Spacing, 0)
    currentSound:SetText("None")
    
    -- Test button
    local testBtn = BLU.Design:CreateButton(soundSection.content, "Test", 60, 22)
    testBtn:SetPoint("RIGHT", -BLU.Design.Layout.Spacing, -BLU.Design.Layout.Spacing)
    testBtn:SetScript("OnClick", function(self)
        local selected = BLU.db.profile.selectedSounds and BLU.db.profile.selectedSounds[eventType]
        
        if not selected or selected == "none" then
            BLU:Print("No sound selected for " .. eventName)
            return
        end
        
        self:SetText("Playing...")
        self:Disable()
        
        -- Extract base sound and volume if it's a default sound with volume
        local baseSound, volume = selected:match("^(default)_(%w+)$")
        if baseSound then
            -- Play default sound at specified volume
            PlaySound(SOUNDKIT.READY_CHECK, "Master")
        elseif selected == "default" then
            -- Play default sound at normal volume
            PlaySound(SOUNDKIT.READY_CHECK, "Master")
        elseif selected:match("^blu:") then
            -- Play BLU sound
            local soundFile = selected:gsub("^blu:", "")
            PlaySoundFile(soundFile, BLU.db.profile.soundChannel or "Master")
        elseif selected:match("^external:") then
            -- Play external sound
            local soundName = selected:gsub("^external:", "")
            if BLU.Modules.sharedmedia then
                BLU.Modules.sharedmedia:PlayExternalSound(soundName)
            end
        end
        
        C_Timer.After(2, function()
            self:SetText("Test")
            self:Enable()
        end)
    end)
    
    -- Main dropdown (using Narcissus style if available)
    local designSystem = BLU.NarciDesign or BLU.Design
    local dropdownContainer = designSystem:CreateDropdown(soundSection.content, "Select Sound:", 400)
    dropdownContainer:SetPoint("TOPLEFT", currentLabel, "BOTTOMLEFT", 0, -20)
    local dropdown = dropdownContainer.dropdown
    
    -- Initialize dropdown
    dropdown.eventId = eventType
    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        level = level or 1
        BLU.db.profile.selectedSounds = BLU.db.profile.selectedSounds or {}
        
        if level == 1 then
            -- NONE option (disables module)
            local info = UIDropDownMenu_CreateInfo()
            info.text = "|cff888888None (Disabled)|r"
            info.value = "none"
            info.func = function()
                BLU.db.profile.selectedSounds[self.eventId] = "none"
                UIDropDownMenu_SetText(self, "None (Disabled)")
                currentSound:SetText("|cff888888None|r")
                CloseDropDownMenus()
                
                -- Disable the module
                BLU.db.profile.modules = BLU.db.profile.modules or {}
                BLU.db.profile.modules[eventType] = false
                if BLU.UnloadModule then
                    BLU:UnloadModule(eventType)
                end
            end
            info.checked = BLU.db.profile.selectedSounds[self.eventId] == "none"
            UIDropDownMenu_AddButton(info, level)
            
            -- Separator
            info = UIDropDownMenu_CreateInfo()
            info.text = ""
            info.disabled = true
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- DEFAULT with volume options
            info = UIDropDownMenu_CreateInfo()
            info.text = "|cffffff00Default WoW Sound|r"
            info.value = "default_category"
            info.hasArrow = true
            info.menuList = "default_volumes"
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- BLU Built-in Sounds
            info = UIDropDownMenu_CreateInfo()
            info.text = "|cff05dffaBLU Sound Packs|r"
            info.value = "blu_sounds"
            info.hasArrow = true
            info.menuList = "blu_sounds"
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- SharedMedia/External sounds
            if BLU.Modules.sharedmedia then
                local categories = BLU.Modules.sharedmedia:GetSoundCategories()
                if categories and next(categories) then
                    info = UIDropDownMenu_CreateInfo()
                    info.text = "|cff00ff00SharedMedia & Sound Packs|r"
                    info.value = "sharedmedia"
                    info.hasArrow = true
                    info.menuList = "sharedmedia"
                    info.notCheckable = true
                    UIDropDownMenu_AddButton(info, level)
                end
            end
            
        elseif level == 2 then
            if menuList == "default_volumes" then
                -- Default sound with volume levels
                local volumes = {
                    {text = "Default (Normal Volume)", value = "default", color = "|cffffffff"},
                    {text = "Default (Low Volume)", value = "default_low", color = "|cff888888"},
                    {text = "Default (Medium Volume)", value = "default_medium", color = "|cffcccccc"},
                    {text = "Default (High Volume)", value = "default_high", color = "|cffffd700"}
                }
                
                for _, vol in ipairs(volumes) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = vol.color .. vol.text .. "|r"
                    info.value = vol.value
                    info.func = function()
                        BLU.db.profile.selectedSounds[dropdown.eventId] = vol.value
                        UIDropDownMenu_SetText(dropdown, vol.text)
                        currentSound:SetText(vol.text)
                        CloseDropDownMenus()
                        
                        -- Enable the module
                        BLU.db.profile.modules = BLU.db.profile.modules or {}
                        BLU.db.profile.modules[eventType] = true
                        if BLU.LoadModule then
                            BLU:LoadModule("features", eventType)
                        end
                    end
                    info.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == vol.value
                    UIDropDownMenu_AddButton(info, level)
                end
                
            elseif menuList == "blu_sounds" then
                -- BLU built-in sound packs
                local bluPacks = {
                    {category = "Final Fantasy", sounds = {
                        {name = "FF Victory Fanfare", file = "Interface\\AddOns\\BLU\\media\\sounds\\finalfantasy\\victory.ogg"},
                        {name = "FF Level Up", file = "Interface\\AddOns\\BLU\\media\\sounds\\finalfantasy\\levelup.ogg"},
                        {name = "FF Item Get", file = "Interface\\AddOns\\BLU\\media\\sounds\\finalfantasy\\item.ogg"}
                    }},
                    {category = "Legend of Zelda", sounds = {
                        {name = "Zelda Treasure", file = "Interface\\AddOns\\BLU\\media\\sounds\\zelda\\treasure.ogg"},
                        {name = "Zelda Secret", file = "Interface\\AddOns\\BLU\\media\\sounds\\zelda\\secret.ogg"},
                        {name = "Zelda Item Get", file = "Interface\\AddOns\\BLU\\media\\sounds\\zelda\\item.ogg"}
                    }},
                    {category = "Pokemon", sounds = {
                        {name = "Pokemon Level Up", file = "Interface\\AddOns\\BLU\\media\\sounds\\pokemon\\levelup.ogg"},
                        {name = "Pokemon Evolution", file = "Interface\\AddOns\\BLU\\media\\sounds\\pokemon\\evolution.ogg"}
                    }},
                    {category = "Super Mario", sounds = {
                        {name = "Mario 1-Up", file = "Interface\\AddOns\\BLU\\media\\sounds\\mario\\1up.ogg"},
                        {name = "Mario Power Up", file = "Interface\\AddOns\\BLU\\media\\sounds\\mario\\powerup.ogg"},
                        {name = "Mario Coin", file = "Interface\\AddOns\\BLU\\media\\sounds\\mario\\coin.ogg"}
                    }}
                }
                
                for _, pack in ipairs(bluPacks) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = "|cff05dffa" .. pack.category .. "|r"
                    info.value = pack.category
                    info.hasArrow = true
                    info.menuList = "blu_" .. pack.category
                    info.notCheckable = true
                    UIDropDownMenu_AddButton(info, level)
                end
                
            elseif menuList == "sharedmedia" then
                -- SharedMedia categories
                if BLU.Modules.sharedmedia then
                    local categories = BLU.Modules.sharedmedia:GetSoundCategories()
                    for category, sounds in pairs(categories) do
                        local info = UIDropDownMenu_CreateInfo()
                        info.text = category .. " (" .. #sounds .. ")"
                        info.value = category
                        info.hasArrow = true
                        info.menuList = "sm_" .. category
                        info.notCheckable = true
                        UIDropDownMenu_AddButton(info, level)
                    end
                end
                
            elseif menuList and menuList:match("^blu_") then
                -- BLU sound pack sounds
                local category = menuList:gsub("^blu_", "")
                local bluPacks = {
                    ["Final Fantasy"] = {
                        {name = "FF Victory Fanfare", file = "Interface\\AddOns\\BLU\\media\\sounds\\finalfantasy\\victory.ogg"},
                        {name = "FF Level Up", file = "Interface\\AddOns\\BLU\\media\\sounds\\finalfantasy\\levelup.ogg"},
                        {name = "FF Item Get", file = "Interface\\AddOns\\BLU\\media\\sounds\\finalfantasy\\item.ogg"}
                    },
                    ["Legend of Zelda"] = {
                        {name = "Zelda Treasure", file = "Interface\\AddOns\\BLU\\media\\sounds\\zelda\\treasure.ogg"},
                        {name = "Zelda Secret", file = "Interface\\AddOns\\BLU\\media\\sounds\\zelda\\secret.ogg"},
                        {name = "Zelda Item Get", file = "Interface\\AddOns\\BLU\\media\\sounds\\zelda\\item.ogg"}
                    },
                    ["Pokemon"] = {
                        {name = "Pokemon Level Up", file = "Interface\\AddOns\\BLU\\media\\sounds\\pokemon\\levelup.ogg"},
                        {name = "Pokemon Evolution", file = "Interface\\AddOns\\BLU\\media\\sounds\\pokemon\\evolution.ogg"}
                    },
                    ["Super Mario"] = {
                        {name = "Mario 1-Up", file = "Interface\\AddOns\\BLU\\media\\sounds\\mario\\1up.ogg"},
                        {name = "Mario Power Up", file = "Interface\\AddOns\\BLU\\media\\sounds\\mario\\powerup.ogg"},
                        {name = "Mario Coin", file = "Interface\\AddOns\\BLU\\media\\sounds\\mario\\coin.ogg"}
                    }
                }
                
                local sounds = bluPacks[category]
                if sounds then
                    for _, sound in ipairs(sounds) do
                        local info = UIDropDownMenu_CreateInfo()
                        info.text = sound.name
                        info.value = "blu:" .. sound.file
                        info.func = function()
                            BLU.db.profile.selectedSounds[dropdown.eventId] = info.value
                            UIDropDownMenu_SetText(dropdown, sound.name)
                            currentSound:SetText("|cff05dffa" .. sound.name .. "|r")
                            CloseDropDownMenus()
                            
                            -- Enable the module
                            BLU.db.profile.modules = BLU.db.profile.modules or {}
                            BLU.db.profile.modules[eventType] = true
                            if BLU.LoadModule then
                                BLU:LoadModule("features", eventType)
                            end
                        end
                        info.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == info.value
                        UIDropDownMenu_AddButton(info, level)
                    end
                end
                
            elseif menuList and menuList:match("^sm_") then
                -- SharedMedia sounds
                local category = menuList:gsub("^sm_", "")
                if BLU.Modules.sharedmedia then
                    local categories = BLU.Modules.sharedmedia:GetSoundCategories()
                    local sounds = categories[category]
                    if sounds then
                        for _, soundName in ipairs(sounds) do
                            local info = UIDropDownMenu_CreateInfo()
                            info.text = soundName
                            info.value = "external:" .. soundName
                            info.func = function()
                                BLU.db.profile.selectedSounds[dropdown.eventId] = info.value
                                UIDropDownMenu_SetText(dropdown, soundName)
                                currentSound:SetText("|cff00ff00" .. soundName .. "|r")
                                CloseDropDownMenus()
                                
                                -- Enable the module
                                BLU.db.profile.modules = BLU.db.profile.modules or {}
                                BLU.db.profile.modules[eventType] = true
                                if BLU.LoadModule then
                                    BLU:LoadModule("features", eventType)
                                end
                            end
                            info.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == info.value
                            UIDropDownMenu_AddButton(info, level)
                        end
                    end
                end
            end
        end
    end)
    
    -- Set initial selection
    local selectedSound = BLU.db and BLU.db.profile and BLU.db.profile.selectedSounds and 
                         BLU.db.profile.selectedSounds[eventType] or "none"
    
    if selectedSound == "none" then
        UIDropDownMenu_SetText(dropdown, "None (Disabled)")
        currentSound:SetText("|cff888888None|r")
    elseif selectedSound == "default" then
        UIDropDownMenu_SetText(dropdown, "Default (Normal Volume)")
        currentSound:SetText("Default (Normal Volume)")
    elseif selectedSound:match("^default_") then
        local volume = selectedSound:gsub("^default_", "")
        local volumeText = volume:gsub("^%l", string.upper) .. " Volume"
        UIDropDownMenu_SetText(dropdown, "Default (" .. volumeText .. ")")
        currentSound:SetText("Default (" .. volumeText .. ")")
    elseif selectedSound:match("^blu:") then
        -- Find the name from the file path
        UIDropDownMenu_SetText(dropdown, "BLU Sound")
        currentSound:SetText("|cff05dffaBLU Sound|r")
    elseif selectedSound:match("^external:") then
        local soundName = selectedSound:gsub("^external:", "")
        UIDropDownMenu_SetText(dropdown, soundName)
        currentSound:SetText("|cff00ff00" .. soundName .. "|r")
    else
        UIDropDownMenu_SetText(dropdown, "Custom")
        currentSound:SetText("Custom")
    end
    
    -- Info text
    local infoText = soundSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    infoText:SetPoint("TOPLEFT", dropdownContainer, "BOTTOMLEFT", 20, -20)
    infoText:SetPoint("RIGHT", -BLU.Design.Layout.Spacing, 0)
    infoText:SetText(
        "|cff888888Select |cffff0000None|r|cff888888 to disable this event entirely.|r\n" ..
        "|cff888888Choose from default WoW sounds with volume options, |cff05dffaBLU|r|cff888888 sound packs, or external SharedMedia sounds.|r"
    )
    infoText:SetJustifyH("LEFT")
end