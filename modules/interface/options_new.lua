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
    BLU:PrintDebug("Initializing new options module")
    
    -- Make functions available globally
    BLU.CreateOptionsPanel = function()
        return self:CreateOptionsPanel()
    end
    
    BLU.OpenOptions = function()
        return self:OpenOptions()
    end
    
    -- Create the panel after a short delay
    C_Timer.After(0.1, function()
        if not BLU.OptionsPanel then
            self:CreateOptionsPanel()
        end
    end)
end

-- Create preview section
local function CreatePreviewSection(parent)
    local preview = CreateFrame("Frame", nil, parent)
    preview:SetHeight(180)
    BLU.Design:ApplyBackdrop(preview, "Dark", BLU.Design.Colors.Panel, BLU.Design.Colors.Primary)
    
    -- Title
    local title = preview:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -10)
    title:SetText(BLU.Design.Colors.PrimaryHex .. "Sound Preview|r")
    
    -- Preview content area
    local content = CreateFrame("Frame", nil, preview)
    content:SetPoint("TOPLEFT", 20, -40)
    content:SetPoint("BOTTOMRIGHT", -20, 60)
    
    -- Current sound display
    local currentLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    currentLabel:SetPoint("TOPLEFT", 0, 0)
    currentLabel:SetText("Currently Playing:")
    currentLabel:SetTextColor(unpack(BLU.Design.Colors.TextMuted))
    
    local currentSound = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    currentSound:SetPoint("TOPLEFT", currentLabel, "BOTTOMLEFT", 0, -5)
    currentSound:SetText("None")
    preview.currentSound = currentSound
    
    -- Test buttons
    local buttonY = -10
    local events = {
        {id = "levelup", text = "Level Up", color = {1, 0.82, 0}},
        {id = "achievement", text = "Achievement", color = {0.2, 1, 0.2}},
        {id = "quest", text = "Quest", color = {0.2, 1, 1}},
        {id = "reputation", text = "Reputation", color = {0.8, 0.5, 1}}
    }
    
    for i, event in ipairs(events) do
        local btn = BLU.Design:CreateButton(preview, event.text, 100, 25)
        btn:SetPoint("BOTTOM", preview, "BOTTOM", -220 + (i-1) * 110, 20)
        btn.Text:SetTextColor(unpack(event.color))
        btn:SetScript("OnClick", function()
            if BLU.PlayCategorySound then
                BLU:PlayCategorySound(event.id)
                currentSound:SetText(event.text .. " Sound")
                currentSound:SetTextColor(unpack(event.color))
            end
        end)
    end
    
    return preview
end

