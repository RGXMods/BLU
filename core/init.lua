--=====================================================================================
-- BLU Initialization
-- Bootstrap the addon
--=====================================================================================

local addonName, BLU = ...

-- Remove loading message - not needed

-- Initialize core systems
BLU:RegisterEvent("ADDON_LOADED", function(event, addon)
    if addon ~= addonName then return end
    
    -- ADDON_LOADED event fired
    
    -- Load saved variables first
    if BLU.LoadSettings then
        BLU:LoadSettings()
    end
    
    -- Initialize modules in order
    -- Note: Only modules with Init() functions need to be here
    local initOrder = {
        "database",      -- Has Init()
        "localization",  -- Has Init()
        "sharedmedia",   -- Has Init() - external sound detection
        "registry",      -- Has Init()
        "internal_sounds", -- Has Init() - BLU internal sounds
        "loader",        -- Has Init()
        "options_new"    -- New UI system
        -- "config" and "utils" don't have Init()
        -- "events" is loaded but doesn't need Init()
    }
    
    -- Debug: Print available modules (disabled for release)
    --[[
    if BLU.debugMode then
        BLU:PrintDebug("Available modules:")
        if BLU.Modules then
            for k, v in pairs(BLU.Modules) do
                BLU:PrintDebug("  - " .. k)
            end
        end
    end
    --]]
    
    for _, moduleName in ipairs(initOrder) do
        local module = BLU.Modules[moduleName]
        if module and module.Init then
            BLU:PrintDebug("[Init] Initializing module: " .. moduleName)
            module:Init()
        else
            BLU:PrintDebug("[Init] Module not found or has no Init: " .. moduleName)
        end
    end
    
    -- Load feature modules based on settings
    if BLU.LoadModulesFromSettings then
        BLU:LoadModulesFromSettings()
    end
    
    -- Create simple options panel as backup - disabled for new UI
    -- C_Timer.After(1, function()
    --     if BLU.CreateSimpleOptionsPanel and not BLU.OptionsPanel then
    --         BLU:PrintDebug("Creating simple options panel as backup")
    --         BLU:CreateSimpleOptionsPanel()
    --     end
    -- end)
    
    BLU:PrintDebug("BLU initialized successfully")
    BLU.isInitialized = true
end)

BLU:RegisterEvent("PLAYER_LOGIN", function()
    BLU:PrintDebug("[Init] PLAYER_LOGIN event fired")
    
    -- Force initialize the options_new module and create the FULL panel
    if not BLU.OptionsPanel then
        -- Make sure options_new module is initialized
        if BLU.Modules and BLU.Modules.options_new then
            if BLU.Modules.options_new.Init then
                BLU:PrintDebug("[Init] Initializing options_new module")
                BLU.Modules.options_new:Init()
            end
            
            -- Now create the full panel with all tabs
            if BLU.Modules.options_new.CreateOptionsPanel then
                BLU:PrintDebug("[Init] Creating FULL options panel with tabs")
                BLU.Modules.options_new:CreateOptionsPanel()
                return -- Exit early, we have the full panel
            end
        end
        
        -- Only use fallback if full panel creation failed
        BLU:PrintDebug("[Init] Fallback: Creating simple panel")
        
        local panel = CreateFrame("Frame", "BLUOptionsPanel", UIParent)
        panel.name = "Better Level-Up!"
        
        -- Container
        local container = CreateFrame("Frame", nil, panel, "BackdropTemplate")
        container:SetPoint("TOPLEFT", 10, -10)
        container:SetPoint("BOTTOMRIGHT", -10, 10)
        container:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = false,
            edgeSize = 1,
            insets = {left = 1, right = 1, top = 1, bottom = 1}
        })
        container:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
        container:SetBackdropBorderColor(0.02, 0.37, 1, 1) -- BLU blue
        
        -- Header
        local header = CreateFrame("Frame", nil, container, "BackdropTemplate")
        header:SetHeight(80)
        header:SetPoint("TOPLEFT", 10, -10)
        header:SetPoint("TOPRIGHT", -10, -10)
        header:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = false,
            edgeSize = 1,
            insets = {left = 1, right = 1, top = 1, bottom = 1}
        })
        header:SetBackdropColor(0.08, 0.08, 0.08, 0.9)
        header:SetBackdropBorderColor(0.02, 0.37, 1, 1)
        
        -- Title
        local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
        title:SetPoint("LEFT", 20, 10)
        title:SetText("Better Level-Up|cff05dffa!|r")
        
        -- Version
        local version = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        version:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
        version:SetText("Version 6.0.0-alpha |cffff0000[ALPHA]|r")
        version:SetTextColor(0.7, 0.7, 0.7)
        
        -- RGX Mods
        local rgx = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        rgx:SetPoint("RIGHT", -20, 0)
        rgx:SetText("|cffffd700RGX |r|cff05dffaMods|r")
        
        -- Instructions
        local info = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        info:SetPoint("TOP", header, "BOTTOM", 0, -50)
        info:SetText("Type |cff05dffa/blu|r to open the full options panel")
        
        -- About text
        local about = container:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        about:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 20, -100)
        about:SetPoint("RIGHT", -20, 0)
        about:SetJustifyH("LEFT")
        about:SetText("BLU replaces default World of Warcraft sounds with iconic audio from 50+ games.\n\nFeatures:\n• Level up sounds\n• Achievement sounds\n• Quest completion sounds\n• Reputation sounds\n• And much more!\n\nJoin our Discord: |cffffd700discord.gg/rgxmods|r")
        
        -- Register the panel
        if Settings and Settings.RegisterCanvasLayoutCategory then
            local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
            Settings.RegisterAddOnCategory(category)
            BLU.OptionsCategory = category
            BLU:PrintDebug("[Init] Panel registered with Settings API")
        else
            InterfaceOptions_AddCategory(panel)
            BLU.OptionsCategory = panel
            BLU:PrintDebug("[Init] Panel registered with legacy API")
        end
        
        BLU.OptionsPanel = panel
    end
    
    -- Show welcome message
    C_Timer.After(1, function()
        BLU:ShowWelcomeMessage()
    end)
end)

-- Register for VARIABLES_LOADED to ensure database is ready
BLU:RegisterEvent("VARIABLES_LOADED", function()
    BLU:PrintDebug("Variables loaded - database should be ready")
end)

BLU:RegisterEvent("PLAYER_LOGOUT", function()
    if BLU.SaveSettings then
        BLU:SaveSettings()
    end
end)