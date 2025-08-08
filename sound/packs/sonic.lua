--=====================================================================================
-- BLU - sound/packs/sonic.lua
-- Sonic the Hedgehog sound pack
--=====================================================================================

local addonName, BLU = ...

local sounds = {
    -- Level Up
    sonic_levelup = {
        name = "Sonic - Act Clear",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\sonic_the_hedgehog.ogg",
        duration = 3.5,
        category = "levelup"
    },
    
    -- Achievement
    sonic_achievement = {
        name = "Sonic - Chaos Emerald",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\sonic_the_hedgehog.ogg",
        duration = 3.5,
        category = "achievement"
    },
    
    -- Quest
    sonic_quest = {
        name = "Sonic - Bonus Stage",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\sonic_the_hedgehog.ogg",
        duration = 3.5,
        category = "quest"
    },
    
    -- Reputation
    sonic_reputation = {
        name = "Sonic - Ring Collect",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\sonic_the_hedgehog.ogg",
        duration = 3.5,
        category = "reputation"
    },
    
    -- Honor
    sonic_honor = {
        name = "Sonic - Speed Boost",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\sonic_the_hedgehog.ogg",
        duration = 3.5,
        category = "honor"
    }
}

-- Register the sound pack
if BLU.RegisterSoundPack then
    BLU:RegisterSoundPack("sonic", "Sonic the Hedgehog", sounds)
end