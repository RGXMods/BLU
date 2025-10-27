-- modules/sounds.lua
local addonName = ...
local BLU = _G["BLU"]
local Sounds = {}

local muteSoundIDs = {
    880, -- Level Up
    873, -- Quest Complete
    861, -- Achievement
    1335, -- Renown
    119, -- Honor
    870, -- Trading Post
}

-- Assign functions to the table directly
function Sounds:Init()
    BLU:PrintDebug("Sounds module initialized")
    self:MuteSounds()
end

function Sounds:OnEnable()
    BLU:PrintDebug("Sounds module enabled!")
    self:MuteSounds()
end

function Sounds:OnDisable()
    BLU:PrintDebug("Sounds module disabled!")
    self:UnmuteSounds()
end

function Sounds:MuteSounds()
    for _, soundID in ipairs(muteSoundIDs) do
        MuteSoundFile(soundID)
    end
end

function Sounds:UnmuteSounds()
    for _, soundID in ipairs(muteSoundIDs) do
        UnmuteSoundFile(soundID)
    end
end

BLU.Modules["sounds"] = Sounds -- Register the module
