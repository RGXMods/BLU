--=====================================================================================
-- BLU - Dropdown Menu System
-- Enhanced dropdown with nested categories and SharedMedia integration
--=====================================================================================

local addonName, BLU = ...

local Dropdown = {}
BLU.Dropdown = Dropdown

-- Create a dropdown menu
function Dropdown:Create(parent, width, height)
    local dropdown = CreateFrame("Frame", nil, parent)
    dropdown:SetSize(width or 200, height or 30)
    
    -- Main button
    dropdown.button = CreateFrame("Button", nil, dropdown)
    dropdown.button:SetAllPoints()
    dropdown.button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    dropdown.button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
    dropdown.button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    dropdown.button:GetNormalTexture():SetSize(20, 20)
    dropdown.button:GetNormalTexture():SetPoint("RIGHT", -5, 0)
    dropdown.button:GetPushedTexture():SetSize(20, 20)
    dropdown.button:GetPushedTexture():SetPoint("RIGHT", -5, 0)
    
    -- Text display
    dropdown.text = dropdown.button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdown.text:SetPoint("LEFT", 10, 0)
    dropdown.text:SetPoint("RIGHT", -30, 0)
    dropdown.text:SetJustifyH("LEFT")
    dropdown.text:SetText("Select...")
    
    -- Background
    dropdown.bg = dropdown:CreateTexture(nil, "BACKGROUND")
    dropdown.bg:SetAllPoints()
    dropdown.bg:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
    dropdown.bg:SetVertexColor(0, 0, 0, 0.5)
    
    -- Border
    dropdown.border = CreateFrame("Frame", nil, dropdown, "BackdropTemplate")
    dropdown.border:SetAllPoints()
    dropdown.border:SetBackdrop({
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    -- Dropdown menu frame
    dropdown.menu = CreateFrame("Frame", nil, dropdown, "BackdropTemplate")
    dropdown.menu:SetFrameStrata("FULLSCREEN_DIALOG")
    dropdown.menu:SetFrameLevel(100)
    dropdown.menu:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    dropdown.menu:SetBackdropColor(0, 0, 0, 0.9)
    dropdown.menu:Hide()
    
    -- Scroll frame for menu
    dropdown.scrollFrame = CreateFrame("ScrollFrame", nil, dropdown.menu, "UIPanelScrollFrameTemplate")
    dropdown.scrollFrame:SetPoint("TOPLEFT", 8, -8)
    dropdown.scrollFrame:SetPoint("BOTTOMRIGHT", -26, 8)
    
    -- Content frame
    dropdown.content = CreateFrame("Frame", nil, dropdown.scrollFrame)
    dropdown.scrollFrame:SetScrollChild(dropdown.content)
    
    -- Menu items storage
    dropdown.items = {}
    dropdown.itemFrames = {}
    dropdown.categories = {}
    dropdown.expandedCategories = {}
    dropdown.selectedValue = nil
    dropdown.selectedText = nil
    
    -- Button click handler
    dropdown.button:SetScript("OnClick", function()
        self:ToggleMenu(dropdown)
    end)
    
    -- Close menu when clicking outside
    dropdown.menu:SetScript("OnShow", function()
        self:SetupMenuCloseHandler(dropdown)
    end)
    
    dropdown.menu:SetScript("OnHide", function()
        self:RemoveMenuCloseHandler(dropdown)
    end)
    
    -- Methods
    dropdown.SetItems = function(_, items) self:SetItems(dropdown, items) end
    dropdown.SetValue = function(_, value) self:SetValue(dropdown, value) end
    dropdown.GetValue = function() return dropdown.selectedValue end
    dropdown.GetText = function() return dropdown.selectedText end
    dropdown.SetCallback = function(_, callback) dropdown.callback = callback end
    dropdown.Refresh = function() self:RefreshMenu(dropdown) end
    
    return dropdown
end

-- Set dropdown items with category support
function Dropdown:SetItems(dropdown, items)
    dropdown.items = items
    dropdown.categories = {}
    
    -- Organize items by category
    for _, item in ipairs(items) do
        local category = item.category or "Uncategorized"
        if not dropdown.categories[category] then
            dropdown.categories[category] = {}
        end
        table.insert(dropdown.categories[category], item)
    end
    
    -- Build menu
    self:BuildMenu(dropdown)
end

-- Build the dropdown menu
function Dropdown:BuildMenu(dropdown)
    -- Clear existing frames
    for _, frame in ipairs(dropdown.itemFrames) do
        frame:Hide()
        frame:SetParent(nil)
    end
    dropdown.itemFrames = {}
    
    local yOffset = 0
    local itemHeight = 20
    local categoryHeight = 25
    local maxWidth = 200
    
    -- Sort categories
    local sortedCategories = {}
    for category in pairs(dropdown.categories) do
        table.insert(sortedCategories, category)
    end
    table.sort(sortedCategories)
    
    -- Create category headers and items
    for _, category in ipairs(sortedCategories) do
        local items = dropdown.categories[category]
        
        -- Create category header
        local categoryFrame = CreateFrame("Button", nil, dropdown.content)
        categoryFrame:SetSize(maxWidth, categoryHeight)
        categoryFrame:SetPoint("TOPLEFT", 0, -yOffset)
        
        -- Category background
        categoryFrame.bg = categoryFrame:CreateTexture(nil, "BACKGROUND")
        categoryFrame.bg:SetAllPoints()
        categoryFrame.bg:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
        categoryFrame.bg:SetVertexColor(0.2, 0.2, 0.2, 0.8)
        
        -- Category text
        categoryFrame.text = categoryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        categoryFrame.text:SetPoint("LEFT", 20, 0)
        categoryFrame.text:SetText("|cff00ccff" .. category .. "|r")
        
        -- Expand/collapse icon
        categoryFrame.icon = categoryFrame:CreateTexture(nil, "ARTWORK")
        categoryFrame.icon:SetSize(12, 12)
        categoryFrame.icon:SetPoint("LEFT", 5, 0)
        
        -- Set initial expand state
        if dropdown.expandedCategories[category] == nil then
            dropdown.expandedCategories[category] = true
        end
        
        self:UpdateCategoryIcon(categoryFrame, dropdown.expandedCategories[category])
        
        -- Category click handler
        categoryFrame:SetScript("OnClick", function()
            dropdown.expandedCategories[category] = not dropdown.expandedCategories[category]
            self:RefreshMenu(dropdown)
        end)
        
        -- Highlight on hover
        categoryFrame:SetScript("OnEnter", function(frame)
            frame.bg:SetVertexColor(0.3, 0.3, 0.3, 0.8)
        end)
        
        categoryFrame:SetScript("OnLeave", function(frame)
            frame.bg:SetVertexColor(0.2, 0.2, 0.2, 0.8)
        end)
        
        table.insert(dropdown.itemFrames, categoryFrame)
        yOffset = yOffset + categoryHeight
        
        -- Create items if category is expanded
        if dropdown.expandedCategories[category] then
            -- Sort items within category
            table.sort(items, function(a, b)
                return (a.text or a.value) < (b.text or b.value)
            end)
            
            for _, item in ipairs(items) do
                local itemFrame = CreateFrame("Button", nil, dropdown.content)
                itemFrame:SetSize(maxWidth - 20, itemHeight)
                itemFrame:SetPoint("TOPLEFT", 20, -yOffset)
                
                -- Item background
                itemFrame.bg = itemFrame:CreateTexture(nil, "BACKGROUND")
                itemFrame.bg:SetAllPoints()
                itemFrame.bg:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
                itemFrame.bg:SetVertexColor(0, 0, 0, 0.3)
                
                -- Item text
                itemFrame.text = itemFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                itemFrame.text:SetPoint("LEFT", 5, 0)
                itemFrame.text:SetPoint("RIGHT", -5, 0)
                itemFrame.text:SetJustifyH("LEFT")
                
                local displayText = item.text or item.value
                
                -- Add color coding for different sources
                if item.source == "BLU" then
                    displayText = "|cff05dffa" .. displayText .. "|r"
                elseif item.source == "SharedMedia" then
                    displayText = "|cff00ff00" .. displayText .. "|r"
                elseif item.source == "Test" then
                    displayText = "|cff808080" .. displayText .. "|r"
                end
                
                -- Add icon if available
                if item.icon then
                    itemFrame.icon = itemFrame:CreateTexture(nil, "ARTWORK")
                    itemFrame.icon:SetSize(16, 16)
                    itemFrame.icon:SetPoint("LEFT", 2, 0)
                    itemFrame.icon:SetTexture(item.icon)
                    itemFrame.text:SetPoint("LEFT", 22, 0)
                else
                    itemFrame.text:SetPoint("LEFT", 5, 0)
                end
                
                itemFrame.text:SetText(displayText)
                
                -- Selected highlight
                if dropdown.selectedValue == item.value then
                    itemFrame.bg:SetVertexColor(0.3, 0.3, 0.6, 0.5)
                    itemFrame.selected = true
                end
                
                -- Item click handler
                itemFrame:SetScript("OnClick", function()
                    self:SelectItem(dropdown, item)
                    self:HideMenu(dropdown)
                end)
                
                -- Highlight on hover
                itemFrame:SetScript("OnEnter", function(frame)
                    if not frame.selected then
                        frame.bg:SetVertexColor(0.2, 0.2, 0.2, 0.5)
                    end
                    
                    -- Show tooltip if item has description
                    if item.description then
                        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
                        GameTooltip:SetText(item.text or item.value, 1, 1, 1)
                        GameTooltip:AddLine(item.description, 0.8, 0.8, 0.8, true)
                        if item.path then
                            GameTooltip:AddLine("\n|cff808080Path: " .. item.path .. "|r", 0.5, 0.5, 0.5, true)
                        end
                        GameTooltip:Show()
                    end
                end)
                
                itemFrame:SetScript("OnLeave", function(frame)
                    if not frame.selected then
                        frame.bg:SetVertexColor(0, 0, 0, 0.3)
                    end
                    GameTooltip:Hide()
                end)
                
                table.insert(dropdown.itemFrames, itemFrame)
                yOffset = yOffset + itemHeight
            end
        end
    end
    
    -- Set content size
    dropdown.content:SetSize(maxWidth, yOffset)
    
    -- Set menu size (max height 400)
    local menuHeight = math.min(yOffset + 16, 400)
    dropdown.menu:SetSize(maxWidth + 30, menuHeight)
    dropdown.menu:SetPoint("TOP", dropdown, "BOTTOM", 0, -2)
end

-- Update category expand/collapse icon
function Dropdown:UpdateCategoryIcon(frame, expanded)
    if expanded then
        frame.icon:SetTexture("Interface\\Buttons\\UI-MinusButton-Up")
    else
        frame.icon:SetTexture("Interface\\Buttons\\UI-PlusButton-Up")
    end
end

-- Select an item
function Dropdown:SelectItem(dropdown, item)
    dropdown.selectedValue = item.value
    dropdown.selectedText = item.text or item.value
    dropdown.text:SetText(dropdown.selectedText)
    
    -- Call callback if set
    if dropdown.callback then
        dropdown.callback(item.value, item)
    end
    
    -- Update visual selection
    for _, frame in ipairs(dropdown.itemFrames) do
        if frame.text then
            frame.selected = false
            if frame.bg then
                frame.bg:SetVertexColor(0, 0, 0, 0.3)
            end
        end
    end
end

-- Set value programmatically
function Dropdown:SetValue(dropdown, value)
    for _, items in pairs(dropdown.categories) do
        for _, item in ipairs(items) do
            if item.value == value then
                self:SelectItem(dropdown, item)
                return
            end
        end
    end
end

-- Toggle menu visibility
function Dropdown:ToggleMenu(dropdown)
    if dropdown.menu:IsShown() then
        self:HideMenu(dropdown)
    else
        self:ShowMenu(dropdown)
    end
end

-- Show menu
function Dropdown:ShowMenu(dropdown)
    dropdown.menu:Show()
    dropdown.button:GetNormalTexture():SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up")
end

-- Hide menu
function Dropdown:HideMenu(dropdown)
    dropdown.menu:Hide()
    dropdown.button:GetNormalTexture():SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
end

-- Refresh menu (rebuild)
function Dropdown:RefreshMenu(dropdown)
    self:BuildMenu(dropdown)
end

-- Setup click outside handler
function Dropdown:SetupMenuCloseHandler(dropdown)
    if not self.closeHandler then
        self.closeHandler = CreateFrame("Button", nil, UIParent)
        self.closeHandler:SetAllPoints()
        self.closeHandler:SetFrameStrata("FULLSCREEN")
        self.closeHandler:SetFrameLevel(99)
        self.closeHandler:EnableMouse(true)
        self.closeHandler:RegisterForClicks("AnyUp")
    end
    
    self.closeHandler:SetScript("OnClick", function()
        self:HideMenu(dropdown)
    end)
    
    self.closeHandler:Show()
end

-- Remove click outside handler
function Dropdown:RemoveMenuCloseHandler()
    if self.closeHandler then
        self.closeHandler:Hide()
    end
end