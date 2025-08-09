--=====================================================================================
-- BLU | Sounds Panel - Complete Sound Browser and Event Configuration
-- Author: donniedice
-- Description: Browse all sounds, configure per-event, preview functionality
--=====================================================================================

local addonName, BLU = ...

-- Sound categories and their available sounds
local soundCategories = {
    ["Final Fantasy"] = {
        "final_fantasy.ogg",
        "final_fantasy_victory.ogg",
        "final_fantasy_levelup.ogg"
    },
    ["Legend of Zelda"] = {
        "legend_of_zelda.ogg",
        "zelda_chest.ogg",
        "zelda_secret.ogg"
    },
    ["Pokemon"] = {
        "pokemon.ogg",
        "pokemon_levelup.ogg",
        "pokemon_evolve.ogg"
    },
    ["Sonic"] = {
        "sonic_the_hedgehog.ogg",
        "sonic_ring.ogg",
        "sonic_speed.ogg"
    },
    ["Mario"] = {
        "super_mario_bros_3.ogg",
        "mario_coin.ogg", 
        "mario_powerup.ogg"
    },
    ["Elder Scrolls"] = {
        "skyrim.ogg",
        "morrowind.ogg",
        "oblivion.ogg"
    },
    ["Warcraft"] = {
        "warcraft_3.ogg",
        "warcraft_3-2.ogg",
        "warcraft_3-3.ogg"
    },
    ["Other Games"] = {
        "minecraft.ogg",
        "fortnite.ogg",
        "elden_ring-1.ogg",
        "witcher_3-1.ogg"
    }
}

-- Event types that can have custom sounds
local eventTypes = {
    {id = "levelup", name = "Level Up", icon = "Interface\\Icons\\Achievement_Level_110"},
    {id = "achievement", name = "Achievement", icon = "Interface\\Icons\\Achievement_General"},
    {id = "quest", name = "Quest Complete", icon = "Interface\\Icons\\Achievement_Quests_Completed_08"},
    {id = "reputation", name = "Reputation", icon = "Interface\\Icons\\Achievement_Reputation_08"},
    {id = "honor", name = "Honor Gain", icon = "Interface\\Icons\\Spell_Holy_ChampionsBond"},
    {id = "battlepet", name = "Pet Level", icon = "Interface\\Icons\\INV_Pet_BattlePetTraining"},
    {id = "renown", name = "Renown", icon = "Interface\\Icons\\UI_MajorFaction_Tuskarr"},
    {id = "tradingpost", name = "Trading Post", icon = "Interface\\Icons\\Inv_Currency_TradingPost"},
    {id = "delve", name = "Delve Complete", icon = "Interface\\Icons\\Ui_DelvesCurrency"}
}

