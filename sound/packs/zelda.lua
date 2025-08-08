--=====================================================================================
-- BLU - sound/packs/zelda.lua
-- Legend of Zelda sound pack
--=====================================================================================

local addonName, BLU = ...

local sounds = {
    -- Level Up
    zelda_levelup = {
        name = "Zelda - Item Get",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\legend_of_zelda.ogg",
        duration = 3.0,
        category = "levelup"
    },
    
    -- Achievement
    zelda_achievement = {
        name = "Zelda - Secret Found",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\legend_of_zelda.ogg",
        duration = 3.0,
        category = "achievement"
    },
    
    -- Quest
    zelda_quest = {
        name = "Zelda - Puzzle Solved",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\legend_of_zelda.ogg",
        duration = 3.0,
        category = "quest"
    },
    
    -- Reputation
    zelda_reputation = {
        name = "Zelda - Heart Container",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\legend_of_zelda.ogg",
        duration = 3.0,
        category = "reputation"
    }
}

-- Register the sound pack
if BLU.RegisterSoundPack then
    BLU:RegisterSoundPack("zelda", "Legend of Zelda", sounds)
end