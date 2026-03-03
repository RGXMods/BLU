--=====================================================================================
-- BLU - sharedmedia.lua
-- Integration with LibSharedMedia and external sound pack addons
--=====================================================================================

local addonName, _ = ...
local BLU = _G["BLU"]

-- Create SharedMedia module
local SharedMedia = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["sharedmedia"] = SharedMedia

-- Storage for external sounds
SharedMedia.externalSounds = {}
SharedMedia.soundCategories = {}
SharedMedia.callbacksRegistered = false
SharedMedia.eventsRegistered = false
SharedMedia.pendingRescan = false

local SHARED_MEDIA_ADDON_EVENT_ID = "sharedmedia_addon_loaded"
local SHARED_MEDIA_LOGIN_EVENT_ID = "sharedmedia_player_login"

local function SortCaseInsensitive(a, b)
    return string.lower(a) < string.lower(b)
end

-- Attempt to infer addon folder name from a media file path.
local function ExtractAddonNameFromPath(path)
    if type(path) ~= "string" or path == "" then
        return "SharedMedia"
    end

    -- Normalize separators so matching works on both slash styles.
    local normalizedPath = path:gsub("\\", "/")
    local addonFolder = normalizedPath:match("[Ii]nterface/[Aa]dd[oO]ns/([^/]+)")

    if addonFolder and addonFolder ~= "" then
        return addonFolder
    end

    return "SharedMedia"
end

-- Try to bind to LibSharedMedia when it becomes available.
function SharedMedia:TryBindLSM()
    if self.LSM then
        return true
    end

    local libStub = _G.LibStub
    if not libStub then
        return false
    end

    local ok, lsm = pcall(function()
        return libStub("LibSharedMedia-3.0", true)
    end)

    if not ok or not lsm then
        return false
    end

    self.LSM = lsm

    if not self.callbacksRegistered then
        self.LSM.RegisterCallback(self, "LibSharedMedia_Registered", "OnMediaRegistered")
        self.LSM.RegisterCallback(self, "LibSharedMedia_SetGlobal", "OnMediaSetGlobal")
        self.callbacksRegistered = true
    end

    BLU:PrintDebug("LibSharedMedia found and callbacks registered.")
    return true
end

-- Remove previously registered external sounds before rebuilding the set.
function SharedMedia:ClearExternalFromRegistry()
    if not BLU.SoundRegistry or not BLU.SoundRegistry.GetAllSounds or not BLU.SoundRegistry.UnregisterSound then
        return
    end

    local removeIds = {}
    for soundId, soundData in pairs(BLU.SoundRegistry:GetAllSounds()) do
        if soundData and soundData.source == "SharedMedia" then
            table.insert(removeIds, soundId)
        end
    end

    for _, soundId in ipairs(removeIds) do
        BLU.SoundRegistry:UnregisterSound(soundId)
    end
end

-- Queue a rescan to avoid repeated full scans during burst registrations.
function SharedMedia:QueueRescan(delaySeconds)
    if self.pendingRescan then
        return
    end

    self.pendingRescan = true

    local function runRescan()
        self.pendingRescan = false

        local ok, err = pcall(function()
            self:ScanExternalSounds()
        end)

        if not ok then
            BLU:PrintError("SharedMedia rescan failed: " .. tostring(err))
        end
    end

    if C_Timer and C_Timer.After then
        C_Timer.After(delaySeconds or 0, runRescan)
    else
        runRescan()
    end
end

-- Initialize SharedMedia integration.
function SharedMedia:Init()
    BLU:PrintDebug("SharedMedia:Init() called.")

    if not self.eventsRegistered then
        BLU:RegisterEvent("ADDON_LOADED", function(event, loadedAddonName)
            self:OnAddonLoaded(loadedAddonName)
        end, SHARED_MEDIA_ADDON_EVENT_ID)

        BLU:RegisterEvent("PLAYER_LOGIN", function()
            self:OnPlayerLogin()
        end, SHARED_MEDIA_LOGIN_EVENT_ID)

        self.eventsRegistered = true
    end

    if self:TryBindLSM() then
        self:ScanExternalSounds()
    else
        BLU:PrintDebug("LibSharedMedia not found at init; waiting for later addon loads.")
    end

    -- Make functions available
    BLU.GetExternalSounds = function()
        return self:GetExternalSounds()
    end

    BLU.GetSoundCategories = function()
        return self:GetSoundCategories()
    end

    BLU.PlayExternalSound = function(_, name)
        return self:PlayExternalSound(name)
    end

    BLU:PrintDebug("SharedMedia integration initialized")
