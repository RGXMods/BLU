--=====================================================================================
-- BLU Sound Registry Module
-- Manages all sound registrations and playback
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

local SoundRegistry = {}

local defaultBluSounds = {
    levelup = "level_default",
    achievement = "achievement_default",
    quest = "quest_default",
    questaccept = "quest_accept_default",
    reputation = "rep_default",
    battlepet = "battle_pet_level_default",
    honorrank = "honor_default",
    renownrank = "renown_default",
    tradingpost = "post_default",
    delvecompanion = "delve_default",
}

BLU.Modules["registry"] = SoundRegistry
BLU.SoundRegistry = SoundRegistry

-- Sound storage with caching
SoundRegistry.sounds = {}
SoundRegistry.categories = {}
SoundRegistry.soundCache = {} -- Performance cache
SoundRegistry.lastCacheUpdate = 0
SoundRegistry.uiSoundCache = {} -- Cache for UI dropdowns

-- Initialize
function SoundRegistry:Init()
    -- Register core API functions
    BLU.RegisterSound = function(_, soundId, soundData)
        return self:RegisterSound(soundId, soundData)
    end
    
    BLU.UnregisterSound = function(_, soundId)
        return self:UnregisterSound(soundId)
    end
    
    BLU.GetSound = function(_, soundId)
        return self:GetSound(soundId)
    end
    
    BLU.PlaySound = function(_, soundId, volume)
        return self:PlaySound(soundId, volume)
    end
    
    BLU.PlayCategorySound = function(_, category, forceSound)
        return self:PlayCategorySound(category, forceSound)
    end
    
    BLU.RegisterSoundPack = function(_, packId, packName, sounds)
        return self:RegisterSoundPack(packId, packName, sounds)
    end
    
    BLU.GetRegisteredPacks = function()
        return self:GetRegisteredPacks()
    end

    BLU.GetSoundsGroupedForUI = function(_, targetEvent)
        return self:GetSoundsGroupedForUI(targetEvent)
    end
    
    BLU:PrintDebug(BLU:Loc("MODULE_LOADED", "SoundRegistry"))
end

-- Register a sound
function SoundRegistry:RegisterSound(soundId, soundData)
    if not soundId or not soundData then
        BLU:PrintError("Invalid sound registration")
        return false
    end
    BLU:PrintDebug(string.format("SoundRegistry:RegisterSound: id='%s', name='%s', pack='%s'", soundId, soundData.name or "nil", soundData.packName or "nil"))
    
    -- Store sound
    self.sounds[soundId] = soundData
    
    -- Track category
    if soundData.category then
        self.categories[soundData.category] = self.categories[soundData.category] or {}
        self.categories[soundData.category][soundId] = true
    end
    
    -- Invalidate UI cache
    self.uiSoundCache = {}

    BLU:PrintDebug("Registered sound: " .. soundId)
    return true
end

-- Unregister a sound
function SoundRegistry:UnregisterSound(soundId)
    local sound = self.sounds[soundId]
    if not sound then return end
    
    -- Remove from category
    if sound.category and self.categories[sound.category] then
        self.categories[sound.category][soundId] = nil
    end
    
    -- Remove sound
    self.sounds[soundId] = nil

    -- Invalidate UI cache
    self.uiSoundCache = {}
end

-- Get sound data
function SoundRegistry:GetSound(soundId)
    return self.sounds[soundId]
end

-- Get sounds by category
function SoundRegistry:GetSoundsByCategory(category)
    local sounds = {}
    
    if self.categories[category] then
        for soundId in pairs(self.categories[category]) do
            sounds[soundId] = self.sounds[soundId]
        end
    end
    
    return sounds
end

-- Get all sounds
function SoundRegistry:GetAllSounds()
    return self.sounds
end

