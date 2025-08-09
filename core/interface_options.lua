--=====================================================================================
-- BLU | Interface Options Integration
-- Author: donniedice
-- Description: Proper integration with WoW's Interface Options panel
--=====================================================================================

local addonName, BLU = ...

local InterfaceOptions = {}
BLU.InterfaceOptions = InterfaceOptions

-- Create the main options panel that integrates into Interface Options
function InterfaceOptions:CreatePanel()
    if self.panel then
        return self.panel
    end
    
    -- Create main panel (no parent for Interface Options)
    local panel = CreateFrame("Frame", "BLUInterfaceOptionsPanel")
    panel.name = "Better Level-Up!"
    
    -- Container that fills the Interface Options content area
    local container = CreateFrame("Frame", nil, panel)
    container:SetPoint("TOPLEFT", 0, 0)
    container:SetPoint("BOTTOMRIGHT", 0, 0)
    
    -- Initialize tab system within the container
    BLU.TabSystem:Initialize(container)
    
    -- Adjust tab content area to fit properly
    BLU.TabSystem.contentArea:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -40)
    BLU.TabSystem.contentArea:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -10, 10)
    
    -- Move tabs to top of container
    if BLU.TabSystem.tabContainer then
        BLU.TabSystem.tabContainer:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -5)
    end
    
    -- Create all panels
    self:CreateAllPanels()
    
    -- Select default tab
    local defaultTab = (BLU.db and BLU.db.profile and BLU.db.profile.selectedTab) or "general"
    BLU.TabSystem:SelectTab(defaultTab)
    
    -- Register with Interface Options
    self:RegisterPanel(panel)
    
    self.panel = panel
    return panel
end

-- Register the panel with Interface Options
function InterfaceOptions:RegisterPanel(panel)
    -- Modern WoW (Dragonflight+) Settings API
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
        self.category = category
        BLU:PrintDebug("Registered with modern Settings API")
    
    -- Older WoW versions
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
        BLU:PrintDebug("Registered with classic InterfaceOptions API")
    else
        BLU:PrintError("Could not register with Interface Options")
    end
end

-- Create all the tab panels
function InterfaceOptions:CreateAllPanels()
    -- General Panel
    if BLU.CreateGeneralPanel then
        BLU.CreateGeneralPanel()
    end
    
    -- Sounds Panel
    if BLU.CreateSoundsPanel then
        BLU.CreateSoundsPanel()
    end
    
    -- Modules Panel
    if BLU.CreateModulesPanel then
        BLU.CreateModulesPanel()
    end
    
    -- Profiles Panel
    if BLU.CreateProfilesPanel then
        BLU.CreateProfilesPanel()
    end
    
    -- Advanced Panel
    if BLU.CreateAdvancedPanel then
        BLU.CreateAdvancedPanel()
    end
    
    -- About Panel
    if BLU.CreateAboutPanel then
        BLU.CreateAboutPanel()
    end
end

-- Open the options panel through Interface Options
function InterfaceOptions:Open()
    if not self.panel then
        self:CreatePanel()
    end
    
    -- Modern WoW Settings API
    if Settings and Settings.OpenToCategory and self.category then
        Settings.OpenToCategory(self.category:GetID())
    
    -- Fallback to legacy API
    elseif InterfaceOptionsFrame_OpenToCategory then
        -- Call twice due to old WoW bug
        InterfaceOptionsFrame_OpenToCategory(self.panel)
        InterfaceOptionsFrame_OpenToCategory(self.panel)
    
    -- Direct show as last resort
    elseif InterfaceOptionsFrame then
        InterfaceOptionsFrame:Show()
        InterfaceOptionsFrame_OpenToCategory(self.panel)
    else
        BLU:PrintError("Unable to open Interface Options")
    end
end

-- Initialize on addon load
function InterfaceOptions:Init()
    -- Wait for PLAYER_LOGIN to ensure everything is loaded
    local loader = CreateFrame("Frame")
    loader:RegisterEvent("PLAYER_LOGIN")
    loader:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_LOGIN" then
            InterfaceOptions:CreatePanel()
            self:UnregisterEvent("PLAYER_LOGIN")
        end
    end)
    
    -- Override the slash command to use Interface Options
    SLASH_BLU1 = "/blu"
    SLASH_BLU2 = "/betterlu"
    SlashCmdList["BLU"] = function(msg)
        msg = msg:trim():lower()
        
        if msg == "" or msg == "options" or msg == "config" then
            InterfaceOptions:Open()
        elseif msg == "test" then
            BLU:PlayTestSound("levelup")
        elseif msg == "debug" then
            BLU:ToggleDebug()
        elseif msg == "reload" then
            ReloadUI()
        elseif msg == "version" then
            BLU:Print("Version: " .. (GetAddOnMetadata and GetAddOnMetadata(addonName, "Version") or "6.0.0-alpha"))
        else
            BLU:Print("Usage: /blu - Open options")
            BLU:Print("       /blu test - Test sound")
            BLU:Print("       /blu debug - Toggle debug mode")
            BLU:Print("       /blu reload - Reload UI")
        end
    end
    
    BLU:PrintDebug("Interface Options integration initialized")
end

-- Export functions to BLU namespace
function BLU:OpenOptions()
    InterfaceOptions:Open()
end

function BLU:CreateInterfaceOptions()
    return InterfaceOptions:CreatePanel()
end

-- Initialize the module
InterfaceOptions:Init()

return InterfaceOptions