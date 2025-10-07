--=====================================================================================
-- BLU - sound/packs/pokemon.lua  
-- Pokemon sound pack
--=====================================================================================

local addonName, BLU = ...

local sounds = {
    -- Level Up
    pokemon_levelup = {
        name = "Pokemon - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\pokemon.ogg",
        duration = 2.5,
        category = "levelup"
    },
    
    -- Achievement
    pokemon_achievement = {
        name = "Pokemon - Badge Earned",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\pokemon.ogg",
        duration = 2.5,
        category = "achievement"
    },
    
    -- Quest
    pokemon_quest = {
        name = "Pokemon - Item Obtained",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\pokemon.ogg",
        duration = 2.5,
        category = "quest"
    },
    
    -- Battle Pet
    pokemon_battlepet = {
        name = "Pokemon - Evolution",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\pokemon.ogg",
        duration = 2.5,
        category = "battlepet"
    },
    
    -- Reputation
    pokemon_reputation = {
        name = "Pokemon - Friendship Increased",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\pokemon.ogg",
        duration = 2.5,
        category = "reputation"
    }
}

-- Register the sound pack
if BLU.RegisterSoundPack then
    BLU:RegisterSoundPack("pokemon", "Pokemon", sounds)
end