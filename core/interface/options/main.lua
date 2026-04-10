--=====================================================================================
-- BLU - interface/options/main.lua
-- Main options panel logic
--=====================================================================================

local addonName = ...
local ADDON_PATH = "Interface\\AddOns\\" .. addonName .. "\\"
local BLU = _G["BLU"]
local Tabs = BLU.Modules and BLU.Modules["tabs"]

-- Layout Constants
local TAB_BUTTON_WIDTH_CORE = 94

-- Create options module
local Options = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["options"] = Options

local function GetAddOnMetadataSafe(addonName, key)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        local ok, value = pcall(C_AddOns.GetAddOnMetadata, addonName, key)
        return ok and value or nil
    elseif GetAddOnMetadata then
        local ok, value = pcall(GetAddOnMetadata, addonName, key)
        return ok and value or nil
    end
    return nil
end

local OPTIONS_PANEL_NAME = "Better Level-Up!"
local OPTIONS_LIST_STYLED_NAME = "|T" .. ADDON_PATH .. "media\\Textures\\icon:16:16:0:0|t |cff05dffaB|r|cffffffffetter |cff05dffaL|r|cffffffffevel-|cff05dffaU|r|cffffffffp|cff05dffa!|r"

function Options:ResolveOptionsCategoryID()
    BLU:PrintDebug("[Options] ResolveOptionsCategoryID called")
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
    header:SetHeight(52)
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
    logo:SetSize(28, 28)
    logo:SetPoint("LEFT", 10, 0)
    logo:SetTexture(ADDON_PATH .. "media\\Textures\\icon.tga")

    local leftX = 50
    local rightX = -15
    local rowOneY = -14
    local rowTwoY = -26
    local rowThreeY = -38

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", header, "TOPLEFT", leftX, rowOneY)
    title:SetText("|cff05dffaB|r|cffffffffetter |cff05dffaL|r|cffffffffevel-|cff05dffaU|r|cffffffffp|cff05dffa!|r")
    title:SetJustifyV("MIDDLE")

    local subtitle = header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    subtitle:SetPoint("LEFT", header, "TOPLEFT", leftX, rowTwoY)
    subtitle:SetText("Iconic game sounds for World of Warcraft events")
    subtitle:SetTextColor(0.7, 0.7, 0.7)
    subtitle:SetJustifyV("MIDDLE")

    local discord = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    discord:SetPoint("LEFT", header, "TOPLEFT", leftX, rowThreeY)
    discord:SetText("|cff7289daDiscord:|r |cffffd700discord.gg/N7kdKAHVVF|r")
    discord:SetTextColor(0.85, 0.85, 0.85)
    discord:SetJustifyV("MIDDLE")

    local version = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    version:SetPoint("RIGHT", header, "TOPRIGHT", rightX, rowOneY)
    local metadataVersion = GetAddOnMetadataSafe(addonName, "Version") or BLU.version or "v6.0.0"
    version:SetText(metadataVersion)
    version:SetTextColor(unpack(BLU.Modules.design.Colors.Primary))
    version:SetJustifyH("RIGHT")
    version:SetJustifyV("MIDDLE")

    local author = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    author:SetPoint("RIGHT", header, "TOPRIGHT", rightX, rowTwoY)
    author:SetText("by donniedice")
    author:SetTextColor(0.7, 0.7, 0.7)
    author:SetJustifyH("RIGHT")
    author:SetJustifyV("MIDDLE")

    local branding = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    branding:SetPoint("RIGHT", header, "TOPRIGHT", rightX, rowThreeY)
    branding:SetText("|cff8b4b5cRGX|r |cffffd700Mods|r")
    branding:SetJustifyH("RIGHT")
    branding:SetJustifyV("MIDDLE")

    local tabContainer = CreateFrame("Frame", nil, container)
    tabContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -2)
    tabContainer:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -2)
    local tabContainerHeight = (Tabs and Tabs.GetContainerHeight and Tabs:GetContainerHeight()) or 62
    tabContainer:SetHeight(tabContainerHeight)

    local tabBg = tabContainer:CreateTexture(nil, "BACKGROUND")
    tabBg:SetAllPoints()
    tabBg:SetColorTexture(0.03, 0.03, 0.03, 0.6)

    local leftTabGroup = CreateFrame("Frame", nil, tabContainer, "BackdropTemplate")
    leftTabGroup:SetPoint("TOPLEFT", tabContainer, "TOPLEFT", 5, -4)
    leftTabGroup:SetSize(100, tabContainerHeight - 8)
    leftTabGroup:SetBackdrop(BLU.Modules.design.Backdrops.Dark)
    leftTabGroup:SetBackdropColor(0.06, 0.08, 0.12, 0.95)
    leftTabGroup:SetBackdropBorderColor(0.15, 0.25, 0.35, 1)

    local leftSeparator = tabContainer:CreateTexture(nil, "OVERLAY")
    leftSeparator:SetSize(2, tabContainerHeight - 12)
    leftSeparator:SetPoint("TOPLEFT", leftTabGroup, "TOPRIGHT", 5, -2)
    leftSeparator:SetColorTexture(0.12, 0.16, 0.22, 0.85)

    panel.tabs = {}
    panel.contents = {}

    local tabs = BLU.OptionsTabs
    if not tabs then
        BLU:PrintError("BLU.OptionsTabs not defined")
        return panel
    end

    for i, tabInfo in ipairs(tabs) do
        BLU:PrintDebug("[Options] Creating tab content for '" .. tostring(tabInfo.text) .. "'")
        local tab = BLU.CreateTabButton(tabContainer, tabInfo.text, i, tabInfo.row, tabInfo.col, panel, tabInfo.icon)
        if tabInfo.placeholder then
            tab:SetPlaceholder(true)
        end
        panel.tabs[i] = tab

        local content = CreateFrame("Frame", nil, container, "BackdropTemplate")
        content:SetPoint("TOPLEFT", tabContainer, "BOTTOMLEFT", 1, -8)
        content:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -7, 8)
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
        elseif tabInfo.placeholder then
            local placeholderMessage = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            placeholderMessage:SetPoint("TOPLEFT", 18, -18)
            placeholderMessage:SetText("|cff778899Reserved for a future options panel.|r")
            placeholderMessage:SetJustifyH("LEFT")
        end
        panel.contents[i] = content
    end

    function panel:SelectTab(index)
        BLU:PrintDebug("[Options] Selecting tab index " .. tostring(index))
        for i, tab in ipairs(self.tabs) do
            if self.tabs[i] and self.contents[i] then
                self.tabs[i]:SetActive(i == index)
                self.contents[i]:SetShown(i == index)
                if i == index and type(self.contents[i].Refresh) == "function" then
                    local success, err = pcall(self.contents[i].Refresh, self.contents[i])
                    if not success then
                        BLU:PrintError("Error refreshing content for " .. tostring(tabs[i] and tabs[i].text or i) .. ": " .. tostring(err))
                    end
                end
            end
        end
    end

    if #panel.tabs > 0 then
        panel:SelectTab(1)
    end

    -- Global refresh helper to update the currently active options tab
    function BLU:RefreshOptions()
        if not panel or not panel.contents then return end
        for i, content in ipairs(panel.contents) do
            if content:IsShown() and type(content.Refresh) == "function" then
                local success, err = pcall(content.Refresh, content)
                if not success then
                    BLU:PrintDebug("RefreshOptions error: " .. tostring(err))
                end
            end
        end
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
    BLU:PrintDebug("[Options] OpenOptions called")
    if not BLU.db or not BLU.db.profile then
        BLU:Print("Database not ready. Please wait a moment and try again.")
        return
    end

    if InCombatLockdown and InCombatLockdown() then
        BLU:PrintDebug("[Options] OpenOptions blocked by combat lockdown")
        if not BLU._queuedOpenOptions then
            BLU._queuedOpenOptions = true
            BLU:Print("|cff00ccffBLU:|r Options cannot be opened in combat. Queued to open after combat.")
            if BLU.QueueForCombat then
                BLU:QueueForCombat(function()
                    BLU._queuedOpenOptions = nil
                    if BLU.OpenOptions then
                        BLU:OpenOptions()
                    end
                    return true
                end)
            else
                BLU._queuedOpenOptions = nil
            end
        else
            BLU:PrintDebug("[Options] OpenOptions already queued for after combat")
        end
        return
    end

    if not BLU.OptionsPanel then
        BLU:PrintDebug("[Options] Options panel missing, creating now")
        self:CreateOptionsPanel()
    end

    if not BLU.OptionsCategory then
        BLU:Print("Options panel not properly registered.")
        return
    end

    local opened = false
    local categoryID = self:ResolveOptionsCategoryID()

    if Settings and Settings.OpenToCategory and categoryID then
        local ok, result = pcall(function()
            if securecall then
                -- Use string name as fallback if ID is not a number
                local target = type(categoryID) == "number" and categoryID or (BLU.OptionsPanel and (BLU.OptionsPanel.settingsCategoryName or BLU.OptionsPanel.name))
                if target then
                    return securecall(Settings.OpenToCategory, target)
                end
            end
            return Settings.OpenToCategory(categoryID)
        end)
        opened = ok and result ~= nil
    end

    -- Avoid calling C_SettingsUtil.OpenSettingsPanel directly because it can be blocked for addons.
    if not opened and SettingsPanel and SettingsPanel.OpenToCategory and type(categoryID) == "number" then
        local ok, result = pcall(function()
            if securecall then
                return securecall(SettingsPanel.OpenToCategory, SettingsPanel, categoryID)
            end
            return SettingsPanel.OpenToCategory(SettingsPanel, categoryID)
        end)
        opened = ok and result ~= nil
    end

    if not opened and Settings and Settings.OpenToCategory and BLU.OptionsPanel then
        local categoryName = BLU.OptionsPanel.settingsCategoryName or BLU.OptionsPanel.name
        if categoryName then
            local ok, result = pcall(function()
                if securecall then
                    return securecall(Settings.OpenToCategory, categoryName)
                end
                return Settings.OpenToCategory(categoryName)
            end)
            opened = ok and result ~= nil
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
    else
        BLU:PrintDebug("[Options] Options panel opened successfully")
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
    BLU:PrintDebug("[Options] Cleanup called")
end

if BLU.RegisterModule then
    BLU:RegisterModule(Options, "options", "Options Interface")
end
