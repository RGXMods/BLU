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

    -- Register default sounds pack
    local defaultPack = {
        id = "blu_default",
        name = "BLU Defaults",
        sounds = {
            achievement_default = { name = "Default Achievement", file = "Interface\\AddOns\\BLU\\sounds\\achievement_default.ogg", duration = 2.0, category = "achievement", source = "BLU", isInternal = true },
            battle_pet_level_default = { name = "Default Battle Pet Level", file = "Interface\\AddOns\\BLU\\sounds\\battle_pet_level_default.ogg", duration = 2.0, category = "battlepet", source = "BLU", isInternal = true },
            honor_default = { name = "Default Honor", file = "Interface\\AddOns\\BLU\\sounds\\honor_default.ogg", duration = 2.0, category = "honorrank", source = "BLU", isInternal = true },
            level_default = { name = "Default Level Up", file = "Interface\\AddOns\\BLU\\sounds\\level_default.ogg", duration = 2.0, category = "levelup", source = "BLU", isInternal = true },
            post_default = { name = "Default Trading Post", file = "Interface\\AddOns\\BLU\\sounds\\post_default.ogg", duration = 2.0, category = "tradingpost", source = "BLU", isInternal = true },
            quest_accept_default = { name = "Default Quest Accept", file = "Interface\\AddOns\\BLU\\sounds\\quest_accept_default.ogg", duration = 2.0, category = "questaccept", source = "BLU", isInternal = true },
            quest_default = { name = "Default Quest Complete", file = "Interface\\AddOns\\BLU\\sounds\\quest_default.ogg", duration = 2.0, category = "quest", source = "BLU", isInternal = true },
            renown_default = { name = "Default Renown", file = "Interface\\AddOns\\BLU\\sounds\\renown_default.ogg", duration = 2.0, category = "renownrank", source = "BLU", isInternal = true },
            rep_default = { name = "Default Reputation", file = "Interface\\AddOns\\BLU\\sounds\\rep_default.ogg", duration = 2.0, category = "reputation", source = "BLU", isInternal = true }
        }
    }
    if BLU.RegisterSoundPack then
        BLU:RegisterSoundPack(defaultPack.id, defaultPack.name, defaultPack.sounds)
        BLU:PrintDebug(string.format("Registered BLU sound pack: %s (%d sounds)", defaultPack.name, countTableEntries(defaultPack.sounds)))
    end

    -- Register game sound packs
    local gamePacks = {
        { id = "altered_beast", name = "Altered Beast", file_id = "altered_beast" },
        { id = "assassins_creed", name = "Assassin's Creed", file_id = "assassins_creed" },
        { id = "castlevania", name = "Castlevania", file_id = "castlevania" },
        { id = "diablo_2", name = "Diablo 2", file_id = "diablo_2" },
        { id = "dota_2", name = "Dota 2", file_id = "dota_2" },
        { id = "dragon_quest", name = "Dragon Quest", file_id = "dragon_quest" },
        { id = "elden_ring_1", name = "Elden Ring 1", file_id = "elden_ring-1" },
        { id = "elden_ring_2", name = "Elden Ring 2", file_id = "elden_ring-2" },
        { id = "elden_ring_3", name = "Elden Ring 3", file_id = "elden_ring-3" },
        { id = "elden_ring_4", name = "Elden Ring 4", file_id = "elden_ring-4" },
        { id = "elden_ring_5", name = "Elden Ring 5", file_id = "elden_ring-5" },
        { id = "elden_ring_6", name = "Elden Ring 6", file_id = "elden_ring-6" },
        { id = "everquest", name = "EverQuest", file_id = "everquest" },
        { id = "fallout_3", name = "Fallout 3", file_id = "fallout_3" },
        { id = "fallout_new_vegas", name = "Fallout New Vegas", file_id = "fallout_new_vegas" },
        { id = "final_fantasy", name = "Final Fantasy", file_id = "final_fantasy" },
        { id = "fire_emblem_awakening", name = "Fire Emblem Awakening", file_id = "fire_emblem_awakening" },
        { id = "fire_emblem", name = "Fire Emblem", file_id = "fire_emblem" },
        { id = "fly_for_fun", name = "Fly For Fun", file_id = "fly_for_fun" },
        { id = "fortnite", name = "Fortnite", file_id = "fortnite" },
        { id = "gta_san_andreas", name = "GTA San Andreas", file_id = "gta_san_andreas" },
        { id = "kingdom_hearts_3", name = "Kingdom Hearts 3", file_id = "kingdom_hearts_3" },
        { id = "kirby_1", name = "Kirby 1", file_id = "kirby-1" },
        { id = "kirby_2", name = "Kirby 2", file_id = "kirby-2" },
        { id = "league_of_legends", name = "League of Legends", file_id = "league_of_legends" },
        { id = "legend_of_zelda", name = "Legend of Zelda", file_id = "legend_of_zelda" },
        { id = "maplestory", name = "Maplestory", file_id = "maplestory" },
        { id = "metalgear_solid", name = "Metal Gear Solid", file_id = "metalgear_solid" },
        { id = "minecraft", name = "Minecraft", file_id = "minecraft" },
        { id = "modern_warfare_2", name = "Modern Warfare 2", file_id = "modern_warfare_2" },
        { id = "morrowind", name = "Morrowind", file_id = "morrowind" },
        { id = "old_school_runescape", name = "Old School Runescape", file_id = "old_school_runescape" },
        { id = "palworld", name = "Palworld", file_id = "palworld" },
        { id = "path_of_exile", name = "Path of Exile", file_id = "path_of_exile" },
        { id = "pokemon", name = "Pokemon", file_id = "pokemon" },
        { id = "ragnarok_online", name = "Ragnarok Online", file_id = "ragnarok_online" },
        { id = "shining_force_2", name = "Shining Force 2", file_id = "shining_force_2" },
        { id = "shining_force_3_1", name = "Shining Force 3-1", file_id = "shining_force_3-1" },
        { id = "shining_force_3_10", name = "Shining Force 3-10", file_id = "shining_force_3-10" },
        { id = "shining_force_3_11", name = "Shining Force 3-11", file_id = "shining_force_3-11" },
        { id = "shining_force_3_2", name = "Shining Force 3-2", file_id = "shining_force_3-2" },
        { id = "shining_force_3_3", name = "Shining Force 3-3", file_id = "shining_force_3-3" },
        { id = "shining_force_3_4", name = "Shining Force 3-4", file_id = "shining_force_3-4" },
        { id = "shining_force_3_5", name = "Shining Force 3-5", file_id = "shining_force_3-5" },
        { id = "shining_force_3_6", name = "Shining Force 3-6", file_id = "shining_force_3-6" },
        { id = "shining_force_3_7", name = "Shining Force 3-7", file_id = "shining_force_3-7" },
        { id = "shining_force_3_8", name = "Shining Force 3-8", file_id = "shining_force_3-8" },
        { id = "shining_force_3_9", name = "Shining Force 3-9", file_id = "shining_force_3-9" },
        { id = "skyrim", name = "Skyrim", file_id = "skyrim" },
        { id = "sonic_the_hedgehog", name = "Sonic The Hedgehog", file_id = "sonic_the_hedgehog" },
        { id = "spyro_the_dragon", name = "Spyro The Dragon", file_id = "spyro_the_dragon" },
        { id = "super_mario_bros_3", name = "Super Mario Bros 3", file_id = "super_mario_bros_3" },
        { id = "warcraft_3", name = "Warcraft 3", file_id = "warcraft_3" },
        { id = "warcraft_3_2", name = "Warcraft 3-2", file_id = "warcraft_3-2" },
        { id = "warcraft_3_3", name = "Warcraft 3-3", file_id = "warcraft_3-3" },
        { id = "witcher_3_1", name = "Witcher 3-1", file_id = "witcher_3-1" },
        { id = "witcher_3_2", name = "Witcher 3-2", file_id = "witcher_3-2" },
    }

    for _, packData in ipairs(gamePacks) do
        local sounds = {
            [packData.id] = {
                name = packData.name,
                file = "Interface\\AddOns\\BLU\\sounds\" .. packData.file_id .. ".ogg",
                duration = 2.0,
                category = packData.category or "levelup",
                source = "BLU",
                isInternal = true
            }
        }
        if BLU.RegisterSoundPack then
            BLU:RegisterSoundPack(packData.id, packData.name, sounds)
            BLU:PrintDebug(string.format("Registered BLU sound pack: %s (%d sounds)", packData.name, 1))
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
