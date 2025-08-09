--=====================================================================================
-- BLU | Options New Module
-- Author: donniedice
-- Description: New options panel system with full tabbed interface
--=====================================================================================

local addonName, BLU = ...

-- Create the module
local OptionsNew = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["options_new"] = OptionsNew

function OptionsNew:Init()
    BLU:PrintDebug("Options_new module initializing...")
    
    -- Set up the slash command handler
    self:SetupSlashCommands()
    
    BLU:PrintDebug("Options_new module initialized")
end

function OptionsNew:SetupSlashCommands()
    -- Register slash commands
    SLASH_BLU1 = "/blu"
    SLASH_BLU2 = "/betterlu"
    SLASH_BLU3 = "/betterlevelup"
    
    SlashCmdList["BLU"] = function(msg)
        self:HandleSlashCommand(msg)
    end
end

function OptionsNew:HandleSlashCommand(msg)
    msg = msg:trim():lower()
    
    if msg == "" or msg == "options" or msg == "config" then
        self:OpenOptionsPanel()
    elseif msg == "test" then
        self:TestSound()
    elseif msg == "reload" then
        ReloadUI()
    elseif msg == "debug" then
        self:ToggleDebug()
    elseif msg == "version" then
        BLU:Print("Version: " .. (BLU_VERSION or "6.0.0-alpha"))
    elseif msg == "help" then
        self:ShowHelp()
    else
        self:ShowHelp()
    end
end

function OptionsNew:CreateOptionsPanel()
    if BLU.OptionsPanel then
        BLU:PrintDebug("[Options_new] Panel already exists")
        return BLU.OptionsPanel
    end
    
    BLU:PrintDebug("[Options_new] Creating full options panel with tabs")
    
    -- Create main panel frame
    local panel = CreateFrame("Frame", "BLUOptionsPanel", UIParent, "BackdropTemplate")
    panel:SetSize(800, 600)
    panel:SetPoint("CENTER")
    panel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:Hide()
    
    -- Title bar
    local titleBar = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    titleBar:SetHeight(40)
    titleBar:SetPoint("TOPLEFT", 11, -12)
    titleBar:SetPoint("TOPRIGHT", -12, -12)
    titleBar:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    titleBar:SetBackdropColor(0.02, 0.37, 1, 0.9)
    
    -- Title text
    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("CENTER")
    title:SetText("|cff05dffaBetter Level-Up!|r Settings")
    
    -- Close button
    local closeButton = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        panel:Hide()
    end)
    
    -- Initialize tab system
    BLU.TabSystem:Initialize(panel)
    BLU.TabSystem.contentArea:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, -5)
    
    -- Create all panels
    self:CreateGeneralPanel()
    self:CreateSoundsPanel()
    self:CreateModulesPanel()
    self:CreateProfilesPanel()
    self:CreateAdvancedPanel()
    self:CreateAboutPanel()
    
    -- Select default tab
    local defaultTab = (BLU.db and BLU.db.profile and BLU.db.profile.selectedTab) or "general"
    BLU.TabSystem:SelectTab(defaultTab)
    
    BLU.OptionsPanel = panel
    BLU:PrintDebug("[Options_new] Full panel created successfully")
    
    return panel
end

function OptionsNew:CreateGeneralPanel()
    if BLU.CreateGeneralPanel then
        BLU.CreateGeneralPanel()
    else
        -- Fallback basic panel
        local panel = CreateFrame("Frame", nil)
        local text = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER")
        text:SetText("General Settings")
        BLU.TabSystem:RegisterPanel("general", panel)
    end
end

function OptionsNew:CreateSoundsPanel()
    if BLU.CreateSoundsPanel then
        BLU.CreateSoundsPanel()
    else
        -- Fallback basic panel
        local panel = CreateFrame("Frame", nil)
        local text = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER")
        text:SetText("Sound Settings")
        BLU.TabSystem:RegisterPanel("sounds", panel)
    end
end

function OptionsNew:CreateModulesPanel()
    if BLU.CreateModulesPanel then
        BLU.CreateModulesPanel()
    else
        -- Fallback basic panel
        local panel = CreateFrame("Frame", nil)
        local text = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER")
        text:SetText("Module Settings")
        BLU.TabSystem:RegisterPanel("modules", panel)
    end
end

function OptionsNew:CreateProfilesPanel()
    if BLU.CreateProfilesPanel then
        BLU.CreateProfilesPanel()
    else
        -- Fallback basic panel
        local panel = CreateFrame("Frame", nil)
        local text = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER")
        text:SetText("Profile Settings")
        BLU.TabSystem:RegisterPanel("profiles", panel)
    end
end

function OptionsNew:CreateAdvancedPanel()
    if BLU.CreateAdvancedPanel then
        BLU.CreateAdvancedPanel()
    else
        -- Fallback basic panel
        local panel = CreateFrame("Frame", nil)
        local text = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER")
        text:SetText("Advanced Settings")
        BLU.TabSystem:RegisterPanel("advanced", panel)
    end
end

function OptionsNew:CreateAboutPanel()
    if BLU.CreateAboutPanel then
        BLU.CreateAboutPanel()
    else
        -- Fallback basic panel
        local panel = CreateFrame("Frame", nil)
        local text = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER")
        text:SetText("About BLU")
        BLU.TabSystem:RegisterPanel("about", panel)
    end
end

function OptionsNew:OpenOptionsPanel()
    if not BLU.OptionsPanel then
        self:CreateOptionsPanel()
    end
    
    if BLU.OptionsPanel then
        BLU.OptionsPanel:Show()
        BLU:PrintDebug("[Options_new] Panel opened")
    else
        BLU:Print("Failed to create options panel")
    end
end

function OptionsNew:TestSound()
    if BLU.Registry and BLU.Registry.PlaySound then
        BLU.Registry:PlaySound("finalfantasy_levelup")
        BLU:Print("Playing test sound: Final Fantasy Level Up")
    else
        BLU:Print("Sound system not ready")
    end
end

function OptionsNew:ToggleDebug()
    BLU.debugMode = not BLU.debugMode
    if BLU.db and BLU.db.profile then
        BLU.db.profile.debugMode = BLU.debugMode
    end
    BLU:Print("Debug mode: " .. (BLU.debugMode and "Enabled" or "Disabled"))
end

function OptionsNew:ShowHelp()
    BLU:Print("BLU Commands:")
    BLU:Print("  /blu - Open options panel")
    BLU:Print("  /blu test - Play test sound")
    BLU:Print("  /blu reload - Reload UI")
    BLU:Print("  /blu debug - Toggle debug mode")
    BLU:Print("  /blu version - Show version")
    BLU:Print("  /blu help - Show this help")
end