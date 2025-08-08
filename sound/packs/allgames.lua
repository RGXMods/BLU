--=====================================================================================
-- BLU - sound/packs/allgames.lua
-- All other games sound pack (comprehensive mapping)
--=====================================================================================

local addonName, BLU = ...

local sounds = {
    -- ELDEN RING (6 variants)
    eldenring_levelup_1 = {
        name = "Elden Ring - Rune Acquired 1",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\elden_ring-1.ogg",
        duration = 4.0,
        category = "levelup"
    },
    eldenring_achievement_2 = {
        name = "Elden Ring - Boss Defeated 2",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\elden_ring-2.ogg",
        duration = 2.0,
        category = "achievement"
    },
    eldenring_quest_3 = {
        name = "Elden Ring - Item Discovery 3",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\elden_ring-3.ogg",
        duration = 3.0,
        category = "quest"
    },
    eldenring_levelup_4 = {
        name = "Elden Ring - Level Up 4",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\elden_ring-4.ogg",
        duration = 5.0,
        category = "levelup"
    },
    eldenring_achievement_5 = {
        name = "Elden Ring - Great Rune 5",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\elden_ring-5.ogg",
        duration = 2.5,
        category = "achievement"
    },
    eldenring_reputation_6 = {
        name = "Elden Ring - Covenant 6",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\elden_ring-6.ogg",
        duration = 1.5,
        category = "reputation"
    },
    
    -- SHINING FORCE 3 (11 variants)
    shiningforce3_levelup_1 = {
        name = "Shining Force 3 - Level Up 1",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\shining_force_3-1.ogg",
        duration = 4.0,
        category = "levelup"
    },
    shiningforce3_battle_2 = {
        name = "Shining Force 3 - Battle Theme 2",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\shining_force_3-2.ogg",
        duration = 2.5,
        category = "achievement"
    },
    shiningforce3_victory_3 = {
        name = "Shining Force 3 - Victory 3",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\shining_force_3-3.ogg",
        duration = 8.0,
        category = "quest"
    },
    
    -- ASSASSIN'S CREED
    assassinscreed_levelup = {
        name = "Assassin's Creed - Synchronization",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\assassins_creed.ogg",
        duration = 7.0,
        category = "levelup"
    },
    
    -- CASTLEVANIA
    castlevania_levelup = {
        name = "Castlevania - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\castlevania.ogg",
        duration = 1.5,
        category = "levelup"
    },
    
    -- DOTA 2
    dota2_levelup = {
        name = "Dota 2 - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\dota_2.ogg",
        duration = 8.0,
        category = "levelup"
    },
    
    -- DRAGON QUEST
    dragonquest_levelup = {
        name = "Dragon Quest - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\dragon_quest.ogg",
        duration = 2.0,
        category = "levelup"
    },
    
    -- EVERQUEST
    everquest_levelup = {
        name = "EverQuest - Ding!",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\everquest.ogg",
        duration = 2.0,
        category = "levelup"
    },
    
    -- FALLOUT
    fallout3_levelup = {
        name = "Fallout 3 - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\fallout_3.ogg",
        duration = 6.0,
        category = "levelup"
    },
    falloutnv_levelup = {
        name = "Fallout New Vegas - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\fallout_new_vegas.ogg",
        duration = 8.0,
        category = "levelup"
    },
    
    -- FIRE EMBLEM
    fireemblem_levelup = {
        name = "Fire Emblem - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\fire_emblem.ogg",
        duration = 1.5,
        category = "levelup"
    },
    fireemblem_awakening_levelup = {
        name = "Fire Emblem Awakening - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\fire_emblem_awakening.ogg",
        duration = 2.0,
        category = "levelup"
    },
    
    -- FLY FOR FUN
    flyforfun_levelup = {
        name = "Fly For Fun - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\fly_for_fun.ogg",
        duration = 5.0,
        category = "levelup"
    },
    
    -- FORTNITE
    fortnite_levelup = {
        name = "Fortnite - Victory Royale",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\fortnite.ogg",
        duration = 2.5,
        category = "levelup"
    },
    
    -- GTA SAN ANDREAS
    gta_mission = {
        name = "GTA San Andreas - Mission Passed",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\gta_san_andreas.ogg",
        duration = 6.0,
        category = "quest"
    },
    
    -- KINGDOM HEARTS 3
    kingdomhearts_levelup = {
        name = "Kingdom Hearts 3 - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\kingdom_hearts_3.ogg",
        duration = 4.5,
        category = "levelup"
    },
    
    -- KIRBY
    kirby_levelup_1 = {
        name = "Kirby - Stage Clear",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\kirby-1.ogg",
        duration = 1.5,
        category = "levelup"
    },
    kirby_achievement_2 = {
        name = "Kirby - 1-Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\kirby-2.ogg",
        duration = 1.0,
        category = "achievement"
    },
    
    -- LEAGUE OF LEGENDS
    lol_levelup = {
        name = "League of Legends - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\league_of_legends.ogg",
        duration = 3.0,
        category = "levelup"
    },
    
    -- MAPLESTORY
    maplestory_levelup = {
        name = "MapleStory - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\maplestory.ogg",
        duration = 2.5,
        category = "levelup"
    },
    
    -- METAL GEAR SOLID
    mgs_alert = {
        name = "Metal Gear Solid - Alert",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\metalgear_solid.ogg",
        duration = 3.0,
        category = "achievement"
    },
    
    -- MINECRAFT
    minecraft_levelup = {
        name = "Minecraft - Experience",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\minecraft.ogg",
        duration = 2.0,
        category = "levelup"
    },
    
    -- MODERN WARFARE 2
    mw2_levelup = {
        name = "Modern Warfare 2 - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\modern_warfare_2.ogg",
        duration = 5.0,
        category = "levelup"
    },
    
    -- OLD SCHOOL RUNESCAPE
    osrs_levelup = {
        name = "Old School RuneScape - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\old_school_runescape.ogg",
        duration = 4.0,
        category = "levelup"
    },
    
    -- PALWORLD
    palworld_levelup = {
        name = "Palworld - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\palworld.ogg",
        duration = 2.0,
        category = "levelup"
    },
    
    -- PATH OF EXILE
    poe_levelup = {
        name = "Path of Exile - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\path_of_exile.ogg",
        duration = 2.5,
        category = "levelup"
    },
    
    -- RAGNAROK ONLINE
    ragnarok_levelup = {
        name = "Ragnarok Online - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\ragnarok_online.ogg",
        duration = 1.5,
        category = "levelup"
    },
    
    -- SHINING FORCE 2
    shiningforce2_levelup = {
        name = "Shining Force 2 - Level Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\shining_force_2.ogg",
        duration = 7.0,
        category = "levelup"
    },
    
    -- SPYRO THE DRAGON
    spyro_levelup = {
        name = "Spyro - Gem Collect",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\spyro_the_dragon.ogg",
        duration = 1.5,
        category = "levelup"
    },
    
    -- ALTERED BEAST
    alteredbeast_levelup = {
        name = "Altered Beast - Power Up",
        file = "Interface\\AddOns\\BLU\\media\\sounds\\altered_beast.ogg",
        duration = 2.0,
        category = "levelup"
    }
}

-- Register the sound pack
if BLU.RegisterSoundPack then
    BLU:RegisterSoundPack("allgames", "All Games Collection", sounds)
end