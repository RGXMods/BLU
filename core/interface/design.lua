--=====================================================================================
-- BLU - interface/design.lua
-- Design system with colors, backdrops, and styling
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

-- Create design module
local Design = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["design"] = Design
BLU.Design = Design

-- Color palette
Design.Colors = {
    Primary = {0.02, 0.47, 0.98},      -- #05DFFA (BLU cyan)
    PrimaryHex = "cff05dffa",
    Secondary = {1.0, 0.84, 0.0},       -- #FFD700 (RGX gold)
    Success = {0.0, 0.8, 0.0},          -- Green
    Warning = {1.0, 0.65, 0.0},         -- Orange
    Error = {1.0, 0.2, 0.2},            -- Red
    Dark = {0.05, 0.05, 0.05},          -- Almost black
    Light = {0.9, 0.9, 0.9},            -- Almost white
    Gray = {0.5, 0.5, 0.5},             -- Gray
    Text = {1.0, 1.0, 1.0},             -- White
}

-- Backdrop templates
Design.Backdrops = {
    Dark = {
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {left = 11, right = 12, top = 12, bottom = 11}
    },
    
    Light = {
        bgFile = "Interface\Tooltips\UI-Tooltip-Background",
        edgeFile = "Interface\Tooltips\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    },
    
    Button = {
        bgFile = "Interface\Tooltips\UI-Tooltip-Background",
        edgeFile = "Interface\Buttons\WHITE8x8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    },
    
    Solid = {
        bgFile = "Interface\Tooltips\UI-Tooltip-Background",
        edgeFile = "Interface\Buttons\WHITE8x8",
        tile = false,
        edgeSize = 1,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    },

    Panel = {
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {left = 11, right = 12, top = 12, bottom = 11}
    }
}

-- Layout constants
Design.Layout = {
    Spacing = 10,
    Padding = 15,
}

-- Font objects
Design.Fonts = {
    Title = "GameFontNormalLarge",
    Normal = "GameFontNormal",
    Small = "GameFontNormalSmall",
    Highlight = "GameFontHighlight",
}

-- Convert RGB (0-1) to Hex string
function Design:RGBToHex(r, g, b)
    return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

-- Helper function to create styled frames
function Design:CreateStyledFrame(parent, width, height, template)
    template = template or "Dark"
    
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    if width then frame:SetWidth(width) end
    if height then frame:SetHeight(height) end
    
    local backdrop = Design.Backdrops[template] or Design.Backdrops.Dark
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    return frame
end

-- Helper function to create styled buttons
function Design:CreateStyledButton(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width or 120, height or 30)
    
    button:SetBackdrop(Design.Backdrops.Button)
    button:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
    button:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("CENTER")
    label:SetText(text or "Button")
    button.label = label
    
    -- Hover effects
    button:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.25, 0.25, 0.25, 1)
        self:SetBackdropBorderColor(unpack(Design.Colors.Primary))
    end)
    
    button:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
        self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    end)
    
    return button
end

-- Helper function to create section headers
function Design:CreateSectionHeader(parent, text)
    local header = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    header:SetHeight(30)
    header:SetBackdrop(Design.Backdrops.Solid)
    header:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    header:SetBackdropBorderColor(unpack(Design.Colors.Primary))
    
    local label = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", 10, 0)
    label:SetText(text)
    label:SetTextColor(unpack(Design.Colors.Primary))
    header.label = label
    
    return header
end

-- Helper function to create dividers
function Design:CreateDivider(parent)
    local divider = parent:CreateTexture(nil, "ARTWORK")
    divider:SetHeight(1)
    divider:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    return divider
end

function Design:ApplyBackdrop(frame, template, bgColor, borderColor)
    template = template or "Dark"
    local backdrop = self.Backdrops[template] or self.Backdrops.Dark
    frame:SetBackdrop(backdrop)
    if bgColor then
        frame:SetBackdropColor(unpack(bgColor))
    end
    if borderColor then
        frame:SetBackdropBorderColor(unpack(borderColor))
    end
