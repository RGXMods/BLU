--=====================================================================================
-- BLU - sound/packs/elderscrolls.lua
-- Elder Scrolls sound pack (Skyrim, Morrowind)
--=====================================================================================

local addonName, BLU = ...

local sounds = {
    -- Level Up - Skyrim
    skyrim_levelup = {
        name = "Skyrim - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\skyrim.ogg",
        duration = 3.0,
        category = "levelup"
    },
    
    -- Achievement - Skyrim
    skyrim_achievement = {
        name = "Skyrim - Dragon Soul",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\skyrim.ogg",
        duration = 3.0,
        category = "achievement"
    },
    
    -- Quest - Skyrim
    skyrim_quest = {
        name = "Skyrim - Quest Complete",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\skyrim.ogg",
        duration = 3.0,
        category = "quest"
    },
    
    -- Level Up - Morrowind
    morrowind_levelup = {
        name = "Morrowind - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\morrowind.ogg",
        duration = 3.0,
        category = "levelup"
    },
    
    -- Achievement - Morrowind
    morrowind_achievement = {
        name = "Morrowind - Skill Increase",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\morrowind.ogg",
        duration = 3.0,
        category = "achievement"
    },
    
    -- Quest - Morrowind
    morrowind_quest = {
        name = "Morrowind - Journal Update",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\morrowind.ogg",
        duration = 3.0,
        category = "quest"
    },
    
    -- Reputation
    elderscrolls_reputation = {
        name = "Elder Scrolls - Fame Increased",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\skyrim.ogg",
        duration = 3.0,
        category = "reputation"
    }
}

-- Register the sound pack
if BLU.RegisterSoundPack then
    BLU:RegisterSoundPack("elderscrolls", "Elder Scrolls", sounds)
end