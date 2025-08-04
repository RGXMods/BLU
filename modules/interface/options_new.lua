--=====================================================================================
-- BLU - interface/options_new.lua
-- New options panel with SimpleQuestPlates-inspired design
--=====================================================================================

local addonName, BLU = ...

-- Create options module
local Options = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["options_new"] = Options

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
    
    BLU:PrintDebug("[Options] Functions registered")
    
    -- Create the panel after a short delay
    C_Timer.After(0.1, function()
        if not BLU.OptionsPanel then
            self:CreateOptionsPanel()
        end
    end)
end

-- Removed preview section - tabs will be module based

-- Create tab button with SimpleQuestPlates style
local function CreateTabButton(parent, text, icon, index, totalTabs)
    local button = CreateFrame("Button", "BLUTab" .. text:gsub(" ", ""), parent)
    button:SetSize(90, 28)
    
    -- Position
    if index == 1 then
        button:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, -2)
    else
        button:SetPoint("LEFT", parent[index-1], "RIGHT", 2, 0)
    end
    parent[index] = button
    
    -- Background
    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    button.bg = bg
    
    -- Border frame (SQP style)
    local border = CreateFrame("Frame", nil, button, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 1,
    })
    border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    button.border = border
    
    -- Icon
    if icon then
        local tabIcon = button:CreateTexture(nil, "ARTWORK")
        tabIcon:SetSize(16, 16)
        tabIcon:SetPoint("LEFT", 8, 0)
        tabIcon:SetTexture(icon)
        button.icon = tabIcon
    end
    
    -- Text
    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    if icon then
        buttonText:SetPoint("LEFT", button.icon, "RIGHT", 5, 0)
    else
        buttonText:SetPoint("CENTER", 0, 0)
    end
    buttonText:SetText(text)
    button.text = buttonText
    
    -- Removed separate active indicator - using border instead
    
    -- Scripts
    button:SetScript("OnClick", function(self)
        self:GetParent():GetParent():SelectTab(self.tabIndex)
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
            if self.icon then
                self.icon:SetVertexColor(unpack(BLU.Design.Colors.Primary))
            end
        else
            self.bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
            self.text:SetTextColor(0.7, 0.7, 0.7, 1)
            self.border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
            if self.icon then
                self.icon:SetVertexColor(0.7, 0.7, 0.7, 1)
            end
        end
    end
    
    return button
end

-- Create main options panel
function Options:CreateOptionsPanel()
    BLU:PrintDebug("Creating new options panel...")
    
    -- Create main frame
    local panel = CreateFrame("Frame", "BLUOptionsPanel", UIParent)
    panel.name = "|T" .. "Interface\\AddOns\\BLU\\media\\images\\icon:0|t |cff05dffaB|r|cffffffffLU|r - |cff05dffaB|r|cffffffffetter|r |cff05dffaL|r|cffffffffevel-|r|cff05dffaU|r|cffffffffp!|r"
    
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
    header:SetHeight(80)
    header:SetPoint("TOPLEFT", 10, -10)
    header:SetPoint("TOPRIGHT", -10, -10)
    header:SetBackdrop(BLU.Design.Backdrops.Dark)
    header:SetBackdropColor(0.08, 0.08, 0.08, 0.8)
    header:SetBackdropBorderColor(unpack(BLU.Design.Colors.Primary))
    
    -- Logo/Icon
    local logo = header:CreateTexture(nil, "ARTWORK")
    logo:SetSize(64, 64)
    logo:SetPoint("LEFT", 15, 0)
    if BLU.HasCustomIcon then
        logo:SetTexture("Interface\\AddOns\\BLU\\media\\images\\icon")
    else
        logo:SetTexture("Interface\\Icons\\Achievement_Level_100")
    end
    
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
    version:SetText("v" .. (BLU.version or "5.3.0-alpha"))
    version:SetTextColor(unpack(BLU.Design.Colors.Primary))
    
    local author = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    author:SetPoint("TOP", version, "BOTTOM", 0, -2)
    author:SetText("by donniedice")
    author:SetTextColor(0.7, 0.7, 0.7)
    
    -- RGX Mods branding
    local branding = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    branding:SetPoint("BOTTOMRIGHT", -15, 10)
    branding:SetText("|cffffd700RGX Mods|r")
    
    -- Tab container (SQP style tabs)
    local tabContainer = CreateFrame("Frame", nil, container)
    tabContainer:SetHeight(32)
    tabContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -10)
    tabContainer:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -10)
    
    -- Create tabs for each sound event type
    local tabs = {
        {text = "General", icon = "Interface\\Icons\\INV_Misc_Gear_01", create = BLU.CreateGeneralPanel},
        {text = "Level Up", icon = "Interface\\Icons\\Achievement_Level_100", eventType = "levelup"},
        {text = "Achievement", icon = "Interface\\Icons\\Achievement_GuildPerk_MobileMailbox", eventType = "achievement"},
        {text = "Quest", icon = "Interface\\Icons\\INV_Misc_Note_01", eventType = "quest"},
        {text = "Reputation", icon = "Interface\\Icons\\Achievement_Reputation_01", eventType = "reputation"},
        {text = "Battle Pets", icon = "Interface\\Icons\\INV_Pet_BattlePetTraining", eventType = "battlepet"},
        {text = "About", icon = "Interface\\Icons\\INV_Misc_Book_09", create = BLU.CreateAboutPanel}
    }
    
    panel.tabs = {}
    panel.contents = {}
    
    for i, tabInfo in ipairs(tabs) do
        local tab = CreateTabButton(tabContainer, tabInfo.text, tabInfo.icon, i, #tabs)
        panel.tabs[i] = tab
        
        -- Create content frame
        local content = CreateFrame("Frame", nil, container, "BackdropTemplate")
        content:SetPoint("TOPLEFT", tabContainer, "BOTTOMLEFT", 0, -2)
        content:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -10, 10)
        content:SetBackdrop(BLU.Design.Backdrops.Dark)
        content:SetBackdropColor(0.08, 0.08, 0.08, 0.8)
        content:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
        content:Hide()
        
        -- Create tab content
        if tabInfo.create then
            tabInfo.create(content)
        elseif tabInfo.eventType then
            -- Create sound selection panel for this event type
            BLU.CreateEventSoundPanel(content, tabInfo.eventType, tabInfo.text, tabInfo.icon)
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
        BLU:PrintDebug("Options panel registered with new Settings API")
    else
        -- Pre-Dragonflight
        InterfaceOptions_AddCategory(panel)
        BLU.OptionsCategory = panel
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

