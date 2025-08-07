--=====================================================================================
-- BLU - interface/design_narcissus.lua
-- Narcissus-inspired design system for clean, modern UI
--=====================================================================================

local addonName, BLU = ...

-- Create Narcissus-style design namespace
BLU.NarciDesign = {
    -- Narcissus-inspired color system
    Colors = {
        -- Three-tier text system
        Text = {
            Highlight = {0.92, 0.92, 0.92, 1},  -- Bright white (hover/active)
            Normal = {0.67, 0.67, 0.67, 1},     -- Medium gray (default)
            Disabled = {0.40, 0.40, 0.40, 1},   -- Dark gray (disabled)
            Muted = {0.72, 0.72, 0.72, 1},      -- Light gray (descriptions)
        },
        -- BLU brand colors
        Brand = {
            Primary = {0.02, 0.87, 0.98, 1},    -- BLU blue: #05dffa
            PrimaryHex = "|cff05dffa",
            PrimaryRGB = {5, 223, 250},         -- For texture coloring
        },
        -- Background colors
        Background = {
            Dark = {0.08, 0.08, 0.08, 0.95},    -- Very dark background
            Panel = {0.12, 0.12, 0.12, 0.9},    -- Panel background
            Section = {0.05, 0.05, 0.05, 0.6},  -- Section background
            Hover = {1, 1, 1, 0.05},             -- Subtle hover highlight
        },
        -- Border colors
        Border = {
            Normal = {0.3, 0.3, 0.3, 1},        -- Default border
            Highlight = {0.5, 0.5, 0.5, 1},     -- Medium border
            Active = {0.02, 0.87, 0.98, 0.8},   -- BLU blue for active
        },
        -- Status colors
        Status = {
            Success = {0.2, 0.8, 0.2, 1},       -- Green
            Warning = {1, 0.82, 0, 1},           -- Yellow
            Error = {1, 0.2, 0.2, 1},            -- Red
        }
    },
    
    -- Narcissus-style spacing and measurements
    Layout = {
        -- Consistent padding
        PADDING_H = 18,          -- Horizontal padding
        PADDING_V = 12,          -- Vertical padding
        WIDGET_GAP = 16,         -- Gap between widgets
        SECTION_GAP = 20,        -- Gap between sections
        
        -- Standard sizes
        BUTTON_HEIGHT = 24,      -- Standard button height
        SLIDER_WIDTH = 160,      -- Standard slider width
        SLIDER_HEIGHT = 6,       -- Compact slider height
        CHECKBOX_SIZE = 12,      -- Checkbox size
        RADIO_SIZE = 16,         -- Radio button size
        
        -- Panel dimensions
        PANEL_WIDTH = 640,       -- Standard panel width
        SIDEBAR_WIDTH = 160,     -- Category sidebar width
        CONTENT_MARGIN = 10,     -- Content margin from edges
        SCROLL_MARGIN = 30,      -- Extra margin for scrollbar
    },
    
    -- Font definitions (mimicking Narcissus style)
    Fonts = {
        -- Font heights
        Heights = {
            Huge = 18,
            Large = 14,
            Medium = 12,
            Normal = 11,
            Small = 10,
            Tiny = 9,
        },
        -- Font shadows (1px offset for depth)
        Shadow = {
            Offset = {x = 1, y = -1},
            Color = {0, 0, 0, 0.8},
        }
    },
    
    -- Animation settings
    Animation = {
        FadeInDuration = 0.15,
        FadeOutDuration = 0.1,
        ScaleHover = 1.02,
        TransitionTime = 0.1,
    }
}

local ND = BLU.NarciDesign  -- Shorthand

-- Helper: Apply Narcissus-style font
function ND:ApplyFont(fontString, size, color)
    local font, _, flags = fontString:GetFont()
    fontString:SetFont(font, self.Fonts.Heights[size] or self.Fonts.Heights.Normal, "OUTLINE")
    fontString:SetShadowOffset(self.Fonts.Shadow.Offset.x, self.Fonts.Shadow.Offset.y)
    fontString:SetShadowColor(unpack(self.Fonts.Shadow.Color))
    
    if color then
        if type(color) == "string" then
            fontString:SetTextColor(unpack(self.Colors.Text[color] or self.Colors.Text.Normal))
        else
            fontString:SetTextColor(unpack(color))
        end
    else
        fontString:SetTextColor(unpack(self.Colors.Text.Normal))
    end
end

