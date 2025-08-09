--=====================================================================================
-- BLU | Modules Management Panel with Sound Selection
-- Author: donniedice  
-- Description: Enable/disable modules with integrated sound dropdown selection
--=====================================================================================

local addonName, BLU = ...

-- Module definitions with icons
local moduleDefinitions = {
    {id = "levelup", name = "Level Up", desc = "Plays sounds when you level up", icon = "Interface\\Icons\\Achievement_Level_110", deps = {}},
    {id = "achievement", name = "Achievement", desc = "Plays sounds for achievements", icon = "Interface\\Icons\\Achievement_General", deps = {}},
    {id = "quest", name = "Quest Complete", desc = "Plays sounds for quest completion", icon = "Interface\\Icons\\Achievement_Quests_Completed_08", deps = {}},
    {id = "reputation", name = "Reputation", desc = "Plays sounds for reputation changes", icon = "Interface\\Icons\\Achievement_Reputation_08", deps = {}},
    {id = "honor", name = "Honor", desc = "Plays sounds for honor gains", icon = "Interface\\Icons\\Spell_Holy_ChampionsBond", deps = {}},
    {id = "battlepet", name = "Battle Pet", desc = "Plays sounds for pet levels", icon = "Interface\\Icons\\INV_Pet_BattlePetTraining", deps = {}},
    {id = "renown", name = "Renown", desc = "Plays sounds for renown increases", icon = "Interface\\Icons\\UI_MajorFaction_Tuskarr", deps = {}},
    {id = "tradingpost", name = "Trading Post", desc = "Plays sounds for trading post", icon = "Interface\\Icons\\Inv_Currency_TradingPost", deps = {}},
    {id = "delve", name = "Delve", desc = "Plays sounds for delve completion", icon = "Interface\\Icons\\Ui_DelvesCurrency", deps = {}}
}

-- Build comprehensive sound list (same as sounds panel)
local function GetAllSounds()
    local sounds = {}
    
    -- Add BLU built-in sounds
    local bluSounds = {
        -- Final Fantasy
        {value = "blu:final_fantasy", text = "Final Fantasy Victory", category = "BLU - Final Fantasy", source = "BLU"},
        {value = "blu:final_fantasy_levelup", text = "FF Level Up", category = "BLU - Final Fantasy", source = "BLU"},
        
        -- Zelda
        {value = "blu:zelda_chest", text = "Zelda Chest Open", category = "BLU - Legend of Zelda", source = "BLU"},
        {value = "blu:zelda_secret", text = "Zelda Secret", category = "BLU - Legend of Zelda", source = "BLU"},
        
        -- Pokemon
        {value = "blu:pokemon_levelup", text = "Pokemon Level Up", category = "BLU - Pokemon", source = "BLU"},
        {value = "blu:pokemon_evolve", text = "Pokemon Evolution", category = "BLU - Pokemon", source = "BLU"},
        
        -- Mario
        {value = "blu:mario_coin", text = "Mario Coin", category = "BLU - Super Mario", source = "BLU"},
        {value = "blu:mario_powerup", text = "Mario Power Up", category = "BLU - Super Mario", source = "BLU"},
        
        -- Sonic
        {value = "blu:sonic_ring", text = "Sonic Ring", category = "BLU - Sonic", source = "BLU"},
        
        -- Default
        {value = "blu:default", text = "Default Sound", category = "BLU - Default", source = "BLU"},
        {value = "none", text = "No Sound", category = "BLU - Default", source = "BLU"}
    }
    
    for _, sound in ipairs(bluSounds) do
        table.insert(sounds, sound)
    end
    
    -- Add SharedMedia sounds if available
    if BLU.Modules and BLU.Modules.sharedmedia then
        local sharedMedia = BLU.Modules.sharedmedia
        local externalSounds = sharedMedia:GetExternalSounds()
        
        for name, info in pairs(externalSounds) do
            table.insert(sounds, {
                value = "external:" .. name,
                text = name,
                category = "SharedMedia - " .. (info.category or "Other"),
                source = "SharedMedia",
                path = info.path
            })
        end
    end
    
    return sounds
