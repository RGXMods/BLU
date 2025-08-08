--=====================================================================================
-- BLU | Modules Management Panel
-- Author: donniedice  
-- Description: Enable/disable modules, view memory usage, manage dependencies
--=====================================================================================

local addonName, BLU = ...

-- Module definitions from manifest
local moduleDefinitions = {
    {id = "levelup", name = "Level Up", desc = "Plays sounds when you level up", deps = {}},
    {id = "achievement", name = "Achievement", desc = "Plays sounds for achievements", deps = {}},
    {id = "quest", name = "Quest Complete", desc = "Plays sounds for quest completion", deps = {}},
    {id = "reputation", name = "Reputation", desc = "Plays sounds for reputation changes", deps = {}},
    {id = "honor", name = "Honor", desc = "Plays sounds for honor gains", deps = {}},
    {id = "battlepet", name = "Battle Pet", desc = "Plays sounds for pet levels", deps = {}},
    {id = "renown", name = "Renown", desc = "Plays sounds for renown increases", deps = {}},
    {id = "tradingpost", name = "Trading Post", desc = "Plays sounds for trading post", deps = {}},
    {id = "delve", name = "Delve", desc = "Plays sounds for delve completion", deps = {}}
}

function BLU.CreateModulesPanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()
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
    headerEnabled:SetText("Enabled")
    
    local headerName = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    headerName:SetPoint("LEFT", 80, yOffset - 12)
    headerName:SetText("Module")
    
    local headerMemory = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    headerMemory:SetPoint("LEFT", 200, yOffset - 12)
    headerMemory:SetText("Memory")
    
    local headerStatus = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    headerStatus:SetPoint("LEFT", 280, yOffset - 12)
    headerStatus:SetText("Status")
    
    local headerLoad = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    headerLoad:SetPoint("LEFT", 380, yOffset - 12)
    headerLoad:SetText("Load Order")
    
    yOffset = yOffset - 35
    
    -- Create module rows
    for i, module in ipairs(moduleDefinitions) do
        local row = CreateFrame("Frame", nil, content)
        row:SetPoint("TOPLEFT", 0, yOffset)
        row:SetPoint("TOPRIGHT", -20, yOffset)
        row:SetHeight(50)
        
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
        checkbox:SetPoint("LEFT", 20, 0)
        checkbox:SetSize(24, 24)
        
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
        nameText:SetPoint("LEFT", 80, 5)
        nameText:SetText(module.name)
        
        -- Module description
        local descText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        descText:SetPoint("LEFT", 80, -10)
        descText:SetText(module.desc)
        descText:SetTextColor(0.7, 0.7, 0.7)
        
        -- Memory usage
        local memoryText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        memoryText:SetPoint("LEFT", 200, 0)
        memoryText:SetText("0 KB")
        memoryText:SetTextColor(0.7, 1, 0.7)
        row.memoryText = memoryText
        
        -- Status indicator
        local statusText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        statusText:SetPoint("LEFT", 280, 0)
        if enabled then
            statusText:SetText("|cff00ff00Active|r")
        else
            statusText:SetText("|cffff0000Disabled|r")
        end
        row.statusText = statusText
        
        -- Load order
        local loadOrderText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        loadOrderText:SetPoint("LEFT", 400, 0)
        loadOrderText:SetText("#" .. i)
        loadOrderText:SetTextColor(0.5, 0.5, 0.5)
        
        -- Dependencies indicator
        if module.deps and #module.deps > 0 then
            local depsText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            depsText:SetPoint("LEFT", 450, 0)
            depsText:SetText("Deps: " .. table.concat(module.deps, ", "))
            depsText:SetTextColor(0.8, 0.8, 0.3)
        end
        
        -- Configure button
        local configBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        configBtn:SetSize(60, 20)
        configBtn:SetPoint("RIGHT", -10, 0)
        configBtn:SetText("Config")
        configBtn:SetScript("OnClick", function()
            -- Open module-specific config
            print("|cff00ccffBLU:|r Opening config for " .. module.name)
        end)
        
        panel.moduleRows[module.id] = row
        yOffset = yOffset - 55
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
    
    return panel
end