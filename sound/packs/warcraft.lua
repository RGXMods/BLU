--=====================================================================================
-- BLU - sound/packs/warcraft.lua
-- Warcraft 3 sound pack
--=====================================================================================

local addonName, BLU = ...

local sounds = {
    -- Level Up
    warcraft_levelup = {
        name = "Warcraft 3 - Hero Level",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\warcraft_3.ogg",
        duration = 2.0,
        category = "levelup"
    },
    
    -- Achievement
    warcraft_achievement = {
        name = "Warcraft 3 - Quest Complete",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\warcraft_3-2.ogg",
        duration = 1.5,
        category = "achievement"
    },
    
    -- Quest
    warcraft_quest = {
        name = "Warcraft 3 - New Quest",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\warcraft_3-3.ogg",
        duration = 1.5,
        category = "quest"
    },
    
    -- Quest Accept
    warcraft_quest_accept = {
        name = "Warcraft 3 - Work Complete",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\warcraft_3.ogg",
        duration = 2.0,
        category = "quest_accept"
    },
    
    -- Reputation
    warcraft_reputation = {
        name = "Warcraft 3 - Alliance Gained",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\warcraft_3-2.ogg",
        duration = 1.5,
        category = "reputation"
    },
    
    -- Honor
    warcraft_honor = {
        name = "Warcraft 3 - Victory",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\warcraft_3-3.ogg",
        duration = 1.5,
        category = "honor"
    }
}

-- Register the sound pack
if BLU.RegisterSoundPack then
    BLU:RegisterSoundPack("warcraft", "Warcraft 3", sounds)
end