-- Create Narcissus-style checkbox
function ND:CreateCheckbox(parent, label, tooltip)
    local container = CreateFrame("Frame", nil, parent)
    container:SetHeight(24)
    
    -- Custom checkbox button (12x12 like Narcissus)
    local checkbox = CreateFrame("Button", nil, container)
    checkbox:SetSize(self.Layout.CHECKBOX_SIZE, self.Layout.CHECKBOX_SIZE)
    checkbox:SetPoint("LEFT", 0, 0)
    
    -- Checkbox border (always visible)
    local border = checkbox:CreateTexture(nil, "BORDER")
    border:SetAllPoints()
    border:SetColorTexture(1, 1, 1, 1)
    checkbox.border = border
    
    -- Inner background
    local bg = checkbox:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", 1, -1)
    bg:SetPoint("BOTTOMRIGHT", -1, 1)
    bg:SetColorTexture(unpack(self.Colors.Background.Dark))
    
    -- Check mark (tick)
    local tick = checkbox:CreateTexture(nil, "OVERLAY")
    tick:SetSize(8, 8)
    tick:SetPoint("CENTER")
    tick:SetColorTexture(unpack(self.Colors.Brand.Primary))
    tick:Hide()
    checkbox.tick = tick
    
    -- Highlight on hover
    local highlight = checkbox:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(unpack(self.Colors.Background.Hover))
    highlight:SetBlendMode("ADD")
    
    -- Label
    local text = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", checkbox, "RIGHT", 8, 0)
    text:SetText(label)
    self:ApplyFont(text, "Normal", "Normal")
    container.label = text
    
    -- Checkbox state
    checkbox.checked = false
    
    -- Click handler
    checkbox:SetScript("OnClick", function(self)
        self.checked = not self.checked
        if self.checked then
            self.tick:Show()
            self.border:SetColorTexture(unpack(ND.Colors.Brand.Primary))
        else
            self.tick:Hide()
            self.border:SetColorTexture(unpack(ND.Colors.Border.Normal))
        end
        
        if container.OnValueChanged then
            container:OnValueChanged(self.checked)
        end
    end)
    
    -- Hover effects
    checkbox:SetScript("OnEnter", function(self)
        ND:ApplyFont(text, "Normal", "Highlight")
        if not self.checked then
            self.border:SetColorTexture(unpack(ND.Colors.Border.Highlight))
        end
        
        if tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(label, unpack(ND.Colors.Text.Highlight))
            GameTooltip:AddLine(tooltip, unpack(ND.Colors.Text.Muted))
            GameTooltip:Show()
        end
    end)
    
    checkbox:SetScript("OnLeave", function(self)
        ND:ApplyFont(text, "Normal", "Normal")
        if not self.checked then
            self.border:SetColorTexture(unpack(ND.Colors.Border.Normal))
        end
        GameTooltip:Hide()
    end)
    
    -- API
    function container:SetChecked(checked)
        checkbox.checked = checked
        if checked then
            checkbox.tick:Show()
            checkbox.border:SetColorTexture(unpack(ND.Colors.Brand.Primary))
        else
            checkbox.tick:Hide()
            checkbox.border:SetColorTexture(unpack(ND.Colors.Border.Normal))
        end
    end
    
    function container:GetChecked()
        return checkbox.checked
    end
    
    container.checkbox = checkbox
    container:SetWidth(checkbox:GetWidth() + 8 + text:GetStringWidth())
    
    return container
end

