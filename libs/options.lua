-- libs/options.lua
local options = {}

local function create_options_panel(addon)
    local frame = CreateFrame("Frame", addon.name .. "OptionsFrame", UIParent)
    frame:SetSize(600, 400)
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

BLULib = BLULib or {}
BLULib.Options = options