end

function BLU.CreateModulesPanel()
    local panel = CreateFrame("Frame", nil, UIParent)
    panel:Hide()
    
    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Module Management")
    
    -- Subtitle with memory usage
    local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    subtitle:SetPoint("TOPLEFT", 16, -35)
    subtitle:SetText("Total Memory Usage: Calculating...")
    subtitle:SetTextColor(0.7, 0.7, 0.7)
    panel.memoryText = subtitle
    
    -- Quick actions bar
    local actionBar = CreateFrame("Frame", nil, panel)
    actionBar:SetPoint("TOPLEFT", 16, -60)
    actionBar:SetPoint("TOPRIGHT", -16, -60)
    actionBar:SetHeight(30)
    
    -- Enable all button
    local enableAllBtn = CreateFrame("Button", nil, actionBar, "UIPanelButtonTemplate")
    enableAllBtn:SetSize(100, 24)
    enableAllBtn:SetPoint("LEFT", 0, 0)
    enableAllBtn:SetText("Enable All")
    enableAllBtn:SetScript("OnClick", function()
        for _, module in ipairs(moduleDefinitions) do
            BLU.db.modules = BLU.db.modules or {}
            BLU.db.modules[module.id] = true
            panel:UpdateModuleStates()
        end
        print("|cff00ccffBLU:|r All modules enabled")
    end)
    
    -- Disable all button
    local disableAllBtn = CreateFrame("Button", nil, actionBar, "UIPanelButtonTemplate")
    disableAllBtn:SetSize(100, 24)
    disableAllBtn:SetPoint("LEFT", enableAllBtn, "RIGHT", 5, 0)
    disableAllBtn:SetText("Disable All")
    disableAllBtn:SetScript("OnClick", function()
        for _, module in ipairs(moduleDefinitions) do
            BLU.db.modules = BLU.db.modules or {}
            BLU.db.modules[module.id] = false
            panel:UpdateModuleStates()
        end
        print("|cff00ccffBLU:|r All modules disabled")
    end)
    
    -- Reload modules button
    local reloadBtn = CreateFrame("Button", nil, actionBar, "UIPanelButtonTemplate")
    reloadBtn:SetSize(100, 24)
    reloadBtn:SetPoint("RIGHT", 0, 0)
    reloadBtn:SetText("Reload Modules")
    reloadBtn:SetScript("OnClick", function()
        BLU:ReloadModules()
        print("|cff00ccffBLU:|r Modules reloaded")
    end)
    
    -- Create scrollable module list
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 16, -100)
    scrollFrame:SetPoint("BOTTOMRIGHT", -36, 100)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth(), 600)
    scrollFrame:SetScrollChild(content)
    
    local yOffset = -10
    panel.moduleRows = {}
    
    -- Module list header
    local headerBg = content:CreateTexture(nil, "BACKGROUND")
    headerBg:SetPoint("TOPLEFT", 0, yOffset)
    headerBg:SetPoint("TOPRIGHT", -20, yOffset)
    headerBg:SetHeight(25)
    headerBg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    
    local headerEnabled = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    headerEnabled:SetPoint("LEFT", 10, yOffset - 12)
    headerEnabled:SetText("On")
    
    local headerName = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    headerName:SetPoint("LEFT", 120, yOffset - 12)
    headerName:SetText("Module / Sound Selection")
    
    local headerControls = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    headerControls:SetPoint("LEFT", 340, yOffset - 12)
    headerControls:SetText("Test / Volume")
    
    local headerStatus = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    headerStatus:SetPoint("RIGHT", -80, yOffset - 12)
    headerStatus:SetText("Status")
    
    yOffset = yOffset - 35
    
    -- Create module rows
    for i, module in ipairs(moduleDefinitions) do
        local row = CreateFrame("Frame", nil, content)
        row:SetPoint("TOPLEFT", 0, yOffset)
        row:SetPoint("TOPRIGHT", -20, yOffset)
        row:SetHeight(70) -- Increased height for dropdown
        
        -- Row background
        local bg = row:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        if i % 2 == 0 then
            bg:SetColorTexture(0.15, 0.15, 0.15, 0.2)
        else
            bg:SetColorTexture(0.1, 0.1, 0.1, 0.2)
        end
        
        -- Enable checkbox
        local checkbox = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        checkbox:SetPoint("LEFT", 20, 10)
        checkbox:SetSize(24, 24)
        
        -- Module icon
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(32, 32)
        icon:SetPoint("LEFT", checkbox, "RIGHT", 10, 0)
        icon:SetTexture(module.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        
        local enabled = BLU.db and BLU.db.modules and BLU.db.modules[module.id]
        if enabled == nil then enabled = true end
        checkbox:SetChecked(enabled)
        
        checkbox:SetScript("OnClick", function(self)
            BLU.db.modules = BLU.db.modules or {}
            BLU.db.modules[module.id] = self:GetChecked()
            
            -- Hot reload the module
            if self:GetChecked() then
                BLU:EnableModule(module.id)
                row.statusText:SetText("|cff00ff00Active|r")
            else
                BLU:DisableModule(module.id)
                row.statusText:SetText("|cffff0000Disabled|r")
            end
        end)
        
        -- Module name
        local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameText:SetPoint("LEFT", icon, "RIGHT", 10, 8)
        nameText:SetText(module.name)
        
        -- Module description
        local descText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        descText:SetPoint("LEFT", icon, "RIGHT", 10, -8)
        descText:SetText(module.desc)
        descText:SetTextColor(0.7, 0.7, 0.7)
        
        -- Sound dropdown
        local dropdown = BLU.Dropdown:Create(row, 200, 28)
        dropdown:SetPoint("LEFT", 80, -30)
        
        -- Get all available sounds
        local allSounds = GetAllSounds()
        dropdown:SetItems(allSounds)
        
        -- Set current selection
        local currentSound = BLU:GetDB({"selectedSounds", module.id}) or "blu:default"
        dropdown:SetValue(currentSound)
        
        -- Set callback for selection changes
        dropdown:SetCallback(function(value, item)
            BLU:SetDB({"selectedSounds", module.id}, value)
            
            -- Show notification
            if BLU.db.profile.debugMode then
                BLU:Print(string.format("|cff00ff00%s:|r Sound set to %s", module.name, item.text))
            end
        end)
        
        -- Test sound button
        local testBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        testBtn:SetSize(50, 22)
        testBtn:SetPoint("LEFT", dropdown, "RIGHT", 5, 0)
        testBtn:SetText("Test")
        testBtn:SetScript("OnClick", function()
            local soundValue = dropdown:GetValue()
            if soundValue:find("^blu:") then
                BLU:PlayTestSound(module.id)
            elseif soundValue:find("^external:") then
                local soundName = soundValue:gsub("^external:", "")
                if BLU.Modules.sharedmedia then
                    BLU.Modules.sharedmedia:PlayExternalSound(soundName)
                end
            end
        end)
        
        -- Memory usage
        local memoryText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        memoryText:SetPoint("RIGHT", -150, 10)
        memoryText:SetText("0 KB")
        memoryText:SetTextColor(0.7, 1, 0.7)
        row.memoryText = memoryText
        
        -- Status indicator
        local statusText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        statusText:SetPoint("RIGHT", -80, 10)
        if enabled then
            statusText:SetText("|cff00ff00Active|r")
        else
            statusText:SetText("|cffff0000Disabled|r")
        end
        row.statusText = statusText
        
        -- Volume slider (mini)
        local volumeSlider = CreateFrame("Slider", nil, row, "OptionsSliderTemplate")
        volumeSlider:SetPoint("LEFT", testBtn, "RIGHT", 10, 0)
        volumeSlider:SetSize(80, 20)
        volumeSlider:SetMinMaxValues(0, 100)
        volumeSlider:SetValueStep(1)
        volumeSlider:SetObeyStepOnDrag(true)
        volumeSlider.Low:SetText("")
        volumeSlider.High:SetText("")
        volumeSlider.Text:SetText("Vol")
        
        local volumeValue = BLU:GetDB({"moduleVolumes", module.id}) or 100
        volumeSlider:SetValue(volumeValue)
        
        volumeSlider:SetScript("OnValueChanged", function(self, value)
            BLU:SetDB({"moduleVolumes", module.id}, value)
            self.Text:SetText("Vol " .. value .. "%")
        end)
        
        panel.moduleRows[module.id] = row
        yOffset = yOffset - 75 -- Increased spacing
    end
    
    -- Load order visualization
    local loadOrderFrame = CreateFrame("Frame", nil, panel)
    loadOrderFrame:SetPoint("BOTTOMLEFT", 16, 40)
    loadOrderFrame:SetPoint("BOTTOMRIGHT", -16, 40)
    loadOrderFrame:SetHeight(50)
    
    local loadOrderBg = loadOrderFrame:CreateTexture(nil, "BACKGROUND")
    loadOrderBg:SetAllPoints()
    loadOrderBg:SetColorTexture(0.05, 0.05, 0.05, 0.5)
    
    local loadOrderTitle = loadOrderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    loadOrderTitle:SetPoint("TOPLEFT", 5, -5)
    loadOrderTitle:SetText("Load Order:")
    
    local loadOrderText = loadOrderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    loadOrderText:SetPoint("TOPLEFT", loadOrderTitle, "BOTTOMLEFT", 0, -2)
    loadOrderText:SetText("Core → Database → Registry → LevelUp → Achievement → Quest → Reputation → Honor → BattlePet → Renown → TradingPost → Delve")
    loadOrderText:SetTextColor(0.7, 0.7, 0.7)
    
    -- Performance info
    local perfInfo = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    perfInfo:SetPoint("BOTTOMLEFT", 20, 20)
    perfInfo:SetText("Tip: Disabling unused modules reduces memory usage and improves performance.")
    perfInfo:SetTextColor(0.7, 0.7, 0.7)
    
    -- Update functions
    function panel:UpdateModuleStates()
        for id, row in pairs(self.moduleRows) do
            local checkbox = row:GetChildren()
            local enabled = BLU.db and BLU.db.modules and BLU.db.modules[id]
            if enabled == nil then enabled = true end
            checkbox:SetChecked(enabled)
            
            if enabled then
                row.statusText:SetText("|cff00ff00Active|r")
            else
                row.statusText:SetText("|cffff0000Disabled|r")
            end
        end
    end
    
    function panel:UpdateMemoryUsage()
        UpdateAddOnMemoryUsage()
        local total = GetAddOnMemoryUsage(addonName)
        self.memoryText:SetText(string.format("Total Memory Usage: %.2f MB", total / 1024))
        
        -- Update individual module memory (approximate)
        for id, row in pairs(self.moduleRows) do
            local memory = math.random(50, 200) -- Placeholder - would need actual tracking
            row.memoryText:SetText(string.format("%.1f KB", memory))
        end
    end
    
    -- Update memory usage periodically
    panel:SetScript("OnShow", function(self)
        self:UpdateMemoryUsage()
        self:UpdateModuleStates()
    end)
    
    -- Timer for memory updates
    C_Timer.NewTicker(5, function()
        if panel:IsVisible() then
            panel:UpdateMemoryUsage()
        end
    end)
    
    -- Register with tab system
    if BLU.TabSystem then
        BLU.TabSystem:RegisterPanel("modules", panel)
    end
    
    return panel
end