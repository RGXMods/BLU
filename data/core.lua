--v4.0.3
-- BLU is an addon that provides sound effects for various events in World of Warcraft.
-- This file contains the core functionality of the addon, including event registration and sound playback.
-- The addon uses Ace3 libraries for configuration and database management.
-- The sounds are stored in the "sounds" folder within the addon directory.
-- The addon can be configured using the "/blu" or "/lu" chat commands.
BLU = LibStub("AceAddon-3.0"):NewAddon("BLU", "AceEvent-3.0", "AceConsole-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local functionsHalted = false
function BLU:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("BLUDB", self.defaults, true)
    AC:RegisterOptionsTable("BLU_Options", self.options)
    self.optionsFrame = ACD:AddToBlizOptions("BLU_Options", "Better Level Up!")
    profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    AC:RegisterOptionsTable("BLU_Profiles", profiles)
    ACD:AddToBlizOptions("BLU_Profiles", "Profiles", "Better Level Up!")
    self:RegisterChatCommand("lu", "SlashCommand")
    self:RegisterChatCommand("blu", "SlashCommand")
end
function BLU:OnEnable()
    self:RegisterEvent("ACHIEVEMENT_EARNED")
    self:RegisterEvent("HONOR_LEVEL_UPDATE")
    self:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
    self:RegisterEvent("PERKS_ACTIVITY_COMPLETED")
    self:RegisterEvent("PET_BATTLE_LEVEL_CHANGED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_LEVEL_UP")
    self:RegisterEvent("QUEST_ACCEPTED")
    self:RegisterEvent("QUEST_TURNED_IN")
    self:RegisterEvent("UPDATE_FACTION")
end
function BLU:PLAYER_ENTERING_WORLD(...)
    C_Timer.After(15, function()
        functionsHalted = false
    end)
    functionsHalted = true
    self:MuteSounds()
end
local muteSoundIDs = {
    569143,
    1489546,
    569593,
    642841,
    4745441,
    568016,
    567400,
    567439,
    2066672
}
function BLU:MuteSounds()
    for _, soundID in ipairs(muteSoundIDs) do
        MuteSoundFile(soundID)
    end
end
local defaultAchievementSounds = {
    [1] = "Interface\\Addons\\BLU\\sounds\\achievement_default_low.ogg",
    [2] = "Interface\\Addons\\BLU\\sounds\\achievement_default_med.ogg",
    [3] = "Interface\\Addons\\BLU\\sounds\\achievement_default_high.ogg"
}
local defaultHonorSounds = {
    [1] = "Interface\\Addons\\BLU\\sounds\\honor_default_low.ogg",
    [2] = "Interface\\Addons\\BLU\\sounds\\honor_default_med.ogg",
    [3] = "Interface\\Addons\\BLU\\sounds\\honor_default_high.ogg"
}
local defaultLevelSounds = {
    [1] = "Interface\\Addons\\BLU\\sounds\\level_default_low.ogg",
    [2] = "Interface\\Addons\\BLU\\sounds\\level_default_med.ogg",
    [3] = "Interface\\Addons\\BLU\\sounds\\level_default_high.ogg"
}
local defaultBattlePetLevelSounds = {
    [1] = "Interface\\Addons\\BLU\\sounds\\battle_pet_level_default_low.ogg",
    [2] = "Interface\\Addons\\BLU\\sounds\\battle_pet_level_default_med.ogg",
    [3] = "Interface\\Addons\\BLU\\sounds\\battle_pet_level_default_high.ogg"
}
local defaultRenownSounds = {
    [1] = "Interface\\Addons\\BLU\\sounds\\renown_default_low.ogg",
    [2] = "Interface\\Addons\\BLU\\sounds\\renown_default_med.ogg",
    [3] = "Interface\\Addons\\BLU\\sounds\\renown_default_high.ogg"
}
local defaultRepSounds = {
    [1] = "Interface\\Addons\\BLU\\sounds\\rep_default_low.ogg",
    [2] = "Interface\\Addons\\BLU\\sounds\\rep_default_med.ogg",
    [3] = "Interface\\Addons\\BLU\\sounds\\rep_default_high.ogg"
}
local defaultQuestAcceptSounds = {
    [1] = "Interface\\Addons\\BLU\\sounds\\quest_accept_default_low.ogg",
    [2] = "Interface\\Addons\\BLU\\sounds\\quest_accept_default_med.ogg",
    [3] = "Interface\\Addons\\BLU\\sounds\\quest_accept_default_high.ogg"
}
local defaultQuestSounds = {
    [1] = "Interface\\Addons\\BLU\\sounds\\quest_default_low.ogg",
    [2] = "Interface\\Addons\\BLU\\sounds\\quest_default_med.ogg",
    [3] = "Interface\\Addons\\BLU\\sounds\\quest_default_high.ogg"
}
local defaultPostSounds = {
    [1] = "Interface\\Addons\\BLU\\sounds\\post_default_low.ogg",
    [2] = "Interface\\Addons\\BLU\\sounds\\post_default_med.ogg",
    [3] = "Interface\\Addons\\BLU\\sounds\\post_default_high.ogg"
}
local sounds = {
    [3] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\altered_beast_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\altered_beast_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\altered_beast_high.ogg"
    },
    [4] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\assassins_creed_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\assassins_creed_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\assassins_creed_high.ogg"
    },
    [5] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\castlevania_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\castlevania_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\castlevania_high.ogg"
    },
    [6] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\diablo_2_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\diablo_2_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\diablo_2_high.ogg"
    },
    [7] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\dragon_quest_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\dragon_quest_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\dragon_quest_high.ogg"
    },
    [8] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\dota_2_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\dota_2_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\dota_2_high.ogg"
    },
    [9] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\everquest_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\everquest_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\everquest_high.ogg"
    },
    [10] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\fallout_new_vegas_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\fallout_new_vegas_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\fallout_new_vegas_high.ogg"
    },
    [11] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\fallout_3_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\fallout_3_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\fallout_3_high.ogg"
    },
    [12] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\final_fantasy_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\final_fantasy_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\final_fantasy_high.ogg"
    },
    [13] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\fire_emblem_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\fire_emblem_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\fire_emblem_high.ogg"
    },
    [14] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\fire_emblem_awakening_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\fire_emblem_awakening_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\fire_emblem_awakening_high.ogg"
    },
    [15] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\fly_for_fun_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\fly_for_fun_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\fly_for_fun_high.ogg"
    },
    [16] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\fortnite_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\fortnite_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\fortnite_high.ogg"
    },
    [17] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\gta_san_andreas_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\gta_san_andreas_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\gta_san_andreas_high.ogg"
    },
    [18] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\kingdom_hearts_3_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\kingdom_hearts_3_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\kingdom_hearts_3_high.ogg"
    },
    [19] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\kirby-1_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\kirby-1_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\kirby-1_high.ogg"
    },
    [20] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\kirby-2_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\kirby-2_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\kirby-2_high.ogg"
    },
    [21] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\league_of_legends_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\league_of_legends_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\league_of_legends_high.ogg"
    },
    [22] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\legend_of_zelda_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\legend_of_zelda_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\legend_of_zelda_high.ogg"
    },
    [23] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\maplestory_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\maplestory_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\maplestory_high.ogg"
    },
    [24] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\metalgear_solid_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\metalgear_solid_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\metalgear_solid_high.ogg"
    },
    [25] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\minecraft_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\minecraft_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\minecraft_high.ogg"
    },
    [26] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\modern_warfare_2_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\modern_warfare_2_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\modern_warfare_2_high.ogg"
    },
    [27] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\morrowind_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\morrowind_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\morrowind_high.ogg"
    },
    [28] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\old_school_runescape_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\old_school_runescape_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\old_school_runescape_high.ogg"
    },
    [29] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\palworld_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\palworld_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\palworld_high.ogg"
    },
    [30] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\path_of_exile_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\path_of_exile_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\path_of_exile_high.ogg"
    },
    [31] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\pokemon_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\pokemon_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\pokemon_high.ogg"
    },
    [32] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\ragnarok_online_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\ragnarok_online_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\ragnarok_online_high.ogg"
    },
    [33] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\shining_force_2_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\shining_force_2_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\shining_force_2_high.ogg"
    },
    [34] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-1_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-1_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-1_high.ogg"
    },
    [35] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-2_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-2_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-2_haigh.ogg"
    },
    [36] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-3_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-3_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-3_high.ogg"
    },
    [37] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-4_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-4_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-4_high.ogg"
    },
    [38] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-5_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-5_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-5_high.ogg"
    },
    [39] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-6_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-6_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-6_high.ogg"
    },
    [40] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-7_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-7_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-7_high.ogg"
    },
    [41] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-8_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-8_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-8_high.ogg"
    },
    [42] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-9_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-9_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-9_high.ogg"
    },
    [43] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-10_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-10_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-10_high.ogg"
    },
    [44] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-11_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-11_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-11_high.ogg"
    },
    [45] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\skyrim_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\skyrim_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\skyrim_high.ogg"
    },
    [46] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\sonic_the_hedgehog_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\sonic_the_hedgehog_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\sonic_the_hedgehog_high.ogg"
    },
    [47] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\spyro_the_dragon_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\spyro_the_dragon_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\spyro_the_dragon_high.ogg"
    },
    [48] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\super_mario_bros_3_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\super_mario_bros_3_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\super_mario_bros_3_high.ogg"
    },
    [49] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\warcraft_3_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\warcraft_3_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\warcraft_3_high.ogg"
    },
    [50] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\witcher_3-1_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\witcher_3-1_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\witcher_3-1_high.ogg"
    },
    [51] = {
        [1] = "Interface\\Addons\\BLU\\sounds\\witcher_3-2_low.ogg",
        [2] = "Interface\\Addons\\BLU\\sounds\\witcher_3-2_med.ogg",
        [3] = "Interface\\Addons\\BLU\\sounds\\witcher_3-2_high.ogg"
    },
}
local defaultSounds = {
    defaultAchievementSounds,
    defaultHonorSounds,
    defaultLevelSounds,
    defaultBattlePetLevelSounds,
    defaultRenownSounds,
    defaultRepSounds,
    defaultQuestAcceptSounds,
    defaultQuestSounds,
    defaultPostSounds
}
local function RandomSoundID()
    local validSoundIDs = {}
    for i, _ in pairs(sounds) do
        if i ~= 2 then
            table.insert(validSoundIDs, i)
        end
    end
    for _, soundList in ipairs(defaultSounds) do
        for soundID, _ in pairs(soundList) do
            table.insert(validSoundIDs, soundID)
        end
    end
    local randomIndex = math.random(1, #validSoundIDs)
    return validSoundIDs[randomIndex]
end
local function SelectSound(soundID)
    if soundID == 2 then
        soundID = RandomSoundID()
    end
    return soundID
end
function BLU:ACHIEVEMENT_EARNED(event, ...)
    if functionsHalted then return end
    local soundID = SelectSound(BLU.db.profile.AchievementSoundSelect)
    local volumeLevel = BLU.db.profile.AchievementVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if soundID == 1 then
        soundFile = defaultAchievementSounds[volumeLevel]
    else
        soundFile = sounds[soundID][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
function TestAchievementSound()
    local soundID = SelectSound(BLU.db.profile.AchievementSoundSelect)
    local volumeLevel = BLU.db.profile.AchievementVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if soundID == 1 then
        soundFile = defaultAchievementSounds[volumeLevel]
    else
        soundFile = sounds[soundID][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
function BLU:PET_BATTLE_LEVEL_CHANGED(event, ...)
    if functionsHalted then return end
    local soundID = SelectSound(BLU.db.profile.BattlePetLevelSoundSelect)
    local volumeLevel = BLU.db.profile.BattlePetLevelVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if soundID == 1 then
        soundFile = defaultBattlePetLevelSounds[volumeLevel]
    else
        soundFile = sounds[soundID][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
function TestBattlePetLevelSound()
    local soundID = SelectSound(BLU.db.profile.BattlePetLevelSoundSelect)
    local volumeLevel = BLU.db.profile.BattlePetLevelVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if soundID == 1 then
        soundFile = defaultBattlePetLevelSounds[volumeLevel]
    else
        soundFile = sounds[soundID][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
function BLU:HONOR_LEVEL_UPDATE(event, ...)
    if functionsHalted then return end
    local soundID = SelectSound(BLU.db.profile.HonorSoundSelect)
    local volumeLevel = BLU.db.profile.HonorVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if soundID == 1 then
        soundFile = defaultHonorSounds[volumeLevel]
    else
        soundFile = sounds[soundID][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
function TestHonorSound()
    local soundID = SelectSound(BLU.db.profile.HonorSoundSelect)
    local volumeLevel = BLU.db.profile.HonorVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if soundID == 1 then
        soundFile = defaultHonorLevelSounds[volumeLevel]
    else
        soundFile = sounds[soundID][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
function BLU:PLAYER_LEVEL_UP(event, ...)
    if functionsHalted then return end
    local soundID = SelectSound(BLU.db.profile.LevelSoundSelect)
    local volumeLevel = BLU.db.profile.LevelVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if soundID == 1 then
        soundFile = defaultLevelUpSounds[volumeLevel]
    else
        soundFile = sounds[soundID][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
function TestLevelSound()
    local soundID = SelectSound(BLU.db.profile.LevelSoundSelect)
    local volumeLevel = BLU.db.profile.LevelVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if soundID == 1 then
        soundFile = defaultLevelSounds[volumeLevel]
    else
        soundFile = sounds[soundID][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
function BLU:MAJOR_FACTION_RENOWN_LEVEL_CHANGED(event, ...)
    if functionsHalted then return end
    local soundID = SelectSound(BLU.db.profile.RenownSoundSelect)
    local volumeLevel = BLU.db.profile.RenownVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if soundID == 1 then
        soundFile = defaultRenownSounds[volumeLevel]
    else
        soundFile = sounds[soundID][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
function TestRenownSound()
    local soundID = SelectSound(BLU.db.profile.RenownSoundSelect)
    local volumeLevel = BLU.db.profile.RenownVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if soundID == 1 then
        soundFile = defaultRenownSounds[volumeLevel]
    else
        soundFile = sounds[soundID][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
local TrackedFactions = {}
function BLU:UPDATE_FACTION(event, ...)
    if functionsHalted then return end
    for i = 1, GetNumFactions() do
        local _, _, newstanding, _, _, _, _, _, isheader, _, hasrep, _, _, faction = GetFactionInfo(i)
        if not faction then return nil end
        if (not isheader or hasrep) and (newstanding or 0) > 0 then
            local oldstanding = TrackedFactions[faction]
            if oldstanding and oldstanding < newstanding and BLU.db.profile.RepSoundSelect then
                local soundID = SelectSound(BLU.db.profile.RepSoundSelect)
                local volumeLevel = BLU.db.profile.RepVolume
                local soundFile
                if volumeLevel == 0 then
                    return
                end
                if soundID == 1 then
                    soundFile = defaultRepSounds[volumeLevel]
                else
                    soundFile = sounds[soundID][volumeLevel]
                end
                PlaySoundFile(soundFile, "MASTER")
            end
            TrackedFactions[faction] = newstanding
        end
    end
end
function TestRepSound()
    local soundID = SelectSound(BLU.db.profile.RepSoundSelect)
    local volumeLevel = BLU.db.profile.RepVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if soundID == 1 then
        soundFile = defaultRepSounds[volumeLevel]
    else
        soundFile = sounds[soundID][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
function BLU:QUEST_ACCEPTED(event, ...)
    if functionsHalted then return end
    local soundID = SelectSound(BLU.db.profile.QuestAcceptSoundSelect)
    local volumeLevel = BLU.db.profile.QuestAcceptVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if soundID == 1 then
        soundFile = defaultQuestAcceptSounds[volumeLevel]
    else
        soundFile = sounds[soundID][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
function TestQuestAcceptSound()
    local soundID = SelectSound(BLU.db.profile.QuestAcceptSoundSelect)
    local volumeLevel = BLU.db.profile.QuestAcceptVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if soundID == 1 then
        soundFile = defaultQuestAcceptSounds[volumeLevel]
    else
        soundFile = sounds[soundID][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
function BLU:QUEST_TURNED_IN(event, ...)
    if functionsHalted then return end
    local soundID = SelectSound(BLU.db.profile.QuestSoundSelect)
    local volumeLevel = BLU.db.profile.QuestVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if soundID == 1 then
        soundFile = defaultQuestSounds[volumeLevel]
    else
        if sounds[soundID] then
            soundFile = sounds[soundID][volumeLevel]
        end
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
function TestQuestSound()
    local soundID = SelectSound(BLU.db.profile.QuestSoundSelect)
    local volumeLevel = BLU.db.profile.QuestVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if soundID == 1 then
        soundFile = defaultQuestSounds[volumeLevel]
    else
        soundFile = sounds[soundID][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
function BLU:PERKS_ACTIVITY_COMPLETED(event, ...)
    if functionsHalted then return end
    local soundID = SelectSound(BLU.db.profile.PostSoundSelect)
    local volumeLevel = BLU.db.profile.PostVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if soundID == 1 then
        soundFile = defaultPostSounds[volumeLevel]
    else
        soundFile = sounds[soundID][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
function TestPostSound()
    local soundID = SelectSound(BLU.db.profile.PostSoundSelect)
    local volumeLevel = BLU.db.profile.PostVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if soundID == 1 then
        soundFile = defaultPostSounds[volumeLevel]
    else
        soundFile = sounds[soundID][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
function BLU:SlashCommand(input, editbox)
    if input == "enable" then
        self:Enable()
        self:Print("Enabled.")
    elseif input == "disable" then
        self:Disable()
        self:Print("Disabled.")
    else
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    end
end