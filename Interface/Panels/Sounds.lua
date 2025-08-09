--=====================================================================================
-- BLU | Sounds Panel - Enhanced with Dropdown Menus and SharedMedia
-- Author: donniedice  
-- Description: Advanced sound configuration with nested dropdowns and external sound support
--=====================================================================================

local addonName, BLU = ...

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

-- Build comprehensive sound list from all sources
local function GetAllSounds()
    local sounds = {}
    
    -- Add default WoW sounds
    local wowSounds = {
        {value = "wow:default_levelup", text = "Default Level Up", category = "WoW Default Sounds", source = "WoW"},
        {value = "wow:default_achievement", text = "Default Achievement", category = "WoW Default Sounds", source = "WoW"},
        {value = "wow:default_quest", text = "Default Quest Complete", category = "WoW Default Sounds", source = "WoW"},
        {value = "wow:default_reputation", text = "Default Reputation", category = "WoW Default Sounds", source = "WoW"},
        {value = "wow:default_pvp", text = "Default PvP Sound", category = "WoW Default Sounds", source = "WoW"},
        {value = "wow:garrison_complete", text = "Garrison Complete", category = "WoW Default Sounds", source = "WoW"},
        {value = "wow:ready_check", text = "Ready Check", category = "WoW Default Sounds", source = "WoW"},
    }
    
    for _, sound in ipairs(wowSounds) do
        table.insert(sounds, sound)
    end
    
    -- Add BLU built-in sounds (with volume variants)
    -- These are organized by game franchise
    local bluSounds = {
        -- Final Fantasy
        {value = "blu:final_fantasy", text = "Victory Fanfare", category = "BLU Sounds - Final Fantasy", source = "BLU"},
        {value = "blu:final_fantasy_levelup", text = "Level Up", category = "BLU Sounds - Final Fantasy", source = "BLU"},
        {value = "blu:final_fantasy_fanfare", text = "Fanfare", category = "BLU Sounds - Final Fantasy", source = "BLU"},
        
        -- Zelda
        {value = "blu:zelda_chest", text = "Chest Open", category = "BLU Sounds - Legend of Zelda", source = "BLU"},
        {value = "blu:zelda_secret", text = "Secret Found", category = "BLU Sounds - Legend of Zelda", source = "BLU"},
        {value = "blu:zelda_item", text = "Item Get", category = "BLU Sounds - Legend of Zelda", source = "BLU"},
        
        -- Pokemon
        {value = "blu:pokemon_levelup", text = "Level Up", category = "BLU Sounds - Pokemon", source = "BLU"},
        {value = "blu:pokemon_evolve", text = "Pokemon Evolution", category = "BLU - Pokemon", source = "BLU"},
        {value = "blu:pokemon_caught", text = "Pokemon Caught", category = "BLU - Pokemon", source = "BLU"},
        
        -- Mario
        {value = "blu:mario_coin", text = "Mario Coin", category = "BLU - Super Mario", source = "BLU"},
        {value = "blu:mario_powerup", text = "Mario Power Up", category = "BLU - Super Mario", source = "BLU"},
        {value = "blu:mario_1up", text = "Mario 1-Up", category = "BLU - Super Mario", source = "BLU"},
        
        -- Sonic
        {value = "blu:sonic_ring", text = "Sonic Ring", category = "BLU - Sonic", source = "BLU"},
        {value = "blu:sonic_emerald", text = "Sonic Emerald", category = "BLU - Sonic", source = "BLU"},
        {value = "blu:sonic_speed", text = "Sonic Speed Boost", category = "BLU - Sonic", source = "BLU"},
        
        -- Elder Scrolls
        {value = "blu:skyrim_levelup", text = "Skyrim Level Up", category = "BLU - Elder Scrolls", source = "BLU"},
        {value = "blu:morrowind_levelup", text = "Morrowind Level Up", category = "BLU - Elder Scrolls", source = "BLU"},
        {value = "blu:oblivion_levelup", text = "Oblivion Level Up", category = "BLU - Elder Scrolls", source = "BLU"},
        
        -- Witcher
        {value = "blu:witcher_levelup", text = "Witcher Level Up", category = "BLU - The Witcher", source = "BLU"},
        {value = "blu:witcher_quest", text = "Witcher Quest Complete", category = "BLU - The Witcher", source = "BLU"},
        
        -- Diablo
        {value = "blu:diablo_levelup", text = "Diablo Level Up", category = "BLU - Diablo", source = "BLU"},
        {value = "blu:diablo_legendary", text = "Diablo Legendary Drop", category = "BLU - Diablo", source = "BLU"},
        
        -- Warcraft
        {value = "blu:warcraft3_questcomplete", text = "WC3 Quest Complete", category = "BLU - Warcraft", source = "BLU"},
        {value = "blu:warcraft3_herolevelup", text = "WC3 Hero Level Up", category = "BLU - Warcraft", source = "BLU"},
        
        -- Default/Generic
        {value = "blu:default", text = "Default Sound", category = "BLU - Default", source = "BLU"},
        {value = "none", text = "No Sound", category = "BLU - Default", source = "BLU"}
    }
    
    for _, sound in ipairs(bluSounds) do
        table.insert(sounds, sound)
    end
    
    -- Add SharedMedia sounds if available
    if BLU.Modules and BLU.Modules.sharedmedia then
        local sharedMedia = BLU.Modules.sharedmedia
        local externalSounds = sharedMedia:GetExternalSounds()
        
        for name, info in pairs(externalSounds) do
            table.insert(sounds, {
                value = "external:" .. name,
                text = name,
                category = "SharedMedia - " .. (info.category or "Other"),
                source = "SharedMedia",
                path = info.path,
                description = string.format("External sound from %s", info.source or "Unknown")
            })
        end
    end
    
    return sounds