end

function Design:CreateCheckbox(parent, label, tooltip)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetHeight(24)
    
    local check = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
    check:SetPoint("LEFT", 0, 0)
    
    local text = frame:CreateFontString(nil, "OVERLAY", Design.Fonts.Normal)
    text:SetPoint("LEFT", check, "RIGHT", 5, 0)
    text:SetText(label)
    
    frame.check = check
    frame.text = text
    
    if tooltip then
        check:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(label, 1, 1, 1)
            GameTooltip:AddLine(tooltip, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        check:SetScript("OnLeave", GameTooltip_Hide)
    end
    
    -- Auto-size frame
    frame:SetWidth(check:GetWidth() + 5 + text:GetStringWidth())
    
    return frame
end

function Design:CreateSlider(parent, label, tooltip, min, max, step)
    local frame = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    frame:SetMinMaxValues(min, max)
    frame:SetValueStep(step)
    frame:SetObeyStepOnDrag(true)
    frame.Low:SetText(min)
    frame.High:SetText(max)
    frame.Text:SetText(label)

    if tooltip then
        frame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(label, 1, 1, 1)
            GameTooltip:AddLine(tooltip, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", GameTooltip_Hide)
    end

    return frame
end

function Design:CreateDropdown(parent, label, values)
    local container = CreateFrame("Frame", nil, parent)
    container:SetHeight(45)
    
    -- Label
    local labelText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelText:SetPoint("TOPLEFT", 0, 0)
    labelText:SetText(label)
    labelText:SetTextColor(unpack(Design.Colors.Text))
    
    -- Dropdown with better styling
    -- Create dropdown with a unique name to avoid nil errors
    self.dropdownCounter = (self.dropdownCounter or 0) + 1
    local dropdownName = "BLUDropdown" .. self.dropdownCounter
    local dropdown = CreateFrame("Frame", dropdownName, container, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", labelText, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(dropdown, 200)

    UIDropDownMenu_Initialize(dropdown, function(self) 
        for _, value in ipairs(values) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = value
            info.value = value
            info.func = function()
                UIDropDownMenu_SetSelectedValue(dropdown, value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    UIDropDownMenu_SetSelectedValue(dropdown, values[1])
    
    container.label = labelText
    container.dropdown = dropdown
    
    return container
end

function Design:CreateSection(parent, title, icon)
    local section = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    self:ApplyBackdrop(section, "Panel", {0.03, 0.03, 0.03, 0.6}, {0.1, 0.1, 0.1, 1})
    
    if title then
        local header = self:CreateHeader(section, title, icon)
        header:SetPoint("TOPLEFT", 8, -8)
        header:SetPoint("TOPRIGHT", -8, -8)
        section.header = header
        section.content = CreateFrame("Frame", nil, section)
        section.content:SetPoint("TOPLEFT", 15, -32)
        section.content:SetPoint("BOTTOMRIGHT", -15, 8)
    else
        section.content = CreateFrame("Frame", nil, section)
        section.content:SetPoint("TOPLEFT", 15, -8)
        section.content:SetPoint("BOTTOMRIGHT", -15, 8)
    end
    
    return section
end

function Design:Init()
    BLU:PrintDebug("[Design] Initializing design system")
    
    -- Verify all components are loaded
    if not Design then
        BLU:PrintError("[Design] Design not initialized!")
        return
    end
    
    if not Design.Colors then
        BLU:PrintError("[Design] Design.Colors not initialized!")
        return
    end
    
    if not Design.Backdrops then
        BLU:PrintError("[Design] Design.Backdrops not initialized!")
        return
    end
    
    BLU:PrintDebug("[Design] Design system initialized successfully")

    -- Alias for backward compatibility
    Design.CreateButton = Design.CreateStyledButton
    Design.CreateHeader = Design.CreateSectionHeader
end

-- Register module
if BLU.RegisterModule then
    BLU:RegisterModule(Design, "design", "Design System")
end
