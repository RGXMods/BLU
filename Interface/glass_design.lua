--=====================================================================================
-- BLU | Modern Glass Design System
-- Author: donniedice
-- Description: Beautiful, modern UI design with glass effects
--=====================================================================================

local addonName, BLU = ...

-- Create the modern glass design system
BLU.GlassDesign = {}
local GlassDesign = BLU.GlassDesign

-- Color Palette (Modern glass theme)
GlassDesign.Colors = {
    -- Primary colors with transparency
    Background = {0.05, 0.05, 0.05, 0.85},      -- Dark with glass effect
    BackgroundLight = {0.1, 0.1, 0.1, 0.75},    -- Lighter panels
    Border = {0.8, 0.8, 0.8, 0.3},              -- Subtle white border
    BorderHighlight = {1, 1, 1, 0.6},           -- Highlighted border
    
    -- Text colors
    TextHighlight = {1, 1, 1, 1},               -- Pure white for emphasis
    TextNormal = {0.9, 0.9, 0.9, 1},            -- Slightly gray
    TextDisabled = {0.5, 0.5, 0.5, 1},          -- Grayed out
    
    -- Accent colors
    Accent = {0.82, 0.69, 0.36, 1},             -- Gold accent
    AccentBlue = {0.4, 0.73, 1, 1},             -- Blue for BLU branding
    Success = {0.4, 0.8, 0.4, 1},               -- Green
    Warning = {1, 0.8, 0.4, 1},                 -- Yellow/Orange
    Error = {1, 0.4, 0.4, 1},                   -- Red
}

-- Spacing and dimensions
GlassDesign.Spacing = {
    Tiny = 4,
    Small = 8,
    Medium = 12,
    Large = 20,
    Huge = 32,
}

-- Font definitions
GlassDesign.Fonts = {
    Title = "SystemFont_Shadow_Huge2",          -- Large titles
    Header = "SystemFont_Shadow_Large",         -- Section headers
    Normal = "SystemFont_Shadow_Med1",          -- Regular text
    Small = "SystemFont_Shadow_Small",          -- Small text
    Tiny = "SystemFont_Tiny",                   -- Tiny text
}

-- Create a glass panel with blur effect
function GlassDesign:CreateGlassPanel(parent, name)
    local panel = CreateFrame("Frame", name, parent, "BackdropTemplate")
    
    -- Modern backdrop with blur effect simulation
    panel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    
    -- Apply glass effect colors
    panel:SetBackdropColor(unpack(self.Colors.Background))
    panel:SetBackdropBorderColor(unpack(self.Colors.Border))
    
    -- Add gradient overlay for depth
    local gradient = panel:CreateTexture(nil, "BACKGROUND", nil, 1)
    gradient:SetAllPoints()
    gradient:SetTexture("Interface\\AddOns\\BLU\\media\\textures\\gradient")
    gradient:SetVertexColor(1, 1, 1, 0.05)
    gradient:SetBlendMode("ADD")
    
    -- Hover effect
    panel:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(unpack(GlassDesign.Colors.BorderHighlight))
    end)
    
    panel:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(unpack(GlassDesign.Colors.Border))
    end)
    
    return panel
end

-- Create a section with title
function GlassDesign:CreateSection(parent, title)
    local section = self:CreateGlassPanel(parent)
    section:SetHeight(200) -- Default height
    
    -- Title bar
    local titleBar = CreateFrame("Frame", nil, section, "BackdropTemplate")
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", 0, 0)
    titleBar:SetHeight(32)
    titleBar:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    titleBar:SetBackdropColor(0, 0, 0, 0.5)
    
    -- Title text with glow
    local titleText = titleBar:CreateFontString(nil, "OVERLAY", self.Fonts.Header)
    titleText:SetPoint("LEFT", self.Spacing.Medium, 0)
    titleText:SetText(title)
    titleText:SetTextColor(unpack(self.Colors.Accent))
    
    -- Content area
    local content = CreateFrame("Frame", nil, section)
    content:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", self.Spacing.Small, -self.Spacing.Small)
    content:SetPoint("BOTTOMRIGHT", -self.Spacing.Small, self.Spacing.Small)
    
    section.titleBar = titleBar
    section.titleText = titleText
    section.content = content
    
    return section
end

-- Create a beautiful button
function GlassDesign:CreateButton(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width or 120, height or 32)
    
    -- Glass backdrop
    button:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    button:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    button:SetBackdropBorderColor(unpack(self.Colors.Border))
    
    -- Button text
    button.text = button:CreateFontString(nil, "OVERLAY", self.Fonts.Normal)
    button.text:SetPoint("CENTER")
    button.text:SetText(text)
    button.text:SetTextColor(unpack(self.Colors.TextNormal))
    
    -- Highlight texture
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    highlight:SetBlendMode("ADD")
    highlight:SetAlpha(0.3)
    
    -- Animations
    button:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(unpack(GlassDesign.Colors.AccentBlue))
        self.text:SetTextColor(unpack(GlassDesign.Colors.TextHighlight))
    end)
    
    button:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(unpack(GlassDesign.Colors.Border))
        self.text:SetTextColor(unpack(GlassDesign.Colors.TextNormal))
    end)
    
    button:SetScript("OnMouseDown", function(self)
        self.text:SetPoint("CENTER", 1, -1)
    end)
    
    button:SetScript("OnMouseUp", function(self)
        self.text:SetPoint("CENTER", 0, 0)
    end)
    
    return button
end

