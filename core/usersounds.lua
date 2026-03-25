--=====================================================================================
-- BLU - usersounds.lua
-- User Custom Sounds pack
-- Supports both explicit manifest entries and auto-detected custom sound slots.
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
    "Interface\\AddOns\\BLU\\custom%02d.%s",
    "Interface\\AddOns\\BLU\\sounds\\custom%02d.%s",
    "Interface\\AddOns\\BLU\\user\\sounds\\custom%02d.%s",
}

local function BuildDisplayNameFromPath(filePath, fallbackName)
    return string.match(filePath or "", "([^\\]+)%.[^%.]+$") or fallbackName
end

local function CanLoadSoundFile(soundPath)
    if type(soundPath) ~= "string" or soundPath == "" then
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

    return ok and willPlay == true
end

local function CollectAutoDetectedEntries()
    local entries = {}
    local seenPaths = {}

    for slot = 1, AUTO_SLOT_COUNT do
        for _, pathPattern in ipairs(AUTO_SLOT_PATHS) do
            local foundForPattern = false

            for _, extension in ipairs(AUTO_SLOT_EXTENSIONS) do
                local soundPath = string.format(pathPattern, slot, extension)
                if not seenPaths[soundPath] and CanLoadSoundFile(soundPath) then
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

    return entries
end

local function CollectAllEntries()
    local combined = {}
    local seenPaths = {}

    local manifestEntries = _G["BLU_USER_SOUNDS"]
    if type(manifestEntries) == "table" then
        for _, entry in ipairs(manifestEntries) do
            if type(entry) == "table" and type(entry.file) == "string" and entry.file ~= "" and not seenPaths[entry.file] then
                combined[#combined + 1] = {
                    name = entry.name,
                    file = entry.file,
                }
                seenPaths[entry.file] = true
            end
        end
    end

    local autoEntries = CollectAutoDetectedEntries()
    for _, entry in ipairs(autoEntries) do
        if not seenPaths[entry.file] then
            combined[#combined + 1] = entry
            seenPaths[entry.file] = true
        end
    end

    return combined
end

-- Clear all previously registered user custom sounds from the registry
local function ClearRegisteredSounds()
    if not (BLU.SoundRegistry and BLU.SoundRegistry.UnregisterSound and BLU.SoundRegistry.GetAllSounds) then
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
end

-- Read BLU_USER_SOUNDS and auto-detected custom sound slots, then register valid entries
function UserSounds:Register()
    ClearRegisteredSounds()

    local entries = CollectAllEntries()
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
        end
    end

    BLU:PrintDebug(string.format("[UserSounds] Registered %d user custom sound(s).", count))
    return count
end

function UserSounds:Init()
    self:Register()

    -- Expose public refresh API so /blu refresh also picks up user sounds
    local existingRefresh = BLU.RefreshUserSounds
    BLU.RefreshUserSounds = function()
        local count = UserSounds:Register()
        if BLU.RefreshSoundPackUI then BLU.RefreshSoundPackUI() end
        return count
    end

    BLU:PrintDebug("[UserSounds] User custom sounds module initialized.")
end

if BLU.RegisterModule then
    BLU:RegisterModule(UserSounds, "usersounds", "User Custom Sounds")
end