function BLU.CreateSoundsPanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()
    panel:Hide()
    
    -- Create scrollable container
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth(), 1000)
    scrollFrame:SetScrollChild(content)
    
    -- Title
    local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Sound Configuration")
    
    local yOffset = -50
    
    -- Event Sound Configuration Section
    local eventTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    eventTitle:SetPoint("TOPLEFT", 16, yOffset)
    eventTitle:SetText("Event Sounds")
    eventTitle:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    -- Create event rows
    panel.eventRows = {}
    
    for i, event in ipairs(eventTypes) do
        local row = CreateFrame("Frame", nil, content)
        row:SetSize(700, 40)
        row:SetPoint("TOPLEFT", 20, yOffset)
        
        -- Background
        local bg = row:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
        if i % 2 == 0 then
            bg:SetColorTexture(0.15, 0.15, 0.15, 0.3)
        end
        
        -- Icon
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(32, 32)
        icon:SetPoint("LEFT", 5, 0)
        icon:SetTexture(event.icon)
        
        -- Event name
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("LEFT", icon, "RIGHT", 10, 0)
        name:SetText(event.name)
        name:SetWidth(120)
        name:SetJustifyH("LEFT")
        
        -- Sound dropdown
        local dropdown = CreateFrame("Frame", "BLUSoundDropdown"..i, row, "UIDropDownMenuTemplate")
        dropdown:SetPoint("LEFT", name, "RIGHT", 10, 0)
        UIDropDownMenu_SetWidth(dropdown, 200)
        
        local currentSound = BLU:GetDB({"selectedSounds", event.id}) or "default"
        UIDropDownMenu_SetText(dropdown, currentSound)
        
        UIDropDownMenu_Initialize(dropdown, function(self, level)
            -- Default option
            local info = UIDropDownMenu_CreateInfo()
            info.text = "Default"
            info.value = "default"
            info.func = function()
                BLU:SetDB({"selectedSounds", event.id}, "default")
                UIDropDownMenu_SetText(dropdown, "Default")
            end
            UIDropDownMenu_AddButton(info, level)
            
            -- Add separator
            info = UIDropDownMenu_CreateInfo()
            info.notCheckable = true
            info.disabled = true
            info.text = ""
            UIDropDownMenu_AddButton(info, level)
            
            -- Add all sound categories
            for category, sounds in pairs(soundCategories) do
                info = UIDropDownMenu_CreateInfo()
                info.text = category
                info.value = category
                info.hasArrow = true
                info.notCheckable = true
                info.menuList = {}
                
                for _, sound in ipairs(sounds) do
                    local soundInfo = UIDropDownMenu_CreateInfo()
                    soundInfo.text = sound:gsub("%.ogg", ""):gsub("_", " ")
                    soundInfo.value = sound
                    soundInfo.func = function()
                        BLU:SetDB({"selectedSounds", event.id}, sound)
                        UIDropDownMenu_SetText(dropdown, soundInfo.text)
                    end
                    table.insert(info.menuList, soundInfo)
                end
                
                UIDropDownMenu_AddButton(info, level)
            end
        end)
        
        -- Volume slider
        local volumeSlider = CreateFrame("Slider", nil, row, "OptionsSliderTemplate")
        volumeSlider:SetPoint("LEFT", dropdown, "RIGHT", 20, 0)
        volumeSlider:SetSize(100, 20)
        volumeSlider:SetMinMaxValues(0, 100)
        volumeSlider:SetValueStep(1)
        volumeSlider:SetObeyStepOnDrag(true)
        volumeSlider.Low:SetText("")
        volumeSlider.High:SetText("")
        volumeSlider.Text:SetText("")
        
        local volumeText = volumeSlider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        volumeText:SetPoint("TOP", volumeSlider, "BOTTOM", 0, -2)
        
        local currentVolume = 100 -- Volume handled globally
        volumeSlider:SetValue(currentVolume)
        volumeText:SetText(currentVolume .. "%")
        
        volumeSlider:SetScript("OnValueChanged", function(self, value)
            -- Individual event volumes not implemented yet
            volumeText:SetText(value .. "%")
        end)
        
        -- Test button
        local testBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        testBtn:SetSize(60, 22)
        testBtn:SetPoint("LEFT", volumeSlider, "RIGHT", 10, 0)
        testBtn:SetText("Test")
        testBtn:SetScript("OnClick", function()
            BLU:PlayCategorySound(event.id)
        end)
        
        -- Enable checkbox
        local enableCheck = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        enableCheck:SetPoint("LEFT", testBtn, "RIGHT", 10, 0)
        enableCheck:SetSize(24, 24)
        
        local enabled = true -- All events enabled by default
        enableCheck:SetChecked(enabled)
        
        enableCheck:SetScript("OnClick", function(self)
            -- Module enable/disable handled in modules panel
        end)
        
        local enableLabel = enableCheck:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        enableLabel:SetPoint("LEFT", enableCheck, "RIGHT", 2, 0)
        enableLabel:SetText("Enable")
        
        panel.eventRows[event.id] = row
        yOffset = yOffset - 45
    end
    
    yOffset = yOffset - 30
    
    -- Sound Browser Section
    local browserTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    browserTitle:SetPoint("TOPLEFT", 16, yOffset)
    browserTitle:SetText("Sound Browser")
    browserTitle:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    -- Search box
    local searchBox = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    searchBox:SetPoint("TOPLEFT", 30, yOffset)
    searchBox:SetSize(200, 20)
    searchBox:SetAutoFocus(false)
    searchBox:SetScript("OnTextChanged", function(self)
        -- Filter sounds based on search
        panel:FilterSounds(self:GetText())
    end)
    
    local searchLabel = searchBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    searchLabel:SetPoint("RIGHT", searchBox, "LEFT", -10, 0)
    searchLabel:SetText("Search:")
    
    -- Category filter dropdown
    local categoryDropdown = CreateFrame("Frame", "BLUCategoryFilter", content, "UIDropDownMenuTemplate")
    categoryDropdown:SetPoint("LEFT", searchBox, "RIGHT", 20, 0)
    UIDropDownMenu_SetWidth(categoryDropdown, 150)
    UIDropDownMenu_SetText(categoryDropdown, "All Categories")
    
    UIDropDownMenu_Initialize(categoryDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        info.text = "All Categories"
        info.value = "all"
        info.func = function()
            UIDropDownMenu_SetText(categoryDropdown, "All Categories")
            panel:FilterCategory(nil)
        end
        UIDropDownMenu_AddButton(info, level)
        
        for category, _ in pairs(soundCategories) do
            info = UIDropDownMenu_CreateInfo()
            info.text = category
            info.value = category
            info.func = function()
                UIDropDownMenu_SetText(categoryDropdown, category)
                panel:FilterCategory(category)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    yOffset = yOffset - 40
    
    -- Sound list
    local soundList = CreateFrame("Frame", nil, content)
    soundList:SetPoint("TOPLEFT", 30, yOffset)
    soundList:SetSize(680, 200)
    
    local listBg = soundList:CreateTexture(nil, "BACKGROUND")
    listBg:SetAllPoints()
    listBg:SetColorTexture(0.05, 0.05, 0.05, 0.5)
    
    panel.soundList = soundList
    panel.soundButtons = {}
    
    -- Populate sound list
    local buttonYOffset = -5
    local buttonIndex = 1
    
    for category, sounds in pairs(soundCategories) do
        for _, sound in ipairs(sounds) do
            local btn = CreateFrame("Button", nil, soundList)
            btn:SetSize(660, 24)
            btn:SetPoint("TOPLEFT", 5, buttonYOffset)
            
            local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetAllPoints()
            highlight:SetColorTexture(0.3, 0.3, 0.3, 0.3)
            
            local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("LEFT", 10, 0)
            text:SetText(string.format("[%s] %s", category, sound:gsub("%.ogg", ""):gsub("_", " ")))
            btn.text = text
            btn.sound = sound
            btn.category = category
            
            -- Play button
            local playBtn = CreateFrame("Button", nil, btn)
            playBtn:SetSize(20, 20)
            playBtn:SetPoint("RIGHT", -10, 0)
            playBtn:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
            playBtn:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
            playBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
            
            playBtn:SetScript("OnClick", function()
                BLU:PlaySound(sound, 100)
            end)
            
            panel.soundButtons[buttonIndex] = btn
            buttonIndex = buttonIndex + 1
            buttonYOffset = buttonYOffset - 25
        end
    end
    
    -- Filter functions
    function panel:FilterSounds(searchText)
        local yPos = -5
        for _, btn in ipairs(self.soundButtons) do
            if searchText == "" or btn.text:GetText():lower():find(searchText:lower()) then
                btn:Show()
                btn:SetPoint("TOPLEFT", 5, yPos)
                yPos = yPos - 25
            else
                btn:Hide()
            end
        end
    end
    
    function panel:FilterCategory(category)
        local yPos = -5
        for _, btn in ipairs(self.soundButtons) do
            if not category or btn.category == category then
                btn:Show()
                btn:SetPoint("TOPLEFT", 5, yPos)
                yPos = yPos - 25
            else
                btn:Hide()
            end
        end
    end
    
    return panel
end