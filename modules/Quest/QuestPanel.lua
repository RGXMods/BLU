--=====================================================================================
-- BLU - interface/panels/quest_simple.lua
-- Simplified Quest panel with two dropdowns for Accept and Turn In
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local QuestPanel = {}
BLU.Modules["questpanel"] = QuestPanel

function QuestPanel:Init()
    BLU:PrintDebug("QuestPanel:Init() called")
end

function BLU.CreateQuestPanel(panel)
    -- Create scrollable content
    local scrollFrame, content = BLU.Design:CreatePanelScrollFrame(panel, 600)
    
    -- Header
    local header = CreateFrame("Frame", nil, content)
    header:SetHeight(50)
    header:SetPoint("TOPLEFT", BLU.Design.Layout.ContentMargin, -BLU.Design.Layout.ContentMargin)
    header:SetPoint("RIGHT", -BLU.Design.Layout.ContentMargin, 0)
    
    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("LEFT", 0, 0)
    icon:SetTexture("Interface\Icons\INV_Misc_Note_01")
    
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    title:SetText("|cff05dffaB|retter |cff05dffaL|revel-|cff05dffaU|rp! Quest Events")
    
    -- Helper function to create a quest sound dropdown
    local function CreateQuestDropdown(parent, questEventType, questEventName, yOffset)
        local section = BLU.Design:CreateSection(parent, questEventName, "Interface\Icons\INV_Misc_Bell_01")
        section:SetPoint("TOPLEFT", 0, yOffset)
        section:SetPoint("RIGHT", -BLU.Design.Layout.ContentMargin, 0)
        section:SetHeight(200)
        
        -- Current selection display
        local currentLabel = section.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        currentLabel:SetPoint("TOPLEFT", BLU.Design.Layout.Spacing, -BLU.Design.Layout.Spacing)
        currentLabel:SetText("Current Selection:")
        
        local currentSound = section.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        currentSound:SetPoint("LEFT", currentLabel, "RIGHT", BLU.Design.Layout.Spacing, 0)
        currentSound:SetText("None")
        
        -- Test button
        local testBtn = BLU.Design:CreateButton(section.content, "Test", 60, 22)
        testBtn:SetPoint("RIGHT", -BLU.Design.Layout.Spacing, -BLU.Design.Layout.Spacing)
        testBtn:SetScript("OnClick", function(self)
            local selected = BLU.db.profile.selectedSounds and BLU.db.profile.selectedSounds[questEventType]
            
            if not selected or selected == "none" then
                BLU:Print("No sound selected for " .. questEventName)
                return
            end
            
            self:SetText("Playing...")
            self:Disable()
            
            -- Play the selected sound based on type
            if selected:match("^default") then
                PlaySound(SOUNDKIT.READY_CHECK, "Master")
            elseif selected:match("^blu:") then
                local soundFile = selected:gsub("^blu:", "")
                PlaySoundFile(soundFile, BLU.db.profile.soundChannel or "Master")
            elseif selected:match("^external:") then
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
        local dropdownContainer = designSystem:CreateDropdown(section.content, "Select Sound:", 350)
        dropdownContainer:SetPoint("TOPLEFT", currentLabel, "BOTTOMLEFT", 0, -20)
        local dropdown = dropdownContainer.dropdown
        
        -- Initialize dropdown (same structure as simple event panel)
        dropdown.eventId = questEventType
        UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
            level = level or 1
            BLU.db.profile.selectedSounds = BLU.db.profile.selectedSounds or {}
            
            if level == 1 then
                -- NONE option
                local info = UIDropDownMenu_CreateInfo()
                info.text = "|cff888888None (Disabled)|r"
                info.value = "none"
                info.func = function()
                    BLU.db.profile.selectedSounds[self.eventId] = "none"
                    UIDropDownMenu_SetText(self, "None (Disabled)")
                    currentSound:SetText("|cff888888None|r")
                    CloseDropDownMenus()
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
                        {text = "Default (Normal Volume)", value = "default"},
                        {text = "Default (Low Volume)", value = "default_low"},
                        {text = "Default (Medium Volume)", value = "default_medium"},
                        {text = "Default (High Volume)", value = "default_high"}
                    }
                    
                    for _, vol in ipairs(volumes) do
                        local info = UIDropDownMenu_CreateInfo()
                        info.text = vol.text
                        info.value = vol.value
                        info.func = function()
                            BLU.db.profile.selectedSounds[dropdown.eventId] = vol.value
                            UIDropDownMenu_SetText(dropdown, vol.text)
                            currentSound:SetText(vol.text)
                            CloseDropDownMenus()
                            
                            -- Enable quest module if any sound is selected
                            if vol.value ~= "none" then
                                BLU.db.profile.modules = BLU.db.profile.modules or {}
                                BLU.db.profile.modules.quest = true
                                if BLU.LoadModule then
                                    BLU:LoadModule("features", "quest")
                                end
                            end
                        end
                        info.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == vol.value
                        UIDropDownMenu_AddButton(info, level)
                    end
                    
                elseif menuList == "blu_sounds" then
                    -- Quest-specific BLU sounds
                    local questSounds = {
                        {name = "FF Quest Complete", file = "Interface\AddOns\BLU\media\sounds\finalfantasy\quest.ogg"},
                        {name = "Zelda Item Get", file = "Interface\AddOns\BLU\media\sounds\zelda\item.ogg"},
                        {name = "Mario Coin", file = "Interface\AddOns\BLU\media\sounds\mario\coin.ogg"},
                        {name = "Pokemon Item Get", file = "Interface\AddOns\BLU\media\sounds\pokemon\item.ogg"}
                    }
                    
                    for _, sound in ipairs(questSounds) do
                        local info = UIDropDownMenu_CreateInfo()
                        info.text = sound.name
                        info.value = "blu:" .. sound.file
                        info.func = function()
                            BLU.db.profile.selectedSounds[dropdown.eventId] = info.value
                            UIDropDownMenu_SetText(dropdown, sound.name)
                            currentSound:SetText("|cff05dffa" .. sound.name .. "|r")
                            CloseDropDownMenus()
                            
                            -- Enable quest module
                            BLU.db.profile.modules = BLU.db.profile.modules or {}
                            BLU.db.profile.modules.quest = true
                            if BLU.LoadModule then
                                BLU:LoadModule("features", "quest")
                            end
                        end
                        info.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == info.value
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
                                    
                                    -- Enable quest module
                                    BLU.db.profile.modules = BLU.db.profile.modules or {}
                                    BLU.db.profile.modules.quest = true
                                    if BLU.LoadModule then
                                        BLU:LoadModule("features", "quest")
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
                             BLU.db.profile.selectedSounds[questEventType] or "none"
        
        if selectedSound == "none" then
            UIDropDownMenu_SetText(dropdown, "None (Disabled)")
            currentSound:SetText("|cff888888None|r")
        elseif selectedSound:match("^default") then
            local volumePart = selectedSound:gsub("^default_?", "")
            if volumePart == "" or volumePart == "default" then
                UIDropDownMenu_SetText(dropdown, "Default (Normal Volume)")
                currentSound:SetText("Default (Normal Volume)")
            else
                local volumeText = volumePart:gsub("^%l", string.upper) .. " Volume"
                UIDropDownMenu_SetText(dropdown, "Default (" .. volumeText .. ")")
                currentSound:SetText("Default (" .. volumeText .. ")")
            end
        else
            UIDropDownMenu_SetText(dropdown, "Custom")
            currentSound:SetText("Custom")
        end
        
        return section
    end
    
    -- Quest Accept dropdown
    local acceptSection = CreateQuestDropdown(content, "questaccept", "Quest Accept", 
        -(header:GetHeight() + BLU.Design.Layout.SectionSpacing))
    acceptSection:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -BLU.Design.Layout.SectionSpacing)
    
    -- Quest Turn In dropdown
    local turninSection = CreateQuestDropdown(content, "questturnin", "Quest Turn In", 
        -(acceptSection:GetHeight() + BLU.Design.Layout.SectionSpacing))
    turninSection:SetPoint("TOPLEFT", acceptSection, "BOTTOMLEFT", 0, -BLU.Design.Layout.SectionSpacing)
    
    -- Info section
    local infoText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    infoText:SetPoint("TOPLEFT", turninSection, "BOTTOMLEFT", BLU.Design.Layout.ContentMargin, -20)
    infoText:SetPoint("RIGHT", -BLU.Design.Layout.ContentMargin, 0)
    infoText:SetText(
        "|cff888888The Quest module is automatically enabled when you select a sound for either event.|r\n" ..
        "|cff888888Select |cffff0000None|r|cff888888 for both events to completely disable quest sounds.|r"
    )
    infoText:SetJustifyH("LEFT")
end