end

-- Rebuild external sound inventory from LibSharedMedia.
function SharedMedia:ScanExternalSounds()
    if not self:TryBindLSM() then
        return
    end

    wipe(self.externalSounds)
    wipe(self.soundCategories)
    self:ClearExternalFromRegistry()

    local soundList = self.LSM:List("sound") or {}
    local registeredCount = 0

    for _, soundName in ipairs(soundList) do
        local soundPath = self.LSM:Fetch("sound", soundName)
        if type(soundPath) == "string" and soundPath ~= "" then
            local packName = ExtractAddonNameFromPath(soundPath)

            self.externalSounds[soundName] = {
                name = soundName,
                file = soundPath,
                packId = packName,
                packName = packName,
            }

            self.soundCategories[packName] = self.soundCategories[packName] or {}
            table.insert(self.soundCategories[packName], soundName)

            if BLU.SoundRegistry and BLU.SoundRegistry.RegisterSound then
                BLU.SoundRegistry:RegisterSound("external:" .. soundName, {
                    name = soundName,
                    file = soundPath,
                    category = "all", -- External sounds are available for all categories.
                    source = "SharedMedia",
                    packId = packName,
                    packName = packName,
                })
            end

            registeredCount = registeredCount + 1
        end
    end

    local categoryCount = 0
    for _, categorySounds in pairs(self.soundCategories) do
        table.sort(categorySounds, SortCaseInsensitive)
        categoryCount = categoryCount + 1
    end

    BLU:PrintDebug(string.format("SharedMedia scan complete: %d sounds across %d packs.", registeredCount, categoryCount))
end

-- Get all discovered external sounds keyed by sound name.
function SharedMedia:GetExternalSounds()
    return self.externalSounds
end

-- Get discovered external sounds grouped by source pack.
function SharedMedia:GetSoundCategories()
    return self.soundCategories
end

-- Play an external sound by LibSharedMedia key.
function SharedMedia:PlayExternalSound(name)
    if not self:TryBindLSM() then
        BLU:PrintDebug("LibSharedMedia unavailable; cannot play external sound.")
        return false
    end

    local soundPath = self.LSM:Fetch("sound", name)
    if not soundPath then
        BLU:PrintDebug("External sound not found: " .. tostring(name))
        return false
    end

    local channel = "Master"
    local willPlay = PlaySoundFile(soundPath, channel)

    if willPlay then
        BLU:PrintDebug(string.format("Playing external sound: %s", tostring(name)))
        return true
    end

    BLU:PrintError("Failed to play external sound: " .. tostring(name))
    return false
end

-- Handle addon load and bind/re-scan when LibSharedMedia becomes available.
function SharedMedia:OnAddonLoaded(loadedAddonName)
    if self.LSM then
        return
    end

    if self:TryBindLSM() then
        BLU:PrintDebug("LibSharedMedia became available after addon load: " .. tostring(loadedAddonName))
        self:QueueRescan(0)
    end
end

-- Final login pass to catch late registrations.
function SharedMedia:OnPlayerLogin()
    if self:TryBindLSM() then
        self:QueueRescan(0)
    end
end

-- Handle new media registration callback.
function SharedMedia:OnMediaRegistered(event, mediatype, key)
    if mediatype ~= "sound" then
        return
    end

    BLU:PrintDebug("New shared media sound registered: " .. tostring(key))
    self:QueueRescan(0.1)
end

-- Handle global media changes callback.
function SharedMedia:OnMediaSetGlobal(event, mediatype, key)
    if mediatype ~= "sound" then
        return
    end

    self:QueueRescan(0.1)
end
