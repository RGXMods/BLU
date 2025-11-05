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

-- Panel dimensions
local PANEL_WIDTH = 700
local PANEL_HEIGHT = 600

-- Create main options panel
function Options:CreateOptionsPanel()
    BLU:PrintDebug("Creating new options panel...")
    
    -- Ensure database is initialized
    if not BLU.db then
        BLU:PrintDebug("Database not ready, attempting to initialize...")
        if BLU.InitializeDatabase then
            BLU:InitializeDatabase()
        elseif BLU.Modules.database and BLU.Modules.database.InitializeDatabase then
            BLU.Modules.database:InitializeDatabase()
        else
            BLU:PrintError("Cannot create options panel: Database system not available")
            return nil
        end
    end

    -- Create main frame
    local panel = CreateFrame("Frame", "BLUOptionsPanel", UIParent)
    panel.name = "Better Level-Up!"

    -- Custom icon for the settings menu
    panel.OnCommit = function() end
    panel.OnDefault = function() end
    panel.OnRefresh = function() end

    -- Store reference
    BLU.OptionsPanel = panel

    -- Main container with custom background
    local container = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    container:SetPoint("TOPLEFT", 0, 0)
    container:SetPoint("BOTTOMRIGHT", 0, 0)
    container:SetBackdrop(BLU.Modules.design.Backdrops.Dark)
    container:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    container:SetBackdropBorderColor(unpack(BLU.Modules.design.Colors.Primary))

    -- Create header
    local header = CreateFrame("Frame", nil, container, "BackdropTemplate")
    header:SetHeight(60)
    header:SetPoint("TOPLEFT", 5, -5)
    header:SetPoint("TOPRIGHT", -5, -5)
    header:SetBackdrop(BLU.Modules.design.Backdrops.Dark)
    header:SetBackdropColor(0.08, 0.08, 0.08, 0.8)
    header:SetBackdropBorderColor(unpack(BLU.Modules.design.Colors.Primary))

    -- Logo/Icon
    local logo = header:CreateTexture(nil, "ARTWORK")
    logo:SetSize(40, 40)
    logo:SetPoint("LEFT", 10, 0)
    logo:SetTexture("Interface\\AddOns\\BLU\\media\\images\\icon")

    -- Title
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", logo, "RIGHT", 10, 5)
    title:SetText("|cff05dffaBLU|r - Better Level-Up!")

    -- Subtitle
    local subtitle = header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
    subtitle:SetText("Iconic game sounds for World of Warcraft events")
    subtitle:SetTextColor(0.7, 0.7, 0.7)

    -- Version & Author
    local version = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    version:SetPoint("TOPRIGHT", -15, -15)
    version:SetText(BLU.version or "v6.0.0-alpha")
    version:SetTextColor(unpack(BLU.Modules.design.Colors.Primary))

    local author = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    author:SetPoint("TOP", version, "BOTTOM", 0, -2)
    author:SetText("by donniedice")
    author:SetTextColor(0.7, 0.7, 0.7)

    -- RGX Mods branding
    local branding = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    branding:SetPoint("BOTTOMRIGHT", -15, 10)
    branding:SetText("|cffffd700RGX Mods|r")

    -- Tab container
    local tabContainer = CreateFrame("Frame", nil, container)
    tabContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -2)
    tabContainer:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -2)
    tabContainer:SetHeight(120)

    -- Add background for tab container
    local tabBg = tabContainer:CreateTexture(nil, "BACKGROUND")
    tabBg:SetAllPoints()
    tabBg:SetColorTexture(0.03, 0.03, 0.03, 0.6)

    panel.tabs = {}
    panel.contents = {}

    local tabs = BLU.OptionsTabs
    if not tabs then
        BLU:PrintError("BLU.OptionsTabs not defined - tabs system not loaded")
        
        -- Create error message
        local errorText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        errorText:SetPoint("CENTER")
        errorText:SetText("|cffff0000Tab system failed to load|r\n\nPlease /reload and check for errors")
        return panel
    end
    
    if not BLU.CreateTabButton then
        BLU:PrintError("BLU.CreateTabButton not defined")
        return panel
    end
    
    if not BLU.CreateEventSoundPanel then
        BLU:PrintError("BLU.CreateEventSoundPanel not defined")
        return panel
    end

    BLU:PrintDebug("[Options] Creating " .. #tabs .. " tabs...")
    
    for i, tabInfo in ipairs(tabs) do
        -- Create tab button
        local tab = BLU.CreateTabButton(tabContainer, tabInfo.text, i, tabInfo.row, tabInfo.col, panel)
        if not tab then
            BLU:PrintError("[Options] Failed to create tab: " .. tabInfo.text)
        else
            panel.tabs[i] = tab
            BLU:PrintDebug("[Options] Created tab: " .. tabInfo.text)
        end

        -- Create content frame
        local content = CreateFrame("Frame", nil, container, "BackdropTemplate")
        content:SetPoint("TOPLEFT", tabContainer, "BOTTOMLEFT", 0, -10)
        content:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, 10)
        content:SetBackdrop(BLU.Modules.design.Backdrops.Dark)
        content:SetBackdropColor(0.06, 0.06, 0.06, 0.95)
        content:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
        content:Hide()

        -- Populate content
        if tabInfo.create then
            local success, err = pcall(tabInfo.create, content)
            if not success then
                BLU:PrintError("[Options] Error creating tab content for " .. tabInfo.text .. ": " .. tostring(err))
                local errorLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                errorLabel:SetPoint("CENTER")
                errorLabel:SetText("|cffff0000Error loading " .. tabInfo.text .. " panel|r")
            else
                BLU:PrintDebug("[Options] Created custom content for: " .. tabInfo.text)
            end
        elseif tabInfo.eventType then
            local success, err = pcall(BLU.CreateEventSoundPanel, content, tabInfo.eventType, tabInfo.text)
            if not success then
                BLU:PrintError("[Options] Error creating event panel for " .. tabInfo.text .. ": " .. tostring(err))
                local errorLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                errorLabel:SetPoint("CENTER")
                errorLabel:SetText("|cffff0000Error loading " .. tabInfo.text .. " panel|r")
            else
                BLU:PrintDebug("[Options] Created event panel for: " .. tabInfo.text)
            end
        else
            BLU:PrintDebug("[Options] No content handler for: " .. tabInfo.text)
        end

        panel.contents[i] = content
    end

    -- Tab selection function
    function panel:SelectTab(index)
        BLU:PrintDebug("[Options] Selecting tab: " .. index)
        for i, tab in ipairs(self.tabs) do
            if tab and tab.SetActive then
                tab:SetActive(i == index)
            end
            if self.contents[i] then
                self.contents[i]:SetShown(i == index)
            end
        end
    end

    -- Select first tab
    if #panel.tabs > 0 then
        panel:SelectTab(1)
        BLU:PrintDebug("[Options] Selected first tab")
    else
        BLU:PrintError("[Options] No tabs were created!")
    end

    -- Register the panel
    local category
    if Settings and Settings.RegisterCanvasLayoutCategory then
        category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
        BLU.OptionsCategory = category
        BLU:Print("|cff00ccffBLU:|r Options panel registered in Interface Options")
        BLU:PrintDebug("Options panel registered with new Settings API")
    else
        InterfaceOptions_AddCategory(panel)
        BLU.OptionsCategory = panel
        BLU:Print("|cff00ccffBLU:|r Options panel registered in Interface Options")
        BLU:PrintDebug("Options panel registered with legacy API")
    end

    return panel
