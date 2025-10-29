--=====================================================================================
-- BLU - interface/options_new.lua
-- New options panel with SimpleQuestPlates-inspired design
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

-- Create options module
local Options = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["options"] = Options

-- Panel dimensions
local PANEL_WIDTH = 700
local PANEL_HEIGHT = 600

-- Test SharedMedia functionality
function Options:TestSharedMedia()
    BLU:Print("=== SharedMedia Debug Test ===")
    
    -- Test LibStub
    local hasLibStub = LibStub ~= nil
    BLU:Print(string.format("LibStub available: %s", tostring(hasLibStub)))
    
    if hasLibStub then
        local LSM = LibStub("LibSharedMedia-3.0", true)
        local hasLSM = LSM ~= nil
        BLU:Print(string.format("LibSharedMedia-3.0 available: %s", tostring(hasLSM)))
        
        if hasLSM then
            local soundList = LSM:List("sound")
            BLU:Print(string.format("LSM sound count: %d", soundList and #soundList or 0))
            
            if soundList and #soundList > 0 then
                BLU:Print("First 5 LSM sounds:")
                for i = 1, math.min(5, #soundList) do
                    BLU:Print(string.format("  %d. %s", i, soundList[i]))
                end
            end
        end
    end
    
    -- Test BLU SharedMedia module
    local hasBLUSharedMedia = BLU.Modules.sharedmedia ~= nil
    BLU:Print(string.format("BLU SharedMedia module exists: %s", tostring(hasBLUSharedMedia)))
    
    if hasBLUSharedMedia then
        local hasGetSoundCategories = BLU.Modules.sharedmedia.GetSoundCategories ~= nil
        BLU:Print(string.format("GetSoundCategories function exists: %s", tostring(hasGetSoundCategories)))
        
        if hasGetSoundCategories then
            local categories = BLU.Modules.sharedmedia:GetSoundCategories()
            local categoriesType = type(categories)
            BLU:Print(string.format("Categories type: %s", categoriesType))
            
            if categoriesType == "table" then
                local count = 0
                for category, sounds in pairs(categories) do
                    count = count + 1
                    BLU:Print(string.format("  Category '%s': %d sounds", category, sounds and #sounds or 0))
                end
                BLU:Print(string.format("Total categories: %d", count))
            end
        end
    end
    
    BLU:Print("=== End SharedMedia Test ===")
end

-- Create tab button with SimpleQuestPlates style
local function CreateTabButton(parent, text, index, row, col, panel)
    local button = CreateFrame("Button", "BLUTab" .. text:gsub(" ", ""), parent)
    -- Smaller tabs for better fit
    button:SetSize(80, 22)
    
    -- Calculate position based on row and column with tighter spacing
    local tabWidth = 80
    local tabSpacing = 3
    local xOffset = 10 + (col - 1) * (tabWidth + tabSpacing)
    local yOffset = -8 - (row - 1) * 26  -- 22 height + 4 spacing
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)
    parent[index] = button
    
    -- Background
    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    button.bg = bg
    
    -- Border frame (Updated for Dragonflight)
    local border = CreateFrame("Frame", nil, button, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({
        edgeFile = "Interface\Buttons\WHITE8x8",
        edgeSize = 1,
    })
    border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    button.border = border
    
    -- Text with smaller font
    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    buttonText:SetPoint("CENTER", 0, 0)
    buttonText:SetText(text)
    buttonText:SetTextColor(0.8, 0.8, 0.8, 1)
    button.text = buttonText
    
    -- Scripts
    button:SetScript("OnClick", function(self)
        panel:SelectTab(self.tabIndex)
    end)
    
    button:SetScript("OnEnter", function(self)
        if not self.isActive then
            self.border:SetBackdropBorderColor(unpack(BLU.Design.Colors.Primary))
            self.text:SetTextColor(unpack(BLU.Design.Colors.Primary))
        end
    end)
    
    button:SetScript("OnLeave", function(self)
        if not self.isActive then
            self.border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
            self.text:SetTextColor(0.7, 0.7, 0.7, 1)
        end
    end)
    
    button.tabIndex = index
    
    function button:SetActive(active)
        self.isActive = active
        if active then
            self.bg:SetColorTexture(0.08, 0.08, 0.08, 1)
            self.text:SetTextColor(unpack(BLU.Design.Colors.Primary))
            self.border:SetBackdropBorderColor(unpack(BLU.Design.Colors.Primary))
        else
            self.bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
            self.text:SetTextColor(0.7, 0.7, 0.7, 1)
            self.border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        end
    end
    
    return button
end

-- Create dropdown helper
local function CreateDropdown(parent, label, width)
    local container = CreateFrame("Frame", nil, parent)
    container:SetHeight(45)
    
    local labelText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelText:SetPoint("TOPLEFT", 0, 0)
    labelText:SetText(label)
    
    local dropdown = CreateFrame("Frame", nil, container, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", labelText, "BOTTOMLEFT", -20, -5)
    UIDropDownMenu_SetWidth(dropdown, width or 200)
    
    container.label = labelText
    container.dropdown = dropdown
    
    return container
end

-- Create main options panel
function Options:CreateOptionsPanel()
    BLU:PrintDebug("Creating new options panel...")
    
    -- Create main frame
    local panel = CreateFrame("Frame", "BLUOptionsPanel", UIParent)
    panel.name = "Better Level-Up!"
    
    -- Custom icon for the settings menu
    panel.OnCommit = function() end
    panel.OnDefault = function() end
    panel.OnRefresh = function() end
    
    -- Store reference
    BLU.OptionsPanel = panel
    
    -- Main container with custom background (SQP style)
    local container = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    container:SetPoint("TOPLEFT", 0, 0)
    container:SetPoint("BOTTOMRIGHT", 0, 0)
    container:SetBackdrop(BLU.Design.Backdrops.Dark)
    container:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    container:SetBackdropBorderColor(unpack(BLU.Design.Colors.Primary))
    
    -- Create header
    local header = CreateFrame("Frame", nil, container, "BackdropTemplate")
    header:SetHeight(60)  -- Compact header
    header:SetPoint("TOPLEFT", 5, -5)
    header:SetPoint("TOPRIGHT", -5, -5)
    header:SetBackdrop(BLU.Design.Backdrops.Dark)
    header:SetBackdropColor(0.08, 0.08, 0.08, 0.8)
    header:SetBackdropBorderColor(unpack(BLU.Design.Colors.Primary))
    
    -- Logo/Icon
    local logo = header:CreateTexture(nil, "ARTWORK")
    logo:SetSize(40, 40)
    logo:SetPoint("LEFT", 10, 0)
    logo:SetTexture("Interface\AddOns\BLU\media\images\icon")
    
    -- Title (with colored letters like SQP)
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", logo, "RIGHT", 10, 5)
    title:SetText("|cff05dffaBLU|r - Better Level-Up!")
    
    -- Subtitle
    local subtitle = header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
    subtitle:SetText("Iconic game sounds for World of Warcraft events")
    subtitle:SetTextColor(0.7, 0.7, 0.7)
    
    -- Version & Author
    local version = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    version:SetPoint("TOPRIGHT", -15, -15)
    version:SetText("v" .. (BLU.version or "6.0.0-alpha"))
    version:SetTextColor(unpack(BLU.Design.Colors.Primary))
    
    local author = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    author:SetPoint("TOP", version, "BOTTOM", 0, -2)
    author:SetText("by donniedice")
    author:SetTextColor(0.7, 0.7, 0.7)
    
    -- RGX Mods branding
    local branding = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    branding:SetPoint("BOTTOMRIGHT", -15, 10)
    branding:SetText("|cffffd700RGX Mods|r")
    
    -- Tab container (SQP style tabs) - multiple rows
    local tabContainer = CreateFrame("Frame", nil, container)
    tabContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -2)
    tabContainer:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -2)
    tabContainer:SetHeight(60)  -- Height for 2 rows
    
    -- Add background for tab container
    local tabBg = tabContainer:CreateTexture(nil, "BACKGROUND")
    tabBg:SetAllPoints()
    tabBg:SetColorTexture(0.03, 0.03, 0.03, 0.6)
    
    -- Create tabs for each sound event type (reorganized for better fit)
        local tabs = {
            -- Row 1 - Core tabs and primary events
            {text = "General", create = BLU.CreateGeneralPanel, row = 1, col = 1},
            {text = "Sounds", create = BLU.CreateSoundsPanel, row = 1, col = 2},
            {text = "Level Up", eventType = "levelup", row = 1, col = 3},
            {text = "Achievement", eventType = "achievement", row = 1, col = 4},
            {text = "Quest", eventType = "quest", row = 1, col = 5},
            {text = "Reputation", eventType = "reputation", row = 1, col = 6},
            -- Row 2 - Secondary events
            {text = "Battle Pets", eventType = "battlepet", row = 2, col = 1},
            {text = "Honor", eventType = "honorrank", row = 2, col = 2},
            {text = "Renown", eventType = "renownrank", row = 2, col = 3},
            {text = "Trading Post", eventType = "tradingpost", row = 2, col = 4},
            {text = "Delve", eventType = "delvecompanion", row = 2, col = 5},
            {text = "About", create = BLU.CreateAboutPanel, row = 2, col = 6}
        }
    
    panel.tabs = {}
    panel.contents = {}
    
    for i, tabInfo in ipairs(tabs) do
        local tab = CreateTabButton(tabContainer, tabInfo.text, i, tabInfo.row, tabInfo.col, panel)
        panel.tabs[i] = tab
        
        -- Create content frame with proper padding
        local content = CreateFrame("Frame", nil, container, "BackdropTemplate")
        content:SetPoint("TOPLEFT", tabContainer, "BOTTOMLEFT", 0, -10)
        content:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, 10)
        content:SetBackdrop(BLU.Design.Backdrops.Dark)
        content:SetBackdropColor(0.06, 0.06, 0.06, 0.95)
        content:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
        content:Hide()
        
        if tabInfo.text == "Sounds" then
            panel.soundsContent = content
        end

        -- Create tab content
        if tabInfo.create then
            tabInfo.create(content)
        elseif tabInfo.eventType then
            -- Create sound selection panel for this event type
            BLU.CreateEventSoundPanel(content, tabInfo.eventType, tabInfo.text)
        end
        
        panel.contents[i] = content
    end
    
    -- Tab selection function
    function panel:SelectTab(index)
        for i, tab in ipairs(self.tabs) do
            tab:SetActive(i == index)
            self.contents[i]:SetShown(i == index)
        end
    end
    
    -- Select first tab
    panel:SelectTab(1)
    
    -- Add a custom icon check
    BLU.HasCustomIcon = select(3, C_AddOns.GetAddOnInfo(addonName)) ~= nil
    
    -- Register the panel
    local category
    if Settings and Settings.RegisterCanvasLayoutCategory then
        -- Dragonflight+ (10.0+)
        category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
        BLU.OptionsCategory = category
        BLU:Print("|cff00ccffBLU:|r Options panel registered in Interface Options")
        BLU:PrintDebug("Options panel registered with new Settings API")
    else
        -- Pre-Dragonflight
        InterfaceOptions_AddCategory(panel)
        BLU.OptionsCategory = panel
        BLU:Print("|cff00ccffBLU:|r Options panel registered in Interface Options")
        BLU:PrintDebug("Options panel registered with legacy API")
    end
    
    return panel
end

-- Open options
function Options:OpenOptions()
    BLU:PrintDebug("Options:OpenOptions called. BLU.db is " .. tostring(BLU.db))
    if not BLU.db or not BLU.db.profile then
        BLU:Print("Database not ready. Please wait a moment and try again.")
        return
    end

    -- Create panel if it doesn't exist
    if not BLU.OptionsPanel then
        self:CreateOptionsPanel()
    end
    
    if not BLU.OptionsCategory then
        BLU:Print("Options panel not properly registered.")
        return
    end
    
    if Settings and Settings.OpenToCategory and BLU.OptionsCategory and BLU.OptionsCategory.ID then
        Settings.OpenToCategory(BLU.OptionsCategory.ID)
        C_Timer.After(0.1, function()
            Settings.OpenToCategory(BLU.OptionsCategory.ID)
        end)
    elseif InterfaceOptionsFrame_OpenToCategory and BLU.OptionsCategory then
        InterfaceOptionsFrame_OpenToCategory(BLU.OptionsCategory)
        InterfaceOptionsFrame_OpenToCategory(BLU.OptionsCategory)
    else
        BLU:Print("Unable to open options panel")
    end
end

-- Helper function to create a sound selection dropdown
local function CreateSoundDropdown(parent, eventType, label, yOffset, soundType)
    local actualEventType = soundType or eventType

    -- Container frame with better positioning
    local container = CreateFrame("Frame", nil, parent)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
    container:SetPoint("RIGHT", parent, "RIGHT", -10, 0)
    container:SetHeight(90)
    
    -- Label for the dropdown
    local dropdownLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdownLabel:SetPoint("TOPLEFT", 10, -5)
    dropdownLabel:SetText(BLU.Design.Colors.PrimaryHex .. label .. "|r")
    
    -- Current sound display
    local currentLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    currentLabel:SetPoint("TOPLEFT", dropdownLabel, "BOTTOMLEFT", 0, -5)
    currentLabel:SetText("Currently selected: ")
    currentLabel:SetTextColor(0.7, 0.7, 0.7)
    
    local currentSound = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    currentSound:SetPoint("LEFT", currentLabel, "RIGHT", 5, 0)
    currentSound:SetTextColor(0.02, 0.87, 0.98)
    
    -- Test button and volume slider container
    local controlsFrame = CreateFrame("Frame", nil, container)
    controlsFrame:SetPoint("TOPRIGHT", container, "TOPRIGHT", -150, -20)
    controlsFrame:SetSize(190, 60)
    
    -- Volume dropdown
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
        local volumes = {"None", "Low", "Medium", "High"}
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
    
    -- Test button
    local testBtn = BLU.Design:CreateButton(controlsFrame, "Test", 60, 22)
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

    -- Sound dropdown with better positioning
    local dropdown = CreateFrame("Frame", "BLUDropdown_" .. actualEventType, container, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", currentLabel, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(dropdown, 260)

    -- Store references
    dropdown.currentSound = currentSound
    dropdown.eventId = actualEventType

        -- Initialize dropdown
        UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
            level = level or 1
    
            if not BLU.db or not BLU.db.profile then return end
            BLU.db.profile.selectedSounds = BLU.db.profile.selectedSounds or {}
    
            local function onSoundSelected(value, text)
                BLU.db.profile.selectedSounds[self.eventId] = value
                UIDropDownMenu_SetText(self, text)
                self.currentSound:SetText(text)
                -- Logic to show/hide volume dropdown based on sound type
                if string.find(value, "^blu_") and not string.find(value, "external:") then
                    volumeDropdown:Show()
                else
                    volumeDropdown:Hide()
                end
                CloseDropDownMenus()
            end
    
            local customHierarchy = BLU.SoundRegistry:GetSoundsGroupedForUI(self.eventId)
    
            -- === LEVEL 1: Special Options and Custom Top-Level Groups ===
            if level == 1 then
                -- Special Options (Random, None, Default WoW)
                local specialOptions = {
                    {text = "|cff00ff00Random|r", value = "random"},
                    {text = "None", value = "None"},
                    {text = "Default WoW Sound", value = "default"},
                }
                for _, info in ipairs(specialOptions) do
                    local dInfo = UIDropDownMenu_CreateInfo()
                    dInfo.text = info.text
                    dInfo.value = info.value
                    dInfo.func = function() onSoundSelected(info.value, info.text) end
                    dInfo.checked = BLU.db.profile.selectedSounds[self.eventId] == info.value
                    UIDropDownMenu_AddButton(dInfo, level)
                end
    
                -- Separator
                local sep = UIDropDownMenu_CreateInfo()
                sep.notClickable = true; sep.notCheckable = true
                UIDropDownMenu_AddButton(sep, level)
    
                -- Custom Top-Level Groups (BLU WoW Defaults, BLU Other Game Sounds, Shared Media)
                local sortedTopLevelKeys = {"BLU WoW Defaults", "BLU Other Game Sounds", "Shared Media"}
    
                for _, groupKey in ipairs(sortedTopLevelKeys) do
                    if next(customHierarchy[groupKey]) then -- Only show if it has contents
                        local count = 0
                        if groupKey == "BLU WoW Defaults" then
                            for _, categorySounds in pairs(customHierarchy[groupKey]) do count = count + #categorySounds end
                        else
                            for _, packSounds in pairs(customHierarchy[groupKey]) do count = count + #packSounds end
                        end
    
                        local info = UIDropDownMenu_CreateInfo()
                        info.text = "|cffffff00" .. groupKey .. "|r (" .. count .. ")"
                        info.value = groupKey
                        info.hasArrow = true
                        info.menuList = groupKey -- Pass the group key to the next level
                        info.notCheckable = true
                        UIDropDownMenu_AddButton(info, level)
                    end
                end
    
            -- === LEVEL 2: Custom Grouping Logic ===
            elseif level == 2 then
                local groupKey = menuList
                local subgroups = customHierarchy[groupKey]
                local sortedSubKeys = {}
    
                for subKey in pairs(subgroups) do table.insert(sortedSubKeys, subKey) end
                table.sort(sortedSubKeys)
    
                for _, subKey in ipairs(sortedSubKeys) do
                    local sounds = subgroups[subKey]
    
                    local info = UIDropDownMenu_CreateInfo()
                    info.value = subKey
                    info.notCheckable = true
    
                    if groupKey == "BLU WoW Defaults" then
                        -- Tier 2: Category (e.g. 'Level Up') -> Tier 3: Sound
                        info.text = "|cff99ff99" .. subKey .. "|r (" .. #sounds .. ")"
                        info.hasArrow = true
                        info.menuList = {group = groupKey, sub = subKey, type = "category"}
                    elseif groupKey == "BLU Other Game Sounds" or groupKey == "Shared Media" then
                        -- Tier 2: Pack Name (e.g. 'Zelda' or 'SharedMedia_MyMedia') -> Tier 3: Sound
                        info.text = subKey .. " (" .. #sounds .. ")"
                        info.hasArrow = true
                        info.menuList = {group = groupKey, sub = subKey, type = "pack"}
                    end
    
                    UIDropDownMenu_AddButton(info, level)
                end
    
            -- === LEVEL 3: Individual Sounds ===
            elseif level == 3 then
                local groupKey = menuList.group
                local subKey = menuList.sub
                local listType = menuList.type
                local soundsToDisplay
    
                if groupKey == "BLU WoW Defaults" then
                    soundsToDisplay = customHierarchy[groupKey][subKey]
                elseif groupKey == "BLU Other Game Sounds" or groupKey == "Shared Media" then
                    soundsToDisplay = customHierarchy[groupKey][subKey]
                end
    
                -- Sort final sounds by name
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
        end)
    -- Set initial text
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

-- Create event sound panel for each tab
function BLU.CreateEventSoundPanel(panel, eventType, eventName)
    -- Create scrollable content with proper sizing aligned to content frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 5)
    
    -- Add scroll frame background for better visibility
    local scrollBg = scrollFrame:CreateTexture(nil, "BACKGROUND")
    scrollBg:SetAllPoints()
    scrollBg:SetColorTexture(0.05, 0.05, 0.05, 0.3)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(680)  -- Fixed width to fill available space
    scrollFrame:SetScrollChild(content)
    
    -- Event header
    local header = CreateFrame("Frame", nil, content)
    header:SetHeight(45)
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("RIGHT", 0, 0)
    
    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("LEFT", 0, 0)
    -- Set appropriate icon based on event type
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
    
    -- Module enable/disable section with better styling
    local moduleSection = BLU.Design:CreateSection(content, "Module Control", "Interface\Icons\INV_Misc_Gear_08")
    moduleSection:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -10)
    moduleSection:SetPoint("RIGHT", -10, 0)
    moduleSection:SetHeight(140)
    
    -- Enable toggle with description
    local toggleFrame = CreateFrame("Frame", nil, moduleSection.content)
    toggleFrame:SetPoint("TOPLEFT", BLU.Design.Layout.Spacing, -BLU.Design.Layout.Spacing)
    toggleFrame:SetSize(500, 60)
    
    -- Toggle switch (styled like the modules panel)
    local switchFrame = CreateFrame("Frame", nil, toggleFrame)
    switchFrame:SetSize(60, 24)
    switchFrame:SetPoint("LEFT", 0, 0)
    
    -- Switch background
    local switchBg = switchFrame:CreateTexture(nil, "BACKGROUND")
    switchBg:SetAllPoints()
    switchBg:SetTexture("Interface\Buttons\WHITE8x8")
    
    -- Switch toggle
    local toggle = CreateFrame("Button", nil, switchFrame)
    toggle:SetSize(28, 28)
    toggle:EnableMouse(true)
    
    local toggleBg = toggle:CreateTexture(nil, "ARTWORK")
    toggleBg:SetAllPoints()
    toggleBg:SetTexture("Interface\Buttons\WHITE8x8")
    toggleBg:SetVertexColor(1, 1, 1, 1)
    
    -- Module text
    local moduleText = toggleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    moduleText:SetPoint("LEFT", switchFrame, "RIGHT", 15, 5)
    moduleText:SetText("Enable " .. eventName .. " Module")
    
    local moduleDesc = toggleFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    moduleDesc:SetPoint("TOPLEFT", moduleText, "BOTTOMLEFT", 0, -3)
    moduleDesc:SetText("When enabled, BLU will respond to " .. eventName:lower() .. " events and play custom sounds")
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
        enabled = BLU.db.profile.modules[eventType] ~= false
    end
    UpdateToggleState(enabled)
    
    -- Click handler with module loading/unloading
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
        
        -- Load/unload module
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
    
    -- Sound selection section
    local soundSection = BLU.Design:CreateSection(content, "Sound Selection", "Interface\Icons\INV_Misc_Bell_01")
    soundSection:SetPoint("TOPLEFT", moduleSection, "BOTTOMLEFT", 0, -10)
    soundSection:SetPoint("RIGHT", -20, 0)
    
    -- Adjust height based on event type (Quest needs more space for 2 dropdowns)
    local sectionHeight = (eventType == "quest") and 260 or 150
    soundSection:SetHeight(sectionHeight)
    
    -- Create sound dropdowns based on event type
    if eventType == "quest" then
        -- Quest has two separate sounds: complete and progress
        CreateSoundDropdown(soundSection.content, "quest", "Quest Complete Sound", -5, "quest_complete")
        CreateSoundDropdown(soundSection.content, "quest", "Quest Progress Sound", -95, "quest_progress")
    else
        -- All other events have a single sound
        CreateSoundDropdown(soundSection.content, eventType, eventName .. " Sound", -5)
    end
    
    -- Set content height based on event type
    local contentHeight = (eventType == "quest") and 450 or 400
    content:SetHeight(contentHeight)
end

-- Cleanup module
function Options:Init()
    BLU:PrintDebug("Options:Init() called, registering OpenOptions.")
    BLU:PrintDebug("[Options] Initializing new options module")

    -- Create panel directly on init
    if not BLU.OptionsPanel then
        self:CreateOptionsPanel()
    end

    -- Make functions available globally
    BLU.CreateOptionsPanel = function()
        return self:CreateOptionsPanel()
    end
    
    BLU.OpenOptions = function()
        return self:OpenOptions()
    end
    
    -- Test SharedMedia availability
    BLU.TestSharedMedia = function()
        return self:TestSharedMedia()
    end

    BLU.RefreshSoundLists = function()
        return self:RefreshSoundLists()
    end
    
    BLU:PrintDebug("[Options] Functions registered")
end

function Options:Cleanup()
    -- Nothing to cleanup
end

function Options:RefreshSoundLists()
    if BLU.OptionsPanel and BLU.OptionsPanel.soundsContent and BLU.OptionsPanel:IsVisible() then
        BLU.CreateSoundsPanel(BLU.OptionsPanel.soundsContent)
    end
end

-- Register module
if BLU.RegisterModule then
    BLU:RegisterModule(Options, "options", "Options Interface")
end
