--=====================================================================================
-- BLU - interface/panels/sounds_new.lua
-- Sound pack display panel showing installed packs
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

function BLU.CreateSoundsPanel(panel)
    -- Create scrollable content with proper spacing
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 5)
    
    -- Add scroll frame background
    local scrollBg = scrollFrame:CreateTexture(nil, "BACKGROUND")
    scrollBg:SetAllPoints()
    scrollBg:SetColorTexture(0.05, 0.05, 0.05, 0.3)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(680)  -- Fixed width to fill available space
    scrollFrame:SetScrollChild(content)
    
    -- Header
    local header = BLU.Design:CreateHeader(content, "Installed Sound Packs", "Interface\Icons\INV_Misc_Bag_33")
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("RIGHT", 0, 0)
    
    -- BLU Internal Sounds section
    local internalSection = BLU.Design:CreateSection(content, "BLU Built-in Sound Packs", "Interface\Icons\INV_Misc_Bell_01")
    internalSection:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -15)
    internalSection:SetPoint("RIGHT", 0, 0)
    internalSection:SetHeight(200)
    
    -- Create a grid layout for BLU sound packs
    local bluPacks = {
        {id = "finalfantasy", name = "Final Fantasy", icon = "Interface\Icons\INV_Sword_39"},
        {id = "zelda", name = "Legend of Zelda", icon = "Interface\Icons\INV_Sword_48"},
        {id = "pokemon", name = "Pokemon", icon = "Interface\Icons\INV_Misc_Ball_04"},
        {id = "mario", name = "Super Mario", icon = "Interface\Icons\INV_Mushroom_11"},
        {id = "sonic", name = "Sonic the Hedgehog", icon = "Interface\Icons\INV_Boots_01"},
        {id = "metalgear", name = "Metal Gear Solid", icon = "Interface\Icons\INV_Misc_Bomb_04"},
        {id = "elderscrolls", name = "Elder Scrolls", icon = "Interface\Icons\INV_Misc_Book_11"},
        {id = "warcraft", name = "Warcraft", icon = "Interface\Icons\INV_Misc_Head_Orc_01"},
        {id = "eldenring", name = "Elden Ring", icon = "Interface\Icons\INV_Sword_94"},
        {id = "castlevania", name = "Castlevania", icon = "Interface\Icons\INV_Misc_Bone_Skull_02"},
        {id = "diablo", name = "Diablo", icon = "Interface\Icons\INV_Misc_Gem_Bloodstone_02"},
        {id = "fallout", name = "Fallout", icon = "Interface\Icons\INV_Gizmo_FelIronBomb"},
        {id = "blu_default", name = "BLU Defaults", icon = "Interface\Icons\INV_Misc_QuestionMark"}
    }
    
    local xOffset = 10
    local yOffset = -10
    local packWidth = 150
    local packHeight = 30
    local packsPerRow = 3
    local currentRow = 0
    local currentCol = 0
    
    for i, pack in ipairs(bluPacks) do
        local packFrame = CreateFrame("Frame", nil, internalSection.content)
        packFrame:SetSize(packWidth, packHeight)
        packFrame:SetPoint("TOPLEFT", xOffset + (currentCol * (packWidth + 10)), yOffset - (currentRow * (packHeight + 5)))
        
        -- Icon
        local icon = packFrame:CreateTexture(nil, "ARTWORK")
        icon:SetSize(24, 24)
        icon:SetPoint("LEFT", 3, 0)
        icon:SetTexture(pack.icon)
        
        -- Name
        local name = packFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("LEFT", icon, "RIGHT", 5, 0)
        name:SetText(pack.name)
        
        -- Status
        local status = packFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        status:SetPoint("RIGHT", -5, 0)
        status:SetText("|cff00ff00✓|r")
        
        -- Update position
        currentCol = currentCol + 1
        if currentCol >= packsPerRow then
            currentCol = 0
            currentRow = currentRow + 1
        end
    end
    
    -- External Sound Packs section
    local externalSection = BLU.Design:CreateSection(content, "External Sound Packs", "Interface\Icons\INV_Misc_Book_09")
    externalSection:SetPoint("TOPLEFT", internalSection, "BOTTOMLEFT", 0, -20)
    externalSection:SetPoint("RIGHT", -20, 0)
    externalSection:SetHeight(250)
    
    -- Check for loaded sound addons
    local loadedAddons = {}
    if BLU.Modules.sharedmedia then
        loadedAddons = BLU.Modules.sharedmedia:GetLoadedSoundAddons()
    end
    
    if #loadedAddons > 0 then
        local addonsText = "|cff00ff00Detected Sound Addons:|r\n\n"
        
        for _, addon in ipairs(loadedAddons) do
            addonsText = addonsText .. "• " .. addon .. " - |cff00ff00Loaded|r\n"
        end
        
        local detectedText = externalSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        detectedText:SetPoint("TOPLEFT", 0, -5)
        detectedText:SetPoint("RIGHT", 0, 0)
        detectedText:SetJustifyH("LEFT")
        detectedText:SetText(addonsText)
    else
        local noAddonsText = externalSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        noAddonsText:SetPoint("TOPLEFT", 0, -5)
        noAddonsText:SetPoint("RIGHT", 0, 0)
        noAddonsText:SetJustifyH("LEFT")
        noAddonsText:SetText(
            "|cffff0000No external sound addons detected.|r\n\n" ..
            "To add more sounds, install sound pack addons from:\n" ..
            "• CurseForge - Search for 'SharedMedia' sound packs\n" ..
            "• WoWInterface - Browse the audio category\n" ..
            "• Wago.io - Find WeakAuras with custom sounds\n\n" ..
            "Popular sound pack addons:\n" ..
            "• SharedMedia_MyMedia\n" ..
            "• SharedMedia_Causese\n" ..
            "• Epic Music Player"
        )
    end
    
    -- How to Use section
    local usageSection = BLU.Design:CreateSection(content, "How to Configure Sounds", "Interface\Icons\INV_Misc_Note_02")
    usageSection:SetPoint("TOPLEFT", externalSection, "BOTTOMLEFT", 0, -20)
    usageSection:SetPoint("RIGHT", -20, 0)
    usageSection:SetHeight(140)
    
    local usageText = usageSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    usageText:SetPoint("TOPLEFT", 0, -5)
    usageText:SetPoint("RIGHT", -10, 0)
    usageText:SetJustifyH("LEFT")
    usageText:SetText(
        "To configure sounds for each event:\n\n" ..
        "|cff05dffa1.|r Click on any event tab at the top (Level Up, Achievement, Quest, etc.)\n" ..
        "|cff05dffa2.|r Use the dropdown menu to select your preferred sound\n" ..
        "|cff05dffa3.|r Choose from WoW sounds, BLU packs, or external addons\n" ..
        "|cff05dffa4.|r Use the Test button to preview your selection\n" ..
        "|cff05dffa5.|r BLU volume slider only affects BLU internal sounds"
    )
    
    -- Set content height
    content:SetHeight(700)
end
