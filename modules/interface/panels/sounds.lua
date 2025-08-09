--=====================================================================================
-- BLU - interface/panels/sounds.lua
-- Sound selection panel with enhanced visual design
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateSoundsPanel(panel)
    local widgets = BLU.Widgets
    
    -- Create scrollable content
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth(), 800)
    scrollFrame:SetScrollChild(content)
    
    -- Sound Selection header with icon
    local header = widgets:CreateHeader(content, "|TInterface\\Icons\\INV_Misc_Bell_01:20:20|t Sound Pack Selection")
    header:SetPoint("TOPLEFT", 0, 0)
    
    local divider = widgets:CreateDivider(content)
    divider:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -5)
    
    -- Info text
    local info = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    info:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 0, -10)
    info:SetWidth(550)
    info:SetJustifyH("LEFT")
    info:SetText("Choose sound packs for each event type. Mix and match from over 50 games!")
    
    -- Quick actions bar
    local actionBar = CreateFrame("Frame", nil, content)
    actionBar:SetPoint("TOPLEFT", info, "BOTTOMLEFT", 0, -15)
    actionBar:SetSize(550, 30)
    
    -- Set all to dropdown
    local setAllLabel = actionBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    setAllLabel:SetPoint("LEFT", 0, 0)
    setAllLabel:SetText("Set all to:")
    
    local setAllDropdown = CreateFrame("Frame", "BLUSetAllDropdown", actionBar, "UIDropDownMenuTemplate")
    setAllDropdown:SetPoint("LEFT", setAllLabel, "RIGHT", 5, -2)
    UIDropDownMenu_SetWidth(setAllDropdown, 150)
    
    -- Available game packs with icons
    local games = {
        {value = "default", text = "|TInterface\\Icons\\INV_Misc_QuestionMark:16:16|t Default WoW", icon = "INV_Misc_QuestionMark"},
        {value = "wowdefault", text = "|TInterface\\Icons\\Achievement_General:16:16|t WoW Built-in", icon = "Achievement_General"},
        {value = "finalfantasy", text = "|TInterface\\Icons\\INV_Sword_39:16:16|t Final Fantasy", icon = "INV_Sword_39"},
        {value = "zelda", text = "|TInterface\\Icons\\INV_Shield_09:16:16|t Legend of Zelda", icon = "INV_Shield_09"},
        {value = "pokemon", text = "|TInterface\\Icons\\INV_Pet_PetTrap01:16:16|t Pokemon", icon = "INV_Pet_PetTrap01"},
        {value = "mario", text = "|TInterface\\Icons\\INV_Mushroom_11:16:16|t Super Mario", icon = "INV_Mushroom_11"},
        {value = "sonic", text = "|TInterface\\Icons\\INV_Jewelcrafting_Gem_37:16:16|t Sonic", icon = "INV_Jewelcrafting_Gem_37"},
        {value = "metroid", text = "|TInterface\\Icons\\INV_Gizmo_02:16:16|t Metroid", icon = "INV_Gizmo_02"},
        {value = "megaman", text = "|TInterface\\Icons\\INV_Gizmo_RocketBoot_01:16:16|t Mega Man", icon = "INV_Gizmo_RocketBoot_01"}
    }
    
    UIDropDownMenu_Initialize(setAllDropdown, function(self)
        for _, game in ipairs(games) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = game.text
            info.value = game.value
            info.func = function()
                -- Set all categories to this game
                for catId in pairs(BLU.db.profile.selectedSounds) do
                    BLU.db.profile.selectedSounds[catId] = game.value
                end
                UIDropDownMenu_SetText(self, game.text)
                -- Refresh the panel
                if BLU.Tabs and BLU.Tabs.RefreshCurrentTab then
                    BLU.Tabs:RefreshCurrentTab()
                end
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetText(setAllDropdown, "Choose...")
    
    -- Random button
    local randomButton = widgets:CreateButton(actionBar, "Randomize All", 100, 22, "Set all sounds to random selection")
    randomButton:SetPoint("LEFT", setAllDropdown, "RIGHT", 10, 2)
    randomButton:SetScript("OnClick", function()
        for catId in pairs(BLU.db.profile.selectedSounds) do
            local randomGame = games[math.random(#games)]
            BLU.db.profile.selectedSounds[catId] = randomGame.value
        end
        if BLU.Tabs and BLU.Tabs.RefreshCurrentTab then
            BLU.Tabs:RefreshCurrentTab()
        end
    end)
    
    -- Sound categories section
    local catHeader = widgets:CreateHeader(content, "|TInterface\\Icons\\Spell_ChargePositive:20:20|t Event Sound Configuration")
    catHeader:SetPoint("TOPLEFT", actionBar, "BOTTOMLEFT", 0, -20)
    
    local catDivider = widgets:CreateDivider(content)
    catDivider:SetPoint("TOPLEFT", catHeader, "BOTTOMLEFT", 0, -5)
    
    local yOffset = 0
    local soundCategories = {
        {id = "levelup", name = "|TInterface\\Icons\\Achievement_Level_100:20:20|t Level Up", desc = "Played when you gain a level"},
        {id = "achievement", name = "|TInterface\\Icons\\Achievement_GuildPerk_MobileMailbox:20:20|t Achievement", desc = "Played when you earn an achievement"},
        {id = "quest", name = "|TInterface\\Icons\\INV_Misc_Note_01:20:20|t Quest Complete", desc = "Played when you complete a quest"},
        {id = "reputation", name = "|TInterface\\Icons\\Achievement_Reputation_01:20:20|t Reputation", desc = "Played when you gain reputation"},
        {id = "honorrank", name = "|TInterface\\Icons\\PVPCurrency-Honor-Horde:20:20|t Honor Rank", desc = "Played when you gain honor rank"},
        {id = "renownrank", name = "|TInterface\\Icons\\UI_MajorFaction_Centaur:20:20|t Renown Rank", desc = "Played when you gain renown"},
        {id = "tradingpost", name = "|TInterface\\Icons\\INV_Tradingpost_Currency:20:20|t Trading Post", desc = "Played for trading post rewards"},
        {id = "battlepet", name = "|TInterface\\Icons\\INV_Pet_BattlePetTraining:20:20|t Battle Pet", desc = "Played for pet battle victories"},
        {id = "delvecompanion", name = "|TInterface\\Icons\\UI_MajorFaction_Delve:20:20|t Delve Companion", desc = "Played for delve companion events"}
    }
    
    local categoryStartY = select(5, catDivider:GetPoint())
    
    for i, category in ipairs(soundCategories) do
        -- Category frame with background
        local catFrame = CreateFrame("Frame", nil, content)
        catFrame:SetPoint("TOPLEFT", 0, categoryStartY - 10 - (i-1) * 75)
        catFrame:SetSize(540, 70)
        
        -- Alternating background
        if i % 2 == 0 then
            local bg = catFrame:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
        end
        
        -- Category name with icon
        local catName = catFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        catName:SetPoint("TOPLEFT", 10, -10)
        catName:SetText(category.name)
        
        -- Category description
        local catDesc = catFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        catDesc:SetPoint("TOPLEFT", catName, "BOTTOMLEFT", 22, -2)
        catDesc:SetText(category.desc)
        catDesc:SetTextColor(0.7, 0.7, 0.7)
        
        -- Dropdown
        local dropdown = CreateFrame("Frame", "BLUSoundDropdown"..i, catFrame, "UIDropDownMenuTemplate")
        dropdown:SetPoint("RIGHT", catFrame, "RIGHT", -80, 0)
        UIDropDownMenu_SetWidth(dropdown, 180)
        
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
        
        -- Preview button with play icon
        local previewBtn = CreateFrame("Button", nil, catFrame, "UIPanelButtonTemplate")
        previewBtn:SetPoint("RIGHT", catFrame, "RIGHT", -5, 0)
        previewBtn:SetSize(22, 22)
        previewBtn:SetNormalTexture("Interface\\AddOns\\BLU\\media\\images\\play")
        previewBtn:SetScript("OnClick", function()
            local selected = BLU.db.profile.selectedSounds[category.id] or "default"
            if BLU.PlayCategorySound then
                BLU:PlayCategorySound(category.id, selected)
            end
        end)
        previewBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Preview Sound")
            GameTooltip:AddLine("Click to play this sound", 1, 1, 1)
            GameTooltip:Show()
        end)
        previewBtn:SetScript("OnLeave", GameTooltip_Hide)
    end
    
    -- Footer info
    local footerInfo = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    footerInfo:SetPoint("BOTTOM", content, "BOTTOM", 0, 20)
    footerInfo:SetText("|cff808080Note: Sound packs without .ogg files will use WoW default sounds|r")
    
    content:SetHeight(750)
end