-- Create tab button with SimpleQuestPlates style
local function CreateTabButton(parent, text, index, totalTabs)
    local button = CreateFrame("Button", "BLUTab" .. text:gsub(" ", ""), parent)
    button:SetSize(120, 32)
    
    -- Position
    local xOffset = -((totalTabs * 120 + (totalTabs - 1) * 5) / 2) + (index - 1) * 125 + 60
    button:SetPoint("TOP", parent, "TOP", xOffset, -5)
    
    -- Background
    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    button.bg = bg
    
    -- Border
    local border = CreateFrame("Frame", nil, button, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    button.border = border
    
    -- Text
    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buttonText:SetPoint("CENTER", 0, 0)
    buttonText:SetText(text)
    button.text = buttonText
    
    -- Active indicator
    local active = button:CreateTexture(nil, "ARTWORK")
    active:SetHeight(3)
    active:SetPoint("BOTTOMLEFT", 0, 0)
    active:SetPoint("BOTTOMRIGHT", 0, 0)
    active:SetColorTexture(unpack(BLU.Design.Colors.Primary))
    active:Hide()
    button.active = active
    
    -- Scripts
    button:SetScript("OnClick", function(self)
        self:GetParent():GetParent():SelectTab(self.tabIndex)
    end)
    
    button:SetScript("OnEnter", function(self)
        if not self.isActive then
            self.bg:SetColorTexture(0.15, 0.15, 0.15, 1)
            self.border:SetBackdropBorderColor(unpack(BLU.Design.Colors.Primary))
        end
    end)
    
    button:SetScript("OnLeave", function(self)
        if not self.isActive then
            self.bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
            self.border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        end
    end)
    
    button.tabIndex = index
    
    function button:SetActive(active)
        self.isActive = active
        if active then
            self.bg:SetColorTexture(0.05, 0.05, 0.05, 1)
            self.border:SetBackdropBorderColor(unpack(BLU.Design.Colors.Primary))
            self.text:SetTextColor(unpack(BLU.Design.Colors.Primary))
            self.active:Show()
        else
            self.bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
            self.border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
            self.text:SetTextColor(1, 1, 1, 1)
            self.active:Hide()
        end
    end
    
    return button
end

-- Create main options panel
function Options:CreateOptionsPanel()
    BLU:PrintDebug("Creating new options panel...")
    
    -- Create main frame
    local panel = CreateFrame("Frame", "BLUOptionsPanel", UIParent)
    panel.name = "Better Level-Up!"
    
    -- Apply main panel styling
    BLU.Design:ApplyBackdrop(panel, "Panel")
    
    -- Store reference
    BLU.OptionsPanel = panel
    
    -- Header section
    local header = CreateFrame("Frame", nil, panel)
    header:SetHeight(100)
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)
    BLU.Design:ApplyBackdrop(header, "Dark", {0.05, 0.05, 0.05, 1})
    
    -- Large icon
    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(80, 80)
    icon:SetPoint("LEFT", 20, 0)
    icon:SetTexture("Interface\\Icons\\Achievement_Level_100")
    
    -- Title
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("LEFT", icon, "RIGHT", 15, 15)
    title:SetText(BLU.Design.Colors.PrimaryHex .. "BLU|r - Better Level-Up!")
    
    -- Subtitle
    local subtitle = header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
    subtitle:SetText("Play sounds from 50+ games when events fire in WoW!")
    subtitle:SetTextColor(unpack(BLU.Design.Colors.TextMuted))
    
    -- Version in corner
    local version = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    version:SetPoint("TOPRIGHT", -20, -20)
    version:SetText("v" .. (BLU.version or "5.3.0-alpha"))
    version:SetTextColor(unpack(BLU.Design.Colors.Primary))
    
    -- RGX Mods branding
    local branding = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    branding:SetPoint("BOTTOMRIGHT", -20, 10)
    branding:SetText("|cffffd700RGX Mods|r")
    
    -- Preview section
    local preview = CreatePreviewSection(panel)
    preview:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 10, -10)
    preview:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", -10, -10)
    
    -- Tab container
    local tabContainer = CreateFrame("Frame", nil, panel)
    tabContainer:SetHeight(40)
    tabContainer:SetPoint("TOPLEFT", preview, "BOTTOMLEFT", 0, -10)
    tabContainer:SetPoint("TOPRIGHT", preview, "BOTTOMRIGHT", 0, -10)
    
    -- Create tabs
    local tabs = {
        {text = "General", create = BLU.CreateGeneralPanel},
        {text = "Sounds", create = BLU.CreateSoundsPanel},
        {text = "Modules", create = BLU.CreateModulesPanel},
        {text = "About", create = BLU.CreateAboutPanel},
        {text = "RGX Mods", create = BLU.CreateRGXPanel}
    }
    
    panel.tabs = {}
    panel.contents = {}
    
    for i, tabInfo in ipairs(tabs) do
        local tab = CreateTabButton(tabContainer, tabInfo.text, i, #tabs)
        panel.tabs[i] = tab
        
        -- Create content frame
        local content = CreateFrame("Frame", nil, panel)
        content:SetPoint("TOPLEFT", tabContainer, "BOTTOMLEFT", 0, -5)
        content:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 10)
        BLU.Design:ApplyBackdrop(content, "Dark", BLU.Design.Colors.Panel)
        content:Hide()
        
        -- Create tab content
        if tabInfo.create then
            tabInfo.create(content)
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

-- Create RGX Mods panel (new)
function BLU.CreateRGXPanel(panel)
    local content = CreateFrame("Frame", nil, panel)
    content:SetAllPoints()
    
    local header = BLU.Design:CreateHeader(content, "RGX Mods - RealmGX Community", "Interface\\Icons\\VAS_RaceChange")
    header:SetPoint("TOPLEFT", 20, -20)
    header:SetPoint("TOPRIGHT", -20, -20)
    
    local info = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    info:SetPoint("TOP", header, "BOTTOM", 0, -30)
    info:SetText("Join our community for more amazing addons!")
    
    local discord = BLU.Design:CreateButton(content, "Discord", 200, 40)
    discord:SetPoint("TOP", info, "BOTTOM", 0, -30)
    discord:SetScript("OnClick", function()
        BLU:Print("Join us at: |cffffd700discord.gg/rgxmods|r")
    end)
end