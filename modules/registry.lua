--=====================================================================================
-- BLU Sound Registry Module
-- Manages all sound registrations and playback
--=====================================================================================

local addonName, addonTable = ...
local SoundRegistry = {}
BLU.Modules["registry"] = SoundRegistry

-- Sound storage
SoundRegistry.sounds = {}
SoundRegistry.categories = {}

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
    
    BLU:PrintDebug(BLU:Loc("MODULE_LOADED", "SoundRegistry"))
end

-- Register a sound
function SoundRegistry:RegisterSound(soundId, soundData)
    if not soundId or not soundData then
        BLU:PrintError("Invalid sound registration")
        return false
    end
    
    -- Store sound
    self.sounds[soundId] = soundData
    
    -- Track category
    if soundData.category then
        self.categories[soundData.category] = self.categories[soundData.category] or {}
        self.categories[soundData.category][soundId] = true
    end
    
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
    if BLU.db and BLU.db.profile and BLU.db.profile.soundChannel then
        channel = BLU.db.profile.soundChannel
    end
    
    -- Play the sound based on type
    local willPlay, handle
    
    if sound.soundKit then
        -- Use PlaySound for built-in WoW sounds
        willPlay = PlaySound(sound.soundKit, channel)
        handle = sound.soundKit
    elseif sound.file then
        -- For BLU's internal sounds with volume variants
        if sound.isInternal and volume < 1.0 then
            -- Choose appropriate volume variant based on volume setting
            local variant
            if volume <= 0.33 then
                variant = "low"
            elseif volume <= 0.66 then
                variant = "med"
            else
                variant = "high"
            end
            
            -- Try to find volume variant file
            local variantFile = sound.file:gsub("%.ogg$", "_" .. variant .. ".ogg")
            if variantFile ~= sound.file then
                willPlay, handle = PlaySoundFile(variantFile, channel)
            else
                willPlay, handle = PlaySoundFile(sound.file, channel)
            end
        else
            -- External sounds or full volume - play as is
            willPlay, handle = PlaySoundFile(sound.file, channel)
        end
    else
        BLU:PrintError("Sound has no file or soundKit: " .. soundId)
        return false
    end
    
    if willPlay then
        BLU:PrintDebug(string.format("Playing sound: %s (volume: %.2f, channel: %s)", soundId, volume, channel))
        
        -- Show in chat if debug mode is on
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
    -- Get selected sound for category
    local selectedSound = forceSound
    if not selectedSound and BLU.db and BLU.db.profile and BLU.db.profile.selectedSounds then
        selectedSound = BLU.db.profile.selectedSounds[category]
    end
    
    -- Check if it's an external sound
    if selectedSound and selectedSound:match("^external:") then
        local externalName = selectedSound:gsub("^external:", "")
        if BLU.PlayExternalSound then
            return BLU:PlayExternalSound(externalName)
        end
    end
    
    -- Check if random sounds are enabled
    if BLU.db and BLU.db.profile and BLU.db.profile.randomSounds then
        -- Get all sounds for this category
        local categorySounds = self:GetSoundsByCategory(category)
        local soundList = {}
        
        for soundId in pairs(categorySounds) do
            table.insert(soundList, soundId)
        end
        
        if #soundList > 0 then
            local randomIndex = math.random(1, #soundList)
            return self:PlaySound(soundList[randomIndex])
        end
    else
        -- Use selected sound for category
        if selectedSound and selectedSound ~= "default" and not selectedSound:match("^external:") then
            -- Build sound ID from game + category
            local soundId = selectedSound .. "_" .. category
            
            -- Try to play the sound
            if self.sounds[soundId] then
                return self:PlaySound(soundId)
            else
                BLU:PrintDebug("Sound not found: " .. soundId)
            end
        elseif selectedSound == "default" then
            -- Play default WoW sound if available
            return self:PlayDefaultSound(category)
        end
    end
    
    return false
end

-- Play default WoW sounds
function SoundRegistry:PlayDefaultSound(category)
    local defaultSounds = {
        levelup = 888,     -- gsTitleIntroMovie
        achievement = 12891, -- Achievement sound
        quest = 618,       -- QuestComplete
        reputation = 12198, -- Reputation change
        honorrank = 8455,  -- PVP Reward
        renownrank = 168610, -- Renown rank up
        tradingpost = 179115, -- Trading post fanfare
        battlepet = 65973,  -- Pet battle victory
        delvecompanion = 182216 -- Delve complete
    }
    
    local soundKit = defaultSounds[category]
    if soundKit then
        local channel = "Master"
        if BLU.db and BLU.db.profile and BLU.db.profile.soundChannel then
            channel = BLU.db.profile.soundChannel
        end
        PlaySound(soundKit, channel)
        BLU:PrintDebug(string.format("Playing default sound for %s (soundKit: %d)", category, soundKit))
        return true
    end
    
    return false
end

-- Get sound list for UI
function SoundRegistry:GetSoundList(category, includeNone)
    local list = {}
    
    if includeNone then
        list["None"] = BLU:Loc("SOUND_NONE") or "None"
    end
    
    -- Add sounds from category or all
    local sounds = category and self:GetSoundsByCategory(category) or self.sounds
    
    for soundId, soundData in pairs(sounds) do
        list[soundId] = soundData.name or soundId
    end
    
    return list
end

-- Helper functions for options
function BLU:GetSoundList(soundType)
    if not BLU.Modules.registry then return {} end
    return BLU.Modules.registry:GetSoundList(soundType)
end

function BLU:GetSoundName(soundId)
    if not soundId or not BLU.Modules.registry then return nil end
    local sounds = BLU.Modules.registry:GetAllSounds()
    return sounds[soundId] and sounds[soundId].name or nil
end

-- Export module
-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["registry"] = SoundRegistry
return SoundRegistry