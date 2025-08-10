--=====================================================================================
-- BLU - Simplified Options Panel with Proper Alignment
--=====================================================================================

local addonName, BLU = ...

-- Create options module
local Options = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["options"] = Options

-- Initialize
function Options:Init()
    BLU:PrintDebug("[Options] Initializing simplified options module")
    
    BLU.CreateOptionsPanel = function()
        return self:CreateOptionsPanel()
    end
    
    BLU.OpenOptions = function()
        return self:OpenOptions()
    end
    
    -- Create panel after database is ready
    C_Timer.After(0.5, function()
        if BLU.db and BLU.db.profile then
            if not BLU.OptionsPanel then
                self:CreateOptionsPanel()
            end
        end
    end)
end

-- Simple tab button creation
local function CreateTabButton(parent, text, x, y)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(120, 22)
    button:SetPoint("TOPLEFT", x, y)
    button:SetText(text)
    return button
end

-- Create main options panel
function Options:CreateOptionsPanel()
    BLU:PrintDebug("Creating simplified options panel...")
    
    -- Main frame
    local panel = CreateFrame("Frame", "BLUOptionsPanel", UIParent)
    panel.name = "Better Level-Up!"
    
    panel.OnCommit = function() end
    panel.OnDefault = function() end
    panel.OnRefresh = function() end
    
    BLU.OptionsPanel = panel
    
    -- Title
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("BLU - Better Level-Up!")
    
    -- Subtitle
    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Version " .. (BLU.version or "6.0.0-alpha") .. " | by donniedice | RGX Mods")
    
    -- Tab frame
    local tabFrame = CreateFrame("Frame", nil, panel)
    tabFrame:SetPoint("TOPLEFT", 16, -60)
    tabFrame:SetPoint("TOPRIGHT", -16, -60)
    tabFrame:SetHeight(30)
    
    -- Content frame with border for visibility
    local contentFrame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    contentFrame:SetPoint("TOPLEFT", tabFrame, "BOTTOMLEFT", 0, -10)
    contentFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 16)
    contentFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    contentFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
    contentFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    -- Create tabs (simplified single row)
    local tabs = {
        {text = "General", func = function() self:ShowGeneralTab(contentFrame) end},
        {text = "Sounds", func = function() self:ShowSoundsTab(contentFrame) end},
        {text = "Modules", func = function() self:ShowModulesTab(contentFrame) end},
        {text = "Events", func = function() self:ShowEventsTab(contentFrame) end},
        {text = "About", func = function() self:ShowAboutTab(contentFrame) end},
    }
    
    panel.tabs = {}
    panel.contents = {}
    
    for i, tabInfo in ipairs(tabs) do
        local x = (i - 1) * 125
        local button = CreateTabButton(tabFrame, tabInfo.text, x, 0)
        
        button:SetScript("OnClick", function()
            -- Clear content
            for _, child in pairs({contentFrame:GetChildren()}) do
                child:Hide()
            end
            -- Show selected tab
            tabInfo.func()
            
            -- Update button states
            for _, btn in ipairs(panel.tabs) do
                btn:SetEnabled(true)
            end
            button:SetEnabled(false)
        end)
        
        panel.tabs[i] = button
    end
    
    -- Select first tab
    panel.tabs[1]:Click()
    
    -- Register panel
    local category
    if Settings and Settings.RegisterCanvasLayoutCategory then
        category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
        BLU.OptionsCategory = category
    else
        InterfaceOptions_AddCategory(panel)
        BLU.OptionsCategory = panel
    end
    
    BLU:Print("|cff00ccffBLU:|r Options panel registered")
    return panel
end