-- Register a sound pack
function SoundRegistry:RegisterSoundPack(packId, packName, sounds)
    if not packId or not sounds then
        BLU:PrintError("Invalid sound pack registration")
        return false
    end
    
    BLU:PrintDebug("Registering sound pack: " .. packName)
    
    local registered = 0
    for soundId, soundData in pairs(sounds) do
        -- Add pack info to sound data
        soundData.packId = packId
        soundData.packName = packName
        
        -- Register the sound
        if self:RegisterSound(soundId, soundData) then
            registered = registered + 1
        end
    end
    
    BLU:PrintDebug(string.format("Registered %d sounds from pack: %s", registered, packName))
    return true
end

-- Get registered sound packs
function SoundRegistry:GetRegisteredPacks()
    local packs = {}
    local packMap = {}
    
    -- Collect unique packs from registered sounds
    for soundId, soundData in pairs(self.sounds) do
        BLU:PrintDebug(string.format("GetRegisteredPacks: Processing soundId=%s, packId=%s", soundId, soundData.packId))
        if soundData.packId and not packMap[soundData.packId] then
            packMap[soundData.packId] = true
            table.insert(packs, {
                id = soundData.packId,
                name = soundData.packName or soundData.packId
            })
        end
    end
    
    return packs
end

-- Get sounds grouped for UI with caching
function SoundRegistry:GetSoundsGroupedForUI(targetEvent)
    if self.uiSoundCache[targetEvent] then
        return self.uiSoundCache[targetEvent]
    end

    local hierarchy = {
        ["BLU WoW Defaults"] = {},
        ["BLU Other Game Sounds"] = {},
        ["Shared Media"] = {},
    }

    for soundId, soundData in pairs(self:GetAllSounds()) do
        if soundData.source == "SharedMedia" then
            local packId = soundData.packId or "Unidentified Pack"
            hierarchy["Shared Media"][packId] = hierarchy["Shared Media"][packId] or {}
            table.insert(hierarchy["Shared Media"][packId], {id = soundId, name = soundData.name})
        elseif soundData.category == targetEvent or soundData.category == "all" then
            if soundData.source == "BLU" or soundData.source == "BLU Built-in" then
                local packName = soundData.packName or "BLU Defaults"
                if packName == "BLU Defaults" then
                    local category = soundData.category
                    hierarchy["BLU WoW Defaults"][category] = hierarchy["BLU WoW Defaults"][category] or {}
                    table.insert(hierarchy["BLU WoW Defaults"][category], {id = soundId, name = soundData.name})
                else
                    hierarchy["BLU Other Game Sounds"][packName] = hierarchy["BLU Other Game Sounds"][packName] or {}
                    table.insert(hierarchy["BLU Other Game Sounds"][packName], {id = soundId, name = soundData.name})
                end
            end
        end
    end

    self.uiSoundCache[targetEvent] = hierarchy
    return hierarchy
end

