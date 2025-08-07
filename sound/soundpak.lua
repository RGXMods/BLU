--=====================================================================================
-- BLU SoundPak Bridge Module
-- Provides compatibility with SoundPak addons using Ace libraries
--=====================================================================================

local addonName, BLU = ...
local SoundPakBridge = {}

-- LibSharedMedia integration
local LSM = LibStub and LibStub("LibSharedMedia-3.0", true) or nil

-- SoundPak registry
SoundPakBridge.registeredPaks = {}
SoundPakBridge.soundMapping = {}

-- Initialize SoundPak Bridge
function SoundPakBridge:Init()
    if not LSM then
        BLU:PrintDebug("LibSharedMedia not found - SoundPak support disabled")
        return
    end
    
    -- Register for SharedMedia callbacks
    LSM.RegisterCallback(self, "LibSharedMedia_Registered", "OnMediaRegistered")
    LSM.RegisterCallback(self, "LibSharedMedia_SetGlobal", "OnMediaSetGlobal")
    
    -- Scan for existing sound paks
    self:ScanExistingSounds()
    
    BLU:PrintDebug("SoundPak Bridge initialized")
end

-- Scan existing sounds from LibSharedMedia
function SoundPakBridge:ScanExistingSounds()
    if not LSM then return end
    
    local soundList = LSM:List("sound")
    
    for _, soundName in ipairs(soundList) do
        local soundPath = LSM:Fetch("sound", soundName)
        if soundPath then
            self:RegisterExternalSound(soundName, soundPath)
        end
    end
    
    BLU:PrintDebug(string.format("Found %d external sounds", #soundList))
end

-- Register external sound from SoundPak
function SoundPakBridge:RegisterExternalSound(name, path)
    -- Create a BLU-compatible sound entry
    local bluSoundId = "soundpak_" .. name:lower():gsub("%s+", "_")
    
    local soundData = {
        name = "SoundPak - " .. name,
        file = path,
        duration = 2.0, -- Default duration, can be overridden
        category = "external",
        source = "soundpak"
    }
    
    -- Register with BLU
    BLU:RegisterSound(bluSoundId, soundData)
    
    -- Track the mapping
    self.soundMapping[name] = bluSoundId
end

-- Handle new media registration
function SoundPakBridge:OnMediaRegistered(event, mediatype, key)
    if mediatype ~= "sound" then return end
    
    local soundPath = LSM:Fetch("sound", key)
    if soundPath then
        self:RegisterExternalSound(key, soundPath)
        BLU:PrintDebug("New SoundPak sound registered: " .. key)
    end
end

-- Convert SoundPak format to BLU format
function SoundPakBridge:ConvertSoundPakToBLU(soundPakData)
    -- SoundPaks typically have a single sound file
    -- BLU has multiple volume variants
    -- We'll create a mapping system
    
    local bluFormat = {
        high = soundPakData.file,
        medium = soundPakData.file, -- Same file, adjusted via volume
        low = soundPakData.file,    -- Same file, adjusted via volume
        volumes = {
            high = 1.0,
            medium = 0.7,
            low = 0.5
        }
    }
    
    return bluFormat
end

-- Get available SoundPak sounds for a category
function SoundPakBridge:GetSoundPakSounds(category)
    local sounds = {}
    
    if not LSM then return sounds end
    
    local soundList = LSM:List("sound")
    
    for _, soundName in ipairs(soundList) do
        -- Filter by category if needed
        if self:SoundMatchesCategory(soundName, category) then
            local bluSoundId = self.soundMapping[soundName]
            if bluSoundId then
                table.insert(sounds, {
                    id = bluSoundId,
                    name = soundName,
                    source = "soundpak"
                })
            end
        end
    end
    
    return sounds
end

-- Check if sound matches category (basic pattern matching)
function SoundPakBridge:SoundMatchesCategory(soundName, category)
    local patterns = {
        levelup = {"level", "ding", "levelup", "level up"},
        achievement = {"achieve", "complete", "success"},
        quest = {"quest", "accept", "turnin", "complete"},
        reputation = {"reputation", "rep", "standing"},
        pvp = {"pvp", "honor", "conquest"}
    }
    
    if not patterns[category] then return true end -- No filter
    
    local lowerName = soundName:lower()
    
    for _, pattern in ipairs(patterns[category]) do
        if lowerName:find(pattern) then
            return true
        end
    end
    
    return false
end

-- Register a SoundPak addon
function SoundPakBridge:RegisterSoundPak(pakName, pakData)
    self.registeredPaks[pakName] = pakData
    
    -- Process sounds from the pak
    if pakData.sounds then
        for soundId, soundInfo in pairs(pakData.sounds) do
            self:RegisterExternalSound(soundId, soundInfo.file or soundInfo)
        end
    end
    
    BLU:PrintDebug("SoundPak registered: " .. pakName)
end

-- API for other addons to register with BLU
function BLU:RegisterSoundPak(pakName, pakData)
    return SoundPakBridge:RegisterSoundPak(pakName, pakData)
end

-- Export module
return SoundPakBridge