-- Create Narcissus-style slider
function ND:CreateSlider(parent, label, min, max, step, width)
    local container = CreateFrame("Frame", nil, parent)
    container:SetHeight(40)
    container:SetWidth(width or self.Layout.SLIDER_WIDTH)
    
    -- Label
    local text = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOPLEFT", 0, 0)
    text:SetText(label)
    self:ApplyFont(text, "Normal", "Normal")
    
    -- Value display
    local value = container:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    value:SetPoint("TOPRIGHT", 0, 0)
    self:ApplyFont(value, "Small", "Highlight")
    
    -- Custom slider frame
    local slider = CreateFrame("Frame", nil, container)
    slider:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -8)
    slider:SetPoint("TOPRIGHT", value, "BOTTOMRIGHT", 0, -8)
    slider:SetHeight(self.Layout.SLIDER_HEIGHT)
    
    -- Slider track background
    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetHeight(2)
    track:SetPoint("LEFT", 0, 0)
    track:SetPoint("RIGHT", 0, 0)
    track:SetColorTexture(unpack(self.Colors.Border.Normal))
    
    -- Slider fill (progress)
    local fill = slider:CreateTexture(nil, "ARTWORK")
    fill:SetHeight(2)
    fill:SetPoint("LEFT", track, "LEFT", 0, 0)
    fill:SetColorTexture(unpack(self.Colors.Brand.Primary))
    slider.fill = fill
    
    -- Slider thumb
    local thumb = CreateFrame("Button", nil, slider)
    thumb:SetSize(16, 16)
    thumb:SetPoint("CENTER", track, "LEFT", 0, 0)
    
    -- Thumb texture (circular)
    local thumbBg = thumb:CreateTexture(nil, "BACKGROUND")
    thumbBg:SetAllPoints()
    thumbBg:SetTexture("Interface\\Buttons\\UI-RadioButton")
    thumbBg:SetTexCoord(0.25, 0.5, 0, 1)
    thumbBg:SetVertexColor(unpack(self.Colors.Text.Normal))
    thumb.bg = thumbBg
    
    -- Enlarged hit area
    thumb:SetHitRectInsets(-4, -4, -8, -8)
    
    -- Slider values
    slider.min = min or 0
    slider.max = max or 100
    slider.step = step or 1
    slider.value = slider.min
    
    -- Update display
    local function UpdateSlider()
        local percent = (slider.value - slider.min) / (slider.max - slider.min)
        local trackWidth = track:GetWidth()
        thumb:SetPoint("CENTER", track, "LEFT", trackWidth * percent, 0)
        fill:SetWidth(math.max(1, trackWidth * percent))
        value:SetText(string.format("%.0f", slider.value))
    end
    
    -- Dragging
    thumb:SetMovable(true)
    thumb:RegisterForDrag("LeftButton")
    
    thumb:SetScript("OnDragStart", function(self)
        self:StartMoving()
        self.dragging = true
    end)
    
    thumb:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.dragging = false
    end)
    
    thumb:SetScript("OnUpdate", function(self)
        if self.dragging then
            local x = self:GetCenter()
            local trackLeft = track:GetLeft()
            local trackWidth = track:GetWidth()
            
            if trackLeft and trackWidth > 0 then
                local percent = math.min(1, math.max(0, (x - trackLeft) / trackWidth))
                slider.value = slider.min + (slider.max - slider.min) * percent
                
                -- Snap to step
                if slider.step > 0 then
                    slider.value = math.floor(slider.value / slider.step + 0.5) * slider.step
                end
                
                UpdateSlider()
                
                if container.OnValueChanged then
                    container:OnValueChanged(slider.value)
                end
            end
        end
    end)
    
    -- Click to set
    slider:EnableMouse(true)
    slider:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            local x = GetCursorPosition() / self:GetEffectiveScale()
            local trackLeft = track:GetLeft()
            local trackWidth = track:GetWidth()
            
            if trackLeft and trackWidth > 0 then
                local percent = math.min(1, math.max(0, (x - trackLeft) / trackWidth))
                slider.value = slider.min + (slider.max - slider.min) * percent
                
                -- Snap to step
                if slider.step > 0 then
                    slider.value = math.floor(slider.value / slider.step + 0.5) * slider.step
                end
                
                UpdateSlider()
                
                if container.OnValueChanged then
                    container:OnValueChanged(slider.value)
                end
            end
        end
    end)
    
    -- Hover effects
    thumb:SetScript("OnEnter", function(self)
        self.bg:SetVertexColor(unpack(ND.Colors.Text.Highlight))
        self:SetSize(18, 18)
    end)
    
    thumb:SetScript("OnLeave", function(self)
        if not self.dragging then
            self.bg:SetVertexColor(unpack(ND.Colors.Text.Normal))
            self:SetSize(16, 16)
        end
    end)
    
    -- API
    function container:SetValue(val)
        slider.value = math.min(slider.max, math.max(slider.min, val))
        UpdateSlider()
    end
    
    function container:GetValue()
        return slider.value
    end
    
    container.slider = slider
    container.label = text
    container.valueText = value
    
    -- Initial update
    C_Timer.After(0.01, UpdateSlider)
    
    return container
end

