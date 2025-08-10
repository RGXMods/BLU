--=====================================================================================
-- BLU - interface/options_new.lua
-- New options panel with SimpleQuestPlates-inspired design
--=====================================================================================

local addonName, BLU = ...

-- Create options module
local Options = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["options"] = Options

-- Panel dimensions
local PANEL_WIDTH = 700
local PANEL_HEIGHT = 600

-- Initialize options module
function Options:Init()
    BLU:PrintDebug("[Options] Initializing new options module")
    
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
    
    BLU:PrintDebug("[Options] Functions registered")
    
    -- Create the panel after database is initialized
    local function tryCreatePanel()
        if BLU.db and BLU.db.profile then
            if not BLU.OptionsPanel then
                self:CreateOptionsPanel()
            end
        else
            -- Database not ready yet, try again in 0.2 seconds
            C_Timer.After(0.2, tryCreatePanel)
        end
    end
    
    C_Timer.After(0.1, tryCreatePanel)
end

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
    button:SetSize(BLU.Design.Layout.TabWidth, BLU.Design.Layout.TabHeight)
    
    -- Position based on row and column with proper spacing from design constants
    local xOffset = 8 + (col - 1) * (BLU.Design.Layout.TabWidth + BLU.Design.Layout.TabSpacing)
    local yOffset = -5 - (row - 1) * BLU.Design.Layout.TabRowHeight
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
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    button.border = border
    
    -- Text (no icons)
    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    buttonText:SetPoint("CENTER", 0, 0)
    buttonText:SetText(text)
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
    container:SetPoint("TOPLEFT", 10, -10)
    container:SetPoint("BOTTOMRIGHT", -10, 10)
    container:SetBackdrop(BLU.Design.Backdrops.Dark)
    container:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    container:SetBackdropBorderColor(unpack(BLU.Design.Colors.Primary))
    
    -- Create header
    local header = CreateFrame("Frame", nil, container, "BackdropTemplate")
    header:SetHeight(70)  -- Reduced header height
    header:SetPoint("TOPLEFT", 10, -10)
    header:SetPoint("TOPRIGHT", -10, -10)
    header:SetBackdrop(BLU.Design.Backdrops.Dark)
    header:SetBackdropColor(0.08, 0.08, 0.08, 0.8)
    header:SetBackdropBorderColor(unpack(BLU.Design.Colors.Primary))
    
    -- Logo/Icon
    local logo = header:CreateTexture(nil, "ARTWORK")
    logo:SetSize(48, 48)
    logo:SetPoint("LEFT", 15, 0)
    logo:SetTexture("Interface\\AddOns\\BLU\\media\\images\\icon")
    
    -- Title (with colored letters like SQP)
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("LEFT", logo, "RIGHT", 15, 10)
    title:SetText("|cff05dffaB|r|cffffffffLU|r - |cff05dffaB|r|cffffffffetter|r |cff05dffaL|r|cffffffffevel-|r|cff05dffaU|r|cffffffffp!|r")
    
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
    tabContainer:SetHeight(60)  -- 2 rows * 27 height + spacing
    tabContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -10)
    tabContainer:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -10)
    
    -- Add background for tab container
    local tabBg = tabContainer:CreateTexture(nil, "BACKGROUND")
    tabBg:SetAllPoints()
    tabBg:SetColorTexture(0.03, 0.03, 0.03, 0.6)
    
    -- Create tabs for each sound event type (no icons)
    local tabs = {
        -- Row 1
        {text = "General", create = BLU.CreateGeneralPanel, row = 1, col = 1},
        {text = "Level Up", eventType = "levelup", row = 1, col = 2},
        {text = "Achievement", eventType = "achievement", row = 1, col = 3},
        {text = "Quest", eventType = "quest", row = 1, col = 4},
        {text = "Reputation", eventType = "reputation", row = 1, col = 5},
        {text = "Battle Pets", eventType = "battlepet", row = 1, col = 6},
        -- Row 2
        {text = "Honor", eventType = "honorrank", row = 2, col = 1},
        {text = "Renown", eventType = "renownrank", row = 2, col = 2},
        {text = "Trading Post", eventType = "tradingpost", row = 2, col = 3},
        {text = "Delve", eventType = "delvecompanion", row = 2, col = 4},
        {text = "About", create = BLU.CreateAboutPanel, row = 2, col = 5}
    }
    
    panel.tabs = {}
    panel.contents = {}
    
    for i, tabInfo in ipairs(tabs) do
        local tab = CreateTabButton(tabContainer, tabInfo.text, i, tabInfo.row, tabInfo.col, panel)
        panel.tabs[i] = tab
        
        -- Create content frame with proper positioning using design constants
        local content = CreateFrame("Frame", nil, container, "BackdropTemplate")
        content:SetPoint("TOPLEFT", tabContainer, "BOTTOMLEFT", BLU.Design.Layout.Padding, -BLU.Design.Layout.Spacing)
        content:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -BLU.Design.Layout.Padding, BLU.Design.Layout.Spacing)
        content:SetBackdrop(BLU.Design.Backdrops.Dark)
        content:SetBackdropColor(0.08, 0.08, 0.08, 0.9)
        content:SetBackdropBorderColor(0.15, 0.15, 0.15, 1)
        content:Hide()
        
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
    -- soundType is used for events that have multiple sounds (like quest_complete and quest_progress)
    local actualEventType = soundType or eventType
    
    -- Container frame
    local container = CreateFrame("Frame", nil, parent)
    container:SetPoint("TOPLEFT", BLU.Design.Layout.Spacing, yOffset)
    container:SetPoint("RIGHT", -BLU.Design.Layout.Spacing, 0)
    container:SetHeight(120)
    
    -- Current sound display
    local currentLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentLabel:SetPoint("TOPLEFT", 0, 0)
    currentLabel:SetText(label .. " - Current:")
    
    local currentSound = container:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    currentSound:SetPoint("LEFT", currentLabel, "RIGHT", BLU.Design.Layout.Spacing, 0)
    
    -- Test button
    local testBtn = BLU.Design:CreateButton(container, "Test", 80, 25)
    testBtn:SetPoint("LEFT", currentSound, "RIGHT", BLU.Design.Layout.Padding, 0)
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
    
    -- Sound dropdown
    local dropdownContainer = BLU.Design:CreateDropdown(container, "Select " .. label .. ":", 280)
    dropdownContainer:SetPoint("TOPLEFT", currentLabel, "BOTTOMLEFT", 0, -(BLU.Design.Layout.Spacing + 10))
    local dropdown = dropdownContainer.dropdown
    
    -- Store references
    dropdown.currentSound = currentSound
    dropdown.eventId = actualEventType
    
    -- Initialize dropdown
    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        level = level or 1
        
        if not BLU.db or not BLU.db.profile then
            return
        end
        BLU.db.profile.selectedSounds = BLU.db.profile.selectedSounds or {}
        
        if level == 1 then
            -- Default option
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
            
            -- WoW's built-in sounds
            info = UIDropDownMenu_CreateInfo()
            info.text = "|cffffff00WoW Game Sounds|r"
            info.value = "wow_sounds"
            info.hasArrow = true
            info.menuList = "wow_sounds"
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- BLU built-in sounds
            info = UIDropDownMenu_CreateInfo()
            info.text = "|cff05dffaBLU Sound Packs|r"
            info.value = "blu_builtin"
            info.hasArrow = true
            info.menuList = "blu_builtin"
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- External sounds by category
            if BLU.Modules.sharedmedia and BLU.Modules.sharedmedia.GetSoundCategories then
                local success, categories = pcall(function() return BLU.Modules.sharedmedia:GetSoundCategories() end)
                if success and categories and type(categories) == "table" then
                    for category, sounds in pairs(categories) do
                        if sounds and type(sounds) == "table" and #sounds > 0 then
                            info = UIDropDownMenu_CreateInfo()
                            info.text = category .. " (" .. #sounds .. ")"
                            info.value = category
                            info.hasArrow = true
                            info.menuList = category
                            info.notCheckable = true
                            UIDropDownMenu_AddButton(info, level)
                        end
                    end
                end
            end
        elseif level == 2 then
            if menuList == "blu_builtin" then
                -- BLU's built-in sounds
                local builtinSounds = {
                    {value = "finalfantasy_" .. dropdown.eventId, text = "Final Fantasy"},
                    {value = "zelda_" .. dropdown.eventId, text = "Legend of Zelda"},
                    {value = "pokemon_" .. dropdown.eventId, text = "Pokemon"},
                    {value = "mario_" .. dropdown.eventId, text = "Super Mario"},
                    {value = "sonic_" .. dropdown.eventId, text = "Sonic the Hedgehog"},
                    {value = "metalgear_" .. dropdown.eventId, text = "Metal Gear Solid"},
                    {value = "elderscrolls_" .. dropdown.eventId, text = "Elder Scrolls"},
                    {value = "warcraft_" .. dropdown.eventId, text = "Warcraft"},
                    {value = "eldenring_" .. dropdown.eventId, text = "Elden Ring"},
                    {value = "castlevania_" .. dropdown.eventId, text = "Castlevania"},
                    {value = "diablo_" .. dropdown.eventId, text = "Diablo"},
                    {value = "fallout_" .. dropdown.eventId, text = "Fallout"},
                    {value = "blu_default_" .. dropdown.eventId, text = "BLU Defaults"}
                }
                
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
                -- WoW's built-in sounds for this event type
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
                -- External sounds from SharedMedia categories
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
    
    -- Set initial text
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
            -- BLU internal sound
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