-- General Tab
function Options:ShowGeneralTab(parent)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -10, 10)
    frame:Show()
    
    local y = -10
    
    -- Enable checkbox
    local enableCheck = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
    enableCheck:SetPoint("TOPLEFT", 16, y)
    enableCheck.Text:SetText("Enable BLU")
    if BLU.db and BLU.db.profile then
        enableCheck:SetChecked(BLU.db.profile.enabled ~= false)
    end
    enableCheck:SetScript("OnClick", function(self)
        if BLU.db and BLU.db.profile then
            BLU.db.profile.enabled = self:GetChecked()
        end
    end)
    
    y = y - 30
    
    -- Volume slider
    local volumeLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    volumeLabel:SetPoint("TOPLEFT", 16, y)
    volumeLabel:SetText("Sound Volume:")
    
    y = y - 25
    
    local volumeSlider = CreateFrame("Slider", "BLUVolumeSlider", frame, "OptionsSliderTemplate")
    volumeSlider:SetPoint("TOPLEFT", 16, y)
    volumeSlider:SetSize(200, 20)
    volumeSlider:SetMinMaxValues(0, 100)
    volumeSlider:SetValueStep(5)
    volumeSlider.Low:SetText("0")
    volumeSlider.High:SetText("100")
    volumeSlider.Text:SetText("Volume")
    
    -- Add value display
    local volumeValue = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    volumeValue:SetPoint("LEFT", volumeSlider, "RIGHT", 10, 0)
    
    local currentVolume = 100
    if BLU.db and BLU.db.profile then
        currentVolume = BLU.db.profile.soundVolume or 100
    end
    volumeSlider:SetValue(currentVolume)
    volumeValue:SetText(currentVolume .. "%")
    
    volumeSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        volumeValue:SetText(value .. "%")
        if BLU.db and BLU.db.profile then
            BLU.db.profile.soundVolume = value
        end
    end)
    
    y = y - 50
    
    -- Sound channel dropdown
    local channelLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    channelLabel:SetPoint("TOPLEFT", 16, y)
    channelLabel:SetText("Sound Channel:")
    
    y = y - 25
    
    local channelDropdown = CreateFrame("Frame", "BLUChannelDropdown", frame, "UIDropDownMenuTemplate")
    channelDropdown:SetPoint("TOPLEFT", -4, y)  -- Adjusted for dropdown template offset
    UIDropDownMenu_SetWidth(channelDropdown, 180)
    UIDropDownMenu_SetText(channelDropdown, BLU.db and BLU.db.profile and BLU.db.profile.soundChannel or "Master")
    
    UIDropDownMenu_Initialize(channelDropdown, function(self)
        local channels = {"Master", "Sound", "Music", "Ambience", "Dialog"}
        for _, channel in ipairs(channels) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = channel
            info.value = channel
            info.func = function()
                if BLU.db and BLU.db.profile then
                    BLU.db.profile.soundChannel = channel
                end
                UIDropDownMenu_SetText(channelDropdown, channel)
                CloseDropDownMenus()
            end
            info.checked = BLU.db and BLU.db.profile and BLU.db.profile.soundChannel == channel
            UIDropDownMenu_AddButton(info)
        end
    end)
end