-- Create event sound panel for each tab
function BLU.CreateEventSoundPanel(panel, eventType, eventName, eventIcon)
    -- Create scrollable content
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth() - 20, 600)
    scrollFrame:SetScrollChild(content)
    
    -- Event header
    local header = CreateFrame("Frame", nil, content)
    header:SetHeight(40)
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("RIGHT", -20, 0)
    
    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("LEFT", 0, 0)
    icon:SetTexture(eventIcon)
    
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    title:SetText("|cff05dffa" .. eventName .. " Sounds|r")
    
    -- Enable checkbox
    local enableCheck = BLU.Design:CreateCheckbox(content, "Enable " .. eventName .. " sounds", "Play sounds for this event type")
    enableCheck:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -10)
    enableCheck.check:SetChecked(BLU.db.profile.modules and BLU.db.profile.modules[eventType] ~= false)
    enableCheck.check:SetScript("OnClick", function(self)
        BLU.db.profile.modules = BLU.db.profile.modules or {}
        BLU.db.profile.modules[eventType] = self:GetChecked()
    end)
    
    -- Sound selection section
    local soundSection = BLU.Design:CreateSection(content, "Sound Selection", "Interface\\Icons\\INV_Misc_Bell_01")
    soundSection:SetPoint("TOPLEFT", enableCheck, "BOTTOMLEFT", 0, -20)
    soundSection:SetPoint("RIGHT", -20, 0)
    soundSection:SetHeight(400)
    
    -- Current sound
    local currentLabel = soundSection.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentLabel:SetPoint("TOPLEFT", 0, -5)
    currentLabel:SetText("Current Sound:")
    
    local currentSound = soundSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    currentSound:SetPoint("LEFT", currentLabel, "RIGHT", 10, 0)
    currentSound:SetText(BLU.db.profile.selectedSounds and BLU.db.profile.selectedSounds[eventType] or "Default")
    
    -- Test button
    local testBtn = BLU.Design:CreateButton(soundSection.content, "Test", 60, 22)
    testBtn:SetPoint("LEFT", currentSound, "RIGHT", 20, 0)
    testBtn:SetScript("OnClick", function()
        if BLU.PlaySound then
            BLU:PlaySound(eventType)
        elseif BLU.Modules.registry and BLU.Modules.registry.PlaySound then
            BLU.Modules.registry:PlaySound(eventType)
        end
    end)
    
    -- Sound list
    local listLabel = soundSection.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    listLabel:SetPoint("TOPLEFT", currentLabel, "BOTTOMLEFT", 0, -20)
    listLabel:SetText("Available Sounds:")
    
    -- Create sound buttons
    local sounds = {
        {id = "default", name = "Default WoW Sound", icon = "Interface\\Icons\\INV_Misc_QuestionMark"},
        {id = "wowdefault", name = "WoW Built-in", icon = "Interface\\Icons\\INV_Misc_Book_09"},
        {id = "finalfantasy", name = "Final Fantasy", icon = "Interface\\Icons\\INV_Sword_39"},
        {id = "zelda", name = "Legend of Zelda", icon = "Interface\\Icons\\INV_Shield_05"},
        {id = "pokemon", name = "Pokemon", icon = "Interface\\Icons\\INV_Pet_BabyBlizzardBear"},
        {id = "mario", name = "Super Mario", icon = "Interface\\Icons\\INV_Mushroom_11"},
        {id = "sonic", name = "Sonic", icon = "Interface\\Icons\\INV_Boots_01"},
        {id = "metalgear", name = "Metal Gear Solid", icon = "Interface\\Icons\\INV_Misc_Bomb_04"}
    }
    
    local yOffset = -50
    for _, sound in ipairs(sounds) do
        local btn = CreateFrame("Button", nil, soundSection.content)
        btn:SetSize(300, 32)
        btn:SetPoint("TOPLEFT", 0, yOffset)
        
        -- Selection highlight
        local highlight = btn:CreateTexture(nil, "BACKGROUND")
        highlight:SetAllPoints()
        highlight:SetColorTexture(0.02, 0.37, 1, 0.2)
        highlight:Hide()
        btn.highlight = highlight
        
        -- Hover
        btn:SetHighlightTexture("Interface\\Buttons\\WHITE8x8")
        local hover = btn:GetHighlightTexture()
        hover:SetVertexColor(1, 1, 1, 0.1)
        
        -- Icon
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetSize(24, 24)
        icon:SetPoint("LEFT", 5, 0)
        icon:SetTexture(sound.icon)
        
        -- Name
        local name = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("LEFT", icon, "RIGHT", 10, 0)
        name:SetText(sound.name)
        
        -- Selected indicator
        if BLU.db.profile.selectedSounds and BLU.db.profile.selectedSounds[eventType] == sound.id then
            highlight:Show()
            name:SetTextColor(0.02, 0.87, 0.98)
        end
        
        btn:SetScript("OnClick", function(self)
            -- Update selection
            BLU.db.profile.selectedSounds = BLU.db.profile.selectedSounds or {}
            BLU.db.profile.selectedSounds[eventType] = sound.id
            
            -- Update UI
            currentSound:SetText(sound.name)
            
            -- Update highlights
            for i, s in ipairs(sounds) do
                local button = soundSection.content.soundButtons[i]
                if button then
                    if s.id == sound.id then
                        button.highlight:Show()
                        button.name:SetTextColor(0.02, 0.87, 0.98)
                    else
                        button.highlight:Hide()
                        button.name:SetTextColor(1, 1, 1)
                    end
                end
            end
            
            -- Play test sound
            if BLU.PlaySound then
                BLU:PlaySound(eventType)
            elseif BLU.Modules.registry and BLU.Modules.registry.PlaySound then
                BLU.Modules.registry:PlaySound(eventType)
            end
        end)
        
        -- Store reference
        soundSection.content.soundButtons = soundSection.content.soundButtons or {}
        soundSection.content.soundButtons[#soundSection.content.soundButtons + 1] = {
            button = btn,
            highlight = highlight,
            name = name
        }
        
        yOffset = yOffset - 35
    end
    
    -- External sounds section
    if BLU.Modules.sharedmedia then
        local externalLabel = soundSection.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        externalLabel:SetPoint("TOPLEFT", 0, yOffset - 10)
        externalLabel:SetText("External Sounds (from other addons):")
        externalLabel:SetTextColor(0.7, 0.7, 0.7)
        
        -- Show detected sounds
        local externalSounds = BLU.Modules.sharedmedia:GetExternalSounds()
        if externalSounds and next(externalSounds) then
            yOffset = yOffset - 35
            for soundName, soundData in pairs(externalSounds) do
                if yOffset < -350 then break end -- Limit display
                
                local btn = CreateFrame("Button", nil, soundSection.content)
                btn:SetSize(300, 28)
                btn:SetPoint("TOPLEFT", 0, yOffset)
                
                -- Similar button setup but for external sounds
                -- ... (abbreviated for space)
                
                yOffset = yOffset - 30
            end
        else
            local noSounds = soundSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            noSounds:SetPoint("TOPLEFT", externalLabel, "BOTTOMLEFT", 0, -5)
            noSounds:SetText("No external sounds detected")
            noSounds:SetTextColor(0.5, 0.5, 0.5)
        end
    end
    
    content:SetHeight(math.abs(yOffset) + 100)
end