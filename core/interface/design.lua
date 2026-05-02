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
    Primary = {0.02, 0.87, 0.98},      -- #05DFFA (BLU cyan)
    PrimaryHex = "cff05dffa",
    Secondary = {1.0, 0.84, 0.0},      -- #FFD700 (RGX gold)
    Accent = {0.08, 0.22, 0.30},       -- Deep cyan accent
    Surface = {0.07, 0.09, 0.12},      -- Panel surface
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
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    },
    
    Light = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    },
    
    Button = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    },
    
    Solid = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        edgeSize = 1,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    },

    Panel = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
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
    frame:SetBackdropColor(unpack(Design.Colors.Surface))
    frame:SetBackdropBorderColor(unpack(Design.Colors.Accent))
    
    return frame
end

-- Helper function to create styled buttons
function Design:CreateStyledButton(parent, text, width, height)
    return self:CreateActionButton(parent, text, width, height)
end

-- Action button — matches tab button visual system (bg texture + border frame + text)
-- Optional tooltip: pass tooltipTitle and tooltipBody on the returned button, or call
-- button:SetTooltip(title, body) after creation.
function Design:CreateActionButton(parent, text, width, height, tooltipTitle, tooltipBody)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width or 120, height or 22)

    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.08, 0.11, 0.15, 0.90)
    button.bg = bg

    local border = CreateFrame("Frame", nil, button, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    border:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
    button.border = border

    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER", 0, 0)
    label:SetText(text or "Button")
    label:SetTextColor(0.80, 0.80, 0.80, 1)
    button.label = label

    local function applyHover(self)
        self.bg:SetColorTexture(0.11, 0.18, 0.24, 1)
        self.border:SetBackdropBorderColor(unpack(Design.Colors.Primary))
        self.label:SetTextColor(unpack(Design.Colors.Primary))
    end
    local function applyIdle(self)
        self.bg:SetColorTexture(0.08, 0.11, 0.15, 0.90)
        self.border:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
        self.label:SetTextColor(0.80, 0.80, 0.80, 1)
    end

    button:SetScript("OnEnter", function(self)
        applyHover(self)
        if self._ttTitle then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self._ttTitle, unpack(Design.Colors.Primary))
            if self._ttBody then
                GameTooltip:AddLine(" ")
                for line in tostring(self._ttBody):gmatch("[^\n]+") do
                    local color = {0.88, 0.88, 0.88}
                    local lower = string.lower(line)

                    if string.find(lower, "type ", 1, true) or string.find(lower, "enter ", 1, true) then
                        color = Design.Colors.Secondary
                    elseif string.find(lower, "full interface", 1, true) or string.find(lower, "full path", 1, true) then
                        color = {0.72, 0.84, 1.0}
                    elseif string.find(lower, "automatically", 1, true) or string.find(lower, "search", 1, true) then
                        color = {0.60, 0.88, 0.70}
                    end

                    GameTooltip:AddLine(line, color[1], color[2], color[3], true)
                end
            end
            GameTooltip:Show()
        end
    end)
    button:SetScript("OnLeave", function(self)
        applyIdle(self)
        GameTooltip:Hide()
    end)

    function button:SetTooltip(title, body)
        self._ttTitle = title
        self._ttBody = body
    end

    if tooltipTitle then
        button:SetTooltip(tooltipTitle, tooltipBody)
    end

    return button
end

-- Helper function to create section headers
function Design:CreateSectionHeader(parent, text, icon)
    local header = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    header:SetHeight(32)
    header:SetBackdrop(Design.Backdrops.Solid)
    header:SetBackdropColor(0.09, 0.12, 0.16, 0.95)
    header:SetBackdropBorderColor(unpack(Design.Colors.Accent))

    local leftInset = 10
    if icon then
        local iconTexture = header:CreateTexture(nil, "ARTWORK")
        iconTexture:SetSize(16, 16)
        iconTexture:SetPoint("LEFT", 8, 0)
        iconTexture:SetTexture(icon)
        leftInset = 30
    end
    
    local label = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", leftInset, 0)
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

    UIDropDownMenu_Initialize(dropdown, function(self, level)
        level = level or 1
        local dd = BLU.Modules and BLU.Modules.dropdown
        if dd and dd.ResetLevel then
            dd:ResetLevel(level)
        end

        for _, value in ipairs(values) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = value
            info.value = value
            info.func = function()
                UIDropDownMenu_SetSelectedValue(dropdown, value)
            end
            UIDropDownMenu_AddButton(info)
            if dd and dd.StyleLastAddedButton then
                dd:StyleLastAddedButton(level, {minWidth = 140})
            end
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
        header:SetPoint("TOPLEFT", 10, -8)
        header:SetPoint("TOPRIGHT", -10, -8)
        section.header = header
        section.content = CreateFrame("Frame", nil, section)
        section.content:SetPoint("TOPLEFT", 16, -42)
        section.content:SetPoint("BOTTOMRIGHT", -16, 12)
    else
        section.content = CreateFrame("Frame", nil, section)
        section.content:SetPoint("TOPLEFT", 16, -10)
        section.content:SetPoint("BOTTOMRIGHT", -16, 10)
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
