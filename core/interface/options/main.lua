--=====================================================================================
-- BLU - interface/options/main.lua
-- Main options panel logic
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

-- Create options module
local Options = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["options"] = Options

local OPTIONS_PANEL_NAME = "Better Level-Up!"
local OPTIONS_LIST_STYLED_NAME = "|TInterface\\AddOns\\BLU\\media\\Textures\\icon.tga:16:16|t |cff05dffaB|r|cffffffffetter |cff05dffaL|r|cffffffffevel-|cff05dffaU|r|cffffffffp|cff05dffa!|r"

function Options:ResolveOptionsCategoryID()
    if type(BLU.OptionsCategoryID) == "number" then
        return BLU.OptionsCategoryID
    end

    local category = BLU.OptionsCategory
    if Settings and Settings.GetCategory and BLU.OptionsPanel then
        local settingsCategory = Settings.GetCategory(BLU.OptionsPanel.settingsCategoryName or BLU.OptionsPanel.name)
        if not settingsCategory then
            settingsCategory = Settings.GetCategory(BLU.OptionsPanel.name)
        end
        if settingsCategory then
            category = settingsCategory
        end
    end
    if not category then
        return nil
    end

    local categoryID = nil
    if type(category.GetID) == "function" then
        categoryID = category:GetID()
    else
        categoryID = category.ID
    end

    if type(categoryID) ~= "number" and type(category.GetOrder) == "function" then
        local repairedID = category:GetOrder()
        if type(repairedID) == "number" then
            categoryID = repairedID
        end
    end

    if type(categoryID) == "number" then
        BLU.OptionsCategoryID = categoryID
        return categoryID
    end

    return nil
end

-- Create main options panel
function Options:CreateOptionsPanel()
    BLU:PrintDebug("Creating new options panel...")

    if not BLU.db then
        BLU:PrintError("Cannot create options panel: Database not available")
        return nil
    end

    local panel = CreateFrame("Frame", "BLUOptionsPanel", UIParent, "BackdropTemplate")
    panel.name = OPTIONS_PANEL_NAME
    panel.settingsCategoryName = OPTIONS_LIST_STYLED_NAME
    BLU.OptionsPanel = panel

    local container = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    container:SetPoint("TOPLEFT", 0, 0)
    container:SetPoint("BOTTOMRIGHT", 0, 0)
    container:SetBackdrop(BLU.Modules.design.Backdrops.Dark)
    container:SetBackdropColor(0.05, 0.07, 0.10, 0.95)
    container:SetBackdropBorderColor(0.10, 0.18, 0.24, 1)

    local header = CreateFrame("Frame", nil, container, "BackdropTemplate")
    header:SetHeight(66)
    header:SetPoint("TOPLEFT", 8, -8)
    header:SetPoint("TOPRIGHT", -8, -8)
    header:SetBackdrop(BLU.Modules.design.Backdrops.Dark)
    header:SetBackdropColor(0.07, 0.10, 0.14, 0.95)
    header:SetBackdropBorderColor(0.12, 0.22, 0.30, 1)

    local headerAccent = header:CreateTexture(nil, "ARTWORK")
    headerAccent:SetHeight(2)
    headerAccent:SetPoint("BOTTOMLEFT", 8, 0)
    headerAccent:SetPoint("BOTTOMRIGHT", -8, 0)
    headerAccent:SetColorTexture(unpack(BLU.Modules.design.Colors.Primary))

    local logo = header:CreateTexture(nil, "ARTWORK")
    logo:SetSize(40, 40)
    logo:SetPoint("LEFT", 10, 0)
    logo:SetTexture("Interface\\AddOns\\BLU\\media\\Textures\\icon.tga")

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", logo, "RIGHT", 10, 5)
    title:SetText("|cff05dffaBLU|r - Better Level-Up!")

    local subtitle = header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
    subtitle:SetText("Iconic game sounds for World of Warcraft events")
    subtitle:SetTextColor(0.7, 0.7, 0.7)

    local version = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    version:SetPoint("TOPRIGHT", -15, -15)
    local metadataVersion = (C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata("BLU", "Version"))
        or (GetAddOnMetadata and GetAddOnMetadata("BLU", "Version"))
        or BLU.version
        or "v6.0.0-alpha.6"
    version:SetText(metadataVersion)
    version:SetTextColor(unpack(BLU.Modules.design.Colors.Primary))

    local author = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    author:SetPoint("TOP", version, "BOTTOM", 0, -2)
    author:SetText("by donniedice")
    author:SetTextColor(0.7, 0.7, 0.7)

    local branding = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    branding:SetPoint("BOTTOMRIGHT", -15, 10)
    branding:SetText("|cffffd700RGX Mods|r")

    local tabContainer = CreateFrame("Frame", nil, container)
    tabContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -4)
    tabContainer:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -4)
    tabContainer:SetHeight(62)

    local tabBg = tabContainer:CreateTexture(nil, "BACKGROUND")
    tabBg:SetAllPoints()
    tabBg:SetColorTexture(0.03, 0.03, 0.03, 0.6)

    panel.tabs = {}
    panel.contents = {}

    local tabs = BLU.OptionsTabs
    if not tabs then
        BLU:PrintError("BLU.OptionsTabs not defined")
        return panel
    end

    for i, tabInfo in ipairs(tabs) do
        local tab = BLU.CreateTabButton(tabContainer, tabInfo.text, i, tabInfo.row, tabInfo.col, panel)
        panel.tabs[i] = tab

        local content = CreateFrame("Frame", nil, container, "BackdropTemplate")
        content:SetPoint("TOPLEFT", tabContainer, "BOTTOMLEFT", 8, -8)
        content:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -8, 8)
        content:SetBackdrop(BLU.Modules.design.Backdrops.Dark)
        content:SetBackdropColor(0.06, 0.06, 0.06, 0.95)
        content:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
        content:Hide()

        if tabInfo.create then
            local success, err = pcall(tabInfo.create, content)
            if not success then BLU:PrintError("Error creating content for " .. tabInfo.text .. ": " .. tostring(err)) end
        elseif tabInfo.eventType then
            local success, err = pcall(BLU.CreateEventSoundPanel, content, tabInfo.eventType, tabInfo.text)
            if not success then BLU:PrintError("Error creating event panel for " .. tabInfo.text .. ": " .. tostring(err)) end
        end
        panel.contents[i] = content
    end

    function panel:SelectTab(index)
        for i, tab in ipairs(self.tabs) do
            if self.tabs[i] and self.contents[i] then
                self.tabs[i]:SetActive(i == index)
                self.contents[i]:SetShown(i == index)
            end
        end
    end

    if #panel.tabs > 0 then
        panel:SelectTab(1)
    end

    local category
    if Settings and Settings.RegisterCanvasLayoutCategory then
        category = Settings.RegisterCanvasLayoutCategory(panel, panel.settingsCategoryName or panel.name)
        Settings.RegisterAddOnCategory(category)
        BLU.OptionsCategory = category
        self:ResolveOptionsCategoryID()
    else
        panel.name = panel.settingsCategoryName or panel.name
        InterfaceOptions_AddCategory(panel)
        BLU.OptionsCategory = panel
    end

    return panel
