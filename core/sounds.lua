--=====================================================================================
-- BLU | Sound Management
-- Author: donniedice
-- Description: Mutes and unmutes default WoW sounds
--=====================================================================================

local addonName, _ = ...
local BLU = _G["BLU"]

local Sounds = {}
BLU.Modules["sounds"] = Sounds

local wowDefaultSounds = {
    888,  -- LEVELUPSOUND
    12891,  -- Achievement sound
    618,  -- QuestComplete
    12197,  -- Reputation change
    12173,  -- PVP Reward sound
    167404,  -- Renown rank up
    179114,  -- Trading post sound
    65978,  -- Pet battle victory
    182235  -- Delve companion sound
}

function Sounds:MuteDefaultSounds()
    if not BLU.db or not BLU.db.profile or not BLU.db.profile.enabled then return end
    BLU:PrintDebug("Muting default WoW sounds.")
    for _, soundId in ipairs(wowDefaultSounds) do
        MuteSoundFile(soundId)
    end
end

function Sounds:UnmuteDefaultSounds()
    BLU:PrintDebug("Unmuting default WoW sounds.")
    for _, soundId in ipairs(wowDefaultSounds) do
        UnmuteSoundFile(soundId)
    end
end

function Sounds:Init()
    self:MuteDefaultSounds()
end

function Sounds:OnDisable()
    self:UnmuteDefaultSounds()
end

BLU:RegisterEvent("PLAYER_LOGOUT", function()
    Sounds:UnmuteDefaultSounds()
end)
