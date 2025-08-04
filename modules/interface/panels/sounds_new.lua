--=====================================================================================
-- BLU - interface/panels/sounds_new.lua
-- Sound selection panel with SharedMedia integration
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateSoundsPanel(panel)
    -- Create scrollable content
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 20, -20)
    scrollFrame:SetPoint("BOTTOMRIGHT", -40, 20)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth() - 20, 1000)
    scrollFrame:SetScrollChild(content)
    
    -- Header
    local header = BLU.Design:CreateHeader(content, "Sound Configuration", "Interface\\Icons\\INV_Misc_Bell_01")
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("RIGHT", -20, 0)
    
    -- Info section
    local infoSection = BLU.Design:CreateSection(content, "Available Sound Sources", "Interface\\Icons\\INV_Misc_Book_09")
    infoSection:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -20)
    infoSection:SetPoint("RIGHT", -20, 0)
    infoSection:SetHeight(120)
    
    local infoText = infoSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    infoText:SetPoint("TOPLEFT", 0, -5)
    infoText:SetPoint("RIGHT", 0, 0)
    infoText:SetJustifyH("LEFT")
    
    -- Check for loaded sound addons
    local loadedAddons = {}
    if BLU.Modules.sharedmedia then
        loadedAddons = BLU.Modules.sharedmedia:GetLoadedSoundAddons()
    end
    
    if #loadedAddons > 0 then
        infoText:SetText(string.format(
            "|cff00ff00Sound addons detected:|r\n%s\n\n" ..
            "BLU can use sounds from these addons. Select sounds below for each event type.",
            table.concat(loadedAddons, ", ")
        ))
    else
        infoText:SetText(
            "|cffff0000No external sound addons detected.|r\n\n" ..
            "Install sound pack addons like:\n" ..
            "• SharedMedia_MyMedia\n" ..
            "• SharedMedia addons from CurseForge\n" ..
            "• WeakAuras (if installed)"
        )
    end
    
    -- Event sound configuration
    local configSection = BLU.Design:CreateSection(content, "Event Sound Selection", "Interface\\Icons\\Spell_ChargePositive")
    configSection:SetPoint("TOPLEFT", infoSection, "BOTTOMLEFT", 0, -20)
    configSection:SetPoint("RIGHT", -20, 0)
    configSection:SetHeight(500)
    
    -- Sound categories
    local soundEvents = {
        {id = "levelup", name = "Level Up", icon = "Achievement_Level_100", desc = "When you gain a level"},
        {id = "achievement", name = "Achievement Earned", icon = "Achievement_GuildPerk_MobileMailbox", desc = "When you earn an achievement"},
        {id = "quest", name = "Quest Complete", icon = "INV_Misc_Note_01", desc = "When you complete a quest"},
        {id = "reputation", name = "Reputation Gain", icon = "Achievement_Reputation_01", desc = "When you gain reputation"},
        {id = "honorrank", name = "Honor Rank Up", icon = "PVPCurrency-Honor-Horde", desc = "When you gain honor rank"},
        {id = "renownrank", name = "Renown Level", icon = "UI_MajorFaction_Centaur", desc = "When you gain renown"},
        {id = "tradingpost", name = "Trading Post", icon = "INV_Tradingpost_Currency", desc = "Trading post rewards"},
        {id = "battlepet", name = "Pet Battle Victory", icon = "INV_Pet_BattlePetTraining", desc = "When you win a pet battle"},
        {id = "delvecompanion", name = "Delve Companion", icon = "UI_MajorFaction_Delve", desc = "Delve companion events"}
    }
    
    local yOffset = -10
    
    for i, event in ipairs(soundEvents) do
        -- Event row
        local row = CreateFrame("Frame", nil, configSection.content)
        row:SetPoint("TOPLEFT", 0, yOffset)
        row:SetPoint("RIGHT", 0, 0)
        row:SetHeight(50)
        
        -- Alternating background
        if i % 2 == 0 then
            local bg = row:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
        end
        
        -- Icon
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(32, 32)
        icon:SetPoint("LEFT", 10, 0)
        icon:SetTexture("Interface\\Icons\\" .. event.icon)
        
        -- Name
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("LEFT", icon, "RIGHT", 10, 8)
        name:SetText(event.name)
        
        -- Description
        local desc = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        desc:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
        desc:SetText(event.desc)
        desc:SetTextColor(0.7, 0.7, 0.7)
        
        -- Dropdown
        local dropdown = CreateFrame("Frame", "BLUSoundDropdown_" .. event.id, row, "UIDropDownMenuTemplate")
        dropdown:SetPoint("RIGHT", -50, 0)
        UIDropDownMenu_SetWidth(dropdown, 250)
        
        -- Initialize dropdown with sounds
        dropdown.eventId = event.id
        UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
            level = level or 1
            
            if level == 1 then
                -- Default option
                local info = UIDropDownMenu_CreateInfo()
                info.text = "Default WoW Sound"
                info.value = "default"
                info.func = function()
                    BLU.db.profile.selectedSounds[self.eventId] = "default"
                    UIDropDownMenu_SetText(self, "Default WoW Sound")
                end
                info.checked = BLU.db.profile.selectedSounds[self.eventId] == "default"
                UIDropDownMenu_AddButton(info, level)
                
                -- BLU built-in sounds
                info = UIDropDownMenu_CreateInfo()
                info.text = "|cff05dffaBLU Built-in Sounds|r"
                info.value = "blu_builtin"
                info.hasArrow = true
                info.menuList = "blu_builtin"
                UIDropDownMenu_AddButton(info, level)
                
                -- External sounds by category
                if BLU.Modules.sharedmedia then
                    local categories = BLU.Modules.sharedmedia:GetSoundCategories()
                    for category, sounds in pairs(categories) do
                        if #sounds > 0 then
                            info = UIDropDownMenu_CreateInfo()
                            info.text = category .. " (" .. #sounds .. ")"
                            info.value = category
                            info.hasArrow = true
                            info.menuList = category
                            UIDropDownMenu_AddButton(info, level)
                        end
                    end
                end
            elseif level == 2 then
                if menuList == "blu_builtin" then
                    -- BLU's built-in sounds
                    local builtinSounds = {
                        {value = "wowdefault", text = "WoW Built-in"},
                        {value = "finalfantasy", text = "Final Fantasy"}
                    }
                    
                    for _, sound in ipairs(builtinSounds) do
                        local info = UIDropDownMenu_CreateInfo()
                        info.text = sound.text
                        info.value = sound.value
                        info.func = function()
                            BLU.db.profile.selectedSounds[dropdown.eventId] = sound.value
                            UIDropDownMenu_SetText(dropdown, sound.text)
                            CloseDropDownMenus()
                        end
                        info.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == sound.value
                        UIDropDownMenu_AddButton(info, level)
                    end
                else
                    -- External sounds from category
                    local sounds = BLU.Modules.sharedmedia:GetSoundCategories()[menuList]
                    if sounds then
                        for _, soundName in ipairs(sounds) do
                            local info = UIDropDownMenu_CreateInfo()
                            info.text = soundName
                            info.value = "external:" .. soundName
                            info.func = function()
                                BLU.db.profile.selectedSounds[dropdown.eventId] = "external:" .. soundName
                                UIDropDownMenu_SetText(dropdown, soundName .. " (External)")
                                CloseDropDownMenus()
                            end
                            info.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == "external:" .. soundName
                            UIDropDownMenu_AddButton(info, level)
                        end
                    end
                end
            end
        end)
        
        -- Set current value
        local currentValue = BLU.db.profile.selectedSounds[event.id] or "default"
        if currentValue == "default" then
            UIDropDownMenu_SetText(dropdown, "Default WoW Sound")
        elseif currentValue:match("^external:") then
            local soundName = currentValue:gsub("^external:", "")
            UIDropDownMenu_SetText(dropdown, soundName .. " (External)")
        else
            UIDropDownMenu_SetText(dropdown, currentValue)
        end
        
        -- Preview button
        local preview = CreateFrame("Button", nil, row)
        preview:SetSize(32, 32)
        preview:SetPoint("RIGHT", -10, 0)
        preview:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
        preview:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
        preview.eventId = event.id
        
        preview:SetScript("OnClick", function(self)
            BLU:PlayCategorySound(self.eventId)
        end)
        
        preview:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText("Preview Sound")
            GameTooltip:AddLine("Click to test this sound", 1, 1, 1)
            GameTooltip:Show()
        end)
        preview:SetScript("OnLeave", GameTooltip_Hide)
        
        yOffset = yOffset - 55
    end
    
    -- Sound browser button
    local browserSection = BLU.Design:CreateSection(content, "Sound Browser", "Interface\\Icons\\INV_Misc_Spyglass_03")
    browserSection:SetPoint("TOPLEFT", configSection, "BOTTOMLEFT", 0, -20)
    browserSection:SetPoint("RIGHT", -20, 0)
    browserSection:SetHeight(80)
    
    local browserBtn = BLU.Design:CreateButton(browserSection.content, "Open Sound Browser", 200, 30)
    browserBtn:SetPoint("CENTER", 0, 0)
    browserBtn:SetScript("OnClick", function()
        if BLU.OpenSoundBrowser then
            BLU:OpenSoundBrowser()
        else
            BLU:Print("Sound browser coming soon!")
        end
    end)
    
    content:SetHeight(800)
end