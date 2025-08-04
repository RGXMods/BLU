--=====================================================================================
-- BLU - interface/panels/modules.lua
-- Modules management panel
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateModulesPanel(panel)
    
    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 8, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", -26, 8)
    
    -- Content frame
    local content = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(content)
    content:SetWidth(scrollFrame:GetWidth() - 18)
    content:SetHeight(1)
    
    -- Module list
    local modules = {
        {id = "levelup", name = "Level Up", desc = "Play sounds when you gain a level"},
        {id = "achievement", name = "Achievements", desc = "Play sounds when earning achievements"},
        {id = "quest", name = "Quest Complete", desc = "Play sounds when completing quests"},
        {id = "reputation", name = "Reputation", desc = "Play sounds when gaining reputation"},
        {id = "honorrank", name = "Honor Rank", desc = "Play sounds when gaining honor ranks"},
        {id = "renownrank", name = "Renown Rank", desc = "Play sounds when gaining renown"},
        {id = "battlepet", name = "Battle Pets", desc = "Play sounds for pet battle events"},
        {id = "tradingpost", name = "Trading Post", desc = "Play sounds for Trading Post rewards"},
        {id = "delvecompanion", name = "Delve Companion", desc = "Play sounds for Brann level ups"}
    }
    
    local yOffset = -10
    for i, module in ipairs(modules) do
        -- Module frame
        local moduleFrame = CreateFrame("Frame", nil, content)
        moduleFrame:SetPoint("TOPLEFT", 10, yOffset)
        moduleFrame:SetPoint("RIGHT", -10, 0)
        moduleFrame:SetHeight(60)
        
        -- Background
        if i % 2 == 0 then
            local bg = moduleFrame:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
        end
        
        -- Checkbox
        local checkbox = CreateFrame("CheckButton", nil, moduleFrame, "UICheckButtonTemplate")
        checkbox:SetPoint("LEFT", 5, 0)
        checkbox:SetChecked(BLU:GetConfig("modules", module.id, true))
        checkbox:SetScript("OnClick", function(self)
            BLU:SetConfig("modules", module.id, self:GetChecked())
            -- Toggle module
            if self:GetChecked() then
                BLU:LoadModule(module.id)
            else
                BLU:UnloadModule(module.id)
            end
        end)
        
        -- Name
        local name = moduleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("LEFT", checkbox, "RIGHT", 5, 8)
        name:SetText(module.name)
        
        -- Description
        local desc = moduleFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        desc:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
        desc:SetText(module.desc)
        desc:SetTextColor(0.7, 0.7, 0.7)
        
        yOffset = yOffset - 65
    end
    
    content:SetHeight(-yOffset)
end