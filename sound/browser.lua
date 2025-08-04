--=====================================================================================
-- BLU Sound Browser Module
-- Provides UI for browsing and previewing all sounds
--=====================================================================================

local addonName, BLU = ...
local SoundBrowser = {}

-- Browser frame reference
local browserFrame = nil

-- Initialize browser
function SoundBrowser:Init()
    BLU.OpenSoundBrowser = function()
        self:Open()
    end
    
    BLU:PrintDebug("Sound Browser initialized")
end

-- Create browser frame
function SoundBrowser:CreateFrame()
    if browserFrame then return browserFrame end
    
    -- Main frame
    browserFrame = CreateFrame("Frame", "BLUSoundBrowser", UIParent, "BasicFrameTemplateWithInset")
    browserFrame:SetSize(700, 500)
    browserFrame:SetPoint("CENTER")
    browserFrame:SetMovable(true)
    browserFrame:EnableMouse(true)
    browserFrame:SetClampedToScreen(true)
    browserFrame:RegisterForDrag("LeftButton")
    browserFrame:SetScript("OnDragStart", browserFrame.StartMoving)
    browserFrame:SetScript("OnDragStop", browserFrame.StopMovingOrSizing)
    browserFrame:Hide()
    
    -- Title
    browserFrame.TitleText:SetText("BLU Sound Browser")
    
    -- Category dropdown
    local categoryDropdown = CreateFrame("Frame", "BLUSoundBrowserCategory", browserFrame, "UIDropDownMenuTemplate")
    categoryDropdown:SetPoint("TOPLEFT", browserFrame.InsetBg, "TOPLEFT", 0, -10)
    UIDropDownMenu_SetWidth(categoryDropdown, 150)
    
    -- Search box
    local searchBox = CreateFrame("EditBox", nil, browserFrame, "SearchBoxTemplate")
    searchBox:SetSize(200, 20)
    searchBox:SetPoint("LEFT", categoryDropdown, "RIGHT", 10, 3)
    searchBox:SetMaxLetters(50)
    searchBox:SetScript("OnTextChanged", function(self)
        SearchBoxTemplate_OnTextChanged(self)
        SoundBrowser:UpdateList()
    end)
    
    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, browserFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", browserFrame.InsetBg, "TOPLEFT", 5, -50)
    scrollFrame:SetPoint("BOTTOMRIGHT", browserFrame.InsetBg, "BOTTOMRIGHT", -26, 40)
    
    -- Content frame
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(650, 1)
    scrollFrame:SetScrollChild(content)
    browserFrame.content = content
    
    -- Sound buttons container
    browserFrame.soundButtons = {}
    
    -- Currently playing indicator
    local nowPlaying = browserFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nowPlaying:SetPoint("BOTTOMLEFT", browserFrame.InsetBg, "BOTTOMLEFT", 10, 10)
    nowPlaying:SetText("Now Playing: None")
    browserFrame.nowPlaying = nowPlaying
    
    -- Stop button
    local stopButton = CreateFrame("Button", nil, browserFrame, "UIPanelButtonTemplate")
    stopButton:SetSize(80, 22)
    stopButton:SetPoint("BOTTOMRIGHT", browserFrame.InsetBg, "BOTTOMRIGHT", -10, 10)
    stopButton:SetText("Stop")
    stopButton:SetScript("OnClick", function()
        StopSound(0)
        browserFrame.nowPlaying:SetText("Now Playing: None")
    end)
    
    -- Initialize dropdown
    UIDropDownMenu_Initialize(categoryDropdown, function(self, level)
        local categories = {
            {text = "All Sounds", value = "all"},
            {text = "Level Up", value = "levelup"},
            {text = "Achievement", value = "achievement"},
            {text = "Quest Complete", value = "quest"},
            {text = "Reputation", value = "reputation"},
            {text = "Honor Rank", value = "honorrank"},
            {text = "Renown Rank", value = "renownrank"},
            {text = "Trading Post", value = "tradingpost"},
            {text = "Battle Pet", value = "battlepet"},
            {text = "Delve Companion", value = "delvecompanion"}
        }
        
        for _, category in ipairs(categories) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = category.text
            info.value = category.value
            info.func = function()
                UIDropDownMenu_SetText(self, category.text)
                browserFrame.selectedCategory = category.value
                SoundBrowser:UpdateList()
            end
            info.checked = browserFrame.selectedCategory == category.value
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    UIDropDownMenu_SetText(categoryDropdown, "All Sounds")
    browserFrame.selectedCategory = "all"
    browserFrame.searchBox = searchBox
    browserFrame.categoryDropdown = categoryDropdown
    
    return browserFrame
end

-- Create sound button
function SoundBrowser:CreateSoundButton(index)
    local button = CreateFrame("Button", nil, browserFrame.content)
    button:SetSize(630, 30)
    button:SetPoint("TOPLEFT", 0, -(index - 1) * 35)
    
    -- Background
    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(1, 1, 1, 0.05)
    button.bg = bg
    
    -- Highlight
    button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    
    -- Sound name
    local name = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("LEFT", 10, 0)
    name:SetJustifyH("LEFT")
    button.name = name
    
    -- Category
    local category = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    category:SetPoint("LEFT", 250, 0)
    category:SetTextColor(0.7, 0.7, 0.7)
    button.category = category
    
    -- Game
    local game = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    game:SetPoint("LEFT", 400, 0)
    game:SetTextColor(0.7, 0.7, 0.7)
    button.game = game
    
    -- Play button
    local playBtn = CreateFrame("Button", nil, button)
    playBtn:SetSize(50, 20)
    playBtn:SetPoint("RIGHT", -10, 0)
    playBtn:SetNormalFontObject("GameFontNormalSmall")
    playBtn:SetHighlightFontObject("GameFontHighlightSmall")
    playBtn:SetText("Play")
    button.playBtn = playBtn
    
    -- Hover effect
    button:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(1, 1, 1, 0.1)
    end)
    
    button:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(1, 1, 1, 0.05)
    end)
    
    return button
