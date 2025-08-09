--=====================================================================================
-- BLU | Integrated Interface Options
-- Author: donniedice
-- Description: BLU options integrated into WoW's Interface Options panel
--=====================================================================================

local addonName, BLU = ...

-- Create the main panel that goes in Interface Options
local function CreateIntegratedPanel()
    if BLU.MainPanel then
        return BLU.MainPanel
    end
    
    -- Create main panel
    local mainPanel = CreateFrame("Frame", "BLUMainOptionsPanel", UIParent)
    mainPanel.name = "Better Level-Up!"
    
    -- Title
    local title = mainPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("|cff05dffaB|retter |cff05dffaL|revel-|cff05dffaU|rp!")
    
    local subtitle = mainPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Sound replacement addon for World of Warcraft")
    
    -- General settings on main panel
    local generalTitle = mainPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    generalTitle:SetPoint("TOPLEFT", 16, -80)
    generalTitle:SetText("General Settings")
    generalTitle:SetTextColor(0, 0.8, 1)
    
    -- Enable checkbox
    local enableCheck = CreateFrame("CheckButton", nil, mainPanel, "UICheckButtonTemplate")
    enableCheck:SetPoint("TOPLEFT", 20, -110)
    enableCheck.text = enableCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableCheck.text:SetPoint("LEFT", enableCheck, "RIGHT", 5, 0)
    enableCheck.text:SetText("Enable BLU Sound System")
    enableCheck:SetChecked(BLU.db and BLU.db.enabled ~= false)
    enableCheck:SetScript("OnClick", function(self)
        if BLU.db then
            BLU.db.enabled = self:GetChecked()
        end
    end)
    
    -- Master Volume
    local volumeTitle = mainPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    volumeTitle:SetPoint("TOPLEFT", 20, -150)
    volumeTitle:SetText("Master Volume:")
    
    local volumeSlider = CreateFrame("Slider", nil, mainPanel, "OptionsSliderTemplate")
    volumeSlider:SetPoint("TOPLEFT", 30, -170)
    volumeSlider:SetSize(300, 20)
    volumeSlider:SetMinMaxValues(0, 100)
    volumeSlider:SetValueStep(1)
    volumeSlider:SetObeyStepOnDrag(true)
    volumeSlider.Low:SetText("0")
    volumeSlider.High:SetText("100")
    volumeSlider.Text:SetText("")
    volumeSlider:SetValue(BLU.db and BLU.db.soundVolume or 100)
    
    local volumeValue = volumeSlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    volumeValue:SetPoint("LEFT", volumeSlider, "RIGHT", 10, 0)
    volumeValue:SetText(string.format("%d%%", BLU.db and BLU.db.soundVolume or 100))
    volumeSlider.valueDisplay = volumeValue
    
    volumeSlider:SetScript("OnValueChanged", function(self, value)
        if BLU.db then
            BLU.db.soundVolume = value
        end
        self.valueDisplay:SetText(string.format("%d%%", value))
    end)
    
    -- Test button
    local testBtn = CreateFrame("Button", nil, mainPanel, "UIPanelButtonTemplate")
    testBtn:SetSize(80, 22)
    testBtn:SetPoint("LEFT", volumeValue, "RIGHT", 20, 0)
    testBtn:SetText("Test")
    testBtn:SetScript("OnClick", function()
        if BLU.PlayTestSound then
            BLU:PlayTestSound("levelup", volumeSlider:GetValue())
        else
            print("|cff00ccffBLU:|r Playing test sound...")
        end
    end)
    
    -- Quick settings
    local quickTitle = mainPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    quickTitle:SetPoint("TOPLEFT", 16, -220)
    quickTitle:SetText("Quick Settings")
    quickTitle:SetTextColor(0, 0.8, 1)
    
    -- Debug mode
    local debugCheck = CreateFrame("CheckButton", nil, mainPanel, "UICheckButtonTemplate")
    debugCheck:SetPoint("TOPLEFT", 20, -250)
    debugCheck.text = debugCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    debugCheck.text:SetPoint("LEFT", debugCheck, "RIGHT", 5, 0)
    debugCheck.text:SetText("Enable debug messages")
    debugCheck:SetChecked(BLU.db and BLU.db.debugMode or false)
    debugCheck:SetScript("OnClick", function(self)
        if BLU.db then
            BLU.db.debugMode = self:GetChecked()
        end
    end)
    
    -- Random variations
    local randomCheck = CreateFrame("CheckButton", nil, mainPanel, "UICheckButtonTemplate")
    randomCheck:SetPoint("TOPLEFT", 20, -280)
    randomCheck.text = randomCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    randomCheck.text:SetPoint("LEFT", randomCheck, "RIGHT", 5, 0)
    randomCheck.text:SetText("Enable random sound variations")
    randomCheck:SetChecked(BLU.db and BLU.db.randomSounds or false)
    randomCheck:SetScript("OnClick", function(self)
        if BLU.db then
            BLU.db.randomSounds = self:GetChecked()
        end
    end)
    
    BLU.MainPanel = mainPanel
    return mainPanel
