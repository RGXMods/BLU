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

-- Create main options panel
function Options:CreateOptionsPanel()
    BLU:PrintDebug("Creating new options panel...")

    if not BLU.db then
        BLU:PrintError("Cannot create options panel: Database not available")
        return nil
    end

    local panel = CreateFrame("Frame", "BLUOptionsPanel", UIParent, "BackdropTemplate")
    panel.name = "Better Level-Up!"
    BLU.OptionsPanel = panel

    local container = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    container:SetPoint("TOPLEFT", 0, 0)
    container:SetPoint("BOTTOMRIGHT", 0, 0)
    container:SetBackdrop(BLU.Modules.design.Backdrops.Dark)
    container:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    container:SetBackdropBorderColor(unpack(BLU.Modules.design.Colors.Primary))

    local header = CreateFrame("Frame", nil, container, "BackdropTemplate")
    header:SetHeight(60)
    header:SetPoint("TOPLEFT", 5, -5)
    header:SetPoint("TOPRIGHT", -5, -5)
    header:SetBackdrop(BLU.Modules.design.Backdrops.Dark)
    header:SetBackdropColor(0.08, 0.08, 0.08, 0.8)
    header:SetBackdropBorderColor(unpack(BLU.Modules.design.Colors.Primary))

    local logo = header:CreateTexture(nil, "ARTWORK")
    logo:SetSize(40, 40)
    logo:SetPoint("LEFT", 10, 0)
    logo:SetTexture("Interface\\AddOns\\BLU\\media\\images\\icon")

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", logo, "RIGHT", 10, 5)
    title:SetText("|cff05dffaBLU|r - Better Level-Up!")

    local subtitle = header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
    subtitle:SetText("Iconic game sounds for World of Warcraft events")
    subtitle:SetTextColor(0.7, 0.7, 0.7)

    local version = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    version:SetPoint("TOPRIGHT", -15, -15)
    version:SetText(BLU.version or "v6.0.0-alpha")
    version:SetTextColor(unpack(BLU.Modules.design.Colors.Primary))

    local author = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    author:SetPoint("TOP", version, "BOTTOM", 0, -2)
    author:SetText("by donniedice")
    author:SetTextColor(0.7, 0.7, 0.7)

    local branding = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    branding:SetPoint("BOTTOMRIGHT", -15, 10)
    branding:SetText("|cffffd700RGX Mods|r")

    local tabContainer = CreateFrame("Frame", nil, container)
    tabContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -2)
    tabContainer:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -2)
    tabContainer:SetHeight(60)

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
        content:SetPoint("TOPLEFT", tabContainer, "BOTTOMLEFT", 0, -10)
        content:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -10, 10)
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
        category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
        BLU.OptionsCategory = category
    else
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

    if Settings and Settings.OpenToCategory and BLU.OptionsCategory and BLU.OptionsCategory.ID then
        Settings.OpenToCategory(BLU.OptionsCategory.ID)
    elseif InterfaceOptionsFrame_OpenToCategory and BLU.OptionsCategory then
        InterfaceOptionsFrame_OpenToCategory(BLU.OptionsCategory)
    else
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
