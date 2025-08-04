--=====================================================================================
-- BLU - interface/options.lua
-- Main options panel registration
--=====================================================================================

local addonName, BLU = ...

-- Create options module
local Options = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["options"] = Options

-- Initialize options module
function Options:Init()
    BLU:PrintDebug("Initializing options module")
    
    -- Load interface components
    if BLU.Widgets then
        BLU.Widgets:Init()
    else
        BLU:PrintDebug("WARNING: BLU.Widgets not found!")
    end
    
    if not BLU.Tabs then
        BLU:PrintDebug("WARNING: BLU.Tabs not found!")
    end
    
    -- Make functions available globally
    BLU.CreateOptionsPanel = function()
        return self:CreateOptionsPanel()
    end
    
    BLU.OpenOptions = function()
        return self:OpenOptions()
    end
    
    -- Create the panel immediately
    C_Timer.After(0.1, function()
        if not BLU.OptionsPanel then
            BLU:PrintDebug("Creating options panel from timer...")
            self:CreateOptionsPanel()
        end
    end)
    
    BLU:PrintDebug("Options module initialized")
end

-- Create main options panel
function Options:CreateOptionsPanel()
    BLU:PrintDebug("Creating options panel...")
    
    -- Create main frame
    local panel = CreateFrame("Frame", "BLUOptionsPanel", UIParent)
    panel.name = "Better Level-Up!"
    
    -- Store reference
    BLU.OptionsPanel = panel
    
    -- Header section
    local header = CreateFrame("Frame", nil, panel)
    header:SetPoint("TOPLEFT", 16, -16)
    header:SetPoint("TOPRIGHT", -16, -16)
    header:SetHeight(40)
    
    -- Title with icon
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT")
    title:SetText("|TInterface\\AddOns\\BLU\\media\\images\\icon:16:16|t |cff05dffaBLU|r - Better Level-Up!")
    
    -- Version
    local version = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    version:SetPoint("TOPRIGHT")
    version:SetText("Version: " .. (BLU.version or "Unknown"))
    version:SetTextColor(0.7, 0.7, 0.7)
    
    -- Subtitle
    local subtitle = header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    subtitle:SetText("Play sounds from other games!")
    
    -- Initialize tab system
    if not BLU.Tabs then
        BLU:PrintDebug("ERROR: BLU.Tabs not found!")
        return
    end
    
    BLU:PrintDebug("Initializing tab system...")
    BLU.Tabs:Init(panel)
    
    -- Add tabs
    BLU:PrintDebug("Adding tabs...")
    if BLU.CreateGeneralPanel then
        BLU.Tabs:AddTab("General", BLU.CreateGeneralPanel)
    else
        BLU:PrintDebug("ERROR: CreateGeneralPanel not found!")
    end
    
    if BLU.CreateSoundsPanel then
        BLU.Tabs:AddTab("Sounds", BLU.CreateSoundsPanel)
    else
        BLU:PrintDebug("ERROR: CreateSoundsPanel not found!")
    end
    
    if BLU.CreateModulesPanel then
        BLU.Tabs:AddTab("Modules", BLU.CreateModulesPanel)
    else
        BLU:PrintDebug("ERROR: CreateModulesPanel not found!")
    end
    
    if BLU.CreateAboutPanel then
        BLU.Tabs:AddTab("About", BLU.CreateAboutPanel)
    else
        BLU:PrintDebug("ERROR: CreateAboutPanel not found!")
    end
    
    -- Register with Blizzard using proper API
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        -- Use new Settings API (Dragonflight+)
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        category.ID = panel.name
        Settings.RegisterAddOnCategory(category)
        BLU.OptionsCategory = category
        BLU:PrintDebug("Options panel registered with new Settings API")
    else
        -- Fallback to older interface options
        InterfaceOptions_AddCategory(panel)
        BLU.OptionsCategory = panel
        BLU:PrintDebug("Options panel registered with legacy InterfaceOptions")
    end
end

-- Open options
function Options:OpenOptions()
    -- Create panel if it doesn't exist
    if not BLU.OptionsPanel then
        BLU:PrintDebug("Panel doesn't exist, creating now...")
        self:CreateOptionsPanel()
    end
    
    if not BLU.OptionsCategory then
        BLU:Print("Options panel not properly registered. Please try again.")
        return
    end
    
    if Settings and Settings.OpenToCategory and BLU.OptionsCategory and BLU.OptionsCategory.ID then
        -- Use new Settings API
        Settings.OpenToCategory(BLU.OptionsCategory.ID)
        BLU:PrintDebug("Opened with new Settings API")
    elseif InterfaceOptionsFrame_OpenToCategory and BLU.OptionsCategory then
        -- Use legacy interface
        InterfaceOptionsFrame_OpenToCategory(BLU.OptionsCategory)
        InterfaceOptionsFrame_OpenToCategory(BLU.OptionsCategory) -- Called twice for proper display
        BLU:PrintDebug("Opened with legacy InterfaceOptions API")
    else
        BLU:Print("Unable to open options panel - API not available")
    end
end