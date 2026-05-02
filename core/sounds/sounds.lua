--=====================================================================================
-- BLU | Sound Management
-- Author: donniedice
-- Description: Mutes and unmutes default WoW sounds
--=====================================================================================

local addonName, _ = ...
local BLU = _G["BLU"]

local Sounds = {}
BLU.Modules["sound_muter"] = Sounds
local SOUNDS_EVENT_ID_LOGOUT = "sound_muter_logout"

local wowDefaultSounds = {
    -- Level Up
    888,     -- LEVELUPSOUND (legacy)
    569593,  -- Level Up

    -- Achievement
    12891,   -- Achievement (legacy)
    569143,  -- Achievement

    -- Quest
    618,     -- QuestComplete (legacy)
    567400,  -- Quest Accepted
    567439,  -- Quest Turned In

    -- Reputation
    12197,   -- Reputation change (legacy)
    568016,  -- Reputation

    -- Honor / PVP
    12173,   -- PVP Reward sound (legacy)
    1489546, -- Honor

    -- Renown
    167404,  -- Renown rank up (legacy)
    4745441, -- Renown

    -- Trading Post
    179114,  -- Trading post (legacy)
    2066672, -- Trading Post

    -- Battle Pet
    65978,   -- Pet battle victory (legacy)
    642841,  -- Battle Pet Level

    -- Delve
    182235,  -- Delve companion sound
}

function Sounds:MuteDefaultSounds()
    if not BLU.db or not BLU.db.enabled then return end
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
end, SOUNDS_EVENT_ID_LOGOUT)
