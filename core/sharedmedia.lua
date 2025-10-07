--=====================================================================================
-- BLU - sharedmedia.lua
-- Integration with LibSharedMedia and external sound pack addons
--=====================================================================================

local addonName, BLU = ...

-- Create SharedMedia module
local SharedMedia = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["sharedmedia"] = SharedMedia

-- Storage for external sounds
SharedMedia.externalSounds = {}
SharedMedia.soundCategories = {}

-- Initialize SharedMedia integration
function SharedMedia:Init()
    -- Try to load LibSharedMedia
    self.LSM = LibStub and LibStub("LibSharedMedia-3.0", true) or nil
    
    if not self.LSM then
        BLU:PrintDebug("LibSharedMedia not found - checking for direct sound addons")
        -- Try alternative detection method
        self:DetectSoundAddons()
    else
        BLU:PrintDebug("LibSharedMedia found - scanning for sounds")
        -- Register callbacks
        self.LSM.RegisterCallback(self, "LibSharedMedia_Registered", "OnMediaRegistered")
        self.LSM.RegisterCallback(self, "LibSharedMedia_SetGlobal", "OnMediaSetGlobal")
        
        -- Scan existing sounds
        self:ScanExternalSounds()
    end
    
    -- Always add some test sounds for development/testing
    self:AddTestSounds()
    
    -- Make functions available
    BLU.GetExternalSounds = function() return self:GetExternalSounds() end
    BLU.GetSoundCategories = function() return self:GetSoundCategories() end
    BLU.PlayExternalSound = function(_, name) return self:PlayExternalSound(name) end
    
    BLU:PrintDebug("SharedMedia integration initialized")
end

