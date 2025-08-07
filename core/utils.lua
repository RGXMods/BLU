--=====================================================================================
-- BLU Utils Module
-- Shared utility functions
--=====================================================================================

local addonName, BLU = ...
local Utils = {}
BLU.Modules["utils"] = Utils

-- Sound queue for managing multiple sounds
Utils.soundQueue = {}
Utils.isPlaying = false

-- Initialize utils module
function Utils:Init()
    BLU:PrintDebug("Utils module initialized")
end

-- Queue a sound to be played
function Utils:QueueSound(soundFile, volume, callback)
    if not BLU.db.profile.queueSounds then
        -- Just play immediately if queuing is disabled
        self:PlaySoundFile(soundFile, volume, callback)
        return
    end
    
    -- Add to queue
    table.insert(self.soundQueue, {
        file = soundFile,
        volume = volume,
        callback = callback
    })
    
    -- Limit queue size
    local maxSize = BLU.db.profile.maxQueueSize or 3
    while #self.soundQueue > maxSize do
        table.remove(self.soundQueue, 1)
    end
    
    -- Process queue if not already playing
    if not self.isPlaying then
        self:ProcessSoundQueue()
    end
end

-- Process sound queue
function Utils:ProcessSoundQueue()
    if #self.soundQueue == 0 then
        self.isPlaying = false
        return
    end
    
    self.isPlaying = true
    local sound = table.remove(self.soundQueue, 1)
    
    self:PlaySoundFile(sound.file, sound.volume, function()
        if sound.callback then
            sound.callback()
        end
        
        -- Play next sound after a short delay
        C_Timer.After(0.1, function()
            self:ProcessSoundQueue()
        end)
    end)
end

-- Play a sound file
function Utils:PlaySoundFile(soundFile, volume, callback)
    local channel = BLU.db.profile.soundChannel or "Master"
    local willPlay, handle = PlaySoundFile(soundFile, channel)
    
    if willPlay then
        -- Stop music if configured
        if BLU.db.profile.interruptMusic then
            StopMusic()
        end
        
        -- Set volume if supported
        if handle and volume then
            -- Note: WoW doesn't support per-sound volume, this is for future use
        end
        
        if callback then
            -- Estimate duration and call callback
            C_Timer.After(2, callback)
        end
    else
        BLU:PrintDebug("Failed to play sound: " .. tostring(soundFile))
        if callback then
            callback()
        end
    end
end

-- Format time duration
function Utils:FormatDuration(seconds)
    if seconds < 60 then
        return string.format("%ds", seconds)
    elseif seconds < 3600 then
        return string.format("%dm %ds", seconds / 60, seconds % 60)
    else
        return string.format("%dh %dm", seconds / 3600, (seconds % 3600) / 60)
    end
end

-- Throttle function calls
Utils.throttleTimers = {}
function Utils:Throttle(key, seconds, func)
    local now = GetTime()
    
    if not self.throttleTimers[key] or (now - self.throttleTimers[key]) >= seconds then
        self.throttleTimers[key] = now
        return func()
    end
end

-- Debounce function calls
Utils.debounceTimers = {}
function Utils:Debounce(key, seconds, func)
    if self.debounceTimers[key] then
        self.debounceTimers[key]:Cancel()
    end
    
    self.debounceTimers[key] = C_Timer.NewTimer(seconds, func)
end

-- Get addon memory usage
function Utils:GetMemoryUsage()
    UpdateAddOnMemoryUsage()
    local usage = GetAddOnMemoryUsage("BLU")
    return usage
end

-- Format memory size
function Utils:FormatMemory(kb)
    if kb < 1024 then
        return string.format("%.1f KB", kb)
    else
        return string.format("%.2f MB", kb / 1024)
    end
end

-- Check if in combat
function Utils:IsInCombat()
    return InCombatLockdown()
end

-- Safe function call (delays if in combat)
function Utils:SafeCall(func)
    if self:IsInCombat() then
        BLU:RegisterEvent("PLAYER_REGEN_ENABLED", function()
            BLU:UnregisterEvent("PLAYER_REGEN_ENABLED")
            func()
        end)
    else
        func()
    end
end

-- Color text with hex color
function Utils:ColorText(text, color)
    return string.format("|cff%s%s|r", color, text)
end

-- Common colors
Utils.colors = {
    blu = "05dffa",
    green = "00ff00",
    red = "ff0000",
    yellow = "ffff00",
    orange = "ff8000",
    purple = "9d4dc5",
    white = "ffffff",
    gray = "808080"
}

-- Export module
return Utils