end

function BLU.CreateSoundsPanel()
    local panel = CreateFrame("Frame", nil, UIParent)
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
    
    -- SharedMedia detection status
    local sharedMediaStatus = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sharedMediaStatus:SetPoint("TOPRIGHT", -20, -50)
    
    -- Update SharedMedia status
    local function UpdateSharedMediaStatus()
        local loadedAddons = BLU.Modules.sharedmedia and BLU.Modules.sharedmedia:GetLoadedSoundAddons() or {}
        if #loadedAddons > 0 then
            sharedMediaStatus:SetText("|cff00ff00SharedMedia Detected:|r " .. table.concat(loadedAddons, ", "))
        else
            sharedMediaStatus:SetText("|cffff0000No SharedMedia addons found|r")
        end
    end
    
    -- Refresh button for scanning external sounds
    local refreshBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    refreshBtn:SetSize(100, 22)
    refreshBtn:SetPoint("TOPRIGHT", -20, -70)
    refreshBtn:SetText("Refresh Sounds")
    refreshBtn:SetScript("OnClick", function()
        if BLU.Modules.sharedmedia then
            BLU.Modules.sharedmedia:ScanExternalSounds()
            
            -- Refresh all dropdowns
            for _, row in ipairs(panel.eventRows) do
                if row.dropdown then
                    local allSounds = GetAllSounds()
                    row.dropdown:SetItems(allSounds)
                end
            end
            
            UpdateSharedMediaStatus()
            BLU:Print("|cff00ff00Sound list refreshed!|r")
        end
    end)
    
    UpdateSharedMediaStatus()
    
    -- Create event rows
    panel.eventRows = {}
    panel.dropdowns = {}
    
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
        
        -- Sound dropdown using enhanced dropdown system
        local dropdown = BLU.Dropdown:Create(row, 250, 30)
        dropdown:SetPoint("LEFT", name, "RIGHT", 10, 0)
        row.dropdown = dropdown -- Store reference for refresh
        
        -- Get all available sounds
        local allSounds = GetAllSounds()
        dropdown:SetItems(allSounds)
        
        -- Set current selection
        local currentSound = BLU:GetDB({"selectedSounds", event.id}) or "blu:default"
        dropdown:SetValue(currentSound)
        
        -- Set callback for selection changes
        dropdown:SetCallback(function(value, item)
            BLU:SetDB({"selectedSounds", event.id}, value)
            
            -- Show notification
            if BLU.db.profile.debugMode then
                BLU:Print(string.format("|cff00ff00%s:|r Set to %s", event.name, item.text))
            end
            
            -- Auto-play preview if enabled
            if BLU.db.profile.autoPreview then
                -- Play the selected sound
                if value:find("^blu:") then
                    local soundFile = value:gsub("^blu:", "")
                    BLU:PlayTestSound(event.id)
                elseif value:find("^external:") then
                    local soundName = value:gsub("^external:", "")
                    if BLU.Modules.sharedmedia then
                        BLU.Modules.sharedmedia:PlayExternalSound(soundName)
                    end
                end
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
            local vol = math.floor(value)
            volumeText:SetText(vol .. "%")
            -- Store per-event volume
            BLU:SetDB({"eventVolumes", event.id}, vol)
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
    
    -- Category filter dropdown using enhanced system
    local categoryDropdown = BLU.Dropdown:Create(content, 200, 30)
    categoryDropdown:SetPoint("LEFT", searchBox, "RIGHT", 20, 2)
    
    -- Build category list
    local categoryItems = {
        {value = "all", text = "All Categories", category = "Filter"}
    }
    
    -- Get unique categories from all sounds
    local allSounds = GetAllSounds()
    local uniqueCategories = {}
    for _, sound in ipairs(allSounds) do
        if sound.category and not uniqueCategories[sound.category] then
            uniqueCategories[sound.category] = true
            table.insert(categoryItems, {
                value = sound.category,
                text = sound.category,
                category = "Categories"
            })
        end
    end
    
    categoryDropdown:SetItems(categoryItems)
    categoryDropdown:SetValue("all")
    
    categoryDropdown:SetCallback(function(value, item)
        if value == "all" then
            panel:FilterCategory(nil)
        else
            panel:FilterCategory(value)
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
    
    -- Populate sound list with all available sounds
    local buttonYOffset = -5
    local buttonIndex = 1
    
    for _, soundData in ipairs(allSounds) do
        local btn = CreateFrame("Button", nil, soundList)
        btn:SetSize(660, 24)
        btn:SetPoint("TOPLEFT", 5, buttonYOffset)
        
        local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints()
        highlight:SetColorTexture(0.3, 0.3, 0.3, 0.3)
        
        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", 10, 0)
        
        -- Color code by source
        local displayText = soundData.text
        if soundData.source == "BLU" then
            displayText = "|cff05dffa" .. displayText .. "|r"
        elseif soundData.source == "SharedMedia" then
            displayText = "|cff00ff00" .. displayText .. "|r"
        end
        
        text:SetText(string.format("[%s] %s", soundData.category or "Unknown", displayText))
        btn.text = text
        btn.soundData = soundData
        btn.category = soundData.category
            
            -- Play button
            local playBtn = CreateFrame("Button", nil, btn)
            playBtn:SetSize(20, 20)
            playBtn:SetPoint("RIGHT", -10, 0)
            playBtn:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
            playBtn:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
            playBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
            
        playBtn:SetScript("OnClick", function()
            -- Play sound based on type
            if soundData.value:find("^blu:") then
                local soundFile = soundData.value:gsub("^blu:", "")
                BLU:PlayTestSound("levelup") -- Use levelup as test event
            elseif soundData.value:find("^external:") then
                local soundName = soundData.value:gsub("^external:", "")
                if BLU.Modules.sharedmedia then
                    BLU.Modules.sharedmedia:PlayExternalSound(soundName)
                end
            end
        end)
        
        panel.soundButtons[buttonIndex] = btn
        buttonIndex = buttonIndex + 1
        buttonYOffset = buttonYOffset - 25
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
    
    -- Sound Pack Management Section (added after browse section)
    yOffset = yOffset - 40
    
    local packTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    packTitle:SetPoint("TOPLEFT", 16, yOffset)
    packTitle:SetText("Sound Pack Management")
    packTitle:SetTextColor(0, 0.8, 1)
    
    yOffset = yOffset - 30
    
    local packDesc = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    packDesc:SetPoint("TOPLEFT", 20, yOffset)
    packDesc:SetPoint("TOPRIGHT", -20, yOffset)
    packDesc:SetText("Manage external sound packs from SharedMedia-compatible addons")
    packDesc:SetTextColor(0.7, 0.7, 0.7)
    packDesc:SetJustifyH("LEFT")
    
    yOffset = yOffset - 30
    
    -- Available sound packs list
    local packListFrame = CreateFrame("Frame", nil, content)
    packListFrame:SetPoint("TOPLEFT", 20, yOffset)
    packListFrame:SetPoint("TOPRIGHT", -20, yOffset)
    packListFrame:SetHeight(200)
    
    local packListBg = packListFrame:CreateTexture(nil, "BACKGROUND")
    packListBg:SetAllPoints()
    packListBg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
    
    -- Create scroll frame for pack list
    local packScrollFrame = CreateFrame("ScrollFrame", nil, packListFrame, "UIPanelScrollFrameTemplate")
    packScrollFrame:SetPoint("TOPLEFT", 5, -5)
    packScrollFrame:SetPoint("BOTTOMRIGHT", -25, 5)
    
    local packContent = CreateFrame("Frame", nil, packScrollFrame)
    packContent:SetSize(packScrollFrame:GetWidth(), 1)
    packScrollFrame:SetScrollChild(packContent)
    
    -- Function to populate pack list
    local function UpdatePackList()
        -- Clear existing
        for i = 1, packContent:GetNumChildren() do
            local child = select(i, packContent:GetChildren())
            child:Hide()
            child:SetParent(nil)
        end
        
        local packYOffset = 0
        
        -- Get available sound packs
        local packs = {}
        if BLU.Modules and BLU.Modules.sharedmedia then
            packs = BLU.Modules.sharedmedia:GetLoadedSoundAddons() or {}
        end
        
        if #packs == 0 then
            local noPacks = packContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            noPacks:SetPoint("CENTER", packContent, "CENTER", 0, 0)
            noPacks:SetText("No external sound packs detected")
            noPacks:SetTextColor(0.5, 0.5, 0.5)
        else
            for i, packName in ipairs(packs) do
                local packRow = CreateFrame("Frame", nil, packContent)
                packRow:SetSize(packContent:GetWidth() - 10, 30)
                packRow:SetPoint("TOPLEFT", 5, -packYOffset)
                
                -- Background
                local packBg = packRow:CreateTexture(nil, "BACKGROUND")
                packBg:SetAllPoints()
                packBg:SetColorTexture(0.15, 0.15, 0.15, 0.3)
                if i % 2 == 0 then
                    packBg:SetColorTexture(0.2, 0.2, 0.2, 0.3)
                end
                
                -- Pack name
                local packNameText = packRow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                packNameText:SetPoint("LEFT", 10, 0)
                packNameText:SetText(packName)
                
                -- Status indicator
                local statusText = packRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                statusText:SetPoint("RIGHT", -10, 0)
                statusText:SetText("|cff00ff00Loaded|r")
                
                packYOffset = packYOffset + 32
            end
        end
        
        packContent:SetHeight(math.max(packYOffset, 190))
    end
    
    -- Update pack list on show
    if not panel.hasOnShowHandler then
        panel:SetScript("OnShow", function()
            UpdatePackList()
            UpdateSharedMediaStatus()
        end)
        panel.hasOnShowHandler = true
    end
    
    -- Buttons for pack management
    local scanBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    scanBtn:SetSize(120, 24)
    scanBtn:SetPoint("TOPLEFT", packListFrame, "BOTTOMLEFT", 0, -10)
    scanBtn:SetText("Scan for Packs")
    scanBtn:SetScript("OnClick", function()
        if BLU.Modules and BLU.Modules.sharedmedia then
            BLU.Modules.sharedmedia:ScanExternalSounds()
            UpdatePackList()
            UpdateSharedMediaStatus()
            
            -- Refresh dropdowns
            for _, row in ipairs(panel.eventRows) do
                if row.dropdown then
                    local allSounds = GetAllSounds()
                    row.dropdown:SetItems(allSounds)
                end
            end
            
            BLU:Print("|cff00ff00Sound packs scanned successfully!|r")
        else
            BLU:Print("|cffff0000SharedMedia module not loaded|r")
        end
    end)
    
    local reloadBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    reloadBtn:SetSize(120, 24)
    reloadBtn:SetPoint("LEFT", scanBtn, "RIGHT", 10, 0)
    reloadBtn:SetText("Reload UI")
    reloadBtn:SetScript("OnClick", function()
        ReloadUI()
    end)
    
    local helpBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    helpBtn:SetSize(120, 24)
    helpBtn:SetPoint("LEFT", reloadBtn, "RIGHT", 10, 0)
    helpBtn:SetText("Get More Packs")
    helpBtn:SetScript("OnClick", function()
        StaticPopup_Show("BLU_SOUNDPACK_INFO")
    end)
    
    -- Register with tab system
    if BLU.TabSystem then
        BLU.TabSystem:RegisterPanel("sounds", panel)
    end
    
    return panel
end

-- Sound pack info dialog
StaticPopupDialogs["BLU_SOUNDPACK_INFO"] = {
    text = "To add more sound packs:\n\n1. Install SharedMedia addons from CurseForge\n2. Install SoundPak addons\n3. Reload UI after installing\n4. Click 'Scan for Packs' to detect new sounds\n\nPopular sound pack addons:\n- SharedMedia_MyMedia\n- SoundPak_Various\n- Epic Music Player",
    button1 = "Got it!",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true
}