--=====================================================================================
-- BLU - interface/panels/modules_new.lua
-- Module management panel with new design
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateModulesPanel(panel)
    -- Create scrollable content with proper sizing
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 20, -15)
    scrollFrame:SetPoint("BOTTOMRIGHT", -40, 15)
    
    -- Add scroll frame background
    local scrollBg = scrollFrame:CreateTexture(nil, "BACKGROUND")
    scrollBg:SetAllPoints()
    scrollBg:SetColorTexture(0.05, 0.05, 0.05, 0.3)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    -- Calculate proper content width based on scroll frame
    C_Timer.After(0.01, function()
        if scrollFrame:GetWidth() then
            content:SetSize(scrollFrame:GetWidth() - 25, 800)
        else
            content:SetSize(600, 800)
        end
    end)
    scrollFrame:SetScrollChild(content)
    
    -- Header
    local header = BLU.Design:CreateHeader(content, "Module Management", "Interface\\Icons\\INV_Misc_Gear_08")
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("RIGHT", -20, 0)
    
    -- Info text
    local infoText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    infoText:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -10)
    infoText:SetPoint("RIGHT", -20, 0)
    infoText:SetText("Enable or disable specific BLU features. Disabled modules won't use any resources and won't respond to game events.")
    infoText:SetJustifyH("LEFT")
    
    -- Quick actions
    local actionBar = CreateFrame("Frame", nil, content)
    actionBar:SetPoint("TOPLEFT", infoText, "BOTTOMLEFT", 0, -15)
    actionBar:SetSize(500, 30)
    
    local enableAllBtn = BLU.Design:CreateButton(actionBar, "Enable All", 100, 25)
    enableAllBtn:SetPoint("LEFT", 0, 0)
    
    local disableAllBtn = BLU.Design:CreateButton(actionBar, "Disable All", 100, 25)
    disableAllBtn:SetPoint("LEFT", enableAllBtn, "RIGHT", 10, 0)
    
    local defaultBtn = BLU.Design:CreateButton(actionBar, "Default Setup", 100, 25)
    defaultBtn:SetPoint("LEFT", disableAllBtn, "RIGHT", 10, 0)
    
    -- Module categories
    local categories = {
        {
            name = "Core Features",
            icon = "Interface\\Icons\\Achievement_General",
            modules = {
                {
                    id = "levelup",
                    name = "Level Up",
                    desc = "Play sounds when you gain a level",
                    icon = "Interface\\Icons\\Achievement_Level_100",
                    default = true
                },
                {
                    id = "achievement",
                    name = "Achievements",
                    desc = "Play sounds when you earn achievements",
                    icon = "Interface\\Icons\\Achievement_GuildPerk_MobileMailbox",
                    default = true
                },
                {
                    id = "quest",
                    name = "Quest Complete",
                    desc = "Play sounds when you complete quests",
                    icon = "Interface\\Icons\\INV_Misc_Note_01",
                    default = true
                },
                {
                    id = "reputation",
                    name = "Reputation",
                    desc = "Play sounds when you gain reputation",
                    icon = "Interface\\Icons\\Achievement_Reputation_01",
                    default = true
                }
            }
        },
        {
            name = "PvP Features",
            icon = "Interface\\Icons\\Achievement_PVP_A_A",
            modules = {
                {
                    id = "honorrank",
                    name = "Honor Rank",
                    desc = "Play sounds when you gain honor ranks",
                    icon = "Interface\\Icons\\PVPCurrency-Honor-Horde",
                    default = false
                },
                {
                    id = "renownrank",
                    name = "Renown Rank",
                    desc = "Play sounds when you gain renown with factions",
                    icon = "Interface\\Icons\\UI_MajorFaction_Centaur",
                    default = true
                }
            }
        },
        {
            name = "Special Features",
            icon = "Interface\\Icons\\INV_Misc_Coin_01",
            modules = {
                {
                    id = "tradingpost",
                    name = "Trading Post",
                    desc = "Play sounds for trading post rewards",
                    icon = "Interface\\Icons\\INV_Tradingpost_Currency",
                    default = false
                },
                {
                    id = "battlepet",
                    name = "Battle Pets",
                    desc = "Play sounds for pet battle victories and level ups",
                    icon = "Interface\\Icons\\INV_Pet_BattlePetTraining",
                    default = false
                },
                {
                    id = "delvecompanion",
                    name = "Delve Companion",
                    desc = "Play sounds for delve companion events",
                    icon = "Interface\\Icons\\UI_MajorFaction_Delve",
                    default = false
                }
            }
        }
    }
    
    -- Initialize modules table
    BLU.db.profile.modules = BLU.db.profile.modules or {}
    
    local yOffset = -80
    
    -- Create UI for each category
    for _, category in ipairs(categories) do
        -- Category section
        local section = BLU.Design:CreateSection(content, category.name, category.icon)
        section:SetPoint("TOPLEFT", 0, yOffset)
        section:SetPoint("RIGHT", -20, 0)
        section:SetHeight(40 + #category.modules * 55)
        
        local moduleY = -10
        
        for i, module in ipairs(category.modules) do
            -- Module frame
            local modFrame = CreateFrame("Frame", nil, section.content)
            modFrame:SetPoint("TOPLEFT", 0, moduleY)
            modFrame:SetPoint("RIGHT", 0, 0)
            modFrame:SetHeight(50)
            
            -- Hover highlight
            modFrame:EnableMouse(true)
            modFrame:SetScript("OnEnter", function(self)
                if not self.highlight then
                    self.highlight = self:CreateTexture(nil, "HIGHLIGHT")
                    self.highlight:SetAllPoints()
                    self.highlight:SetColorTexture(1, 1, 1, 0.05)
                end
                self.highlight:Show()
            end)
            modFrame:SetScript("OnLeave", function(self)
                if self.highlight then
                    self.highlight:Hide()
                end
            end)
            
            -- Icon
            local icon = modFrame:CreateTexture(nil, "ARTWORK")
            icon:SetSize(36, 36)
            icon:SetPoint("LEFT", 10, 0)
            icon:SetTexture(module.icon)
            
            -- Name
            local name = modFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            name:SetPoint("LEFT", icon, "RIGHT", 10, 10)
            name:SetText(module.name)
            
            -- Description
            local desc = modFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            desc:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
            desc:SetText(module.desc)
            desc:SetTextColor(0.7, 0.7, 0.7)
            
            -- Status text
            local status = modFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            status:SetPoint("RIGHT", modFrame, "RIGHT", -80, 0)
            
            -- Toggle switch
            local switchFrame = CreateFrame("Frame", nil, modFrame)
            switchFrame:SetSize(60, 24)
            switchFrame:SetPoint("RIGHT", -10, 0)
            
            -- Switch background
            local switchBg = switchFrame:CreateTexture(nil, "BACKGROUND")
            switchBg:SetAllPoints()
            switchBg:SetTexture("Interface\\Buttons\\WHITE8x8")
            
            -- Switch toggle
            local toggle = CreateFrame("Button", nil, switchFrame)
            toggle:SetSize(28, 28)
            toggle:EnableMouse(true)
            
            local toggleBg = toggle:CreateTexture(nil, "ARTWORK")
            toggleBg:SetAllPoints()
            toggleBg:SetTexture("Interface\\Buttons\\WHITE8x8")
            toggleBg:SetVertexColor(1, 1, 1, 1)
            
            -- Add glow effect
            local glow = toggle:CreateTexture(nil, "OVERLAY")
            glow:SetSize(32, 32)
            glow:SetPoint("CENTER")
            glow:SetTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
            glow:SetBlendMode("ADD")
            glow:SetAlpha(0)
            
            -- Module data
            toggle.moduleId = module.id
            toggle.statusText = status
            toggle.switchBg = switchBg
            toggle.glow = glow
            
            -- Initialize state
            local function UpdateToggleState(btn, enabled)
                if enabled then
                    btn:SetPoint("RIGHT", switchFrame, "RIGHT", -2, 0)
                    btn.switchBg:SetVertexColor(0.02, 0.37, 1, 1)
                    btn.statusText:SetText("|cff00ff00ENABLED|r")
                    btn.statusText:SetTextColor(0, 1, 0)
                else
                    btn:SetPoint("LEFT", switchFrame, "LEFT", 2, 0)
                    btn.switchBg:SetVertexColor(0.3, 0.3, 0.3, 1)
                    btn.statusText:SetText("|cffff0000DISABLED|r")
                    btn.statusText:SetTextColor(1, 0, 0)
                end
            end
            
            -- Set initial state
            local isEnabled = BLU.db.profile.modules[module.id] ~= false
            UpdateToggleState(toggle, isEnabled)
            
            -- Click handler
            toggle:SetScript("OnClick", function(self)
                local enabled = BLU.db.profile.modules[self.moduleId] ~= false
                enabled = not enabled
                BLU.db.profile.modules[self.moduleId] = enabled
                
                UpdateToggleState(self, enabled)
                
                -- Glow animation
                self.glow:SetAlpha(0.8)
                local fadeOut = self.glow:CreateAnimationGroup()
                local alpha = fadeOut:CreateAnimation("Alpha")
                alpha:SetFromAlpha(0.8)
                alpha:SetToAlpha(0)
                alpha:SetDuration(0.3)
                fadeOut:Play()
                
                -- Load/unload module
                if enabled then
                    if BLU.LoadModule then
                        BLU:LoadModule("features", self.moduleId)
                    end
                else
                    if BLU.UnloadModule then
                        BLU:UnloadModule(self.moduleId)
                    end
                end
            end)
            
            -- Store reference for quick actions
            modFrame.toggle = toggle
            modFrame.moduleData = module
            
            moduleY = moduleY - 55
        end
        
        -- Store section reference
        section.modules = category.modules
        content["section_" .. category.name:gsub(" ", "")] = section
        
        yOffset = yOffset - section:GetHeight() - 20
    end
    
    -- Quick action handlers
    enableAllBtn:SetScript("OnClick", function()
        for _, category in ipairs(categories) do
            for _, module in ipairs(category.modules) do
                BLU.db.profile.modules[module.id] = true
                if BLU.LoadModule then
                    BLU:LoadModule("features", module.id)
                end
            end
        end
        -- Refresh display
        if panel.Refresh then
            panel:Refresh()
        else
            BLU.CreateModulesPanel(panel)
        end
    end)
    
    disableAllBtn:SetScript("OnClick", function()
        for _, category in ipairs(categories) do
            for _, module in ipairs(category.modules) do
                BLU.db.profile.modules[module.id] = false
                if BLU.UnloadModule then
                    BLU:UnloadModule(module.id)
                end
            end
        end
        -- Refresh display
        if panel.Refresh then
            panel:Refresh()
        else
            BLU.CreateModulesPanel(panel)
        end
    end)
    
    defaultBtn:SetScript("OnClick", function()
        for _, category in ipairs(categories) do
            for _, module in ipairs(category.modules) do
                BLU.db.profile.modules[module.id] = module.default
                if module.default then
                    if BLU.LoadModule then
                        BLU:LoadModule("features", module.id)
                    end
                else
                    if BLU.UnloadModule then
                        BLU:UnloadModule(module.id)
                    end
                end
            end
        end
        -- Refresh display
        if panel.Refresh then
            panel:Refresh()
        else
            BLU.CreateModulesPanel(panel)
        end
    end)
    
    content:SetHeight(math.abs(yOffset) + 100)
end