--=====================================================================================
-- BLU - sound/internal_sounds.lua
-- Registers all internal BLU sounds with the registry
--=====================================================================================

local addonName, BLU = ...

-- Internal sounds module
local InternalSounds = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["internal_sounds"] = InternalSounds

-- Sound definitions organized by game
local soundPacks = {
    -- Final Fantasy sounds
    finalfantasy = {
        name = "Final Fantasy",
        sounds = {
            levelup = { file = "final_fantasy", name = "Final Fantasy Victory Fanfare" },
            achievement = { file = "final_fantasy", name = "Final Fantasy Achievement" },
            quest = { file = "final_fantasy", name = "Final Fantasy Quest Complete" }
        }
    },
    
    -- Legend of Zelda sounds
    zelda = {
        name = "Legend of Zelda",
        sounds = {
            levelup = { file = "legend_of_zelda", name = "Zelda Item Get" },
            achievement = { file = "legend_of_zelda", name = "Zelda Secret Found" },
            quest = { file = "legend_of_zelda", name = "Zelda Puzzle Solved" }
        }
    },
    
    -- Pokemon sounds
    pokemon = {
        name = "Pokemon",
        sounds = {
            levelup = { file = "pokemon", name = "Pokemon Level Up" },
            achievement = { file = "pokemon", name = "Pokemon Badge Get" },
            quest = { file = "pokemon", name = "Pokemon Item Get" },
            battlepet = { file = "pokemon", name = "Pokemon Victory" }
        }
    },
    
    -- Super Mario sounds
    mario = {
        name = "Super Mario",
        sounds = {
            levelup = { file = "super_mario_bros_3", name = "Mario Power Up" },
            achievement = { file = "super_mario_bros_3", name = "Mario Stage Clear" },
            quest = { file = "super_mario_bros_3", name = "Mario Coin" }
        }
    },
    
    -- Sonic sounds
    sonic = {
        name = "Sonic the Hedgehog",
        sounds = {
            levelup = { file = "sonic_the_hedgehog", name = "Sonic Act Clear" },
            achievement = { file = "sonic_the_hedgehog", name = "Sonic Extra Life" },
            quest = { file = "sonic_the_hedgehog", name = "Sonic Ring" }
        }
    },
    
    -- Metal Gear Solid sounds
    metalgear = {
        name = "Metal Gear Solid",
        sounds = {
            levelup = { file = "metalgear_solid", name = "MGS Alert (!)" },
            achievement = { file = "metalgear_solid", name = "MGS Codec" },
            quest = { file = "metalgear_solid", name = "MGS Item" }
        }
    },
    
    -- Elder Scrolls sounds
    elderscrolls = {
        name = "Elder Scrolls",
        sounds = {
            levelup = { file = "skyrim", name = "Skyrim Level Up" },
            achievement = { file = "morrowind", name = "Morrowind Level Up" },
            quest = { file = "skyrim", name = "Skyrim Quest Complete" }
        }
    },
    
    -- Warcraft sounds
    warcraft = {
        name = "Warcraft",
        sounds = {
            levelup = { file = "warcraft_3", name = "Warcraft 3 Job Done" },
            achievement = { file = "warcraft_3-2", name = "Warcraft 3 Quest Complete" },
            quest = { file = "warcraft_3-3", name = "Warcraft 3 New Quest" }
        }
    },
    
    -- Elden Ring sounds (multiple variations)
    eldenring = {
        name = "Elden Ring",
        sounds = {
            levelup = { file = "elden_ring-1", name = "Elden Ring Enemy Felled" },
            achievement = { file = "elden_ring-2", name = "Elden Ring Great Enemy Felled" },
            quest = { file = "elden_ring-3", name = "Elden Ring Victory" }
        }
    },
    
    -- Other games
    castlevania = {
        name = "Castlevania",
        sounds = {
            levelup = { file = "castlevania", name = "Castlevania Stage Clear" }
        }
    },
    
    diablo = {
        name = "Diablo",
        sounds = {
            levelup = { file = "diablo_2", name = "Diablo 2 Level Up" },
            quest = { file = "diablo_2", name = "Diablo 2 Quest Complete" }
        }
    },
    
    fallout = {
        name = "Fallout",
        sounds = {
            levelup = { file = "fallout_3", name = "Fallout 3 Level Up" },
            achievement = { file = "fallout_new_vegas", name = "Fallout New Vegas Challenge" }
        }
    }
}

