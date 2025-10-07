-- libs/options.lua
local options = {}

local function create_options_panel(addon)
    local frame = CreateFrame("Frame", addon.name .. "OptionsFrame", UIParent)
    frame:SetSize(600, 800) -- Increased height to accommodate all options
    frame:SetPoint("CENTER")
    frame:SetBackdrop({ bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 } })
    frame:SetBackdropColor(0, 0, 0, 1)
    frame:Hide()

    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -20)
    title:SetText(addon.name .. " Options")

    addon.optionsFrame = frame
end

function options:Create(addon)
    create_options_panel(addon)
end

function options:CreateGroup(parent, name, yOffset, color)
    local group = CreateFrame("Frame", parent:GetName() .. name .. "Group", parent)
    group:SetSize(560, 100)
    group:SetPoint("TOPLEFT", 20, yOffset)

    local label = group:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    label:SetPoint("TOPLEFT", 0, 0)
    label:SetText(color .. name .. "|r")

    return group
end

function options:CreateDropdown(parent, name, values, get, set)
    local dropdown = CreateFrame("Frame", parent:GetName() .. name, parent, "UIDropDownMenuTemplate")
    dropdown.name = name

    local function on_select(self, value)
        set(value)
    end

    UIDropDownMenu_Initialize(dropdown, function(self, level)
        for key, value in pairs(values) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = value
            info.value = key
            info.func = function(self)
                on_select(self, self.value)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    UIDropDownMenu_SetSelectedValue(dropdown, get())

    return dropdown
end

function options:CreateButton(parent, name, func)
    local button = CreateFrame("Button", parent:GetName() .. name, parent, "UIPanelButtonTemplate")
    button:SetSize(32, 32)
    button:SetNormalTexture("Interface/Buttons/UI-PlayButton-Up")
    button:SetPushedTexture("Interface/Buttons/UI-PlayButton-Down")
    button:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight")
    button:SetScript("OnClick", func)
    return button
end

function options:CreateSlider(parent, name, min, max, step, get, set)
    local slider = CreateFrame("Slider", parent:GetName() .. name, parent, "OptionsSliderTemplate")
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetValue(get())

    _G[slider:GetName() .. "Text"]:SetText(string.format("%.2f", get()))
    _G[slider:GetName() .. "Low"]:SetText(min)
    _G[slider:GetName() .. "High"]:SetText(max)
    _G[slider:GetName() .. "Label"]:SetText(name)

    slider:SetScript("OnValueChanged", function(self, value)
        set(value)
        _G[self:GetName() .. "Text"]:SetText(string.format("%.2f", value))
    end)

    return slider
end

BLULib = BLULib or {}
BLULib.Options = options
