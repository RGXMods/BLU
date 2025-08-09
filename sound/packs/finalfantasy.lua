--=====================================================================================
-- BLU - sound/packs/finalfantasy.lua
-- Final Fantasy sound pack
--=====================================================================================

local addonName, BLU = ...

-- Register Final Fantasy sounds
local sounds = {
    finalfantasy_levelup = {
        name = "Final Fantasy - Victory Fanfare",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\final_fantasy.ogg",
        duration = 3.5,
        category = "levelup"
    },
    finalfantasy_achievement = {
        name = "Final Fantasy - Achievement",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\final_fantasy.ogg",
        duration = 2.5,
        category = "achievement"
    },
    finalfantasy_quest = {
        name = "Final Fantasy - Quest Complete",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\final_fantasy.ogg",
        duration = 2.0,
        category = "quest"
    }
}

-- Register with sound registry
if BLU.RegisterSoundPack then
    BLU:RegisterSoundPack("finalfantasy", "Final Fantasy", sounds)
end