-- Create Narcissus-style button
function ND:CreateButton(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width or 100, height or self.Layout.BUTTON_HEIGHT)
    
    -- Background
    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(unpack(self.Colors.Background.Panel))
    button.bg = bg
    
    -- Border
    local border = CreateFrame("Frame", nil, button, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    border:SetBackdropBorderColor(unpack(self.Colors.Border.Normal))
    button.border = border
    
    -- Text
    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("CENTER")
    label:SetText(text)
    self:ApplyFont(label, "Normal", "Normal")
    button.label = label
    
    -- Highlight texture
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(unpack(self.Colors.Background.Hover))
    highlight:SetBlendMode("ADD")
    
    -- Button states
    button:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(0.15, 0.15, 0.15, 0.9)
        self.border:SetBackdropBorderColor(unpack(ND.Colors.Border.Highlight))
        ND:ApplyFont(self.label, "Normal", "Highlight")
    end)
    
    button:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(unpack(ND.Colors.Background.Panel))
        self.border:SetBackdropBorderColor(unpack(ND.Colors.Border.Normal))
        ND:ApplyFont(self.label, "Normal", "Normal")
    end)
    
    button:SetScript("OnMouseDown", function(self)
        self.label:SetPoint("CENTER", 0, -1)
        self.bg:SetColorTexture(0.05, 0.05, 0.05, 0.9)
    end)
    
    button:SetScript("OnMouseUp", function(self)
        self.label:SetPoint("CENTER", 0, 0)
        if self:IsMouseOver() then
            self.bg:SetColorTexture(0.15, 0.15, 0.15, 0.9)
        else
            self.bg:SetColorTexture(unpack(ND.Colors.Background.Panel))
        end
    end)
    
    -- API
    function button:SetText(text)
        self.label:SetText(text)
    end
    
    return button
end

-- Create Narcissus-style radio button
function ND:CreateRadioButton(parent, label, group)
    local container = CreateFrame("Frame", nil, parent)
    container:SetHeight(24)
    
    -- Radio button
    local radio = CreateFrame("Button", nil, container)
    radio:SetSize(self.Layout.RADIO_SIZE, self.Layout.RADIO_SIZE)
    radio:SetPoint("LEFT", 0, 0)
    
    -- Outer circle
    local border = radio:CreateTexture(nil, "BORDER")
    border:SetAllPoints()
    border:SetTexture("Interface\\Buttons\\UI-RadioButton")
    border:SetTexCoord(0, 0.25, 0, 1)
    border:SetVertexColor(unpack(self.Colors.Border.Normal))
    radio.border = border
    
    -- Inner dot (selected indicator)
    local dot = radio:CreateTexture(nil, "OVERLAY")
    dot:SetSize(8, 8)
    dot:SetPoint("CENTER")
    dot:SetTexture("Interface\\Buttons\\UI-RadioButton")
    dot:SetTexCoord(0.25, 0.5, 0, 1)
    dot:SetVertexColor(unpack(self.Colors.Brand.Primary))
    dot:Hide()
    radio.dot = dot
    
    -- Label
    local text = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", radio, "RIGHT", 8, 0)
    text:SetText(label)
    self:ApplyFont(text, "Normal", "Normal")
    container.label = text
    
    -- Group management
    radio.group = group or "default"
    radio.selected = false
    
    -- Store in group registry
    if not ND.RadioGroups then
        ND.RadioGroups = {}
    end
    if not ND.RadioGroups[radio.group] then
        ND.RadioGroups[radio.group] = {}
    end
    table.insert(ND.RadioGroups[radio.group], radio)
    
    -- Click handler
    radio:SetScript("OnClick", function(self)
        -- Deselect all in group
        for _, btn in ipairs(ND.RadioGroups[self.group]) do
            btn.selected = false
            btn.dot:Hide()
            btn.border:SetVertexColor(unpack(ND.Colors.Border.Normal))
        end
        
        -- Select this one
        self.selected = true
        self.dot:Show()
        self.border:SetVertexColor(unpack(ND.Colors.Brand.Primary))
        
        if container.OnValueChanged then
            container:OnValueChanged(true)
        end
    end)
    
    -- Hover effects
    radio:SetScript("OnEnter", function(self)
        ND:ApplyFont(text, "Normal", "Highlight")
        if not self.selected then
            self.border:SetVertexColor(unpack(ND.Colors.Border.Highlight))
        end
    end)
    
    radio:SetScript("OnLeave", function(self)
        ND:ApplyFont(text, "Normal", "Normal")
        if not self.selected then
            self.border:SetVertexColor(unpack(ND.Colors.Border.Normal))
        end
    end)
    
    -- API
    function container:SetSelected(selected)
        if selected then
            radio:Click()
        else
            radio.selected = false
            radio.dot:Hide()
            radio.border:SetVertexColor(unpack(ND.Colors.Border.Normal))
        end
    end
    
    function container:GetSelected()
        return radio.selected
    end
    
    container.radio = radio
    container:SetWidth(radio:GetWidth() + 8 + text:GetStringWidth())
    
    return container
