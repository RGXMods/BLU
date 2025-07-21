--=====================================================================================
-- BLU Sound Registry Module
-- Manages all sound registrations and playback
--=====================================================================================

local addonName, addonTable = ...
local SoundRegistry = {}

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
    
    -- Get volume settings
    volume = volume or 1.0
    if BLU.db then
        volume = volume * (BLU.db.masterVolume or 1.0)
    end
    
    -- Clamp volume
    volume = math.max(0, math.min(1, volume))
    
    -- Skip if volume is 0
    if volume <= 0 then
        BLU:PrintDebug("Volume is 0, skipping sound: " .. soundId)
        return false
    end
    
    -- Get sound channel
    local channel = "Master"
    if BLU.db and BLU.db.soundChannel then
        channel = BLU.db.soundChannel
    end
    
    -- Play the sound
    local willPlay, handle = PlaySoundFile(sound.file, channel)
    
    if willPlay then
        BLU:PrintDebug(string.format("Playing sound: %s (volume: %.2f)", soundId, volume))
        
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

-- Export module
BLU:RegisterModule("SoundRegistry", SoundRegistry)
return SoundRegistry