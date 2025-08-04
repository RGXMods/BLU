--=====================================================================================
-- BLU - interface/design.lua
-- Design constants and styling following SimpleQuestPlates pattern
--=====================================================================================

local addonName, BLU = ...

BLU.Design = {
    -- Brand colors
    Colors = {
        Primary = {0.02, 0.37, 1, 1},        -- BLU blue: #05dffa
        PrimaryHex = "|cff05dffa",
        Background = {0.02, 0.02, 0.02, 0.95},  -- Almost black
        Panel = {0.03, 0.03, 0.03, 0.9},        -- Slightly lighter
        Border = {0.02, 0.37, 1, 0.5},          -- BLU blue translucent
        Text = {1, 1, 1, 1},                    -- White
        TextMuted = {0.7, 0.7, 0.7, 1},        -- Gray
        Success = {0.34, 0.74, 0.36, 1},       -- Green
        Warning = {1, 0.82, 0, 1},              -- Yellow
        Error = {1, 0.2, 0.2, 1},               -- Red
    },
    
    -- Backdrop templates
    Backdrops = {
        Dark = {
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = false,
            tileSize = 0,
            edgeSize = 1,
            insets = {left = 1, right = 1, top = 1, bottom = 1}
        },
        Panel = {
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = {left = 11, right = 12, top = 12, bottom = 11}
        },
        Tooltip = {
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        }
    },
    
    -- Layout constants
    Layout = {
        PanelWidth = 700,
        PanelHeight = 600,
        HeaderHeight = 100,
        TabHeight = 32,
        Padding = 20,
        Spacing = 10,
        ColumnGap = 20,
    },
    
    -- Font styles
    Fonts = {
        Large = "GameFontNormalLarge",
        Normal = "GameFontNormal",
        Small = "GameFontNormalSmall",
        Highlight = "GameFontHighlight",
        Huge = "GameFontNormalHuge",
    }
}

-- Helper function to apply backdrop with color
function BLU.Design:ApplyBackdrop(frame, backdropType, bgColor, borderColor)
    if not frame.SetBackdrop then
        Mixin(frame, BackdropTemplateMixin)
    end
    
    frame:SetBackdrop(self.Backdrops[backdropType] or self.Backdrops.Dark)
    
    if bgColor then
        frame:SetBackdropColor(unpack(bgColor))
    else
        frame:SetBackdropColor(unpack(self.Colors.Background))
    end
    
    if borderColor then
        frame:SetBackdropBorderColor(unpack(borderColor))
    else
        frame:SetBackdropBorderColor(unpack(self.Colors.Border))
    end
end

-- Create styled header
function BLU.Design:CreateHeader(parent, text, icon)
    local header = CreateFrame("Frame", nil, parent)
    header:SetHeight(30)
    
    if icon then
        local iconTex = header:CreateTexture(nil, "ARTWORK")
        iconTex:SetSize(24, 24)
        iconTex:SetPoint("LEFT", 0, 0)
        iconTex:SetTexture(icon)
        
        local title = header:CreateFontString(nil, "OVERLAY", self.Fonts.Large)
        title:SetPoint("LEFT", iconTex, "RIGHT", 5, 0)
        title:SetText(self.Colors.PrimaryHex .. text .. "|r")
        header.title = title
    else
        local title = header:CreateFontString(nil, "OVERLAY", self.Fonts.Large)
        title:SetPoint("LEFT", 0, 0)
        title:SetText(self.Colors.PrimaryHex .. text .. "|r")
        header.title = title
    end
    
    -- Divider line
    local divider = header:CreateTexture(nil, "BACKGROUND")
    divider:SetHeight(1)
    divider:SetPoint("TOPLEFT", 0, -25)
    divider:SetPoint("TOPRIGHT", 0, -25)
    divider:SetColorTexture(unpack(self.Colors.Border))
    
    return header
end

-- Create styled button
function BLU.Design:CreateButton(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width or 120, height or 25)
    button:SetText(text)
    
    -- Custom highlight
    button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    
    return button
end

-- Create styled checkbox
function BLU.Design:CreateCheckbox(parent, label, tooltip)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetHeight(24)
    
    local check = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
    check:SetPoint("LEFT", 0, 0)
    
    local text = frame:CreateFontString(nil, "OVERLAY", self.Fonts.Normal)
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

-- Create section container
function BLU.Design:CreateSection(parent, title, icon)
    local section = CreateFrame("Frame", nil, parent)
    self:ApplyBackdrop(section, "Dark", self.Colors.Panel)
    
    if title then
        local header = self:CreateHeader(section, title, icon)
        header:SetPoint("TOPLEFT", 10, -10)
        header:SetPoint("TOPRIGHT", -10, -10)
        section.header = header
        section.content = CreateFrame("Frame", nil, section)
        section.content:SetPoint("TOPLEFT", 10, -45)
        section.content:SetPoint("BOTTOMRIGHT", -10, 10)
    else
        section.content = CreateFrame("Frame", nil, section)
        section.content:SetPoint("TOPLEFT", 10, -10)
        section.content:SetPoint("BOTTOMRIGHT", -10, 10)
    end
    
    return section
end