end

-- Create Narcissus-style section
function ND:CreateSection(parent, title, expandable)
    local section = CreateFrame("Frame", nil, parent)
    
    -- Section background
    local bg = section:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(unpack(self.Colors.Background.Section))
    
    -- Header
    local header = CreateFrame("Frame", nil, section)
    header:SetHeight(24)
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)
    
    -- Title
    local titleText = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("LEFT", self.Layout.PADDING_H, 0)
    titleText:SetText(title)
    self:ApplyFont(titleText, "Medium", "Highlight")
    
    -- Divider
    local divider = header:CreateTexture(nil, "BORDER")
    divider:SetHeight(1)
    divider:SetPoint("BOTTOMLEFT", self.Layout.PADDING_H, 0)
    divider:SetPoint("BOTTOMRIGHT", -self.Layout.PADDING_H, 0)
    divider:SetColorTexture(unpack(self.Colors.Border.Normal))
    
    -- Content area
    local content = CreateFrame("Frame", nil, section)
    content:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -self.Layout.PADDING_V)
    content:SetPoint("BOTTOMRIGHT", -self.Layout.PADDING_H, self.Layout.PADDING_V)
    
    -- Expandable functionality
    if expandable then
        local arrow = header:CreateTexture(nil, "OVERLAY")
        arrow:SetSize(12, 12)
        arrow:SetPoint("RIGHT", -self.Layout.PADDING_H, 0)
        arrow:SetTexture("Interface\\Buttons\\UI-MinusButton-Up")
        header.arrow = arrow
        
        header.expanded = true
        header:EnableMouse(true)
        
        header:SetScript("OnMouseDown", function(self)
            self.expanded = not self.expanded
            if self.expanded then
                content:Show()
                self.arrow:SetTexture("Interface\\Buttons\\UI-MinusButton-Up")
            else
                content:Hide()
                self.arrow:SetTexture("Interface\\Buttons\\UI-PlusButton-Up")
            end
        end)
        
        header:SetScript("OnEnter", function(self)
            ND:ApplyFont(titleText, "Medium", "Highlight")
        end)
        
        header:SetScript("OnLeave", function(self)
            ND:ApplyFont(titleText, "Medium", "Normal")
        end)
    end
    
    section.header = header
    section.content = content
    section.title = titleText
    
    return section
end

-- Create tab button (Narcissus style)
function ND:CreateTab(parent, text, index)
    local tab = CreateFrame("Button", nil, parent)
    tab:SetHeight(self.Layout.BUTTON_HEIGHT)
    
    -- Background (only visible when active)
    local bg = tab:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(unpack(self.Colors.Background.Panel))
    bg:Hide()
    tab.bg = bg
    
    -- Bottom border (active indicator)
    local activeBorder = tab:CreateTexture(nil, "BORDER")
    activeBorder:SetHeight(2)
    activeBorder:SetPoint("BOTTOMLEFT", 0, -1)
    activeBorder:SetPoint("BOTTOMRIGHT", 0, -1)
    activeBorder:SetColorTexture(unpack(self.Colors.Brand.Primary))
    activeBorder:Hide()
    tab.activeBorder = activeBorder
    
    -- Text
    local label = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("CENTER")
    label:SetText(text)
    self:ApplyFont(label, "Normal", "Normal")
    tab.label = label
    
    -- Auto-size to text
    tab:SetWidth(label:GetStringWidth() + 20)
    
    -- States
    tab.active = false
    
    function tab:SetActive(active)
        self.active = active
        if active then
            self.bg:Show()
            self.activeBorder:Show()
            ND:ApplyFont(self.label, "Normal", "Highlight")
        else
            self.bg:Hide()
            self.activeBorder:Hide()
            ND:ApplyFont(self.label, "Normal", "Normal")
        end
    end
    
    -- Hover
    tab:SetScript("OnEnter", function(self)
        if not self.active then
            ND:ApplyFont(self.label, "Normal", "Muted")
        end
    end)
    
    tab:SetScript("OnLeave", function(self)
        if not self.active then
            ND:ApplyFont(self.label, "Normal", "Normal")
        end
    end)
    
    return tab
end

-- Export to main BLU namespace
BLU.Design = BLU.NarciDesign