-- Create event sound panel for each tab
function BLU.CreateEventSoundPanel(panel, eventType, eventName)
    -- Create scrollable content with proper sizing aligned to content frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", BLU.Design.Layout.Padding/2, -BLU.Design.Layout.Padding/2)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, BLU.Design.Layout.Padding/2)
    
    -- Add scroll frame background for better visibility
    local scrollBg = scrollFrame:CreateTexture(nil, "BACKGROUND")
    scrollBg:SetAllPoints()
    scrollBg:SetColorTexture(0.05, 0.05, 0.05, 0.3)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    -- Set size dynamically after frame is ready
    C_Timer.After(0.01, function()
        if scrollFrame:GetWidth() and scrollFrame:GetWidth() > 0 then
            content:SetSize(scrollFrame:GetWidth() - 25, 800) -- Increased height for all sections
        else
            content:SetSize(650, 800) -- Increased fallback size
        end
    end)
    scrollFrame:SetScrollChild(content)
    
    -- Event header
    local header = CreateFrame("Frame", nil, content)
    header:SetHeight(50)
    header:SetPoint("TOPLEFT", BLU.Design.Layout.Padding, -BLU.Design.Layout.Padding)
    header:SetPoint("RIGHT", -BLU.Design.Layout.Padding, 0)
    
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
    title:SetText("|cff05dffa" .. eventName .. " Sounds|r")
    
    -- Module enable/disable section with better styling
    local moduleSection = BLU.Design:CreateSection(content, "Module Control", "Interface\\Icons\\INV_Misc_Gear_08")
    moduleSection:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -BLU.Design.Layout.Spacing)
    moduleSection:SetPoint("RIGHT", -BLU.Design.Layout.Padding, 0)
    moduleSection:SetHeight(120) -- Increased height for better spacing
    
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
    switchBg:SetTexture("Interface\\Buttons\\WHITE8x8")
    
    -- Switch toggle
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
    local soundSection = BLU.Design:CreateSection(content, "Sound Selection", "Interface\\Icons\\INV_Misc_Bell_01")
    soundSection:SetPoint("TOPLEFT", moduleSection, "BOTTOMLEFT", 0, -BLU.Design.Layout.Spacing)
    soundSection:SetPoint("RIGHT", -BLU.Design.Layout.Padding, 0)
    
    -- Adjust height based on event type (Quest needs more space for 2 dropdowns)
    local sectionHeight = (eventType == "quest") and 250 or 150
    soundSection:SetHeight(sectionHeight)
    
    -- Create sound dropdowns based on event type
    if eventType == "quest" then
        -- Quest has two separate sounds: complete and progress
        CreateSoundDropdown(soundSection.content, "quest", "Quest Complete Sound", -BLU.Design.Layout.Spacing, "quest_complete")
        CreateSoundDropdown(soundSection.content, "quest", "Quest Progress Sound", -130, "quest_progress")
    else
        -- All other events have a single sound
        CreateSoundDropdown(soundSection.content, eventType, eventName .. " Sound", -BLU.Design.Layout.Spacing)
    end
    
    -- Set content height
    content:SetHeight(600)
