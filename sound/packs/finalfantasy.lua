--=====================================================================================
-- BLU Final Fantasy Sound Module
-- Contains all Final Fantasy game sounds
--=====================================================================================

local addonName, BLU = ...
local FinalFantasy = {}

-- Sound definitions
FinalFantasy.sounds = {
    -- Victory Fanfare
    finalfantasy_levelup = {
        name = "Final Fantasy - Victory Fanfare",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\finalfantasy\\victory.ogg",
        duration = 3.5,
        category = "levelup"
    },
    
    -- Item Get
    finalfantasy_quest = {
        name = "Final Fantasy - Item Get",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\finalfantasy\\itemget.ogg",
        duration = 1.5,
        category = "quest"
    },
    
    -- Save Complete
    finalfantasy_achievement = {
        name = "Final Fantasy - Save Complete",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\finalfantasy\\save.ogg",
        duration = 1.0,
        category = "achievement"
    },
    
    -- Crystal Theme
    finalfantasy_reputation = {
        name = "Final Fantasy - Crystal Theme",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\finalfantasy\\crystal.ogg",
        duration = 4.0,
        category = "reputation"
    }
}

-- Initialize sound module
function FinalFantasy:Init()
    -- Register sounds with the main addon
    for soundId, soundData in pairs(self.sounds) do
        BLU:RegisterSound(soundId, soundData)
    end
    
    BLU:PrintDebug("Final Fantasy sound module loaded")
end

-- Cleanup (if needed)
function FinalFantasy:Cleanup()
    -- Unregister sounds
    for soundId in pairs(self.sounds) do
        BLU:UnregisterSound(soundId)
    end
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["FinalFantasy"] = FinalFantasy

-- Export module
return FinalFantasy