--=====================================================================================
-- BLU - usersounds.lua
-- User Custom Sounds pack
-- Reads from BLU_USER_SOUNDS table defined in user/user_sounds.lua
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

local UserSounds = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["usersounds"] = UserSounds

local PACK_ID   = "user_custom_sounds"
local PACK_NAME = "User Custom Sounds"

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

-- Read BLU_USER_SOUNDS and register all valid entries
function UserSounds:Register()
    ClearRegisteredSounds()

    local entries = _G["BLU_USER_SOUNDS"]
    if type(entries) ~= "table" or #entries == 0 then
        BLU:PrintDebug("[UserSounds] No user custom sounds defined.")
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
                or string.match(entry.file, "([^\\]+)%.[^%.]+$")
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
