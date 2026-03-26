--=====================================================================================
-- BLU - usersounds.lua
-- User Custom Sounds pack
-- Auto-detects custom sound slots from shared AddOns folders.
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

local UserSounds = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["usersounds"] = UserSounds

local PACK_ID   = "user_custom_sounds"
local PACK_NAME = "User Custom Sounds"
local AUTO_SLOT_COUNT = 24
local AUTO_SLOT_EXTENSIONS = {"ogg", "mp3", "wav"}
local AUTO_SLOT_PATHS = {
    "Interface\\AddOns\\custom%02d.%s",
    "Interface\\AddOns\\sounds\\custom%02d.%s",
}

local function BuildDisplayNameFromPath(filePath, fallbackName)
    return string.match(filePath or "", "([^\\]+)%.[^%.]+$") or fallbackName
end

local function CanLoadSoundFile(soundPath)
    if type(soundPath) ~= "string" or soundPath == "" then
        BLU:PrintDebug("[UserSounds] CanLoadSoundFile rejected invalid path")
        return false
    end

    local muted = false
    local unmuteRequired = false

    if MuteSoundFile and UnmuteSoundFile then
        local ok = pcall(MuteSoundFile, soundPath)
        muted = ok
        unmuteRequired = ok
    end

    local ok, willPlay, handle = pcall(PlaySoundFile, soundPath, "Master")

    if handle and StopSound then
        pcall(StopSound, handle)
    end

    if unmuteRequired then
        pcall(UnmuteSoundFile, soundPath)
    end

    local canLoad = ok and willPlay == true
    BLU:PrintDebug("[UserSounds] Probe for '" .. tostring(soundPath) .. "' => " .. tostring(canLoad))
    return canLoad
end

local function CollectAutoDetectedEntries()
    BLU:PrintDebug("[UserSounds] CollectAutoDetectedEntries scanning " .. tostring(AUTO_SLOT_COUNT) .. " slots")
    local entries = {}
    local seenPaths = {}

    for slot = 1, AUTO_SLOT_COUNT do
        for _, pathPattern in ipairs(AUTO_SLOT_PATHS) do
            local foundForPattern = false

            for _, extension in ipairs(AUTO_SLOT_EXTENSIONS) do
                local soundPath = string.format(pathPattern, slot, extension)
                if not seenPaths[soundPath] and CanLoadSoundFile(soundPath) then
                    BLU:PrintDebug("[UserSounds] Auto-detected custom sound at '" .. tostring(soundPath) .. "'")
                    table.insert(entries, {
                        name = BuildDisplayNameFromPath(soundPath, string.format("Custom %02d", slot)),
                        file = soundPath,
                        autoDetected = true,
                    })
                    seenPaths[soundPath] = true
                    foundForPattern = true
                    break
                end
            end

            if foundForPattern then
                break
            end
        end
    end

    BLU:PrintDebug("[UserSounds] Auto-detected " .. tostring(#entries) .. " candidate custom sounds")
    return entries
end

-- Clear all previously registered user custom sounds from the registry
local function ClearRegisteredSounds()
    if not (BLU.SoundRegistry and BLU.SoundRegistry.UnregisterSound and BLU.SoundRegistry.GetAllSounds) then
        BLU:PrintDebug("[UserSounds] ClearRegisteredSounds skipped; SoundRegistry unavailable")
        return
    end
    local prefix = PACK_ID .. ":"
    local toRemove = {}
    for soundId in pairs(BLU.SoundRegistry:GetAllSounds()) do
        if string.sub(soundId, 1, #prefix) == prefix then
            table.insert(toRemove, soundId)
        end
    end
    for _, soundId in ipairs(toRemove) do
        BLU.SoundRegistry:UnregisterSound(soundId)
    end
    BLU:PrintDebug("[UserSounds] Cleared " .. tostring(#toRemove) .. " previously registered custom sounds")
end

-- Read auto-detected custom sound slots and register valid entries
function UserSounds:Register()
    BLU:PrintDebug("[UserSounds] Register called")
    ClearRegisteredSounds()

    local entries = CollectAutoDetectedEntries()
    if #entries == 0 then
        BLU:PrintDebug("[UserSounds] No user custom sounds found.")
        return 0
    end

    if not (BLU.SoundRegistry and BLU.SoundRegistry.RegisterSound) then
        BLU:PrintDebug("[UserSounds] SoundRegistry not ready.")
        return 0
    end

    local count = 0
    for i, entry in ipairs(entries) do
        if type(entry) == "table" and type(entry.file) == "string" and entry.file ~= "" then
            local soundId     = PACK_ID .. ":" .. tostring(i)
            local displayName = entry.name
                or BuildDisplayNameFromPath(entry.file)
                or ("Sound " .. i)

            BLU.SoundRegistry:RegisterSound(soundId, {
                name     = displayName,
                file     = entry.file,
                category = "all",
                source   = "UserCustom",
                packId   = PACK_ID,
                packName = PACK_NAME,
            })
            count = count + 1
            BLU:PrintDebug("[UserSounds] Registered custom sound '" .. tostring(soundId) .. "' from '" .. tostring(entry.file) .. "'")
        end
    end

    BLU:PrintDebug(string.format("[UserSounds] Registered %d user custom sound(s).", count))
    return count
end

function UserSounds:Init()
    BLU:PrintDebug("[UserSounds] Init called")
    self:Register()

    -- Expose public refresh API so /blu refresh also picks up user sounds
    local existingRefresh = BLU.RefreshUserSounds
    BLU.RefreshUserSounds = function()
        BLU:PrintDebug("[UserSounds] RefreshUserSounds invoked")
        local count = UserSounds:Register()
        if BLU.RefreshSoundPackUI then BLU.RefreshSoundPackUI() end
        return count
    end
    BLU:PrintDebug("[UserSounds] Existing refresh hook present: " .. tostring(existingRefresh ~= nil))

    BLU:PrintDebug("[UserSounds] User custom sounds module initialized.")
end

if BLU.RegisterModule then
    BLU:RegisterModule(UserSounds, "usersounds", "User Custom Sounds")
end
