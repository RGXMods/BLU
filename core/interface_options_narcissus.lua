--=====================================================================================
-- BLU | Interface Options with Narcissus Style
-- Author: donniedice
-- Description: Beautiful Narcissus-style interface integrated with WoW Options
--=====================================================================================

local addonName, BLU = ...

local InterfaceOptions = {}
BLU.InterfaceOptions = InterfaceOptions

-- Create the main options panel with Narcissus styling
function InterfaceOptions:CreatePanel()
    if self.panel then
        return self.panel
    end
    
    -- Create main panel for Interface Options
    local panel = CreateFrame("Frame", "BLUInterfaceOptionsPanel", nil, "BackdropTemplate")
    panel.name = "Better Level-Up!"
    
    -- Apply Narcissus-style glass effect backdrop
    panel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
        tile = true,
        tileSize = 12,
        edgeSize = 12,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    panel:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
    panel:SetBackdropBorderColor(0.82, 0.69, 0.36, 0.8) -- Gold accent
    
    -- Title with glow effect
    local title = panel:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Huge2")
    title:SetPoint("TOP", 0, -15)
    title:SetText("|cffD2B48CBetter Level-Up!|r")
    title:SetShadowOffset(2, -2)
    title:SetShadowColor(0, 0, 0, 0.8)
    
    -- Subtitle
    local subtitle = panel:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -5)
    subtitle:SetText("Sound Replacement Addon")
    subtitle:SetTextColor(0.7, 0.7, 0.7)
    
    -- Version badge
    local versionBadge = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    versionBadge:SetSize(100, 24)
    versionBadge:SetPoint("TOPRIGHT", -20, -20)
    versionBadge:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    versionBadge:SetBackdropColor(0, 0, 0, 0.7)
    versionBadge:SetBackdropBorderColor(0.82, 0.69, 0.36, 0.5)
    
    local versionText = versionBadge:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Small")
    versionText:SetPoint("CENTER")
    versionText:SetText("v6.0.0-alpha")
    versionText:SetTextColor(0.82, 0.69, 0.36)
    
    -- Main content container with glass effect
    local contentFrame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    contentFrame:SetPoint("TOPLEFT", 20, -80)
    contentFrame:SetPoint("BOTTOMRIGHT", -20, 20)
    contentFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 1,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    contentFrame:SetBackdropColor(0.08, 0.08, 0.08, 0.6)
    contentFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.3)
    
    -- Create Narcissus-style tab system
    local tabSystem = self:CreateNarcissusTabSystem(contentFrame)
    
    -- Create tab panels
    self:CreateGeneralTab(tabSystem)
    self:CreateSoundsTab(tabSystem)
    self:CreateModulesTab(tabSystem)
    self:CreateProfilesTab(tabSystem)
    self:CreateAdvancedTab(tabSystem)
    self:CreateAboutTab(tabSystem)
    
    -- Select default tab
    tabSystem:SelectTab("general")
    
    -- Register with Interface Options
    self:RegisterPanel(panel)
    
    self.panel = panel
    self.tabSystem = tabSystem
    return panel
end

-- Create Narcissus-style tab system
function InterfaceOptions:CreateNarcissusTabSystem(parent)
    local tabContainer = CreateFrame("Frame", nil, parent)
    tabContainer:SetHeight(36)
    tabContainer:SetPoint("TOPLEFT", 10, -10)
    tabContainer:SetPoint("TOPRIGHT", -10, -10)
    
    local tabs = {}
    local panels = {}
    local currentTab = nil
    
    -- Tab data
    local tabData = {
        {id = "general", text = "General", icon = "Interface\\Icons\\INV_Misc_Gear_01"},
        {id = "sounds", text = "Sounds", icon = "Interface\\Icons\\INV_Misc_Bell_01"},
        {id = "modules", text = "Modules", icon = "Interface\\Icons\\INV_Misc_EngGizmos_30"},
        {id = "profiles", text = "Profiles", icon = "Interface\\Icons\\INV_Misc_Book_11"},
        {id = "advanced", text = "Advanced", icon = "Interface\\Icons\\INV_Misc_Wrench_01"},
        {id = "about", text = "About", icon = "Interface\\Icons\\INV_Misc_QuestionMark"}
    }
    
    -- Create tabs
    for i, data in ipairs(tabData) do
        local tab = CreateFrame("Button", nil, tabContainer, "BackdropTemplate")
        tab:SetSize(100, 32)
        tab:SetPoint("LEFT", (i-1) * 102 + 5, 0)
        
        -- Narcissus-style tab backdrop
        tab:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 1,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        tab:SetBackdropColor(0.1, 0.1, 0.1, 0.7)
        tab:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
        
        -- Tab icon
        local icon = tab:CreateTexture(nil, "ARTWORK")
        icon:SetSize(20, 20)
        icon:SetPoint("LEFT", 8, 0)
        icon:SetTexture(data.icon)
        icon:SetVertexColor(0.8, 0.8, 0.8)
        
        -- Tab text
        local text = tab:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Small")
        text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
        text:SetText(data.text)
        text:SetTextColor(0.7, 0.7, 0.7)
        
        -- Highlight line (hidden by default)
        local highlight = tab:CreateTexture(nil, "BACKGROUND")
        highlight:SetHeight(3)
        highlight:SetPoint("BOTTOMLEFT", 2, 2)
        highlight:SetPoint("BOTTOMRIGHT", -2, 2)
        highlight:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        highlight:SetVertexColor(0.82, 0.69, 0.36, 1)
        highlight:Hide()
        
        -- Store references
        tab.icon = icon
        tab.text = text
        tab.highlight = highlight
        tabs[data.id] = tab
        
        -- Create panel for this tab
        local panel = CreateFrame("Frame", nil, parent)
        panel:SetPoint("TOPLEFT", tabContainer, "BOTTOMLEFT", 0, -5)
        panel:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -10, 10)
        panel:Hide()
        panels[data.id] = panel
        
        -- Tab click handler
        tab:SetScript("OnClick", function()
            tabSystem:SelectTab(data.id)
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        end)
        
        -- Hover effects
        tab:SetScript("OnEnter", function(self)
            if currentTab ~= data.id then
                self:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8)
                self.icon:SetVertexColor(1, 1, 1)
                self.text:SetTextColor(0.9, 0.9, 0.9)
            end
        end)
        
        tab:SetScript("OnLeave", function(self)
            if currentTab ~= data.id then
                self:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
                self.icon:SetVertexColor(0.8, 0.8, 0.8)
                self.text:SetTextColor(0.7, 0.7, 0.7)
            end
        end)
    end
    
    -- Tab selection function
    function tabSystem:SelectTab(tabId)
        -- Deselect all tabs
        for id, tab in pairs(tabs) do
            tab:SetBackdropColor(0.1, 0.1, 0.1, 0.7)
            tab:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
            tab.icon:SetVertexColor(0.8, 0.8, 0.8)
            tab.text:SetTextColor(0.7, 0.7, 0.7)
            tab.highlight:Hide()
            panels[id]:Hide()
        end
        
        -- Select new tab
        if tabs[tabId] then
            local tab = tabs[tabId]
            tab:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
            tab:SetBackdropBorderColor(0.82, 0.69, 0.36, 0.8)
            tab.icon:SetVertexColor(0.82, 0.69, 0.36)
            tab.text:SetTextColor(1, 1, 1)
            tab.highlight:Show()
            panels[tabId]:Show()
            currentTab = tabId
        end
    end
    
    tabSystem.tabs = tabs
    tabSystem.panels = panels
    
    return tabSystem
