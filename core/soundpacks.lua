--=====================================================================================
-- BLU - Sound Pack Loader
-- Handles loading and registration of all sound packs
--=====================================================================================

local addonName, BLU = ...

-- Create sound pack module
local SoundPacks = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["soundpacks"] = SoundPacks

-- Store pending sound packs (registered before initialization)
SoundPacks.pendingPacks = {}

-- Initialize sound packs
function SoundPacks:Init()
    BLU:PrintDebug("Initializing sound packs module")
    
    -- Register any pending packs
    self:RegisterPendingPacks()
    
    -- Load all defined sound packs
    self:LoadAllSoundPacks()
    
    BLU:PrintDebug("Sound packs module initialized")
end

-- Register pending packs that were added before initialization
function SoundPacks:RegisterPendingPacks()
    if #self.pendingPacks > 0 then
        BLU:PrintDebug(string.format("Registering %d pending sound packs", #self.pendingPacks))
        for _, pack in ipairs(self.pendingPacks) do
            if BLU.RegisterSoundPack then
                BLU:RegisterSoundPack(pack.id, pack.name, pack.sounds)
            end
        end
        wipe(self.pendingPacks)
    end
end

-- Load all sound packs
function SoundPacks:LoadAllSoundPacks()
    -- Define all BLU sound packs
    local soundPacks = {
        {
            id = "finalfantasy",
            name = "Final Fantasy",
            sounds = {
                finalfantasy_levelup = {
                    name = "Final Fantasy - Victory Fanfare",
                    file = "Interface\\AddOns\\BLU\\media\\sounds\\final_fantasy.ogg",
                    duration = 3.5,
                    category = "levelup",
                    source = "BLU",
                    isInternal = true
                },
                finalfantasy_achievement = {
                    name = "Final Fantasy - Achievement",
                    file = "Interface\\AddOns\\BLU\\media\\sounds\\final_fantasy.ogg",
                    duration = 2.5,
                    category = "achievement",
                    source = "BLU",
                    isInternal = true
                },
                finalfantasy_quest_complete = {
                    name = "Final Fantasy - Quest Complete",
                    file = "Interface\\AddOns\\BLU\\media\\sounds\\final_fantasy.ogg",
                    duration = 2.0,
                    category = "quest_complete",
                    source = "BLU",
                    isInternal = true
                },
                finalfantasy_quest_progress = {
                    name = "Final Fantasy - Quest Progress",
                    file = "Interface\\AddOns\\BLU\\media\\sounds\\final_fantasy.ogg",
                    duration = 1.5,
                    category = "quest_progress",
                    source = "BLU",
                    isInternal = true
                },
                finalfantasy_reputation = {
                    name = "Final Fantasy - Reputation",
                    file = "Interface\\AddOns\\BLU\\media\\sounds\\final_fantasy.ogg",
                    duration = 2.0,
                    category = "reputation",
                    source = "BLU",
                    isInternal = true
                }
            }
        },
        {
            id = "zelda",
            name = "Legend of Zelda",
            sounds = {
                zelda_levelup = {
                    name = "Zelda - Level Up",
                    file = "Interface\\AddOns\\BLU\\media\\sounds\\zelda_levelup.ogg",
                    duration = 3.0,
                    category = "levelup",
                    source = "BLU",
                    isInternal = true
                },
                zelda_achievement = {
                    name = "Zelda - Achievement",
                    file = "Interface\\AddOns\\BLU\\media\\sounds\\zelda_achievement.ogg",
                    duration = 2.5,
                    category = "achievement",
                    source = "BLU",
                    isInternal = true
                },
                zelda_quest_complete = {
                    name = "Zelda - Quest Complete",
                    file = "Interface\\AddOns\\BLU\\media\\sounds\\zelda_quest.ogg",
                    duration = 2.0,
                    category = "quest_complete",
                    source = "BLU",
                    isInternal = true
                },
                zelda_quest_progress = {
                    name = "Zelda - Quest Progress",
                    file = "Interface\\AddOns\\BLU\\media\\sounds\\zelda_quest.ogg",
                    duration = 1.5,
                    category = "quest_progress",
                    source = "BLU",
                    isInternal = true
                }
            }
        },
        {
            id = "pokemon",
            name = "Pokemon",
            sounds = {
                pokemon_levelup = {
                    name = "Pokemon - Level Up",
                    file = "Interface\\AddOns\\BLU\\media\\sounds\\pokemon_levelup.ogg",
                    duration = 3.0,
                    category = "levelup",
                    source = "BLU",
                    isInternal = true
                },
                pokemon_achievement = {
                    name = "Pokemon - Achievement",
                    file = "Interface\\AddOns\\BLU\\media\\sounds\\pokemon_achievement.ogg",
                    duration = 2.5,
                    category = "achievement",
                    source = "BLU",
                    isInternal = true
                }
            }
        },
        {
            id = "mario",
            name = "Super Mario",
            sounds = {
                mario_levelup = {
                    name = "Mario - Level Up",
                    file = "Interface\\AddOns\\BLU\\media\\sounds\\mario_levelup.ogg",
                    duration = 2.5,
                    category = "levelup",
                    source = "BLU",
                    isInternal = true
                },
                mario_achievement = {
                    name = "Mario - Star Power",
                    file = "Interface\\AddOns\\BLU\\media\\sounds\\mario_achievement.ogg",
                    duration = 2.0,
                    category = "achievement",
                    source = "BLU",
                    isInternal = true
                }
            }
        },
        {
            id = "sonic",
            name = "Sonic the Hedgehog",
            sounds = {
                sonic_levelup = {
                    name = "Sonic - Level Up",
                    file = "Interface\\AddOns\\BLU\\media\\sounds\\sonic_levelup.ogg",
                    duration = 2.5,
                    category = "levelup",
                    source = "BLU",
                    isInternal = true
                }
            }
        }
    }
    
    -- Register all sound packs
    for _, pack in ipairs(soundPacks) do
        if BLU.RegisterSoundPack then
            BLU:RegisterSoundPack(pack.id, pack.name, pack.sounds)
            BLU:PrintDebug(string.format("Registered sound pack: %s (%d sounds)", pack.name, self:CountTableEntries(pack.sounds)))
        end
    end
end

-- Helper to count table entries
function SoundPacks:CountTableEntries(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

-- Global function to queue sound pack registration
function BLU:QueueSoundPack(packId, packName, sounds)
    if not SoundPacks.pendingPacks then
        SoundPacks.pendingPacks = {}
    end
    table.insert(SoundPacks.pendingPacks, {
        id = packId,
        name = packName,
        sounds = sounds
    })
end