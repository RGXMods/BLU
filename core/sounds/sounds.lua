--=====================================================================================
-- BLU | Sound Muter
-- Mutes/unmutes default WoW sounds via RGX-Framework Sound module.
--=====================================================================================

local addonName, _ = ...
local BLU = _G["BLU"]

local Sounds = {}
BLU.Modules["sound_muter"] = Sounds

-- Default WoW sound IDs replaced by BLU.  RGX-Framework provides the MuteList /
-- UnmuteList helpers; we just supply our list at Init and clean up on logout.
local wowDefaultSounds = {
    888,     569593,    -- Level Up (legacy + current)
    12891,   569143,    -- Achievement
    618,     567400, 567439,  -- Quest (complete / accepted / turned in)
    12197,   568016,    -- Reputation
    12173,   1489546,   -- Honor / PvP
    167404,  4745441,   -- Renown
    179114,  2066672,   -- Trading Post
    65978,   642841,    -- Battle Pet
    182235,             -- Delve companion
}

function Sounds:MuteDefaultSounds()
    if not BLU.db or not BLU.db.enabled then return end
    local RGX = _G.RGXFramework
    if RGX then
        local Sound = RGX:GetSound()
        if Sound then
            Sound:MuteList(wowDefaultSounds)
        end
    end
end

function Sounds:UnmuteDefaultSounds()
    local RGX = _G.RGXFramework
    if RGX then
        local Sound = RGX:GetSound()
        if Sound then
            Sound:UnmuteList(wowDefaultSounds)
        end
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
end, "sound_muter_logout")