-- Create a slider with modern style
function GlassDesign:CreateSlider(parent, label, min, max, step)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(200, 50)
    
    -- Label
    local labelText = container:CreateFontString(nil, "OVERLAY", self.Fonts.Normal)
    labelText:SetPoint("TOP", 0, 0)
    labelText:SetText(label)
    labelText:SetTextColor(unpack(self.Colors.TextNormal))
    
    -- Slider
    local slider = CreateFrame("Slider", nil, container, "BackdropTemplate")
    slider:SetPoint("TOP", labelText, "BOTTOM", 0, -8)
    slider:SetSize(180, 20)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    
    -- Slider backdrop
    slider:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    slider:SetBackdropColor(0, 0, 0, 0.5)
    
    -- Thumb texture (modern style)
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    local thumb = slider:GetThumbTexture()
    thumb:SetSize(16, 16)
    thumb:SetVertexColor(unpack(self.Colors.Accent))
    
    -- Value display
    local valueText = slider:CreateFontString(nil, "OVERLAY", self.Fonts.Small)
    valueText:SetPoint("BOTTOM", slider, "TOP", 0, 2)
    valueText:SetTextColor(unpack(self.Colors.TextHighlight))
    
    slider:SetScript("OnValueChanged", function(self, value)
        valueText:SetText(string.format("%.0f", value))
    end)
    
    container.label = labelText
    container.slider = slider
    container.value = valueText
    
    return container
end

-- Create a checkbox with modern style
function GlassDesign:CreateCheckbox(parent, label)
    local checkbox = CreateFrame("CheckButton", nil, parent, "BackdropTemplate")
    checkbox:SetSize(24, 24)
    
    -- Custom checkbox backdrop
    checkbox:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    checkbox:SetBackdropColor(0, 0, 0, 0.5)
    checkbox:SetBackdropBorderColor(unpack(self.Colors.Border))
    
    -- Check mark
    checkbox:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Check")
    checkbox:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    checkbox:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    checkbox:GetHighlightTexture():SetAlpha(0.3)
    
    local check = checkbox:GetNormalTexture()
    check:SetSize(20, 20)
    check:SetPoint("CENTER")
    check:SetVertexColor(unpack(self.Colors.Accent))
    check:SetAlpha(0)
    
    -- Label
    local labelText = checkbox:CreateFontString(nil, "OVERLAY", self.Fonts.Normal)
    labelText:SetPoint("LEFT", checkbox, "RIGHT", self.Spacing.Small, 0)
    labelText:SetText(label)
    labelText:SetTextColor(unpack(self.Colors.TextNormal))
    
    -- Toggle functionality
    checkbox:SetScript("OnClick", function(self)
        if self:GetChecked() then
            check:SetAlpha(1)
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        else
            check:SetAlpha(0)
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
        end
    end)
    
    checkbox.label = labelText
    checkbox.check = check
    
    return checkbox
end

-- Create tab system with smooth transitions
function GlassDesign:CreateTabSystem(parent)
    local tabContainer = CreateFrame("Frame", nil, parent)
    tabContainer:SetHeight(40)
    tabContainer:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    tabContainer:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    
    local tabs = {}
    local panels = {}
    local currentTab = nil
    
    local function SelectTab(tabName)
        -- Hide all panels
        for name, panel in pairs(panels) do
            panel:Hide()
        end
        
        -- Deselect all tabs
        for name, tab in pairs(tabs) do
            tab:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
            tab.text:SetTextColor(unpack(GlassDesign.Colors.TextNormal))
        end
        
        -- Show selected panel and highlight tab
        if panels[tabName] then
            panels[tabName]:Show()
            tabs[tabName]:SetBackdropColor(0.15, 0.15, 0.15, 0.8)
            tabs[tabName].text:SetTextColor(unpack(GlassDesign.Colors.Accent))
            currentTab = tabName
        end
    end
    
    local function CreateTab(name, text)
        local tab = CreateFrame("Button", nil, tabContainer, "BackdropTemplate")
        tab:SetSize(120, 32)
        
        -- Position tabs horizontally
        local numTabs = 0
        for _ in pairs(tabs) do numTabs = numTabs + 1 end
        tab:SetPoint("LEFT", numTabs * 125 + GlassDesign.Spacing.Medium, 0)
        
        -- Tab backdrop
        tab:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        })
        tab:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
        tab:SetBackdropBorderColor(unpack(GlassDesign.Colors.Border))
        
        -- Tab text
        tab.text = tab:CreateFontString(nil, "OVERLAY", GlassDesign.Fonts.Normal)
        tab.text:SetPoint("CENTER")
        tab.text:SetText(text)
        tab.text:SetTextColor(unpack(GlassDesign.Colors.TextNormal))
        
        -- Click handler
        tab:SetScript("OnClick", function()
            SelectTab(name)
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        end)
        
        tabs[name] = tab
        
        -- Create associated panel
        local panel = CreateFrame("Frame", nil, parent)
        panel:SetPoint("TOPLEFT", tabContainer, "BOTTOMLEFT", 0, -GlassDesign.Spacing.Small)
        panel:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
        panel:Hide()
        
        panels[name] = panel
        
        return tab, panel
    end
    
    tabContainer.CreateTab = CreateTab
    tabContainer.SelectTab = SelectTab
    tabContainer.tabs = tabs
    tabContainer.panels = panels
    
    return tabContainer
end

-- Initialize the design system
function GlassDesign:Init()
    -- Create gradient texture if it doesn't exist
    if not self.gradientTexture then
        self.gradientTexture = "Interface\\AddOns\\BLU\\media\\textures\\gradient"
    end
    
    BLU:PrintDebug("Modern Glass Design System initialized")
end

-- Export to BLU namespace
BLU.GlassDesign = GlassDesign

return GlassDesign