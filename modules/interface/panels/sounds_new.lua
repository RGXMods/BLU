--=====================================================================================
-- BLU - interface/panels/sounds_new.lua
-- Sound pack display panel showing installed packs
--=====================================================================================

local addonName, BLU = ...

function BLU.CreateSoundsPanel(panel)
    -- Create scrollable content with standardized positioning
    local scrollFrame, content = BLU.Design:CreatePanelScrollFrame(panel, 1000)
    
    -- Header
    local headerFrame = CreateFrame("Frame", nil, content)
    headerFrame:SetPoint("TOPLEFT", BLU.Design.Layout.ContentMargin, -BLU.Design.Layout.ContentMargin)
    headerFrame:SetPoint("RIGHT", -BLU.Design.Layout.ContentMargin, 0)
    headerFrame:SetHeight(50)
    
    local icon = headerFrame:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("LEFT", 0, 0)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Bell_01")
    
    local title = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    title:SetText("|cff05dffaB|retter |cff05dffaL|revel-|cff05dffaU|rp! Sound Management")
    
    -- BLU Internal Sounds section
    local internalSection = BLU.Design:CreateSection(content, "|cff05dffaB|retter |cff05dffaL|revel-|cff05dffaU|rp! Built-in Sound Packs", "Interface\\Icons\\INV_Misc_Bell_01")
    internalSection:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT", 0, -BLU.Design.Layout.SectionSpacing)
    internalSection:SetPoint("RIGHT", -BLU.Design.Layout.ContentMargin, 0)
    internalSection:SetHeight(250)
    
    -- Create a grid layout for BLU sound packs with load/unload functionality
    local bluPacks = {
        {id = "finalfantasy", name = "Final Fantasy", icon = "Interface\\Icons\\INV_Sword_39", description = "Classic RPG sounds", loaded = true},
        {id = "zelda", name = "Legend of Zelda", icon = "Interface\\Icons\\INV_Sword_48", description = "Adventure melodies", loaded = true},
        {id = "pokemon", name = "Pokemon", icon = "Interface\\Icons\\INV_Misc_Ball_04", description = "Gotta catch 'em all!", loaded = false},
        {id = "mario", name = "Super Mario", icon = "Interface\\Icons\\INV_Mushroom_11", description = "It's-a me, Mario!", loaded = false},
        {id = "sonic", name = "Sonic the Hedgehog", icon = "Interface\\Icons\\INV_Boots_01", description = "Gotta go fast!", loaded = false},
        {id = "metalgear", name = "Metal Gear Solid", icon = "Interface\\Icons\\INV_Misc_Bomb_04", description = "Tactical espionage", loaded = false},
        {id = "elderscrolls", name = "Elder Scrolls", icon = "Interface\\Icons\\INV_Misc_Book_11", description = "Epic fantasy", loaded = true},
        {id = "warcraft", name = "Warcraft", icon = "Interface\\Icons\\INV_Misc_Head_Orc_01", description = "For the Horde!", loaded = true},
        {id = "eldenring", name = "Elden Ring", icon = "Interface\\Icons\\INV_Sword_94", description = "Souls-like adventure", loaded = false},
        {id = "castlevania", name = "Castlevania", icon = "Interface\\Icons\\INV_Misc_Bone_Skull_02", description = "Gothic horror", loaded = false},
        {id = "diablo", name = "Diablo", icon = "Interface\\Icons\\INV_Misc_Gem_Bloodstone_02", description = "Hell awaits", loaded = false},
        {id = "fallout", name = "Fallout", icon = "Interface\\Icons\\INV_Gizmo_FelIronBomb", description = "Post-apocalyptic", loaded = false},
        {id = "blu_default", name = "BLU Defaults", icon = "Interface\\Icons\\INV_Misc_QuestionMark", description = "BLU's default sounds", loaded = true}
    }
    
    -- Create pack grid with load/unload controls
    local packGrid = CreateFrame("Frame", nil, internalSection.content)
    packGrid:SetPoint("TOPLEFT", BLU.Design.Layout.Spacing/2, -BLU.Design.Layout.Spacing)
    packGrid:SetPoint("BOTTOMRIGHT", -BLU.Design.Layout.Spacing/2, BLU.Design.Layout.Spacing)
    
    local cols = 2
    local itemWidth = 280
    local itemHeight = 40
    
    for i, pack in ipairs(bluPacks) do
        local row = math.ceil(i / cols) - 1
        local col = ((i - 1) % cols)
        
        local packItem = CreateFrame("Frame", nil, packGrid)
        packItem:SetSize(itemWidth, itemHeight)
        packItem:SetPoint("TOPLEFT", col * (itemWidth + 10), -row * (itemHeight + 5))
        
        -- Background with different colors based on status
        local bg = packItem:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        if pack.loaded then
            bg:SetColorTexture(0.02, 0.37, 0.5, 0.2) -- Blue tint for loaded
        else
            bg:SetColorTexture(0.1, 0.1, 0.1, 0.3) -- Gray for unloaded
        end
        
        -- Border
        local border = CreateFrame("Frame", nil, packItem, "BackdropTemplate")
        border:SetAllPoints()
        border:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        if pack.loaded then
            border:SetBackdropBorderColor(unpack(BLU.Design.Colors.Primary))
        else
            border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        end
        
        -- Icon
        local icon = packItem:CreateTexture(nil, "ARTWORK")
        icon:SetSize(28, 28)
        icon:SetPoint("LEFT", 6, 0)
        icon:SetTexture(pack.icon)
        
        -- Pack info
        local packName = packItem:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        packName:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, -2)
        packName:SetText(pack.name)
        if pack.loaded then
            packName:SetTextColor(unpack(BLU.Design.Colors.Primary))
        else
            packName:SetTextColor(0.7, 0.7, 0.7)
        end
        
        -- Description
        local desc = packItem:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        desc:SetPoint("TOPLEFT", packName, "BOTTOMLEFT", 0, -2)
        desc:SetText(pack.description)
        desc:SetTextColor(0.6, 0.6, 0.6)
        
        -- Status and toggle
        local status = packItem:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        status:SetPoint("BOTTOMRIGHT", -55, 2)
        if pack.loaded then
            status:SetText("|cff00ff00LOADED|r")
        else
            status:SetText("|cffff0000NOT LOADED|r")
        end
        
        local toggleBtn = BLU.Design:CreateButton(packItem, pack.loaded and "Unload" or "Load", 50, 18)
        toggleBtn:SetPoint("RIGHT", -3, 0)
        toggleBtn:SetScript("OnClick", function(self)
            pack.loaded = not pack.loaded
            
            if pack.loaded then
                -- Load sound pack
                self:SetText("Unload")
                status:SetText("|cff00ff00LOADED|r")
                bg:SetColorTexture(0.02, 0.37, 0.5, 0.2)
                border:SetBackdropBorderColor(unpack(BLU.Design.Colors.Primary))
                packName:SetTextColor(unpack(BLU.Design.Colors.Primary))
                BLU:Print("Loaded sound pack: " .. pack.name)
            else
                -- Unload sound pack
                self:SetText("Load")
                status:SetText("|cffff0000NOT LOADED|r")
                bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
                border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                packName:SetTextColor(0.7, 0.7, 0.7)
                BLU:Print("Unloaded sound pack: " .. pack.name)
            end
            
            -- TODO: Implement actual loading/unloading logic
            if BLU.LoadSoundPack then
                if pack.loaded then
                    BLU:LoadSoundPack(pack.id)
                else
                    BLU:UnloadSoundPack(pack.id)
                end
            end
        end)
    end
    
    -- SharedMedia Integration Section
    local sharedMediaSection = BLU.Design:CreateSection(content, "SharedMedia Integration", "Interface\\Icons\\Trade_Engineering")
    sharedMediaSection:SetPoint("TOPLEFT", internalSection, "BOTTOMLEFT", 0, -BLU.Design.Layout.Spacing)
    sharedMediaSection:SetPoint("RIGHT", -BLU.Design.Layout.Spacing, 0)
    sharedMediaSection:SetHeight(200)
    
    -- Container for addon display
    local addonContainer = CreateFrame("Frame", nil, sharedMediaSection.content)
    addonContainer:SetPoint("TOPLEFT", BLU.Design.Layout.Spacing, -BLU.Design.Layout.Spacing)
    addonContainer:SetPoint("BOTTOMRIGHT", -BLU.Design.Layout.Spacing, BLU.Design.Layout.Spacing)
    
    -- Get SharedMedia and sound addon information
    local hasLibStub = LibStub ~= nil
    local hasLSM = false
    local lsmSoundCount = 0
    local soundCategories = {}
    local detectedAddons = {}
    
    -- Check for LibSharedMedia sounds
    if hasLibStub then
        local LSM = LibStub("LibSharedMedia-3.0", true)
        hasLSM = LSM ~= nil
        if hasLSM then
            local soundList = LSM:List("sound")
            lsmSoundCount = soundList and #soundList or 0
        end
    end
    
    -- Get categories from BLU's SharedMedia module
    if BLU.Modules and BLU.Modules.sharedmedia then
        soundCategories = BLU.Modules.sharedmedia:GetSoundCategories() or {}
    end
    
    -- Check for loaded sound addons
    local knownSoundAddons = {
        {name = "SharedMedia", displayName = "SharedMedia Core", icon = "Interface\\Icons\\Trade_Engineering"},
        {name = "SharedMedia_MyMedia", displayName = "SharedMedia MyMedia", icon = "Interface\\Icons\\INV_Misc_Bell_01"},
        {name = "SharedMedia_Causese", displayName = "Causese's SharedMedia", icon = "Interface\\Icons\\INV_Misc_Bell_01"},
        {name = "BigWigs", displayName = "BigWigs (Boss Mod)", icon = "Interface\\Icons\\INV_Misc_Head_Dragon_01"},
        {name = "DBM-Core", displayName = "DBM (Boss Mod)", icon = "Interface\\Icons\\Spell_Shadow_RaiseDead"},
        {name = "WeakAuras", displayName = "WeakAuras", icon = "Interface\\Icons\\Spell_Nature_WispSplode"},
        {name = "SoundPack_FF14", displayName = "FF14 Sound Pack", icon = "Interface\\Icons\\INV_Sword_39"},
        {name = "SoundPack_Zelda", displayName = "Zelda Sound Pack", icon = "Interface\\Icons\\INV_Sword_48"},
    }
    
    for _, addon in ipairs(knownSoundAddons) do
        if C_AddOns.IsAddOnLoaded(addon.name) then
            table.insert(detectedAddons, addon)
        end
    end
    
    -- Display header
    local statusHeader = addonContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    statusHeader:SetPoint("TOPLEFT", 0, 0)
    if hasLSM and lsmSoundCount > 0 then
        statusHeader:SetText("|cff00ff00SharedMedia Integration Active|r")
    else
        statusHeader:SetText("|cffff8800SharedMedia Integration|r")
    end
    
    -- Display detected addons
    local yOffset = -25
    if #detectedAddons > 0 then
        local addonsLabel = addonContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        addonsLabel:SetPoint("TOPLEFT", 0, yOffset)
        addonsLabel:SetText("Detected Sound Addons:")
        yOffset = yOffset - 20
        
        for _, addon in ipairs(detectedAddons) do
            local addonFrame = CreateFrame("Frame", nil, addonContainer)
            addonFrame:SetPoint("TOPLEFT", 20, yOffset)
            addonFrame:SetSize(300, 20)
            
            local icon = addonFrame:CreateTexture(nil, "ARTWORK")
            icon:SetSize(16, 16)
            icon:SetPoint("LEFT", 0, 0)
            icon:SetTexture(addon.icon)
            
            local name = addonFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            name:SetPoint("LEFT", icon, "RIGHT", 5, 0)
            name:SetText("|cff00ff00✓|r " .. addon.displayName)
            
            yOffset = yOffset - 20
        end
    else
        local noAddonsText = addonContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        noAddonsText:SetPoint("TOPLEFT", 0, yOffset)
        noAddonsText:SetText("No external sound pack addons detected.")
        yOffset = yOffset - 20
    end
    
    -- Display sound categories if available
    if next(soundCategories) then
        yOffset = yOffset - 10
        local categoriesLabel = addonContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        categoriesLabel:SetPoint("TOPLEFT", 0, yOffset)
        categoriesLabel:SetText(string.format("Available Sound Categories (%d):", BLU.Modules.sharedmedia:GetTableSize(soundCategories)))
        yOffset = yOffset - 15
        
        for category, sounds in pairs(soundCategories) do
            if yOffset < -150 then break end  -- Limit display height
            local catText = addonContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            catText:SetPoint("TOPLEFT", 20, yOffset)
            catText:SetText(string.format("|cff05dffa%s|r (%d sounds)", category, #sounds))
            yOffset = yOffset - 15
        end
    end
    
    -- Info text at bottom
    local infoText = sharedMediaSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    infoText:SetPoint("BOTTOMLEFT", BLU.Design.Layout.Spacing, BLU.Design.Layout.Spacing)
    infoText:SetPoint("RIGHT", -BLU.Design.Layout.Spacing, 0)
    infoText:SetText("|cff888888External sounds from these addons can be selected in each event tab's sound dropdown.|r")
    infoText:SetJustifyH("LEFT")
    
    -- Test SharedMedia button
    local testSMBtn = BLU.Design:CreateButton(sharedMediaSection.content, "Test SharedMedia", 120, 24)
    testSMBtn:SetPoint("BOTTOMLEFT", BLU.Design.Layout.Spacing, BLU.Design.Layout.Spacing + 20)
    testSMBtn:SetScript("OnClick", function()
        if BLU.TestSharedMedia then
            BLU:TestSharedMedia()
        else
            BLU:Print("SharedMedia test function not available")
        end
    end)
    
    -- SharedMedia refresh button
    local refreshSMBtn = BLU.Design:CreateButton(sharedMediaSection.content, "Refresh", 80, 24)
    refreshSMBtn:SetPoint("LEFT", testSMBtn, "RIGHT", 10, 0)
    refreshSMBtn:SetScript("OnClick", function()
        -- Refresh SharedMedia detection
        hasLibStub = LibStub ~= nil
        hasLSM = false
        lsmSoundCount = 0
        
        if hasLibStub then
            local LSM = LibStub("LibSharedMedia-3.0", true)
            hasLSM = LSM ~= nil
            if hasLSM then
                local soundList = LSM:List("sound")
                lsmSoundCount = soundList and #soundList or 0
            end
        end
        
        -- Update display
        if hasLSM and lsmSoundCount > 0 then
            smStatus:SetText("|cff00ff00SharedMedia Available|r")
            smStatus:SetTextColor(0.2, 0.8, 0.2)
            smInfo:SetText(string.format("Found %d external sounds from SharedMedia-compatible addons. These can be selected in individual event tabs.", lsmSoundCount))
        else
            smStatus:SetText("|cffff8800SharedMedia Not Available|r")
            smStatus:SetTextColor(1, 0.5, 0)
            smInfo:SetText("SharedMedia is not available or no external sounds are registered. Install addons like SharedMedia_MyMedia or SoundPaks to add external sounds.")
        end
        
        BLU:Print("SharedMedia status refreshed.")
    end)
    
    -- Sound Pack Actions Section
    local actionsSection = BLU.Design:CreateSection(content, "Sound Pack Actions", "Interface\\Icons\\ACHIEVEMENT_GUILDPERK_QUICK AND DEAD")
    actionsSection:SetPoint("TOPLEFT", sharedMediaSection, "BOTTOMLEFT", 0, -BLU.Design.Layout.Spacing)
    actionsSection:SetPoint("RIGHT", -BLU.Design.Layout.Spacing, 0)
    actionsSection:SetHeight(120)
    
    -- Load all packs button
    local loadAllBtn = BLU.Design:CreateButton(actionsSection.content, "Load All Packs", 100, 24)
    loadAllBtn:SetPoint("TOPLEFT", BLU.Design.Layout.Spacing, -BLU.Design.Layout.Spacing)
    loadAllBtn:SetScript("OnClick", function(self)
        self:SetText("Loading...")
        self:Disable()
        
        local loadCount = 0
        for _, pack in ipairs(bluPacks) do
            if not pack.loaded then
                pack.loaded = true
                loadCount = loadCount + 1
            end
        end
        
        BLU:Print(string.format("Loaded %d sound packs", loadCount))
        
        C_Timer.After(1, function()
            self:SetText("Load All Packs")
            self:Enable()
        end)
    end)
    
    -- Unload all packs button
    local unloadAllBtn = BLU.Design:CreateButton(actionsSection.content, "Unload All Packs", 110, 24)
    unloadAllBtn:SetPoint("LEFT", loadAllBtn, "RIGHT", 10, 0)
    unloadAllBtn:SetScript("OnClick", function(self)
        self:SetText("Unloading...")
        self:Disable()
        
        local unloadCount = 0
        for _, pack in ipairs(bluPacks) do
            if pack.loaded then
                pack.loaded = false
                unloadCount = unloadCount + 1
            end
        end
        
        BLU:Print(string.format("Unloaded %d sound packs", unloadCount))
        
        C_Timer.After(1, function()
            self:SetText("Unload All Packs")
            self:Enable()
        end)
    end)
    
    -- Test random sound button
    local testRandomBtn = BLU.Design:CreateButton(actionsSection.content, "Test Random", 90, 24)
    testRandomBtn:SetPoint("LEFT", unloadAllBtn, "RIGHT", 10, 0)
    testRandomBtn:SetScript("OnClick", function(self)
        self:SetText("Playing...")
        self:Disable()
        
        -- Play a random sound from loaded packs
        local loadedPacks = {}
        for _, pack in ipairs(bluPacks) do
            if pack.loaded then
                table.insert(loadedPacks, pack)
            end
        end
        
        if #loadedPacks > 0 then
            local randomPack = loadedPacks[math.random(#loadedPacks)]
            BLU:Print("Playing random sound from: " .. randomPack.name)
            
            -- TODO: Implement random sound playback
            if BLU.PlaySound then
                BLU:PlaySound("levelup", randomPack.id)
            elseif BLU.Modules.registry and BLU.Modules.registry.PlaySound then
                BLU.Modules.registry:PlaySound("levelup")
            end
        else
            BLU:Print("No sound packs are loaded")
        end
        
        C_Timer.After(2, function()
            self:SetText("Test Random")
            self:Enable()
        end)
    end)
    
    -- How to Use section
    local usageSection = BLU.Design:CreateSection(content, "How to Configure Sounds", "Interface\\Icons\\INV_Misc_Note_02")
    usageSection:SetPoint("TOPLEFT", actionsSection, "BOTTOMLEFT", 0, -BLU.Design.Layout.Spacing)
    usageSection:SetPoint("RIGHT", -BLU.Design.Layout.Spacing, 0)
    usageSection:SetHeight(140)
    
    local usageText = usageSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    usageText:SetPoint("TOPLEFT", BLU.Design.Layout.Spacing, -BLU.Design.Layout.Spacing)
    usageText:SetPoint("RIGHT", -BLU.Design.Layout.Spacing, 0)
    usageText:SetJustifyH("LEFT")
    usageText:SetText(
        "To configure sounds for each event:\n\n" ..
        "|cff05dffa1.|r Click on any event tab at the top (Level Up, Achievement, Quest, etc.)\n" ..
        "|cff05dffa2.|r Use the dropdown menu to select your preferred sound\n" ..
        "|cff05dffa3.|r Choose from WoW sounds, |cff05dffaB|retter |cff05dffaL|revel-|cff05dffaU|rp! packs, or external addons\n" ..
        "|cff05dffa4.|r Use the Test button to preview your selection\n" ..
        "|cff05dffa5.|r |cff05dffaBLU|r volume slider only affects |cff05dffaB|retter |cff05dffaL|revel-|cff05dffaU|rp! internal sounds"
    )
    
    -- Set content height
    -- Content height already set by CreatePanelScrollFrame
end