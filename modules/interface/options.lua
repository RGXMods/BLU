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
    BLU:Print("|cff00ff00BLU Options module loading...|r")
    
    -- Load interface components
    if BLU.Widgets then
        BLU.Widgets:Init()
        BLU:PrintDebug("Widgets initialized")
    else
        BLU:PrintDebug("ERROR: BLU.Widgets not found!")
        BLU:Print("|cffff0000ERROR: BLU.Widgets not found!|r")
    end
    
    if not BLU.Tabs then
        BLU:PrintDebug("ERROR: BLU.Tabs not found!")
        BLU:Print("|cffff0000ERROR: BLU.Tabs not found!|r")
    else
        BLU:PrintDebug("Tabs system found")
    end
    
    -- Make functions available globally
    BLU.CreateOptionsPanel = function()
        BLU:PrintDebug("CreateOptionsPanel wrapper called")
        return self:CreateOptionsPanel()
    end
    
    BLU.OpenOptions = function()
        BLU:PrintDebug("OpenOptions wrapper called")
        return self:OpenOptions()
    end
    
    -- Create the panel immediately
    C_Timer.After(0.5, function()
        if not BLU.OptionsPanel then
            BLU:PrintDebug("Creating options panel from timer...")
            BLU:Print("|cff00ff00Creating BLU options panel...|r")
            self:CreateOptionsPanel()
        else
            BLU:PrintDebug("Options panel already exists")
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
    
    -- Background texture
    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.05, 0.05, 0.05, 0.8)
    
    -- Header section with gradient
    local header = CreateFrame("Frame", nil, panel)
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)
    header:SetHeight(80)
    
    -- Header gradient
    local headerBg = header:CreateTexture(nil, "BACKGROUND")
    headerBg:SetAllPoints()
    headerBg:SetColorTexture(0.02, 0.37, 1, 0.2)
    
    -- Large icon
    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(64, 64)
    icon:SetPoint("TOPLEFT", 16, -8)
    icon:SetTexture("Interface\\AddOns\\BLU\\media\\images\\icon")
    
    -- Title with larger font
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("LEFT", icon, "RIGHT", 12, 10)
    title:SetText("|cff05dffaBLU|r - Better Level-Up!")
    
    -- Version badge
    local versionFrame = CreateFrame("Frame", nil, header)
    versionFrame:SetSize(120, 24)
    versionFrame:SetPoint("TOPRIGHT", -16, -12)
    
    local versionBg = versionFrame:CreateTexture(nil, "BACKGROUND")
    versionBg:SetAllPoints()
    versionBg:SetColorTexture(0, 0, 0, 0.5)
    
    local version = versionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    version:SetPoint("CENTER")
    version:SetText("v" .. (BLU.version or "5.3.0-alpha"))
    version:SetTextColor(0.02, 0.37, 1, 1)
    
    -- Subtitle with author info
    local subtitle = header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    subtitle:SetPoint("LEFT", icon, "RIGHT", 12, -10)
    subtitle:SetText("Play sounds from 50+ games! |cff808080by donniedice|r")
    
    -- RGX Mods branding
    local branding = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    branding:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", -16, 4)
    branding:SetText("|cffffd700RGX Mods|r")
    
    -- Separator line
    local separator = header:CreateTexture(nil, "ARTWORK")
    separator:SetHeight(1)
    separator:SetPoint("BOTTOMLEFT", 16, 0)
    separator:SetPoint("BOTTOMRIGHT", -16, 0)
    separator:SetColorTexture(0.02, 0.37, 1, 0.5)
    
    -- Initialize tab system
    if not BLU.Tabs then
        BLU:PrintDebug("ERROR: BLU.Tabs not found!")
        BLU:Print("|cffff0000ERROR: Cannot create tabs - BLU.Tabs missing|r")
        
        -- Fallback to simple text
        local errorText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        errorText:SetPoint("CENTER")
        errorText:SetText("Tab system not loaded. Please reload UI.")
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
    BLU:PrintDebug("OpenOptions called")
    
    -- Try to create panel if it doesn't exist
    if not BLU.OptionsPanel then
        BLU:PrintDebug("Panel doesn't exist, creating now...")
        local success, err = pcall(function()
            self:CreateOptionsPanel()
        end)
        
        if not success then
            BLU:Print("|cffff0000Failed to create options panel:|r " .. tostring(err))
            -- Fallback to simple options
            if BLU.OpenSimpleOptions then
                BLU:Print("|cff00ff00Using simple options as fallback|r")
                BLU:OpenSimpleOptions()
            end
            return
        end
    end
    
    if not BLU.OptionsCategory then
        BLU:Print("Options panel not properly registered.")
        -- Try simple options
        if BLU.OpenSimpleOptions then
            BLU:Print("|cff00ff00Using simple options as fallback|r")
            BLU:OpenSimpleOptions()
        end
        return
    end
    
    if Settings and Settings.OpenToCategory and BLU.OptionsCategory and BLU.OptionsCategory.ID then
        -- Use new Settings API
        Settings.OpenToCategory(BLU.OptionsCategory.ID)
        -- Call twice to ensure it opens to our category
        C_Timer.After(0.1, function()
            Settings.OpenToCategory(BLU.OptionsCategory.ID)
        end)
        BLU:PrintDebug("Opened with new Settings API")
    elseif InterfaceOptionsFrame_OpenToCategory and BLU.OptionsCategory then
        -- Use legacy interface
        InterfaceOptionsFrame_OpenToCategory(BLU.OptionsCategory)
        -- Call twice to ensure it opens to our category
        InterfaceOptionsFrame_OpenToCategory(BLU.OptionsCategory)
        BLU:PrintDebug("Opened with legacy InterfaceOptions API")
    else
        BLU:Print("Unable to open options panel - trying simple options")
        if BLU.OpenSimpleOptions then
            BLU:OpenSimpleOptions()
        end
    end
end