end

-- Update sound list
function SoundBrowser:UpdateList()
    if not browserFrame then return end
    
    -- Get all sounds
    local sounds = {}
    if BLU.Modules and BLU.Modules.registry then
        sounds = BLU.Modules.registry:GetAllSounds()
    end
    
    local filteredSounds = {}
    
    -- Filter by category and search
    local searchText = browserFrame.searchBox:GetText():lower()
    local category = browserFrame.selectedCategory
    
    for soundId, soundData in pairs(sounds) do
        local matchesCategory = category == "all" or soundData.category == category
        local matchesSearch = searchText == "" or 
                            soundData.name:lower():find(searchText) or 
                            soundId:lower():find(searchText)
        
        if matchesCategory and matchesSearch then
            table.insert(filteredSounds, {
                id = soundId,
                data = soundData
            })
        end
    end
    
    -- Sort by name
    table.sort(filteredSounds, function(a, b)
        return a.data.name < b.data.name
    end)
    
    -- Hide all buttons
    for _, button in ipairs(browserFrame.soundButtons) do
        button:Hide()
    end
    
    -- Create/update buttons
    for i, sound in ipairs(filteredSounds) do
        local button = browserFrame.soundButtons[i]
        if not button then
            button = self:CreateSoundButton(i)
            browserFrame.soundButtons[i] = button
        end
        
        -- Update button data
        button.name:SetText(sound.data.name)
        button.category:SetText(sound.data.category or "misc")
        
        -- Extract game name from sound ID
        local gameName = sound.id:match("^(.-)_") or "custom"
        button.game:SetText(gameName)
        
        -- Play button click
        button.playBtn:SetScript("OnClick", function()
            StopSound(0)
            BLU:PlaySound(sound.id)
            browserFrame.nowPlaying:SetText("Now Playing: " .. sound.data.name)
        end)
        
        button:Show()
    end
    
    -- Update content height
    browserFrame.content:SetHeight(math.max(1, #filteredSounds * 35))
end

-- Open browser
function SoundBrowser:Open()
    if not browserFrame then
        self:CreateFrame()
    end
    
    self:UpdateList()
    browserFrame:Show()
end

-- Close browser
function SoundBrowser:Close()
    if browserFrame then
        browserFrame:Hide()
    end
end

-- Export module
BLU.SoundBrowser = SoundBrowser
return SoundBrowser