end

-- Create sub-panels
local function CreateSoundsPanel()
    if BLU.SoundsPanel then
        return BLU.SoundsPanel
    end
    
    local panel = CreateFrame("Frame", "BLUSoundsPanel", UIParent)
    panel.name = "Sounds"
    panel.parent = "Better Level-Up!"
    
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Sound Configuration")
    
    local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    subtitle:SetPoint("TOPLEFT", 16, -40)
    subtitle:SetText("Configure sounds for each event type")
    subtitle:SetTextColor(0.7, 0.7, 0.7)
    
    -- Event sections
    local events = {
        {id = "levelup", name = "Level Up"},
        {id = "achievement", name = "Achievement"},
        {id = "quest", name = "Quest Complete"},
        {id = "reputation", name = "Reputation"}
    }
    
    local yOffset = -80
    for _, event in ipairs(events) do
        local eventTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        eventTitle:SetPoint("TOPLEFT", 20, yOffset)
        eventTitle:SetText(event.name .. ":")
        eventTitle:SetTextColor(0, 0.8, 1)
        
        local dropdown = CreateFrame("Frame", "BLU" .. event.id .. "Dropdown", panel, "UIDropDownMenuTemplate")
        dropdown:SetPoint("LEFT", eventTitle, "RIGHT", 10, 0)
        UIDropDownMenu_SetWidth(dropdown, 200)
        UIDropDownMenu_SetText(dropdown, "Default")
        
        yOffset = yOffset - 35
    end
    
    BLU.SoundsPanel = panel
    return panel
end

local function CreateModulesPanel()
    if BLU.ModulesPanel then
        return BLU.ModulesPanel
    end
    
    local panel = CreateFrame("Frame", "BLUModulesPanel", UIParent)
    panel.name = "Modules"
    panel.parent = "Better Level-Up!"
    
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Module Management")
    
    local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    subtitle:SetPoint("TOPLEFT", 16, -40)
    subtitle:SetText("Enable or disable BLU feature modules")
    subtitle:SetTextColor(0.7, 0.7, 0.7)
    
    -- Module list
    local modules = {
        {id = "levelup", name = "Level Up", desc = "Plays sounds when you level up"},
        {id = "achievement", name = "Achievement", desc = "Plays sounds for achievements"},
        {id = "quest", name = "Quest Complete", desc = "Plays sounds for quest completion"},
        {id = "reputation", name = "Reputation", desc = "Plays sounds for reputation changes"},
        {id = "honor", name = "Honor", desc = "Plays sounds for honor gains"},
        {id = "battlepet", name = "Battle Pet", desc = "Plays sounds for pet levels"}
    }
    
    local yOffset = -80
    for _, module in ipairs(modules) do
        local check = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
        check:SetPoint("TOPLEFT", 20, yOffset)
        check.text = check:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        check.text:SetPoint("LEFT", check, "RIGHT", 5, 0)
        check.text:SetText(module.name)
        check:SetChecked(true)
        
        local desc = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        desc:SetPoint("TOPLEFT", 45, yOffset - 20)
        desc:SetText(module.desc)
        desc:SetTextColor(0.7, 0.7, 0.7)
        
        yOffset = yOffset - 45
    end
    
    BLU.ModulesPanel = panel
    return panel
