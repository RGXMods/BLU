--=====================================================================================
-- BLU | Internal Sounds Module
-- Author: donniedice
-- Description: Manages BLU's built-in sound collection
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

-- Create the module
local InternalSounds = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["internal_sounds"] = InternalSounds

function InternalSounds:Init()
    BLU:PrintDebug("Internal sounds module initializing...")
    
    -- Register all built-in sound packs
    self:RegisterSoundPacks()
    
    BLU:PrintDebug("Internal sounds module initialized")
end

function InternalSounds:RegisterSoundPacks()
    BLU:PrintDebug("Internal sounds module: Registering BLU's built-in sound packs...")

    local function countTableEntries(tbl)
        if type(tbl) ~= "table" then return 0 end
        local count = 0
        for _ in pairs(tbl) do
            count = count + 1
        end
        return count
    end

    local bluSoundPacks = {
        {
            id = "blu_default",
            name = "BLU Defaults",
            sounds = {
                achievement_default = { name = "Default Achievement", file = "Interface\AddOns\BLU\sounds\achievement_default.ogg", duration = 2.0, category = "achievement", source = "BLU", isInternal = true },
                battle_pet_level_default = { name = "Default Battle Pet Level", file = "Interface\AddOns\BLU\sounds\battle_pet_level_default.ogg", duration = 2.0, category = "battlepet", source = "BLU", isInternal = true },
                honor_default = { name = "Default Honor", file = "Interface\AddOns\BLU\sounds\honor_default.ogg", duration = 2.0, category = "honorrank", source = "BLU", isInternal = true },
                level_default = { name = "Default Level Up", file = "Interface\AddOns\BLU\sounds\level_default.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                post_default = { name = "Default Trading Post", file = "Interface\AddOns\BLU\sounds\post_default.ogg", duration = 2.0, category = "tradingpost", source = "BLU", isInternal = true },
                quest_accept_default = { name = "Default Quest Accept", file = "Interface\AddOns\BLU\sounds\quest_accept_default.ogg", duration = 2.0, category = "questaccept", source = "BLU", isInternal = true },
                quest_default = { name = "Default Quest Complete", file = "Interface\AddOns\BLU\sounds\quest_default.ogg", duration = 2.0, category = "quest", source = "BLU", isInternal = true },
                renown_default = { name = "Default Renown", file = "Interface\AddOns\BLU\sounds\renown_default.ogg", duration = 2.0, category = "renownrank", source = "BLU", isInternal = true },
                rep_default = { name = "Default Reputation", file = "Interface\AddOns\BLU\sounds\rep_default.ogg", duration = 2.0, category = "reputation", source = "BLU", isInternal = true }
            }
        },
        {
            id = "blu_games",
            name = "BLU Game Sounds",
            sounds = {
                altered_beast = { name = "Altered Beast", file = "Interface\AddOns\BLU\sounds\altered_beast.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                assassins_creed = { name = "Assassin's Creed", file = "Interface\AddOns\BLU\sounds\assassins_creed.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                castlevania = { name = "Castlevania", file = "Interface\AddOns\BLU\sounds\castlevania.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                diablo_2 = { name = "Diablo 2", file = "Interface\AddOns\BLU\sounds\diablo_2.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                dota_2 = { name = "Dota 2", file = "Interface\AddOns\BLU\sounds\dota_2.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                dragon_quest = { name = "Dragon Quest", file = "Interface\AddOns\BLU\sounds\dragon_quest.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                elden_ring_1 = { name = "Elden Ring 1", file = "Interface\AddOns\BLU\sounds\elden_ring-1.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                elden_ring_2 = { name = "Elden Ring 2", file = "Interface\AddOns\BLU\sounds\elden_ring-2.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                elden_ring_3 = { name = "Elden Ring 3", file = "Interface\AddOns\BLU\sounds\elden_ring-3.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                elden_ring_4 = { name = "Elden Ring 4", file = "Interface\AddOns\BLU\sounds\elden_ring-4.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                elden_ring_5 = { name = "Elden Ring 5", file = "Interface\AddOns\BLU\sounds\elden_ring-5.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                elden_ring_6 = { name = "Elden Ring 6", file = "Interface\AddOns\BLU\sounds\elden_ring-6.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                everquest = { name = "EverQuest", file = "Interface\AddOns\BLU\sounds\everquest.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                fallout_3 = { name = "Fallout 3", file = "Interface\AddOns\BLU\sounds\fallout_3.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                fallout_new_vegas = { name = "Fallout New Vegas", file = "Interface\AddOns\BLU\sounds\fallout_new_vegas.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                final_fantasy = { name = "Final Fantasy", file = "Interface\AddOns\BLU\sounds\final_fantasy.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                fire_emblem_awakening = { name = "Fire Emblem Awakening", file = "Interface\AddOns\BLU\sounds\fire_emblem_awakening.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                fire_emblem = { name = "Fire Emblem", file = "Interface\AddOns\BLU\sounds\fire_emblem.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                fly_for_fun = { name = "Fly For Fun", file = "Interface\AddOns\BLU\sounds\fly_for_fun.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                fortnite = { name = "Fortnite", file = "Interface\AddOns\BLU\sounds\fortnite.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                gta_san_andreas = { name = "GTA San Andreas", file = "Interface\AddOns\BLU\sounds\gta_san_andreas.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                kingdom_hearts_3 = { name = "Kingdom Hearts 3", file = "Interface\AddOns\BLU\sounds\kingdom_hearts_3.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                kirby_1 = { name = "Kirby 1", file = "Interface\AddOns\BLU\sounds\kirby-1.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                kirby_2 = { name = "Kirby 2", file = "Interface\AddOns\BLU\sounds\kirby-2.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                league_of_legends = { name = "League of Legends", file = "Interface\AddOns\BLU\sounds\league_of_legends.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                legend_of_zelda = { name = "Legend of Zelda", file = "Interface\AddOns\BLU\sounds\legend_of_zelda.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                maplestory = { name = "Maplestory", file = "Interface\AddOns\BLU\sounds\maplestory.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                metalgear_solid = { name = "Metal Gear Solid", file = "Interface\AddOns\BLU\sounds\metalgear_solid.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                minecraft = { name = "Minecraft", file = "Interface\AddOns\BLU\sounds\minecraft.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                modern_warfare_2 = { name = "Modern Warfare 2", file = "Interface\AddOns\BLU\sounds\modern_warfare_2.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                morrowind = { name = "Morrowind", file = "Interface\AddOns\BLU\sounds\morrowind.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                old_school_runescape = { name = "Old School Runescape", file = "Interface\AddOns\BLU\sounds\old_school_runescape.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                palworld = { name = "Palworld", file = "Interface\AddOns\BLU\sounds\palworld.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                path_of_exile = { name = "Path of Exile", file = "Interface\AddOns\BLU\sounds\path_of_exile.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                pokemon = { name = "Pokemon", file = "Interface\AddOns\BLU\sounds\pokemon.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                ragnarok_online = { name = "Ragnarok Online", file = "Interface\AddOns\BLU\sounds\ragnarok_online.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                shining_force_2 = { name = "Shining Force 2", file = "Interface\AddOns\BLU\sounds\shining_force_2.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                shining_force_3_1 = { name = "Shining Force 3-1", file = "Interface\AddOns\BLU\sounds\shining_force_3-1.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                shining_force_3_10 = { name = "Shining Force 3-10", file = "Interface\AddOns\BLU\sounds\shining_force_3-10.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                shining_force_3_11 = { name = "Shining Force 3-11", file = "Interface\AddOns\BLU\sounds\shining_force_3-11.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                shining_force_3_2 = { name = "Shining Force 3-2", file = "Interface\AddOns\BLU\sounds\shining_force_3-2.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                shining_force_3_3 = { name = "Shining Force 3-3", file = "Interface\AddOns\BLU\sounds\shining_force_3-3.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                shining_force_3_4 = { name = "Shining Force 3-4", file = "Interface\AddOns\BLU\sounds\shining_force_3-4.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                shining_force_3_5 = { name = "Shining Force 3-5", file = "Interface\AddOns\BLU\sounds\shining_force_3-5.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                shining_force_3_6 = { name = "Shining Force 3-6", file = "Interface\AddOns\BLU\sounds\shining_force_3-6.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                shining_force_3_7 = { name = "Shining Force 3-7", file = "Interface\AddOns\BLU\sounds\shining_force_3-7.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                shining_force_3_8 = { name = "Shining Force 3-8", file = "Interface\AddOns\BLU\sounds\shining_force_3-8.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                shining_force_3_9 = { name = "Shining Force 3-9", file = "Interface\AddOns\BLU\sounds\shining_force_3-9.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                skyrim = { name = "Skyrim", file = "Interface\AddOns\BLU\sounds\skyrim.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                sonic_the_hedgehog = { name = "Sonic The Hedgehog", file = "Interface\AddOns\BLU\sounds\sonic_the_hedgehog.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                spyro_the_dragon = { name = "Spyro The Dragon", file = "Interface\AddOns\BLU\sounds\spyro_the_dragon.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                super_mario_bros_3 = { name = "Super Mario Bros 3", file = "Interface\AddOns\BLU\sounds\super_mario_bros_3.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                warcraft_3 = { name = "Warcraft 3", file = "Interface\AddOns\BLU\sounds\warcraft_3.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                warcraft_3_2 = { name = "Warcraft 3-2", file = "Interface\AddOns\BLU\sounds\warcraft_3-2.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                warcraft_3_3 = { name = "Warcraft 3-3", file = "Interface\AddOns\BLU\sounds\warcraft_3-3.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                witcher_3_1 = { name = "Witcher 3-1", file = "Interface\AddOns\BLU\sounds\witcher_3-1.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
                witcher_3_2 = { name = "Witcher 3-2", file = "Interface\AddOns\BLU\sounds\witcher_3-2.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true }
            }
        }
    }

    for _, pack in ipairs(bluSoundPacks) do
        if BLU.RegisterSoundPack then
            BLU:RegisterSoundPack(pack.id, pack.name, pack.sounds)
            BLU:PrintDebug(string.format("Registered BLU sound pack: %s (%d sounds)", pack.name, countTableEntries(pack.sounds)))
        end
    end

    -- Verify sound registry has content
    if BLU.Registry and BLU.Registry.GetAllSounds then
        local sounds = BLU.Registry:GetAllSounds()
        local count = 0
        for _ in pairs(sounds) do
            count = count + 1
        end
        BLU:PrintDebug("Total sounds registered in registry: " .. count)
    end

end

-- Get all internal sounds for a category
function InternalSounds:GetSoundsForCategory(category)
    if not BLU.Registry or not BLU.Registry.GetSoundsByCategory then
        return {}
    end
    
    return BLU.Registry:GetSoundsByCategory(category)
end

-- Test play a sound
function InternalSounds:TestSound(soundId)
    if BLU.Registry and BLU.Registry.PlaySound then
        BLU.Registry:PlaySound(soundId)
        BLU:Print("Playing test sound: " .. (soundId or "none"))
    end
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["internal_sounds"] = InternalSounds