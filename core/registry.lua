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
    achievementprogress = "achievement_progress_default",
    quest = "quest_default",
    questaccept = "quest_accept_default",
    questturnin = "quest_turnin_default",
    reputation = "rep_default",
    battlepet = "battle_pet_level_default",
    petcapture = "pet_capture_default",
    honorrank = "honor_default",
    renownrank = "renown_default",
    tradingpost = "post_default",
    delvecompanion = "delve_default",
    delvelifelost = "delve_life_lost_default",
    delvelifegained = "delve_life_gained_default",
    housingxpgained = "housing_xp_default",
    housingleveledup = "housing_level_default",
    housingrewardsreceived = "housing_rewards_default",
    housingdecorcollected = "housing_decor_default",
}

local moduleCategoryMap = {
    questaccept = "quest",
    questturnin = "quest",
    questprogress = "quest",
    achievementprogress = "achievement",
    petcapture = "battlepet",
    delvelifelost = "delvecompanion",
    delvelifegained = "delvecompanion",
}

local CATEGORY_SOUND_COOLDOWN_SECONDS = 0.20
local GLOBAL_SOUND_COOLDOWN_SECONDS = 0.05

BLU.Modules["registry"] = SoundRegistry
BLU.SoundRegistry = SoundRegistry
BLU.Registry = SoundRegistry

-- Sound storage with caching
SoundRegistry.sounds = {}
SoundRegistry.categories = {}
SoundRegistry.soundCache = {} -- Performance cache
SoundRegistry.lastCacheUpdate = 0
SoundRegistry.uiSoundCache = {} -- Cache for UI dropdowns
SoundRegistry.lastCategoryPlayAt = {}
SoundRegistry.lastAnyPlayAt = 0

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
    BLU:PrintDebug("[Registry] GetSound called for '" .. tostring(soundId) .. "'")
    return self.sounds[soundId]
end

-- Get sounds by category
function SoundRegistry:GetSoundsByCategory(category)
    BLU:PrintDebug("[Registry] GetSoundsByCategory called for '" .. tostring(category) .. "'")
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

function SoundRegistry:GetSoundsGroupedForUI(targetEvent)
    BLU:PrintDebug("[Registry] GetSoundsGroupedForUI called for '" .. tostring(targetEvent) .. "'")
    if self.uiSoundCache[targetEvent] then
        BLU:PrintDebug("[Registry] Returning cached UI sound hierarchy for '" .. tostring(targetEvent) .. "'")
        return self.uiSoundCache[targetEvent]
    end

    local hierarchy = {
        ["BLU WoW Defaults"] = {},
        ["BLU Other Game Sounds"] = {},
        ["User Custom Sounds"] = {},
        ["Shared Media"] = {},
    }

    for soundId, soundData in pairs(self:GetAllSounds()) do
        if soundData.source == "SharedMedia" then
            local packId = soundData.packId or "Unidentified Pack"
            hierarchy["Shared Media"][packId] = hierarchy["Shared Media"][packId] or {}
            table.insert(hierarchy["Shared Media"][packId], {id = soundId, name = soundData.name})
        elseif soundData.source == "UserCustom" then
            table.insert(hierarchy["User Custom Sounds"], {id = soundId, name = soundData.name})
        elseif soundData.category == targetEvent or soundData.category == "all" then
            if soundData.source == "BLU" or soundData.source == "BLU Built-in" then
                local packName = soundData.packName or "BLU Defaults"
                if packName == "BLU Defaults" then
                    table.insert(hierarchy["BLU WoW Defaults"], {id = soundId, name = soundData.name})
                else
                    hierarchy["BLU Other Game Sounds"][packName] = hierarchy["BLU Other Game Sounds"][packName] or {}
                    table.insert(hierarchy["BLU Other Game Sounds"][packName], {id = soundId, name = soundData.name})
                end
            end
        end
    end

    self.uiSoundCache[targetEvent] = hierarchy
    BLU:PrintDebug("[Registry] Built UI sound hierarchy for '" .. tostring(targetEvent) .. "'")
    return hierarchy
end

