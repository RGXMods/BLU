--=====================================================================================
-- BLU - interface/panels/sounds.lua
-- Sound selection panel
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateSoundsPanel(panel)
    local widgets = BLU.Widgets
    
    -- Sound Selection header
    local header = widgets:CreateHeader(panel, "Sound Selection")
    header:SetPoint("TOPLEFT", 0, 0)
    
    local divider = widgets:CreateDivider(panel)
    divider:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -5)
    
    -- Info text
    local info = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    info:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 0, -10)
    info:SetWidth(550)
    info:SetJustifyH("LEFT")
    info:SetText("Select which game sounds to use for each event type. You can preview sounds before selecting them.")
    
    -- Create scrollframe for sound categories
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", info, "BOTTOMLEFT", 0, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -26, 30)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(550, 1)
    scrollFrame:SetScrollChild(content)
    
    local yOffset = 0
    local soundCategories = {
        {id = "levelup", name = "Level Up", desc = "Sound played when you gain a level"},
        {id = "achievement", name = "Achievement", desc = "Sound played when you earn an achievement"},
        {id = "quest", name = "Quest Complete", desc = "Sound played when you complete a quest"},
        {id = "reputation", name = "Reputation", desc = "Sound played when you gain reputation"},
        {id = "honorrank", name = "Honor Rank", desc = "Sound played when you gain honor rank"},
        {id = "renownrank", name = "Renown Rank", desc = "Sound played when you gain renown"},
        {id = "tradingpost", name = "Trading Post", desc = "Sound played for trading post rewards"},
        {id = "battlepet", name = "Battle Pet", desc = "Sound played when pet battles level up"},
        {id = "delvecompanion", name = "Delve Companion", desc = "Sound played for delve companion events"}
    }
    
    -- Placeholder game list (will be populated from registry later)
    local games = {
        {value = "default", text = "Default WoW"},
        {value = "wowdefault", text = "WoW Built-in Sounds"},
        {value = "finalfantasy", text = "Final Fantasy"},
        {value = "zelda", text = "Legend of Zelda"},
        {value = "pokemon", text = "Pokemon"},
        {value = "mario", text = "Super Mario"},
        {value = "sonic", text = "Sonic"},
        {value = "metroid", text = "Metroid"},
        {value = "megaman", text = "Mega Man"}
    }
    
    for _, category in ipairs(soundCategories) do
        -- Category frame
        local catFrame = CreateFrame("Frame", nil, content)
        catFrame:SetPoint("TOPLEFT", 0, -yOffset)
        catFrame:SetSize(540, 60)
        
        -- Category name
        local catName = catFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        catName:SetPoint("TOPLEFT", 5, -5)
        catName:SetText(category.name)
        
        -- Category description
        local catDesc = catFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        catDesc:SetPoint("TOPLEFT", catName, "BOTTOMLEFT", 0, -2)
        catDesc:SetText(category.desc)
        catDesc:SetTextColor(0.7, 0.7, 0.7)
        
        -- Dropdown
        local dropdown = widgets:CreateDropdown(catFrame, "", 200, games)
        dropdown:SetPoint("LEFT", catFrame, "LEFT", 200, 0)
        
        UIDropDownMenu_Initialize(dropdown, function(self)
            for _, game in ipairs(games) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = game.text
                info.value = game.value
                info.func = function()
                    BLU.db.profile.selectedSounds[category.id] = game.value
                    UIDropDownMenu_SetText(self, game.text)
                end
                info.checked = BLU.db.profile.selectedSounds[category.id] == game.value
                UIDropDownMenu_AddButton(info)
            end
        end)
        
        -- Set current selection
        local currentSound = BLU.db.profile.selectedSounds[category.id] or "default"
        for _, game in ipairs(games) do
            if game.value == currentSound then
                UIDropDownMenu_SetText(dropdown, game.text)
                break
            end
        end
        
        -- Preview button
        local previewBtn = widgets:CreateButton(catFrame, "Preview", 70, 22, "Preview this sound")
        previewBtn:SetPoint("LEFT", dropdown, "RIGHT", 10, 0)
        previewBtn:SetScript("OnClick", function()
            local selected = BLU.db.profile.selectedSounds[category.id] or "default"
            if BLU.PlayCategorySound then
                BLU:PlayCategorySound(category.id, selected)
            else
                BLU:Print("Preview not yet available")
            end
        end)
        
        yOffset = yOffset + 65
    end
    
    content:SetHeight(yOffset)
    
    -- Random sounds option
    local randomCheck = widgets:CreateCheckbox(panel, "Use random sounds", "Randomly select from all available sounds for each event")
    randomCheck:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 0, 5)
    randomCheck:SetChecked(BLU.db.profile.randomSounds)
    randomCheck:SetScript("OnClick", function(self)
        BLU.db.profile.randomSounds = self:GetChecked()
    end)
    
    -- Browse sounds button
    local browseButton = widgets:CreateButton(panel, "Browse All Sounds", 140, 22, "Open the sound browser to preview all available sounds")
    browseButton:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)
    browseButton:SetScript("OnClick", function()
        if BLU.OpenSoundBrowser then
            BLU:OpenSoundBrowser()
        else
            BLU:Print("Sound browser not yet implemented")
        end
    end)
end