end

local function CreateProfilesPanel()
    if BLU.ProfilesPanel then
        return BLU.ProfilesPanel
    end
    
    local panel = CreateFrame("Frame", "BLUProfilesPanel", UIParent)
    panel.name = "Profiles"
    panel.parent = "Better Level-Up!"
    
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Profile Management")
    
    local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    subtitle:SetPoint("TOPLEFT", 16, -40)
    subtitle:SetText("Save and load sound configurations")
    subtitle:SetTextColor(0.7, 0.7, 0.7)
    
    -- Current profile
    local currentTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentTitle:SetPoint("TOPLEFT", 20, -80)
    currentTitle:SetText("Current Profile:")
    
    local profileDropdown = CreateFrame("Frame", "BLUProfileDropdown", panel, "UIDropDownMenuTemplate")
    profileDropdown:SetPoint("LEFT", currentTitle, "RIGHT", 10, 0)
    UIDropDownMenu_SetWidth(profileDropdown, 200)
    UIDropDownMenu_SetText(profileDropdown, "Default")
    
    -- Profile buttons
    local saveBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    saveBtn:SetSize(80, 22)
    saveBtn:SetPoint("TOPLEFT", 20, -120)
    saveBtn:SetText("Save")
    
    local newBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    newBtn:SetSize(80, 22)
    newBtn:SetPoint("LEFT", saveBtn, "RIGHT", 5, 0)
    newBtn:SetText("New")
    
    local deleteBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    deleteBtn:SetSize(80, 22)
    deleteBtn:SetPoint("LEFT", newBtn, "RIGHT", 5, 0)
    deleteBtn:SetText("Delete")
    
    BLU.ProfilesPanel = panel
    return panel
end

local function CreateAboutPanel()
    if BLU.AboutPanel then
        return BLU.AboutPanel
    end
    
    local panel = CreateFrame("Frame", "BLUAboutPanel", UIParent)
    panel.name = "About"
    panel.parent = "Better Level-Up!"
    
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("|cff00ccffBLU|r - Better Level-Up!")
    
    local version = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    version:SetPoint("TOPLEFT", 16, -50)
    version:SetText("Version: 6.0.0-alpha")
    
    local author = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    author:SetPoint("TOPLEFT", 16, -70)
    author:SetText("Author: donniedice")
    
    local email = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    email:SetPoint("TOPLEFT", 16, -90)
    email:SetText("Email: 60427166+donniedice@users.noreply.github.com")
    
    local desc = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOPLEFT", 16, -120)
    desc:SetPoint("RIGHT", -20, 0)
    desc:SetJustifyH("LEFT")
    desc:SetText("BLU replaces default World of Warcraft sounds with iconic audio from over 50 classic and modern games. Experience nostalgic level-up fanfares, achievement jingles, and quest completion sounds from your favorite gaming franchises.")
    
    local features = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    features:SetPoint("TOPLEFT", 16, -180)
    features:SetText("Features")
    features:SetTextColor(0, 0.8, 1)
    
    local featureList = {
        "• 50+ game sound packs including Final Fantasy, Zelda, Pokemon",
        "• Customizable volume controls for each event type",
        "• Profile system for saving configurations",
        "• Modular architecture for optimal performance",
        "• SharedMedia/SoundPak compatibility"
    }
    
    local yOffset = -210
    for _, feature in ipairs(featureList) do
        local text = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("TOPLEFT", 20, yOffset)
        text:SetText(feature)
        text:SetTextColor(0.8, 0.8, 0.8)
        yOffset = yOffset - 20
    end
    
    BLU.AboutPanel = panel
    return panel
