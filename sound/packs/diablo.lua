--=====================================================================================
-- BLU - sound/packs/diablo.lua
-- Diablo 2 sound pack
--=====================================================================================

local addonName, BLU = ...

local sounds = {
    -- Level Up
    diablo_levelup = {
        name = "Diablo 2 - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\diablo_2.ogg",
        duration = 2.0,
        category = "levelup"
    },
    
    -- Achievement
    diablo_achievement = {
        name = "Diablo 2 - Skill Point",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\diablo_2.ogg",
        duration = 2.0,
        category = "achievement"
    },
    
    -- Quest
    diablo_quest = {
        name = "Diablo 2 - Quest Complete",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\diablo_2.ogg",
        duration = 2.0,
        category = "quest"
    },
    
    -- Reputation
    diablo_reputation = {
        name = "Diablo 2 - Horadric Cube",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\diablo_2.ogg",
        duration = 2.0,
        category = "reputation"
    },
    
    -- Honor
    diablo_honor = {
        name = "Diablo 2 - PvP Kill",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\diablo_2.ogg",
        duration = 2.0,
        category = "honor"
    }
}

-- Register the sound pack
if BLU.RegisterSoundPack then
    BLU:RegisterSoundPack("diablo", "Diablo 2", sounds)
end