end

-- Create General tab content
function InterfaceOptions:CreateGeneralTab(tabSystem)
    local panel = tabSystem.panels.general
    
    if BLU.CreateGeneralPanel then
        -- Use existing panel creation
        local generalPanel = BLU.CreateGeneralPanel()
        generalPanel:SetParent(panel)
        generalPanel:SetAllPoints()
        generalPanel:Show()
    else
        -- Fallback content
        local text = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER")
        text:SetText("General Settings")
    end
end

-- Create other tabs (similar pattern)
function InterfaceOptions:CreateSoundsTab(tabSystem)
    local panel = tabSystem.panels.sounds
    if BLU.CreateSoundsPanel then
        local soundsPanel = BLU.CreateSoundsPanel()
        soundsPanel:SetParent(panel)
        soundsPanel:SetAllPoints()
        soundsPanel:Show()
    end
end

function InterfaceOptions:CreateModulesTab(tabSystem)
    local panel = tabSystem.panels.modules
    if BLU.CreateModulesPanel then
        local modulesPanel = BLU.CreateModulesPanel()
        modulesPanel:SetParent(panel)
        modulesPanel:SetAllPoints()
        modulesPanel:Show()
    end
end

function InterfaceOptions:CreateProfilesTab(tabSystem)
    local panel = tabSystem.panels.profiles
    if BLU.CreateProfilesPanel then
        local profilesPanel = BLU.CreateProfilesPanel()
        profilesPanel:SetParent(panel)
        profilesPanel:SetAllPoints()
        profilesPanel:Show()
    end
end

function InterfaceOptions:CreateAdvancedTab(tabSystem)
    local panel = tabSystem.panels.advanced
    if BLU.CreateAdvancedPanel then
        local advancedPanel = BLU.CreateAdvancedPanel()
        advancedPanel:SetParent(panel)
        advancedPanel:SetAllPoints()
        advancedPanel:Show()
    end
end

function InterfaceOptions:CreateAboutTab(tabSystem)
    local panel = tabSystem.panels.about
    if BLU.CreateAboutPanel then
        local aboutPanel = BLU.CreateAboutPanel()
        aboutPanel:SetParent(panel)
        aboutPanel:SetAllPoints()
        aboutPanel:Show()
    end
end

-- Register the panel
function InterfaceOptions:RegisterPanel(panel)
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
        self.category = category
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end
end

-- Open the panel
function InterfaceOptions:Open()
    if not self.panel then
        self:CreatePanel()
    end
    
    if Settings and Settings.OpenToCategory and self.category then
        Settings.OpenToCategory(self.category:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(self.panel)
        InterfaceOptionsFrame_OpenToCategory(self.panel)
    end
end

-- Initialize
function InterfaceOptions:Init()
    local loader = CreateFrame("Frame")
    loader:RegisterEvent("PLAYER_LOGIN")
    loader:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_LOGIN" then
            InterfaceOptions:CreatePanel()
            self:UnregisterEvent("PLAYER_LOGIN")
        end
    end)
    
    -- Override slash command
    SLASH_BLU1 = "/blu"
    SlashCmdList["BLU"] = function(msg)
        if msg == "" then
            InterfaceOptions:Open()
        end
    end
    
    BLU:PrintDebug("Narcissus-style Interface Options initialized")
end

-- Export
function BLU:OpenOptions()
    InterfaceOptions:Open()
end

InterfaceOptions:Init()
return InterfaceOptions