-- Initialize internal sounds
function InternalSounds:Init()
    -- Wait for registry to be available
    C_Timer.After(0.1, function()
        self:RegisterAllSounds()
    end)
end

-- Register all internal sounds
function InternalSounds:RegisterAllSounds()
    if not BLU.RegisterSound then
        BLU:PrintError("Sound registry not available")
        return
    end
    
    local registeredCount = 0
    
    -- Register each sound pack
    for packId, pack in pairs(soundPacks) do
        for eventType, soundData in pairs(pack.sounds) do
            -- Create sound ID
            local soundId = packId .. "_" .. eventType
            
            -- Build file path (without volume suffix)
            local basePath = "Interface\\AddOns\\BLU\\media\\sounds\\"
            
            -- Register the sound with all volume variants
            local soundInfo = {
                name = soundData.name,
                file = basePath .. soundData.file .. "_high.ogg",  -- Default to high
                category = eventType,
                pack = packId,
                packName = pack.name,
                isInternal = true,  -- Mark as internal for volume handling
                -- Store base file path for volume variant selection
                baseFile = basePath .. soundData.file
            }
            
            if BLU:RegisterSound(soundId, soundInfo) then
                registeredCount = registeredCount + 1
            end
        end
    end
    
    -- Also register default sounds
    local defaults = {
        levelup = { file = "level_default", name = "BLU Default Level Up" },
        achievement = { file = "achievement_default", name = "BLU Default Achievement" },
        quest = { file = "quest_default", name = "BLU Default Quest Complete" },
        questaccept = { file = "quest_accept_default", name = "BLU Default Quest Accept" },
        reputation = { file = "rep_default", name = "BLU Default Reputation" },
        honorrank = { file = "honor_default", name = "BLU Default Honor" },
        renownrank = { file = "renown_default", name = "BLU Default Renown" },
        tradingpost = { file = "post_default", name = "BLU Default Trading Post" },
        battlepet = { file = "battle_pet_level_default", name = "BLU Default Battle Pet" }
    }
    
    for eventType, soundData in pairs(defaults) do
        local soundId = "blu_default_" .. eventType
        local basePath = "Interface\\AddOns\\BLU\\media\\sounds\\"
        
        local soundInfo = {
            name = soundData.name,
            file = basePath .. soundData.file .. "_high.ogg",
            category = eventType,
            pack = "blu_default",
            packName = "BLU Defaults",
            isInternal = true,
            baseFile = basePath .. soundData.file
        }
        
        if BLU:RegisterSound(soundId, soundInfo) then
            registeredCount = registeredCount + 1
        end
    end
    
    BLU:PrintDebug(string.format("Registered %d internal sounds", registeredCount))
end

-- Get available sound packs
function InternalSounds:GetSoundPacks()
    local packs = {}
    
    -- Add default pack
    table.insert(packs, {
        id = "default",
        name = "Default WoW Sounds",
        icon = "Interface\\Icons\\INV_Misc_QuestionMark"
    })
    
    table.insert(packs, {
        id = "blu_default", 
        name = "BLU Defaults",
        icon = "Interface\\Icons\\INV_Misc_Bell_01"
    })
    
    -- Add all game packs
    for packId, pack in pairs(soundPacks) do
        table.insert(packs, {
            id = packId,
            name = pack.name,
            icon = pack.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
        })
    end
    
    -- Sort by name
    table.sort(packs, function(a, b) return a.name < b.name end)
    
    return packs
end

-- Get sounds for a specific pack
function InternalSounds:GetPackSounds(packId)
    if packId == "default" then
        -- Return WoW default sound options
        return {
            levelup = { name = "WoW Level Up", isDefault = true },
            achievement = { name = "WoW Achievement", isDefault = true },
            quest = { name = "WoW Quest Complete", isDefault = true },
            reputation = { name = "WoW Reputation", isDefault = true }
        }
    elseif packId == "blu_default" then
        return defaults
    else
        return soundPacks[packId] and soundPacks[packId].sounds or {}
    end
end