-- Scan for external sounds from SharedMedia
function SharedMedia:ScanExternalSounds()
    if not self.LSM then return end
    
    -- Clear existing
    wipe(self.externalSounds)
    wipe(self.soundCategories)
    
    -- Get all registered sounds
    local soundList = self.LSM:List("sound")
    
    for _, soundName in ipairs(soundList) do
        local soundPath = self.LSM:Fetch("sound", soundName)
        if soundPath then
            -- Categorize by addon/type
            local category = self:CategorizeSound(soundName, soundPath)
            
            -- Store sound info
            self.externalSounds[soundName] = {
                name = soundName,
                path = soundPath,
                category = category,
                source = "SharedMedia"
            }
            
            -- Add to category list
            if not self.soundCategories[category] then
                self.soundCategories[category] = {}
            end
            table.insert(self.soundCategories[category], soundName)
        end
    end
    
    BLU:PrintDebug(string.format("Found %d external sounds in %d categories", 
        #soundList, self:GetTableSize(self.soundCategories)))
end

-- Categorize sounds by name patterns
function SharedMedia:CategorizeSound(name, path)
    local nameLower = name:lower()
    
    -- Check for known sound pack patterns
    local patterns = {
        -- SharedMedia_MyMedia sounds
        ["mymedia"] = "MyMedia Sounds",
        ["custom"] = "Custom Sounds",
        
        -- Game-specific patterns
        ["ff14"] = "Final Fantasy XIV",
        ["ffxiv"] = "Final Fantasy XIV",
        ["final fantasy"] = "Final Fantasy",
        ["zelda"] = "Legend of Zelda",
        ["mario"] = "Super Mario",
        ["pokemon"] = "Pokemon",
        ["sonic"] = "Sonic",
        ["metroid"] = "Metroid",
        ["megaman"] = "Mega Man",
        ["chrono"] = "Chrono Trigger",
        ["kingdom hearts"] = "Kingdom Hearts",
        
        -- Event type patterns
        ["level"] = "Level Up Sounds",
        ["ding"] = "Level Up Sounds",
        ["achievement"] = "Achievement Sounds",
        ["quest"] = "Quest Sounds",
        ["complete"] = "Completion Sounds",
        ["victory"] = "Victory Sounds",
        ["fanfare"] = "Fanfare Sounds",
        
        -- Addon-specific patterns
        ["weakauras"] = "WeakAuras Sounds",
        ["bigwigs"] = "BigWigs Sounds",
        ["dbm"] = "DBM Sounds",
        ["elvui"] = "ElvUI Sounds",
        
        -- Generic patterns
        ["alert"] = "Alert Sounds",
        ["warning"] = "Warning Sounds",
        ["notification"] = "Notification Sounds"
    }
    
    -- Check each pattern
    for pattern, category in pairs(patterns) do
        if nameLower:find(pattern) then
            return category
        end
    end
    
    -- Check path for addon name
    if path:find("SharedMedia_Ayarei") then
        return "Ayarei's Sounds"
    elseif path:find("SharedMedia_Arey") then
        return "Arey's Sounds"
    elseif path:find("ShadowPriest") then
        return "Shadow Priest Sounds"
    elseif path:find("SharedMedia") then
        return "SharedMedia Sounds"
    end
    
    -- Default category
    return "Other Sounds"
end

-- Get all external sounds
function SharedMedia:GetExternalSounds()
    return self.externalSounds
end

-- Get sounds by category
function SharedMedia:GetSoundCategories()
    return self.soundCategories
end

-- Get formatted sound list for dropdowns
function SharedMedia:GetSoundList(filterCategory)
    local sounds = {}
    
    -- Add BLU's built-in sounds first
    table.insert(sounds, {
        value = "blu_default",
        text = "|cff05dffaBLU Default|r",
        category = "BLU Built-in"
    })
    
    -- Add external sounds
    for name, info in pairs(self.externalSounds) do
        if not filterCategory or info.category == filterCategory then
            table.insert(sounds, {
                value = "external:" .. name,
                text = name,
                category = info.category,
                path = info.path
            })
        end
    end
    
    -- Sort by category then name
    table.sort(sounds, function(a, b)
        if a.category ~= b.category then
            return a.category < b.category
        end
        return a.text < b.text
    end)
    
    return sounds
end

-- Play external sound
function SharedMedia:PlayExternalSound(name)
    local sound = self.externalSounds[name]
    if not sound then
        BLU:PrintDebug("External sound not found: " .. name)
        return false
    end
    
    -- Get volume and channel from BLU settings
    local volume = (BLU.db.profile.soundVolume or 100) / 100
    local channel = BLU.db.profile.soundChannel or "Master"
    
    -- Play the sound
    local willPlay, handle = PlaySoundFile(sound.path, channel)
    
    if willPlay then
        BLU:PrintDebug(string.format("Playing external sound: %s", name))
        
        -- Show in chat if debug mode
        if BLU.db.profile.debugMode then
            BLU:Print(string.format("|cff00ff00Playing:|r %s (External)", name))
        end
        
        return true
    else
        BLU:PrintError("Failed to play external sound: " .. name)
        return false
    end
end

-- Handle new media registration
function SharedMedia:OnMediaRegistered(event, mediatype, key)
    if mediatype ~= "sound" then return end
    
    BLU:PrintDebug("New sound registered: " .. key)
    
    -- Rescan sounds
    self:ScanExternalSounds()
    
    -- Notify UI to refresh if open
    if BLU.RefreshSoundLists then
        BLU:RefreshSoundLists()
    end
end

-- Handle global media changes
function SharedMedia:OnMediaSetGlobal(event, mediatype, key)
    if mediatype ~= "sound" then return end
    
    -- Rescan sounds
    self:ScanExternalSounds()
end

-- Helper function to get table size
function SharedMedia:GetTableSize(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

-- Alternative detection for sound addons without LibSharedMedia
function SharedMedia:DetectSoundAddons()
    BLU:PrintDebug("Detecting sound addons directly...")
    
    -- Check for common sound pack globals
    local soundPackGlobals = {
        -- SharedMedia addons often create these globals
        "SharedMedia",
        "SharedMediaAdditionalFonts",
        "SharedMedia_MyMedia",
        "SharedMedia_Causese",
        -- WeakAuras
        "WeakAurasSaved",
        -- Other common sound addons
        "DBM",
        "BigWigs"
    }
    
    local detectedAddons = {}
    for _, global in ipairs(soundPackGlobals) do
        if _G[global] then
            table.insert(detectedAddons, global)
            BLU:PrintDebug("Found global: " .. global)
        end
    end
    
    BLU:PrintDebug(string.format("Detected %d sound addon globals", #detectedAddons))
    return detectedAddons
end

-- Add test sounds for development and fallback
function SharedMedia:AddTestSounds()
    BLU:PrintDebug("Adding test sounds for development...")
    
    -- Clear and rebuild categories
    self.soundCategories = {}
    self.externalSounds = {}
    
    -- Add WoW built-in sounds as examples
    local wowSounds = {
        {name = "WoW Level Up", path = "Sound\\Interface\\levelup2.ogg", category = "WoW Sounds"},
        {name = "WoW Quest Complete", path = "Sound\\Interface\\iQuestComplete.ogg", category = "WoW Sounds"},
        {name = "WoW Achievement", path = "Sound\\Interface\\UI_Achievement_Alert.ogg", category = "WoW Sounds"},
        {name = "WoW Epic Loot", path = "Sound\\Interface\\UI_EpicLoot_Toast.ogg", category = "WoW Sounds"},
        {name = "WoW Legendary", path = "Sound\\Interface\\UI_Legendary_Item_Toast.ogg", category = "WoW Sounds"}
    }
    
    for _, sound in ipairs(wowSounds) do
        self.externalSounds[sound.name] = {
            name = sound.name,
            path = sound.path,
            category = sound.category,
            source = "WoW Built-in"
        }
        
        -- Add to categories
        if not self.soundCategories[sound.category] then
            self.soundCategories[sound.category] = {}
        end
        table.insert(self.soundCategories[sound.category], sound.name)
    end
    
    self.soundCategories["Level Up Sounds"] = {
        "Classic Ding",
        "Power Up Fanfare",
        "Victory Theme",
        "Level Complete"
    }
    
    self.soundCategories["Quest Sounds"] = {
        "Quest Complete",
        "Objective Done",
        "Turn In Success",
        "World Quest Complete"
    }
    
    -- Store sound info for the test sounds
    for category, sounds in pairs(self.soundCategories) do
        for _, soundName in ipairs(sounds) do
            self.externalSounds[soundName] = {
                name = soundName,
                path = "Interface\\AddOns\\BLU\\media\\sounds\\test\\placeholder.ogg",
                category = category,
                source = "Test"
            }
        end
    end
    
    local totalSounds = 0
    for _, sounds in pairs(self.soundCategories) do
        totalSounds = totalSounds + #sounds
    end
    
    BLU:PrintDebug(string.format("Added %d test sounds in %d categories", totalSounds, self:GetTableSize(self.soundCategories)))
end

-- Check if specific sound addons are loaded
function SharedMedia:GetLoadedSoundAddons()
    local addons = {}
    
    local soundAddons = {
        "SharedMedia",
        "SharedMedia_MyMedia", 
        "SharedMedia_Causese",
        "SharedMedia_Ayarei",
        "SharedMedia_Arey",
        "ShadowPriest-SoundPack",
        "WeakAuras",
        "BigWigs",
        "DBM-Core"
    }
    
    for _, addon in ipairs(soundAddons) do
        if C_AddOns.IsAddOnLoaded(addon) then
            table.insert(addons, addon)
        end
    end
    
    return addons
end