end

-- Open options
function Options:OpenOptions()
    BLU:PrintDebug("Options:OpenOptions called. BLU.db is " .. tostring(BLU.db))
    
    -- Double-check database is ready
    if not BLU.db then
        BLU:PrintDebug("BLU.db is nil, attempting emergency initialization...")
        
        -- Try to initialize database
        if BLU.InitializeDatabase then
            BLU:InitializeDatabase()
        elseif BLU.Modules.database and BLU.Modules.database.InitializeDatabase then
            BLU.Modules.database:InitializeDatabase()
        end
        
        -- Check again
        if not BLU.db then
            BLU:Print("|cffff9900Database not ready.|r Please wait a moment and try |cffffff00/blu|r again.")
            BLU:PrintDebug("Emergency initialization failed. BLUDB: " .. tostring(_G["BLUDB"]))
            return
        end
    end
    
    -- Check for profile structure
    if not BLU.db.profile then
        BLU:PrintDebug("BLU.db.profile is nil, initializing profile structure...")
        BLU.db.profile = BLU.db.profile or {}
        
        -- Apply defaults if available
        if BLU.Modules.database and BLU.Modules.database.ApplyDefaults then
            BLU.Modules.database:ApplyDefaults()
        end
    end

    -- Create panel if it doesn't exist
    if not BLU.OptionsPanel then
        BLU:PrintDebug("Options panel doesn't exist, creating it...")
        self:CreateOptionsPanel()
        
        if not BLU.OptionsPanel then
            BLU:Print("|cffff0000Failed to create options panel.|r Please try |cffffff00/reload|")
            return
        end
    end

    if not BLU.OptionsCategory then
        BLU:Print("Options panel not properly registered.")
        return
    end

    -- Try to open the panel
    if Settings and Settings.OpenToCategory and BLU.OptionsCategory and BLU.OptionsCategory.ID then
        Settings.OpenToCategory(BLU.OptionsCategory.ID)
        C_Timer.After(0.1, function()
            Settings.OpenToCategory(BLU.OptionsCategory.ID)
        end)
    elseif InterfaceOptionsFrame_OpenToCategory and BLU.OptionsCategory then
        InterfaceOptionsFrame_OpenToCategory(BLU.OptionsCategory)
        InterfaceOptionsFrame_OpenToCategory(BLU.OptionsCategory)
    else
        BLU:Print("Unable to open options panel")
    end
end

function Options:Init()
    BLU:PrintDebug("Options:Init() called, registering OpenOptions.")
    BLU:PrintDebug("[Options] Initializing new options module")

    -- Make functions available globally
    BLU.CreateOptionsPanel = function()
        return self:CreateOptionsPanel()
    end

    BLU.OpenOptions = function()
        return self:OpenOptions()
    end

    BLU:PrintDebug("[Options] Functions registered. BLU.db is " .. tostring(BLU.db))
end

function Options:Cleanup()
    -- Nothing to cleanup
end

-- Register module
if BLU.RegisterModule then
    BLU:RegisterModule(Options, "options", "Options Interface")
end