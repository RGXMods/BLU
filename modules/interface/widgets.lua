--=====================================================================================
-- BLU - interface/widgets.lua
-- UI Widget creation helpers
--=====================================================================================

local addonName, BLU = ...

BLU.Widgets = {}

-- Initialize widgets
function BLU.Widgets:Init()
    -- Widget system is ready
    BLU:PrintDebug("Widgets initialized")
end

-- Create a checkbox
function BLU.Widgets:CreateCheckbox(parent, label, tooltip)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check.text = check:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    check.text:SetPoint("LEFT", check, "RIGHT", 5, 0)
    check.text:SetText(label)
    
    if tooltip then
        check:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltip, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        check:SetScript("OnLeave", GameTooltip_Hide)
    end
    
    return check
end

-- Create a slider
function BLU.Widgets:CreateSlider(parent, label, min, max, step, tooltip)
    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    
    slider.Low:SetText(min)
    slider.High:SetText(max)
    slider.Text:SetText(label)
    
    slider.value = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    slider.value:SetPoint("TOP", slider, "BOTTOM", 0, -2)
    
    if tooltip then
        slider:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltip, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        slider:SetScript("OnLeave", GameTooltip_Hide)
    end
    
    return slider
end

-- Create a dropdown
function BLU.Widgets:CreateDropdown(parent, label, width, items, tooltip)
    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(dropdown, width or 200)
    
    local dropLabel = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropLabel:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 16, 3)
    dropLabel:SetText(label)
    
    dropdown.items = items
    
    if tooltip then
        dropdown:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltip, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        dropdown:SetScript("OnLeave", GameTooltip_Hide)
    end
    
    return dropdown
end

-- Create a button
function BLU.Widgets:CreateButton(parent, text, width, height, tooltip)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width or 100, height or 22)
    button:SetText(text)
    
    if tooltip then
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltip, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", GameTooltip_Hide)
    end
    
    return button
end

-- Create a color picker
function BLU.Widgets:CreateColorPicker(parent, label, r, g, b, callback)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(150, 22)
    
    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT")
    text:SetText(label)
    
    local swatch = CreateFrame("Button", nil, frame)
    swatch:SetSize(16, 16)
    swatch:SetPoint("RIGHT")
    
    local bg = swatch:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(1, 1, 1)
    
    local tex = swatch:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints()
    tex:SetColorTexture(r, g, b)
    
    swatch.tex = tex
    swatch.r = r
    swatch.g = g
    swatch.b = b
    swatch.callback = callback
    
    swatch:SetScript("OnClick", function(self)
        local function ColorCallback(restore)
            local newR, newG, newB
            if restore then
                newR, newG, newB = restore.r, restore.g, restore.b
            else
                newR, newG, newB = ColorPickerFrame:GetColorRGB()
            end
            
            self.tex:SetColorTexture(newR, newG, newB)
            self.r, self.g, self.b = newR, newG, newB
            
            if self.callback then
                self.callback(newR, newG, newB)
            end
        end
        
        ColorPickerFrame.func = ColorCallback
        ColorPickerFrame.cancelFunc = ColorCallback
        ColorPickerFrame.previousValues = {r = self.r, g = self.g, b = self.b}
        ColorPickerFrame:SetColorRGB(self.r, self.g, self.b)
        ColorPickerFrame:Show()
    end)
    
    return frame, swatch
end

-- Create section header
function BLU.Widgets:CreateHeader(parent, text)
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetText(text)
    return header
end

-- Create divider line
function BLU.Widgets:CreateDivider(parent, width)
    local divider = parent:CreateTexture(nil, "OVERLAY")
    divider:SetHeight(1)
    divider:SetWidth(width or 550)
    divider:SetColorTexture(0.3, 0.3, 0.3, 0.5)
    return divider
end