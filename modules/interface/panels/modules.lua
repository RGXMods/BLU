--=====================================================================================
-- BLU - interface/panels/modules.lua
-- Module management panel with enhanced visuals
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateModulesPanel(panel)
    local widgets = BLU.Widgets
    
    -- Create scrollable content
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth(), 600)
    scrollFrame:SetScrollChild(content)
    
    -- Module Management header with icon
    local header = widgets:CreateHeader(content, "|TInterface\\Icons\\INV_Misc_Gear_08:20:20|t Module Management")
    header:SetPoint("TOPLEFT", 0, 0)
    
    local divider = widgets:CreateDivider(content)
    divider:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -5)
    
    -- Info text
    local info = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    info:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 0, -10)
    info:SetWidth(550)
    info:SetJustifyH("LEFT")
    info:SetText("Enable or disable specific BLU features. Disabled modules won't use any resources.")
    
    -- Quick actions
    local actionBar = CreateFrame("Frame", nil, content)
    actionBar:SetPoint("TOPLEFT", info, "BOTTOMLEFT", 0, -15)
    actionBar:SetSize(550, 30)
    
    -- Module list (defined before buttons)
    local moduleList = {
        {
            category = "Core Features",
            icon = "|TInterface\\Icons\\Achievement_General:20:20|t",
            modules = {
                {id = "levelup", name = "Level Up", desc = "Play sounds when you gain a level", icon = "Achievement_Level_100"},
                {id = "achievement", name = "Achievements", desc = "Play sounds when you earn achievements", icon = "Achievement_GuildPerk_MobileMailbox"},
                {id = "quest", name = "Quest Complete", desc = "Play sounds when you complete quests", icon = "INV_Misc_Note_01"},
                {id = "reputation", name = "Reputation", desc = "Play sounds when you gain reputation", icon = "Achievement_Reputation_01"}
            }
        },
        {
            category = "PvP Features",
            icon = "|TInterface\\Icons\\Achievement_PVP_A_A:20:20|t",
            modules = {
                {id = "honorrank", name = "Honor Rank", desc = "Play sounds when you gain honor ranks", icon = "PVPCurrency-Honor-Horde"},
                {id = "renownrank", name = "Renown Rank", desc = "Play sounds when you gain renown", icon = "UI_MajorFaction_Centaur"}
            }
        },
        {
            category = "Special Features",
            icon = "|TInterface\\Icons\\INV_Misc_Coin_01:20:20|t",
            modules = {
                {id = "tradingpost", name = "Trading Post", desc = "Play sounds for trading post rewards", icon = "INV_Tradingpost_Currency"},
                {id = "battlepet", name = "Battle Pets", desc = "Play sounds for pet battle victories", icon = "INV_Pet_BattlePetTraining"},
                {id = "delvecompanion", name = "Delve Companion", desc = "Play sounds for delve companion events", icon = "UI_MajorFaction_Delve"}
            }
        }
    }
    
    local enableAllBtn = widgets:CreateButton(actionBar, "Enable All", 90, 22, "Enable all modules")
    enableAllBtn:SetPoint("LEFT", 0, 0)
    enableAllBtn:SetScript("OnClick", function()
        for _, category in ipairs(moduleList) do
            for _, module in ipairs(category.modules) do
                if BLU.db.profile.modules then
                    BLU.db.profile.modules[module.id] = true
                end
            end
        end
        if BLU.Tabs and BLU.Tabs.RefreshCurrentTab then
            BLU.Tabs:RefreshCurrentTab()
        end
    end)
    
    local disableAllBtn = widgets:CreateButton(actionBar, "Disable All", 90, 22, "Disable all modules")
    disableAllBtn:SetPoint("LEFT", enableAllBtn, "RIGHT", 5, 0)
    disableAllBtn:SetScript("OnClick", function()
        for _, category in ipairs(moduleList) do
            for _, module in ipairs(category.modules) do
                if BLU.db.profile.modules then
                    BLU.db.profile.modules[module.id] = false
                end
            end
        end
        if BLU.Tabs and BLU.Tabs.RefreshCurrentTab then
            BLU.Tabs:RefreshCurrentTab()
        end
    end)
    
    -- Ensure modules table exists
    BLU.db.profile.modules = BLU.db.profile.modules or {}
    
    local yOffset = 0
    local categoryStartY = select(5, actionBar:GetPoint())
    
    for catIndex, category in ipairs(moduleList) do
        -- Category header
        local catHeader = widgets:CreateHeader(content, category.icon .. " " .. category.category)
        catHeader:SetPoint("TOPLEFT", 0, categoryStartY - 40 - yOffset)
        
        local catDivider = widgets:CreateDivider(content)
        catDivider:SetPoint("TOPLEFT", catHeader, "BOTTOMLEFT", 0, -5)
        
        yOffset = yOffset + 40
        
        for modIndex, module in ipairs(category.modules) do
            -- Module frame with background
            local modFrame = CreateFrame("Frame", nil, content)
            modFrame:SetPoint("TOPLEFT", 10, categoryStartY - 40 - yOffset - (modIndex * 60))
            modFrame:SetSize(520, 55)
            
            -- Alternating background
            if modIndex % 2 == 0 then
                local bg = modFrame:CreateTexture(nil, "BACKGROUND")
                bg:SetAllPoints()
                bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
            end
            
            -- Module icon
            local icon = modFrame:CreateTexture(nil, "ARTWORK")
            icon:SetSize(32, 32)
            icon:SetPoint("LEFT", 10, 0)
            icon:SetTexture("Interface\\Icons\\" .. module.icon)
            
            -- Module name
            local name = modFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            name:SetPoint("LEFT", icon, "RIGHT", 10, 8)
            name:SetText(module.name)
            
            -- Module description
            local desc = modFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            desc:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
            desc:SetText(module.desc)
            desc:SetTextColor(0.7, 0.7, 0.7)
            
            -- Status indicator
            local status = modFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            status:SetPoint("RIGHT", modFrame, "RIGHT", -100, 0)
            
            -- Enable/Disable checkbox styled as switch
            local switchBg = CreateFrame("Frame", nil, modFrame)
            switchBg:SetSize(50, 24)
            switchBg:SetPoint("RIGHT", modFrame, "RIGHT", -20, 0)
            
            local switchBgTex = switchBg:CreateTexture(nil, "BACKGROUND")
            switchBgTex:SetAllPoints()
            switchBgTex:SetColorTexture(0.2, 0.2, 0.2, 0.8)
            
            local switch = CreateFrame("CheckButton", nil, switchBg)
            switch:SetSize(24, 24)
            switch:SetHitRectInsets(-13, -13, 0, 0)
            
            local switchTex = switch:CreateTexture(nil, "ARTWORK")
            switchTex:SetAllPoints()
            switchTex:SetColorTexture(0.5, 0.5, 0.5, 1)
            
            -- Initialize state
            local isEnabled = BLU.db.profile.modules[module.id] ~= false
            switch:SetChecked(isEnabled)
            
            if isEnabled then
                switch:SetPoint("RIGHT", switchBg, "RIGHT", 0, 0)
                switchBgTex:SetColorTexture(0.02, 0.37, 1, 0.8)
                switchTex:SetColorTexture(1, 1, 1, 1)
                status:SetText("|cff00ff00ENABLED|r")
            else
                switch:SetPoint("LEFT", switchBg, "LEFT", 0, 0)
                switchBgTex:SetColorTexture(0.2, 0.2, 0.2, 0.8)
                switchTex:SetColorTexture(0.5, 0.5, 0.5, 1)
                status:SetText("|cffff0000DISABLED|r")
            end
            
            switch:SetScript("OnClick", function(self)
                local enabled = self:GetChecked()
                BLU.db.profile.modules[module.id] = enabled
                
                if enabled then
                    self:SetPoint("RIGHT", switchBg, "RIGHT", 0, 0)
                    switchBgTex:SetColorTexture(0.02, 0.37, 1, 0.8)
                    switchTex:SetColorTexture(1, 1, 1, 1)
                    status:SetText("|cff00ff00ENABLED|r")
                    
                    -- Load the module
                    if BLU.LoadModule then
                        BLU:LoadModule("features", module.id)
                    end
                else
                    self:SetPoint("LEFT", switchBg, "LEFT", 0, 0)
                    switchBgTex:SetColorTexture(0.2, 0.2, 0.2, 0.8)
                    switchTex:SetColorTexture(0.5, 0.5, 0.5, 1)
                    status:SetText("|cffff0000DISABLED|r")
                    
                    -- Unload the module
                    if BLU.UnloadModule then
                        BLU:UnloadModule(module.id)
                    end
                end
            end)
            
            -- Hover effect
            modFrame:SetScript("OnEnter", function(self)
                if not self.highlight then
                    self.highlight = self:CreateTexture(nil, "HIGHLIGHT")
                    self.highlight:SetAllPoints()
                    self.highlight:SetColorTexture(1, 1, 1, 0.1)
                end
            end)
            modFrame:SetScript("OnLeave", function(self)
                if self.highlight then
                    self.highlight:Hide()
                end
            end)
        end
        
        yOffset = yOffset + (#category.modules * 60) + 20
    end
    
    -- Performance info
    local perfHeader = widgets:CreateHeader(content, "|TInterface\\Icons\\Spell_Nature_TimeStop:20:20|t Performance Information")
    perfHeader:SetPoint("TOPLEFT", 0, categoryStartY - 40 - yOffset - 20)
    
    local perfDivider = widgets:CreateDivider(content)
    perfDivider:SetPoint("TOPLEFT", perfHeader, "BOTTOMLEFT", 0, -5)
    
    local perfInfo = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    perfInfo:SetPoint("TOPLEFT", perfDivider, "BOTTOMLEFT", 0, -10)
    perfInfo:SetWidth(520)
    perfInfo:SetJustifyH("LEFT")
    perfInfo:SetText("Disabling unused modules can improve performance and reduce memory usage. Modules are loaded/unloaded in real-time without requiring a reload.")
    
    content:SetHeight(yOffset + 200)
end