function SoundRegistry:GetAllPlayableSoundIds()
    BLU:PrintDebug("[Registry] GetAllPlayableSoundIds called")
    local grouped = {
        self:GetSoundsGroupedForUI("levelup"),
        self:GetSoundsGroupedForUI("achievement"),
        self:GetSoundsGroupedForUI("achievementprogress"),
        self:GetSoundsGroupedForUI("questaccept"),
        self:GetSoundsGroupedForUI("questturnin"),
        self:GetSoundsGroupedForUI("questprogress"),
        self:GetSoundsGroupedForUI("reputation"),
        self:GetSoundsGroupedForUI("battlepet"),
        self:GetSoundsGroupedForUI("petcapture"),
        self:GetSoundsGroupedForUI("honorrank"),
        self:GetSoundsGroupedForUI("renownrank"),
        self:GetSoundsGroupedForUI("tradingpost"),
        self:GetSoundsGroupedForUI("delvecompanion"),
        self:GetSoundsGroupedForUI("delvelifelost"),
        self:GetSoundsGroupedForUI("delvelifegained"),
        self:GetSoundsGroupedForUI("housingxpgained"),
        self:GetSoundsGroupedForUI("housingleveledup"),
        self:GetSoundsGroupedForUI("housingrewardsreceived"),
        self:GetSoundsGroupedForUI("housingdecorcollected"),
    }
    local soundIds = {}
    local seen = {}

    local function addSoundId(soundId)
        if soundId and not seen[soundId] then
            seen[soundId] = true
            table.insert(soundIds, soundId)
        end
    end

    local function walk(node)
        if type(node) ~= "table" then
            return
        end

        if node.id then
            addSoundId(node.id)
            return
        end

        for _, value in pairs(node) do
            walk(value)
        end
    end

    for _, group in ipairs(grouped) do
        walk(group)
    end

    for _, defaultSoundId in pairs(defaultBluSounds) do
        addSoundId(defaultSoundId)
    end

    BLU:PrintDebug("[Registry] Collected " .. tostring(#soundIds) .. " playable sound ids")
    return soundIds
end

-- Play a sound
function SoundRegistry:PlaySound(soundId, volume, options)
    BLU:PrintDebug("[Registry] PlaySound called for '" .. tostring(soundId) .. "'")
    local sound = self.sounds[soundId]
    if not sound then
        BLU:PrintDebug("Sound not found: " .. tostring(soundId))
        return false
    end

    options = options or {}
    BLU:PrintDebug("[Registry] PlaySound options categoryOverride='" .. tostring(options.categoryOverride) .. "', volumeOverride='" .. tostring(options.volumeSettingOverride) .. "'")
    
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
    
    local channel = "Master"
    
    -- Play the sound based on type
    local willPlay, handle
    
    if sound.soundKit then
        BLU:PrintDebug("[Registry] Using soundKit playback for '" .. tostring(soundId) .. "'")
        -- Use PlaySound for built-in WoW sounds
        willPlay = PlaySound(sound.soundKit, channel)
        handle = sound.soundKit
    elseif sound.file then
        BLU:PrintDebug("[Registry] Using file playback for '" .. tostring(soundId) .. "'")
        local fileToPlay = sound.file
        
        -- Check if this is a BLU sound (all BLU sounds have _low, _med, _high variants)
        if sound.isInternal or sound.source == "BLU" then
            BLU:PrintDebug("[Registry] Sound is BLU source; resolving volume variant for category '" .. tostring(options.categoryOverride or sound.category) .. "'")
            -- BLU sounds have _low, _med, _high variants
            local category = options.categoryOverride or sound.category
            local volumeSetting = options.volumeSettingOverride or "medium"
            if not options.volumeSettingOverride and BLU.db and BLU.db.profile and BLU.db.profile.soundVolumes and BLU.db.profile.soundVolumes[category] then
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
            BLU:PrintDebug("Attempting to play sound: " .. fileToPlay)
            
            willPlay, handle = PlaySoundFile(variantFile, channel)
            
            if not willPlay then
                -- Fallback to base file if variant not found
                BLU:PrintDebug("Failed to play variant, falling back to base file: " .. sound.file)
                willPlay, handle = PlaySoundFile(sound.file, channel)
            end
        else
            BLU:PrintDebug("[Registry] Sound is external/non-internal; using direct file playback")
            -- External sounds, SoundPaks, or BLU sounds without variants.
            -- User custom sounds may carry candidate files so shorthand adds can
            -- fall back across supported extensions and common locations.
            local fileCandidates = {}
            local seenFiles = {}

            local function addFileCandidate(filePath)
                if type(filePath) == "string" and filePath ~= "" and not seenFiles[filePath] then
                    seenFiles[filePath] = true
                    table.insert(fileCandidates, filePath)
                end
            end

            addFileCandidate(sound.file)
            if type(sound.candidateFiles) == "table" then
                for _, candidateFile in ipairs(sound.candidateFiles) do
                    addFileCandidate(candidateFile)
                end
            end

            for _, candidateFile in ipairs(fileCandidates) do
                BLU:PrintDebug("[Registry] Attempting direct file playback for '" .. tostring(soundId) .. "' using '" .. tostring(candidateFile) .. "'")
                willPlay, handle = PlaySoundFile(candidateFile, channel)
                if willPlay then
                    if candidateFile ~= sound.file then
                        BLU:PrintDebug("[Registry] Direct file playback succeeded using fallback candidate '" .. tostring(candidateFile) .. "'")
                    end
                    break
                end
            end
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
    BLU:PrintDebug("[Registry] PlayCategorySound called for '" .. tostring(category) .. "' with forceSound='" .. tostring(forceSound) .. "'")
    if BLU.db and BLU.db.profile and BLU.db.profile.enabled == false then
        BLU:PrintDebug("BLU disabled, skipping category sound: " .. tostring(category))
        return false
    end

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
    local moduleKey = moduleCategoryMap[category] or category
    BLU:PrintDebug("[Registry] Resolved module key for category '" .. tostring(category) .. "' to '" .. tostring(moduleKey) .. "'")
    if BLU.db and BLU.db.profile and BLU.db.profile.modules and BLU.db.profile.modules[moduleKey] == false then
        BLU:PrintDebug("Module disabled for category: " .. category)
        return false
    end

    local now = GetTime and GetTime() or 0
    local lastForCategory = self.lastCategoryPlayAt[category]
    if lastForCategory and (now - lastForCategory) < CATEGORY_SOUND_COOLDOWN_SECONDS then
        BLU:PrintDebug("Skipped duplicate sound in cooldown window for category: " .. category)
        return false
    end

    if self.lastAnyPlayAt and (now - self.lastAnyPlayAt) < GLOBAL_SOUND_COOLDOWN_SECONDS then
        BLU:PrintDebug("Skipped sound due to global cooldown for category: " .. category)
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
    BLU:PrintDebug("[Registry] Selected sound for category '" .. tostring(category) .. "' is '" .. tostring(selectedSound) .. "'")

    if selectedSound == "None" then
        BLU:PrintDebug("Selected sound is None, skipping playback.")
        return false
    end

    if selectedSound == "random" then
        BLU:PrintDebug("[Registry] Random sound selection requested for '" .. tostring(category) .. "'")
        local soundIds = self:GetAllPlayableSoundIds()
        if #soundIds > 0 then
            local randomIndex = math.random(1, #soundIds)
            local randomSoundId = soundIds[randomIndex]
            BLU:PrintDebug("[Registry] Randomly selected '" .. tostring(randomSoundId) .. "' for category '" .. tostring(category) .. "'")
            local played = self:PlaySound(randomSoundId, nil, {
                categoryOverride = category,
                volumeSettingOverride = "medium",
            })
            if played then
                self.lastCategoryPlayAt[category] = now
                self.lastAnyPlayAt = now
            end
            return played
        else
            -- fallback to default if no sounds in category
            selectedSound = "default"
        end
    end
    
    -- Handle different sound types
    if selectedSound == "default" then
        local soundId = defaultBluSounds[category]
        BLU:PrintDebug("[Registry] Default sound lookup for category '" .. tostring(category) .. "' => '" .. tostring(soundId) .. "'")
        if soundId then
            local played = self:PlaySound(soundId, nil, { categoryOverride = category })
            if played then
                self.lastCategoryPlayAt[category] = now
                self.lastAnyPlayAt = now
            end
            return played
        end
        
    elseif selectedSound:match("^external:") then
        BLU:PrintDebug("[Registry] External sound playback for '" .. tostring(selectedSound) .. "'")
        local externalName = selectedSound:gsub("^external:", "")
        if BLU.PlayExternalSound then
            local played = BLU:PlayExternalSound(externalName)
            if played then
                self.lastCategoryPlayAt[category] = now
                self.lastAnyPlayAt = now
            end
            return played
        end

    else
        BLU:PrintDebug("[Registry] Direct sound id playback for '" .. tostring(selectedSound) .. "'")
        -- Direct sound ID
        local played = self:PlaySound(selectedSound, nil, { categoryOverride = category })
        if played then
            self.lastCategoryPlayAt[category] = now
            self.lastAnyPlayAt = now
        end
        return played
    end
    
    return false
end

-- Helper to get sound info
function SoundRegistry:GetSoundInfo(soundId)
    BLU:PrintDebug("[Registry] GetSoundInfo called for '" .. tostring(soundId) .. "'")
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
    self:PrintDebug("[Registry] BLU:PlayTestSound helper called for '" .. tostring(category) .. "'")
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
    self:PrintDebug("[Registry] BLU:PlayCategorySound helper called for '" .. tostring(category) .. "'")
    if BLU.Registry then
        return BLU.Registry:PlayCategorySound(category, volume)
    end
    return false
end

function BLU:TestAllSounds()
    self:PrintDebug("[Registry] TestAllSounds called")
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
    BLU:PrintDebug("[Registry] ReloadAllSounds called")
    -- Clear cache
    self.sounds = {}
    self.categories = {}
    
    -- Re-initialize
    self:Init()
    
    BLU:PrintDebug("Sound registry reloaded")
end
