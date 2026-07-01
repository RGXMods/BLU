--=====================================================================================
-- BLU - sharedmedia.lua
-- Thin bridge over RGXSharedMedia. All external sound scanning (DBM registrars,
-- known-addon compatibility, generic addon-global scan) now lives in the shared
-- framework module RGXSharedMedia. This file only imports the framework's scan
-- results into BLU.SoundRegistry and re-exports BLU's public sound-bridge API.
--
-- Replaces the former 830-line local scanner. See RGX-Framework
-- modules/sharedmedia/sharedmedia.lua for the scanning implementation.
--=====================================================================================

local addonName, _ = ...
local BLU = _G["BLU"]

local SharedMedia = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["sharedmedia"] = SharedMedia

-- Mirror of imported entries, keyed by sound id, for compat with callers that
-- read BLU.GetExternalSounds().
SharedMedia.externalSounds = {}
SharedMedia.soundCategories = {}
SharedMedia._listenerRegistered = false

local function GetRGX()
    return _G.RGXFramework
end

local function GetSM()
    local RGX = GetRGX()
    if RGX and type(RGX.GetSharedMedia) == "function" then
        return RGX:GetSharedMedia()
    end
    return _G.RGXSharedMedia
end

-- Remove all sounds previously imported from the shared media registry so a
-- re-import starts clean. Mirrors the old ClearExternalFromRegistry behavior.
function SharedMedia:ClearImported()
    if not BLU.SoundRegistry or type(BLU.SoundRegistry.GetAllSounds) ~= "function" then
        return
    end

    local removeIds = {}
    for soundId, soundData in pairs(BLU.SoundRegistry:GetAllSounds()) do
        if soundData and soundData.source == "SharedMedia" then
            removeIds[#removeIds + 1] = soundId
        end
    end

    for _, soundId in ipairs(removeIds) do
        BLU.SoundRegistry:UnregisterSound(soundId)
    end
end

-- Pull the current sound entries from RGXSharedMedia and register them into
-- BLU.SoundRegistry as source="SharedMedia" bridge sounds.
function SharedMedia:ImportFromRGX()
    local SM = GetSM()
    if not SM or type(SM.List) ~= "function" then
        return
    end

    wipe(self.externalSounds)
    wipe(self.soundCategories)
    self:ClearImported()

    local imported = 0
    for _, entry in ipairs(SM:List("sound")) do
        if entry and entry.path then
            local soundId = entry.id
            local record = {
                name = entry.name,
                file = entry.path,
                category = "all",
                source = "SharedMedia",
                packId = entry.packId,
                packName = entry.packName,
                isBridge = true,
            }

            if BLU.SoundRegistry and type(BLU.SoundRegistry.RegisterSound) == "function" then
                BLU.SoundRegistry:RegisterSound(soundId, record)
            end

            self.externalSounds[soundId] = record
            imported = imported + 1
        end
    end

    -- Invalidate UI cache and refresh the Sounds panel if it is open.
    if BLU.SoundRegistry then
        BLU.SoundRegistry.uiSoundCache = {}
    end
    if type(BLU.RefreshSoundPackUI) == "function" then
        local ok, err = pcall(BLU.RefreshSoundPackUI)
        if not ok then
            BLU:PrintDebug("Failed to refresh Sounds panel after media import: " .. tostring(err))
        end
    end

    BLU:PrintDebug(string.format("[SharedMedia] Imported %d sound(s) from RGXSharedMedia.", imported))
end

-- Ask RGXSharedMedia to (re)scan. Its scan fires RGX_SHAREDMEDIA_UPDATED, which
-- triggers ImportFromRGX via the message listener.
function SharedMedia:QueueRescan(delay)
    local SM = GetSM()
    if SM and type(SM.QueueScan) == "function" then
        SM:QueueScan(delay or 0, false)
    end
end

-- Public bridge API for non-LSM addons: forward to RGXSharedMedia's pack
-- registration, then re-import so the entries appear in BLU immediately.
function SharedMedia:RegisterExternalSoundPack(packName, soundEntries)
    local SM = GetSM()
    if not SM or type(SM.RegisterSoundPack) ~= "function" then
        return 0
    end

    local registered = SM:RegisterSoundPack(packName or "External", soundEntries)
    self:ImportFromRGX()
    return registered
end

function SharedMedia:GetExternalSounds()
    return self.externalSounds
end

function SharedMedia:GetSoundCategories()
    return self.soundCategories
end

function SharedMedia:PlayExternalSound(name)
    -- Preserves the original bridge behavior exactly: try the "external:<name>"
    -- registry id first, then the imported mirror keyed by id.
    if BLU.SoundRegistry then
        local soundId = "external:" .. tostring(name)
        local sound = BLU.SoundRegistry.sounds and BLU.SoundRegistry.sounds[soundId]
        if sound and sound.file then
            if PlaySoundFile(sound.file, "Master") then
                return true
            end
        end
    end

    local entry = self.externalSounds[name]
    if entry and entry.file then
        if PlaySoundFile(entry.file, "Master") then
            return true
        end
    end

    BLU:PrintDebug("External sound not found: " .. tostring(name))
    return false
end

function SharedMedia:Init()
    BLU:PrintDebug("SharedMedia bridge:Init() called.")

    local RGX = GetRGX()
    if not RGX then
        BLU:PrintDebug("[SharedMedia] RGXFramework not present — external sound bridge disabled.")
        return
    end

    -- Import whenever RGXSharedMedia finishes a scan.
    if not self._listenerRegistered and type(RGX.RegisterMessage) == "function" then
        RGX:RegisterMessage("RGX_SHAREDMEDIA_UPDATED", function()
            self:ImportFromRGX()
        end, "BLU_SharedMedia_Import")
        self._listenerRegistered = true
    end

    -- Public API forwarded to this bridge.
    BLU.GetExternalSounds       = function() return self:GetExternalSounds() end
    BLU.GetSoundCategories      = function() return self:GetSoundCategories() end
    BLU.PlayExternalSound       = function(_, name) return self:PlayExternalSound(name) end
    BLU.RefreshExternalSounds   = function() self:QueueRescan(0) end
    BLU.RegisterExternalSoundPack = function(_, packName, soundEntries)
        return self:RegisterExternalSoundPack(packName, soundEntries)
    end

    -- Import whatever RGXSharedMedia already discovered, then nudge a rescan so
    -- late-loading providers are picked up (the scan fires the import again).
    self:ImportFromRGX()
    self:QueueRescan(0.25)

    BLU:PrintDebug("SharedMedia bridge initialized")
end
