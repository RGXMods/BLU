--=====================================================================================
-- BLU - sound/packs/witcher.lua
-- The Witcher 3 sound pack
--=====================================================================================

local addonName, BLU = ...

local sounds = {
    -- Level Up
    witcher_levelup = {
        name = "Witcher 3 - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\witcher_3-1.ogg",
        duration = 3.0,
        category = "levelup"
    },
    
    -- Achievement
    witcher_achievement = {
        name = "Witcher 3 - Ability Point",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\witcher_3-2.ogg",
        duration = 2.5,
        category = "achievement"
    },
    
    -- Quest Complete
    witcher_quest = {
        name = "Witcher 3 - Quest Complete",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\witcher_3-1.ogg",
        duration = 3.0,
        category = "quest"
    },
    
    -- Quest Accept
    witcher_quest_accept = {
        name = "Witcher 3 - Contract Accepted",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\witcher_3-2.ogg",
        duration = 2.5,
        category = "quest_accept"
    },
    
    -- Reputation
    witcher_reputation = {
        name = "Witcher 3 - Reputation Gained",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\witcher_3-1.ogg",
        duration = 3.0,
        category = "reputation"
    },
    
    -- Honor
    witcher_honor = {
        name = "Witcher 3 - Gwent Victory",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\witcher_3-2.ogg",
        duration = 2.5,
        category = "honor"
    }
}

-- Register the sound pack
if BLU.RegisterSoundPack then
    BLU:RegisterSoundPack("witcher", "The Witcher 3", sounds)
end