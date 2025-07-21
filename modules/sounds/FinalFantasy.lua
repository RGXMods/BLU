--=====================================================================================
-- BLU Final Fantasy Sound Module
-- Contains all Final Fantasy game sounds
--=====================================================================================

local addonName, addonTable = ...
local FinalFantasy = {}

-- Sound definitions
FinalFantasy.sounds = {
    -- Victory Fanfare
    finalfantasy_victory = {
        name = "Final Fantasy - Victory Fanfare",
        file = "Interface\\AddOns\\BLU\\sounds\\FinalFantasy\\victory.ogg",
        duration = 3.5,
        category = "levelup"
    },
    
    -- Level Up
    finalfantasy_levelup = {
        name = "Final Fantasy - Level Up",
        file = "Interface\\AddOns\\BLU\\sounds\\FinalFantasy\\levelup.ogg",
        duration = 2.0,
        category = "levelup"
    },
    
    -- Item Get
    finalfantasy_itemget = {
        name = "Final Fantasy - Item Get",
        file = "Interface\\AddOns\\BLU\\sounds\\FinalFantasy\\itemget.ogg",
        duration = 1.5,
        category = "quest"
    },
    
    -- Save Complete
    finalfantasy_save = {
        name = "Final Fantasy - Save Complete",
        file = "Interface\\AddOns\\BLU\\sounds\\FinalFantasy\\save.ogg",
        duration = 1.0,
        category = "achievement"
    },
    
    -- Crystal Theme
    finalfantasy_crystal = {
        name = "Final Fantasy - Crystal Theme",
        file = "Interface\\AddOns\\BLU\\sounds\\FinalFantasy\\crystal.ogg",
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

-- Export module
return FinalFantasy