end

-- Register panels when addon loads
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    -- Create all panels
    local mainPanel = CreateIntegratedPanel()
    local soundsPanel = CreateSoundsPanel()
    local modulesPanel = CreateModulesPanel()
    local profilesPanel = CreateProfilesPanel()
    local aboutPanel = CreateAboutPanel()
    
    -- Register with Interface Options
    -- Legacy method
    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(mainPanel)
        InterfaceOptions_AddCategory(soundsPanel)
        InterfaceOptions_AddCategory(modulesPanel)
        InterfaceOptions_AddCategory(profilesPanel)
        InterfaceOptions_AddCategory(aboutPanel)
    end
    
    -- Modern method
    if Settings and Settings.RegisterCanvasLayoutCategory then
        -- Main category
        local mainCategory = Settings.RegisterCanvasLayoutCategory(mainPanel, mainPanel.name)
        Settings.RegisterAddOnCategory(mainCategory)
        mainPanel.settingsCategory = mainCategory
        
        -- Sub-categories
        local soundsCategory = Settings.RegisterCanvasLayoutSubcategory(mainCategory, soundsPanel, soundsPanel.name)
        local modulesCategory = Settings.RegisterCanvasLayoutSubcategory(mainCategory, modulesPanel, modulesPanel.name)
        local profilesCategory = Settings.RegisterCanvasLayoutSubcategory(mainCategory, profilesPanel, profilesPanel.name)
        local aboutCategory = Settings.RegisterCanvasLayoutSubcategory(mainCategory, aboutPanel, aboutPanel.name)
    end
end)

-- Slash command to open Interface Options to BLU
SLASH_BLU1 = "/blu"
SlashCmdList["BLU"] = function(msg)
    msg = msg:trim():lower()
    
    if msg == "test" then
        print("|cff00ccffBLU:|r Playing test sound...")
        if BLU.PlayTestSound then
            BLU:PlayTestSound("levelup", BLU.db and BLU.db.soundVolume or 100)
        end
        return
    elseif msg == "debug" then
        if BLU.db then
            BLU.db.debugMode = not BLU.db.debugMode
            print("|cff00ccffBLU:|r Debug mode " .. (BLU.db.debugMode and "enabled" or "disabled"))
        end
        return
    end
    
    -- Open Interface Options to BLU panel
    local opened = false
    
    -- Try modern Settings API first
    if Settings and Settings.OpenToCategory then
        if BLU.MainPanel and BLU.MainPanel.settingsCategory then
            Settings.OpenToCategory(BLU.MainPanel.settingsCategory.ID)
            opened = true
        elseif Settings.OpenToCategory then
            Settings.OpenToCategory("Better Level-Up!")
            opened = true
        end
    end
    
    -- Try legacy method
    if not opened and InterfaceOptionsFrame_OpenToCategory then
        if BLU.MainPanel then
            InterfaceOptionsFrame_OpenToCategory(BLU.MainPanel)
            InterfaceOptionsFrame_OpenToCategory(BLU.MainPanel) -- Call twice (Blizzard bug workaround)
            opened = true
        end
    end
    
    -- Fallback: Just open Interface Options
    if not opened then
        if Settings and Settings.Open then
            Settings.Open()
            print("|cff00ccffBLU:|r Opening Settings - look for 'Better Level-Up!' in the addon list")
        elseif InterfaceOptionsFrame then
            InterfaceOptionsFrame:Show()
            print("|cff00ccffBLU:|r Opening Interface Options - look for 'Better Level-Up!' in the addon list")
        end
    end
end

print("|cff05dffaBLU|r loaded - Type |cffffff00/blu|r to open options")