-- Sounds Tab
function Options:ShowSoundsTab(parent)
    local frame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -30, 10)
    frame:Show()
    
    local content = CreateFrame("Frame", nil, frame)
    -- Use fixed width to avoid sizing issues
    content:SetWidth(550)
    content:SetHeight(800)
    frame:SetScrollChild(content)
    
    local y = -10
    
    local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, y)
    title:SetText("Sound Pack Selection")
    
    y = y - 30
    
    -- Create dropdown for each event type
    local events = {
        {id = "levelup", name = "Level Up"},
        {id = "achievement", name = "Achievement"},
        {id = "quest", name = "Quest Complete"},
        {id = "reputation", name = "Reputation"},
    }
    
    for _, event in ipairs(events) do
        local label = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        label:SetPoint("TOPLEFT", 16, y)
        label:SetText(event.name .. " Sound:")
        
        y = y - 25
        
        local dropdown = CreateFrame("Frame", "BLUSound" .. event.id, content, "UIDropDownMenuTemplate")
        dropdown:SetPoint("TOPLEFT", -4, y)  -- Adjusted for dropdown template offset
        UIDropDownMenu_SetWidth(dropdown, 250)
        
        local currentSound = "Default"
        if BLU.db and BLU.db.profile and BLU.db.profile.selectedSounds then
            currentSound = BLU.db.profile.selectedSounds[event.id] or "Default"
        end
        UIDropDownMenu_SetText(dropdown, currentSound)
        
        UIDropDownMenu_Initialize(dropdown, function(self, level)
            level = level or 1
            
            if level == 1 then
                -- Default option
                local info = UIDropDownMenu_CreateInfo()
                info.text = "Default WoW Sound"
                info.value = "default"
                info.func = function()
                    if BLU.db and BLU.db.profile then
                        BLU.db.profile.selectedSounds = BLU.db.profile.selectedSounds or {}
                        BLU.db.profile.selectedSounds[event.id] = "default"
                    end
                    UIDropDownMenu_SetText(dropdown, "Default WoW Sound")
                    CloseDropDownMenus()
                end
                info.checked = currentSound == "default"
                UIDropDownMenu_AddButton(info, level)
                
                -- BLU Sounds submenu
                info = UIDropDownMenu_CreateInfo()
                info.text = "BLU Sound Packs"
                info.value = "blu"
                info.hasArrow = true
                info.notCheckable = true
                UIDropDownMenu_AddButton(info, level)
            elseif level == 2 then
                -- BLU sound packs
                local packs = {
                    "Final Fantasy",
                    "Legend of Zelda",
                    "Pokemon",
                    "Super Mario",
                    "Elder Scrolls",
                    "Warcraft"
                }
                
                for _, pack in ipairs(packs) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = pack
                    info.value = pack:lower():gsub(" ", "_")
                    info.func = function()
                        if BLU.db and BLU.db.profile then
                            BLU.db.profile.selectedSounds = BLU.db.profile.selectedSounds or {}
                            BLU.db.profile.selectedSounds[event.id] = info.value .. "_" .. event.id
                        end
                        UIDropDownMenu_SetText(dropdown, pack)
                        CloseDropDownMenus()
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end)
        
        -- Test button
        local testBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        testBtn:SetSize(60, 22)
        testBtn:SetPoint("TOPLEFT", 280, y + 2)  -- Fixed position instead of relative
        testBtn:SetText("Test")
        testBtn:SetScript("OnClick", function()
            if BLU.PlayCategorySound then
                BLU:PlayCategorySound(event.id)
            end
        end)
        
        y = y - 40
    end
end

-- Modules Tab
function Options:ShowModulesTab(parent)
    local frame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -30, 10)
    frame:Show()
    
    local content = CreateFrame("Frame", nil, frame)
    -- Use fixed width to avoid sizing issues
    content:SetWidth(550)
    content:SetHeight(600)
    frame:SetScrollChild(content)
    
    local y = -10
    
    local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, y)
    title:SetText("Module Management")
    
    y = y - 30
    
    local modules = {
        {id = "levelup", name = "Level Up", desc = "Play sounds when you gain a level"},
        {id = "achievement", name = "Achievements", desc = "Play sounds when you earn achievements"},
        {id = "quest", name = "Quest Complete", desc = "Play sounds when you complete quests"},
        {id = "reputation", name = "Reputation", desc = "Play sounds when you gain reputation"},
        {id = "battlepet", name = "Battle Pets", desc = "Play sounds for pet battles"},
        {id = "honor", name = "Honor Rank", desc = "Play sounds for honor ranks"},
        {id = "renown", name = "Renown", desc = "Play sounds for renown levels"},
    }
    
    for _, module in ipairs(modules) do
        local check = CreateFrame("CheckButton", nil, content, "InterfaceOptionsCheckButtonTemplate")
        check:SetPoint("TOPLEFT", 16, y)
        check.Text:SetText(module.name)
        
        if BLU.db and BLU.db.profile and BLU.db.profile.modules then
            check:SetChecked(BLU.db.profile.modules[module.id] ~= false)
        else
            check:SetChecked(true)
        end
        
        check:SetScript("OnClick", function(self)
            if BLU.db and BLU.db.profile then
                BLU.db.profile.modules = BLU.db.profile.modules or {}
                BLU.db.profile.modules[module.id] = self:GetChecked()
            end
        end)
        
        local desc = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        desc:SetPoint("TOPLEFT", check.Text, "BOTTOMLEFT", 0, -2)
        desc:SetText(module.desc)
        desc:SetTextColor(0.7, 0.7, 0.7)
        
        y = y - 40
    end
