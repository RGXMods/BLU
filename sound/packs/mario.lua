--=====================================================================================
-- BLU - sound/packs/mario.lua
-- Super Mario sound pack
--=====================================================================================

local addonName, BLU = ...

local sounds = {
    -- Level Up
    mario_levelup = {
        name = "Mario - Power Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\super_mario_bros_3.ogg",
        duration = 1.5,
        category = "levelup"
    },
    
    -- Achievement
    mario_achievement = {
        name = "Mario - Star Power",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\super_mario_bros_3.ogg",
        duration = 1.5,
        category = "achievement"
    },
    
    -- Quest
    mario_quest = {
        name = "Mario - Course Clear",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\super_mario_bros_3.ogg",
        duration = 1.5,
        category = "quest"
    },
    
    -- Reputation
    mario_reputation = {
        name = "Mario - 1-Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\super_mario_bros_3.ogg",
        duration = 1.5,
        category = "reputation"
    },
    
    -- Honor
    mario_honor = {
        name = "Mario - Coin",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\super_mario_bros_3.ogg",
        duration = 1.5,
        category = "honor"
    }
}

-- Register the sound pack
if BLU.RegisterSoundPack then
    BLU:RegisterSoundPack("mario", "Super Mario", sounds)
end