end

-- Old function removed and replaced with helper above
--[[
    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        level = level or 1
        
        -- Debug SharedMedia state
        if level == 1 then
            BLU:PrintDebug(string.format("[Options] Initializing dropdown for %s", eventType))
            BLU:PrintDebug(string.format("[Options] SharedMedia module exists: %s", tostring(BLU.Modules.sharedmedia ~= nil)))
            if BLU.Modules.sharedmedia then
                BLU:PrintDebug(string.format("[Options] GetSoundCategories function exists: %s", 
                    tostring(BLU.Modules.sharedmedia.GetSoundCategories ~= nil)))
                if BLU.Modules.sharedmedia.GetSoundCategories then
                    local categories = BLU.Modules.sharedmedia:GetSoundCategories()
                    BLU:PrintDebug(string.format("[Options] Categories type: %s", type(categories)))
                    if type(categories) == "table" then
                        local count = 0
                        for k, v in pairs(categories) do
                            count = count + 1
                            BLU:PrintDebug(string.format("[Options] Category '%s' has %d sounds", k, v and #v or 0))
                        end
                        BLU:PrintDebug(string.format("[Options] Total categories: %d", count))
                    end
                end
            end
        end
        
        -- Ensure database exists
        if not BLU.db or not BLU.db.profile then
            return
        end
        BLU.db.profile.selectedSounds = BLU.db.profile.selectedSounds or {}
        
        if level == 1 then
            -- Default option
            local info = UIDropDownMenu_CreateInfo()
            info.text = "Default WoW Sound"
            info.value = "default"
            info.func = function()
                BLU.db.profile.selectedSounds[self.eventId] = "default"
                UIDropDownMenu_SetText(self, "Default WoW Sound")
                self.currentSound:SetText("Default WoW Sound")
                CloseDropDownMenus()
                if dropdown.UpdateVolumeVisibility then
                    dropdown.UpdateVolumeVisibility()
                end
            end
            info.checked = BLU.db.profile.selectedSounds[self.eventId] == "default"
            UIDropDownMenu_AddButton(info, level)
            
            -- WoW's built-in sounds
            info = UIDropDownMenu_CreateInfo()
            info.text = "|cffffff00WoW Game Sounds|r"
            info.value = "wow_sounds"
            info.hasArrow = true
            info.menuList = "wow_sounds"
            UIDropDownMenu_AddButton(info, level)
            
            -- BLU built-in sounds
            info = UIDropDownMenu_CreateInfo()
            info.text = "|cff05dffaBLU Sound Packs|r"
            info.value = "blu_builtin"
            info.hasArrow = true
            info.menuList = "blu_builtin"
            UIDropDownMenu_AddButton(info, level)
            
            -- External sounds by category
            if BLU.Modules.sharedmedia and BLU.Modules.sharedmedia.GetSoundCategories then
                local success, categories = pcall(function() return BLU.Modules.sharedmedia:GetSoundCategories() end)
                if success and categories and type(categories) == "table" then
                    local categoryCount = 0
                    for category, sounds in pairs(categories) do
                        if sounds and type(sounds) == "table" and #sounds > 0 then
                            categoryCount = categoryCount + 1
                            info = UIDropDownMenu_CreateInfo()
                            info.text = category .. " (" .. #sounds .. ")"
                            info.value = category
                            info.hasArrow = true
                            info.menuList = category
                            UIDropDownMenu_AddButton(info, level)
                        end
                    end
                    if categoryCount == 0 then
                        BLU:PrintDebug("[Options] SharedMedia has no valid sound categories")
                    end
                else
                    BLU:PrintDebug("[Options] SharedMedia GetSoundCategories failed or returned invalid data")
                end
            else
                BLU:PrintDebug("[Options] SharedMedia module not available or missing GetSoundCategories function")
            end
        elseif level == 2 then
            if menuList == "blu_builtin" then
                -- BLU's built-in sounds
                local builtinSounds = {
                    {value = "finalfantasy_" .. dropdown.eventId, text = "Final Fantasy"},
                    {value = "zelda_" .. dropdown.eventId, text = "Legend of Zelda"},
                    {value = "pokemon_" .. dropdown.eventId, text = "Pokemon"},
                    {value = "mario_" .. dropdown.eventId, text = "Super Mario"},
                    {value = "sonic_" .. dropdown.eventId, text = "Sonic the Hedgehog"},
                    {value = "metalgear_" .. dropdown.eventId, text = "Metal Gear Solid"},
                    {value = "elderscrolls_" .. dropdown.eventId, text = "Elder Scrolls"},
                    {value = "warcraft_" .. dropdown.eventId, text = "Warcraft"},
                    {value = "eldenring_" .. dropdown.eventId, text = "Elden Ring"},
                    {value = "castlevania_" .. dropdown.eventId, text = "Castlevania"},
                    {value = "diablo_" .. dropdown.eventId, text = "Diablo"},
                    {value = "fallout_" .. dropdown.eventId, text = "Fallout"},
                    {value = "blu_default_" .. dropdown.eventId, text = "BLU Defaults"}
                }
                
                for _, sound in ipairs(builtinSounds) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = sound.text
                    info.value = sound.value
                    info.func = function()
                        BLU.db.profile.selectedSounds[dropdown.eventId] = sound.value
                        UIDropDownMenu_SetText(dropdown, sound.text)
                        dropdown.currentSound:SetText(sound.text)
                        CloseDropDownMenus()
                        if dropdown.UpdateVolumeVisibility then
                            dropdown.UpdateVolumeVisibility()
                        end
                    end
                    info.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == sound.value
                    UIDropDownMenu_AddButton(info, level)
                end
            elseif menuList == "wow_sounds" then
                -- WoW's built-in sounds for this event type
                local wowSounds = {
                    levelup = {
                        {value = "wowsounds_levelup_fanfare", text = "Level Up Fanfare"},
                        {value = "wowsounds_levelup_ding", text = "Level Ding"},
                        {value = "wowsounds_levelup_gong", text = "Gong"},
                        {value = "wowsounds_levelup_epic", text = "Epic Victory"},
                        {value = "wowsounds_levelup_power", text = "Power Up"},
                        {value = "wowsounds_classic_ding", text = "Classic Level Ding"}
                    },
                    achievement = {
                        {value = "wowsounds_achievement_default", text = "Achievement Earned"},
                        {value = "wowsounds_achievement_guild", text = "Guild Achievement"},
                        {value = "wowsounds_achievement_criteria", text = "Achievement Progress"},
                        {value = "wowsounds_achievement_legendary", text = "Legendary Alert"},
                        {value = "wowsounds_achievement_epic", text = "Epic Loot"},
                        {value = "wowsounds_achievement_rare", text = "Rare Item"},
                        {value = "wowsounds_ready_check", text = "Ready Check"},
                        {value = "wowsounds_raid_warning", text = "Raid Warning"}
                    },
                    quest = {
                        {value = "wowsounds_quest_complete", text = "Quest Complete"},
                        {value = "wowsounds_quest_objective", text = "Quest Objective"},
                        {value = "wowsounds_quest_turnin", text = "Quest Turn In"},
                        {value = "wowsounds_quest_special", text = "Special Quest Complete"},
                        {value = "wowsounds_quest_world", text = "World Quest Complete"},
                        {value = "wowsounds_quest_bonus", text = "Bonus Objective"},
                        {value = "wowsounds_quest_daily", text = "Daily Quest Complete"},
                        {value = "wowsounds_garrison_complete", text = "Garrison Mission Complete"},
                        {value = "wowsounds_island_complete", text = "Island Expedition Complete"},
                        {value = "wowsounds_warfront_complete", text = "Warfront Complete"},
                        {value = "wowsounds_classic_complete", text = "Classic Quest Complete"}
                    },
                    reputation = {
                        {value = "wowsounds_reputation_levelup", text = "Reputation Level Up"},
                        {value = "wowsounds_reputation_paragon", text = "Paragon Reputation"}
                    },
                    honorrank = {
                        {value = "wowsounds_honor_rankup", text = "Honor Rank Up"},
                        {value = "wowsounds_honor_prestige", text = "Prestige Level Up"},
                        {value = "wowsounds_honor_battleground", text = "Battleground Victory"},
                        {value = "wowsounds_honor_arena", text = "Arena Victory"},
                        {value = "wowsounds_honor_rbg", text = "RBG Victory"}
                    },
                    renownrank = {
                        {value = "wowsounds_renown_levelup", text = "Renown Level Up"},
                        {value = "wowsounds_renown_milestone", text = "Renown Milestone"}
                    },
                    tradingpost = {
                        {value = "wowsounds_tradingpost_complete", text = "Trading Post Complete"},
                        {value = "wowsounds_tradingpost_progress", text = "Trading Post Progress"},
                        {value = "wowsounds_tradingpost_unlock", text = "Trading Post Unlock"},
                        {value = "wowsounds_tradingpost_purchase", text = "Trading Post Purchase"}
                    },
                    battlepet = {
                        {value = "wowsounds_battlepet_victory", text = "Pet Battle Victory"},
                        {value = "wowsounds_battlepet_capture", text = "Pet Captured"},
                        {value = "wowsounds_battlepet_levelup", text = "Battle Pet Level Up"},
                        {value = "wowsounds_battlepet_rare", text = "Rare Pet Captured"},
                        {value = "wowsounds_battlepet_achievement", text = "Pet Achievement"}
                    },
                    delvecompanion = {
                        {value = "wowsounds_delve_complete", text = "Delve Complete"},
                        {value = "wowsounds_delve_bonus", text = "Bonus Objective Complete"}
                    }
                }
                
                local eventSounds = wowSounds[dropdown.eventId] or {}
                for _, sound in ipairs(eventSounds) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = sound.text
                    info.value = sound.value
                    info.func = function()
                        BLU.db.profile.selectedSounds[dropdown.eventId] = sound.value
                        UIDropDownMenu_SetText(dropdown, sound.text)
                        dropdown.currentSound:SetText(sound.text)
                        CloseDropDownMenus()
                        if dropdown.UpdateVolumeVisibility then
                            dropdown.UpdateVolumeVisibility()
                        end
                    end
                    info.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == sound.value
                    UIDropDownMenu_AddButton(info, level)
                end
            else
                -- External sounds from category
                if BLU.Modules.sharedmedia and BLU.Modules.sharedmedia.GetSoundCategories then
                    local categories = BLU.Modules.sharedmedia:GetSoundCategories()
                    local sounds = categories and categories[menuList]
                    if sounds and type(sounds) == "table" then
                        for _, soundName in ipairs(sounds) do
                            local info = UIDropDownMenu_CreateInfo()
                            info.text = soundName
                            info.value = "external:" .. soundName
                            info.func = function()
                                BLU.db.profile.selectedSounds[dropdown.eventId] = "external:" .. soundName
                                UIDropDownMenu_SetText(dropdown, soundName .. " (External)")
                                dropdown.currentSound:SetText(soundName .. " (External)")
                                CloseDropDownMenus()
                                if dropdown.UpdateVolumeVisibility then
                                    dropdown.UpdateVolumeVisibility()
                                end
                            end
                            info.checked = BLU.db.profile.selectedSounds[dropdown.eventId] == "external:" .. soundName
                            UIDropDownMenu_AddButton(info, level)
                        end
                    else
                        BLU:PrintDebug("[Options] No sounds found for category: " .. (menuList or "unknown"))
                    end
                else
                    BLU:PrintDebug("[Options] SharedMedia module not available for external sounds")
                end
            end
        end
    end)
    
    -- Set current value (delayed to ensure everything is loaded)
    C_Timer.After(0.1, function()
        local currentValue = "default"
        if BLU.db and BLU.db.profile and BLU.db.profile.selectedSounds then
            currentValue = BLU.db.profile.selectedSounds[eventType] or "default"
        end
        if currentValue == "default" then
            UIDropDownMenu_SetText(dropdown, "Default WoW Sound")
            currentSound:SetText("Default WoW Sound")
        elseif currentValue:match("^external:") then
            local soundName = currentValue:gsub("^external:", "")
            UIDropDownMenu_SetText(dropdown, soundName .. " (External)")
            currentSound:SetText(soundName .. " (External)")
        elseif currentValue:match("^wowsounds_") then
            -- Find the text for WoW sounds
            local wowSounds = {
                levelup = {
                    {value = "wowsounds_levelup_fanfare", text = "Level Up Fanfare"},
                    {value = "wowsounds_levelup_ding", text = "Level Ding"},
                    {value = "wowsounds_levelup_gong", text = "Gong"},
                    {value = "wowsounds_levelup_epic", text = "Epic Victory"},
                    {value = "wowsounds_levelup_power", text = "Power Up"},
                    {value = "wowsounds_classic_ding", text = "Classic Level Ding"}
                },
                achievement = {
                    {value = "wowsounds_achievement_default", text = "Achievement Earned"},
                    {value = "wowsounds_achievement_guild", text = "Guild Achievement"},
                    {value = "wowsounds_achievement_criteria", text = "Achievement Progress"},
                    {value = "wowsounds_achievement_legendary", text = "Legendary Alert"},
                    {value = "wowsounds_achievement_epic", text = "Epic Loot"},
                    {value = "wowsounds_achievement_rare", text = "Rare Item"},
                    {value = "wowsounds_ready_check", text = "Ready Check"},
                    {value = "wowsounds_raid_warning", text = "Raid Warning"}
                }
            }
            local eventSounds = wowSounds[eventType] or {}
            for _, sound in ipairs(eventSounds) do
                if sound.value == currentValue then
                    UIDropDownMenu_SetText(dropdown, sound.text)
                    currentSound:SetText(sound.text)
                    break
                end
            end
        else
            -- BLU internal sounds - extract pack name
            local packName = currentValue:match("^(.+)_" .. eventType .. "$")
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
            else
                UIDropDownMenu_SetText(dropdown, currentValue)
                currentSound:SetText(currentValue)
            end
        end
    end)
--]]

-- Volume control section removed since it's now handled in individual dropdowns
--[[
    volumeContainer:SetHeight(90)
    volumeContainer:Hide() -- Hidden by default
    
    -- Volume label
    local volumeLabel = volumeContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    volumeLabel:SetPoint("TOPLEFT", BLU.Design.Layout.Spacing, -BLU.Design.Layout.Spacing)
    volumeLabel:SetText("BLU Volume:")
    
    -- Volume percentage display
    local volumePercent = volumeContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    volumePercent:SetPoint("LEFT", volumeLabel, "RIGHT", BLU.Design.Layout.Spacing, 0)
    
    -- Volume slider
    local volumeSlider = CreateFrame("Slider", nil, volumeContainer, "OptionsSliderTemplate")
    volumeSlider:SetPoint("TOPLEFT", volumeLabel, "BOTTOMLEFT", 0, -BLU.Design.Layout.Spacing)
    volumeSlider:SetSize(250, 20)
    volumeSlider:SetMinMaxValues(0, 100)
    volumeSlider:SetValueStep(1)
    volumeSlider:SetObeyStepOnDrag(true)
    
    -- Style the slider
    local sliderBg = volumeSlider:CreateTexture(nil, "BACKGROUND")
    sliderBg:SetAllPoints()
    sliderBg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    
    -- Update volume display function
    local function UpdateVolumeDisplay()
        local volume = BLU.db and BLU.db.profile and BLU.db.profile.soundVolume or 50
        volumeSlider:SetValue(volume)
        volumePercent:SetText(volume .. "%")
    end
    
    -- Volume slider change handler
    volumeSlider:SetScript("OnValueChanged", function(self, value)
        if not BLU.db or not BLU.db.profile then return end
        
        local roundedValue = math.floor(value + 0.5)
        BLU.db.profile.soundVolume = roundedValue
        volumePercent:SetText(roundedValue .. "%")
    end)
    
    -- Function to check if current sound is a BLU internal sound
    local function IsBLUInternalSound(soundValue)
        if not soundValue or soundValue == "default" then return false end
        if soundValue:match("^external:") then return false end
        if soundValue:match("^wowsounds_") then return false end
        
        -- Check for BLU internal sound patterns
        local bluPrefixes = {
            "finalfantasy_", "zelda_", "pokemon_", "mario_", "sonic_", 
            "metalgear_", "elderscrolls_", "warcraft_", "eldenring_", 
            "castlevania_", "diablo_", "fallout_", "blu_default_"
        }
        
        for _, prefix in ipairs(bluPrefixes) do
            if soundValue:match("^" .. prefix) then
                return true
            end
        end
        
        return false
    end
    
    -- Function to update volume control visibility
    local function UpdateVolumeVisibility()
        local currentValue = "default"
        if BLU.db and BLU.db.profile and BLU.db.profile.selectedSounds then
            currentValue = BLU.db.profile.selectedSounds[eventType] or "default"
        end
        
        if IsBLUInternalSound(currentValue) then
            volumeContainer:Show()
            UpdateVolumeDisplay()
            -- Adjust sound section height
            soundSection:SetHeight(580) -- Increased to show volume control
        else
            volumeContainer:Hide()
            -- Reset sound section height
            soundSection:SetHeight(500)
        end
    end
    
    -- Store references for dropdown callback
    dropdown.volumeContainer = volumeContainer
    dropdown.UpdateVolumeVisibility = UpdateVolumeVisibility
    
    -- Initial volume visibility check
    C_Timer.After(0.1, UpdateVolumeVisibility)
    
    -- Info text
    local infoText = soundSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    infoText:SetPoint("TOPLEFT", volumeContainer, "BOTTOMLEFT", BLU.Design.Layout.Spacing, -(BLU.Design.Layout.Spacing + 5))
    infoText:SetPoint("RIGHT", -BLU.Design.Layout.Padding, 0)
    infoText:SetText("|cff888888Note: BLU internal sounds respect the volume slider. External and default sounds use game audio settings.|r")
    infoText:SetJustifyH("LEFT")
    
--]]

-- Cleanup module
function Options:Cleanup()
    -- Nothing to cleanup
end

-- Register module
if BLU.RegisterModule then
    BLU:RegisterModule(Options, "options", "Options Interface")
end

-- Note: CreateRGXModsPanel function removed - RGX Mods tab no longer exists