end

-- Events Tab (combines all event settings)
function Options:ShowEventsTab(parent)
    local frame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -30, 10)
    frame:Show()
    
    local content = CreateFrame("Frame", nil, frame)
    -- Use fixed width to avoid sizing issues
    content:SetWidth(550)
    content:SetHeight(400)
    frame:SetScrollChild(content)
    
    local y = -10
    
    local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, y)
    title:SetText("Event Settings")
    
    y = y - 30
    
    local info = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    info:SetPoint("TOPLEFT", 16, y)
    info:SetPoint("RIGHT", -16, 0)
    info:SetText("Configure sound settings for each event type. Use the Sounds tab to select which sound pack to use for each event.")
    info:SetJustifyH("LEFT")
    
    y = y - 50
    
    -- Quick test all button
    local testAllBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    testAllBtn:SetSize(120, 22)
    testAllBtn:SetPoint("TOPLEFT", 16, y)
    testAllBtn:SetText("Test All Sounds")
    testAllBtn:SetScript("OnClick", function()
        local events = {"levelup", "achievement", "quest", "reputation"}
        local index = 1
        local function playNext()
            if index <= #events then
                if BLU.PlayCategorySound then
                    BLU:PlayCategorySound(events[index])
                end
                index = index + 1
                C_Timer.After(2, playNext)
            end
        end
        playNext()
    end)
end

-- About Tab
function Options:ShowAboutTab(parent)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -10, 10)
    frame:Show()
    
    local y = -10
    
    -- Logo and title
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, y)
    title:SetText("|cff05dffaBLU - Better Level-Up!|r")
    
    y = y - 30
    
    local version = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    version:SetPoint("TOPLEFT", 16, y)
    version:SetText("Version: " .. (BLU.version or "6.0.0-alpha"))
    
    y = y - 25
    
    local author = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    author:SetPoint("TOPLEFT", 16, y)
    author:SetText("Author: donniedice")
    
    y = y - 25
    
    local brand = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    brand:SetPoint("TOPLEFT", 16, y)
    brand:SetText("RGX Mods - RealmGX Community Project")
    
    y = y - 40
    
    local desc = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", 16, y)
    desc:SetPoint("RIGHT", -16, 0)
    desc:SetText("BLU replaces the default level-up and achievement sounds with iconic audio from your favorite games. Choose from over 50 game soundtracks!")
    desc:SetJustifyH("LEFT")
    
    y = y - 60
    
    local features = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    features:SetPoint("TOPLEFT", 16, y)
    features:SetText("Features:")
    
    y = y - 20
    
    local featureList = {
        "• Sound packs from 50+ classic games",
        "• Customizable volume control",
        "• Per-event sound selection",
        "• SharedMedia support",
        "• Lightweight and efficient"
    }
    
    for _, feature in ipairs(featureList) do
        local text = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        text:SetPoint("TOPLEFT", 32, y)
        text:SetText(feature)
        y = y - 20
    end
end

-- Open options
function Options:OpenOptions()
    if not BLU.OptionsPanel then
        self:CreateOptionsPanel()
    end
    
    if not BLU.OptionsCategory then
        BLU:Print("Options panel not properly registered.")
        return
    end
    
    if Settings and Settings.OpenToCategory and BLU.OptionsCategory and BLU.OptionsCategory.ID then
        Settings.OpenToCategory(BLU.OptionsCategory.ID)
    elseif InterfaceOptionsFrame_OpenToCategory and BLU.OptionsCategory then
        InterfaceOptionsFrame_OpenToCategory(BLU.OptionsCategory)
        InterfaceOptionsFrame_OpenToCategory(BLU.OptionsCategory)
    end
end