-- Play a sound
function SoundRegistry:PlaySound(soundId, volume)
    local sound = self.sounds[soundId]
    if not sound then
        BLU:PrintDebug("Sound not found: " .. tostring(soundId))
        return false
    end
    
    -- Get volume settings from profile
    local profileVolume = 1.0
    if BLU.db and BLU.db.profile then
        profileVolume = (BLU.db.profile.soundVolume or 100) / 100
    end
    
    -- Apply volume multiplier
    volume = (volume or 1.0) * profileVolume
    
    -- Clamp volume
    volume = math.max(0, math.min(1, volume))
    
    -- Skip if volume is 0
    if volume <= 0 then
        BLU:PrintDebug("Volume is 0, skipping sound: " .. soundId)
        return false
    end
    
    -- Get sound channel from profile
    local channel = "Master"
    
    -- Play the sound based on type
    local willPlay, handle
    
    if sound.soundKit then
        -- Use PlaySound for built-in WoW sounds
        willPlay = PlaySound(sound.soundKit, channel)
        handle = sound.soundKit
    elseif sound.file then
        local fileToPlay = sound.file
        
        -- Check if this is a BLU internal sound (should have volume variants)
        if sound.source == "BLU" or sound.isInternal then
            -- BLU internal sounds SHOULD have _low, _med, _high variants
            local category = sound.category
            local volumeSetting = "medium"
            if BLU.db and BLU.db.profile and BLU.db.profile.soundVolumes and BLU.db.profile.soundVolumes[category] then
                volumeSetting = BLU.db.profile.soundVolumes[category]
            end

            if volumeSetting == "none" then
                BLU:PrintDebug("Sound muted for category: " .. category)
                return false
            end

            local variant = "_med"
            if volumeSetting == "low" then
                variant = "_low"
            elseif volumeSetting == "high" then
                variant = "_high"
            end
            
            -- Build the variant file path
            local baseFile = sound.file:gsub("_high%.ogg$", ""):gsub("_med%.ogg$", ""):gsub("_low%.ogg$", ""):gsub("%.ogg$", "")
            local variantFile = baseFile .. variant .. ".ogg"
            
            fileToPlay = variantFile
            
            willPlay, handle = PlaySoundFile(variantFile, channel)
            
            if not willPlay then
                -- Fallback to base file if variant not found
                willPlay, handle = PlaySoundFile(sound.file, channel)
            end
        else
            -- External sounds, SoundPaks, or BLU sounds without variants
            -- These play at full volume on the specified channel
            willPlay, handle = PlaySoundFile(sound.file, channel)
        end
    else
        BLU:PrintError("Sound has no file or soundKit: " .. soundId)
        return false
    end
    
    if willPlay then
        BLU:PrintDebug(string.format("Playing sound: %s (volume: %.2f, channel: %s)", soundId, volume, channel))
        
        -- Show in chat if enabled
        if BLU.db and BLU.db.profile and BLU.db.profile.debugMode then
            BLU:Print(string.format("|cff00ff00Playing:|r %s", sound.name or soundId))
        end
        
        -- Handle callbacks if provided
        if sound.onPlay then
            sound.onPlay(soundId, volume)
        end
        
        return true
    else
        BLU:PrintError("Failed to play sound: " .. soundId)
        return false
    end
end

-- Get all registered sounds
function SoundRegistry:GetAllSounds()
    return self.sounds
end