end

-- Open options
function Options:OpenOptions()
    if not BLU.db or not BLU.db.profile then
        BLU:Print("Database not ready. Please wait a moment and try again.")
        return
    end

    if not BLU.OptionsPanel then
        self:CreateOptionsPanel()
    end

    if not BLU.OptionsCategory then
        BLU:Print("Options panel not properly registered.")
        return
    end

    local opened = false
    local categoryID = self:ResolveOptionsCategoryID()

    if Settings and Settings.OpenToCategory and type(categoryID) == "number" then
        local ok = pcall(Settings.OpenToCategory, categoryID)
        opened = ok
    end

    if not opened and C_SettingsUtil and C_SettingsUtil.OpenSettingsPanel and type(categoryID) == "number" then
        local ok = pcall(C_SettingsUtil.OpenSettingsPanel, categoryID)
        opened = ok
    end

    if not opened and SettingsPanel and SettingsPanel.OpenToCategory and type(categoryID) == "number" then
        local ok = pcall(SettingsPanel.OpenToCategory, SettingsPanel, categoryID)
        opened = ok
    end

    if not opened and Settings and Settings.OpenToCategory and BLU.OptionsPanel then
        local categoryName = BLU.OptionsPanel.settingsCategoryName or BLU.OptionsPanel.name
        if categoryName then
            local ok = pcall(Settings.OpenToCategory, categoryName)
            opened = ok
        end
    end

    if not opened and InterfaceOptionsFrame_OpenToCategory and BLU.OptionsPanel then
        local okFirst = pcall(InterfaceOptionsFrame_OpenToCategory, BLU.OptionsPanel)
        local okSecond = pcall(InterfaceOptionsFrame_OpenToCategory, BLU.OptionsPanel)
        opened = okFirst or okSecond
    end

    if not opened then
        if SettingsPanel then
            SettingsPanel:Show()
            opened = true
        elseif InterfaceOptionsFrame then
            InterfaceOptionsFrame:Show()
            opened = true
        end
    end

    if not opened then
        BLU:Print("Unable to open options panel")
    end
end

function Options:Init()
    BLU:PrintDebug("Options:Init() called, registering OpenOptions.")
    BLU.CreateOptionsPanel = function()
        return self:CreateOptionsPanel()
    end
    BLU.OpenOptions = function()
        return self:OpenOptions()
    end
end

function Options:Cleanup()
end

if BLU.RegisterModule then
    BLU:RegisterModule(Options, "options", "Options Interface")
end