-- Play sound for a specific event category
function SoundRegistry:PlayCategorySound(category, forceSound)
    -- Check if muted in instances
    if BLU.db and BLU.db.profile and BLU.db.profile.muteInInstances then
        local inInstance, instanceType = IsInInstance()
        if inInstance and (instanceType == "party" or instanceType == "raid" or instanceType == "arena" or instanceType == "pvp") then
            BLU:PrintDebug("Sound muted in instance")
            return false
        end
    end
    
    -- Check if muted in combat
    if BLU.db and BLU.db.profile and BLU.db.profile.muteInCombat and InCombatLockdown() then
        BLU:PrintDebug("Sound muted in combat")
        return false
    end
    
    -- Check if module is enabled
    if BLU.db and BLU.db.profile and BLU.db.profile.modules and BLU.db.profile.modules[category] == false then
        BLU:PrintDebug("Module disabled for category: " .. category)
        return false
    end
    
    -- Get selected sound for category
    local selectedSound = forceSound
    if not selectedSound and BLU.db and BLU.db.profile and BLU.db.profile.selectedSounds then
        selectedSound = BLU.db.profile.selectedSounds[category]
    end
    
    -- Default to "default" if nothing selected
    if not selectedSound then
        selectedSound = "default"
    end

    if selectedSound == "None" then
        BLU:PrintDebug("Selected sound is None, skipping playback.")
        return false
    end

    if selectedSound == "random" then
        local sounds = self:GetSoundsByCategory(category)
        local soundIds = {}
        for id, _ in pairs(sounds) do
            table.insert(soundIds, id)
        end
        if #soundIds > 0 then
            local randomIndex = math.random(1, #soundIds)
            local randomSoundId = soundIds[randomIndex]
            return self:PlaySound(randomSoundId)
        else
            -- fallback to default if no sounds in category
            selectedSound = "default"
        end
    end
    
    -- Handle different sound types
    if selectedSound == "default" then
        local soundId = defaultBluSounds[category]
        if soundId then
            return self:PlaySound(soundId)
        end
    elseif selectedSound == "wow_default" then
        local wowDefaultSounds = {
            levelup = 888,  -- LEVELUPSOUND
            achievement = 12891,  -- Achievement sound
            quest = 618,  -- QuestComplete
            reputation = 12197,  -- Reputation change
            honorrank = 12173,  -- PVP Reward sound
            renownrank = 167404,  -- Renown rank up
            tradingpost = 179114,  -- Trading post sound
            battlepet = 65978,  -- Pet battle victory
            delvecompanion = 182235  -- Delve companion sound
        }
        local soundKit = wowDefaultSounds[category]
        if soundKit then
            local channel = BLU.db.profile.soundChannel or "Master"
            return PlaySound(soundKit, channel)
        end
        
    elseif selectedSound:match("^external:") then
        -- External sound from SharedMedia
        local externalName = selectedSound:gsub("^external:", "")
        if BLU.PlayExternalSound then
            return BLU:PlayExternalSound(externalName)
        end
        
    elseif selectedSound:match("^blu_") or selectedSound:match("^%w+_") then
        -- BLU internal sound pack
        local soundId = selectedSound .. "_" .. category
        return self:PlaySound(soundId)
        
    else
        -- Direct sound ID
        return self:PlaySound(selectedSound)
    end
    
    return false
end

-- Helper to get sound info
function SoundRegistry:GetSoundInfo(soundId)
    local sound = self.sounds[soundId]
    if not sound then return nil end
    
    return {
        id = soundId,
        name = sound.name,
        file = sound.file,
        soundKit = sound.soundKit,
        duration = sound.duration,
        category = sound.category,
        hasVolumeVariants = sound.hasVolumeVariants
    }
end

-- Test/preview functions
function BLU:PlayTestSound(category, volume)
    if not BLU.Registry then
        self:PrintDebug("Registry not available")
        return false
    end
    
    -- Use selected sound for category or default
    local selectedSound = self:GetDB({"selectedSounds", category})
    if not selectedSound then
        -- Try to play first available sound for category
        local sounds = BLU.Registry:GetSoundsByCategory(category)
        if sounds and next(sounds) then
            local firstId = next(sounds)
            return BLU.Registry:PlaySound(firstId, volume)
        end
    else
        return BLU.Registry:PlayCategorySound(category, volume)
    end
    
    return false
end

function BLU:PlayCategorySound(category, volume)
    if BLU.Registry then
        return BLU.Registry:PlayCategorySound(category, volume)
    end
    return false
end

function BLU:TestAllSounds()
    if not BLU.Registry then
        self:Print("Sound registry not available")
        return
    end
    
    local sounds = BLU.Registry:GetAllSounds()
    local count = 0
    local delay = 0
    
    self:Print("Testing all sounds...")
    
    for soundId, soundData in pairs(sounds) do
        count = count + 1
        C_Timer.After(delay, function()
            self:Print(string.format("[%d] Playing: %s", count, soundData.name or soundId))
            BLU.Registry:PlaySound(soundId)
        end)
        delay = delay + (soundData.duration or 2) + 0.5
    end
    
    self:Print(string.format("Scheduled %d sounds for testing", count))
end

-- Reload all sounds
function SoundRegistry:ReloadAllSounds()
    -- Clear cache
    self.sounds = {}
    self.categories = {}
    
    -- Re-initialize
    self:Init()
    
    BLU:PrintDebug("Sound registry reloaded")
end
